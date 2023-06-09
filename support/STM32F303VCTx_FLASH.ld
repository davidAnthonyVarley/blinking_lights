/*
******************************************************************************
**

**  File        : LinkerScript.ld
**
**  Author		  : STM32CubeMX
**
**                with modifications for CSU11021/CSU11022 by
**                Jonathan Dukes (jdukes@tcd.ie)
**                https://www.scss.tcd.ie
**
**  Abstract    : Linker script for STM32F100RBTx series
**                128Kbytes FLASH and 8Kbytes RAM
**
**                Set heap size, stack size and stack location according
**                to application requirements.
**
**                Set memory bank area and size if external memory is used.
**
**  Target      : STMicroelectronics STM32
**
**  Distribution: The file is distributed “as is,” without any warranty
**                of any kind.
**
*****************************************************************************
** @attention
**
** <h2><center>&copy; COPYRIGHT(c) 2019 STMicroelectronics</center></h2>
**
** Redistribution and use in source and binary forms, with or without modification,
** are permitted provided that the following conditions are met:
**   1. Redistributions of source code must retain the above copyright notice,
**      this list of conditions and the following disclaimer.
**   2. Redistributions in binary form must reproduce the above copyright notice,
**      this list of conditions and the following disclaimer in the documentation
**      and/or other materials provided with the distribution.
**   3. Neither the name of STMicroelectronics nor the names of its contributors
**      may be used to endorse or promote products derived from this software
**      without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
** CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
** OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
*****************************************************************************
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = ORIGIN(RAM) + LENGTH(RAM);    /* end of RAM */

/* Generate a link error if the stack does't fit into RAM */
_Min_Stack_Size = 0x400; /* required amount of stack */

/* Specify the memory areas */
MEMORY
{
RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 40K
FLASH (rx)     : ORIGIN = 0x8000000, LENGTH = 256K
}

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
      . = ALIGN(4);
    KEEP(*(.isr_vector))       /* Exception vector table etc. */
    . = ALIGN(4);
  } >FLASH

  /* The program code and other data goes into FLASH */
  .text :
  {
    *(.text)                   /* .text sections (code) */
    *(.text*)                  /* .text* sections (code) */
  } >FLASH

  /* Constant data goes into FLASH */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)                 /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)                /* .rodata* sections (constants, strings, etc.) */
  } >FLASH

  /* Not currently used for bare betal but define for future use */
  .bss :
  {
    . = ALIGN(4);
    _sbss = . ;
    *(.bss .bss.*)
    *(COMMON)
    _ebss = . ;
  } >RAM

  /* Initialized data sections goes into RAM, load LMA copy after RODATA */
  .data : 
  {
    _load_address = LOADADDR(.data);
    . = ALIGN(4);
    _sdata = .;
    KEEP(*(.data.test))       /* .data sections for test.s should go before student data */
    . = ALIGN(4);
    KEEP(*(.data))            /* .data sections for student */
    KEEP(*(.data*))           /* .data* sections for student */
    _edata = .;
  } >RAM AT> FLASH
}


