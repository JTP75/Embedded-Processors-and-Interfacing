;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
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
	IMPORT 	USART_Delay
	
; D = MSB, A = LSB
D_PIN	EQU	7
C_PIN	EQU	6
B_PIN	EQU	3
A_PIN	EQU	2
	
; button pin
BUT_PIN EQU 13
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
		
	BL System_Clock_Init
	BL UART2_Init
	
	; enable clock for GPIO ports B & C
	LDR r0, =RCC_BASE						; load RCC base address to r0
	LDR r1, [r0, #RCC_AHB2ENR]				; load RCC_AHB2ENR address to r1 (RCC_BASE offset by imm RCC_AHB2ENR)
	ORR r1, r1, #0x00000006					; enable B&C on bits 1&2: 0b00000110 = 0x00000006 ORRed w/ r1
	STR r1, [r0, #RCC_AHB2ENR]				; store contents of r1 to RCC_AHB2ENR address
	
	; GPIO B init
	LDR r0, =GPIOB_BASE						; load GPIOB_BASE to r0
	
	LDR r1, [r0, #GPIO_MODER]				; load MODER address
	MOV r10, #0x0000F0F0
	MOV r11, #0x00005050
	BIC r1, r1, r10							; MASK: pin 2,3,6,7 bits: 4&5, 6&7, 12&13, 14&15 = 0b1111000011110000 = 0x0000F0F0
	ORR r1, r1, r11							; set pins' 2,3,6,7 bits to 01 (general purpose output)
	STR r1, [r0, #GPIO_MODER]				; store result back in MODER
	
	LDR r1, [r0, #GPIO_OTYPER]				; load otyper
	BIC r1, r1, #0x000000CC					; clear bits 2,3,6,7
	STR r1, [r0, #GPIO_OTYPER]				; store
	
	; GPIO C init
	LDR r1, =GPIOC_BASE						; load GPIOC_BASE to r1
	
	LDR r2, [r1, #GPIO_MODER]				; load MODER address
	BIC r2, r2, #0x0C000000					; reset pin 13 to 00 (input)
	STR r2, [r1, #GPIO_MODER]				; store result back in MODER
	
	LDR r2, [r1, #GPIO_OTYPER]				; load otyper
	BIC r2, r2, #0x00002000					; clear bit 13 (push-pull)
	STR r2, [r1, #GPIO_OTYPER]				; store
	
; *******************************************************************************************************************************************************
; WARNING: due to bonus, comments may be inaccurate

	MOV	r3, #9								; init counter in r3

loop
	
	AND r4, r3, #1							; and r3 with 0001 to get value of bit 0 (A)
 	AND r5, r3, #2							; and r3 with 0010 to get value of bit 1 (B)
	AND r6, r3, #4							; and r3 with 0100 to get value of bit 2 (C)
	AND r7, r3, #8							; and r3 with 1000 to get value of bit 3 (D)
	
	LSL r4, r4, #2							; shift registers to corresponding ODR positions
	LSL r5, r5, #2
	LSL r6, r6, #4
	LSL r7, r7, #4
	
	ADD r4, r4, r5							; sum registers into r4 for ODR value
	ADD r4, r4, r6
	ADD r4, r4, r7
	
	LDR r0, =GPIOB_BASE						; load GPIOB_BASE to r0
	STR r4, [r0, #GPIO_ODR]					; store r4 to ODR
	
	MOV r10, #0								; counter for wait
	SUB r3, r3, #2							; decr counter
	CMP r3, #0	 							; compare r3 to 10 (post increment)
;	BLE	wait								; go back to button loop if r3 <= 10
	BGT wait
;	B 	reset		 						; reset if r3 > 10
	
reset	
	MOV r3, #9								; otherwise reset r3
;	MOV r10, #0x00000084
;	STR r10, [r0, #GPIO_ODR]	
	B	wait								; go back to button loop
	
wait
;	B	check_button
;back
	ADD r10, r10, #1
	MOV r11, #00008000
	LSL r11, r11, #8
	CMP r10, r11
	BLE	wait
;	B	loop
	
check_button

	LDR r1, =GPIOC_BASE						; load GPIOC_BASE to r1
	LDR r8, [r1, #GPIO_IDR]					; load IDR to r8
	
	AND r8, r8, #0x00002000					; and with bit 13 for button state (and sets rest of register to 0)
	CMP r8, #0x00002000						; compare r4 to 0x00002000
;	BNE	loop								; if not equal, branch back to check_button
	BEQ check_button
	B	loop								; otherwise, branch to button_pressed
	
	ENDP
					
	ALIGN			

	AREA    myData, DATA, READWRITE
	ALIGN
str	DCB   "Pacella\r\n", 0
	END