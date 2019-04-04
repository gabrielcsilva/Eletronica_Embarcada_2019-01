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

P1F:	MOV.B	#00000000b, P1OUT	;define P1OUT dos bits BIT0 e BIT6 como 1
		MOV.B	#01000001b, P1DIR	;define P1DIR dos bits BIT0 e BIT6 como 1
		MOV.B	#00000100b, R4		;define R4 como o input do botão (BIT2) - BTN (??)

LOOP:	CMP		P1IN, R4
		JEQ		ON
		JNE		OFF
		JMP 	LOOP

ON:		OR		P1DIR, P1OUT
		JMP		LOOP

OFF:	XOR.B	#11111111b, P1DIR
		AND		P1DIR, P1OUT
		JMP 	LOOP
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
