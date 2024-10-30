.data
    newline: .asciiz "\n"
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
    move $t0, $v0 # save the input (length)
    
    li $t1, 1 # int prev_three = 1;
    li $t2, 1 # int prev_two = 1;
    li $t3, 1 # int prev_one = 1;
    li $t4, 0 # inialize i=0
    li $t5, 2
    li $t6, 3
    li $t7, 0 #int temp_one;
    li $t8, 0 # int temp_two;


_for_loop:
    bge $t4, $t0, _exit_main # for (int i = 0; i < length; i++)

    blt $t4, $t5, _if_statement1 # if (i < 2)
    beq $t4, $t5, _if_statement2 # if (i == 2)
    bgt $t4, $t6, _if_statement3 # if (i > 3)
    beq $t4, $t6, _if_statement4 # if (i == 3)

    j _for_loop # jump back to the loop


_if_statement1:
    # Print the number
    li $v0, 1
    move $a0, $t3
    syscall
    
    # print the new line
    li $v0, 4
    la $a0, newline
    syscall

    addi $t4, $t4, 1 # Increment $t4 (i++)
    j _for_loop #continue;


_if_statement2:
    #prev_one += prev_two;
    add $t3, $t3, $t2

    # Print the number
    li $v0, 1
    move $a0, $t3
    syscall
    
    # print the new line
    li $v0, 4
    la $a0, newline
    syscall

    addi $t4, $t4, 1 # Increment $t4 (i++)
    j _for_loop #continue;


_if_statement3:
    move $t7, $t3 # temp_one =  prev_one;

    # prev_one = prev_one + prev_two + prev_three;
    add $t3, $t3, $t2
    add $t3, $t3, $t1

    move $t8, $t2 # temp_two = prev_two;
    move $t2, $t7 # prev_two = temp_one;
    move $t1, $t8 # prev_three = temp_two;

    # Print the number
    li $v0, 1
    move $a0, $t3
    syscall
    
    # print the new line
    li $v0, 4
    la $a0, newline
    syscall

    addi $t4, $t4, 1 # Increment $t4 (i++)
    j _for_loop #continue;


_if_statement4:
    move $t7, $t3 # temp_one =  prev_one;

    # prev_one = prev_one + prev_two + prev_three;
    add $t3, $t3, $t2
    add $t3, $t3, $t1

    # prev_two += prev_three;
    add $t2, $t2, $t1

    # Print the number
    li $v0, 1
    move $a0, $t3
    syscall
    
    # print the new line
    li $v0, 4
    la $a0, newline
    syscall

    addi $t4, $t4, 1 # Increment $t4 (i++)
    j _for_loop #continue;


_exit_main:
    # Restore registers from the stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # Return
    jr $ra