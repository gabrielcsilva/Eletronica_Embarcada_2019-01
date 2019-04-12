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
BIGLOOPS:	.set	130
LITTLELOOPS:.set	100

            BIS.B	#LED1, &P2OUT
            BIS.B	#LED1, &P2DIR

LOOP:
			MOV.W	#5, R12
			CALL	#DELAYTENTHS
			XOR.B	#LED1, &P2OUT
			JMP		LOOP

DELAYTENTHS:
			SUB.W	#4, SP
			JMP		LOOPTEST

OUTERLOOP:
			MOV.W	#BIGLOOPS, 2(SP)

BIGLOOP:
			MOV.W	#LITTLELOOPS, 0(SP)

LITTLELOOP:
			DEC.W	0(SP)
			JNZ		LITTLELOOP
			DEC.W	2(SP)
			JNZ		BIGLOOP
			DEC.W	R12

LOOPTEST:
			CMP.W	#0, R12
			JNZ		OUTERLOOP
			ADD.W	#4, SP
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

