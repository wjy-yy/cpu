# Test File for 8 Instruction, include:
# ADD/SUB/OR/AND/LW/SW/ORI/BEQ
################################################################
### Make sure following Settings :
# Settings -> Memory Configuration -> Compact, Data at address 0

.text

// 1. add/sub/add/or/xor 验证成功 // R型
/*
	addi x1,x0,15	//x1=15= f
	addi x2,x1,13	//x2=28=1c
	add x3,x2,x1 	//x3=43=2b
	sub x4,x3,x2 	//x4=43-28=15=f
	and x5,x4,x3 	//x5=15&43=11=b
	or x6,x5,x4  	//x6=11|15=15=f
	xor x31,x6,x2	//x31=15^28=13
*/

// 2. ori/xori/addi/ 验证成功

/*	addi x1,x0,1023		//x1 = 3fff = 1023
	ori x2,x1,1024		//x2 = 7fff = 2047
	andi x3,x2,511		//x3 = 1fff = 511
	xori x4,x3,444		//x4 = 0043 = 67
*/

// 3. lw,sw 验证成功//S型

/*	addi x1,x0,1023
	sw x1,(x0)
	addi x2,x1,511
	sw x2,4(x0)
	lw x3,(x0)
	lw x4,4(x0)
*/

// 4.beq  验证成功 //SB型指令
/*	ori x29, x0, 12//x29 = 12
	ori x8, x0, 0x123 // x8 = 0x123
	ori x9, x0, 0x456 // x9 = 0x456
	add x7, x8, x9//x7 = 0x579
	sub x6, x7, x9 //x6 = 0x123
    or  x10, x8, x9 // x10 = 0x123 | 0x456 = 0x577
    and x11, x9, x10// 0x11 = 0x456 & 0x577 = 0x 456
	sw x8, 0(x0) // dem[0] = 0x123
	sw x9, 4(x0)//dem[4]=0x456
	sw x7, 4(x29)//dem[16] = 0x579
	lw x5, 0(x0)//x5 = dem[0] = 0x123
	addi x5,x5,-1
	beq x8, x5, _lb2 // x8==x5? 相等，跳到 _lb2   //30
	_lb1:  										 
	lw x9, 4(x29)	//x9 = dem[16]=0x579		 //34
	_lb2:										 
	lw x5, 4(x0) // x5 = dem[4] = 0x456 		 //38
	beq x9, x5, _lb1 // x5==x9? 相等，跳到_lb1    //3c
*/
// 5. jal,jalr 验证成功 //SB型特殊指令
	addi x1,x0,15	//x1=15= f
	addi x2,x1,13	//x2=28=1c
	jal x1,4//x1=c
	add x3,x2,x1 	//x3=40=0x28
	sub x4,x3,x2 	//x4=40-28=12=c
	and x5,x4,x3 	//x5=12&40=8
	addi x5,x0,8
	jalr x1,x5,0
	or x6,x5,x4  	//x6=11|15=15=f
	xor x31,x6,x2	//x31=15^28=13
	sub x4,x3,x2 	//x4=43-28=15=f

// 6.sll,srl,sra R型 验证成功
/*	
	addi x1,x0,2//x1=2
	addi x2,x1,1//x2=3
	sll x3,x2,x1//x3=3<<2 = 12=0xc
	xori x4,x3,456//x4 = 0x1c4
	addi x5,x4,-687 //x5 = -235 = -0xeb = 0xffffff15
	srl x6,x5,x1//x6=(x5>>2)（逻辑右移） = 0x3fffffc5 
	sra x7,x5,x1//x7=ffffffc5
*/
// 7.slli,srli,srai I型 验证成功
/*	
	addi x1,x0,7//x1=7
	slli x2,x1,5//x2=7*32=14*16=0xe0
	addi x3,x2,-1023//x3=-799=-0x31f=0xfffffce1
	srli x4,x3,6//x4=0x03fffff3
	srai x5,x3,8//x5=0xfffffffc
*/
// 8.slt,sltu rd =(rs1<rs2)? 1:0 R型指令 验证成功
//	 slti,sltiu rd = (rs1<imm)? 1:0 I型指令 验证成功
/*
	ori x1,x0,54//x1=54=0x36
	ori x2,x0,-5//x2=-5=0xfffffffb
	slt x3,x1,x2//x3 =(signed) (x1<x2) = 0 
	slt x4,x2,x1//x4 = ~x3=1
	sltu x5,x1,x2//x5=(unsigned) (x1<x2) = 1
	sltu x6,x2,x1//x6=~x5=0
	slti x7,x1,1023// x7 =(signed) (x1<1023) = 1
	slti x8,x1,53// x8 = ~x7 = 0
	sltiu x9,x1,89// x9 = (unsigned)(x1<89)=1
	sltiu x10,x1,-4//x10 = (unsigned)(x1<-4)=1 
	sltiu x11,x2,8//x11 = (unsigned) (-5<8) = 0
	sltiu x12,x2,-10//x12 = (unsigned) (-5<-10) = 0
*/
// 9.lui,auipc U型指令 验证成功
/*
	lui x1,0x12345//x1=0x12345000
	addi x2,x1,0x678//x2=0x12345678
	auipc x3,0x55678//x3=55678008
*/
// 10. lb,lh,lbu,lhu,sb,sh I型和S型 验证成功
/*	
	lui x1,0xfffff 
	addi x2,x1,0x33f
	sw x2,37(x0)
	lb x3,37(x0)
	lh x4,37(x0)
	lbu x5,37(x0)
	lhu x6,37(x0)
	sb x2,41(x0)
	sh x2,45(x0)
*/

// 11. bne\blt\bge\bltu\bgeu 验证成功
/*
	addi x1,x0,4
	addi x2,x0,6
	bne x1,x2,8
	addi x1,x1,1
	blt x1,x2,-4
	bge x1,x2,8
	addi x1,x1,1
	bltu x1,x2,8
	addi,x1,x1,1
	addi x1,x1,-456
	bltu x2,x1,8
	addi x1,x1,456
	addi x1,x1,1
	bgeu x1,x2,8
*/
// 12.对任意地址的存储
/*	lui x5  0x1234
	addi x5 x5 0x567
	sw x5 49(x0)
	lw x6 48(x0)*/
	# Never return
