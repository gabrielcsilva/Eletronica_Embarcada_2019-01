#include <msp430.h>
#define BLINK_DELAY_MS 500

/**
 * main.c
 */

int OfCount;

int main(void)
{
    WDTCTL = WDTPW + WDTHOLD; //Stop watchdog timer
    P1DIR |= BIT0; //Configure P1.0 as Output
    P1REN |= BIT3; // Enable internal pull-up/down resistors
    P1OUT |= BIT3; //Select pull-up mode for P1.3
    P1IE |= ~BIT3; // P1.3 interrupt enabled
    P1IES ^= BIT3; // P1.3 Lo/hi edge
    P1IFG &= ~BIT3; // P1.3 IFG cleared

    __enable_interrupt();

    OfCount = 0;
}

//Timer ISR
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A_CCR0_ISR(void)
{
    OfCount++;
    if(OfCount >= BLINK_DELAY_MS)
    {
        P1OUT ^= BIT0;
        OfCount = 0;
    }
}

//Button ISR
#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void)
{
    //Set MCLK = SMCLK = 1MHz
    BCSCTL1 = CALBC1_1MHZ;
    DCOCTL = CALDCO_1MHZ;

    //Timer Configuration
    TACCR0 = 0; //Initially, Stop the Timer
    TACCTL0 ^= CCIE; //Enable interrupt for CCR0.
    TACTL = TASSEL_2 + ID_0 + MC_1; //Select SMCLK, SMCLK/1 , Up Mode

    TACCR0 = 1000-1; //Start Timer, Compare value for Up Mode to get 1ms delay per loop

    P1IES ^= BIT3;
    P1IFG &= ~BIT3;
}
