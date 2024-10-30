.data
    message1: .asciiz "Enter player's last name (DONE to end): "
    message2: .asciiz "Enter how many points the player's team has scored while the player is on the court: "
    message3: .asciiz "Enter how many points the opposition team has scored while the player is on the court: "
    newline: .asciiz "\n"
    space: .asciiz " "
    done: .asciiz "DONE\n"
    struct_size: .word 72

.text

main:
    # create stack pointer and save $s registers
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)

    # create space for the node
    li $v0, 9
    lw $a0, struct_size
    syscall
    move $s0, $v0 # store the memory address
    move $s4, $v0 # save the head

_loop:
    # print the first message
    li $v0, 4
    la $a0, message1
    syscall

    # read the player's name
    li $v0, 8
    la $a0, ($s0)
    li $a1, 64
    syscall

    # int compare = strcmp("DONE", name);
    la $a0, done
    la $a1, 0($s0)
    jal strcmp
    beqz $v0, _leave_loop
    
    # print the second message
    li $v0, 4
    la $a0, message2
    syscall

    # read the player's plus
    li $v0, 5
    syscall
    move $s1, $v0

    # print the third message
    li $v0, 4
    la $a0, message3
    syscall

    # read the player's minus
    li $v0, 5
    syscall
    move $s2, $v0

    # plusminus = plus - minus;
    sub $s3, $s1, $s2 # calculate plusminus
    sw $s3, 64($s0) # save plusminus

    # create a new node for the next player
    li $v0, 9
    lw $a0, struct_size
    syscall
    sw $v0, 68($s0)
    move $s0, $v0 # store the memory address

    j _loop               

_leave_loop:
    # call the sorting function
    la $a0, ($s4)
    jal sortlist
    move $s4, $v0

    # time to call print the sorted list
    la $a0, ($s4)
    jal print_list

sortlist:
    move $t0, $a0 # get the head pointer
    li $t4, 0 # int sorted = 0;

_outer_loop: # while (!sorted)
    move $t1, $t0 # current = *head
    li $t2, 0 # previous = NULL
    li $t4, 1 # sorted = 1;

_inner_loop: # while (current != NULL && current->next != NULL)
    lw $t3, 68($t1) # next = current->next;
    beqz $t1, _end_sort
    beqz $t3, _outer_loop_check

    # get the plusminus for current and next nodes
    lw $t5, 64($t1)
    lw $t6, 64($t3)

    #if (current->plusminus < next->plusminus) go to swap nodes
    blt $t5, $t6, _swap_nodes

    # if (current->plusminus == next->plusminus) go to check strcmp
    # beq $t5, $t6, _check_strcmp

    # jump to else statement if the if statements are not trigger
    j _else_statement

_swap_nodes:
    li $t4, 0 # sorted = 0

    # if (previous != NULL) previous->next = next;
    # else *head = next
    beqz $t2, _change_head
    sw $t3, 68($t2)
    j _change_next

_change_head:
    move $t0, $t3

_change_next:
    lw $t7, 68($t3) # store next->next
    sw $t1, 68($t3) #current->next = next->next;
    sw $t7, 68($t1) #next->next = current;
    move $t1, $t3 # current = next;
    j _inner_loop

# _check_strcmp:
    # load the name of the current and next node and put in the $a registers
    # la $a0, 0($t1)
    # la $a1, 0($t3)
    # jal strcmp

    # if strcmp(current->name, next->name) > 0)
    # bgtz $v0, _swap_nodes

    # j _else_statement

_else_statement:
    move $t2, $t1 # previous = current;
    move $t1, $t3 # current = next;

    # jump to the inner loop
    j _inner_loop

_outer_loop_check:
    beqz $t4, _outer_loop
    j _end_sort

_end_sort:
    move $v0, $t0 # get the head of the sorted linked list
    jr $ra

_end_print:
    # exit the program
    lw $s4, 20($sp)
    lw $s3, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 32
    jr $ra

print_list:
    move $t3, $a0 # Get the head of the linked list

_loop_print:
    la $a0, done
    la $a1, 0($t3)
    jal strcmp
    beqz $v0, _next_node

    # relace newline with null
    la $a0, 0($t3)
    jal replace_newline

    # Load the player's name
    li $v0, 4
    la $a0, 0($t3)
    syscall

    # Print space
    li $v0, 4
    la $a0, space
    syscall

    # Print plusminus
    li $v0, 1
    lw $a0, 64($t3)
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

_next_node:
    # Move to the next node
    lw $t3, 68($t3)

    # check if the current node is NULL or is the "DONE" node
    beqz $t3, _end_print

    j _loop_print

# replace the /n to null
replace_newline:
    move $t0, $a0
    li $t1, 0xa # the newline character

_replace_loop:
    lb $t2, 0($t0) # get the character from $t0
    beq $t2, $t1, _newline_found # found the newline so replace it
    bnez $t2, _newline_continue # we still in the middle of the word
    j _newline_done

_newline_continue:
    addi $t0, $t0, 1 # move to the next character
    j _replace_loop

_newline_found:
    sb $zero, 0($t0) # change the newline to null character
    j _newline_done

_newline_done:
    jr $ra

# strcmp function
strcmp:
    lb $t0, 0($a0)
    lb $t1, 0($a1)

strcmp_loop:
    bne $t0, $t1, strcmp_done
    beqz $t0, strcmp_done

    addi $a0, $a0, 1
    addi $a1, $a1, 1

    lb $t0, 0($a0)
    lb $t1, 0($a1)
    j strcmp_loop

strcmp_done:
    sub $v0, $t0, $t1
    jr $ra
