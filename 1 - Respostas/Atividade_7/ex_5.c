#include <msp430.h>
#define GREEN BIT0
#define RED BIT6
#define BTN BIT3

/**Atividade 5:
 *
 */

//int firstClick, secondClick;

void PortsInit (void)
{
    // Port 1: 0 = SW1 , 1 = SW2 , others used for Chipcon (not placed)
    P1OUT = 0;
    P1DIR = 0xFF & ~BTN; // P1.0,1 input , others output
    P1SEL = BTN; // P1.1 = S2 to Timer_A CCI0B
}

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    PortsInit();

    // Capture either edge of CCI0B , synchronized , interrupts enabled
    TACCTL0 = CM_3 | CCIS_1 | SCS | CAP | CCIE;
    // Start timer: ACLK , no prescale , continuous mode , no ints , clear
    TACTL = TASSEL_1 | ID_0 | MC_2 | TACLR;

    __enable_interrupt();
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void TIMER_A0_ISR(void)
{
    static int LastTime = 0; // Last time captured
    LastTime = TACCR0;

    if(TACCR0 - LastTime < 4) //Qual é o tempo?
    {
        P1OUT = RED;
    }

    switch(TAIV)
    {
    case 02:
        P1OUT |= GREEN;
        break;
    case 04:
        P1OUT |= GREEN;
        break;
    default:
        P1OUT &= ~GREEN;
    }

}
