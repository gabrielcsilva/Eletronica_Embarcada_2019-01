#include <msp430.h>


/**Atividade 2:
 * Temos que TACCR0 = 62500 e TACCR1 = 15625
 */
int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    P1DIR |= BIT6;
    P1SEL |= BIT6;

    TACCTL1 = OUTMOD_7;
    TACCR0 = 62500;
    TACCR1 = 15625;
    TACTL = MC_3|ID_3|TASSEL_2;

    __bis_SR_register(LPM0_bits);
}
