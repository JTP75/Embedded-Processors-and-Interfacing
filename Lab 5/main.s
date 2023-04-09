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
		
max_angle	EQU	207			; max angle (~145 deg) converted to FULL steps		ACTUAL CONVERSION: 		513 steps = 360 degrees
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;	Enable clocks for GPIOC, GPIOB//;	Enable clocks for GPIOA, GPIOB
		
	; Set GPIOC pin 13 (blue button) as an input pin//; Set GPIOA pin 0 (center joystick button) as an input pin
	
	; Set GPIOB pins 2, 3, 6, 7 as output pins
	
	; notes:
	; PB2 ->  A
	; PB6 ->  B
	; PB3 -> ~A
	; PB7 -> ~B
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; init fcns
	BL System_Clock_Init
	BL UART2_Init
	
	; clk en
	LDR	r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #0x00000006
	STR r1, [r0, #RCC_AHB2ENR]
	
	; gpio b
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	MOV r2, #0x0000F0F0
	BIC r1, r1, r2
	MOV r2, #0x00005050
	ORR r1, r1, r2
	STR r1, [r0, #GPIO_MODER]
	LDR r1, [r0, #GPIO_OTYPER]
	BIC r1, r1, #0x000000CC
	STR r1, [r0, #GPIO_OTYPER]
	
	; gpio c
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, r1, #0x0C000000
	STR r1, [r0, #GPIO_MODER]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__loop

	; load bases
	LDR r0, =GPIOC_BASE		; input 	PC13
	
	; check button
	LDR r1, [r0, #GPIO_IDR]
	AND r1, r1, #0x00002000
	CMP r1, #0x00002000
	BEQ	__loop
	BL delay
	
	
	LDR r2, =max_angle
	LDR r3, =0
	LDR r4, =0
forward_loop
	PUSH {r2}
	BL frontstep
	POP {r2}
	
	ADD r3, r3, #1
	CMP 	r3, #8
	CMPNE 	r3, #9
	CMPNE	r3, #10
	ADDNE r4, r4, #1
	
	BNE writeDirCCW
WDCCWBack
	PUSH {r0}
	MOV r0, r4
	BLNE printval
	POP {r0}
	BNE endl1
endlBack1
	
	CMP	r3, #10
	LDREQ r3, =0
	
	SUBS r2, r2, #1
	BNE forward_loop
	
	
	LDR r2, =max_angle
	LDR r3, =0
	LDR r4, =147
reverse_loop
	PUSH {r2}
	BL backstep
	POP {r2}
	
	ADD r3, r3, #1
	CMP 	r3, #8
	CMPNE 	r3, #9
	CMPNE	r3, #10
	SUBNE r4, r4, #1
	BNE writeDirCW
WDCWBack
	PUSH {r0}
	MOV r0, r4
	BLNE printval
	POP {r0}
	BNE endl2
endlBack2
	
	CMP	r3, #10
	LDREQ r3, =0
	
	SUBS r2, r2, #1
	BNE reverse_loop
	
	
	B __loop
	
	
writeDirCCW
	PUSH {r0,r1,r2,r3,r4}
	LDR r0, =ccw
	MOV r1, #22
	BL USART2_Write
	POP {r0,r1,r2,r3,r4}
	B WDCCWBack
writeDirCW
	PUSH {r0,r1,r2,r3,r4}
	LDR r0, =cw
	MOV r1, #22
	BL USART2_Write
	POP {r0,r1,r2,r3,r4}
	B WDCWBack
endl1 
	PUSH {r0,r1,r2,r3,r4}
	LDR r0, =ndl
	MOV r1, #4
	BL USART2_Write
	POP {r0,r1,r2,r3,r4}
	B endlBack1
endl2 
	PUSH {r0,r1,r2,r3,r4}
	LDR r0, =ndl
	MOV r1, #4
	BL USART2_Write
	POP {r0,r1,r2,r3,r4}
	B endlBack2

	ENDP
		

; delay subroutine (no args)
delay	PROC
	
	LDR	r2, =50000			; 3000 works for neither inits, 99999 works for sysclk, 
delayloop
	SUBS	r2, #1
	BNE	delayloop
	
	BX LR
	ENDP
		
		
; delay subroutine (no args)
printval	PROC

	LDR r5, =0x20000050		; first memory address
	STR r0, [r5]
	PUSH {r1,r2,r3,r4,r5,LR}
	MOV r0, r5
	MOV r1, #3
	BL USART2_Write
	POP {r1,r2,r3,r4,r5,LR}
	
	BX LR
	ENDP
		
		
; forward step subroutine (no args)
frontstep	PROC
	LDR r0, =GPIOB_BASE
	
	; set A & ~B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; set A & B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; set ~A & B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; set ~A & ~B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; reset all
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	STR r1, [r0, #GPIO_ODR]
	
	BX LR
	ENDP
		
		
; backward step subroutine (no args)
backstep	PROC
	LDR r0, =GPIOB_BASE
	
	; set ~A & ~B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000088
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; set ~A & B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000048
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; set A & B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000044
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; set A & ~B
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	ORR r1, r1, #0x00000084
	STR r1, [r0, #GPIO_ODR]
	PUSH {LR}
	BL	delay
	POP {LR}
	
	; reset all
	LDR r1, [r0, #GPIO_ODR]
	BIC r1, r1, #0x000000CC
	STR r1, [r0, #GPIO_ODR]
	
	BX LR
	ENDP	
	
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN
		
ccw DCB "Direction: CCW\tAngle: ", 0		; <- the 0 corresponds to a null terminator
cw	DCB "Direction: CW \tAngle: ", 0
ndl DCB "\n\r", 0

	END