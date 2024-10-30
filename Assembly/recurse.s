.data
    message: .asciiz "Enter an integer: "

.text

main:
    # Save callee saved registers on the stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # print the message
    li $v0, 4
    la $a0, message
    syscall

    li $v0, 5 # take the user input
    syscall
    move $a0, $v0 # save the input as the argument for the recursion

    jal recursion

    # Printing the result
    move $a0, $v0
    li $v0, 1
    syscall

    # Puts the stack back to normal
    lw $ra 0($sp)
    addi $sp, $sp, 4

    # EXIT
    jr $ra

recursion:
    # Sets up stack
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    beqz $a0, _base_case # go to the base case (if (n == 0))
    
    # Save n and call recursion (n - 1)
    move $t0, $a0 # Save n
    addi $t0, $t0, -1
    move $a0, $t0 # argument for the recursion
    sw $t0, 8($sp)
    jal recursion # call the recursion
    
    lw $t0, 8($sp)
    move $s0, $v0
    addi $t0, $t0, 1 # to get n again
    
    # 3 * n - 2 * recursion(n - 1) + 7
    mul $t0, $t0, 3
    mul $s0, $s0, 2 
    sub $v0, $t0, $s0 
    addi $v0, $v0, 7 
    j _end_recursion


_base_case:
    # Returns 2
    li $v0, 2

_end_recursion:
    # Clean up
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra