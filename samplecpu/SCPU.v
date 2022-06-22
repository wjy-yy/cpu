`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:38:43 04/28/2009 
// Design Name: 
// Module Name:    single_cycle_Cpu_9 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SCPU(	input clk,			//
					input reset,
					input MIO_ready,
									
					input [31:0]inst_in,
					input [31:0]Data_in,	
									
					output mem_w,
					output[31:0]PC_out,
					output[31:0]Addr_out,
					output[31:0]Data_out, 
					output CPU_MIO,
					input INT
				);

				  
endmodule
