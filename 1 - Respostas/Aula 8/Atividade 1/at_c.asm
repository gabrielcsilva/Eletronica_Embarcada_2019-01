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

P1C:	CLR		R5			;zerar R5
		MOV		#4, R6		;colocar o número 4 em R6

LOOP:	CALL	#SUBROT		;chamar subrotina "SUBROT"
		DEC		R6			;decrementar R6
		JNZ		LOOP		;se diferente de zero, ir para LOOP
		NOP					;nenhuma operação
		JMP		$			;trava a execução num laço infinito
		NOP					;nenhuma operação

SUBROT:	ADD		#1, R5		;somar 1 em R5
		ADD		#1, R5		;somar 1 em R5
		RET					;retornar

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
            
