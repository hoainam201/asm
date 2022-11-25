.data

    # the number of characters to read
    # extra 2 for newline character and \0
    numChars: .word	12

    # space to store user input
    input:	  .space 12

    # User prompt to enter values
    prompt:   .asciiz "Please enter an integer > "

    #Overflow Message
    overFlowMess:   .asciiz "\nOverflow!!!!Try again\n"
.text

main:

    ##########
    #  Read user input
    ##########

    # Prepare to print the prompt
    li $v0, 4
    la $a0, prompt
    syscall

    # Prepare for read string system call
    #
    # Prep $a0:  address to read to
    la $a0, input
    la $a1, numChars
    lw $a1, 0($a1)

    # Execute read string system call
    li $v0, 8
    syscall

    add $s0, $zero, $a0 #$s0 = numChars
    addi $s1, $zero, 0  #i = 0
    loop1:
        lb $a0, 0($s0)  #load numChars[i]
        beq $a0, $zero, itob  # if numChars[i] = '\0' = 0 then print
        addi $t0, $zero, 10     # $t0 = 10 = '\n'
        beq $a0, $t0, itob    # if numChars[i] = '\n' then print
        addi $a2, $a0, -48      # convert ascii to decimal by adding -48
        addi	$t3, $zero, 429496730			# $t3 = 2^32 / 10
        slt		$t4, $s1, $t3		# $t4 = (i < 2^32 / 10) ? 1 : 0
        beq		$t4, $zero, overFlow	# if i > 2^32 / 10 then overFlow
        mul $t1, $t0, $s1   #j = i*10
        add $t1, $t1, $a2   #j = j + $a2
        slt		$t2, $s1, $t1		# $t2 = ($s1 < $t1) ? 1 : 0
        beq		$t2, $zero, overFlow	# if $s1 > $t1 then overFlow
        add		$s1, $zero, $t1		# i = j
        add $a0, $zero, $a2
        addi $s0, $s0, 1    #i++
        j loop1
    overFlow:   
        li $v0, 4
        la $a0, overFlowMess
        syscall
        j main
	itob:
		move $t2, $s1
		li $s1, 32         # Set up a loop counter
		Loop:
			rol $t2, $t2, 1    # Roll the bits left by one bit - wraps highest bit to lowest bit.
			and $t0, $t2, 1    # Mask off low bit (logical AND with 000...0001)
			add $t0, $t0, 48   # Combine it with ASCII code for '0', becomes 0 or 1 

			move $a0, $t0      # Output the ASCII character
			li $v0, 11
			syscall

			addi $s1, $s1, -1   # Decrement loop counter
			bne $s1, $zero, Loop  # Keep looping if loop counter is not zero

		

		jump:
		li $v0, 10 #system call for exit
		syscall

    
    
    
