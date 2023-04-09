;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attention
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************


	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
		
row1	EQU	0x0000000E	; R1 = ~PC0		0b1110
row2	EQU	0x0000000D	; R2 = ~PC1		0b1101
row3	EQU	0x0000000B	; R3 = ~PC2		0b1011
row4	EQU	0x00000007	; R4 = ~PC3		0b0111
col1	EQU	0x0000003C	; C1 = ~PB1		0b1X110X
col2	EQU 0x0000003A	; C2 = ~PB2		0b1X101X
col3	EQU 0x00000036	; C3 = ~PB3		0b1X011X
col4	EQU	0x0000000E	; C4 = ~PB5		0b0X111X

rpins	EQU 0x0000000F	; all rows high
cpins	EQU 0x0000003E	; all cols high
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	BL System_Clock_Init
	BL UART2_Init

;;;;;;;;;;;; INIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; periph clk config
	LDR 	r0, =RCC_BASE
	LDR 	r1, [r0, #RCC_AHB2ENR]
	ORR 	r1, r1, #0x00000006			; enable clk for B & C
	BIC		r1, r1, #0x00000001
	STR 	r1, [r0, #RCC_AHB2ENR]
	
	; GPIOB config (col pins)
	LDR 	r0, =GPIOB_BASE
	; moder
	LDR 	r1, [r0, #GPIO_MODER]
	MOV		r2, #0x00000CFC
	BIC 	r1, r1, r2					; reset bits 2,3, 4,5, 6,7, 10,11 (input)
	STR 	r1, [r0, #GPIO_MODER]
	
	; GPIOC config (row pins)
	LDR 	r0, =GPIOC_BASE
	; moder
	LDR 	r1, [r0, #GPIO_MODER]
	BIC 	r1, r1, #0x000000FF			; reset bits 0-7
	ORR 	r1, r1, #0x00000055			; set bits 0, 2, 4, 6	(output)
	STR 	r1, [r0, #GPIO_MODER]
	
;;;;;;;;;;;; MAIN LOOP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; register map
;	-	r0 & r1 contain GPIO B&C bases (reassign with each branch to _main_loop)
;	-	r2 contains the IDR row data
;	-	r3 contains the ODR col data
;
;


_main_loop
	
	; reassign bases (based)
	LDR 	r0, =GPIOB_BASE				; cols (input)		COLS = GPIOB = INPUT = r0
	LDR 	r1, =GPIOC_BASE				; rows (output)		ROWS = GPIOC = OUTPUT = r1
	BIC		r2, r2						; clear row register
	BIC		r3, r3						; clear col register
	
	; pull all rows low
	LDR 	r2, [r1, #GPIO_ODR]
	BIC 	r2, r2, #rpins				; clear rpin bits
	STR 	r2, [r1, #GPIO_ODR]
	; delay
	BL delay
	; read cols
	LDR 	r3, [r0, #GPIO_IDR]		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;;
	CMP 	r3, #cpins
	BEQ _main_loop						; if same, no keys are pressed, go back to _main_loop
	
	; pull row1 high
	LDR 	r2, [r1, #GPIO_ODR]
	BIC 	r2, r2, #rpins				; all rows low
	ORR		r2, r2, #row1				; row1 high
	STR 	r2, [r1, #GPIO_ODR]
	; delay
	PUSH	{r2}
	BL delay
	POP		{r2}
	; read cols
	LDR		r3, [r0, #GPIO_IDR]		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;;
	CMP		r3, #cpins
	BNE	testCols						; if not same, branch to testCols
	
	; pull row2 high
	LDR 	r2, [r1, #GPIO_ODR]
	BIC 	r2, r2, #rpins				; all rows low
	ORR		r2, r2, #row2				; row2 high
	STR 	r2, [r1, #GPIO_ODR]
	; delay
	PUSH	{r2}
	BL delay
	POP		{r2}
	; read cols
	LDR		r3, [r0, #GPIO_IDR]		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;;
	CMP		r3, #cpins
	BNE	testCols						; if not same, branch to testCols
	
	; pull row3 high
	LDR 	r2, [r1, #GPIO_ODR]
	BIC 	r2, r2, #rpins				; all rows low
	ORR		r2, r2, #row3				; row3 high
	STR 	r2, [r1, #GPIO_ODR]
	; delay
	PUSH	{r2}
	BL delay
	POP		{r2}
	; read cols
	LDR		r3, [r0, #GPIO_IDR]		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;;
	CMP		r3, #cpins
	BNE	testCols						; if not same, branch to testCols
	
	; pull row4 high
	LDR 	r2, [r1, #GPIO_ODR]
	BIC 	r2, r2, #rpins				; all rows low
	ORR		r2, r2, #row4				; row4 high
	STR 	r2, [r1, #GPIO_ODR]
	; delay
	PUSH	{r2}
	BL delay
	POP		{r2}
	; read cols
	LDR		r3, [r0, #GPIO_IDR]		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;;
	CMP		r3, #cpins
	BNE	testCols						; if not same, branch to testCols
	
	B	_main_loop						; back to main loop
	
	
testCols
	
	; r2 & r3 contain row & col data, respectively (inverted)
	; forms		r2: 0b[c4][c3][c2][c1]		r3: 0b[r4]X[r3][r2][r1]X
	; 			r2: 0x0000000[0-F]			r3: 0x000000[0 or 2][even, 0-E]
	; r4 stores row num
	
	; chars are offset by 4 for some reason
	
	CMP		r2, #row1
	CMPEQ	r3, #col1
	LDREQ	r7, =cheese
	MOVEQ	r5, #049					; 1
	BEQ	displaykey
	
	CMP		r2, #row2
	CMPEQ	r3, #col1
	LDREQ	r7, =char1
	MOVEQ	r5, #050					; 2
	BEQ	displaykey
	
	CMP		r2, #row3
	CMPEQ	r3, #col1
	LDREQ	r7, =char2
	MOVEQ	r5, #051					; 3
	BEQ	displaykey
	
	CMP		r2, #row4
	CMPEQ	r3, #col1
	LDREQ	r7, =char3
	MOVEQ	r5, #065					; A
	BEQ	displaykey
	
	CMP		r2, #row1
	CMPEQ	r3, #col2
	LDREQ	r7, =charA
	MOVEQ	r5, #052					; 4
	BEQ	displaykey
	
	CMP		r2, #row2
	CMPEQ	r3, #col2
	LDREQ	r7, =char4
	MOVEQ	r5, #053					; 5
	BEQ	displaykey
	
	CMP		r2, #row3
	CMPEQ	r3, #col2
	LDREQ	r7, =char5
	MOVEQ	r5, #054					; 6
	BEQ	displaykey
	
	CMP		r2, #row4
	CMPEQ	r3, #col2
	LDREQ	r7, =char6
	MOVEQ	r5, #066					; B
	BEQ	displaykey
	
	CMP		r2, #row1
	CMPEQ	r3, #col3
	LDREQ	r7, =charB
	MOVEQ	r5, #055					; 7
	BEQ	displaykey
	
	CMP		r2, #row2
	CMPEQ	r3, #col3
	LDREQ	r7, =char7
	MOVEQ	r5, #056					; 8
	BEQ	displaykey
	
	CMP		r2, #row3
	CMPEQ	r3, #col3
	LDREQ	r7, =char8
	MOVEQ	r5, #057					; 9
	BEQ	displaykey
	
	CMP		r2, #row4
	CMPEQ	r3, #col3
	LDREQ	r7, =char9
	MOVEQ	r5, #067					; C
	BEQ	displaykey
	
	CMP		r2, #row1
	CMPEQ	r3, #col4
	LDREQ	r7, =charC
	MOVEQ	r5, #042					; *
	BEQ	displaykey
	
	CMP		r2, #row2
	CMPEQ	r3, #col4
	LDREQ	r7, =charast
	MOVEQ	r5, #048					; 0
	BEQ	displaykey
	
	CMP		r2, #row3
	CMPEQ	r3, #col4
	LDREQ	r7, =char0
	MOVEQ	r5, #035					; #
	BEQ	displaykey
	
	CMP		r2, #row4
	CMPEQ	r3, #col4
	LDREQ	r7, =charpnd
	MOVEQ	r5, #068					; D
	BEQ	displaykey
	
	
displaykey

	LDR 	r0, =GPIOB_BASE				; rows (output)
	LDR 	r1, =GPIOC_BASE				; cols (input)
	LDR 	r2, [r1, #GPIO_ODR]
	BIC 	r2, r2, #rpins				; clear rpin bits
	STR 	r2, [r1, #GPIO_ODR]
	
waitForRelease
	LDR 	r3, [r0, #GPIO_IDR]		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;; 		;;;;;;;;;;;;;
	CMP 	r3, #cpins
	BNE waitForRelease					; if key is pressed, go back to waitForRelease
	
	STR		r5, [r8]
	ADD		r7, r7, #4
	MOV		r0, r7
	;LDR 	r0, =str   					; First argument
	MOV 	r1, #1    					; Second argument
	BL USART2_Write
 	B _main_loop
	
	ENDP		

			
		
; delay subroutine (no args)
delay	PROC
	; Delay for software debouncing
	LDR	r2, =0x9999
delayloop
	SUBS	r2, #1
	BNE	delayloop
	BX LR
	
	ENDP
		
		
		
		
					
	;ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN

cheese	DCD 100
char1	DCD	49
char2	DCD 50
char3	DCD 51
charA	DCD 65
char4	DCD 52
char5	DCD 53
char6	DCD 54
charB	DCD 66
char7	DCD 55
char8	DCD 56
char9	DCD 57
charC	DCD 67
charast	DCD 42
char0	DCD 48
charpnd	DCD 35
charD	DCD 68
enter	DCD 10
	
	END