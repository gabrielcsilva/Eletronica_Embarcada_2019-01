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

LEDS:	.set	BIT0|BIT6

MAIN:
		MOV.B	#LEDS, P1DIR
		MOV.W	#10, R15
		CALL	#PISCA
		BIS.B	#LEDS, P1OUT
		JMP		$

ATRASO:
		DEC		R15
		JNZ		ATRASO
		RET

PISCA:
		TST		R15
		JZ		PISCA_END
		DEC 	R15
		PUSH	R15
		XOR.B	#LEDS, &P1OUT
		MOV.W	#0xFFFF, R15
		CALL	#ATRASO
		XOR.B	#LEDS, &P1OUT
		MOV.W	#0xFFFF, R15
		CALL	#ATRASO
		POP		R15
		JMP		PISCA

PISCA_END:
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
            
