#include <msp430.h>
#define BLINK_DELAY_MS 500

/**
 * main.c
 */

int OFCount, flag = 0;


int main(void)
{
    WDTCTL = WDTPW + WDTHOLD; //Stop watchdog timer
    P1OUT = 0;
    P1DIR |= BIT0; //Configure P1.0 as Output

    //Set MCLK = SMCLK = 1MHz
    BCSCTL1 = CALBC1_1MHZ;
    DCOCTL = CALDCO_1MHZ;

    //Timer Configuration
    TACCR0 = 0; //Initially, Stop the Timer
    TACCTL0 |= CCIE; //Enable interrupt for CCR0.
    TACTL = TASSEL_2 + ID_0 + MC_1; //Select SMCLK, SMCLK/1 , Up Mode
    __enable_interrupt();

    OFCount  = 0;
    TACCR0 = 1000-1; //Start Timer, Compare value for Up Mode to get 1ms delay per loop
}

//Timer ISR
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A_CCR0_ISR(void)
{
    OFCount++;
    if (flag == 0)
    {
        if(OFCount >= BLINK_DELAY_MS)
            {
                P1OUT ^= BIT0;
                OFCount = 0;
                flag = 1;
            }
    }
    else
    {
        if(OFCount >= BLINK_DELAY_MS * 2)
            {
                P1OUT ^= BIT0;
                OFCount = 0;
                flag = 0;
            }
    }

}
