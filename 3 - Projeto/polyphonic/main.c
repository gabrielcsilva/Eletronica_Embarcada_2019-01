#include <msp430.h> 


void set_tick(unsigned);
unsigned get_tick(void);
void synth_init();
void set_note(int, unsigned);

void main(void)
{

   WDTCTL = WDTPW + WDTHOLD;

   BCSCTL1 = XT2OFF + 15;
   P1DIR = 0xF2;       // I/O assignment
   P1REN = 0x0D;       // Pull up resistor for switch and Rxd
   P1OUT = 0x0F;       // Pull up, serial idle high
   P1SEL = 0x50;       // Enable Timer A output, SMCLK output

  /* P1REN |= BIT3; // Enable internal pull-up/down resistors
   P1OUT |= BIT3; //Select pull-up mode for P1.3
   P1IE |= BIT3; // P1.3 interrupt enabled
   P1IES ^= BIT3; // P1.3 Lo/hi edge
   P1IFG &= ~BIT3; // P1.3 IFG cleared*/

   synth_init();

   set_note(0x69, 1);
   set_tick(50000);
   while(get_tick());
   set_note(-1, 0); //call note off
   set_tick(1000);
   while(get_tick());

}


/*//Timer ISR
#pragma vector = PORT1_VECTOR
__interrupt void Port_1(void)
{
    P1IES ^= BIT3;
    sound();
    P1IFG &= ~BIT3;
}*/
