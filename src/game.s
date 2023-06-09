# PASTE LINK TO TEAM VIDEO BELOW
# https://www.kapwing.com/videos/64394481b8bcf3001f7439eb
#

  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global Main
  .global  SysTick_Handler
  .global EXTI0_IRQHandler

  @ Definitions are in definitions.s to keep this file "clean"
  .include "./src/definitions.s"

  .equ    REST_BLINK_PERIOD, 800 //ie, spend 1 second off, 1 second on if equal to 1000  

  .section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RULES
  //green blinks -> get ready
  //must count the blue blinks between green and red
  //red blinks -> stop counting

  //orange lights -> press the button for the number of blue blinks that occured
  
  //if all lights flash, progress to next level
  //if constant red and orange lights, you are wrong, and have lost
  //if constant green, congradulations, you have won
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RULES



Main:
  PUSH  {R4-R5,LR}

  //stage 0 = flash green light
  //stage 1 = flash blinks
  //stage 2 = flash red light
  //stage 3 = flash orange lights
  //stage 4 = flash success/failure lights

  LDR R4, =game_blink_period  //will be decremented
  LDR R5, =750
  STR R5, [R4]

  LDR R4, =current_LED_to_illuminate
  LDR R5, =0
  STR R5, [R4]

  LDR R4, =advance_to_next_level
  LDR R5, =1
  STR R5, [R4]

  LDR R4, =stage_in_animation
  LDR R5, =0
  STR R5, [R4]

  LDR R4, =number_of_blinks
  LDR R5, =0
  STR R5, [R4]

  LDR R4, =wait_for_x_seconds
  LDR R5, =0
  STR R5, [R4]

  LDR R4, =current_level //if current level==0, user has failed
  LDR R5, =1
  STR R5, [R4]


  @
  @ Prepare GPIO Port E Pin 9 for output (LED LD3)
  @ We'll blink LED LD3 (the orange LED)
  @

  @ Enable GPIO port E by enabling its clock
  LDR     R4, =RCC_AHBENR
  LDR     R5, [R4]
  ORR     R5, R5, #(0b1 << (RCC_AHBENR_GPIOEEN_BIT))
  STR     R5, [R4]

  @ Configure LD3 for output
  @   by setting bits 27:26 of GPIOE_MODER to 01 (GPIO Port E Mode Register)
  @   (by BIClearing then ORRing)
  LDR     R4, =GPIOE_MODER
  LDR     R5, [R4]                    @ Read ...
  BIC     R5, #(0b11<<(LD3_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD3_PIN*2))    @ write 01 to bits 

  BIC     R5, #(0b11<<(LD4_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD4_PIN*2))    @ write 01 to bits 

  BIC     R5, #(0b11<<(LD10_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD10_PIN*2))    @ write 01 to bits 

  BIC     R5, #(0b11<<(LD5_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD5_PIN*2))    @ write 01 to bits 

  BIC     R5, #(0b11<<(LD6_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD6_PIN*2))    @ write 01 to bits 

  BIC     R5, #(0b11<<(LD7_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD7_PIN*2))    @ write 01 to bits 

  BIC     R5, #(0b11<<(LD8_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD8_PIN*2))    @ write 01 to bits 

  BIC     R5, #(0b11<<(LD9_PIN*2))    @ Modify ...
  ORR     R5, #(0b01<<(LD9_PIN*2))    @ write 01 to bits 

  STR     R5, [R4]                    @ Write 

  @ Initialise the first countdown

  LDR     R4, =blink_countdown
  LDR     R5, =REST_BLINK_PERIOD
  STR     R5, [R4]  

  @ Configure SysTick Timer to generate an interrupt every 1ms

  LDR     R4, =SCB_ICSR               @ Clear any pre-existing interrupts
  LDR     R5, =SCB_ICSR_PENDSTCLR     @
  STR     R5, [R4]                    @

  LDR     R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR     R5, =0                      @   by writing 0 to CSR
  STR     R5, [R4]                    @   CSR is the Control and Status Register
  
  LDR     R4, =SYSTICK_LOAD           @ Set SysTick LOAD for 1ms delay
  LDR     R5, =7999                   @ Assuming 8MHz clock
  STR     R5, [R4]                    @ 

  LDR     R4, =SYSTICK_VAL            @   Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @     by writing any value
  STR     R5, [R4]

  LDR     R4, =SYSTICK_CSR            @   Start SysTick timer by setting CSR to 0x7
  LDR     R5, =0x7                    @     set CLKSOURCE (bit 2) to system clock (1)
  STR     R5, [R4]                    @     set TICKINT (bit 1) to 1 to enable interrupts
                                      @     set ENABLE (bit 0) to 1


  @
  @ Prepare external interrupt Line 0 (USER pushbutton)
  @ We'll count the number of times the button is pressed
  @

  @ Initialise count to zero
  LDR   R4, =button_count             @ count = 0;
  MOV   R5, #0                        @
  STR   R5, [R4]                      @

  @ Configure USER pushbutton (GPIO Port A Pin 0 on STM32F3 Discovery
  @   kit) to use the EXTI0 external interrupt signal
  @ Determined by bits 3..0 of the External Interrrupt Control
  @   Register (EXTIICR)
  LDR     R4, =SYSCFG_EXTIICR1
  LDR     R5, [R4]
  BIC     R5, R5, #0b1111
  STR     R5, [R4]

  @ Enable (unmask) interrupts on external interrupt Line0
  LDR     R4, =EXTI_IMR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Set falling edge detection on Line0
  LDR     R4, =EXTI_FTSR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Enable NVIC interrupt #6 (external interrupt Line0)
  LDR     R4, =NVIC_ISER
  MOV     R5, #(1<<6)
  STR     R5, [R4]

  @ Nothing else to do in Main
  @ Idle loop forever (welcome to interrupts!!)
Idle_Loop:
  B     Idle_Loop
  
End_Main:
  POP   {R4-R5,PC}



@
@ SysTick interrupt handler (blink LED LD3)
@
  .type  SysTick_Handler, %function
SysTick_Handler:

  PUSH  {R4-R7, LR}

  LDR   R4, =blink_countdown        @ if (countdown != 0) {
  LDR   R5, [R4]                    @
  CMP   R5, #0                      @
  BEQ   .LelseFire                  @

  SUB   R5, R5, #1                  @   countdown = countdown - 1;
  STR   R5, [R4]                    @

  B     .LendIfDelay                @ }

.LelseFire:                         @ else {

// this is where code is executed every 1 second ---------------------------------------------------------------------
  
  
  LDR R4, =wait_for_x_seconds //if you want two flashes, wait_for_x_seconds = 4
  LDR R5, [R4]

  CMP R5, #0
  BNE .LDontMoveToNextStageInLevelDisplay
  BL  DisplayLevel

.LDontMoveToNextStageInLevelDisplay:

  LDR R4, =wait_for_x_seconds
  LDR R5, [R4]

  SUB R5, R5, #1
  STR R5, [R4]



  LDR     R4, =GPIOE_ODR            @   Invert LED
  LDR     R5, [R4]                  @


  LDR     R6, =current_LED_to_illuminate
  LDR     R7, [R6]
 
  PUSH {R4, R5}
  LDR R4, =stage_in_animation
  LDR R5, [R4]
  
  CMP R5, #5
  BEQ .LIlluminateAllLEDS

  POP {R4, R5}

  MOV     R6, #0b1
  MOV     R7, R6, LSL R7
  EOR     R5, R5, R7
  //STR     R5, [R4]     


  B       .LSetBlinkPeriod

.LIlluminateAllLEDS:
  POP {R4, R5}


  EOR R5, #(0b1<<(LD3_PIN))
  EOR R5, #(0b1<<(LD4_PIN))
  EOR R5, #(0b1<<(LD5_PIN))
  EOR R5, #(0b1<<(LD6_PIN))

  EOR R5, #(0b1<<(LD7_PIN))
  EOR R5, #(0b1<<(LD8_PIN))
  EOR R5, #(0b1<<(LD9_PIN))
  EOR R5, #(0b1<<(LD10_PIN))

  



.LSetBlinkPeriod:
  STR R5, [R4]


  LDR     R4, =blink_countdown      @   countdown = BLINK_PERIOD;

  LDR R6, =stage_in_animation
  LDR R7, [R6]

  CMP R7, #2  //if==2, blue lights are flashing

  BNE .LRestBlink

  LDR R6, =game_blink_period
  LDR R5, [R6]
  STR R5, [R4]
  B   .LendIfDelay

.LRestBlink:
  LDR     R5, =REST_BLINK_PERIOD         @
  STR     R5, [R4]                  @

.LendIfDelay:                       @ }

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  @ Return from interrupt handler
  POP  {R4-R7, PC}



@
@ External interrupt line 0 interrupt handler
@   (count button presses)
@
  .type  EXTI0_IRQHandler, %function
EXTI0_IRQHandler:

  PUSH  {R4,R5,LR}

  LDR R4, =stage_in_animation
  LDR R5, [R4]
  
  // if stage_in_animation==4, orange lights are flashing
//  CMP R5, #4
//  BNE .LDontChangeTimer
//
//  LDR R4, =wait_for_x_seconds
//  LDR R5, =4
//  STR R5, [R4]
//
//.LDontChangeTimer:

  LDR   R4, =button_count           @ count = count + 1
  LDR   R5, [R4]                    @
  ADD   R5, R5, #1                  @
  STR   R5, [R4]                    @

  LDR   R4, =EXTI_PR                @ Clear (acknowledge) the interrupt
  MOV   R5, #(1<<0)                 @
  STR   R5, [R4]                    @

  @ Return from interrupt handler
  POP  {R4,R5,PC}



DisplayLevel:
  PUSH {R4-R7, LR}

  BL FindNumberOfBlinks
  //number of blinks not returned in R0, it is saved at number_of_blinks

  LDR R4, =stage_in_animation
  LDR R5, [R4]
  

  CMP R5, #0
  BEQ .LFlashGreenLights
  CMP R5, #1
  BEQ .LFlashCurrentLevelLights
  CMP R5, #2
  BEQ .LFlashRedLights
  CMP R5, #3
  BEQ .LFlashOrangeLights
  CMP R5, #4
  BEQ .LFlashResultLights
  
  //if not equal to any of the above, it is five and needs to be reset
  MOV R5, #0
  B   .LFlashGreenLights



.LFlashCurrentLevelLights:
  LDR R4, =current_LED_to_illuminate
  LDR R5, =LD9_PIN
  STR R5, [R4]

  LDR R4, =number_of_blinks
  LDR R5, [R4]
  MOV R4, #2
  MUL R5, R5, R4

  B   .LEndDisplaySR

.LFlashOrangeLights:
  LDR R4, =button_count
  MOV R5, #0
  STR R5, [R4]

  //this way, you can't press the button during the blue lights

  LDR R4, =current_LED_to_illuminate
  LDR R5, =LD8_PIN
  STR R5, [R4]

  LDR R5, =8  //on for 1 sec, off for 1 sec, on for 1 sec, off for 1 sec
  B   .LEndDisplaySR

.LFlashRedLights:
  LDR R4, =game_blink_period
  LDR R5, [R4]
  SUB R5, R5, #50
  STR R5, [R4]

  LDR R4, =current_LED_to_illuminate
  LDR R5, =LD10_PIN
  STR R5, [R4]

  LDR R5, =4  //on for 1 sec, off for 1 sec, on for 1 sec, off for 1 sec 
  B   .LEndDisplaySR

.LFlashGreenLights:
  LDR R4, =current_LED_to_illuminate
  LDR R5, =LD6_PIN
  STR R5, [R4]

  LDR R5, =4  //on for 1 sec, off for 1 sec, on for 1 sec, off for 1 sec 
  B   .LEndDisplaySR


.LFlashResultLights:
  LDR R4, =button_count
  LDR R5, [R4]

  LDR R6, =number_of_blinks
  LDR R7, [R6]

  CMP R5, R7
  BNE .LFailure


  LDR R4, =current_LED_to_illuminate
  MOV R5, ALL_PINS
  STR R5, [R4]

  LDR R4, =current_level
  LDR R5, [R4]

  CMP R5, #7     // HOW MANY LEVELS, if #11, 10 levels
  BEQ .LPlayerWins
  ADD R5, R5, #1
  STR R5, [R4]

  LDR R5, =4

  B   .LEndDisplaySR

.LEndDisplaySR:
  LDR R4, =wait_for_x_seconds
  STR R5, [R4]

  LDR R4, =stage_in_animation
  LDR R5, [R4]

  CMP R5, #5
  BGE .LReset
  ADD R5, R5, #1
  STR R5, [R4]

  POP  {R4-R7, PC}


.LReset:
  MOV R5, #1
  STR R5, [R4]

  POP  {R4-R7, PC}






FindNumberOfBlinks:
  PUSH {R4, R5, LR}

  LDR R4, =current_level
  LDR R5, [R4]
//  wont add display failure routine for case 0 here

  CMP R5, #1
  BEQ .LoadLevel1
  CMP R5, #2
  BEQ .LoadLevel2
  CMP R5, #3
  BEQ .LoadLevel3
  CMP R5, #4
  BEQ .LoadLevel4
  CMP R5, #5
  BEQ .LoadLevel1 //level 1 and 5 == 3, likewise for 2 and 8 =4

  CMP R5, #6
  BEQ .LoadLevel6
  CMP R5, #7
  BEQ .LoadLevel7
  CMP R5, #8
  BEQ .LoadLevel2
  CMP R5, #9
  BEQ .LoadLevel9
  CMP R5, #10
  BEQ .LoadLevel10


.LoadLevel1:
  MOV R5, LEVEL1_CORRECT_ANSWER
  B  .LBlinksFound
.LoadLevel2:
  MOV R5, LEVEL2_CORRECT_ANSWER
  B  .LBlinksFound

  .LoadLevel3:
  MOV R5, LEVEL3_CORRECT_ANSWER
  B  .LBlinksFound
.LoadLevel4:
  MOV R5, LEVEL4_CORRECT_ANSWER
  B  .LBlinksFound

.LoadLevel6:
  MOV R5, LEVEL6_CORRECT_ANSWER
  B  .LBlinksFound
.LoadLevel7:
  MOV R5, LEVEL7_CORRECT_ANSWER
  B  .LBlinksFound

.LoadLevel9:
  MOV R5, LEVEL9_CORRECT_ANSWER
  B  .LBlinksFound
.LoadLevel10:
  MOV R5, LEVEL10_CORRECT_ANSWER
  B  .LBlinksFound


.LBlinksFound:
  LDR R4, =number_of_blinks
  STR R5, [R4]
  POP  {R4, R5, PC}


.LFailure:
  LDR R4, =GPIOE_ODR
  LDR R5, =0
  STR R5, [R4]

  ORR R5, #(0b1<<(LD8_PIN))
  ORR R5, #(0b1<<(LD5_PIN))


  EOR R5, #(0b1<<(LD3_PIN))
  EOR R5, #(0b1<<(LD10_PIN))
  STR R5, [R4]

  B .LFinished

.LPlayerWins:
  LDR R4, =GPIOE_ODR
  MOV R5, #0
  STR R5, [R4]


  EOR R5, #(0b1<<(LD6_PIN))
  EOR R5, #(0b1<<(LD7_PIN))
  STR R5, [R4]


.LFinished:
B .LFinished

  .section .data
current_LED_to_illuminate:
  .space  4
advance_to_next_level:
  .space  4
number_of_blinks:
  .space  4
current_level:
  .space   4


wait_for_x_seconds:
  .space  4
stage_in_animation:
  .space  4
button_count:
  .space  4

blink_countdown:
  .space  4
game_blink_period:
  .space  4

  .end