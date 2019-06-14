#include <msp430.h> 
#define REDLED BIT0
#define GREENLED BIT6
#define BTN BIT3
#define TIME 4 //a) 10s
//#define TIME 60 //b) 1 min
//#define TIME 3600 //c) 1 hora - não testado
//#define TIME 86400 //d) 1 dia - não testado

int count = 0;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	TACCTL0 = CCIE;
	TACCR0 = 62500;
	TACTL = MC_3|ID_3|TASSEL_2|TACLR;

	//C
	P1IE = BTN;
	P1IES = BTN;
	P1IFG = 0x00;

	__enable_interrupt();

	P1DIR = REDLED|GREENLED;
	P1OUT = REDLED;

	while(1)
	{
	    LPM1;
	}
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void TimerA_0(void)
{
    LPM1_EXIT;
    count++;
    if (count == TIME)
    {
        P1OUT ^= REDLED|GREENLED;
        count = 0;
    }
}

//C
#pragma vector = PORT1_VECTOR
__interrupt void Port1_ISR(void)
{
    P1OUT = REDLED;
    count = 0;
    TACTL |= TACLR;
    P1IFG = 0x00;
}
