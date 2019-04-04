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

P1G:	MOV		#0, R5	;next
		MOV		#0, R6	;first
		MOV		#1, R7	;second
		MOV		#0, R8	;counter

LOOP:	CMP		#0, R8
		JEQ		FIRST
		MOV		R7, R5	; R5 = R7
		ADD		R6, R5	; R5 = R5 + R6 (next = first + second)
		MOV		R7, R6	; first = second
		MOV		R5, R7	; second = next
		INC		R8		;i++
		CMP		#7, R8	;if i = 7
		JEQ		END		;if yes, end
		JMP		LOOP	;if no, loop

FIRST:	MOV		R8, R5
		INC		R8
		JMP		LOOP

END:	JMP	$
		NOP

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
