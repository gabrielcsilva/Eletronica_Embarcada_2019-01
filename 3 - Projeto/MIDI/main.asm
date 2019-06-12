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

smplrt	.equ    32000                   ; Sample rate
		.global set_tick
		.global get_tick
		.global synth_init
		.global set_note


		.bss    tick, 2
		.bss    pwm_out, 2
       	.bss    phase_inc, 6 * 16       ; Phase increment LSW/MSW (from note table)
       	.bss    phase_acc, 4 * 16       ; Phase accumulator LSW/MSW

set_tick:
       	mov		R12, &tick
       	reta

get_tick:
       	mov     &tick, R12
       	reta

synth_init:
       	mov     #0x0210, &TA0CTL        ; Timer A config: SMCLK, count up
       	mov     #750, &TA0CCR0          ; Setup Timer A period for 32000 sps
       	mov     #375, &TA0CCR1          ; Setup Timer A compare
       	mov     #0x00E0, &TA0CCTL1      ; Setup Timer A reset/set output mode
       	                                ;
       	mov     #phase_inc, R12         ; Clear all phase inc and accum
       	mov     #5 * 16, R14            ; Word count
       	clr     0(R12)                  ; Clear word
       	incd    R12                     ; Next word
       	dec     R14                     ; Dec word count
       	jne     $ - 8                   ; Loop until all words done...
       	                                ;
       	eint                            ; Enable interupts
       	bis     #0x0010, &TA0CCTL0      ; Enable PWM interupt
       	                                ;
       	reta                            ;

synth_isr:
       	mov     &pwm_out, &TA0CCR1      ; Output sample
       	                                ;
       	push    R4                      ; Wavetable pointer
       	push    R5                      ; Phase increment / level pointer
       	push    R6                      ; Phase accumulator pointer
       	push    R7                      ; Voice count
       	push    R8                      ; Wave sample pointer / next sample
       	push    R9                      ; Wave sample
       	push    R10                     ; Voice mix accumulator MSW
       	push    R11                     ; Voice mix accumulator LSW
       	                                ;
       	mov     #sine, R4               ; Get wavetable pointer
       	mov     #phase_inc, R5          ; Setup phase increment pointer
       	mov     #phase_acc, R6          ; Setup phase accumulator pointer
       	mov     #16, R7                 ; Setup voice count
       	mov     #9, R7                  ;
       	clr     R10                     ; Clear voice mix
       	clr     R11                     ;

voice_loop:                              ;
       	;mov     @R6+, &MPYS32L          ; Get phase acc LSW (fraction) to multiplier
       	;clr     &MPYS32H                ;
       	mov     @R6+, R8                ; Get phase acc MSW (wave table index)
       	mov.b   R8, R8                  ; Clear MSB (use mask for smaller / larger tables)
       	add     R4, R8                  ; Add wavetable pointer
       	mov     @R8+, R9                ; Get wave sample
       	mov     @R8, R8                 ; Get next wave sample
       	sub     R9, R8                  ; Calc delta
       	;mov     R8, &OP2L               ; Multiply by delta
       	subc    R8, R8                  ; Sign extend delta
       	;mov     R8, &OP2H               ;
       	add     @R5+, -4(R6)            ; Update phase acc
       	addc    @R5+, -2(R6)            ;
       	;add     &RES1, R9               ; Add interpolation to sample
       	;mov     R9, &MPYS               ; Multiply by voice level
       	;mov     @R5+, &OP2L             ;
       	;add     &RES0, R11              ; Update mix
       	;addc    &RES1, R10              ;
       	dec     R7                      ; Dec voice count
       	jne     voice_loop              ; Next voice...
       	                                ;
       	add     #375, R10               ; Bias to center of PWM range
       	mov     R10, &pwm_out           ;
       	                                ;
       	dec     &tick                   ;
       	jc      $ + 6                   ;
       	clr     &tick                   ;
       	                                ;
       	pop     R11                     ;
       	pop     R10                     ;
       	pop     R9                      ;
       	pop     R8                      ;
       	pop     R7                      ;
       	pop     R6                      ;
       	pop     R5                      ;
       	pop     R4                      ;
       	reti                            ;

set_note:                                ;
       	push    R14                     ; Save level
       	mov     R12, R14                ; Voice * 6
       	add     R14, R12                ; (+1 = *2)
       	add     R14, R12                ; (+1 = *3)
       	rla     R12                     ; (*2 = *6)
       	add     #phase_inc, R12         ; Add phase inc pointer
       	cmp     #128, R13               ; Out of range note values are note off
       	jhs     note_off                ;
       	clr     R14                     ; Clear octave count
tst_note:                                ;
       	cmp     #116, R13               ; Within note table?
       	jge     get_pi                  ; Yes...
       	inc     R14                     ; Inc octave count
       	add     #12, R13                ; Add octave to note
       	jmp     tst_note                ; Check again...
get_pi: 	                                 ; Get phase increment
       	sub     #116, R13               ; Adjust for first note in table
       	rla     R13                     ; MIDI note * 4
       	rla     R13                     ;
       	add     #notes, R13             ; Add note table pointer
       	mov     @R13+, R15              ; Get LSW
       	mov     @R13, R13               ; Get MSW
       	tst     R14                     ; Shifting required?
       	jeq     set_phase               ; No...
shift_phase:                             ;
       	rra     R13                     ; Shift phase inc
       	rrc     R15                     ;
       	dec     R14                     ; Dec octave count
       	jne     shift_phase             ; Repeat until zero...
set_phase:                               ;
       	mov     R15, 0(R12)             ; Set phase inc
       	mov     R13, 2(R12)             ;
       	pop     4(R12)                  ; Set voice level
       	reta                            ; Return
                                       ;
note_off:                                ;
       	incd    SP                      ; Discard level
       	clr     0(R12)                  ; Clear phase inc
       	clr     2(R12)                  ;
       	.if 0                           ; Note: Abrupt return to zero causes poping
       	clr     4(R12)                  ; Clear level
       	add     #phase_acc - phase_inc, R12 ; Phase accum pointer
       	clr     0(R12)                  ; Clear phase accum
       	clr     2(R12)                  ;
       	.endif                          ;
       	reta                            ; Return
                                       ;
notes                                   ; MIDI Note  Frequency
       	.if smplrt == 32000             ; 32000 sps
       	.long    3483828                ; 116  G#8  6644.87457275391
       	.long    3690988                ; 117   A8  7040.00091552734
       	.long    3910465                ; 118  A#8  7458.62007141113
       	.long    4142993                ; 119   B8  7902.13203430176
       	.long    4389349                ; 120   C9  8372.01881408691
       	.long    4650353                ; 121  C#9  8869.84443664551
       	.long    4926877                ; 122   D9  9397.27210998535
       	.long    5219845                ; 123  D#9  9956.06422424316
       	.long    5530233                ; 124   E9  10548.0823516846
       	.long    5859077                ; 125   F9  11175.3025054932
       	.long    6207476                ; 126  F#9  11839.8208618164
       	.long    6576592                ; 127   G9  12543.8537597656
       	.endif                          ;
                                       ;
       	.if smplrt == 48000             ; 48000 sps
       	.long    2322552                ; 116  G#8  6644.87457275391
       	.long    2460658                ; 117   A8  7039.99900817871
       	.long    2606977                ; 118  A#8  7458.62102508545
       	.long    2761996                ; 119   B8  7902.13394165039
       	.long    2926232                ; 120   C9  8372.01690673828
       	.long    3100235                ; 121  C#9  8869.84348297119
       	.long    3284585                ; 122   D9  9397.27306365967
       	.long    3479896                ; 123  D#9  9956.06231689453
       	.long    3686822                ; 124   E9  10548.0823516846
       	.long    3906052                ; 125   F9  11175.3044128418
       	.long    4138318                ; 126  F#9  11839.8227691650
       	.long    4384395                ; 127   G9  12543.8547134399
       	.endif                          ;

sine
       	.int    0
       	.int    804
       	.int    1608
       	.int    2410
       	.int    3212
       	.int    4011
       	.int    4808
       	.int    5602
       	.int    6393
       	.int    7179
       	.int    7962
       	.int    8739
       	.int    9512
       	.int    10278
       	.int    11039
       	.int    11793
       	.int    12539
       	.int    13279
       	.int    14010
       	.int    14732
       	.int    15446
       	.int    16151
       	.int    16846
       	.int    17530
       	.int    18204
       	.int    18868
       	.int    19519
       	.int    20159
       	.int    20787
       	.int    21403
       	.int    22005
       	.int    22594
       	.int    23170
       	.int    23731
       	.int    24279
       	.int    24811
       	.int    25329
       	.int    25832
       	.int    26319
       	.int    26790
       	.int    27245
       	.int    27683
       	.int    28105
       	.int    28510
       	.int    28898
       	.int    29268
       	.int    29621
       	.int    29956
       	.int    30273
       	.int    30571
       	.int    30852
       	.int    31113
       	.int    31356
       	.int    31580
       	.int    31785
       	.int    31971
       	.int    32137
       	.int    32285
       	.int    32412
       	.int    32521
       	.int    32609
       	.int    32678
       	.int    32728
       	.int    32757
       	.int    32767
       	.int    32757
       	.int    32728
       	.int    32678
       	.int    32609
       	.int    32521
       	.int    32412
       	.int    32285
       	.int    32137
       	.int    31971
       	.int    31785
       	.int    31580
       	.int    31356
       	.int    31113
       	.int    30852
       	.int    30571
       	.int    30273
       	.int    29956
       	.int    29621
       	.int    29268
       	.int    28898
       	.int    28510
       	.int    28105
       	.int    27683
       	.int    27245
       	.int    26790
       	.int    26319
       	.int    25832
       	.int    25329
       	.int    24811
       	.int    24279
       	.int    23731
       	.int    23170
       	.int    22594
       	.int    22005
       	.int    21403
       	.int    20787
       	.int    20159
       	.int    19519
       	.int    18868
       	.int    18204
       	.int    17530
       	.int    16846
       	.int    16151
       	.int    15446
       	.int    14732
       	.int    14010
       	.int    13279
       	.int    12539
       	.int    11793
       	.int    11039
       	.int    10278
       	.int    9512
       	.int    8739
       	.int    7962
       	.int    7179
       	.int    6393
       	.int    5602
       	.int    4808
       	.int    4011
       	.int    3212
       	.int    2410
       	.int    1608
       	.int    804
       	.int    0
       	.int    -804
       	.int    -1608
       	.int    -2410
       	.int    -3212
       	.int    -4011
       	.int    -4808
       	.int    -5602
       	.int    -6393
       	.int    -7179
       	.int    -7962
       	.int    -8739
       	.int    -9512
       	.int    -10278
       	.int    -11039
       	.int    -11793
       	.int    -12539
       	.int    -13279
       	.int    -14010
       	.int    -14732
       	.int    -15446
       	.int    -16151
       	.int    -16846
       	.int    -17530
       	.int    -18204
       	.int    -18868
       	.int    -19519
       	.int    -20159
       	.int    -20787
       	.int    -21403
       	.int    -22005
       	.int    -22594
       	.int    -23170
       	.int    -23731
       	.int    -24279
       	.int    -24811
       	.int    -25329
       	.int    -25832
       	.int    -26319
       	.int    -26790
       	.int    -27245
       	.int    -27683
       	.int    -28105
       	.int    -28510
       	.int    -28898
       	.int    -29268
       	.int    -29621
       	.int    -29956
       	.int    -30273
       	.int    -30571
       	.int    -30852
       	.int    -31113
       	.int    -31356
       	.int    -31580
       	.int    -31785
       	.int    -31971
       	.int    -32137
       	.int    -32285
       	.int    -32412
       	.int    -32521
       	.int    -32609
       	.int    -32678
       	.int    -32728
       	.int    -32757
       	.int    -32767
       	.int    -32757
       	.int    -32728
       	.int    -32678
       	.int    -32609
       	.int    -32521
       	.int    -32412
       	.int    -32285
       	.int    -32137
       	.int    -31971
       	.int    -31785
       	.int    -31580
       	.int    -31356
       	.int    -31113
       	.int    -30852
       	.int    -30571
       	.int    -30273
       	.int    -29956
       	.int    -29621
       	.int    -29268
       	.int    -28898
       	.int    -28510
       	.int    -28105
       	.int    -27683
       	.int    -27245
       	.int    -26790
       	.int    -26319
       	.int    -25832
       	.int    -25329
       	.int    -24811
       	.int    -24279
       	.int    -23731
       	.int    -23170
       	.int    -22594
       	.int    -22005
       	.int    -21403
       	.int    -20787
       	.int    -20159
       	.int    -19519
       	.int    -18868
       	.int    -18204
       	.int    -17530
       	.int    -16846
       	.int    -16151
       	.int    -15446
       	.int    -14732
       	.int    -14010
       	.int    -13279
       	.int    -12539
       	.int    -11793
       	.int    -11039
       	.int    -10278
       	.int    -9512
       	.int    -8739
       	.int    -7962
       	.int    -7179
       	.int    -6393
       	.int    -5602
       	.int    -4808
       	.int    -4011
       	.int    -3212
       	.int    -2410
       	.int    -1608
       	.int    -804
       	.int    0

;------	-------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

            .sect   ".int53"            ; TA0CCR0 CCIFG0
       		.short  synth_isr           ;

