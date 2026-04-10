#---------------------------------------------------------
# Floating-Point Calculator Program
# Programming Assignment #2
# - Asks user for 2 real numbers
# - Uses 5 functions: sum, difference, product, quotient, remainder
# - Each function:
#     * Takes 2 floating-point parameters via the stack
#     * Returns a floating-point result in $f0
# - Prints result after each calculation
# - Handles division by zero for quotient and remainder
#---------------------------------------------------------

.data
welcomeMsg:     .asciiz "Welcome to the Floating-Point Calculator\n"
prompt1:        .asciiz "Enter the first real number: "
prompt2:        .asciiz "Enter the second real number: "
sumLabel:       .asciiz "Sum = "
diffLabel:      .asciiz "Difference = "
prodLabel:      .asciiz "Product = "
quotLabel:      .asciiz "Quotient = "
remLabel:       .asciiz "Remainder = "
errDivZeroQ:    .asciiz "ERROR - division by zero (quotient)\n"
errDivZeroR:    .asciiz "ERROR - division by zero (remainder)\n"
doneMsg:        .asciiz "All calculations complete.\n"
newline:        .asciiz "\n"

.text
.globl main

#---------------------------------------------------------
# main
#---------------------------------------------------------
main:
    # Display welcome message
    li      $v0, 4
    la      $a0, welcomeMsg
    syscall

    # Prompt for first real number
    li      $v0, 4
    la      $a0, prompt1
    syscall

    # Read float (syscall 6) -> $f0
    li      $v0, 6
    syscall
    mov.s   $f2, $f0          # operand1 in $f2

    # Prompt for second real number
    li      $v0, 4
    la      $a0, prompt2
    syscall

    # Read float (syscall 6) -> $f0
    li      $v0, 6
    syscall
    mov.s   $f4, $f0          # operand2 in $f4

    #-----------------------------------------------------
    # Call sum(operand1, operand2)
    #-----------------------------------------------------
    addi    $sp, $sp, -8      # make space for 2 floats
    s.s     $f2, 0($sp)       # push operand1
    s.s     $f4, 4($sp)       # push operand2
    jal     sum
    addi    $sp, $sp, 8       # pop parameters

    # Result in $f0
    # Print "Sum = " and result
    li      $v0, 4
    la      $a0, sumLabel
    syscall

    mov.s   $f12, $f0
    li      $v0, 2
    syscall

    # Newline
    li      $v0, 4
    la      $a0, newline
    syscall

    #-----------------------------------------------------
    # Call difference(operand1, operand2)
    #-----------------------------------------------------
    addi    $sp, $sp, -8
    s.s     $f2, 0($sp)
    s.s     $f4, 4($sp)
    jal     difference
    addi    $sp, $sp, 8

    # Print "Difference = " and result
    li      $v0, 4
    la      $a0, diffLabel
    syscall

    mov.s   $f12, $f0
    li      $v0, 2
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    #-----------------------------------------------------
    # Call product(operand1, operand2)
    #-----------------------------------------------------
    addi    $sp, $sp, -8
    s.s     $f2, 0($sp)
    s.s     $f4, 4($sp)
    jal     product
    addi    $sp, $sp, 8

    # Print "Product = " and result
    li      $v0, 4
    la      $a0, prodLabel
    syscall

    mov.s   $f12, $f0
    li      $v0, 2
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    #-----------------------------------------------------
    # Quotient: check division by zero
    #-----------------------------------------------------
    li      $t0, 0            # load 0 as int
    mtc1    $t0, $f6          # move to $f6
    cvt.s.w $f6, $f6          # convert to 0.0
    c.eq.s  $f4, $f6
    bc1t    quotient_div_zero

    addi    $sp, $sp, -8
    s.s     $f2, 0($sp)
    s.s     $f4, 4($sp)
    jal     quotient
    addi    $sp, $sp, 8

    li      $v0, 4
    la      $a0, quotLabel
    syscall

    mov.s   $f12, $f0
    li      $v0, 2
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    j       after_quotient

quotient_div_zero:
    li      $v0, 4
    la      $a0, errDivZeroQ
    syscall

after_quotient:

    #-----------------------------------------------------
    # Remainder: check division by zero
    #-----------------------------------------------------
    li      $t0, 0            # load 0 as int
    mtc1    $t0, $f6          # move to $f6
    cvt.s.w $f6, $f6          # convert to 0.0
    c.eq.s  $f4, $f6
    bc1t    remainder_div_zero

    addi    $sp, $sp, -8
    s.s     $f2, 0($sp)
    s.s     $f4, 4($sp)
    jal     remainder
    addi    $sp, $sp, 8

    li      $v0, 4
    la      $a0, remLabel
    syscall

    mov.s   $f12, $f0
    li      $v0, 2
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    j       after_remainder

remainder_div_zero:
    li      $v0, 4
    la      $a0, errDivZeroR
    syscall

after_remainder:

    li      $v0, 4
    la      $a0, doneMsg
    syscall

    li      $v0, 10
    syscall


#---------------------------------------------------------
# sum
#---------------------------------------------------------
sum:
    lwc1    $f12, 0($sp)
    lwc1    $f14, 4($sp)
    add.s   $f0, $f12, $f14
    jr      $ra

#---------------------------------------------------------
# difference
#---------------------------------------------------------
difference:
    lwc1    $f12, 0($sp)
    lwc1    $f14, 4($sp)
    sub.s   $f0, $f12, $f14
    jr      $ra

#---------------------------------------------------------
# product
#---------------------------------------------------------
product:
    lwc1    $f12, 0($sp)
    lwc1    $f14, 4($sp)
    mul.s   $f0, $f12, $f14
    jr      $ra

#---------------------------------------------------------
# quotient
#---------------------------------------------------------
quotient:
    lwc1    $f12, 0($sp)
    lwc1    $f14, 4($sp)
    div.s   $f0, $f12, $f14
    jr      $ra

#---------------------------------------------------------
# remainder
#---------------------------------------------------------
remainder:
    lwc1    $f12, 0($sp)
    lwc1    $f14, 4($sp)

    div.s     $f6, $f12, $f14
    trunc.w.s $f8, $f6
    mfc1      $t0, $f8
    mtc1      $t0, $f8
    cvt.s.w   $f8, $f8

    mul.s   $f10, $f14, $f8
    sub.s   $f0, $f12, $f10

    jr      $ra
