// Gabriel Waltrip
// Rover.cpp : Defines the entry point for the console application.
// gcc -o rover.out -lwiringPi -lm -pthread rover.c Compass.h gps.h
// #include <stdio.h>
// #include <wiringPi.h>
// #include <pthread.h>
// #include "tcp.h"
// void tcpError(const char *msg);
// void *tcpListener(void *arg);
#include "hardware.h"

int n;
int newsockfd;
int portno;
char mode;

//#include "cfv_bellman.h"

#define MOTOR_RIGHT_A	P1OUT
#define MOTOR_RIGHT_B	P2OUT
#define MOTOR_LEFT_A	P3OUT
#define MOTOR_LEFT_B	P4OUT



#define Stop_All_Motors()	MOTOR_RIGHT_A = 0;\
				MOTOR_RIGHT_B = 0;\
				MOTOR_LEFT_A = 0;\
				MOTOR_LEFT_B = 0;\
				// digitalWrite(MOTOR_RIGHT_A,0);\
				// digitalWrite(MOTOR_RIGHT_B,0);\
				// digitalWrite(MOTOR_LEFT_A,0);\
				// digitalWrite(MOTOR_LEFT_B,0);

void delay(unsigned int us){
    int i;
    int upper = us >> 1; // divide by 2 for accuracy w/ openMSP430 clock
    for(i=0; i<upper; i++);
}

int main()
{
	mode = 0xff;
	char last = mode;
   int count = 0;
   unsigned long start, end;

	// printf("What port do you want to open?\n");
	// scanf("%d",&portno);
	portno = 1;

	//pthread_t tcp;
	//pthread_create(&tcp, NULL,tcpListener,"");

	// pinMode(MOTOR_LEFT_A,OUTPUT);
	P1DIR = 0xff;
	// pinMode(MOTOR_LEFT_B,OUTPUT);
	P2DIR = 0xff;	
	// pinMode(MOTOR_RIGHT_A,OUTPUT);
	P3DIR = 0xff;
	// pinMode(MOTOR_RIGHT_B,OUTPUT);
	P4DIR = 0xff;

	/*Starts Main Loop*/
	while (count++ < 500) {
		// tcpListener(NULL);
		if(last == mode){
			Stop_All_Motors();
			last = mode;
		}
		//Fordward
		else
		if(mode == 0x1+'0'){
			// digitalWrite(MOTOR_RIGHT_A,1);
			MOTOR_RIGHT_A = 1;
			// digitalWrite(MOTOR_LEFT_A,1);
			MOTOR_LEFT_A = 1;
		}
		//Backwards
		else if(mode == 0x2 + '0'){
			// printf("Backward\n");
			// digitalWrite(MOTOR_RIGHT_B,1);
			MOTOR_RIGHT_B = 1;
			// digitalWrite(MOTOR_LEFT_B,1);
			MOTOR_LEFT_B = 1;
		}
		//Left
		else if (mode == 0x3 + '0'){
			// printf("Left\n");
			// digitalWrite(MOTOR_RIGHT_A,1);
			MOTOR_RIGHT_A = 1;
			// digitalWrite(MOTOR_LEFT_B,1);
			MOTOR_LEFT_B = 1;
		}
		//Right
		else if (mode == 0x4 + '0'){
			// printf("Right\n");
			// digitalWrite(MOTOR_RIGHT_B,1);
			MOTOR_RIGHT_B = 1;
			// digitalWrite(MOTOR_LEFT_A,1);
			MOTOR_LEFT_A = 1;
		}
		delay(500);
	}

	Stop_All_Motors();

	acfa_exit();
	return 0;
}