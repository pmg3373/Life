.data
# CONSTANTS
#
# syscall codes
PRINT_INT = 	1
PRINT_STRING = 	4
READ_INT = 		5
MEM_ALLOC = 	9
EXIT = 			10
PRINT_CHAR = 	11

MAX_RULE = 255
MAX_GENS = 25
MAX_WIDTH = 70

	header_1: 
			.asciiz "*****************************************\n"
	header_2:
			.asciiz "**     Cellular Automata Simulator     **\n"
	header_3:
			.asciiz "*****************************************\n"
	header_4:
			.asciiz	"\n"

	invalid_rule:
			.asciiz "Invalid rule number, cell-auto-sim terminating\n"
	invalid_num_gen:
			.asciiz	"Invalid generation number, cell-auto-sim terminating\n"
	invalid_row_size:
			.asciiz "Invalid row size, cell-auto-sim terminating\n"
	illegal_input:
			.asciiz "Illegal input value, cell-auto-sim terminating\n"
	rule_banner:
			.asciiz "Rule "
	life_driver_arguments:
			.word 0
			.word 0
			.word 0
			.space 70
	life_driver_prev_step:
			.space 70
	life_driver_current_step:
			.space 70
	life_step_current_step:
			.space 70
	life_step_prev_step:
			.space 70
	
	
.text
.align 2

.globl main


#
# Name:		MAIN PROGRAM
#
# Description:	Main logic for the program.
#
#	This program runs a 2d conways game of life. The first number is the
#	rule number. The second is the number of generations to simulate. The third
#	is the width of each row. Then a number of ones and zeros equal to the row
#	width. This is the initial row.
#

main:
	addi	$sp, $sp, -28				#Func Setup
	sw	$ra, 24($sp)	
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	addi	$v0, $zero, READ_INT
	addi	$t0, $zero, MAX_RULE
	syscall
	slt	$t1, $v0, $zero
	slt	$t2, $t0, $v0
	add	$t3, $t1, $t2
	beq	$t3, $zero, main_rule_good
	la	$a0, invalid_rule
	addi	$v0, $zero, PRINT_STRING
	syscall
	addi	$v0, $zero, EXIT
	syscall
main_rule_good:
	addi	$s0, $v0, 0
	
	
	addi	$v0, $zero, READ_INT
	addi	$t0, $zero, MAX_GENS
	syscall
	slt	$t1, $v0, $zero
	slt	$t2, $t0, $v0
	add	$t3, $t1, $t2
	beq	$t3, $zero, main_gens_good
	la	$a0, invalid_num_gen
	addi	$v0, $zero, PRINT_STRING
	syscall
	addi	$v0, $zero, EXIT
	syscall
main_gens_good:
	addi	$s1, $v0, 1

	
	addi	$v0, $zero, READ_INT
	addi	$t0, $zero, MAX_WIDTH
	syscall
	slti	$t1, $v0, 1
	slt	$t2, $t0, $v0
	add	$t3, $t1, $t2
	beq	$t3, $zero, main_rows_good
	la	$a0, invalid_row_size
	addi	$v0, $zero, PRINT_STRING
	syscall
	addi	$v0, $zero, EXIT
	syscall
main_rows_good:
	addi	$s2, $v0, 0
	
	la	$s3, life_driver_arguments
	sw	$s0, 0($s3)
	sw	$s1, 4($s3)
	sw	$s2, 8($s3)
	
	addi	$t0, $zero, 0						#loop counter
	addi	$t1, $zero, 1						#constant 1
	addi	$t2, $s3, 12						#write location of bytes
main_read_values_loop_begin:
	addi	$v0, $zero, READ_INT
	syscall
	beq	$v0, $zero, read_values_valid
	beq	$v0, $t1, read_values_valid
	la	$a0, illegal_input
	addi	$v0, $zero, PRINT_STRING
	syscall
	addi	$v0, $zero, EXIT
	syscall
read_values_valid:
	sb	$v0, 0($t2)
	addi	$t2, $t2, 1
	addi	$t0, $t0, 1
	beq	$t0, $s2, main_read_values_loop_end
	j main_read_values_loop_begin
	
main_read_values_loop_end:
	addi	$a0, $s2, 0
	addi	$a1, $s0, 0
	jal	life_print_header
	
	addi	$a0, $s3, 0
	jal	life_driver
	
	addi	$a0, $s2, 0
	jal	life_print_scale
	
	lw 	$ra, 24($sp)			#Func Tear Down
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 28   	
	jr 	$ra	


# 
# Name:		life_print_line
#
# Description:	Prints one line of the life game
#
# Arguments:	
#				a0 Address of the generation line
#				a1 The generation number
#				a2 Width of the board
# Returns:	None
#
life_print_line:
	addi	$sp, $sp, -28				#Func Setup
	sw	$ra, 24($sp)	
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	addi	$s0, $a0, 0
	addi	$s1, $a1, 0
	addi	$s2, $a2, 0
	slti	$t1, $s1, 10
	addi	$t2, $zero, 0
	beq	$t1, $zero, life_print_line_gen_no_space
	
	addi	$a0, $zero, 32				#(sp)
	addi	$v0, $zero, PRINT_CHAR
	syscall	
	addi	$a0, $s1, 0
	addi	$v0, $zero, PRINT_INT
	syscall
	addi	$a0, $zero, 32				#(sp)
	addi	$v0, $zero, PRINT_CHAR
	syscall	
	j	life_print_line_loop_begin
	
life_print_line_gen_no_space:
	addi	$a0, $s1, 0
	addi	$v0, $zero, PRINT_INT
	syscall
	addi	$a0, $zero, 32				#(sp)
	addi	$v0, $zero, PRINT_CHAR
	syscall	
	
life_print_line_loop_begin:
	add	$t0, $s0, $t2
	lb	$a0, 0($t0)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	addi	$t2, $t2, 1
	bne	$t2, $s2, life_print_line_loop_begin
	
	addi	$a0, $zero, 10				#(nl)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	
	lw 	$ra, 24($sp)			#Func Tear Down
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 28   	
	jr 	$ra
	
# 
# Name:		life_print_header
#
# Description:	Prints the results of the life generations
#
# Arguments:	
#				a0: Width of the board
#				a1: Rule Number
# Returns:	None
#
life_print_header:
	addi	$sp, $sp, -28				#Func Setup
	sw	$ra, 24($sp)	
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	addi	$s0, $a0, 0						#Width of the board
	addi	$s1, $a1, 0						#Rule Number
	
	la	$a0, header_1
	addi	$v0, $zero, PRINT_STRING
	syscall
	la	$a0, header_2
	addi	$v0, $zero, PRINT_STRING
	syscall
	la	$a0, header_3
	addi	$v0, $zero, PRINT_STRING
	syscall
	la	$a0, header_4
	addi	$v0, $zero, PRINT_STRING
	syscall
	
	
	la	$a0, rule_banner
	addi	$v0, $zero, PRINT_STRING		#Rule(sp)
	syscall
	addi	$a0, $s1, 0
	addi	$v0, $zero, PRINT_INT
	syscall
	addi	$a0, $zero, 32				#(sp)
	addi	$v0, $zero, PRINT_CHAR
	syscall	
	addi	$a0, $zero, 40				#(
	addi	$v0, $zero, PRINT_CHAR
	syscall
	
	addi	$a0, $s1, 0
	addi	$a1, $zero, 8
	jal	print_int_as_bin
	
	addi	$a0, $zero, 41				#)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	addi	$a0, $zero, 10				#(nl)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	
	addi	$a0, $s0, 0
	jal life_print_scale
	
	lw 	$ra, 24($sp)			#Func Tear Down
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 28   	
	jr 	$ra	

	

# 
# Name:		life_print_scale
#
# Description:	Prints out the scale
#
# Arguments:	a0 width of the board
# Returns:	none
#
life_print_scale:
	addi	$sp, $sp, -28				#Func Setup
	sw	$ra, 24($sp)	
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	addi	$t0, $zero, 0
	addi	$t1, $zero, 0
	addi	$t2, $zero, 4
	addi	$t3, $zero, 9
	addi	$s0, $a0, 0
	
	addi	$a0, $zero, 32				#(sp)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	addi	$a0, $zero, 32				#(sp)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	addi	$a0, $zero, 32				#(sp)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	
life_print_scale_begin_loop:
	beq	$t1, $t2, life_print_scale_plus
	beq	$t1, $t3, life_print_scale_zero
	
	addi	$a0, $zero, 45				#-
	addi	$v0, $zero, PRINT_CHAR
	syscall
	addi	$t0, $t0, 1
	addi	$t1, $t1, 1
	beq	$t0, $s0, life_print_scale_done
	j	life_print_scale_begin_loop
life_print_scale_zero:
	addi	$a0, $zero, 48				#0
	addi	$v0, $zero, PRINT_CHAR
	syscall
	addi	$t0, $t0, 1
	addi	$t1, $zero, 0
	beq	$t0, $s0, life_print_scale_done
	j	life_print_scale_begin_loop
	
life_print_scale_plus:
	addi	$a0, $zero, 43				#+
	addi	$v0, $zero, PRINT_CHAR
	syscall
	addi	$t0, $t0, 1
	addi	$t1, $t1, 1
	beq	$t0, $s0, life_print_scale_done
	j	life_print_scale_begin_loop
	
life_print_scale_done:
	addi	$a0, $zero, 10				#(nl)
	addi	$v0, $zero, PRINT_CHAR
	syscall
	
	lw 	$ra, 24($sp)			#Func Tear Down
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 28   	
	jr 	$ra	
	
# 
# Name:		print_int_as_bin
#
# Description:	Prints an int in binary
#
# Arguments:	a0 Integer to print
#				a1 Number of bits to print
# Returns:	None
#
print_int_as_bin:
	addi	$sp, $sp, -28				#Func Setup
	sw	$ra, 24($sp)	
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	addi	$s0, $a0, 0
	addi	$s1, $a1, 0
	addi	$t0, $zero, 1
	addi	$t1, $zero, 0
	addi	$t2, $s1, -1
	sllv	$t0, $t2
print_int_as_bin_loop_begin:
	and	$t3, $t0, $s0
	beq	$t3, $zero, print_int_as_bin_zero
	addi	$a0, $zero, 49				#1
	addi	$v0, $zero, PRINT_CHAR
	syscall
	sll	$s0, $s0, 1
	addi	$t1, $t1, 1
	beq	$t1, $s1, print_int_as_bin_done
	j print_int_as_bin_loop_begin
print_int_as_bin_zero:
	addi	$a0, $zero, 48				#0
	addi	$v0, $zero, PRINT_CHAR
	syscall
	sll	$s0, $s0, 1
	addi	$t1, $t1, 1
	beq	$t1, $s1, print_int_as_bin_done
	j print_int_as_bin_loop_begin
	
print_int_as_bin_done:
	lw 	$ra, 24($sp)			#Func Tear Down
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 28   	
	jr 	$ra	
	
	

# 
# Name:		life_driver
#
# Description:	Prints out each line of the generation sequence
#
# Arguments:	a0 Address of arguement memory block
#				Format:
#				Word: Rule Number
#				Word: Number of generations
#				Word: Width of the board
#				Bytes (1-70): Initial line, each byte is either zero or one
# Returns:	None
#
life_driver:
	addi	$sp, $sp, -36				#Func Setup
	sw	$ra, 32($sp)	
	sw	$s7, 28($sp)
	sw	$s6, 24($sp)
	sw	$s5, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	lw	$s0, 0($a0)						#Rule Number
	lw	$s1, 4($a0)						#Number of Gens
	lw	$s2, 8($a0)						#Width
	addi	$s3, $a0, 12				#Address of line 1
	la	$s4, life_driver_current_step	#Current Step
	la	$s5, life_driver_prev_step		#Prev Step
	addi	$s6, $zero, 0				#loop counter
	la	$s7, life_step_current_step		#current rule step
	
	addi	$t0, $zero, 1
	beq	$t0, $s2, life_driver_one_wide	#Special case to prevent errors
	
	addi	$t0, $zero, 46				#Period is 46
	addi	$t1, $zero, 0
	
life_driver_init_loop:
	add	$t2, $t1, $s5
	sb	$t0, 0($t2)
	add	$t2, $t1, $s3
	lb	$t3, 0($t2)
	add	$t2, $t1, $s7
	sb	$t3, 0($t2)
	addi	$t1, $t1, 1
	bne	$t1, $s2, life_driver_init_loop
	
	
life_driver_gen_loop:
	addi	$t0, $zero, 0				#Line Loop Counter
life_driver_line_loop:
	add	$t1, $t0, $s7
	lb	$t2, 0($t1)
	beq	$t2, $zero, life_driver_line_dead
	add	$t1, $s5, $t0					#current byte, prev gen
	lb	$t3, 0($t1)
	slti	$t3, $t3, 65
	beq	$t3, $zero, life_driver_line_alive_again
	
	addi	$t2, $zero, 65				#Capital A is 65
	add	$t3, $s4, $t0				#current byte, current gen
	sb	$t2, 0($t3)
	add	$t3, $s5, $t0				#current byte, prev gen
	sb	$t2, 0($t3)
	addi	$t0, $t0, 1
	bne	$t0, $s2, life_driver_line_loop
	j life_driver_line_done
	
life_driver_line_alive_again:
	add	$t1, $s5, $t0					#current byte, prev gen
	lb	$t2, 0($t1)
	addi	$t2, $t2, 1					
	sb	$t2, 0($t1)
	add	$t1, $s4, $t0					#current byte, current gen
	sb	$t2, 0($t1)
	addi	$t0, $t0, 1
	bne	$t0, $s2, life_driver_line_loop
	j life_driver_line_done
	
life_driver_line_dead:
	addi	$t2, $zero, 46				#Period is 46
	add	$t3, $s4, $t0				#current byte, current gen
	sb	$t2, 0($t3)
	add	$t3, $s5, $t0				#current byte, prev gen
	sb	$t2, 0($t3)
	addi	$t0, $t0, 1
	bne	$t0, $s2, life_driver_line_loop
	j life_driver_line_done

life_driver_line_done:
	addi	$a0, $s4, 0
	addi	$a1, $s6, 0 
	addi	$a2, $s2, 0
	jal	life_print_line
	addi	$a0, $s7, 0
	addi	$a1, $s0, 0
	addi	$a2, $s2, 0
	jal life_step
	addi	$s7, $v0, 0
	addi	$s6, $s6, 1
	bne	$s6, $s1, life_driver_gen_loop
	j life_driver_done
	
	
	
life_driver_one_wide:
	lb	$t2, 0($s3)						
	beq	$t2, $zero, life_driver_one_wide_zero
	addi	$t2, $zero, 65				#Capital A is 65
life_driver_one_wide_one:
	sb	$t2, 0($s4)
	addi	$s4, $s4, 1
	addi	$s5, $s5, 1
	beq	$s5, $s2, life_driver_done
	j life_driver_one_wide_one
life_driver_one_wide_zero:
	addi	$t2, $zero, 46				#Period is 46
	sb	$t2, 0($s4)
	addi	$s4, $s4, 1
	addi	$s5, $s5, 1
	beq	$s5, $s2, life_driver_done
	j life_driver_one_wide_zero
	
	
	
life_driver_done:
	lw 	$ra, 32($sp)			#Func Tear Down
	lw	$s7, 28($sp)
	lw	$s6, 24($sp)
	lw	$s5, 20($sp)
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 36   	
	jr 	$ra	



# 
# Name:		life_step
#
# Description:	Performs one interation of the game of life, setting the values
#			in memory and returning the address of the space used
#
# Arguments:	a0 Address of the current board state
#   		a1 The Rule being used as an int
#			a2 Width of the game board
# Returns:	v0 Address of the next line
#
life_step:
	addi	$sp, $sp, -24				#Func Setup
	sw	$ra, 20($sp)	
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	addi	$s0, $a0, 0					#Current state address
	addi	$s1, $a1, 0					#Rule number
	addi	$s2, $a2, 0					#Width of the board
	addi	$s3, $zero, 0				#Loop Counter
	la	$s4, life_step_current_step		#Next Board State

	la	$t0, life_step_prev_step
	addi	$t1, $zero, 0
life_step_init:
	add	$t3, $t1, $s0
	lb	$t2, 0($t3)
	add	$t3, $t1, $t0
	sb	$t2, 0($t3)
	addi	$t1, $t1, 1
	bne	$t1, $s2, life_step_init
	addi	$s0, $t0, 0
	

life_step_loop_begin:
	
	addi	$a0, $s0, 0
	addi	$a1, $s3, 0
	addi	$a2, $s2, 0
	jal	life_rule
	
	addi	$t0, $zero, 1
	sllv	$t0, $t0, $v0			#Shift to corrisponding bit of rule number
	and	$t0, $t0, $s1				#Did we live?
	srlv	$t0, $t0, $v0			#Shift back to save number normally
	
	add	$t1, $s4, $s3				
	sb	$t0, 0($t1)					
	
	addi	$s3, $s3, 1
	bne	$s3, $s2, life_step_loop_begin

life_step_loop_end:	
	
	addi	$v0, $s4, 0
	lw 	$ra, 20($sp)			#Func Tear Down
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 24   	
	jr	$ra		
	

# 
# Name:		life_rule
#
# Description:	Determines what life rule to apply to a byte
#
# Arguments:	a0 Pointer to the location of the board
#   		a1 The number of the byte to examine
#			a2 Width of the game board
# Returns:	v0 The rule number as an int
#
life_rule:
	addi	$sp, $sp, -24				#Func Setup
	sw	$ra, 20($sp)	
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	
	addi $s0, $a0, 0			#Board location
	addi $s1, $a1, 0			#Byte number
	addi $s2, $a2, -1			#need to adjust to do zero indexed math
	add	$t0, $s0, $s1			#Address of byte to read
	
	beq	$s1, $zero, life_rule_zero_case
	beq	$s1, $s2, life_rule_max_case

	lb	$t1, -1($t0)			#Byte to left
	sll	$t1, $t1, 2
	
	lb	$t2, 0($t0)				#Byte being examined
	sll	$t2, $t2, 1
	
	lb	$t3, 1($t0)				#Byte to right
	
	or	$v0, $t1, $t2
	or	$v0, $v0, $t3
	
	j	life_rule_done
	
life_rule_zero_case:

	add	$t4, $s0, $s2
	lb	$t1, 0($t4)				#Byte to left, wrap to end
	sll	$t1, $t1, 2
	
	lb	$t2, 0($t0)				#Byte being examined
	sll	$t2, $t2, 1
	
	lb	$t3, 1($t0)				#Byte to right
	
	add	$v0, $t1, $t2
	add	$v0, $v0, $t3
	j	life_rule_done
	
life_rule_max_case:
	
	lb	$t1, -1($t0)			#Byte to left
	sll	$t1, $t1, 2
	
	lb	$t2, 0($t0)				#Byte being examined
	sll	$t2, $t2, 1
	
	lb	$t3, 0($s0)				#Byte to right, wrap to first bit
	
	add	$v0, $t1, $t2
	add	$v0, $v0, $t3
	j	life_rule_done
	
	
life_rule_done:
	
	lw 	$ra, 20($sp)			#Func Tear Down
	lw	$s4, 16($sp)
	lw	$s3, 12($sp)
	lw	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 24   	
	jr	$ra		
	