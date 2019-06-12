#include <msp430.h> 
#define DELAY 1000
#define P1 BIT0
#define P2 BIT1
#define P3 BIT2

/**
 * main.c
 */

int timeCount;
const unsigned int hi[6] = {P1, P2, P1, P3, P2, P3};
const unsigned int lo[6] = {P2, P1, P3, P1, P3, P2};
const unsigned int z[6]  = {P3, P3, P2, P2, P1, P1};

void charlie (unsigned int value)
{
    P2DIR &= ~z[value];
    P2DIR |= (hi[value] + lo[value]);

    P2OUT &= ~lo[value];
    P2OUT |= hi[value];
}

int main(void)
{

    WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	//Timer Configuration
    TACCR0 = 0; //Initially, Stop the Timer
    TACCTL0 |= CCIE; //Enable interrupt for CCR0.
    TACTL = TASSEL_2 + ID_0 + MC_1; //Select SMCLK, SMCLK/1 , Up Mode
    __enable_interrupt();

    timeCount  = 0;
    TACCR0 = 1000-1; //Start Timer, Compare value for Up Mode to get 1ms delay per loop

    while(1)
    {
        unsigned int i;
        for (i = 0; i < 6; i++)
        {
            charlie(i);
            __bis_SR_register(LPM0_bits);
        }
    }
}

//Timer ISR
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A_CCR0_ISR(void)
{
    timeCount++;
    if(timeCount >= DELAY)
    {
        timeCount = 0;
        __bic_SR_register_on_exit(LPM0_bits);
    }
}
