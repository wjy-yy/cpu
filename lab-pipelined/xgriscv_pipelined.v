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
  wire [31:0]    pcF, pcM;
  wire           memwrite;
  wire [3:0]     amp;
  wire [31:0]    addr, writedata, readdata;
  wire	[1:0]				lwhb;
  wire	[1:0]				swhb;
	wire				lu;
   
  
  imem U_imem(pcF, instr);

  dmem U_dmem(clk, memwrite, addr, writedata, pcM, lwhb, swhb, lu, readdata);
  
  xgriscv U_xgriscv(clk, reset, pcF, instr, memwrite, amp, addr, writedata, pcM, pcW, readdata);
  
endmodule

// xgriscv: a pipelined riscv processor
module xgriscv(input         			        clk, reset,
               output [31:0] 			        pcF,
               input  [`INSTR_SIZE-1:0] instr,
               output					              memwrite,
               output [3:0]  			        amp,
               output [`ADDR_SIZE-1:0] 	daddr, 
               output [`XLEN-1:0] 		    writedata,
               output [`ADDR_SIZE-1:0] 	pcM,
               output [`ADDR_SIZE-1:0] 	pcW,
               input  [`XLEN-1:0] 		    readdata);
	
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
              memwriteD, lunsignedD, lwhbD, swhbD, jD, bD,
              memtoregD, regwriteD);


  datapath    dp(clk, reset,
              instr, pcF,
              readdata, daddr, writedata, memwrite, pcM, pcW,
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, aluctrl1D, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD, lwhbD, swhbD, jD, bD,
              memtoregD, regwriteD, 
              opD, funct3D, funct7D, rdD, rs1D, immD, zeroD, ltD);

endmodule
