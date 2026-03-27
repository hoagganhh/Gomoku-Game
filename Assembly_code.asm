.data
newline:     .asciiz "\n"
prompt1:     .asciiz "Player 1 (X), please input your coordinates (x,y): "
prompt2:     .asciiz "Player 2 (O), please input your coordinates (x,y): "
invalidMsg:  .asciiz "Invalid input! Please re-enter.\n"
msgWin1:     .asciiz "Player 1 wins - Player 2 loses\n"
msgWin2:     .asciiz "Player 2 wins - Player 1 loses\n"
msgTie:      .asciiz "Tie\n"
fileName:    .asciiz "result.txt"
spaceChar:   .asciiz " "
commaChar:   .asciiz ","
buffer:      .space 20
tempX:       .space 8
tempY:       .space 8

.text
main:
    li $a0, 225           # 15x15 board
    li $v0, 9
    syscall
    move $s0, $v0         # $s0 = board base address
    
    # Initialize board with '.'
    li $t0, 0
    li $t1, 225
    li $t2, 46            # ASCII '.'
init_loop:
    sb $t2, 0($s0)
    addi $s0, $s0, 1
    addi $t0, $t0, 1
    blt $t0, $t1, init_loop
    sub $s0, $s0, 225     # reset pointer
    
    li $s3, 0             # move count
    li $s4, 1             # current player (1 = X, 2 = O)

game_loop:
    move $a0, $s0
    jal print_board
    
    beq $s4, 1, p1
    la $a0, prompt2
    li $v0, 4
    syscall
    j input_turn
p1:
    la $a0, prompt1
    li $v0, 4
    syscall
    
input_turn:
    # Read input string
    la $a0, buffer
    li $a1, 20            # Increased buffer size
    li $v0, 8
    syscall
    
    # Extract X coordinate
    la $t5, buffer        # t5 = input buffer pointer
    la $t6, tempX         # t6 = x coordinate buffer
    li $t7, 0             # t7 = digit count for x
    
extract_x:
    lb $t8, 0($t5)        # Read character
    beq $t8, 44, x_done   # Check for comma
    beq $t8, 10, invalid  # Check for newline (invalid input)
    beq $t8, 0, invalid   # Check for null (invalid input)
    
    # Check if digit
    blt $t8, 48, invalid  # < '0'
    bgt $t8, 57, invalid  # > '9'
    
    # Store digit and advance
    sb $t8, 0($t6)
    addi $t5, $t5, 1
    addi $t6, $t6, 1
    addi $t7, $t7, 1
    bgt $t7, 2, invalid   # Too many digits for x
    j extract_x
    
x_done:
    beq $t7, 0, invalid   # No digits for x
    sb $zero, 0($t6)      # Null terminate x string
    
    # Move past comma
    addi $t5, $t5, 1
    
    # Extract Y coordinate
    la $t6, tempY         # t6 = y coordinate buffer
    li $t7, 0             # t7 = digit count for y
    
extract_y:
    lb $t8, 0($t5)        # Read character
    beq $t8, 10, y_done   # Check for newline
    beq $t8, 0, y_done    # Check for null
    
    # Check if digit
    blt $t8, 48, invalid  # < '0'
    bgt $t8, 57, invalid  # > '9'
    
    # Store digit and advance
    sb $t8, 0($t6)
    addi $t5, $t5, 1
    addi $t6, $t6, 1
    addi $t7, $t7, 1
    bgt $t7, 2, invalid   # Too many digits for y
    j extract_y
    
y_done:
    beq $t7, 0, invalid   # No digits for y
    sb $zero, 0($t6)      # Null terminate y string
    
    # Convert x string to integer
    la $t5, tempX
    li $t6, 0             # t6 = x value
    
convert_x:
    lb $t8, 0($t5)
    beq $t8, 0, x_converted
    subi $t8, $t8, 48     # Convert ASCII to decimal
    mul $t6, $t6, 10
    add $t6, $t6, $t8
    addi $t5, $t5, 1
    j convert_x
    
x_converted:
    # Check x range
    blt $t6, 0, invalid
    bgt $t6, 14, invalid
    move $s1, $t6         # Save x value
    
    # Convert y string to integer
    la $t5, tempY
    li $t8, 0             # t8 = y value
    
convert_y:
    lb $t9, 0($t5)
    beq $t9, 0, y_converted
    subi $t9, $t9, 48     # Convert ASCII to decimal
    mul $t8, $t8, 10
    add $t8, $t8, $t9
    addi $t5, $t5, 1
    j convert_y
    
y_converted:
    # Check y range
    blt $t8, 0, invalid
    bgt $t8, 14, invalid
    move $s2, $t8         # Save y value in $s2
    
    # Calculate board index
    li $t9, 15
    mul $t9, $s1, $t9     # t9 = x * 15
    add $t9, $t9, $s2     # t9 = x * 15 + y
    
    # Check if position is available
    add $t5, $s0, $t9
    lb $t6, 0($t5)
    li $t7, 46            # ASCII '.'
    bne $t6, $t7, invalid
    
    # Update board
    beq $s4, 1, write_X
    li $t7, 79            # 'O'
    sb $t7, 0($t5)
    
    # Check if player 2 (O) wins
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    li $a3, 79            # 'O'
    jal check_win
    beq $v0, 1, player2_win
    
    j next_turn
    
write_X:
    li $t7, 88            # 'X'
    sb $t7, 0($t5)
    
    # Check if player 1 (X) wins
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    li $a3, 88            # 'X'
    jal check_win
    beq $v0, 1, player1_win
    
next_turn:
    addi $s3, $s3, 1
    li $t7, 225
    beq $s3, $t7, game_tie
    
    # Switch player
    li $t5, 1
    beq $s4, $t5, switch_to_2
    li $s4, 1
    j game_loop
    
switch_to_2:
    li $s4, 2
    j game_loop
    
invalid:
    la $a0, invalidMsg
    li $v0, 4
    syscall
    j game_loop
    
game_tie:
    move $a0, $s0
    jal print_board
    move $a0, $s0
    la $a1, msgTie
    jal save_result
    la $a0, msgTie
    li $v0, 4
    syscall
    j end_program
    
player1_win:
    move $a0, $s0
    jal print_board
    move $a0, $s0
    la $a1, msgWin1
    jal save_result
    la $a0, msgWin1
    li $v0, 4
    syscall
    j end_program

player2_win:
    move $a0, $s0
    jal print_board
    move $a0, $s0
    la $a1, msgWin2
    jal save_result
    la $a0, msgWin2
    li $v0, 4
    syscall
    j end_program

print_board:
    move $t0, $a0
    li $t1, 0
print_loop:
    lb $a1, 0($t0)
    li $v0, 11
    move $a0, $a1
    syscall
    li $a0, 32       # space
    li $v0, 11
    syscall
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    rem $t2, $t1, 15
    bnez $t2, skip_nl
    li $v0, 4
    la $a0, newline
    syscall
skip_nl:
    li $t3, 225
    blt $t1, $t3, print_loop
    jr $ra
    
# ============== Check win condition ==============
# Parameters:
# $a0 = board base address
# $a1 = x coordinate of last move
# $a2 = y coordinate of last move
# $a3 = player symbol ('X' or 'O')
# Returns:
# $v0 = 1 if win, 0 if not win
check_win:
    # Save registers
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    # Initialize variables
    move $s0, $a0       # board address
    move $s1, $a1       # x
    move $s2, $a2       # y
    move $s3, $a3       # player symbol ('X' or 'O')
    
    # Check horizontal (row)
    li $t0, 0           # consecutive count
    
    # Check row
    li $t1, 0           # column counter
check_row:
    # Calculate position
    mul $t2, $s1, 15    # row * 15
    add $t2, $t2, $t1   # row * 15 + col
    add $t3, $s0, $t2   # board address + offset
    lb $t4, 0($t3)      # get character
    
    # If matches player symbol, increment count
    bne $t4, $s3, reset_row_count
    addi $t0, $t0, 1
    bge $t0, 5, win_found
    j next_col
    
reset_row_count:
    li $t0, 0           # reset count
    
next_col:
    addi $t1, $t1, 1    # next column
    li $t5, 15
    blt $t1, $t5, check_row
    
    # Check vertical (column)
    li $t0, 0           # consecutive count
    li $t1, 0           # row counter
check_col:
    # Calculate position
    mul $t2, $t1, 15    # row * 15
    add $t2, $t2, $s2   # row * 15 + col
    add $t3, $s0, $t2   # board address + offset
    lb $t4, 0($t3)      # get character
    
    # If matches player symbol, increment count
    bne $t4, $s3, reset_col_count
    addi $t0, $t0, 1
    bge $t0, 5, win_found
    j next_row
    
reset_col_count:
    li $t0, 0           # reset count
    
next_row:
    addi $t1, $t1, 1    # next row
    li $t5, 15
    blt $t1, $t5, check_col
    
    # Check diagonal (top-left to bottom-right)
    li $v0, 0           # result (0 = no win)
    
    # Find starting point of diagonal (top-left)
    move $t1, $s1       # current row
    move $t2, $s2       # current col
    
    # Move to top-left as far as possible
    find_top_left:
    beq $t1, 0, done_top_left
    beq $t2, 0, done_top_left
    subi $t1, $t1, 1
    subi $t2, $t2, 1
    j find_top_left
    
done_top_left:
    li $t0, 0           # consecutive count
    
check_diag1:
    # Check if we're still on the board
    bge $t1, 15, check_diag2_init
    bge $t2, 15, check_diag2_init
    
    # Calculate position
    mul $t3, $t1, 15    # row * 15
    add $t3, $t3, $t2   # row * 15 + col
    add $t4, $s0, $t3   # board address + offset
    lb $t5, 0($t4)      # get character
    
    # Check for match
    bne $t5, $s3, reset_diag1_count
    addi $t0, $t0, 1
    bge $t0, 5, win_found
    j next_diag1
    
reset_diag1_count:
    li $t0, 0           # reset count
    
next_diag1:
    addi $t1, $t1, 1    # next row
    addi $t2, $t2, 1    # next col
    j check_diag1
    
    # Check diagonal (top-right to bottom-left)
check_diag2_init:
    # Find starting point of diagonal (top-right)
    move $t1, $s1       # current row
    move $t2, $s2       # current col
    
    # Move to top-right as far as possible
    find_top_right:
    beq $t1, 0, done_top_right
    bge $t2, 14, done_top_right
    subi $t1, $t1, 1
    addi $t2, $t2, 1
    j find_top_right
    
done_top_right:
    li $t0, 0           # consecutive count
    
check_diag2:
    # Check if we're still on the board
    bge $t1, 15, no_win
    bltz $t2, no_win
    
    # Calculate position
    mul $t3, $t1, 15    # row * 15
    add $t3, $t3, $t2   # row * 15 + col
    add $t4, $s0, $t3   # board address + offset
    lb $t5, 0($t4)      # get character
    
    # Check for match
    bne $t5, $s3, reset_diag2_count
    addi $t0, $t0, 1
    bge $t0, 5, win_found
    j next_diag2
    
reset_diag2_count:
    li $t0, 0           # reset count
    
next_diag2:
    addi $t1, $t1, 1    # next row
    subi $t2, $t2, 1    # prev col
    j check_diag2
    
win_found:
    li $v0, 1           # Return 1 (win)
    j check_win_exit
    
no_win:
    li $v0, 0           # Return 0 (no win)
    
check_win_exit:
    # Restore registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra
    
# ============== Save board + result to file ==============
save_result:
    # Save arguments
    move $t7, $a0      # Save board address
    move $t8, $a1      # Save result message
    
    # Open file
    li $v0, 13
    la $a0, fileName
    li $a1, 1          # Open for writing
    li $a2, 0
    syscall
    move $s6, $v0      # Save file descriptor
    
    # Write board
    move $t0, $t7      # Board address
    li $t1, 0          # Counter
write_board_loop:
    lb $t9, 0($t0)     # Load character from board
    
    # Write character
    li $v0, 15
    move $a0, $s6
    move $a1, $t0
    li $a2, 1
    syscall
    
    # Write space
    li $v0, 15
    move $a0, $s6
    la $a1, spaceChar
    li $a2, 1
    syscall
    
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    rem $t2, $t1, 15
    bnez $t2, skip_nl2
    
    # Write newline
    li $v0, 15
    move $a0, $s6
    la $a1, newline
    li $a2, 1
    syscall
    
skip_nl2:
    li $t3, 225
    blt $t1, $t3, write_board_loop
    
    # Write result message
    li $v0, 15
    move $a0, $s6
    move $a1, $t8      # Use saved result message
    li $a2, 30         # Max message length
    syscall
    
    # Close file
    li $v0, 16
    move $a0, $s6
    syscall
    
    jr $ra
    
end_program:
    li $v0, 10
    syscall