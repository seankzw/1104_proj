
@; labs9_example1.s
@; This is Data section
.data

.balign 4       @; Ensure variable is 4-byte aligned 
variable1:      @; Define stored value of variable1 
    .word 1     @; initial value

.balign 4       @; Ensure variable is 4-byte aligned
variable2:      @; Define stored value of variable2
    .word 2     @; initial value

@; This is Code section 
.text
.balign 4       @; Ensure function section starts 4 byte aligned
.global main    @; entry of the program

main:
    LDR R1, addr_of_var1    @; R1 ? &variable1. Load address into R1
    MOV R3, #10             @; R3 ? 10; assign the value to R3
    STR R3, [R1]            @; *R1 ? R3. store R3 value into var address in R1   
    LDR R2, addr_of_var2    @; R2 ? &variable2. Load address into R2
    MOV R4, #15             @; R4 ? 15; assign the value to R3
    STR R4, [R2]            @; *R2 ? R3. store R4 value into var address in R2

    @; Same instructions as above
    LDR R1, addr_of_var1    @; R1 ? &variable1. Load address into R1
    LDR R1, [R1]            @; R1 ? *R1. Load the value at address in R1
    LDR R2, addr_of_var2    @; R2 ? &variable2. Load address into R2
    LDR R2, [R2]            @; R2 ? *R2. Load the value at address in R2
    ADD R0, R1, R2          @; R0 ? R1 + R2
    BX LR                   @; end program; return to previous instruction; LR: Link Reg.

@; Labels (or address) needed to access data
addr_of_var1 : .word variable1   @; add_of_var1 is address of variable1
addr_of_var2 : .word variable2   @; add_of_var2 is address of variable2
