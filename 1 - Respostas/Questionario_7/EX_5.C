#include <msp430.h>
#define BLINK_DELAY_MS 500

/**
 * main.c
 */

int main(void)
{
    WDTCTL = WDTPW + WDTHOLD; //Stop watchdog timer
    P1DIR |= BIT0; //Configure P1.0 as Output
    P1REN |= BIT3; // Enable internal pull-up/down resistors
    P1OUT |= BIT3; //Select pull-up mode for P1.3
    P1IE |= BIT3; // P1.3 interrupt enabled
    P1IES |= ~BIT3; // P1.3 hi/lo edge
    P1IFG &= ~BIT3; // P1.3 IFG cleared
    __bis_SR_register(LPM4_bits + GIE);
}

#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void)
{
    P1IES ^= BIT3;
    P1OUT ^= BIT0;
    P1IFG &= ~BIT3;
}
