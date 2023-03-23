# Towers of Hanoi
# 12/8/2020 - Written by Gabriel Lapolla
		.data
# Make space for four 32-bit integer arguements
args:	.space 128
# Store text to be printed
Prompt:	.asciiz	"Please enter the number of disks: "
Start:	.asciiz	"Start with "
pegA:	.asciiz	" on peg A.\n"
Move:	.asciiz "Move disk from "
To:	.asciiz " to "
A:	.asciiz	"A"
B:	.asciiz	"B"
C:	.asciiz	"C"
Period:	.asciiz ".\n"
	.text

# A macro to push a value onto the stack
.macro push(%x)
	addiu 	$sp, 	$sp, 	-4	# Allocate space
	sw 	%x, 	($sp)
.end_macro
	
# A macro to pop a value from the stack
.macro pop(%x)
	lw 	%x, 	($sp)
	addiu 	$sp, 	$sp, 	4	# Free space
.end_macro

# A macro to print "Move disk from 'source' to 'dest'
.macro printMove
	li	$v0,	4
	la	$a0,	Move
	syscall
	
	# Print correct source letter
	bne	$t1,	$t5,	skipA
	la	$a0,	A	
	skipA:
	bne	$t1,	$t6,	skipB
	la	$a0,	B
	skipB:
	bne	$t1,	$t7,	skipC
	la	$a0,	C
	skipC:
	syscall
	
	la	$a0,	To
	syscall
	
	# Print correct dest letter
	bne	$t2	$t5,	skipA2
	la	$a0,	A	
	skipA2:
	bne	$t2,	$t6,	skipB2
	la	$a0,	B
	skipB2:
	bne	$t2,	$t7,	skipC2
	la	$a0,	C
	skipC2:
	syscall
	
	la	$a0,	Period
	syscall
.end_macro

main:
	badIn:
	# Prompt user
	li	$v0,	4
	la	$a0,	Prompt
	syscall
	
	# Get user input and store in $s0
	li	$v0,	5
	syscall
	move	$s0,	$v0
	beq	$s0,	$zero,	badIn
	
	# Put user input into args space
	la	$s1,	args
	sw	$s0,	($s1)
	
	# Print starting conditions
	li	$v0,	4
	la	$a0,	Start
	syscall
	li	$v0,	1
	move	$a0,	$s0,
	syscall
	li	$v0,	4
	la	$a0,	pegA
	syscall
	
	# Set initial values for source, dest, and temp
	la	$a1,	args
	addi	$a1,	$a1,	32	# Address of A (source)
	addi	$a2,	$a1,	64	# Address of C (dest)
	addi	$a3,	$a1,	32	# Address of B (temp)
	
	# Pass number of rings to function 
	move	$a0,	$s0
	jal hanoi
	
	# End the program
	li 	$v0, 	10
	syscall
###############################################################################
# public static void hanoi(int n, char source, char dest, char temp) {
#        if (n == 1) {
#             System.out.println("Move disk from " + source + " to " + dest);
#         } else {
#             hanoi(n - 1, source, temp, dest);
#             System.out.println("Move disk from " + source + " to " + dest);
#             hanoi(n - 1, temp, dest, source);
#         }
#     }	
###############################################################################
# Simulates the Towers of Hanoi algorithm
hanoi:
	# $t0 holds the number of rings (n), $t1 holds the source address, 
	# $t2 holds the desired destination address, $t3 holds a temp address
	push($ra)
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	move	$t0,	$a0
	move	$t1,	$a1
	move	$t2,	$a2
	move	$t3,	$a3
	
	la	$t4,	args		# Base address
	addi	$t5,	$t4,	32	# Address of A
	addi	$t6,	$t5,	32	# Address of B
	addi	$t7,	$t6,	32	# Address of C
	
	li	$t4,	1
	
	# if(n == 1)
	bne	$t0,	$t4,	else
	
	printMove
	
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	pop($ra)
	jr $ra
	
	else:
	# hanoi(n - 1, source, temp, dest)
	addi	$a0,	$t0,	-1	# n - 1
	move	$a1,	$t1		# source
	move	$a2,	$t3		# temp	
	move	$a3,	$t2		# dest
	jal hanoi
	
	printMove
	
	# hanoi(n - 1, temp, dest, source)
	addi	$a0,	$t0,	-1	# n - 1
	move	$a1,	$t3		# temp
	move	$a2,	$t2		# dest	
	move	$a3,	$t1		# source
	jal hanoi
	
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	pop($ra)
	jr $ra
