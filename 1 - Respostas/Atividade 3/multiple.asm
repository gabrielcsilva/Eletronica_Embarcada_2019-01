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

VALUE:	.set	20

		.data
VETOR:	.word 	"GABRIELCOELHODASILVA"
lastelement

		.text
LOOP:
		MOV		#VETOR, R5		;transfer vector to reg 5
		MOV		#VALUE, R15		;count the number of itens inside vector/also loops
		CALL	#MAIN_MULTIPLE	;calls function
		JMP		$				;output
		NOP

MAIN_MULTIPLE:
		CLR		R6				;clear multiple by two counter
		CLR		R7				;clear multiple by four counter
		MOV.W	@R5+, R14

PREPARE_DIVISION:
   		PUSH	R14				;pass division value to first addr of stack

DIVISION_BY_2:
		SUB.W	#2, R14		;subtract 2 from value divided
   		CMP   	#2, R14			;compare 2 with divided value
   		JGE		DIVISION_BY_2	;if divided >= 2, return to the beginnnig of this function
   		CMP		#0, R14			;if not, compare if divided with 0
   		JZ		INCREASE_2		;if divided = 0, jump to increase
   		JMP		POP_VALUE		;if not, jump to next division

INCREASE_2:
		INC		R6				;increase by two divisor counter by one

POP_VALUE:
		POP		R14

DIVISION_BY_4:
		SUB.W	#4, R14		;subtract 4 from value divided
   		CMP   	#4, R14		;compare 4 with divided value
   		JGE		DIVISION_BY_4	;if divided >= 4, return to the beginnnig of this function
   		CMP		#0, R14			;if not, compare if divided with 0
   		JZ		INCREASE_4		;if divided = 0, jump to increase
   		JMP		LOOP_MULTIPLE	;if not, jump to next division

INCREASE_4:
		INC		R7				;;increase by four divisor counter by one

LOOP_MULTIPLE:
		DEC		R15				;decrease number of loops
		CMP		#0, R15			;compare R15 with 0
		JZ		END				;if Z -> move to end
		MOV.W	@R5+, R14		;move the value of the next addr of R5 to R14
		JMP		PREPARE_DIVISION;back to main function

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

