//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The datapath of the pipeline.
// ====================================================================

`include "xgriscv_defines.v"

module datapath(
	input                    clk, reset,

	input [`INSTR_SIZE-1:0]  instrF, 	 // from instructon memory
	output[`ADDR_SIZE-1:0] 	 pcF, 		   // to instruction memory

	input [`XLEN-1:0]	       readdataM, // from data memory: read data
  output[`XLEN-1:0]        aluoutM, 	 // to data memory: address
 	output[`XLEN-1:0]	       writedataM,// to data memory: write data
  output			                memwriteM,	// to data memory: write enable
 	
	// from controller
	input [4:0]		            immctrlD,
	input			                 itype, jalD, jalrD, bunsignedD, pcsrcD,
	input [3:0]		            aluctrlD,
	input [2:0]					aluctrl1D,
	input [1:0]		            alusrcaD,
	input			                 alusrcbD,
	input			                 memwriteD, lunsignedD, jD, bD,
	input [1:0]		          	 lwhbD, swhbD,  
	input          		        memtoregD, regwriteD,
	
  	// to controller
	output [6:0]		           opD,
	output [2:0]		           funct3D,
	output [6:0]		           funct7D,
	output [4:0] 		          rdD, rs1D,
	output [11:0]  		        immD,
	output 	       		        zeroD, ltD,
	input								data_ram_weD,
	output [3:0]					WEAM
	);
	wire jW, pcsrc, writenE, writenM;
	wire flushM = 0;
	wire [`ADDR_SIZE-1:0] pcW;
	// next PC logic (operates in fetch and decode)
	wire [`ADDR_SIZE-1:0]	 pcplus4F, nextpcF, pcbranchD, pcadder2aD, pcadder2bD, pcbranch0D;
	//mux2 #(`ADDR_SIZE)	    pcsrcmux(pcplus4F, pcbranchD, pcsrcD, nextpcF);
	mux2 #(`ADDR_SIZE)	    pcsrcmux(pcplus4F, pcbranchD, pcsrc, nextpcF);
	
	// Fetch stage logic
	pcenr      	 pcreg(clk, reset, writenE, nextpcF, pcF);
	addr_adder  	pcadder1(pcF, `ADDR_SIZE'b100, pcplus4F);

	///////////////////////////////////////////////////////////////////////////////////
	// IF/ID pipeline registers
	wire [`INSTR_SIZE-1:0]	instrD;
	wire [`ADDR_SIZE-1:0]	pcD, pcplus4D;
	wire flushD = pcsrc; 
	wire regwriteW;

	flopenrc #(`INSTR_SIZE) 	pr1D(clk, reset, writenE, flushD, instrF, instrD);     // instruction
	flopenrc #(`ADDR_SIZE)	  pr2D(clk, reset, writenE, flushD, pcF, pcD);           // pc
	flopenrc #(`ADDR_SIZE)	  pr3D(clk, reset, writenE, flushD, pcplus4F, pcplus4D); // pc+4


	// Decode stage logic
	wire [`RFIDX_WIDTH-1:0] rs2D;
	assign  opD 	= instrD[6:0];
	assign  rdD     = instrD[11:7];
	assign  funct3D = instrD[14:12];
	assign  rs1D    = instrD[19:15];
	assign  rs2D   	= itype?5'b00000:instrD[24:20];
	//assign  rs2D   	= ((opD == `OP_ADDI) & (funct3D == `FUNCT3_SR) & (funct7D == `FUNCT7_SRAI))?5'b00000:instrD[24:20];
	assign  funct7D = instrD[31:25];
	assign  immD    = instrD[31:20];

	// immediate generate
	wire [11:0]  iimmD = instrD[31:20];
	wire [11:0]		simmD	= {instrD[31:25],instrD[11:7]};//instr[31:25, 11:7], 12 bits
	wire [11:0]  bimmD	= {instrD[31],instrD[7],instrD[30:25],instrD[11:8]};//instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	wire [19:0]		uimmD	= instrD[31:12];
	wire [19:0]  jimmD	= {instrD[31],instrD[19:12],instrD[20],instrD[30:21]};
	wire [`XLEN-1:0]	immoutD, shftimmD;
	wire [`XLEN-1:0]	rdata1D, rdata2D, wdataW;
	wire [`RFIDX_WIDTH-1:0]	waddrW;

	imm 	im(iimmD, simmD, bimmD, uimmD, jimmD, immctrlD, immoutD);

	// register file (operates in decode and writeback)
	regfile rf(clk, rs1D, rs2D, rdata1D, rdata2D, regwriteW, waddrW, wdataW, pcW);

	///////////////////////////////////////////////////////////////////////////////////
	// ID/EX pipeline registers

	// for control signals
	wire       regwriteE, memwriteE, alusrcbE, memtoregE;
	wire [1:0] alusrcaE,lwhbE, swhbE;
	wire [3:0] aluctrlE;
	wire [2:0] aluctrl1E;
	//assign flushM = pcsrc/* | ~writenM*/; 
	assign flushE = pcsrc | ~writenE; //what will happen when writenE is 0 ,flushE is 1
	wire luE, jE, bE, data_ram_weE;
	flopenrc #(21) regE(clk, reset, writenE, flushE,
                  {regwriteD, memwriteD, memtoregD, lwhbD, swhbD, lunsignedD, alusrcaD, alusrcbD, aluctrlD, aluctrl1D, jD, bD, data_ram_weD}, 
                  {regwriteE, memwriteE, memtoregE, lwhbE, swhbE, luE,		  alusrcaE, alusrcbE, aluctrlE, aluctrl1E, jE, bE, data_ram_weE});
  
	// for data
	wire [`XLEN-1:0]	srca1E, srcb1E, immoutE, srcaE, srcbE, aluoutE;
	wire [`RFIDX_WIDTH-1:0] rdE, rs1E, rs2E;
	wire [`ADDR_SIZE-1:0] 	pcE, pcplus4E;
	flopenrc #(`XLEN) 	pr1E(clk, reset, writenE, flushE, rdata1D, srca1E);        	// data from rs1
	flopenrc #(`XLEN) 	pr2E(clk, reset, writenE, flushE, rdata2D, srcb1E);         // data from rs2
	flopenrc #(`XLEN) 	pr3E(clk, reset, writenE, flushE, immoutD, immoutE);        // imm output
 	flopenrc #(`RFIDX_WIDTH)  pr4E(clk, reset, writenE, flushE, rs1D, rs1E);         // rd
 	flopenrc #(`RFIDX_WIDTH)  pr5E(clk, reset, writenE, flushE, rs2D, rs2E);         // rd
 	flopenrc #(`RFIDX_WIDTH)  pr6E(clk, reset, writenE, flushE, rdD, rdE);         // rd
 	flopenrc #(`ADDR_SIZE)	pr8E(clk, reset, writenE, flushE, pcD, pcE);            // pc
 	flopenrc #(`ADDR_SIZE)	pr9E(clk, reset, writenE, flushE, pcplus4D, pcplus4E);  // pc+4

	wire[1:0]	forwardA, forwardB;
	wire[`XLEN-1:0] srca, srcb;
	mux3 #(`XLEN)	fA(srca1E, wdataW, /*aluoutW*/ aluoutM, forwardA, srca);//
	mux3 #(`XLEN)	fB(srcb1E, wdataW, /*aluoutW*/ aluoutM, forwardB, srcb);//

	// execute stage logic
	mux3 #(`XLEN)  srcamux(srca, 0, pcE, alusrcaE, srcaE);     // alu src a mux
	mux2 #(`XLEN)  srcbmux(srcb, immoutE, alusrcbE, srcbE);			 // alu src b mux
	//wire[1:0]	forwardA, forwardB;
	//wire[`XLEN-1:0] srca, srcb;
	//mux3 #(`XLEN)	fA(srcaE, wdataW, /*aluoutW*/ aluoutM, forwardA, srca);//
	//mux3 #(`XLEN)	fB(srcbE, wdataW, /*aluoutW*/ aluoutM, forwardB, srcb);//
	wire[`ADDR_SIZE-1:0] PCoutE;

	alu alu(srcaE, srcbE, 5'b0, aluctrlE, aluctrl1E, aluoutE, overflowE, zeroE, ltE, geE);
	alu alu1(pcE, immoutE, 5'b0, `ALU_CTRL_ADD, 3'b000, PCoutE, overflowE, zeroE, ltE, geE);
		
	wire B;
	assign B = bE & aluoutE[0];
	mux2 #(`XLEN) brmux(aluoutE, PCoutE, B, pcbranchD);			 // pcsrc mux	

	assign pcsrc = jE | B;

	hazard hz(clk, memtoregE, rdE, rs1D, rs2D, writenM, writenE);
	
	

		///////////////////////////////////////////////////////////////////////////////////
	// EX/MEM pipeline registers
	// for control signals
	wire 		regwriteM, luM, memtoregM, jM, bM, data_ram_weM;
	wire [1:0] lwhbM, swhbM;
	wire [`XLEN-1:0] srcb1M;
	wire[`ADDR_SIZE-1:0] PCoutM, pcM;

	floprc #(1)	wrenM(clk, reset, flushM, writenE, writenM);
	floprc #(`XLEN+11) 	regM(clk, reset, flushM,
                  	{srcb1E, regwriteE, memwriteE, memtoregE, lwhbE, luE, swhbE, jE, bE, data_ram_weE},
                  	{srcb1M, regwriteM, memwriteM, memtoregM, lwhbM, luM, swhbM, jM, bM, data_ram_weM});
	floprc #(`ADDR_SIZE) 	regpcM(clk, reset, flushM, PCoutE, PCoutM);


	// for data
	wire [`ADDR_SIZE-1:0]	pcplus4M;
 	wire [`RFIDX_WIDTH-1:0]	 rdM;
	floprc #(`XLEN) 	        pr1M(clk, reset, flushM, aluoutE, aluoutM);
	//floprc #(`XLEN) 	        pr5M(clk, reset, flushM, srcb1E, writedataM);
	floprc #(`XLEN) 	        pr5M(clk, reset, flushM, srcb, writedataM);
	floprc #(`RFIDX_WIDTH) 	 pr2M(clk, reset, flushM, rdE, rdM);
	floprc #(`ADDR_SIZE)	    pr3M(clk, reset, flushM, pcE, pcM);            // pc
	floprc #(`ADDR_SIZE)	    pr4M(clk, reset, flushM, pcplus4E, pcplus4M);            // pc+4
	
	// mem stage logic
	wire [`XLEN-1:0] dmoutM;
	//dmem dmem(clk, memwriteM, aluoutM, srcb1M, pcM, lwhbM, swhbM, luM, dmoutM);
reg [31:0] intmp;
always @(*) begin
	case(lwhbM)
	2'b11: intmp <= readdataM;
	2'b10: intmp <= luM?{16'b0, readdataM[15:0]}:{{16{readdataM[15]}}, readdataM[15:0]};
	2'b01: intmp <= luM?{24'b0, readdataM[7:0]}:{{24{readdataM[7]}}, readdataM[7:0]};
	endcase
end

assign dmoutM = intmp;

reg [3:0] WEAtmp;
always @(*) begin
      if (memwriteM) begin
		case(swhbM)
			2'b11:				WEAtmp={data_ram_weM, data_ram_weM, data_ram_weM, data_ram_weM};
			2'b10:			WEAtmp={1'b0, 1'b0, data_ram_weM, data_ram_weM};
			2'b01:				WEAtmp={1'b0, 1'b0, 1'b0, data_ram_weM};
			default:				WEAtmp=4'b0000;
		endcase
      end
		else	WEAtmp=4'b0000;
end
assign WEAM = WEAtmp;

  ///////////////////////////////////////////////////////////////////////////////////
  // MEM/WB pipeline registers
  // for control signals
  wire flushW = 0;
	wire memtoregW, bW;
		wire[`ADDR_SIZE-1:0] PCoutW;
  wire[`XLEN-1:0]		   aluoutW, dmoutW;
	floprc #(`XLEN+4) regW(clk, reset, flushW, {dmoutM, regwriteM, memtoregM, jM, bM}, {dmoutW, regwriteW, memtoregW, jW, bW});
	floprc #(`ADDR_SIZE) 	regpcW(clk, reset, flushW, PCoutM, PCoutW);

	
	
  // for data

  wire[`RFIDX_WIDTH-1:0]	 rdW;
	wire [`ADDR_SIZE-1:0]	pcplus4W;

	forward fw(regwriteM, rdM, rs1E, rs2E, regwriteW, rdW, forwardA, forwardB);

  floprc #(`XLEN) 	       pr1W(clk, reset, flushW, aluoutM, aluoutW);
  floprc #(`RFIDX_WIDTH)  pr2W(clk, reset, flushW, rdM, rdW);
  floprc #(`ADDR_SIZE)	   pr3W(clk, reset, flushW, pcM, pcW);            // pc
  floprc #(`ADDR_SIZE)	   pr4W(clk, reset, flushW, pcplus4M, pcplus4W);            // pc+4
	
	// write-back stage logic
	//assign wdataW = aluoutW;//mux2
	//pc+4
//	assign pcbranchD = aluoutW;
//j or B & meet the case
//j -> aluoutW
//B -> immoutW
//connect bW, modify alu
	mux3 #(`XLEN) wdatamux(aluoutW, pcplus4W, dmoutW, {memtoregW, jW}, wdataW);		
	assign waddrW = rdW;//register destination
	
	//assign pcsrcD = jW;
	//assign pcsrc = jW | B;
endmodule