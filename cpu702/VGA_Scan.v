`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:02:06 8/08/2012 
// Design Name: 
// Module Name:    VGA_Scan 
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
module VGA_Scan(input clk, rst, 					//25MHz
					 output[8:0]row, 				// pixel Screen address, 640 x 480 
					 output[9:0]col,
//					 output [18:0]addr,
					 output Active, 					// read VRAM RAM (active_low)
					 output reg HSYNC, 				// horizontal synchronization
					 output reg VSYNC					// vertical synchronization
					 );	

reg[9:0]HCount;						//VGA horizontal counter (0-799): pixels
reg[9:0]VCount;						//VGA vertical   counter (0-524): lines
reg HActive=0, VActive=0;
//wire[8:0]row;
//wire[9:0]col;

localparam HSC = 10'd95, HBP = 10'd143, HACT = 10'd783, HFP = 10'd799;
    always@(posedge clk or posedge rst) begin
		if(rst)begin
			HCount  <= 0;
			HSYNC   <= 0;
			HActive <= 0;
		end else begin
			HCount <= HCount + 10'h1;
			case(HCount)
				HSC: HSYNC   <= 1;									//行同步脉冲结束：0-95
				HBP: HActive <= 1;									//96-143，返回过冲和左边缘结束
				HACT:HActive <= 0;									//144-783 (0-639)行视频显示有效
				HFP: begin
					HCount <= 10'h0;									//784-799,右边缘、前过冲，一行扫描结束
					HSYNC  <= 0;										//行同步脉冲开始
				end
				default: ;
			endcase
		end
	end
   
localparam VSC = 10'd1, VBP = 10'd35, VACT = 10'd515, VFP = 10'd524;
    always@(posedge clk or posedge rst) begin
		if(rst)begin
			VCount  <= 0;
			VSYNC   <= 0;
			VActive <= 0;
		end else begin
			if(HCount == 10'd799)begin							//水平一行结束
				if(VCount == 10'd524)							//一帧扫描结束
					VCount   <= 10'h0;
				else VCount <= VCount + 10'h1;				//否则垂直扫描下一行
				
			case(VCount)
				VSC: 	VSYNC 	<= 1;								//垂直同步脉冲0-1
				VBP:  VActive 	<= 1;								//2-35，返回过冲和上边缘结束
				VACT:	VActive 	<= 0;								//36-515 (0-479)帧视频显示有效
				VFP:	VSYNC 	<= 0;								//516-524,下边缘、下过冲，一帧扫描结束
				default: ;
			endcase
			end
		end
	end
	
	assign  Active = HActive & VActive;						//视频显示有效区
	assign  col  =  HCount - 10'd144;    					// pixel Screen addr col
   assign  row  =  VCount - 10'd36;     					// pixel Screen addr row
   assign  addr = {row[8:0],col};  								// pixel Screen addr
	 
endmodule
