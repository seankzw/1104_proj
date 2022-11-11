COA group assignment Question 2 Part 2
.data @ data segment
.balign 4 @ alignment of the instruction of data
prompt: .asciz "Please enter a mode:\n" @for printf calls,by GNU assembler's ".asciz";
redpin: .int 0 @ set redpin value to 0, for wiringPi pin 0 = GPIO 17
greenpin: .int 1 @ set greenpin value to 1, for wiringPi pin 1 = GPIO 18
input: .asciz "%d" @ input constant
option: .asciz "option %d \n" @ option constant
num: .int 0 @number variable

.text @ text segment
.global main @ start assembly code
.extern printf @ import printf
.extern wiringPiSetup @ import wiringPi
.extern delay @ import delay
.extern digitalWrite @ import digitalWrite
.extern pinMode @ import pinMode

main: @ main function/instruction
	bl wiringPiSetup @ initializes wiringPi
	ldr r0, =redpin @ load redpin address into r0
	ldr r0, [r0] @ load r0 value into r0
	mov r1, #1 @ move value 1 into r1
	bl pinMode @ initializes redpin pinMode(redpin, OUTPUT)
	ldr r0, =greenpin @ load greenpin address into r0
	ldr r0, [r0] @ load r0 value into r0
	mov r1, #1 @ move value 1 into r1
	bl pinMode @ initilizes greenpin pinMode(greenpin, OUTPUT)
	ldr r0, =prompt @ load prompt address into r0
	bl printf @ call printf to print value of prompt
 	ldr r0, =input @ load input address into r0
   	ldr r1, =num @ load num address r1
   	bl scanf @ scanf input
	ldr r0, =option	@ load option string into r0
	ldr r1, =num @ load address of num into r1
  	ldr r1, [r1] @ load value of r1 address into r1
   	bl printf @print prompt
   	ldr r1, =num @ load num address into r1
   	ldr r1, [r1] @ load value of r1 into r1
	cmp r1, #1 @ if user input 1
	bleq greenLed @ set green led
	cmp r1, #2 @ if user input 2
	bleq redLed	@ set red led
	cmp r1, #3 @ if user input 2
	bleq ledOff	@ set red led

greenLed: @ greenLed function/instruction
	ldr r0, =greenpin @ load greenpin address into r0
	ldr r0, [r0] @ load r0 value into r0
	mov r1, #1 @ move value 1 into r1
	bl digitalWrite @ turn on green light, digitalWrite(greenpin, 1)
	b main @ call main

redLed: @ redLed function/instruction
	ldr r0,=redpin @ load redpin address into r0
	ldr r0,[r0] @ load r0 value into r0
	mov r1, #1 @ move value 1 into r1
	bl digitalWrite @ turn on red light, digitalWrite(redpin, 1)
	b main @ call main

ledOff: @ ledOff function/instruction
	ldr r0,=greenpin @ load greenpin address into r0
   	ldr r0,[r0] @ load r0 value into r0
	mov r1, #0 @ move value 0 into r1
	bl digitalWrite @ turn off green light, digitalWrite(greenpin, 0)
	ldr r0,=redpin @ load redpin address into r0
	ldr r0,[r0] @ load r0 value into r0
   	mov r1, #0 @ move value 0 into r1
   	bl digitalWrite @ turn off red light, digitalWrite(redpin, 0)
   	b main @ call main

