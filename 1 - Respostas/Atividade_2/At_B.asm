;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;LED1		EQU		BIT3
;DELAYLOOPS	EQU		27000

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

LED1: 		.set	BIT3
DELAYLOOPS:	.set	27000

            BIS.B	#LED1, &P2OUT
            BIS.B	#LED1, &P2DIR

LOOP:
			MOV.W	#5, R12
			CALL	#DELAYTENTHS
			XOR.B	#LED1, &P2OUT
			JMP		LOOP

DELAYTENTHS:
			PUSH.W	R4
			JMP		LOOPTEST

OUTERLOOP:
			MOV.W	#DELAYLOOPS, R4

DELAYLOOP:
			DEC.W	R4
			JNZ		DELAYLOOP
			DEC.W	R12

LOOPTEST:
			CMP.W	#0, R12
			JNZ		OUTERLOOP
			POP.W	R4
			RET

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

