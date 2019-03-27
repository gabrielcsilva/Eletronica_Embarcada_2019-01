#include <msp430.h> 


/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	P1OUT = BIT6 + BIT0;
	P1DIR = BIT6 + BIT0;
	for(;;){

	}
	return 0;
}
