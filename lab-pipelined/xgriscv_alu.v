//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The alu module implements the core's ALU.
//
// ====================================================================

`include "xgriscv_defines.v"
module alu(
	input signed	[`XLEN-1:0]	a, b, 
	input	[4:0]  		shamt, 
	input	[3:0]   	aluctrl, 
	input [2:0]			aluctrl1, 

	output reg [`XLEN-1:0]	aluout,
	output       		overflow,
	output 			zero,
	output 			lt,
	output 			ge
	);

	wire op_unsigned = ~aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0]	//ALU_CTRL_ADDU	4'b0010
					| aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0] 	//ALU_CTRL_SUBU	4'b1010
					| aluctrl[3]&aluctrl[2]&~aluctrl[1]&~aluctrl[0] 	//ALU_CTRL_SLTU	4'b1100
					| aluctrl1[2]&~aluctrl1[1]&aluctrl1[0]//bltu
					| aluctrl1[2]&aluctrl1[1]&~aluctrl1[0];//bgeu

	wire [`XLEN-1:0] 	b2;
	wire [`XLEN:0] 		sum; //adder of length XLEN+1
	wire [`XLEN-1:0]	sll,srl,sra,aa,bb;
	wire [`XLEN-1:0]	XOR, OR, AND;
  	wire sub = aluctrl[3]&~aluctrl[2]&~aluctrl[1]&aluctrl[0]
				|aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0]
				|aluctrl[3]&~aluctrl[2]&aluctrl[1]&aluctrl[0]
				|aluctrl[3]&aluctrl[2]&~aluctrl[1]&~aluctrl[0]
				|aluctrl1[2]|aluctrl1[1]|aluctrl1[0];
//slt or b

	assign b2 = sub ? ~b:b; 
	assign sum = (op_unsigned & ({1'b0, a} + {1'b0, b2} + sub))
				| (~op_unsigned & ({a[`XLEN-1], a} + {b2[`XLEN-1], b2} + sub));
				// aluctrl[3]=0 if add, or 1 if sub, don't care if other
	//assign aa = (unsigned) a;
	//assign bb = (unsigned) b;
	assign sll = a<<b;
	assign XOR = a^b;
	assign OR = a|b;
	assign AND = a&b;
	assign srl = a>>b;
	assign sra = a>>>b[9:0];
	integer signed i;

	always@(*)
		case(aluctrl1[2:0])
			`ALU_BEQ:	aluout <= sum[`XLEN-1:0]!=0?0:1;//ZERO
			`ALU_BNE:	aluout <= sum[`XLEN-1:0]!=0?1:0;//ZERO
			`ALU_BLT:	begin							//slt
							if(a[`XLEN-1]!=b[`XLEN-1])
								aluout <= a[`XLEN-1];
							else
								aluout <= sum[`XLEN-1];
						end
			`ALU_BGE:	begin							//slt
							if(a[`XLEN-1]!=b[`XLEN-1])
								aluout <= ~a[`XLEN-1];
							else
								aluout <= ~sum[`XLEN-1];
						end
			`ALU_BLTU:	aluout <= a[`XLEN-1:0]<b[`XLEN-1:0];
			`ALU_BGEU:	aluout <= a[`XLEN-1:0]>=b[`XLEN-1:0];
		default:
		case(aluctrl[3:0])
		`ALU_CTRL_MOVEA: 	aluout <= a;
		`ALU_CTRL_ADD: aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_ADDU:		aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_LUI:	aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_AUIPC:	aluout <= sum[`XLEN-1:0]; //a = pc, b = immout
		`ALU_CTRL_ZERO:		aluout <= sum[`XLEN-1:0]!=0?1:0;
		`ALU_CTRL_SUB:	aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_SLL:	aluout <= sll[`XLEN-1:0];
		`ALU_CTRL_SLT:	begin
							if(a[`XLEN-1]!=b[`XLEN-1])
								aluout <= a[`XLEN-1];
							else
								aluout <= sum[`XLEN-1];
							//$display("a:%8x, b:%8x, a-b:%8x slt:%b\n",a,b,sum,aluout);
						end
		`ALU_CTRL_SLTU:	begin
							aluout <= a[`XLEN-1:0]<b[`XLEN-1:0];
							//$display("a:%8x, b:%8x, a-b:%8x sltu:%b\n",a,b,sum,aluout);
						end
		`ALU_CTRL_XOR:	aluout <= XOR[`XLEN-1:0];
		`ALU_CTRL_OR:	aluout <= OR[`XLEN-1:0];
		`ALU_CTRL_AND:	aluout <= AND[`XLEN-1:0];
		`ALU_CTRL_SRL: begin	aluout <= srl[`XLEN-1:0];
						//$display("a:%8x, b:%8x, srl:%8x\n",a,b,srl);
						end
		`ALU_CTRL_SRA: begin	aluout <= sra[`XLEN-1:0];
						//$display("a:%8x, b:%8x, sra:%8x\n",a,b,sra);
						end
		default: 			aluout <= `XLEN'b0; 
	 endcase
		endcase
	    
	assign overflow = sum[`XLEN-1] ^ sum[`XLEN];
	assign zero = (aluout == `XLEN'b0);
	assign lt = aluout[`XLEN-1];
	assign ge = ~aluout[`XLEN-1];
endmodule

