
.data

input: .asciz "%s"                // define input

output: .asciz "Output: %s\n"     // define output
prompt: .asciz "Input: "          // define prompt

.equ    add_mem, 0x21027          // sets add_mem equals address 0x21027

.text
.global main
main:

        ldr r0, =prompt     // loading address of prompt message in r0
        bl printf           // calling printf to print prompt

        ldr r0, =input      // load input into r0
        ldr r1, =add_mem    // store the address 0x21027 into r1
        bl scanf            // scanf to store input value into add_mem

        ldr r1, =add_mem    // load the address 0x21027 into r1
        ldr r0, =output     // load output to r0
        bl printf           // printf to print output

        mov r0, #0          //
        mov r7, #1          //
        swi 0               // return code
