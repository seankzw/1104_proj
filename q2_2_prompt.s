.section .text

.global main

@; R0 = buffer to write to
@; R1 = Number of bytes to read
read_user_input:
    push {lr}
    push {r4-r11}
    push {r1}
    push {r0}

    mov r7, #0x3
    mov r0, #0x0
    pop {r1}
    pop {r2}
    svc 0x0

    pop {r4-r11}
    pop {pc}

main:
    @; Read user input
    ldr r0, =mode_opt
    ldr r1, =#0x4
    bl read_user_input

    @; Convert input to number

    @; display


    @; Invoke exit
    mov r7, #0x1
    mov r0, #13
    svc 0x0

.section .data

@; Variables
mode_opt:
    .skip 4 @; 4 bytes