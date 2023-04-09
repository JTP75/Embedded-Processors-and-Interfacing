
#include "UART.h"
#include <stdio.h>

// Implement a dummy __FILE struct, which is called with the FILE structure.
struct __FILE {
    int dummy;
};

// We have to define FILE if prinf is used
FILE __stdout;
FILE __stdin;
 
// Retarget printf() to USART2
int fputc(int ch, FILE *f) { 
  uint8_t c;
  c = ch & 0x00FF;
  USART_Write(USART2, (uint8_t *)&c, 1);
  return(ch);
}

// Retarget scanf() to USART2
int fgetc(FILE *f) {  
  uint8_t rxByte;
  rxByte = USART_Read(USART2);
  return rxByte;
}
