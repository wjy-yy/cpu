//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The overall of the pipelined xg-riscv implementation.
//
// ====================================================================

`include "xgriscv_defines.v"

module xgriscv_pipeline(
  input                   clk, reset,
  output[`ADDR_SIZE-1:0]  pcW);
  
  wire [31:0]    instr;
  wire [31:0]    pcF;
	wire CPU_MIO, memwrite;
	wire [`ADDR_SIZE-1:0] ram_addr;
	wire [`XLEN-1:0] ram_data_in, douta;
	wire [3:0] WEA;
  
  imem U_imem(pcF, instr);

  dmem U_dmem(clk, WEA, ram_addr, ram_data_in, douta);

  xgriscv U_xgriscv(clk, reset, 1'b0, instr, douta, memwrite, pcF, ram_addr, ram_data_in, CPU_MIO, WEA, 1'b0);
  
endmodule

module xgriscv(input  clk, reset,
					input MIO_ready,
               
               input  [`INSTR_SIZE-1:0] inst_in,
					input  [`XLEN-1:0] Data_in,
               output mem_w,
					output [31:0] PC_out,
               output [`ADDR_SIZE-1:0] 	Addr_out, 
               output [`XLEN-1:0] 		   Data_out,
               output CPU_MIO,
					output[3:0] WEA,
					input INT
               );
	
  wire [6:0]  opD;
 	wire [2:0]  funct3D, aluctrl1D;
	wire [6:0]  funct7D;
  wire [4:0]  rdD, rs1D;
  wire [11:0] immD;
  wire        zeroD, ltD;
  wire [4:0]  immctrlD;
  wire        itypeD, jalD, jalrD, bunsignedD, pcsrcD;
  wire [3:0]  aluctrlD;
  wire [1:0]  alusrcaD;
  wire        alusrcbD, jD, bD;
  wire        memwriteD, lunsignedD;
  wire [1:0]  swhbD, lwhbD;
  wire        memtoregD, regwriteD;

  controller  c(clk, reset, opD, funct3D, funct7D, rdD, rs1D, immD, zeroD, ltD,
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, aluctrl1D, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD, jD, bD, lwhbD, swhbD,
              memtoregD, regwriteD);


  datapath    dp(clk, reset,
              inst_in, PC_out,
              Data_in, Addr_out, Data_out, mem_w, 
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, aluctrl1D, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD,  jD, bD, lwhbD, swhbD,
              memtoregD, regwriteD, 
              opD, funct3D, funct7D, rdD, rs1D, immD, zeroD, ltD, memwriteD, WEA);

endmodule
