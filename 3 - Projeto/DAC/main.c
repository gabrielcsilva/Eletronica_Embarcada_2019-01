/*
#include <msp430.h>

*
 * main.c


int level;

void sound()
{
    P2OUT ^= (BIT0 + BIT1 + BIT2);
}

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	//Inicializando saídas de áudio
	P2DIR |= (BIT0 + BIT1 + BIT2);

	//Inicializando botão
    P1REN |= BIT3; // Enable internal pull-up/down resistors
    P1OUT |= BIT3; //Select pull-up mode for P1.3
    P1IE |= BIT3; // P1.3 interrupt enabled
    P1IES |= BIT3; // P1.3 Lo/hi edge
    P1IFG &= ~BIT3; // P1.3 IFG cleared

    //Inicializando o timer
    TACCR0 = 0; //Initially, Stop the Timer
    TACCTL0 = 0; //Enable interrupt for CCR0.

    __enable_interrupt();

}

//Timer ISR
#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A_CCR0_ISR(void)
{
    sound();
}

//Button ISR
#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void)
{
    //Timer Configuration
    BCSCTL1 = CALBC1_1MHZ;
    DCOCTL = CALDCO_1MHZ;
    TACCR0 = 0; //Initially, Stop the Timer
    TACCTL0 ^= CCIE; //Enable interrupt for CCR0.
    TACTL = TASSEL_2 + ID_0 + MC_1; //Select SMCLK, SMCLK/1 , Up Mode

    TACCR0 = 800-1; //Start Timer, Compare value for Up Mode to get 1ms delay per loop

    P1IES ^= BIT3;
    P1IFG &= ~BIT3;
}
*/

#include <msp430.h>
#include "notes.h"

#define BUZZER  BIT1                                // Buzzer -> P2.1
#define F_CPU   1200000L                            // CPU Freq approx 1.2 MHz

//Define melody notes and respective duration (1/n seconds)
const unsigned int melody = NOTE_A4;
const unsigned int noteDurations = 10;

volatile unsigned long count;

// Function to generate a note for a specified duration
void playNote(unsigned int note, unsigned int duration)
{
    volatile unsigned int period, cycles;

    period = F_CPU / note;                          // Timer Period = F_CPU / Fnote
    cycles = (F_CPU * duration)/(1000L * period);   // Note duration as number of Timer cycles

    count = cycles;                                 // Set global count variable
    TA1CCR0 = period;                               // Set timer period
    TA1CCR1 = period/2;                             // Generate output on TA1.1 at 50% duty cycle
    TA1CTL = TACLR + TASSEL_2 +  MC_1;              // Timer -> SMCLK, Up Mode, Clear
    TA1CCTL0 |= CCIE;                               // Enable CCR0 interrupt
    TA1CCTL1 |= OUTMOD_7;                           // Output mode for TA1.1

    if(note > 0 && duration > 0)                    // Only if note/duration is non zero
        P2SEL |= BUZZER;                            // Send Timer Output to pin

    __bis_SR_register(LPM0_bits + GIE);             // Goto LPM and wait for note to complete
    TA1CTL = MC_0;                                  // Stop Timer
    P2SEL &= ~BUZZER;                               // Turn off timer output to pin
}

void main(void) {
    WDTCTL = WDTPW | WDTHOLD;                       // Stop watchdog timer
    P2DIR |= BUZZER;                                // Set Buzzer pin as Output
    //Button interrupt
    P1REN |= BIT3; // Enable internal pull-up/down resistors
    P1OUT |= BIT3; //Select pull-up mode for P1.3
    P1IE |= BIT3; // P1.3 interrupt enabled
    P1IES ^= BIT3; // P1.3 Lo/hi edge
    P1IFG &= ~BIT3; // P1.3 IFG cleared


/*    while(1)
    {
        unsigned int i;
        for(i = 0; i < 8; i++)                      // Play notes one by one
            playNote(melody[i], (1000/noteDurations[i]));
    }*/
}

#pragma vector = TIMER1_A0_VECTOR                   // Timer 1 CCR0 Interrupt Vector
__interrupt void CCR0_ISR(void)
{
    count--;                                        // Decrement duration counter
    if(count == 0)
        __bic_SR_register_on_exit(LPM0_bits);       // Exit LPM when note is complete
}

#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void)
{
    playNote(melody, (1000/noteDurations));
    P1IES ^= BIT3;
    P1IFG &= ~BIT3;
}
