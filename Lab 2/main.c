#include "stm32l476xx.h"
#include "SysClock.h"
#include "UART.h"

#include <string.h>
#include <stdio.h>

// PA.5  <--> Green LED
// PC.13 <--> Blue user button
#define LED_PIN    5
#define BUTTON_PIN 13

uint32_t shortDelay = 200000;
uint32_t longDelay = 800000;
uint32_t spaceDelay = 1200000;
uint32_t letterDelay = 400000;



void demo_of_printf_scanf(){
	char rxByte;
	printf("Are you enrolled in ECE 202 (Y or N ):\r\n");
	scanf ("%c", &rxByte);
	if (rxByte == 'N' || rxByte == 'n'){
		printf("You should not be here!!!\r\n\r\n");
	}
	else if (rxByte == 'Y' || rxByte == 'y'){
		printf("Welcome!!! \n\r\n\r\n");
	}
}

void pulseLED(uint32_t duration){
	GPIOA->ODR |= 2UL<<4;							// turn LED on
	USART_Delay(duration);						// wait for duration
	GPIOA->ODR &= ~(2UL<<4);					// turn LED off
	USART_Delay(shortDelay);					// wait extra time to let led turn off
}

uint8_t detectDoublePulse(){
	
}
	
int main(void){

	System_Clock_Init(); // Switch System Clock = 80 MHz
	UART2_Init(); // Communicate with Tera Term
	
	//demo_of_printf_scanf();
	
	
	
	// enable clock for GPIO A and GPIO C
	
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN + RCC_AHB2ENR_GPIOCEN;		// add the values
	
	// Configure PA5 (LED)
	
	GPIOA->MODER &= ~(0xC<<8);					// clear mode bits for pin 5
	GPIOA->MODER |= 4<<8;								// set to output mode (set to 01)
	GPIOA->OTYPER &= ~(2UL<<4);					// set to push-pull mode
	
	GPIOA->PUPDR &= ~(0xC<<8);
	
	// Configure PC13 (button)
	
	GPIOC->MODER &= ~(0xC<<24);												// reset mode bits for pin 13 (leave as 00)
	GPIOC->OTYPER &= ~(0xC<<24);											// set to push-pull mode
	
	GPIOA->PUPDR &= ~(0xC<<24);
	
	int butt = 1;
	GPIOA->ODR &= ~(2UL<<4);
	
	while(butt==1){butt = GPIOC->IDR & 2<<12;}
	GPIOA->ODR |= 2UL<<4;
	while(butt==0){butt = GPIOC->IDR & 2<<12;}
	
	long time = 0;
	while(butt==1){butt = GPIOC->IDR & 2<<12; time++;}
	GPIOA->ODR &= ~(2UL<<4);
	while(butt==0){butt = GPIOC->IDR & 2<<12;}
	
	while(1)
	{
		pulseLED(shortDelay);
	}
	
	// Read from PC13 and Set LED light
	// The blue user button is pulled up externally. 
	// The GPIO input is low if the button is pressed down.
	/*
	// loop
	uint32_t input;
	while(1)											// loop program continuously
	{
		input = GPIOC->IDR & (2<<12);		// read button input (8192 when not pressed, 0 when pressed)
		
		if(input == 0){
			GPIOA->ODR ^= 2UL<<4;
			USART_Delay(shortDelay);
		}
		else{
			
		}
		
		
		
		
		
		
		
		
		
		
		if(input==0)								// if button is pressed:
		{
			
			GPIOA->ODR ^= 2UL<<4;
			USART_Delay(shortDelay);
		// blink "I love ece 202" in morse code:     .. / .-.. --- ...- . / . -.-. . / ..--- ----- ..---
		pulseLED(shortDelay);				// i
		pulseLED(shortDelay);
		USART_Delay(letterDelay);
			
		USART_Delay(spaceDelay);		// /space/
		
			
		pulseLED(shortDelay);				// l
		pulseLED(longDelay);
		pulseLED(shortDelay);
		pulseLED(shortDelay);
		USART_Delay(letterDelay);
			
		pulseLED(longDelay);				// o
		pulseLED(longDelay);
		pulseLED(longDelay);
		USART_Delay(letterDelay);
			
		pulseLED(shortDelay);				// v
		pulseLED(shortDelay);
		pulseLED(shortDelay);
		pulseLED(longDelay);
		USART_Delay(letterDelay);
		
		pulseLED(shortDelay);				// e
		USART_Delay(letterDelay);
		
		USART_Delay(spaceDelay);		// /space/
		
		
		pulseLED(shortDelay);				// e
		USART_Delay(letterDelay);
		
		pulseLED(longDelay);				// c
		pulseLED(shortDelay);
		pulseLED(longDelay);
		pulseLED(shortDelay);
		USART_Delay(letterDelay);
		
		pulseLED(shortDelay);				// e
		USART_Delay(letterDelay);
		
		USART_Delay(spaceDelay);		// /space/
		
		
		pulseLED(shortDelay);				// 2
		pulseLED(shortDelay);
		pulseLED(longDelay);
		pulseLED(longDelay);
		pulseLED(longDelay);
		USART_Delay(letterDelay);
		
		pulseLED(longDelay);				// 0
		pulseLED(longDelay);
		pulseLED(longDelay);
		pulseLED(longDelay);
		pulseLED(longDelay);
		USART_Delay(letterDelay);
		
		pulseLED(shortDelay);				// 2
		pulseLED(shortDelay);
		pulseLED(longDelay);
		pulseLED(longDelay);
		pulseLED(longDelay);
		USART_Delay(letterDelay);
		
		
		
		USART_Delay(spaceDelay);		// end transmission
		USART_Delay(spaceDelay);
		USART_Delay(spaceDelay);
	}
	else
	{
		//GPIOA->ODR &= ~(2UL<<4);
	}
	}*/

}
