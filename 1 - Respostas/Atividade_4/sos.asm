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


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
			.data
MESSAGE		.byte	DOT, DOT, DOT, LETTER, DASH, DASH, DASH, LETTER, DOT, DOT, DOT, ENDTX

			.text

LED1:		.set	BIT3
DELAYLOOPS:	.set	27000
DOT:		.set	2
DASH:		.set	6
SPACE:		.set	2
LETTER:		.set	0
ENDTX:		.set	0xFF

MAIN:
			BIS.B	#LED1, &P2OUT
			BIS.B	#LED1, P2DIR
			CLR		R5
			JMP		MESSAGETEST

MESSAGELOOP:
			BIC.B	#LED1, &P2OUT
			MOV.B	MESSAGE(R5), R12
			CALL	#DELAYTENTHS
			BIS.B	#LED1, &P2OUT
			MOV		#SPACE, R12
			CALL	#DELAYTENTHS
			INC		R5

MESSAGETEST:
			CMP.B	#ENDTX, MESSAGE(R5)
			JNE		MESSAGELOOP

INFLOOP:
			JMP		INFLOOP

;Subroutines
DELAYTENTHS:
			PUSH	R4
			PUSH	R12
			JMP		LOOPTEST

OUTERLOOP:
			MOV		#DELAYLOOPS, R4

DELAYLOOP:
			DEC		R4
			JNZ		DELAYLOOP
			DEC		R12

LOOPTEST:
			CMP	#0, R12
			JNZ		OUTERLOOP
			POP		R4
			POP		R12
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

