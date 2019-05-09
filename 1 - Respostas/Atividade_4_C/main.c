#include <msp430.h>
#define BLINKY_DELAY_MS 250 //Change this as per your needs
#define DOT 2
#define DASH 6

int message[9] = {DOT, DOT, DOT, DASH, DASH, DASH, DOT, DOT, DOT};

unsigned int OFCount, i, counter;

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
    i = 0;
    counter = 0;
    TACCR0 = 1000-1; //Start Timer, Compare value for Up Mode to get 1ms delay per loop
}

//Timer ISR
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A_CCR0_ISR(void)
{
    OFCount++;
    if(OFCount >= BLINKY_DELAY_MS)
    {
        counter++;
        P1OUT |= BIT0;
        if(counter >= BLINKY_DELAY_MS * message[i])
        {
            P1OUT &= ~BIT0;
            if(i >= 8)
            {
                TACCR0 = 0; //Initially, Stop the Timer
            }
            else
            {
                i++;
            }
            counter = 0;
            OFCount = 0;
        }
    }
}
