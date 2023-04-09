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
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
		
	BL System_Clock_Init
	BL UART2_Init
	
	MOV 	r0, #0xFFFFFFFF
	MOV 	r1, #0x00000000
	MOV 	r2, #0x0000002A
	MOV 	r3, #0x00000000
	
	ADDS 	r4, r0, r2
	ADC		r5, r1, r3
	
	PUSH {r0,r2,r1,r5}
  
stop 	B 		stop     		; dead loop & program hangs here

	ENDP
	END