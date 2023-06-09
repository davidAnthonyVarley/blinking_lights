  .equ    GPIOE_BASE, 0x48001000
  .equ    GPIOE_MODER, (GPIOE_BASE + 0x00)
  .equ    GPIOE_OTYPER, (GPIOE_BASE + 0x04)
  .equ    GPIOE_OSPEEDR, (GPIOE_BASE + 0x08)
  .equ    GPIOE_PUPDR, (GPIOE_BASE + 0x0C)
  .equ    GPIOE_IDR, (GPIOE_BASE + 0x10)
  .equ    GPIOE_ODR, (GPIOE_BASE + 0x14)
  .equ    GPIOE_BSRR, (GPIOE_BASE + 0x18)
  .equ    GPIOE_LCKR, (GPIOE_BASE + 0x1C)
  .equ    GPIOE_AFRL, (GPIOE_BASE + 0x20)
  .equ    GPIOE_AFRH, (GPIOE_BASE + 0x24)

  .equ    LEVEL1_CORRECT_ANSWER, 3
  .equ    LEVEL2_CORRECT_ANSWER, 4
  .equ    LEVEL3_CORRECT_ANSWER, 6
  .equ    LEVEL4_CORRECT_ANSWER, 2
  .equ    LEVEL5_CORRECT_ANSWER, 3
  
  .equ    LEVEL6_CORRECT_ANSWER, 1
  .equ    LEVEL7_CORRECT_ANSWER, 7
  .equ    LEVEL8_CORRECT_ANSWER, 4
  .equ    LEVEL9_CORRECT_ANSWER, 5
  .equ    LEVEL10_CORRECT_ANSWER, 6



  .equ    RCC_BASE, 0x40021000
  .equ    RCC_AHBENR, (RCC_BASE + 0x14)
  .equ    RCC_AHBENR_GPIOEEN_BIT, 21

  .equ    SYSTICK_BASE, 0xE000E010
  .equ    SYSTICK_CSR, (SYSTICK_BASE + 0x00)
  .equ    SYSTICK_LOAD, (SYSTICK_BASE + 0x04)
  .equ    SYSTICK_VAL, (SYSTICK_BASE + 0x08)

  .equ    SYSCFG_BASE, (0x40010000)
  .equ    SYSCFG_EXTIICR1, (SYSCFG_BASE + 0x08)

  .equ    NVIC_ISER, 0xE000E100

  .equ    EXTI_BASE, 0x40010400
  .equ    EXTI_IMR, (EXTI_BASE + 0x00)
  .equ    EXTI_RTSR, (EXTI_BASE + 0x08)
  .equ    EXTI_FTSR, (EXTI_BASE + 0x0C)
  .equ    EXTI_PR, (EXTI_BASE + 0x14)

  .equ    LD3_PIN, 9
  .equ    LD4_PIN, 8
  .equ    LD5_PIN, 10
  .equ    LD6_PIN, 15
  .equ    LD7_PIN, 11
  .equ    LD8_PIN, 14
  .equ    LD9_PIN, 12
  .equ    LD10_PIN, 13
  //.equ    current_LED_to_illuminate, 0

  .equ    ALL_PINS, 0x0000FF00
  
  .equ    SCB_BASE, 0xE000ED00
  .equ    SCB_ICSR, (SCB_BASE + 0x04)
  .equ    SCB_ICSR_PENDSTCLR, (1<<25)
  