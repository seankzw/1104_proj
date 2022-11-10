COA group assignment Question 2 Part 2
.data
.balign 4				@alignment of the instruction of data
prompt: .asciz "Please enter a mode:\n" @for printf calls,by GNU assembler's ".asciz";
redpin: .int 0				@set 
greenpin: .int 1			@
input: .asciz "%d"
option: .asciz "option %d \n"
num: .int 0 @number variable

.text
.global main
.extern printf
.extern wiringPiSetup
.extern delay
.extern digitalWrite
.extern pinMode

main:
	bl wiringPiSetup @ initializes wiringPi
	ldr r0, =redpin @ load redpin address into r0
	ldr r0, [r0] @ load r0 value into r0
	mov r1, #1 @ move value 1 into r1
	bl pinMode @ initializes redpin
	ldr r0, =greenpin @ load greenpin address into r0
	ldr r0, [r0] @ load r0 value into r0
	mov r1, #1 @ move value 1 into r1
	bl pinMode @ initilizes greenpin
	ldr r0, =prompt @ load prompt address into r0
	bl printf @ call printf to print value of prompt
 	ldr r0, =input @load input address into r0
   	ldr r1, =num @load num address r1
   	bl scanf @scanf input
	ldr r0, =option	@load option string into r0
	ldr r1, =num @load address of num into r1
  	ldr r1, [r1] @load value of r1 address into r1
   	bl printf @print prompt
   	ldr r1, =num @load num address into r1
   	ldr r1, [r1] @load value of r1 into r1
	cmp r1, #1 @if user input 1
	bleq greenLed @set green led
	cmp r1, #2 @if user input 2
	bleq redLed	@set red led
	cmp r1, #3 @if user input 2
	bleq ledOff	@set red led

greenLed:
	ldr r0, =greenpin
	ldr r0, [r0]
	mov r1, #1
	bl digitalWrite
	b main

redLed:
	ldr r0,=redpin
	ldr r0,[r0]
	mov r1, #1
	bl digitalWrite
	b main

ledOff:
	ldr r0,=greenpin
   	ldr r0,[r0]
	mov r1, #0
	bl digitalWrite
	ldr r0,=redpin
	ldr r0,[r0]
   	mov r1, #0
   	bl digitalWrite
   	b main

