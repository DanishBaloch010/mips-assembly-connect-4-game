.data 
whitespace:             .ascii " "
bar:                    .ascii "|"
gameBoard:              .space  42
player1Token:           .asciiz "X"
player2Token:           .asciiz "O"
topRow:                 .asciiz "\n   0   1   2   3   4   5   6\n+-----------------------------+\n"
middleRow:              .asciiz "\n|----|---|---|---|---|---|----|\n"
bottomRow:              .asciiz "\n|----|---|---|---|---|---|----|\n+-----------------------------+\n   0   1   2   3   4   5   6\n\n"
index_pt1:              .asciiz "|"
index_pt2:              .asciiz "||"
player1Prompt:          .asciiz "Player 1: select a column to place your coin (0-6 or -1 to quit):"
player2Prompt:          .asciiz "Player 2: select a column to place your coin (0-6 or -1 to quit):"
IllegalMove:            .asciiz "Illegal move, no more room in that column.\n"
IllegalColumn:          .asciiz "Illegal column number.\n"
player1Wins:            .asciiz "Player 1 wins!\n"
player2Wins:            .asciiz "Player 2 wins!\n"
player1Quits:           .asciiz "Player 1 quit.\n"
player2Quits:           .asciiz "Player 2 quit.\n"
tieGameString:          .asciiz "The game ends in a tie.\n"

.text              	 
.globl  main            

main:
# stack frame size = 40
# game board size(array size) = 42 bytes (for 42 character entries).
    addi    $sp, $sp, -40        # allocating stack frame
    sw      $ra, -16($sp)
    sw      $ra, 0($sp)
    j       createBoard   	 # creates the initial game board
createRet:
    jal     displayBoard    # display the initial game board
    lw      $ra, 0($sp)
doneDisplay:
    jal     requestPlayer1Move   # begin game loop
gameOver:
    lw      $ra, -16($sp)
    addi    $sp, $sp, 40       	# freeing stack frame 
    jr      $ra 
    
createBoard:
    li      $s1, 42         # store the size of the board array in $s1
    la      $s2, gameBoard  # store the address of the array in $s2
    move    $s3, $zero      # set $s3 to 0
    la      $t2, whitespace
    lb      $t1, 0($t2)     # store the whitespace character in $t1
    j       createLoop      # begin another iteration of the loop

createLoop:
    addi    $t3, $s3, -42   #count is stored in $t3 and $s3 is used as counter(from 0->42)
    bgez    $t3, createRet  # if count >= 0 exit loop
    sb      $t1, 0($s2)     # store whitespace character in the array
    addi    $s2, $s2, 1     # incrementing the array index
    addi    $s3, $s3, 1     # incrementing the counter
    j       createLoop
  
displayBoard:
    move    $s4, $zero      # set the row value to 0
    move    $s5, $zero      # set the column value to 0
    j       displayRowLoop  # display the initial game board to the users
rowLoopRet:
    jr      $ra             # return from the subroutine

displayRowLoop:
    bne     $s4, $zero, notFirstRow     # if row != 0 then branch to notFirstRow
    li      $v0, 4
    la      $a0, topRow                 # print the topRow string
    syscall
    
notFirstRow:
    move    $s5, $zero          # set the column value to 0
    j       displayColumnLoop
columnLoopRet:
    addi    $t4, $s4, -5    
    bgez    $t4, doneRowLoop    # if row >= 5 then branch to doneRowLoop
    li      $v0, 4              
    la      $a0, middleRow      # load the middleRow string
    syscall                     # print the middleRow string
    addi    $s4, $s4, 1         # increment the row value
    j       displayRowLoop

doneRowLoop:
    li      $v0, 4              # prepare to print a string
    la      $a0, bottomRow      # load the bottomRow string address
    syscall                     # print the bottomRow string
    j       rowLoopRet

displayColumnLoop:
    bne     $s5, $zero, notFirstColumn  # if column != 0 branch to notFirstColumn
    li      $v0, 11                     # prepare to print a character
    la      $t2, bar                    # load the address of the bar character
    lb      $a0, 0($t2)                 # stores the bar character in t2
    syscall                             # print the bar character

notFirstColumn:
    li      $v0, 11                 # prepare to print character
    la      $t2, bar                # load the address of the bar character
    lb      $a0, 0($t2)             # stores the bar character in a0
    syscall                         # print the bar character
    la      $t2, whitespace         # load the address of the whiteSpace
    lb      $a0, 0($t2)             # store the whitespace character in a0
    syscall                         # print the whitespace character
    move    $a0, $s4                # a0 = row value
    move    $a1, $s5                # a1 = column value
    sw      $ra, 0($sp)             # store the return address on the stack
    jal     getArrayIndex           # get the corresponding array index
    lw      $ra, 0($sp)             # restore return address from the stack
    move    $s6, $v0                # s6 = current array index
    li      $v0, 11                 # prepare to print character
    la      $s7, gameBoard          # load the address of the gameBoard
    add     $s7, $s7, $s6           # s7 = address of array[currentIndex]
    lb      $a0, 0($s7)             # a0 = array[currentIndex]
    syscall                         # print array[currentIndex]
    la      $t2, whitespace         # load address of whiteSpace character
    lb      $a0, 0($t2)             # a0 = whitespace character
    syscall                         # print whitespace character
    addi    $t4, $s5, -6            # t4 = s5 - 6 
    bgez    $t4, lastColumn         # if column >= 6 branch to lastColumn
    addi    $s5, $s5, 1             # increment the column value
    j       displayColumnLoop       # begin another iteration of the loop

lastColumn:
    li      $v0, 4                  # prepare to print string
    la      $a0, index_pt2          # load the address of index_pt2 string
    syscall                         # print index_pt2
    j       columnLoopRet           # jump to columnLoopRet

getArrayIndex:
    move    $t0, $a0                # t0 = row index
    move    $v0, $a1                # v0 = column index 
multLoop:
    blez    $t0, multDone           # if row value <=0 branch to multDone
    addi    $v0, $v0, 7             # v0 += 7
    addi    $t0, $t0, -1            # t0--
    j       multLoop                # begin another iteration of the loop
multDone:
    jr      $ra                     # return from the subroutine

requestPlayer1Move:
    li      $v0, 4                  # prepare to print a string
    la      $a0, player1Prompt      # load the address of player1Prompt string 
    syscall                         # prompt player 1 to select a column
    li      $v0, 5                  # prepare to read an integer
    syscall                         # read the inputted integer
    move    $a1, $v0                # store the integer value in a1
    addi    $t4, $zero, -1          # t4 = -1
    addi    $a2, $zero, 1           # current player = 1
    beq     $t4, $a1, playerQuit    # if current column = -1 branch to playerQuit
    j       processPlayer1Move      # jump to processPlayer1Move

requestPlayer2Move:
    li      $v0, 4                  # prepare to print a string
    la      $a0, player2Prompt      # load the address of player2Prompt string 
    syscall                         # prompt player 2 to select a column
    li      $v0, 5                  # prepare to read an integer
    syscall                         # read the inputted integer
    move    $a1, $v0                # store the integer value in a1
    addi    $t4, $zero, -1          # t4 = -1
    addi    $a2, $zero, 2           # current player = 2
    beq     $t4, $a1, playerQuit    # if current column = -1 branch to playerQuit
    j       processPlayer2Move      # jump to processPlayer2Move

processPlayer1Move:
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     validIndex                      # check if the inputted index is valid
    lw      $ra, 0($sp)                     # restore the return address from the stack
    move    $t3, $v0                        # t3 = validIndex return value 
    addi    $a2, $zero, 1                   # current player = 1
    bnez    $t3, invalidPlayerIndex         # if t3 != 0 branch to invalidPlayerIndex
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     availableSpace                  # check if the selected index is available
    lw      $ra, 0($sp)                     # restore the return address from the stack 
    addi    $t3, $zero, -1                  # t3 = -1
    move    $a0, $v0                        # a0 = availableSpace return value 
    addi    $a2, $zero, 1                   # current player = 1
    beq     $a0, $t3, invalidSpaceChoice    # if a3 = -1 then branch to invalidSpaceChoice
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     getArrayIndex                   # get the corresponding array index
    lw      $ra, 0($sp)                     # restore the return address from the stack
    la      $t2, player1Token               # store the address of player1Token
    lb      $t1, 0($t2)                     # t1 = player1Token value 
    move    $s6, $v0                        # s6 = current array index
    la      $s7, gameBoard                  # load the address of the gameBoard
    add     $s7, $s7, $s6                   # s7 = address of array[currentIndex]
    sb      $t1, 0($s7)                     # array[currentIndex] = player1Token
    move    $a3, $t1                        # a3 = player1Token
    addi    $a2, $zero, 1                   # current player = 1
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     checkWinner                     # check if there is a winner
    lw      $ra, 0($sp)                     # restore the return address from the stack
    addi    $t4, $zero, 1                   # t4 = 1
    beq     $t4, $v0, gameOver              # if v0 == 1 then branch to gameOver
    addi    $a0, $zero, 1                   # a0 = 1
    j       switchPlayers                   # switch turns

processPlayer2Move:
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     validIndex                      # check if the inputted index is valid
    lw      $ra, 0($sp)                     # restore the return address from the stack
    move    $t3, $v0                        # t3 = validIndex return value 
    addi    $a2, $zero, 2                   # current player = 2
    bnez    $t3, invalidPlayerIndex         # if t3 != 0 branch to invalidPlayerIndex
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     availableSpace                  # check if the selected index is available
    lw      $ra, 0($sp)                     # restore the return address from the stack 
    addi    $t3, $zero, -1                  # t3 = -1
    move    $a0, $v0                        # a0 = availableSpace return value 
    addi    $a2, $zero, 2                   # current player = 2
    beq     $a0, $t3, invalidSpaceChoice    # if a3 = -1 then branch to invalidSpaceChoice
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     getArrayIndex                   # get the corresponding array index
    lw      $ra, 0($sp)                     # restore the return address from the stack
    la      $t2, player2Token               # store the address of player2Token
    lb      $t1, 0($t2)                     # t1 = player2Token value 
    move    $s6, $v0                        # s6 = current array index
    la      $s7, gameBoard                  # load the address of the gameBoard
    add     $s7, $s7, $s6                   # s7 = address of array[currentIndex]
    sb      $t1, 0($s7)                     # array[currentIndex] = player1Token
    move    $a3, $t1                        # a3 = player2Token
    addi    $a2, $zero, 2                   # current player = 2
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     checkWinner                     # check if there is a winner
    lw      $ra, 0($sp)                     # restore the return address from the stack
    addi    $t4, $zero, 1                   # t4 = 1
    beq     $t4, $v0, gameOver              # if v0 == 1 then branch to gameOver
    addi    $a0, $zero, 2                   # a0 = 2
    j       switchPlayers                   # switch turns

validIndex:
    slt     $v0, $a1, $zero     # if index < 0 set v0 to 1
    bnez    $v0, indexReturn    # if v0 != 0 theen branch to indexReturn
    move    $t0, $a1            # t0 = a1
    addi    $t0, $t0, -6        # t0 -= 6
    slt     $v0, $zero, $t0     # if t0 < 0 then t0 = 1
indexReturn:
    jr      $ra                 # return from the subroutine

invalidPlayerIndex:
    li      $v0, 4                          # prepare to print a string
    la      $a0, IllegalColumn              # load the address of the IllegalColumn string 
    syscall                                 # print the illegalColumn string 
    addi    $t2, $zero, 2                   # t2 = 2
    beq     $a2, $t2, requestPlayer2Move    # if currentPlayer == 2 then branch to requestPlayer2Move
    j       requestPlayer1Move              # jump to requestPlayer1Move

invalidSpaceChoice:
    li      $v0, 4                          # prepare to print a string
    la      $a0, IllegalMove                # load the address of the IllegalMove string 
    syscall                                 # print the illegalMove string 
    addi    $t2, $zero, 2                   # t2 = 2
    beq     $a2, $t2, requestPlayer2Move    # if currentPlayer == 2 then branch to requestPlayer2Move
    j       requestPlayer1Move              # jump to requestPlayer1Move

availableSpace:
    addi    $a0, $zero, 5                   # row index = 5
spaceLoop:
    sw      $ra, 0($sp)                     # store the return address on the stack
    jal     getArrayIndex                   # get the corresponding array index
    lw      $ra, 0($sp)                     # restore the return address from the stack
    la      $t2, whitespace                 # load the address of the whitespace character
    lb      $s5, 0($t2)                     # s5 = whitespace character
    move    $s6, $v0                        # s6 = current array index
#   li      $v0, 11                         # prepare to print character
    la      $s7, gameBoard                  # load the address of the gameBoard
    add     $s7, $s7, $s6                   # s7 = address of array[currentIndex]
    lb      $s4, 0($s7)                     # s4 = array[currentInde]
    beq     $s4, $s5, spaceAvailable        # if s4 == whitespace branch to spaceAvailable
    addi    $a0, $a0, -1                    # decrement the row index
    slt     $t5, $a0, $zero                 # checks if the row index is < 0
    bne     $t5, $zero, noSpaceAvailable    # if t5 != 0 then branch to noSpaceAvailable
    j       spaceLoop                       # begin another iteration of the loop
spaceAvailable:
    move    $v0, $a0                        # v0 = available row index
    jr      $ra                             # return from the subroutine
noSpaceAvailable:
    addi    $v0, $zero, -1                  # v0 = -1
    jr      $ra                             # return from the subroutine

checkWinner:
    move    $s1, $a0                        # s1 = row index
    move    $s2, $a1                        # s2 = column index 
    sw      $ra, 0($sp)                     # store the return address on the stack 
    sw      $a0, -4($sp)                    # store the row index on the stack 
    sw      $a1, -8($sp)                    # store the column index on the stack 
    j       checkHorizontalWin              # jump to checkHorizontalWin
hLoopRet:
    j       checkVerticalWin                # jump to checkVerticalWin
vLoopRet:
    j       checkDiagonalWIn                # jump to checkDiagonalWIn
diagonalRet:
    j       checkTieGame                    # jump to checkTieGame

checkHorizontalWin:
    lw      $s1, -4($sp)                    # s1 = stored row index 
    move    $s2, $zero                      # column index = 0
    move    $s3, $zero                      # count = 0
    j       horizontalLoop                  # jump to horizontalLoop

horizontalLoop:
    move    $t6, $s2                        # t6 = current column index 
    addi    $t6, $t6, -6                    # t6 -= 6
    bgtz    $t6, hLoopRet                   # if t6 > 6 branch to hLoopRet
    move    $a0, $s1                        # a0 = current row index
    move    $a1, $s2                        # a1 = current column index 
    sw      $ra, -12($sp)                   # store the return address on the stack 
    jal     getArrayIndex                   # get the corresponding array index 
    lw      $ra, -12($sp)                   # restore the return address from the stack 
    move    $s6, $v0                        # s6 = current array index 
    la      $s7, gameBoard                  # load the address of the gameBoard
    add     $s7, $s7, $s6                   # s7 = address of array[currentIndex]
    lb      $s4, 0($s7)                     # s4 = array[currentIndex]
    bne     $a3, $s4, hLoopReset            # if array[currentIndex] != currentplayer token then branch to hLoopReset 
    addi    $s3, $s3, 1                     # count++
    addi    $t4, $s3, -3                    # t3 = count -3
    bgtz    $t4, winner                     # if count >= 4 then branch to winner 
    addi    $s2, $s2, 1                     # column index ++
    j       horizontalLoop                  # begin another iteration of the loop 

hLoopReset:
    move    $s3, $zero                      # count = 0
    addi    $s2, $s2, 1                     # column index ++
    j       horizontalLoop                  # begin another iteration of the loop 

checkVerticalWin:
    move    $s3, $zero                      # count = 0
    lw      $s2, -8($sp)                    # s2 = stored column index 
    addi    $s1, $zero, 5                   # s1 = 5
    j       verticalLoop                    # jump to verticalLoop

verticalLoop:
    slt     $t4, $s1, $zero                 # if row index < 0 then t4 = 1
    bne     $t4, $zero, vLoopRet            # if t4 != 0 then branch to vLoopRet
    move    $t6, $s2                        # t6 = current column index 
    move    $a0, $s1                        # a0 = current row index 
    move    $a1, $s2                        # a1 = current column index 
    sw      $ra, -12($sp)                   # store the return address on the stack 
    jal     getArrayIndex                   # get the corresponding array index
    lw      $ra, -12($sp)                   # restore the return address from the stack 
    move    $s6, $v0                        # s6 = current array index 
    la      $s7, gameBoard                  # load the address of the gameBoard
    add     $s7, $s7, $s6                   # s7 = address of array[currentIndex]
    lb      $s4, 0($s7)                     # s4 = array[currentIndex]
    bne     $a3, $s4, vLoopReset            # if s4 != currentPlayer token then branch to vLoopReset
    addi    $s3, $s3, 1                     # count++
    addi    $t4, $s3, -3                    # t4 = count -3
    bgtz    $t4, winner                     # if count >= 4 then branch to winner 
    addi    $s1, $s1, -1                    # row index --
    j       verticalLoop                    # begin another iteration of the loop 

vLoopReset:
    move    $s3, $zero                      # count = 0
    addi    $s1, $s1, -1                    # row index --
    j       verticalLoop                    # begin another iteration of the loop 

checkDiagonalWIn:
    lw      $s1, -4($sp)                    # s1 = stored row index
    lw      $s2, -8($sp)                    # s2 = stored column index
    j       rightDiagonalPrep               # jump to rightDiagonalPrep
rDiagonalRet:
    lw      $s1, -4($sp)                    # s1 = stored row index
    lw      $s2, -8($sp)                    # s2 = stored column index 
    j       leftDiagonalPrep                # jump to leftDiagonalPrep

rightDiagonalPrep:
    move    $s3, $zero                      # count = 0
    slti    $t4, $s1, 5                     # if row index < 5 then t4 = 1
    beq     $t4, $zero, checkRightDiagonal  # if t4 == 0 then branch to checkRightDiagonal
    blez    $s2, checkRightDiagonal         # if column index <= 0 then branch to checkRightDiagonal
    addi    $s1, $s1, 1                     # row index ++
    addi    $s2, $s2, -1                    # column index --
    j       rightDiagonalPrep               # begin another iteration of the loop 

leftDiagonalPrep:
    move    $s3, $zero                      # count = 0
    slti    $t4, $s1, 5                     # if row index < 5 then t4 = 1
    beq     $t4, $zero, checkLeftDiagonal   # if t4 == 0 then branch to checkLeftDiagonal
    slti    $t4, $s2, 6                     # if column index < 6 then t4 = 1
    beq     $t4, $zero, checkLeftDiagonal   # if t4 == 0 then branch to checkLeftDiagonal
    addi    $s1, $s1, 1                     # row index ++
    addi    $s2, $s2, 1                     # column index ++
    j       leftDiagonalPrep                # begin another iteration of the loop

checkRightDiagonal:
    move    $t6, $s2                        # t6 = current column index 
    addi    $t6, $t6, -6                    # t6 -= 6
    bgtz    $t6, rDiagonalRet               # if column index > 6 then branch to rDiagonalRet
    move    $a0, $s1                        # a0 = current row index 
    move    $a1, $s2                        # a1 = current column index 
    sw      $ra, -12($sp)                   # store the return address on the stack 
    jal     getArrayIndex                   # get the corresponding array index 
    lw      $ra, -12($sp)                   # restore the return address from the stack
    move    $s6, $v0                        # s6 = current array index 
    la      $s7, gameBoard                  # load the address of the gameBoard
    add     $s7, $s7, $s6                   # s7 = address of array[currentIndex]
    lb      $s4, 0($s7)                     # s4 = array[currentIndex]
    lw      $a0, -4($sp)                    # a0 = stored row index value 
    bne     $a3, $s4, rDiagonalReset        # if array[currentIndex] != currentPlayer token then branch to rDiagonalReset
    addi    $s3, $s3, 1                     # count++
    addi    $t4, $s3, -3                    # t4 = count -3
    bgtz    $t4, winner                     # if count >= 4 then branch to winner 
    addi    $s1, $s1, -1                    # row index --
    addi    $s2, $s2, 1                     # column index ++
    j       checkRightDiagonal              # begin another iteration of the loop 

rDiagonalReset:
    move    $s3, $zero                      # count = 0
    addi    $s1, $s1, -1                    # row index --
    addi    $s2, $s2, 1                     # column index ++
    j       checkRightDiagonal              # begin another iteration of the loop 

checkLeftDiagonal:
    slti    $t4, $s2, 0                     # if column index < 0 then t4 = 1
    bne     $t4, $zero, diagonalRet         # if t4 != 0 then branch to diagonalRet 
    slti    $t4, $s1, 0                     # if row index < 0 then t4 = 1
    bne     $t4, $zero, diagonalRet         # if t4 != 0 then branch to diagonalRet
    move    $a0, $s1                        # a0 = current row index 
    move    $a1, $s2                        # a1 = current column index 
    sw      $ra, -12($sp)                   # store the return address on the stack
    jal     getArrayIndex                   # get the corresponding array index 
    lw      $ra, -12($sp)                   # restore the return address from the stack
    move    $s6, $v0                        # s6 = current array index 
    la      $s7, gameBoard                  # load the address of the gameBoard
    add     $s7, $s7, $s6                   # s7 = address of array[currentIndex]
    lb      $s4, 0($s7)                     # s4 = array[currentIndex]
    lw      $a0, -4($sp)                    # a0 = stored row index value 
    bne     $a3, $s4, lDiagonalReset        # if array[currentIndex] != currentPlayer token then branch to lDiagonalReset
    addi    $s3, $s3, 1                     # count++
    addi    $t4, $s3, -3                    # t4 = count -3
    bgtz    $t4, winner                     # if count >= 4 then branch to winner 
    addi    $s1, $s1, -1                    # row index --
    addi    $s2, $s2, -1                    # column index --
    j       checkLeftDiagonal               # begin another iteration of the loop 

lDiagonalReset:
    move    $s3, $zero                      # count = 0
    addi    $s1, $s1, -1                    # row index --
    addi    $s2, $s2, -1                    # column index --
    j       checkLeftDiagonal               # begin another iteration of the loop 

checkTieGame:
    move    $t4, $zero                      # t4 = 0 using as count
    la      $t5, gameBoard                  # load the address of the gameBoard
    la      $t2, whitespace                 # load the address of the whitespace character
    lb      $t1, 0($t2)                     # t1 = whitespace character value 
    j       checkTieLoop                    # jump to checkTieLoop

checkTieLoop:
    addi    $t3, $t4, -42                   # t3 = count - 42
    bgez    $t3, tieGame                    # if count >= 42 then branch to tie Game 
    lb      $t6, 0($t5)                     # t6 = array[count]
    beq     $t1, $t6, doneWinCheck          # if t6 == whitespace then branch to doneWinCheck
    addi    $t4, $t4, 1                     # count++
    addi    $t5, $t5, 1                     # current array address ++
    j       checkTieLoop                    # begin another iteration of the loop 

tieGame:
    jal     displayBoard                    # display the gameBoard
    li      $v0, 4                          # prepare to print a string 
    la      $a0, tieGameString              # load the address of tieGameString
    syscall                                 # print tieGameString
    j       gameOver                        # jump to gameOver

winner:
    jal     displayBoard                    # display the gameBoard
    lw      $ra, -12($sp)                   # restore the return address from the stack
    addi    $t2, $zero, 1                   # t2 = 1
    bne     $a2, $t2, p2Wins                # if currentPlayer value != 1 then branch to p2Wins
    li      $v0, 4                          # prepare to print a string
    la      $a0, player1Wins                # load the address of the player1Wins string 
    syscall                                 # print the player1Wins string 
    lw      $a0, -4($sp)                    # restore the row value from the stack
    lw      $a1, -8($sp)                    # restore the column value from the stack
    addi    $v0, $zero, 1                   # v0 = 1; a the game has been
    jr      $ra                             # return from subroutine
p2Wins:
    li      $v0, 4                          # prepare to print a string
    la      $a0, player2Wins                # load the address of the player2Wins string 
    syscall                                 # print the player1Wins string 
    lw      $a0, -4($sp)                    # restore the row value from the stack
    lw      $a1, -8($sp)                    # restore the column value from the stack
    addi    $v0, $zero, 1                   # v0 = 1; a the game has been
    jr      $ra                             # return from subroutine

playerQuit:
    addi    $t2, $zero, 1                   # t2 = 1
    bne     $a2, $t2, player2Quit           # if currentPlayer value != 2 then branch to player1Quit
    li      $v0, 4                          # prepare to print a string 
    la      $a0, player1Quits               # load the address of the player1Quits string 
    syscall                                 # print the player1Quits string 
    j       gameOver                        # jump to gameOver
player2Quit:
    li      $v0, 4                          # prepare to print a string 
    la      $a0, player2Quits               # load the address of the player2Quits string 
    syscall                                 # print the player1Quits string 
    j       gameOver                        # jump to gameOver

doneWinCheck:
    move    $v0, $zero                      # v0 = 0; the game has not been won 
    lw      $ra, 0($sp)                     # restore the return address from the stack
    lw      $a0, -4($sp)                    # restore the row index from the stack
    lw      $a1, -8($sp)                    # restore the column index from the stack
    jr      $ra                             # return from the subroutine

switchPlayers:
    sw      $ra, 0($sp)                     # store the return address on the stack
    sw      $a0, -4($sp)                    # store the currentPlayer value on the stack 
    jal     displayBoard                    # display the gameBoard
    lw      $ra, 0($sp)                     # restore the return address from the stack
    lw      $a0, -4($sp)                    # restore the currentPlayer value from the stack
    addi    $t3, $zero, 1                   # t3 = 1
    bne     $a0, $t3, requestPlayer1Move    # if currentPlayer value != 1 then branch to requestPlayer1Move
    j       requestPlayer2Move              # jump to requestPlayer2Move

#exit code
li $v0, 10
syscall
