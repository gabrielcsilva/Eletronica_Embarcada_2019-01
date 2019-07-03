#include <msp430.h> 


/**Atividade 1:
 * Para todos os itens, temos que TACCR0 = 625
 * 1.a) TACCR1 = 156;
 * 1.b) TACCR1 = 312;
 * 1.c) TACCR1 = 469;
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	P1DIR |= BIT6;
	P1SEL |= BIT6;

	TACCTL1 = OUTMOD_7;
    TACCR0 = 625;
    TACCR1 = 469;
    TACTL = MC_3|ID_3|TASSEL_2;

	__bis_SR_register(LPM0_bits);
}
