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

VALUE:	.set	3

		.data
VETOR 	.byte 160, 80, 134, 1996
lastelement

		.text
LOOP:
		MOV		#VETOR, R5		;transfer vector to reg 5
		MOV		#VALUE, R15		;count the number of itens inside vector/also loops
		CALL	#MAIN
		JMP		$				;output R5 = 0x534F
		NOP

MAIN:
		MOV.W	@R5+, R14
		MOV.W	R14, R7		;move R14 to the minor reg (R6)
		MOV.W	R14, R6
		JMP		LOOP_CHOOSE

CHANGE_MAJOR:
		MOV.W	R14, R7			;move R14 to the minor reg (R6)
		JMP		LOOP_CHOOSE

CHANGE_MINOR:
		MOV.W	R14, R6			;move R14 to the minor reg (R6)
		JMP		LOOP_CHOOSE

LOOP_CHOOSE:
		DEC		R15				;decrease number of loops
		CMP		#0, R15			;compare R15 with 0
		JZ		END				;if Z -> move to end
		MOV.W	@R5+, R14		;move the value of the next addr of R5 to R14
		CMP		R14, R7			;compare R6 and R14
		JL		CHANGE_MAJOR	;if R6 < R14, jump to change minor
		CMP		R6, R14			;compare R6 and R14
		JL		CHANGE_MINOR	;if R14 < R6, jump to change minor
		JMP		LOOP_CHOOSE

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

