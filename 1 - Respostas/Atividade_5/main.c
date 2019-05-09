#include <msp430.h> 

/**
 * main.c
 */

int counter;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	counter = 0;
	P1DIR |= (BIT0 | BIT6); //Configure P1.0 as Output
    P1REN |= BIT3; // Enable internal pull-up/down resistors
    P1OUT |= BIT3; //Select pull-up mode for P1.3
    P1IE |= BIT3; // P1.3 interrupt enabled
    P1IES ^= BIT3; // P1.3 Lo/hi edge
    P1IFG &= ~BIT3; // P1.3 IFG cleared

    __bis_SR_register(GIE);

	return 0;
}

#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void)
{
    switch(counter)
    {
    case 0:
        P1OUT ^= BIT0;
        counter++;
        break;
    case 1:
        P1OUT ^= (BIT0 | BIT6);
        counter++;
        break;
    case 2:
        P1OUT ^= BIT0;
        counter++;
        break;
    case 3:
        P1OUT ^= (BIT0 | BIT6);
        counter = 0;
        break;
    default:
        break;
    }
    P1IFG &= ~BIT3;
}
