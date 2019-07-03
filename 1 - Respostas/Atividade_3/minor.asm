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

VALUE:	.set	11

		.data
VETOR	.word 	"JOAQUIMJOSE"
lastelement

		.text
LOOP:
		MOV		#VETOR, R5		;transfer vector to reg 5
		MOV		#VALUE, R15		;count the number of itens inside vector/also loops
		CALL	#MAIN_MINOR		;calls function
		JMP		$				;output R5 = 0x41
		NOP

MAIN_MINOR:
		CLR		R7				;clear counter
		;MOV.W	@R5+, R14		;move value of the first addr of R5 to R14
		;MOV.W	R14, R6			;move R14 to the minor reg (R6)
		MOV.W	@R5+, R6
		JMP		COUNTER_DEALING

CHANGE_MINOR:
		CLR		R7				;clear counter
		MOV.W	R14, R6			;move R14 to the minor reg (R6)

COUNTER_DEALING:
		INC		R7				;increase counter of minor repetition

LOOP_MINOR:
		DEC		R15				;decrease number of loops
		CMP		#0, R15			;compare R15 with 0
		JZ		END				;if Z -> move to end
		MOV.W	@R5+, R14		;move the value of the next addr of R5 to R14
		CMP		R6, R14			;compare R6 and R14
		JL		CHANGE_MINOR	;if R14 < R6, jump to change minor
		JEQ		COUNTER_DEALING	;if R14 = R6, jump to counter dealing
		JMP		LOOP_MINOR		;jump to the loop beginnig

END:
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
            
