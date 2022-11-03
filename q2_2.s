.data // data section
num: .int 0 // set num bits
pin: .int 17 // set pin bits
.balign 4 // ensure 4-byte alignment of address
.cpu cortex-a72 // 3-way decode out-of-order superscalar pipeline
.fpu neon-fp-armv8 // neon instructions
.syntax unified // signals use of unified ARM

prompt: .asciz "Enter num: \n" // prompt constant
input: .asciz "%d" // input constant
opt: .asciz "option %d \n" // opt constant
pin_opt: .asciz "pin: %d \n" // pin_opt constant
here: .asciz ">>\n" // here constant
device: .asciz  "/dev/gpiomem" // device constant/filepath

.equ    PIN18,18 // set pin 18
.equ    PIN17,17 // set pin 17
.equ    PINS_IN_REG,32
.equ    GPSET0,0x1c // set register offset
.equ    PIN_FIELD,0b111 // PIN_FIELD equals 3 bits
.equ    GPCLR0,0x28 // clear register offset
.equ    PROT_RDWR,0x3 //PROT_READ(0x1)|PROT_WRITE(0x2)
.equ    BLOCK_SIZE,4096 // memory page
.equ    OUTPUT,1 // use pin for ouput
.equ    ONE_SEC,1 // sleep one second
.equ    mem_fd_open,3 // file descriptor
.equ    FILE_DESCRP_ARG,0 // file descriptor
.equ    DEVICE_ARG,3 // device address
// defined in /usr/include/asm-generic/mman-common.h:
.equ    MAP_SHARED,1 // share changes
.section .rodata // constant program data
.text
.global main
.extern printf
.extern scanf

main: // main function/label

    push {ip, lr} // push return address and dummy register
	
    bl rpi_setup // call rpi_setup
    b ask_opt // call ask_opt

    pop	{ip, pc} // pop return address and dummy register
    bx lr // end main

rpi_setup: // set up raspberry pins function/label

// open /dev/gpiomem for read/write and syncing
    ldr r1, O_RDWR_O_SYNC // flags for accessing device
    ldr r0, mem_fd // address of /dev/gpiomem
    bl open
    mov r4, r0 // use r4 for file descripton
	
// Map the GPIO registers to a main memory location so we can access them
    str r4, [sp, FILE_DESCRP_ARG] // /dev/gpiomem file descriptor
    mov r1, BLOCK_SIZE // get 1 page of memory
    mov r2, PROT_RDWR // read/write this memory
    mov r3, MAP_SHARED // share with other processes
    mov r0, mem_fd_open // address of /dev/gpiomem
    ldr r0, gpio_base // address of GPIO
    str r0, [sp, DEVICE_ARG] // location of GPIO
    bl mmap // map into memory

//  setup pin
    mov r5, r0 // use r5 for programming memory address
    ldr r1, =pin // pin to blink
    ldr r1, [r1] // load value of r1 into r1
    mov r2, OUTPUT // output

// select GPIO
    mov r4, r0 // save pointer to GPIO
    mov r11, r1 // save pin number
    mov r6, r2 // save function code
    ldr r1, =pin
	
// Compute address of GPFSEL register and pin field
    mov r3, 10 // divisor
    udiv r0, r11, r3 // GPFSEL number
    mul r1, r0, r3 // compute remainder
    sub r1, r11, r1 // for GPFSEL pin

// Set up the GPIO pin funtion register in programming memory
    lsl r0, r0, 2 // 4 bytes in a register
    add r0, r4, r0 // GPFSELn address
    ldr r2, [r0] // get entire register /// error code
    mov r3, r1 // need to multiply pin
    add r1, r1, r3, lsl 1 // position by 3
    mov r3, PIN_FIELD // gpio pin field
    lsl r3, r3, r1 // move to pin position
    bic r2, r2, r3 // clear pin field
    lsl r6, r6, r1 // shift function code to pin position
    orr r2, r2, r6 // enter function code
    str r2, [r0] // update register
    mov r3, PINS_IN_REG // divisor

ask_opt: // ask user for input

    ldr	r0, =prompt	// load prompt address into r0
    bl	printf // print prompt
	
    ldr r0, =input // load input address into r0
    ldr	r1, =num // load num address r1
    bl	scanf // scanf input
    ldr r0, =opt // load option string into r0
    ldr	r1, =num // load address of num into r1
    ldr r1, [r1] // load value of r1 address into r1
    bl printf // print prompt
    ldr r1, =num // load num address into r1
    ldr r1, [r1] // load value of r1 into r1

    cmp r1, #1 // if user input 1
    bleq set_pin17 // set pin to 17 

    cmp r1, #2 // if user input 2
    bleq set_pin18 // set pin to 18

    ldr r0, =pin_opt // load pin_opt address into r0
    ldr r1, =pin // load pin address into r1 
    ldr r1, [r1] // load r1 value into r1
    bl printf // print pin_opt

// option branches
    ldr	r0, =num // load num address into r0
    ldr r0, [r0] // load r0 value into r0

    cmp r0, #1 // if r0 value is 1
	bleq blink // call blink pin 17 (green)
    cmp r0, #2 // if r0 value is 2
    bleq blink // call blink pin 18(red)
    cmp r0, #3 // if r0 value is 3
    bleq reset // off both lights

    b ask_opt // call ask_opt

blink: // on light function/label

    mov r0, r5 // GPIO programming memory
    ldr r1, =pin // load pin address into r1
    ldr r1, [r1] // load value of r1 into r1
    add r8, r0, GPSET0 // pointer to GPSET regs
    mov r9, r1 // save pin number        
    udiv r0, r9, r3 // GPSET number
    add r0, r0, r8 // address of GPSET

// Set up the GPIO pin funtion register in programming memory
    ldr r3, =pin // load pin address to r3
    ldr r3, [r3] // load value of r3 into r3
    lsl r3, r3, r1 / shift to pin position
    orr r2, r2, r3 // set bit
    str r2, [r0] // update register
    bx lr // end blink label/function


reset: // off both lights function/label

    mov r0, r5 // GPIO programming memory
    ldr r1, =PIN17 // load pin 17 to r1
    add r8, r0, GPCLR0 // pointer to GPSET regs.
    mov r9, r1 // save pin number      
    udiv r0, r9, r3 // GPSET number
    add r0, r0, r8 // address of GPSETn

// Set up the GPIO pin funtion register in programming memory
    ldr r3, =PIN17 // one pin
    lsl r3, r3, r1 // shift to pin position
    orr r2, r2, r3 // clear bit
    str r2, [r0] // update register

    mov r0, r5 // GPIO programming memory
    ldr r1, =PIN18 // load pin 18 to r1
    add r8, r0, GPCLR0 // pointer to GPSET regs.
    mov r9, r1 // save pin number      
    udiv r0, r9, r3 // GPSET number
    add r0, r0, r8 // address of GPSETn

// Set up the GPIO pin funtion register in programming memory
    ldr r3, =PIN18 // one pin
    lsl r3, r3, r1 // shift to pin position
    orr r2, r2, r3 // clear bit
    str r2, [r0] // update register
    bx lr // end of label

set_pin18: // set_pin18 label/function
    ldr r2, =PIN18 // load constant PIN18 into r2
    ldr r10, =pin // load =pin into r10
    str r2, [r10] // store r2 into r10 =pin
    bx  lr // end of label

set_pin17: // set_pin17 label/function
    ldr r2, =PIN17 // load constant PIN17 into r2
    ldr r10, =pin // load address pin into r10
    str r2, [r10] // store r2 into r10 =pin
    bx  lr // end of label

// addresses of constants/messages
gpio_base: .word 0x3f200000 // GPIO base address
mem_fd: .word device // device address
O_RDWR_O_SYNC: .word 2|256 // open for read and write, syncing
// =pin: .word pin // pin address
	
