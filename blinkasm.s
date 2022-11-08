@ ---------------------------------------
@	Data Section
@ ---------------------------------------
.data
num:    .int    0
pin:    .int    19      @ pin set bit
.balign 4
.cpu    cortex-a72
.fpu    neon-fp-armv8
.syntax unified         @ modern syntax

prompt:
    .asciz "Enter num: \n"
format:
    .asciz "%d"
opt:
    .asciz "option %d \n"
pin_opt:
    .asciz "pin: %d \n"
here:
    .asciz "-->>\n"
device:
    .asciz  "/dev/gpiomem"

.equ    PIN21,21
.equ    PIN19,19
.equ    PINS_IN_REG,32
.equ    GPSET0,0x1c     @ set register offset
.equ    PIN_FIELD,0b111 @ 3 bits 8
.equ    GPCLR0,0x28     @ clear register offset
.equ    PROT_RDWR,0x3   @PROT_READ(0x1)|PROT_WRITE(0x2)
.equ    BLOCK_SIZE,4096 @ Raspbian memory page
.equ    OUTPUT,1        @ use pin for ouput
.equ    ONE_SEC,1       @ sleep one second
.equ    mem_fd_open,3
.equ    FILE_DESCRP_ARG,0   @ file descriptor
.equ    DEVICE_ARG,3    @ device address
@ The following are defined in /usr/include/asm-generic/mman-common.h:
        .equ    MAP_SHARED,1 @ share changes
@ Constant program data
        .section .rodata

@ ---------------------------------------
@	Code Section
@ ---------------------------------------

	.text
	.global main
	.extern printf
	.extern scanf

main:
    push 	{ip, lr}	@ push return address + dummy register
				        @ for alignment
    bl      rpi_setup
    b       ask_opt

@ program should not reach here due to infinite loop
    pop	{ip, pc}
    bx	lr

rpi_setup:
@ ---------------------------------------
@	raspberry pi set up pins
@ ---------------------------------------


@ Open /dev/gpiomem for read/write and syncing
    ldr     r1, O_RDWR_O_SYNC    @ flags for accessing device
    ldr     r0, mem_fd      @ address of /dev/gpiomem
    bl      open
    mov     r4, r0          @ use r4 for file descriptor
@ Map the GPIO registers to a main memory location so we can access them
    str     r4, [sp, FILE_DESCRP_ARG] @ /dev/gpiomem file descriptor
    mov     r1, BLOCK_SIZE  @ get 1 page of memory
    mov     r2, PROT_RDWR   @ read/write this memory
    mov     r3, MAP_SHARED  @ share with other processes
    mov     r0, mem_fd_open @ address of /dev/gpiomem
    ldr     r0, GPIO_BASE   @ address of GPIO
    str     r0, [sp, DEVICE_ARG]      @ location of GPIO
    bl      mmap

@  -------  SETUP FOR PIN  --------
    mov     r5, r0          @ use r5 for programming memory address
    ldr     r1, =pin       @ pin to blink
    ldr     r1, [r1]
    mov     r2, OUTPUT      @ it's an output


    
@ GPIO Select
    mov     r4, r0          @ save pointer to GPIO
    mov     r11, r1          @ save pin number
    mov     r6, r2          @ save function code

    ldr r1, =pin
@ Compute address of GPFSEL register and pin field
    mov     r3, 10          @ divisor
    udiv    r0, r11, r3      @ GPFSEL number

    mul     r1, r0, r3      @ compute remainder
    sub     r1, r11, r1      @     for GPFSEL pin


@ Set up the GPIO pin funtion register in programming memory
    lsl     r0, r0, 2       @ 4 bytes in a register
    add     r0, r4, r0      @ GPFSELn address
    ldr     r2, [r0]        @ get entire register /// error code
    mov     r3, r1          @ need to multiply pin
    add     r1, r1, r3, lsl 1   @    position by 3
    mov     r3, PIN_FIELD   @ gpio pin field
    lsl     r3, r3, r1      @ shift to pin position
    bic     r2, r2, r3      @ clear pin field
    lsl     r6, r6, r1      @ shift function code to pin position
    orr     r2, r2, r6      @ enter function code
    str     r2, [r0]        @ update register
    mov     r3, PINS_IN_REG @ divisor

ask_opt:
@ Print out the prompt for user to enter
	ldr	r0, =prompt	@ print the prompt
	bl	printf

@ call scanf, and pass address of format string and address of num in r0, and r1,
	ldr r0, =format
	ldr	r1, =num
	bl	scanf
    @ after scanf, r1 is undefined

    ldr r0, =opt @ load option string into r0
    ldr	r1, =num @ load address of num into r1
    ldr r1, [r1] @ load value of r1 address into r1
    @ print the prompt
	bl	printf

    ldr r1, =num            @ load num address into r1
    ldr r1, [r1]            @ load value of r1 into r1

    @  if num is equals to 1
    cmp r1, #1
    bleq set_pin19

    @  if num is equals to 2
    cmp r1, #2
    bleq set_pin21

    ldr r0, =pin_opt
    ldr r1, addr_pin
    ldr r1, [r1]
    bl  printf

@ option branches
    ldr	    r0, =num
    ldr     r0, [r0]

    cmp     r0, #1
	bleq    blink
    cmp     r0, #2
    bleq    blink
    cmp     r0, #3
    bleq    reset

    b       ask_opt

blink:
    mov     r0, r5          @ GPIO programming memory
    ldr     r1, =pin
    ldr     r1, [r1]
    add     r8, r0, GPSET0  @ pointer to GPSET regs.
    mov     r9, r1          @ save pin number        
    udiv    r0, r9, r3      @ GPSET number
    add     r0, r0, r8      @ address of GPSETn

@ Set up the GPIO pin funtion register in programming memory
    ldr     r3, =pin         @ one pin
    ldr     r3, [r3]
    lsl     r3, r3, r1      @ shift to pin position
    orr     r2, r2, r3      @ set bit
    str     r2, [r0]        @ update register
    bx      lr


reset:
    mov     r0, r5
    ldr     r1, =PIN19
    add     r8, r0, GPCLR0  @ pointer to GPSET regs.
    mov     r9, r1          @ save pin number      
    udiv    r0, r9, r3      @ GPSET number
    add     r0, r0, r8      @ address of GPSETn

@ Set up the GPIO pin funtion register in programming memory
    ldr     r3, =PIN19         @ one pin
    lsl     r3, r3, r1      @ shift to pin position
    orr     r2, r2, r3      @ clear bit
    str     r2, [r0]        @ update register

    mov     r0, r5
    ldr     r1, =PIN21
    add     r8, r0, GPCLR0  @ pointer to GPSET regs.
    mov     r9, r1          @ save pin number      
    udiv    r0, r9, r3      @ GPSET number
    add     r0, r0, r8      @ address of GPSETn

@ Set up the GPIO pin funtion register in programming memory
    ldr     r3, =PIN21         @ one pin
    lsl     r3, r3, r1      @ shift to pin position
    orr     r2, r2, r3      @ clear bit
    str     r2, [r0]        @ update register
    bx      lr

set_pin21:
    ldr r2, =PIN21 @ load constant PIN21 (21) into r2
    ldr r10, addr_pin       @ load address pin into r10
    str r2, [r10]           @ store r2 into r10 addr_pin
    bx  lr

set_pin19:
    ldr r2, =PIN19 @ load constant PIN19 (19) into r2
    ldr r10, addr_pin       @ load address pin into r10
    str r2, [r10]           @ store r2 into r10 addr_pin
    bx  lr

@ addresses of messages
GPIO_BASE:
    .word   0x3f200000 @GPIO Base address Raspberry pi 3
mem_fd:
    .word   device
O_RDWR_O_SYNC:
    .word   2|256       @ O_RDWR (2)|O_SYNC (256).
addr_pin:
    .word   pin
