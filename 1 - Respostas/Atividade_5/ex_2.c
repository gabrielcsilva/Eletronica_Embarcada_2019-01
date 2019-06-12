#include <msp430.h>
#define BLINK_DELAY_MS 10000
#define WAIT_TIME 1000

/**
 * main.c
 */

int count, time, click;
int num = 1;

int rand(int num)
{
    /* Ordem do pseudo-aleatorio
     *  NÚMERO ANTERIOR     PRÓXIMO NÚMERO
     *  1                   3
     *  2                   6
     *  3                   2
     *  4                   5
     *  5                   1
     *  6                   4
     *      */
    num = (num * 17) % 7;
    return num;
}

int main(void)
{
    WDTCTL = WDTPW + WDTHOLD; //Stop watchdog timer
    P1DIR |= (BIT0 | BIT6); //Configure P1.0 as Output
    P1REN |= BIT3; // Enable internal pull-up/down resistors
    P1OUT |= BIT3; //Select pull-up mode for P1.3
    P1IE |= BIT3; // P1.3 interrupt enabled
    P1IES |= BIT3; // P1.3 Lo/hi edge
    P1IFG &= ~BIT3; // P1.3 IFG cleared

    __enable_interrupt();

    //Timer Configuration
    TACCR0 = 0; //Initially, Stop the Timer
    TACCTL0 |= CCIE; //Enable interrupt for CCR0.
    TACTL = TASSEL_2 + ID_0 + MC_1; //Select SMCLK, SMCLK/1 , Up Mode

    count = 0;
    time = 0;
    click = 0;
}

//Timer ISR
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A_CCR0_ISR(void)
{
    if(count >= BLINK_DELAY_MS)
    {
        time++;
        if(time >= WAIT_TIME)
        {
            if (click == num)
            {
                num = rand(num);
            }
            count = 0;
            time = 0;
            click = 0;
            TACCR0 = 0;
            P1OUT &= ~(BIT0 | BIT6);
        }
        else
        {
            if(click == num)
            {
                P1OUT |= BIT0;
            }
            else
            {
                P1OUT |= BIT6;
            }
        }
    }
    else
    {
        count++;
    }
}

//Button ISR
#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void)
{
    TACCR0 = 1000-1; //Start Timer, Compare value for Up Mode to get 1ms delay per loop
    click++;
    P1IFG &= ~BIT3;
}
