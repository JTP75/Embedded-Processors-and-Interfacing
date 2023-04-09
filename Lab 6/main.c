#include "stm32l476xx.h"
#include "I2C.h"
#include "ssd1306.h"
#include "SysClock.h"
#include "UART.h"

#include <string.h>
#include <stdio.h>


// fcns
void System_Clock_Init(void);
void RTC_Clock_Init(void);
void RTC_Init(void);
void I2C_GPIO_init(void);
void DisplayString(char* messge);


// globals
char time[] = "13:59:30";
int HT, HU, mT, mU, sT, sU;
int sU_prev;

void DisplayString(char* message)
{
	ssd1306_Fill(White);
	ssd1306_SetCursor(2,0);
	ssd1306_WriteString(message, Font_11x18, Black);
	ssd1306_UpdateScreen();
}
bool check_alraf(void)
{
  if((RTC->ISR & RTC_ISR_ALRAF) == 0) return;
  RTC->ISR &= ~RTC_ISR_ALRAF;
  EXTI->PR1 |= EXTI_PR1_PIF18;
}
void SysTick_Handler(void)
{
  // load values from RTC into curr Hms
	HT = ((RTC->TR & RTC_TR_HT)>>20);
  HU = ((RTC->TR & RTC_TR_HU)>>16);
  mT = ((RTC->TR & RTC_TR_MNT)>>12);
  mU = ((RTC->TR & RTC_TR_MNU)>>8);
  sT = ((RTC->TR & RTC_TR_ST)>>4);
  sU = ((RTC->TR & RTC_TR_SU)>>0);

  // check if second has passed, return if not
  if(sU == sU_prev) return;

  time[0] = HT + '0';
  time[1] = HU + '0';
  time[3] = mT + '0';
  time[4] = mU + '0';
  time[6] = sT + '0';
  time[7] = sU + '0';

  DisplayString(time);

  sU_prev = sU;
}


int main(void)
{	
	// Enable High Speed Internal Clock (HSI = 16 MHz)
  RCC->CR |= ((uint32_t)RCC_CR_HSION);
	
  // wait until HSI is ready
  while ( (RCC->CR & (uint32_t) RCC_CR_HSIRDY) == 0 );
	
  // Select HSI as system clock source 
  RCC->CFGR &= (uint32_t)((uint32_t)~(RCC_CFGR_SW));
  RCC->CFGR |= (uint32_t)RCC_CFGR_SW_HSI;  //01: HSI16 oscillator used as system clock

  // Wait till HSI is used as system clock source 
  while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS) == 0 );

	NVIC_SetPriority(SysTick_IRQn, 1);		// Set Priority to 1
	NVIC_EnableIRQ(SysTick_IRQn);					// Enable EXTI0_1 interrupt in NVIC
	
	/* ====================================== INITS ====================================== */
	System_Clock_Init();
	I2C_GPIO_init();
	I2C_Initialization(I2C1);
	ssd1306_Init();
	RTC_Clock_Init();
  
  /* ==================================== RTC_CLOCK ==================================== */
  // disable write prot
  RTC->WPR = 0x000000CA;
	RTC->WPR = 0x00000053;

  // enter init mode
  RTC->ISR |= RTC_ISR_INIT;
  while( (RTC->ISR & RTC_ISR_INITF) != RTC_ISR_INITF );    // wait for init flag

  // set initial time to 13:59:30
  RTC->TR = 0x135930;

	// disable alarm A
	RTC->CR &= ~RTC_CR_ALRAE;
  while( (RTC->ISR & RTC_ISR_ALRAWF) != RTC_ISR_ALRAWF );

  // alarm cfg
  RTC->ALRMAR = 0x00008000; // set to go off when minute = 00 (i.e. on the hour)

  // re-enable alarm A
  RTC->CR |= RTC_CR_ALRAE;

  // exit init mode
  RTC->ISR &= ~RTC_ISR_INIT;

  // enable write prot
  RTC->WPR = 0x000000FF;


  /* ==================================== SYS_CLOCK ==================================== */
  // disable systick_irq
  SysTick->CTRL &= 0x00000000;

  /** set reload value
  * @note  reload value calculations: 
  * 
  *              systick clock = 80MHz = 80e6Hz
  *              interrupt period = 1ms = 1e-3s
  * 
  *              ( 80e6Hz * 10e-3s ) - 1  =  80e3 - 1  =  79999  =  0x0001387F
  */
  SysTick->LOAD = 79999;

  // reset systick_val
  SysTick->VAL &= 0x00000000;

  // select intern clock, set systick bit, and set enable bit
  SysTick->CTRL |= 0x00000007;


  /* =================================================================================== */

  // Dead loop & program hangs here
	while(1);
}




	
