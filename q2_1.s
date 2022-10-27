
.data

input: .asciz "%s"

output: .asciz "Output: %s\n"
prompt: .asciz "Input: "

.equ    add_mem, 0x21027

.text
.global main
main:

        ldr r0, =prompt     // loading address of prompt message in r0
        bl printf           // calling printf to print prompt

        ldr r0, =input     // loading first parameter of scanf
        ldr r1, =add_mem   // store the address 0x21027 into r1
        bl scanf
        // below print out the user input from scanf
        ldr r1, =add_mem    // load data from storage
        ldr r0, =output        // printf to print format
        bl printf

        mov r0, #0             // return code/graceful exit
        mov r7, #1
        swi 0
