//General CPU code. Run on the upper trianglar part of the force matrix.
//Initail conditions are setup in a cube.																																												
// nvcc nBodyCPU.cu -o nBodyCPU -lglut -lm -lGLU -lGL
//To stop hit "control c" in the window you launched it from.

#include <sys/time.h>
#include <GL/glut.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define N 8000

#define XWindowSize 1000
#define YWindowSize 1000

#define DRAW 1000
#define DAMP 0.5

#define DT 0.001
#define STOP_TIME 2.0

#define G 1.0
#define H 1.0

#define EYE 10.0
#define FAR 50.0

// Globals
float4 Position[N], Velocity[N], Force[N]; 

void set_initail_conditions()
{
	int i,j,k,num,particles_per_side;
    	float position_start, temp;
    	float initail_seperation;
	
	temp = pow((float)N,1.0/3.0) + 0.99999;
	particles_per_side = temp;
    	position_start = -(particles_per_side -1.0)/2.0;
	initail_seperation = 2.0;
	
	num = 0;
	for(i=0; i<particles_per_side; i++)
	{
		for(j=0; j<particles_per_side; j++)
		{
			for(k=0; k<particles_per_side; k++)
			{
			    if(N <= num) break;
				Position[num].x = position_start + i*initail_seperation;
				Position[num].y = position_start + j*initail_seperation;
				Position[num].z = position_start + k*initail_seperation;
				Position[num].w = 1.0; //mass
				
				Velocity[num].x = 0.0;
				Velocity[num].y = 0.0;
				Velocity[num].z = 0.0;
				num++;
			}
		}
	}
}

void draw_picture()
{
	int i;
	
	glClear(GL_COLOR_BUFFER_BIT);
	glClear(GL_DEPTH_BUFFER_BIT);
	
	glColor3d(1.0,1.0,0.5);
	for(i=0; i<N; i++)
	{
		glPushMatrix();
		glTranslatef(Position[i].x, Position[i].y, Position[i].z);
		glutSolidSphere(0.1,20,20);
		glPopMatrix();
	}
	
	glutSwapBuffers();
}

float4 getBodyBodyForce(float4 posMe, float4 posYou)
{
	float4 forceYouOnMe;
	float dx = posYou.x - posMe.x;
	float dy = posYou.y - posMe.y;
	float dz = posYou.z - posMe.z;
	float r2 = dx*dx + dy*dy + dz*dz;
	float r = sqrt(r2);

	float forceMag  = (G*posMe.w*posYou.w)/(r2) - (H*posMe.w*posYou.w)/(r2*r2);

	forceYouOnMe.x = forceMag*dx/r;
	forceYouOnMe.y = forceMag*dy/r;
	forceYouOnMe.z = forceMag*dz/r;

	return(forceYouOnMe);
}

void getForces()
{
	float4 forceYouOnMe; 
	
	for(int i=0; i<N; i++)
	{
		Force[i].x = 0.0;
		Force[i].y = 0.0;
		Force[i].z = 0.0;
	}

	for(int i=0; i<N; i++)
	{
		for(int j=i+1; j<N; j++)
		{
			forceYouOnMe = getBodyBodyForce(Position[i], Position[j]);
			Force[i].x += forceYouOnMe.x;
			Force[i].y += forceYouOnMe.y;
			Force[i].z += forceYouOnMe.z;
			Force[j].x -= forceYouOnMe.x;
			Force[j].y -= forceYouOnMe.y;
			Force[j].z -= forceYouOnMe.z;
		}
	}
}

void moveBodies(float time)
{
	for(int i=0; i<N; i++)
	{
		if(time == 0.0)
		{
			Velocity[i].x += ((Force[i].x-DAMP*Velocity[i].x)/Position[i].w)*0.5*DT;
			Velocity[i].y += ((Force[i].y-DAMP*Velocity[i].y)/Position[i].w)*0.5*DT;
			Velocity[i].z += ((Force[i].z-DAMP*Velocity[i].z)/Position[i].w)*0.5*DT;
		}
		else
		{
			Velocity[i].x += ((Force[i].x-DAMP*Velocity[i].x)/Position[i].w)*DT;
			Velocity[i].y += ((Force[i].y-DAMP*Velocity[i].y)/Position[i].w)*DT;
			Velocity[i].z += ((Force[i].z-DAMP*Velocity[i].z)/Position[i].w)*DT;
		}

		Position[i].x += Velocity[i].x*DT;
		Position[i].y += Velocity[i].y*DT;
		Position[i].z += Velocity[i].z*DT;
	}
}

void n_body()
{	
	int    tdraw = 0; 
	float  time = 0.0;
	
	while(time < STOP_TIME)
	{
		getForces();
		moveBodies(time);

		if(tdraw == DRAW) 
		{
			draw_picture();
			printf("\n Time = %f \n", time);
			tdraw = 0;
		}
		time += DT;
		tdraw++;
	}
}

void control()
{	
	timeval start, end;
	double totalRunTime;

	set_initail_conditions();
	draw_picture();
	
	gettimeofday(&start, NULL);
    	n_body();
    	gettimeofday(&end, NULL);
    	
    	totalRunTime = (end.tv_sec * 1000000.0 + end.tv_usec) - (start.tv_sec * 1000000.0 + start.tv_usec);
	printf("\n Totl run time = %5.15f seconds\n", (totalRunTime/1000000.0));
	
	printf("\n DONE \n");
	exit(0);
}

void Display(void)
{
	gluLookAt(EYE, EYE, EYE, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	control();
}

void reshape(int w, int h)
{
	glViewport(0, 0, (GLsizei) w, (GLsizei) h);

	glMatrixMode(GL_PROJECTION);

	glLoadIdentity();

	glFrustum(-0.2, 0.2, -0.2, 0.2, 0.2, FAR);

	glMatrixMode(GL_MODELVIEW);
}

int main(int argc, char** argv)
{
	glutInit(&argc,argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_DEPTH | GLUT_RGB);
	glutInitWindowSize(XWindowSize,YWindowSize);
	glutInitWindowPosition(0,0);
	glutCreateWindow("n Body CPU");
	GLfloat light_position[] = {1.0, 1.0, 1.0, 0.0};
	GLfloat light_ambient[]  = {0.0, 0.0, 0.0, 1.0};
	GLfloat light_diffuse[]  = {1.0, 1.0, 1.0, 1.0};
	GLfloat light_specular[] = {1.0, 1.0, 1.0, 1.0};
	GLfloat lmodel_ambient[] = {0.2, 0.2, 0.2, 1.0};
	GLfloat mat_specular[]   = {1.0, 1.0, 1.0, 1.0};
	GLfloat mat_shininess[]  = {10.0};
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glShadeModel(GL_SMOOTH);
	glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
	glLightfv(GL_LIGHT0, GL_POSITION, light_position);
	glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
	glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, lmodel_ambient);
	glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
	glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_COLOR_MATERIAL);
	glEnable(GL_DEPTH_TEST);
	glutDisplayFunc(Display);
	glutReshapeFunc(reshape);
	glutMainLoop();
	return 0;
}
