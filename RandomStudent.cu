// To compile: nvcc RandomStudent.cu -o RandomStudent
#include <sys/time.h>
#include <stdio.h>



int main(int argc, char** argv)
{
	time_t t;
	srand((unsigned) time(&t));
	
	int studentId = 1.0 + ((float)rand()/(float)RAND_MAX)*10.0; // Get random number between 0 and 12.
	
	if(studentId == 1) printf("\n\n Joshua\n\n");
	else if(studentId == 2) printf("\n\n Griffin\n\n");
	else if(studentId == 3) printf("\n\n Samuel\n\n");
	else if(studentId == 4) printf("\n\n Derek\n\n");
	else if(studentId == 5) printf("\n\n Gavin\n\n");
	else if(studentId == 6) printf("\n\n Dashon\n\n");
	else if(studentId == 7) printf("\n\n Aurod\n\n");
	else if(studentId == 8) printf("\n\n JaDarrien\n\n");
	else if(studentId == 9) printf("\n\n Zachary\n\n");
	else if(studentId == 10) printf("\n\n Raffie\n\n");
	else printf("\n\n Bad Number = %d\n\n", studentId);
	
	return(0);
}
