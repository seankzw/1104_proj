.data

input: .asciz "%s"

output: .asciz "Output: %s\n"
prompt: .asciz "Input: "

storage: .space 4         // added 4 byte buffer to store input data

.text
.global main
main:

        ldr r0, add_prompt     // loading address of prompt message in r0
        bl printf              // calling printf to print prompt

        ldr r0, add_input     // loading first parameter of scanf
        ldr r1, add_storage    // location to write data from format
//      str r1, [r2]
        bl scanf     
    // below print out the user input from scanf
        ldr r1, add_storage    // load data from storage
//      ldr r1, [r2]
        ldr r0, add_output        // printf to print format
        bl printf

        mov r0, #0             // return code/graceful exit
        mov r7, #1
        swi 0

add_prompt: .word prompt // address of prompt
add_input: .word input // address of format
add_output: .word output // address of string
add_storage: .word storage // address of buffer

// as -o print.o print.s
// gcc -o print print.o
// ./print; echo$?
