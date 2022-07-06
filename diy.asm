start:
    addi x11, x0, 0 # i row
    addi x12, x0, 0 # j col
    addi x13, x0, 8
    addi x14, x0, 6
    addi x15, x0, 1400 #used
    addi x16, x0, 2000 #color
    sw x0, -16(x16)
    addi x17, x17, 0xf
    sw x17, 192(x16)
    #clear 600
    addi x17, x0, 0 #flag
    addi x18, x0, 0 #count
    addi x10, x0, 1
    addi x21, x0, 0 #nowx row, need to save
    addi x22, x0, 0 #nowy col, need to save
    lui x20, 0xdffff
    ori x20, x0, 0x0 #button info
    #lui x20, 0xdfff0 #vram
    # led/score: x9
    #2000 is nowx, 2004 is nowy
    #2008 is yellow
    addi x28, x0, 6
    sw x28, 0(x16)
    addi x28, x0, 7
    sw x28, 4(x16)
    addi x28, x0, 4
    sw x28, 8(x16)
    addi x28, x0, 4
    sw x28, 12(x16)
    addi x28, x0, 6
    sw x28, 16(x16)
    addi x28, x0, 6
    sw x28, 20(x16)
    addi x28, x0, 5
    sw x28, 24(x16)
    addi x28, x0, 7
    sw x28, 28(x16)
    addi x28, x0, 4
    sw x28, 32(x16)
    addi x28, x0, 4
    sw x28, 36(x16)
    addi x28, x0, 5
    sw x28, 40(x16)
    addi x28, x0, 4
    sw x28, 44(x16)
    addi x28, x0, 7
    sw x28, 48(x16)
    addi x28, x0, 5
    sw x28, 52(x16)
    addi x28, x0, 7
    sw x28, 56(x16)
    addi x28, x0, 6
    sw x28, 60(x16)
    addi x28, x0, 6
    sw x28, 64(x16)
    addi x28, x0, 5
    sw x28, 68(x16)
    addi x28, x0, 4
    sw x28, 72(x16)
    addi x28, x0, 4
    sw x28, 76(x16)
    addi x28, x0, 5
    sw x28, 80(x16)
    addi x28, x0, 5
    sw x28, 84(x16)
    addi x28, x0, 7
    sw x28, 88(x16)
    addi x28, x0, 7
    sw x28, 92(x16)
    
	addi x28, x0, 6
    sw x28, 96(x16)
    addi x28, x0, 7
    sw x28, 100(x16)
    addi x28, x0, 4
    sw x28, 104(x16)
    addi x28, x0, 4
    sw x28, 108(x16)
    addi x28, x0, 6
    sw x28, 112(x16)
    addi x28, x0, 6
    sw x28, 116(x16)
    addi x28, x0, 5
    sw x28, 120(x16)
    addi x28, x0, 7
    sw x28, 124(x16)
    addi x28, x0, 4
    sw x28, 128(x16)
    addi x28, x0, 4
    sw x28, 132(x16)
    addi x28, x0, 5
    sw x28, 136(x16)
    addi x28, x0, 4
    sw x28, 140(x16)
    addi x28, x0, 7
    sw x28, 144(x16)
    addi x28, x0, 5
    sw x28, 148(x16)
    addi x28, x0, 7
    sw x28, 152(x16)
    addi x28, x0, 6
    sw x28, 156(x16)
    addi x28, x0, 6
    sw x28, 160(x16)
    addi x28, x0, 5
    sw x28, 164(x16)
    addi x28, x0, 4
    sw x28, 168(x16)
    addi x28, x0, 4
    sw x28, 172(x16)
    addi x28, x0, 5
    sw x28, 176(x16)
    addi x28, x0, 5
    sw x28, 180(x16)
    addi x28, x0, 7
    sw x28, 184(x16)
    addi x28, x0, 7
    sw x28, 188(x16)
    
    addi x9, x0, 0
work:

# flush the used array
loop1:
	#addi x15, x0, 1400
    addi x12, x0, 0
loop2:
    sw x0, 0(x15)
    addi x15, x15, 4
    addi x12, x12, 1
    bne x12, x14, loop2
    addi x11, x11, 1
    bne x11, x13, loop1
    
	addi x8, x0, 0
ctrl:
	addi x28, x0, 2000
	sw x21, -8(x28)
	sw x22, -12(x28)
	lui x20, 0xdffff
	lw x19, 0(x20)	#button info
    beq x8, x19, ctrl
    addi x8, x19, 0
    sw x0, 0(x20)
    lui x20, 0xcffff
    sw x9, 0(x20)
    addi x23, x0, 2 #up
    addi x24, x0, 5 #left
    addi x25, x0, 6 #ok
    addi x26, x0, 7 #right
    addi x27, x0, 10#down
    addi x28, x0, 2000
    beq x19, x24, left
    beq x19, x23, up
    beq x19, x25, solve
    beq x19, x26, right
    beq x19, x27, down
    beq x0, x0, ctrl
    
left:
	beq x22, x0, ctrl
    addi x22, x22, -1
    sw x22, -12(x28)
    jal x1, ctrl
    
up:
	beq x21, x0, ctrl
    addi x21, x21, -1
    sw x21, -8(x28)
	jal x1, ctrl
  
right:
	addi x28, x22, 1
	beq x14, x28, ctrl
	addi x22, x22, 1
    sw x22, -12(x28)
	jal x1, ctrl
    
down:
	addi x28, x21, 1
    beq x13, x28, ctrl
	addi x21, x21, 1
    sw x21, -8(x28)
	jal x1, ctrl
    
mut: #x28*x29
	beq x29, x0, end4
	addi x30, x0, 0
    addi x31, x0, 0
loop:
	add x31, x31, x28
    addi x30, x30, 1
    blt x30, x29, loop
end4:
    jalr x0, x1, 0
    
solve:
	addi x16, x0, 2000
    addi x28, x21, 0 # row num
    addi x29, x12, 0 # col count
    jal x1, mut		 # x31 is x28*x29
    add x28, x31, x22 # x28 = the order of the block
    addi x15, x0, 1400
    add x15, x15, x28 # x15 is the used (used=0: it is still there)
    lw x30, 0(x15)
    bne x30, x0, ctrl# x28 is offset
    addi x29, x0, 4
    jal x1, mut		 # x31 is 4*offset
    add x16, x16, x31
	lw x29, 0(x16)	 # x29 is the color
    addi x17, x0, 1 # flag=1
    addi x15, x0, 1600 # clear
    #add x15, x15, x28
    add x15, x15, x31
    sw x10 0(x15)
    addi x8, x15, 0
    addi x26, x0, 1 # count of joint blocks
    jal x1, search
    bne x26, x10, clear
    #addi x15, x15, 400
    sw x0, 0(x8)	# clear[now] is 0
clear:
    addi x28, x26, 0
    addi x29, x26, 0
    jal x1, mut
    add x9, x9, x31 # the score add to x^2
    # after search, if x26 is 1, recover, else, clear.
    # while(flag) for(i=0 to 6)for(j=0 to 5) if(down is empty) down
    # after that clear are set to 0
while:
	addi x17, x0, 0	#flag
    addi x11, x0, 0	#i
    addi x13, x13, -1 ######
    
    addi x16, x0, 1600
    addi x15, x0, 2000 #color
    addi x26, x0, 2000
    addi x12, x0, 0	#j
loop7:
    addi x12, x12, 1	#j
    addi x26, x26, 4	#color of nextline
    bne x12, x14, loop7
    
loop5:
    addi x12, x0, 0	#j
loop6:
	lw x23, 0(x16)
    beq x23, x10, end2 # this block is clear
    addi x28, x14, 0
    addi x29, x0, 4
    jal x1, mut
    add x25, x16, x31 # clear of nextline
    lw x24, 0(x25)
    beq x24, x0, end2
    lw x24, 0(x15)
    sw x24, 0(x26)#mv color
    sw x0, 0(x15)
    sw x10, 0(x16)#clear=1
    sw x0, 0(x25) #clear=0
    addi x17, x0, 1
    
end2:
	addi x12, x12, 1
	addi x16, x16, 4
    addi x15, x15, 4
    addi x26, x26, 4
    bne x12, x14, loop6
    addi x11, x11, 1
    bne x11, x13, loop5
    bne x17, x0, while
    
    addi x13, x13, 1	######
    # update used with clear
    addi x15, x0, 1600 #clear, -200=used
    addi x16, x0, 2000
    addi x11, x0, 0
loop8:
    addi x12, x0, 0
loop9:
    lw x26, 0(x15)
    beq x26, x0, end3
    sw x10, -200(x15)
    sw x0, 0(x15)
    sw x0, 0(x16)
end3:
	addi x12, x12, 1
	addi x15, x15, 4
    addi x16, x16, 4
    bne x12, x14, loop9
    addi x11, x11, 1
    bne x11, x13, loop8
    beq x0, x0, ctrl
    
search:
	addi x17, x0, 0		# flag
    addi x11, x0, 0		# i
    addi x15, x0, 2000	# color
    addi x16, x0, 1600	# clear
loop3:
    addi x12, x0, 0
loop4:
	lw x23, 0(x15)
    bne x29, x23, end1
    lw x23, 0(x16)	#x16 is the address of clear
    bne x23, x0, end1 # if clear also skip
    
    beq x12, x0, tt2	# if j=0 skip
tt1:#left
	beq x12, x0, tt2
    lw x24, -4(x16)
    beq x24, x0, tt2
    sw x24, 0(x16)
    addi x17, x0, 1
    addi x26, x26, 1
    
    beq x11, x0, tt3
tt2:#up
	sub x25, x16, x14 # -row number
    sub x25, x25, x14 # -row number
    sub x25, x25, x14 # -row number
    sub x25, x25, x14 # -row number
    lw x24, 0(x25)		#-6(x16)
    beq x24, x0, tt3
    sw x24, 0(x16)
    addi x17, x0, 1
    addi x26, x26, 1

	addi x25, x11, 1
    beq x25, x13, tt4
tt3:#down
	add x25, x16, x14
    add x25, x25, x14
    add x25, x25, x14
    add x25, x25, x14
    lw x24, 0(x25)
    beq x24, x0, tt4
    sw x24, 0(x16)
    addi x17, x0, 1
    addi x26, x26, 1
    
    addi x25, x12, 1
    beq x25, x14, end1
tt4:
	lw x24, 4(x16)
    beq x24, x0, end1
    sw x24, 0(x16)
    addi x17, x0, 1
    addi x26, x26, 1

end1:
	addi x15, x15, 4
    addi x16, x16, 4
    addi x12, x12, 1
    bne x12, x14, loop4
    addi x11, x11, 1
    bne x11, x13, loop3
    bne x17, x0, search
    jalr x0, x1, 0
# after searching, all the blocks that should be cleared is set to 1