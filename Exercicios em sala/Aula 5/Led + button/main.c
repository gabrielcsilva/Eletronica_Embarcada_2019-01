#include <msp430.h> 
#define BTN BIT3
#define LED1 BIT0
#define LED2 BIT6

/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	P1OUT = 0;
	P1DIR = LED1 + LED2;
	
	//Acende os leds ao apertar o botão
	/*
	for(;;){
	    if ((P1IN & BTN) == 0)
	        P1OUT |= LED1 + LED2;
	    else
	        P1OUT &= ~(LED1 + LED2);
	}
	*/
	//Apaga os leds ao apertar o botão
	for(;;){
	    if ((P1IN & BTN) == 0)
	        P1OUT &= ~(LED1 + LED2);
	    else
	        P1OUT |= LED1 + LED2;
	}
}
