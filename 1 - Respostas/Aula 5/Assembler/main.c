#include <msp430.h> 

ORG 0XC000

Reset:
mov.w #WDTCTL = WDTPW | WDTHOLD,
mov.b #01000001b, P1OUT
mov.b #01000001b, P1DIR

Loop:
jmp Loop


ORG OxFFFE
DW Reset
END
