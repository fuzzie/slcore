# slrt.s: this file is part of the SL toolchain.
#
# Copyright (C) 2009 The SL project
#
# This program is free software, you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 2
# of the License, or (at your option) any later version.
#
# The complete GNU General Public Licence Notice can be found as the
# `COPYING' file in the root directory.
#

	.text
	.ent _start
	.globl _start
_start:
	#MTREG_SET: $l16,$l17
	.registers 0 0 31 0 0 31
	ldgp $l29, 0($l27)
	ldfp $l30
	
	# initialize slr data pointer:
        ldq $l0,__slr_base($l29) !literal
	stq $l16,0($l0)

	# initialize fibre data pointer:
	ldq $l0,__fibre_base($l29) !literal
	stq $l17,0($l0)

	mov $l30, $l15 # set up frame pointer
	clr $l9 # flush callee-save reg
	clr $l10 # flush callee-save reg
	clr $l11 # flush callee-save reg
	clr $l12 # flush callee-save reg
	clr $l13 # flush callee-save reg
	clr $l14 # flush callee-save reg
	fclr $lf2 # flush callee-save reg
	fclr $lf3 # flush callee-save reg
	fclr $lf4 # flush callee-save reg
	fclr $lf5 # flush callee-save reg
	fclr $lf6 # flush callee-save reg
	fclr $lf7 # flush callee-save reg
	fclr $lf8 # flush callee-save reg
	fclr $lf9 # flush callee-save reg
	fclr $lf0 # init FP return reg

	# initialize argc and argv for main()
	lda $l16,1($l31)
	ldq $l17,__pseudo_argv($l29) !literal
	ldq $l18,__pseudo_environ($l29) !literal
	# initialize the other argument regs
	clr $l19
	clr $l20
	clr $l21
	fclr $lf16
	fclr $lf17
	fclr $lf18
	fclr $lf19
	fclr $lf20
	fclr $lf21

	# call main()
	ldq $l27,main($l29) !literal!1
	jsr $l26,($l27),main !lituse_jsr!1
	ldgp $l29,0($l26)
	
	bne $l0, $bad
	nop
	end
$bad:
	ldah $l1, msg($l29) !gprelhigh
	lda $l2, 115($l31)  # char <- 's'
	lda $l1, msg($l1) !gprellow
	.align 4
$L0:
	print $l2, 194  # print char -> stderr
	lda $l1, 1($l1)
	ldbu $l2, 0($l1)
	sextb $l2, $l2
	bne $l2, $L0

	print $l0, 130 # print int -> stderr
$fini:	
	nop
	nop
	pal1d 0
	br $fini
	.end _start

	.comm __slr_base,8,8
	.comm __fibre_base,8,8
	
	.section .rodata
	.ascii "\0slr_runner:mtalpha-sim:\0"
	.ascii "\0slr_datatag:ppp-mtalpha-sim:\0"

msg:	
	.ascii "slrt: main returned \0"


	.globl __pseudo_argv
	.align 3
__pseudo_argv:
	.long $progname
__pseudo_environ:
	.long 0
$progname:
	.ascii "a.out\0"
	
