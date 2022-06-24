`include "ctrl_encode_def.v"
/*module SCPU(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
   
    output    mem_w,          // output: memory write signal
    output [31:0] PC_out,     // PC address
      // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory

    input  [4:0] reg_sel,    // register selection (for debug use)
    output [31:0] reg_data,  // selected register data (for debug use)
output [2:0] DMType
);*/
module SCPU(	input clk,			//
					input reset,
					input MIO_ready,
									
					input [31:0]inst_in,
					input [31:0]Data_in,	
					input data_ram_we,
					output mem_w,
					output[31:0]PC_out,
					output[31:0]Addr_out,
					output[31:0]Data_out, 
					output CPU_MIO,
					output[3:0] WEA,
					input INT
				);
    wire        RegWrite;    // control signal to register write
    wire [5:0]       EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation

    wire [1:0]  WDSel;       // (register) write data selection
    wire [1:0]  GPRSel;      // general purpose register selection
   
    wire        ALUSrc;      // ALU source for A
    wire        Zero;        // ALU ouput zero
	 //wire DMType;

    wire [31:0] NPC;         // next PC

    wire [4:0]  rs1;          // rs
    wire [4:0]  rs2;          // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;       // funct7
    wire [2:0]  Funct3;       // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    reg [31:0] WD;          // register write data
    wire [31:0] RD1,RD2;         // register data specified by rs
    wire [31:0] B;           // operator for ALU B
	
	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
	wire[31:0] aluout;
	assign Addr_out=aluout;
	assign B = (ALUSrc) ? immout : RD2;
	assign Data_out = RD2;
	
	assign iimm_shamt=inst_in[24:20];
	assign iimm=inst_in[31:20];
	assign simm={inst_in[31:25],inst_in[11:7]};
	assign bimm={inst_in[31],inst_in[7],inst_in[30:25],inst_in[11:8]};
	assign uimm=inst_in[31:12];
	assign jimm={inst_in[31],inst_in[19:12],inst_in[20],inst_in[30:21]};
   
    assign Op = inst_in[6:0];  // instruction
    assign Funct7 = inst_in[31:25]; // funct7
    assign Funct3 = inst_in[14:12]; // funct3
    assign rs1 = inst_in[19:15];  // rs1
    assign rs2 = inst_in[24:20];  // rs2
    assign rd = inst_in[11:7];  // rd
    assign Imm12 = inst_in[31:20];// 12-bit immediate
    assign IMM = inst_in[31:12];  // 20-bit immediate
   
   // instantiation of control unit
	ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), .Zero(Zero), 
		.RegWrite(RegWrite), .MemWrite(mem_w),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel), .DMType(DMType)
	);
 // instantiation of pc unit
	PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out) );
	NPC U_NPC(.PC(PC_out), .NPCOp(NPCOp), .IMM(immout), .NPC(NPC), .aluout(aluout));
	EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);
	RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(RegWrite), 
		.A1(rs1), .A2(rs2), .A3(rd), //Read1, Read2, Write
		.WD(WD), //Write data
		.RD1(RD1), .RD2(RD2) //Read1 Read2
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);
// instantiation of alu unit
	alu U_alu(.A(RD1), .B(B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero), .PC(PC_out));
//	im U_im();
// instantiation of instruction memory
//	im U_im(.addr(PC_out), .dout(inst_in));

// instantiation of data memory
//	dm U_dm(.clk(clk), .DMWr(), .addr(), .din(), .dout());
//please connnect the CPU by yourself
//	assign 
reg [31:0] intmp;
always @*
begin

		case(DMType)
			`dm_word: intmp <= Data_in;
			`dm_halfword: intmp <= {{16{Data_in[15]}}, Data_in[15:0]};
			`dm_halfword_unsigned: intmp <= {16'b0, Data_in[15:0]};
			`dm_byte: intmp <= {{24{Data_in[7]}}, Data_in[7:0]};
			`dm_byte_unsigned: intmp <= {24'b0, Data_in[7:0]};
		endcase
	case(WDSel)
		`WDSel_FromALU: WD<=aluout;
		//`WDSel_FromMEM: WD<=Data_in;
		`WDSel_FromMEM: WD<=intmp;
		`WDSel_FromPC: WD<=PC_out+4;
	endcase
	$display("WDSel:\t %x",WDSel);
	$display("WD:\t %x",WD);
	$display("Data_in:\t %x",Data_in);
	//$display("aluout:\t %x",aluout);
	$display("RD1:\t %x",RD1);
	//$display("B:\t %x",B);
	$display("rs1:\t %x",rs1);
	$display("NPCOp:\t %x",NPCOp);
	//$display("Imm12:\t %x",Imm12);
	//$display("ALUOp:\t %b",ALUOp);
end

reg [3:0] WEAtmp;
	
always @(posedge clk) begin
      if (mem_w) begin
		case(DMType)
			`dm_word:				WEAtmp={data_ram_we, data_ram_we, data_ram_we, data_ram_we};
			`dm_halfword:			WEAtmp={0, 0, data_ram_we, data_ram_we};
			`dm_halfword_unsigned:	WEAtmp={0, 0, data_ram_we, data_ram_we};
			`dm_byte:				WEAtmp={0, 0, 0, data_ram_we};
			`dm_byte_unsigned:	WEAtmp={0, 0, 0, data_ram_we};
		endcase
		
      end
	$display("DMTy = 0x%x,",DMType);
	//$display("addr = 0x%x,",addr);
	//$display("dmem[addr] = 0x%2x",dmem[addr]);
	end

assign WEA = WEAtmp;

/*reg [31:0] intmp;

always @(*) begin

		case(DMType)
			`dm_word: intmp <= Data_in;
			`dm_halfword: intmp <= {{16{Data_in[15]}}, Data_in[15:0]};
			`dm_halfword_unsigned: intmp <= {16'b0, Data_in[15:0]};
			`dm_byte: intmp <= {{24{Data_in[7]}}, Data_in[7:0]};
			`dm_byte_unsigned: intmp <= {24'b0, Data_in[15:0]};
		endcase
end
assign Data_in=intmp;
*/
endmodule
