#include <msp430.h> 


/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	P1DIR = BIT6 + BIT0;
	P1OUT = BIT6 + BIT0;
	for(;;){
	    P1DIR ^= BIT6;
	    __delay_cycles(500000);
	    P1DIR ^= BIT0;
	}
}
