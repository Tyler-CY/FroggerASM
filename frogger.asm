#####################################################################
# Latest Update: 2021-12-07-1738
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Chun Yin Yan, 1007500081
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1, 2, 3, 4, 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining. (Easy Feature)
# 2. Have objects in different rows move at different speeds. (Easy Feature)
# 3. After final player death, display game over/retry screen. Restart the game if the “retry” option is chosen. (Easy Feature)
# 4. Make a second level that starts after the player completes the first level. (Hard Feature)
# 5. Add sound effects for movement, collisions, game end and reaching the goal area. (Hard Feature)
#
# Any additional information that the TA needs to know:
# - Thank you for being a nice TA :)
# - Instructions: wasd to move (NOT WASD), r to reset back to level 1 at anytime, t to reset back to level 2 at anytime, ESC to end game
# - Note: there are two levels. The second level is harder than the first level.
#####################################################################


.data
displayAddress: .word 0x10008000
breakpoint: .asciiz "BREAKPOINT\n" 	# used for debugging
endMessage: .asciiz "GAME OVER!\n"	# used for logging game over activity
liveLostMessage: .asciiz "LIVES -1\n"	# used for logging life lost
lives: .word 3			# no. of lives the player has
sleep: .word 100			# FPS = 1/sleep
updateLeftSlow: .word -4
updateRightSlow: .word 4
updateLeftFast: .word -8
updateRightFast: .word 8

# Array of offsets (from top left corner) of logs, cars and goal regions
logrow: .word 0:4
carrow: .word 0:4
goalrow: .word 0:4

.text
start:	# Initialize variables	

	# Ensure the player has 3 lives
	addi $s4, $zero, 3
	sw $s4, lives
		
	# $s4 stores position of frog
	lw $s4, displayAddress
	addi $s4, $s4, 3644 
		
	# set initial positions of cars and logs
	addi $t0, $zero, 0 # index of array
	
	# load initial offsets of logs
	addi $s0, $zero, 1024 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 1088 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 1564 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 1628 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	
	
	# set initial offsets of cars
	addi $t0, $zero, 0 # index of array
	
	addi $s0, $zero, 2560 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 2592 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 3100 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 3168 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
		
	# set initial offsets of goals
	addi $t0, $zero, 0 # index of array
	
	addi $s0, $zero, 524 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 556 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 588 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 620 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	
	j main
	
main:	# the main program (program starts here)
	
	jal drawBackground # draw background areas
	
	jal drawLives # Print Lives
	
	jal drawGoals # Print Goal Regions
	
	# Draw Cars
	addi $a0, $zero, 16	# width of cars
	jal drawCars
	
	# Draw Logs
	addi $a0, $zero, 48 	# width of logs
	jal drawLogs # Draw Logs
	
	# Check if Frog is on any logs		
	addi $a0, $s4, 0
	jal checkFrogOnLog
	
	# Check if player has won yet
	addi $a0, $zero, 1
	jal checkWin
		
	jal updateCars # Update Cars Position
	
	jal updateLogs # Update Logs Position

	# Print frog	
	addi $a0, $s4, 0 # load address of frog
	jal drawFrog
	
	# Control frog
	lw $t8, 0xffff0000	
	beq $t8, 1, keyboard_input
	
	# check if player scores a goal
	jal checkGoal
	
	# Print frog (Update Position of Frog after moving)	
	addi $a0, $s4, 0 # load address of frog
	jal drawFrog
	
	# If all lives are lost, Exit. Note that the game collision is done in drawFrog method
	lw $t0, lives
	beq $t0, 0, Exit
	
	# sleep
	li $v0, 32
	li $a0, 225 # Sleep Time
	syscall
	
	j main # jump back to main (infinite while loop)

	jal Exit # Safe Exit


##############################################################
# MAIN CODE FOR LEVEL 2 BEGINS HERE
# MAIN CODE FOR LEVEL 2 BEGINS HERE
# MAIN CODE FOR LEVEL 2 BEGINS HERE
# MAIN CODE FOR LEVEL 2 BEGINS HERE
##############################################################
start2:	# Initialize variables	

	# Ensure the player has 3 lives
	addi $s4, $zero, 3
	sw $s4, lives
	
	
	# $s4 stores position of frog
	lw $s4, displayAddress
	addi $s4, $s4, 3644 
	
	
	# set initial positions of cars and logs
	addi $t0, $zero, 0 # index of array
	
	# load initial offsets of logs
	addi $s0, $zero, 1024 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 1084 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 1564 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 1628 # $s0 stores current address
	sw $s0, logrow($t0) # store current address to array
	
	
	# set initial offsets of cars
	addi $t0, $zero, 0 # index of array
	
	addi $s0, $zero, 2560 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 2644 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 3100 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 3136 # $s0 stores current address
	sw $s0, carrow($t0) # store current address to array
	
	
	# set initial offsets of goals
	addi $t0, $zero, 0 # index of array
	
	addi $s0, $zero, 524 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 556 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 588 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	addi $t0, $t0, 4	# iterate to the next index
	
	addi $s0, $zero, 620 # $s0 stores current address
	sw $s0, goalrow($t0) # store current address to array
	
	
main2:	# the main program (program starts here)
	jal drawBackground # draw background areas
	
	jal drawLives # Print Lives
	
	jal drawGoals # Print Goal Regions
	
	# Draw Cars
	addi $a0, $zero, 28	# width of cars
	jal drawCars
	
	# Draw Logs
	addi $a0, $zero, 40 	# width of logs
	jal drawLogs # Draw Logs
	
	# Check if Frog is on any logs		
	addi $a0, $s4, 0
	jal checkFrogOnLog
	
	# Check if player has won yet
	addi $a0, $zero, 2
	jal checkWin
		
	jal updateCars # Update Cars Position
	
	jal updateLogs # Update Logs Position

	# Print frog	
	addi $a0, $s4, 0 # load address of frog
	jal drawFrog
	
	# Control frog
	lw $t8, 0xffff0000	
	beq $t8, 1, keyboard_input
	
	# check if player scores a goal
	jal checkGoal
	
	# Print frog (Update Position of Frog after moving)	
	addi $a0, $s4, 0 # load address of frog
	jal drawFrog
	
	# If all lives are lost, Exit. Note that the game collision is done in drawFrog method
	lw $t0, lives
	beq $t0, 0, Exit
	
	# sleep
	li $v0, 32
	li $a0, 200 # Sleep Time
	syscall
	
	j main2 # jump back to main (infinite while loop)

	jal Exit # Safe Exit



###################################################################################################################################################
# Object Drawing Procedures
###################################################################################################################################################
drawBackground:
	# Load variables
	lw $t0, displayAddress # $t0 stores the base address for display
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0x00ff00 # $t2 stores the green colour code
	li $t3, 0x9ffeff # $t3 stores the light blue colour code

	# Print safe zone (end)
	addi $a0, $t2, 0 # load color to arugment 0 $a0
	addi $a1, $t0, 0 # load address to argument 1 $a1
	addi $a2, $zero, 8 # load no. of rows to argument 2 $a2
	sub $sp, $sp, 4 # push ra
	sw $ra, 4($sp) # store current return address
	jal drawRectWidth
	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack

			
	# Print River
	addi $a0, $t3, 0 # load color to arugment 0 $a0
	addi $a1, $t0, 1024 # load address to argument 1 $a1
	addi $a2, $zero, 8 # load no. of rows to argument 2 $a2
	sub $sp, $sp, 4 # push ra
	sw $ra, 4($sp) # store current return address
	jal drawRectWidth
	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack
	
	# Print safe zone (mid)
	addi $a0, $t2, 0 # load color to arugment 0 $a0
	addi $a1, $t0, 2048 # load address to argument 1 $a1
	addi $a2, $zero, 4 # load no. of rows to argument 2 $a2
	sub $sp, $sp, 4 # push ra
	sw $ra, 4($sp) # store current return address
	jal drawRectWidth
	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack
	
	# Print Road
	addi $a0, $zero, 0x6f8693 # load color to arugment 0 $a0
	addi $a1, $t0, 2560 # load address to argument 1 $a1
	addi $a2, $zero, 8 # load no. of rows to argument 2 $a2
	sub $sp, $sp, 4 # push ra
	sw $ra, 4($sp) # store current return address
	jal drawRectWidth
	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack
	
	# Print safe zone (start)
	addi $a0, $t2, 0 # load color to arugment 0 $a0
	addi $a1, $t0, 3584 # load address to argument 1 $a1
	addi $a2, $zero, 4# load no. of rows to argument 2 $a2
	sub $sp, $sp, 4 # push ra
	sw $ra, 4($sp) # store current return address
	jal drawRectWidth
	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack

	jr $ra


drawGoals:
	lw $t1, displayAddress
	addi $s1, $zero, 0 # index of array
	
	drawGoalsLoop:
		beq $s1, 16, drawGoalsExit	# If we finished drawing 4 FOUR goals
		
		lw $t4, goalrow($s1) # get element from array at index
		add $a0, $t1, $t4 # load address of goal
		addi $a1, $zero, 0xFF00F0 # load color of goal
		
		sub $sp, $sp, 4 # push ra
		sw $ra, 4($sp) # store current return address
		jal drawGoal
		lw $ra, 4($sp) # pop ra
		add $sp, $sp, 4 # restore stack
			
		addi $s1, $s1, 4 # index of array += 4
		
		j drawGoalsLoop
		
	drawGoalsExit:
		jr $ra	


drawCars:	# Take $a0 for width
	lw $t1, displayAddress
	addi $s1, $zero, 0 # index of array
	add $a2, $a0, $zero	# let $a2 store the width
	
	drawCarsLoop:
		beq $s1, 16, drawCarsExit	# If we finished drawing 4 FOUR goals
		
		lw $t4, carrow($s1) # get element from array at index
		add $a0, $t1, $t4 # load address of goal
		addi $a1, $zero, 0xffc0cb # load color of goal
		add $a2, $a2, $zero
		
		sub $sp, $sp, 4 # push ra
		sw $ra, 4($sp) # store current return address
		jal drawObstacle
		lw $ra, 4($sp) # pop ra
		add $sp, $sp, 4 # restore stack
			
		addi $s1, $s1, 4 # index of array += 4
		
		j drawCarsLoop
		
	drawCarsExit:
		jr $ra	


drawLogs:	# Take $a0 for width
	lw $t1, displayAddress
	addi $s1, $zero, 0 # index of array
	add $a2, $a0, $zero	# let $a2 store the width
	
	drawLogsLoop:
		beq $s1, 16, drawLogsExit	# If we finished drawing 4 FOUR goals
		
		lw $t4, logrow($s1) # get element from array at index
		add $a0, $t1, $t4 # load address of goal
		addi $a1, $zero, 0x964B00 # load color of goal
		add $a2, $a2, $zero
		
		sub $sp, $sp, 4 # push ra
		sw $ra, 4($sp) # store current return address
		jal drawObstacle
		lw $ra, 4($sp) # pop ra
		add $sp, $sp, 4 # restore stack
			
		addi $s1, $s1, 4 # index of array += 4
		
		j drawLogsLoop
		
	drawLogsExit:
		jr $ra	
		

###################################################################################################################################################
# Update Drawing Procedures
###################################################################################################################################################
updateLogs:
	addi $s1, $zero, 0 # Iterator
	addi $t7, $zero, 128	# Divisor for division in loop
	

	updateLogsLoop:	
		beq $s1, 16, updateLogsExit		
		lw $t0, logrow($s1)	# load element
		div $t0, $t7	# get row, col
		mfhi $t1	# remainder (offset from left most column of current row)
		sub $t0, $t0, $t1 # set $t0 to the left most column of current row (first by going left most)
		# Now $t0 is the address of the left most column of the current row
		
		beq $s1, 0, updateFirstRow
		beq $s1, 4, updateFirstRow
		
		# REMEMBER TO CHANGE checkFrogOnLog VALUE IF CHANGING LOADWORD
		updateSecondRow:
			lw $t2, updateRightFast		
			j updateContinue
			
		updateFirstRow:
			lw $t2, updateLeftSlow
			j updateContinue
			
		updateContinue:	
			add $t1, $t1, $t2	# update the offset
			bltz $t1, setPositive   	# should i bltzal?
		
		updateElse:
			# make sure this column offset is within correct range
			div $t1, $t7
			mfhi $t1	# new offset
		
		updateFinally:
			add $t0, $t0, $t1	# new address
			sw $t0, logrow($s1)	# store new address
		
			addi $s1, $s1, 4	# Next Iteration
		
			j updateLogsLoop
		
	setPositive:
		addi $t1, $t1, 124	
		j updateFinally
		
	updateLogsExit:
		jr $ra


checkFrogOnLog: # a0 = starting address

	li $t6, 0x964B00 # load log color to $t4
	
	
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 12 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing

	
	addi $a0, $a0, 116 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 120 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 120 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0) # get ground color of frog address (top left corner) into $t1
	bne $t1, 0x964B00, checkFrogOnLogExit	# if that ground color is not brown (color of log), then do nothing
	
	# If all the frogs are on the log, then we move the frog by the amount the log is moving
	# Always check if it is in the same row (TODO)
	
	
	
	lw $t5, displayAddress
	addi $t5, $t5, 1536
	bgt $s4, $t5, updateFrogLowerRoad	# check if the frog is on the lower road
	blt $s4, $t5, updateFrogUpperRoad	# check if the frog is on the upper road
	
	updateFrogLowerRoad:
		# check if frog goes across boundary on the right
		lw $t5, displayAddress
		addi $t5, $t5, 1644
		bgt $s4, $t5, limitRightRiver
		
		lw $t2, updateRightFast
		add $s4, $s4, $t2
		
		j checkFrogOnLogExit
	
	updateFrogUpperRoad:
		# check if frog goes across boundary on the left
		lw $t5, displayAddress
		addi $t5, $t5, 1028
		blt $s4, $t5, limitLeftRiver
		
		lw $t2, updateLeftSlow
		add $s4, $s4, $t2
		
		j checkFrogOnLogExit
		
	limitRightRiver:
		lw $t5, displayAddress
		addi $t5, $t5, 1648
		addi $s4, $t5, 0
		j checkFrogOnLogExit
		
	limitLeftRiver:
		li $v0 4
		la $a0, breakpoint
		syscall
	
		lw $t5, displayAddress
		addi $t5, $t5, 1024
		addi $s4, $t5, 0
		j checkFrogOnLogExit
		
	checkFrogOnLogExit:
		jr $ra
			
updateCars:
	addi $s1, $zero, 0 # Iterator
	addi $t7, $zero, 128	# Divisor for division in loop
	

	updateCarsLoop:	
		beq $s1, 16, updateCarsExit		
		lw $t0, carrow($s1)	# load element
		div $t0, $t7	# get row, col
		mfhi $t1	# remainder (offset from left most column of current row)
		sub $t0, $t0, $t1 # set $t0 to the left most column of current row (first by going left most)
		# Now $t0 is the address of the left most column of the current row
		
		beq $s1, 0, updateFirstRowCar
		beq $s1, 4, updateFirstRowCar
		
		updateSecondRowCar:
			lw $t2, updateRightSlow
			j updateContinueCar
			
		updateFirstRowCar:
			lw $t2, updateLeftFast
			j updateContinueCar
			
		updateContinueCar:	
			add $t1, $t1, $t2	# update the offset
			bltz $t1, setPositiveCar  	# should i bltzal?
		
		updateElseCar:
			# make sure this column offset is within correct range
			div $t1, $t7
			mfhi $t1	# new offset
		
		updateFinallyCar:
			add $t0, $t0, $t1	# new address
			sw $t0, carrow($s1)	# store new address
		
			addi $s1, $s1, 4	# Next Iteration
		
			j updateCarsLoop
		
	setPositiveCar:
		addi $t1, $t1, 124	
		j updateFinallyCar
		
	updateCarsExit:
		jr $ra
		
		
	
	
	

###################################################################################################################################################
# Object Drawing Procedures
###################################################################################################################################################	
drawObstacle:
	# a0 = starting address (CONST), $a1 = color (CONST), $a2 = width (either 16 or 24 or 32)
	move $t3, $a0	# set $t3 to starting address
	
	addi $t4, $zero, 128 # set $t4 to 128 as divisor
	div $t3, $t4	# divide $t3 by 128 to get quotient and remainder
	mfhi $t3	# set $t3 to remainder
	mfhi $t4	# $t4 now stores the remainder (distance from left most column to starting address) (CONST)
	sub $t3, $a0, $t3	# set $t3 to left most column of that row (CONST)
	
	# Now $t3 has the address of the left most column of that row, and $t3 + $t4 is the starting address
	
	li $s5, 3	# load height of car
	
	add  $t5, $zero, $t4	# t5 is the column offset from left most column
	addi $t6, $zero, 0	# Loop iterator (just to keep track of row and column)
	addi $t8, $zero, 0	# Column iterator
	addi $t9, $zero, 0	# Row iterator
	
	
	drawObstacleLoop:
		add $t2, $t3, $t5	# $t2 is the actual address wanted # $t2 = $t3 (Left Most Column Address) + $t5 (Column Offset)
		add $t2, $t2, $t9	# $t2 is the actual address wanted # $t2 = $t2 + t9 (Row Offset)
		
		sw $a1, 0($t2)		# load color $t4 into address $t3 (Printing)
		
		addi $t6, $t6, 4	# Loop iterator += 4
		
		# Iterator for column
		addi $t8, $t8, 4	# Column iterator +=4
		add $t7, $zero, $a2	# Set $t7 = 32 as divisor to get mod in next 2 lines	
		div $t8, $t7
		mfhi $t8		# $t8 = $t8 mod 32 to ensure we are printing 8 times on a row only
		
		add $t5, $t4, $t8	# offset $t5 = $t4 (original offset) + $t8 (column iterator)
		
		addi $t7, $zero, 128	# CONST $t7 = 128 to do division
		div $t5, $t7		# check overflow, if overflow, set $t5 self to remainder
		mfhi $t5
			
		# check if we have printed 8 times (finished the current row)
		add $t7, $zero, $a2	# CONST $t7 = 32	
		div $t6, $t7		# Divide by 32 to get the quotient (how many rows printed so far) and remainder (how far to the right we are printing)
				
		mflo $t9		# Load the current cycle (quotient) in $t9
		bgt $t9, $s5, drawObstacleExit	# exit program if we reach the height of row $t5
		
		mul $t9, $t9, 128	# row offset $t9 = 128 times column
		
		j drawObstacleLoop
	
	drawObstacleExit:		
		jr $ra
	
			
drawFrog: # this function also checks for collision

	# a0 = starting address
	li $t6, 0x35591a # load frog color to $t4	
	
	lw $t1, ($a0) # get color of frog address (top left corner) into $t1
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	
	# drawing at address $a0 with offsets
	sw $t6, 0($a0)	
	
	addi $a0, $a0, 12 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	
	sw $t6, 0($a0) # draw frog
	
	addi $a0, $a0, 116 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 120 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 120 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, 0($a0)
	
	addi $a0, $a0, 4 # next pixel draw
	lw $t1, ($a0)
	beq $t1, 0xffc0cb, collision
	beq $t1, 0x9ffeff, collision
	sw $t6, ($a0)

	jr $ra
	
	collision:
	# Sound Effect
		li $v0, 31
		addi $a0, $zero, 55
		addi $a1, $zero, 2500
		addi $a2, $zero, 39
		addi $a3, $zero, 111
		syscall
		
		li $v0 4
		la $a0, liveLostMessage
		syscall
	
		# If all lives are lost, Exit
		lw $t0, lives	
		# minus one live
		sub $t0, $t0, 1
		sw $t0, lives
		beq $t0, 0, Exit
	
		# reset position of frog
		lw $s4, displayAddress
		addi $s4, $s4, 3644

	
		jr $ra		

###################################################################################################################################################
# Goal and Winning-Checking Procedures
###################################################################################################################################################
checkGoal:
	# check if goal region is filled, $s4 is the address of frog.	
	lw $t0, displayAddress # $t0 stores the base address for display
	
	addi $s1, $zero, 0 # index of array
	lw $s3, goalrow($s1) # get element from array at index
	
	add $t1, $t0, $s3 # address of goal
	beq $s4, $t1, goal # check if goal address matches frog position
	
	addi $s1, $s1, 4 # index of array += 4
	lw $s3, goalrow($s1) # get element from array at index
	add $t1, $t0, $s3 # address of goal
	beq $s4, $t1, goal # check if goal address matches frog position
	
	addi $s1, $s1, 4 # index of array += 4
	lw $s3, goalrow($s1) # get element from array at index
	add $t1, $t0, $s3 # address of goal
	beq $s4, $t1, goal # check if goal address matches frog position
		
	addi $s1, $s1, 4 # index of array += 4
	lw $s3, goalrow($s1) # get element from array at index
	add $t1, $t0, $s3 # address of goal
	beq $s4, $t1, goal # check if goal address matches frog position


checkWin: #$a0 is either 1 or 2, indicating the level
	addi $t0, $zero, 0 # index of array
	
	lw $s0, goalrow($t0) # load 1st goal address
	bne $s0, 40000, checkWinReturn
	
	addi $t0, $t0, 4	# iterate to the next index	
	lw $s0, goalrow($t0) # load 1st goal address
	bne $s0, 40000, checkWinReturn
	
	addi $t0, $t0, 4	# iterate to the next index
	lw $s0, goalrow($t0) # load 1st goal address
	bne $s0, 40000, checkWinReturn
	
	addi $t0, $t0, 4	# iterate to the next index
	lw $s0, goalrow($t0) # load 1st goal address
	bne $s0, 40000, checkWinReturn
	
	
	beq $a0, 1, loadLevel2
	beq $a0, 2, loadGameOver
	
	loadLevel2:
		jal start2
	loadGameOver:
		jal Exit

	checkWinReturn:	# Player hasn't won yet
		jr $ra
	
goal:
	# Cheer Sound Effect
	li $v0, 31
	addi $a0, $zero, 60
	addi $a1, $zero, 2500
	addi $a2, $zero, 126
	addi $a3, $zero, 127
	syscall
	
	# Draw the goal outside the screen to remove the goal
	li $s3, 40000
	sw $s3, goalrow($s1)
	
	# reset position of frog
	lw $s4, displayAddress	# Address of top left corner
	addi $s4, $s4, 3644	# Initial offset of frog from top left corner
	add $a0, $zero, $s4	# $a0 stores the argument (initial address of frog) for drawFrog procedure
	
	sub $sp,$sp,4 # push ra
	sw $ra,4($sp)
	jal drawFrog
	lw $ra,4($sp) # pop ra
	add $sp,$sp,4
	
	jr $ra
		

###################################################################################################################################################
# Exit Procedures
###################################################################################################################################################
Exit:
	sub $sp, $sp, 4 # allocate space
	sw $ra, 4($sp) # push ra in allocated space
	jal gameOver #PRINT GAMEOVER SCREEN
	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack
	
	li $v0 4
	la $a0, endMessage
	syscall
	
	# Sound Effect
	li $v0, 33
	addi $a0, $zero, 59
	addi $a1, $zero, 800
	addi $a2, $zero, 63
	addi $a3, $zero, 111
	syscall
	li $v0, 33
	addi $a0, $zero, 58
	addi $a1, $zero, 800
	addi $a2, $zero, 63
	addi $a3, $zero, 111
	syscall	
	li $v0, 33
	addi $a0, $zero, 57
	addi $a1, $zero, 800
	addi $a2, $zero, 63
	addi $a3, $zero, 111
	syscall
	li $v0, 31
	addi $a0, $zero, 56
	addi $a1, $zero, 1500
	addi $a2, $zero, 63
	addi $a3, $zero, 111
	syscall
	
ExitLoop:
	# sleep
	li $v0, 32
	li $a0, 200 # 200 ms sleep
	syscall
	
	sub $sp, $sp, 4 # allocate space
	sw $ra, 4($sp) # push ra in allocated space
	jal gameOver #PRINT GAMEOVER SCREEN
	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack
		
	lw $t8, 0xffff0000	
	beq $t8, 1, keyboard_input
	
	j ExitLoop
	
	
terminate: # Used for ESC button
	li $v0, 10 # terminate the program gracefully

	syscall
	

###################################################################################################################################################
# Keyboard Control Procedures
###################################################################################################################################################
keyboard_input:
	# push return address to the stack
	sub $sp, $sp, 4 # allocate space
	sw $ra, 4($sp) # push ra in allocated space

	lw $t2, 0xffff0004
	beq $t2, 0x77, respond_to_w
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x73, respond_to_s
	beq $t2, 0x64, respond_to_d
	beq $t2, 0x72, respond_to_r
	beq $t2, 0x74, respond_to_t
	beq $t2, 0x1B, respond_to_esc

	lw $ra, 4($sp) # pop ra
	add $sp, $sp, 4 # restore stack
	jr $ra

respond_to_w:
	# Sound Effect
	li $v0, 31
	addi $a0, $zero, 60
	addi $a1, $zero, 1000
	addi $a2, $zero, 120
	addi $a3, $zero, 111
	syscall
	
	move $t7, $s4		# $t7 stores original address of frog
	
	# t5 stores the first address that is outside the boundaries
	lw $t5, displayAddress
	
	addi $s4, $s4, -512 # move frog address
	
	blt $s4, $t5, setToUp
	
	respond_to_w_cont:
		addi $a0, $s4, 0 # load address of frog

		# push return address to the stack
		sub $sp, $sp, 4 # allocate space
		sw $ra, 4($sp) # push ra in allocated space
		jal drawFrog
		lw $ra, 4($sp) # pop ra
		add $sp, $sp, 4 # restore stack
	
		jr $ra
		
	setToUp:
		addi $s4, $t7, 0	# reset to original position
		j respond_to_w_cont
		
respond_to_a:
	# Sound Effect
	li $v0, 31
	addi $a0, $zero, 60
	addi $a1, $zero, 1000
	addi $a2, $zero, 120
	addi $a3, $zero, 111
	syscall
	
	addi $t7, $zero, 128	# $t7 = 128
	div $s4, $t7		# Get Row, Col
	mfhi $t5		# offset from left boundary of current row
	sub $t5, $s4, $t5	# $t5 now stores the address of the left boundary of current row
	
	addi $s4, $s4, -16 # move frog address	
	blt $s4, $t5, setToLeft
	
	respond_to_a_cont:
		addi $a0, $s4, 0 # load address of frog
	
		# push return address to the stack
		sub $sp, $sp, 4 # allocate space
		sw $ra, 4($sp) # push ra in allocated space
		jal drawFrog
		lw $ra, 4($sp) # pop ra
		add $sp, $sp, 4 # restore stack
		jr $ra
	
	setToLeft:
		addi $s4, $t5, 0
		j respond_to_a_cont
		
respond_to_s:
	# Sound Effect
	li $v0, 31
	addi $a0, $zero, 60
	addi $a1, $zero, 1000
	addi $a2, $zero, 120
	addi $a3, $zero, 111
	syscall
	
	move $t7, $s4		# $t7 stores original address of frog
	
	# t5 stores the first address that is outside the boundaries
	lw $t5, displayAddress
	addi $t5, $t5, 4092
	addi $s4, $s4, 512 # move frog address
	
	bgt $s4, $t5, setToDown

	respond_to_s_cont:
		addi $a0, $s4, 0 # load address of frog

		# push return address to the stack
		sub $sp, $sp, 4 # allocate space
		sw $ra, 4($sp) # push ra in allocated space
		jal drawFrog
		lw $ra, 4($sp) # pop ra
		add $sp, $sp, 4 # restore stack
	
		jr $ra
		
	setToDown:
		addi $s4, $t7, 0	# reset to original position
		j respond_to_s_cont
	
respond_to_d:
	# Sound Effect
	li $v0, 31
	addi $a0, $zero, 60
	addi $a1, $zero, 1000
	addi $a2, $zero, 120
	addi $a3, $zero, 111
	syscall
	
	addi $t7, $zero, 128	# $t7 = 128
	div $s4, $t7		# Get Row, Col
	mfhi $t5		# offset from left boundary of current row
	sub $t5, $s4, $t5	# $t5 now stores the address of the left boundary of current row
	addi $t5, $t5, 112	# $t5 now stores the address of the right boundary (actually -16px, the width of frog) of current row
	
	addi $s4, $s4, 16 # move frog address	
	bgt $s4, $t5, setToRight
	
	respond_to_d_cont:
		addi $a0, $s4, 0 # load address of frog
	
		# push return address to the stack
		sub $sp, $sp, 4 # push ra
		sw $ra, 4($sp) # store current return address
		jal drawFrog
		lw $ra, 4($sp) # pop ra
		add $sp, $sp, 4 # restore stack
		jr $ra
	
	setToRight:
		addi $s4, $t5, 0
		j respond_to_d_cont
		
respond_to_r:
	j start # restart the game

respond_to_t:
	j start2
	
respond_to_esc:
	j terminate # terminate the game
	

###################################################################################################################################################
# Testing Procedures
###################################################################################################################################################
displayMessage:
	li $v0 4
	la $a0, breakpoint
	syscall
	jr $ra
	
	
###################################################################################################################################################
# Non-Object Drawing Procedures
###################################################################################################################################################
drawGoal:
	# a0 = starting address (CONST), $a1 = color (CONST)
	move $t3, $a0	# set $t3 to starting address
	
	addi $t4, $zero, 128 # set $t4 to 128 as divisor
	div $t3, $t4	# divide $t3 by 128 to get quotient and remainder
	mfhi $t3	# set $t3 to remainder
	mfhi $t4	# $t4 now stores the remainder (distance from left most column to starting address) (CONST)
	sub $t3, $a0, $t3	# set $t3 to left most column of that row (CONST)
	
	# Now $t3 has the address of the left most column of that row, and $t3 + $t4 is the starting address
	
	li $s5, 3	# load height of goal
	
	add  $t5, $zero, $t4	# t5 is the column offset from left most column
	addi $t6, $zero, 0	# Loop iterator (just to keep track of row and column)
	addi $t8, $zero, 0	# Column iterator
	addi $t9, $zero, 0	# Row iterator
	
	
	while1:
		add $t2, $t3, $t5	# $t2 is the actual address wanted # $t2 = $t3 (Left Most Column Address) + $t5 (Column Offset)
		add $t2, $t2, $t9	# $t2 is the actual address wanted # $t2 = $t2 + t9 (Row Offset)
		
		sw $a1, 0($t2)		# load color $t4 into address $t3 (Printing)
		
		addi $t6, $t6, 4	# Loop iterator += 4
		
		# Iterator for column
		addi $t8, $t8, 4	# Column iterator +=4
		addi $t7, $zero, 16	# Set $t7 = 32 as divisor to get mod in next 2 lines	
		div $t8, $t7
		mfhi $t8		# $t8 = $t8 mod 32 to ensure we are printing 8 times on a row only
		
		add $t5, $t4, $t8	# offset $t5 = $t4 (original offset) + $t8 (column iterator)
		
		addi $t7, $zero, 128	# CONST $t7 = 128 to do division
		div $t5, $t7		# check overflow, if overflow, set $t5 self to remainder
		mfhi $t5
			
		# check if we have printed 8 times (finished the current row)
		addi $t7, $zero, 32	# CONST $t7 = 32	
		div $t6, $t7		# Divide by 32 to get the quotient (how many rows printed so far) and remainder (how far to the right we are printing)
				
		mflo $t9		# Load the current cycle (quotient) in $t9
		bgt $t9, $s5, exit1	# exit program if we reach the height of row $t5
		
		mul $t9, $t9, 128	# row offset $t9 = 128 times column
		
		j while1
	
	exit1:		
		jr $ra
		
		
drawRectWidth:	# Used for drawing different areas
	# a0 = color, a1 = starting address, a2 = height
	addi $t6, $zero, 0	# iterator
	addi $t8, $zero, 0	# i = 0 (current column / 32)
	addi $t9, $zero, 0	# cycle j (current row)	
	while:
		sw $a0, 0($a1)		# load color $a0 into address $a1 (Printing)
		
		addi $t6, $t6, 4	# iterator += 4
		add $a1, $a1, 4		# address += 4
				
		addi $t7, $zero, 128	# CONST $t7 = 128	
		div $t6, $t7		# Divide by 128 to get the quotient (how many rows printed so far) and remainder (how far to the right we are printing)		
		mfhi $t8		# Load the remainder $t8, which makes 0 <= $t8 < 128
		mflo $t9		# Load the current cycle (quotient) in $t9
		
		bgt $t9, $a2, exit
		
		j while
	
	exit:		
		jr $ra
		
		
gameOver: # a0 = starting address (CONST), $a1 = color (CONST)
	lw $a0, displayAddress
	li $a1, 0xFFFF00
	
	move $t3, $a0	# set $t3 to starting address
	
	addi $t4, $zero, 128 # set $t4 to 128 as divisor
	div $t3, $t4	# divide $t3 by 128 to get quotient and remainder
	mfhi $t3	# set $t3 to remainder
	mfhi $t4	# $t4 now stores the remainder (distance from left most column to starting address) (CONST)
	sub $t3, $a0, $t3	# set $t3 to left most column of that row (CONST)
	
	# Now $t3 has the address of the left most column of that row, and $t3 + $t4 is the starting address
	
	li $s5, 32	# load height of screen
	
	add  $t5, $zero, $t4	# t5 is the column offset from left most column
	addi $t6, $zero, 0	# Loop iterator (just to keep track of row and column)
	addi $t8, $zero, 0	# Column iterator
	addi $t9, $zero, 0	# Row iterator
	
	
	while4:
		add $t2, $t3, $t5	# $t2 is the actual address wanted # $t2 = $t3 (Left Most Column Address) + $t5 (Column Offset)
		add $t2, $t2, $t9	# $t2 is the actual address wanted # $t2 = $t2 + t9 (Row Offset)
		
		sw $a1, 0($t2)		# load color $t4 into address $t3 (Printing)
		
		addi $t6, $t6, 4	# Loop iterator += 4
		
		# Iterator for column
		addi $t8, $t8, 4	# Column iterator +=4
		addi $t7, $zero, 128	# Set $t7 = 32 as divisor to get mod in next 2 lines	
		div $t8, $t7
		mfhi $t8		# $t8 = $t8 mod 32 to ensure we are printing 8 times on a row only
		
		add $t5, $t4, $t8	# offset $t5 = $t4 (original offset) + $t8 (column iterator)
		
		addi $t7, $zero, 128	# CONST $t7 = 128 to do division
		div $t5, $t7		# check overflow, if overflow, set $t5 self to remainder
		mfhi $t5
			
		# check if we have printed 8 times (finished the current row)
		addi $t7, $zero, 128	# CONST $t7 = 32	
		div $t6, $t7		# Divide by 32 to get the quotient (how many rows printed so far) and remainder (how far to the right we are printing)
				
		mflo $t9		# Load the current cycle (quotient) in $t9
		bgt $t9, $s5, exit4	# exit program if we reach the height of row $t5
		
		mul $t9, $t9, 128	# row offset $t9 = 128 times column
		
		j while4
	
	exit4:		
		# load variables
		lw $t0, displayAddress # displayAddress
		li $t2 0x0000FF	# blue color to $t1
		li $t1 0xFF0000 # red color for heart to $t2
	
		# G
		sw  $t1, 0($t0)
		sw  $t1, 4($t0)
		sw  $t1, 8($t0)
		sw  $t1, 12($t0)
		sw  $t1, 16($t0)
		sw  $t1, 128($t0)
		sw  $t1, 256($t0)
		sw  $t1, 384($t0)
		sw  $t1, 512($t0)
		sw  $t1, 516($t0)
		sw  $t1, 520($t0)
		sw  $t1, 524($t0)
		sw  $t1, 528($t0)
		sw  $t1, 400($t0)
		sw  $t1, 272($t0)
		sw  $t1, 268($t0)
		sw  $t1, 264($t0)
	
	
		# A
		sw  $t1, 28($t0)
		sw  $t1, 156($t0)
		sw  $t1, 284($t0)
		sw  $t1, 288($t0)
		sw  $t1, 292($t0)
		sw  $t1, 296($t0)
		sw  $t1, 412($t0)
		sw  $t1, 540($t0)
		sw  $t1, 32($t0)
		sw  $t1, 36($t0)
		sw  $t1, 40($t0)
		sw  $t1, 44($t0)
		sw  $t1, 172($t0)
		sw  $t1, 300($t0)
		sw  $t1, 428($t0)
		sw  $t1, 556($t0)
		
		
		# M
		sw  $t1, 56($t0)
		sw  $t1, 184($t0)
		sw  $t1, 312($t0)
		sw  $t1, 440($t0)
		sw  $t1, 568($t0)
		sw  $t1, 60($t0)
		sw  $t1, 64($t0)
		sw  $t1, 192($t0)
		sw  $t1, 320($t0)
		sw  $t1, 448($t0)
		sw  $t1, 576($t0)
		sw  $t1, 68($t0)
		sw  $t1, 72($t0)
		sw  $t1, 200($t0)
		sw  $t1, 328($t0)
		sw  $t1, 456($t0)
		sw  $t1, 584($t0)

		# E
		sw  $t1, 84($t0)
		sw  $t1, 88($t0)
		sw  $t1, 92($t0)
		sw  $t1, 96($t0)
		sw  $t1, 100($t0)
		sw  $t1, 212($t0)
		sw  $t1, 268($t0)
		sw  $t1, 340($t0)
		sw  $t1, 344($t0)
		sw  $t1, 348($t0)
		sw  $t1, 352($t0)
		sw  $t1, 356($t0)
		sw  $t1, 468($t0)
		sw  $t1, 596($t0)
		sw  $t1, 600($t0)
		sw  $t1, 604($t0)
		sw  $t1, 608($t0)
		sw  $t1, 612($t0)

		# O
		sw  $t1, 792($t0)
		sw  $t1, 920($t0)
		sw  $t1, 936($t0)
		sw  $t1, 1048($t0)
		sw  $t1, 1304($t0)
		sw  $t1, 796($t0)
		sw  $t1, 800($t0)
		sw  $t1, 804($t0)
		sw  $t1, 808($t0)
		sw  $t1, 1176($t0)
		sw  $t1, 1064($t0)
		sw  $t1, 1192($t0)
		sw  $t1, 1308($t0)
		sw  $t1, 1312($t0)
		sw  $t1, 1316($t0)
		sw  $t1, 1320($t0)
		
		# V
		sw  $t1, 820($t0)
		sw  $t1, 836($t0)
		sw  $t1, 948($t0)
		sw  $t1, 960($t0)
		sw  $t1, 1076($t0)
		sw  $t1, 1084($t0)
		sw  $t1, 1204($t0)
		sw  $t1, 1208($t0)
		sw  $t1, 1332($t0)
		
		# E
		sw  $t1, 848($t0)
		sw  $t1, 852($t0)
		sw  $t1, 856($t0)
		sw  $t1, 860($t0)
		sw  $t1, 864($t0)
		sw  $t1, 976($t0)
		sw  $t1, 1104($t0)
		sw  $t1, 1108($t0)
		sw  $t1, 1112($t0)
		sw  $t1, 1116($t0)
		sw  $t1, 1120($t0)
		sw  $t1, 1232($t0)
		sw  $t1, 1360($t0)
		sw  $t1, 1364($t0)
		sw  $t1, 1368($t0)
		sw  $t1, 1372($t0)
		sw  $t1, 1376($t0)
		
		# R
		sw  $t1, 872($t0)
		sw  $t1, 1000($t0)
		sw  $t1, 1128($t0)
		sw  $t1, 1132($t0)
		sw  $t1, 1136($t0)
		sw  $t1, 884($t0)
		sw  $t1, 1016($t0)
		sw  $t1, 1140($t0)
		sw  $t1, 1144($t0)
		sw  $t1, 1256($t0)
		sw  $t1, 1384($t0)
		sw  $t1, 1268($t0)
		sw  $t1, 1400($t0)
		sw  $t1, 876($t0)
		sw  $t1, 880($t0)
		sw  $t1, 884($t0)
		sw  $t1, 888($t0)
	
		jr $ra
		
drawLives:
	# load variables
	lw $t0, displayAddress # displayAddress
	li $t1 0x0000FF	# blue color to $t1
	li $t2 0xFF0000 # red color for heart to $t2
	
	# L
	sw  $t1, 0($t0)
	sw  $t1, 128($t0)
	sw  $t1, 256($t0)
	sw  $t1, 384($t0)
	sw  $t1, 388($t0)
	sw  $t1, 392($t0)
	
	# I
	sw  $t1, 16($t0)
	sw  $t1, 144($t0)
	sw  $t1, 272($t0)
	sw  $t1, 400($t0)
	
	# V
	sw  $t1, 28($t0)
	sw  $t1, 156($t0)
	sw  $t1, 284($t0)
	sw  $t1, 412($t0)
	sw  $t1, 288($t0)
	sw  $t1, 164($t0)
	sw  $t1, 40($t0)
	
	# E
	sw  $t1, 48($t0)
	sw  $t1, 176($t0)
	sw  $t1, 304($t0)
	sw  $t1, 432($t0)
	sw  $t1, 52($t0)
	sw  $t1, 56($t0)
	sw  $t1, 180($t0)
	sw  $t1, 184($t0)
	sw  $t1, 436($t0)
	sw  $t1, 440($t0)
	
	# S
	sw  $t1, 72($t0)
	sw  $t1, 200($t0)
	sw  $t1, 328($t0)
	sw  $t1, 456($t0)
	sw  $t1, 452($t0)
	sw  $t1, 448($t0)
	sw  $t1, 76($t0)
	sw  $t1, 80($t0)
	
	# Draw lives:
	addi $t1, $zero, 1 # For loop index iterator
	drawLivesLoop:
		lw $t3, lives		# load how many lives left from the memory			
	
		# Draw a red box to represent one life
		sw $t2, 216($t0)	
		sw $t2, 220($t0)
		sw $t2, 344($t0)
		sw $t2, 348($t0)
	
		addi $t0, $t0, 12	# Add offset to draw next life (if any) in the next loop
		
		addi $t1, $t1, 1 	# For loop index iterator
		bgt $t1, $t3, ExitDrawHeart
		
		j drawLivesLoop
	
	ExitDrawHeart:
		jr $ra
		
		
