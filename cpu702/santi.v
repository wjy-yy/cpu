`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:40:31 09/04/2017 
// Design Name: 
// Module Name:    santi_jitter 
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
module santi_jitter(
	input clk,
	input RSTN,//rst键按下为0，这里输入的RSTN按下为1
	input [24:0]btn_in,
	input [15:0]sw_in,
	output [24:0]btn_ok,
	output [15:0]sw_ok,
	output rst_ok
    );

anti_jitter Aj_btn_0(.clk(clk), .in(btn_in[0]), .out(btn_ok[0]));
anti_jitter Aj_btn_1(.clk(clk), .in(btn_in[1]), .out(btn_ok[1]));
anti_jitter Aj_btn_2(.clk(clk), .in(btn_in[2]), .out(btn_ok[2]));
anti_jitter Aj_btn_3(.clk(clk), .in(btn_in[3]), .out(btn_ok[3]));
anti_jitter Aj_btn_4(.clk(clk), .in(btn_in[4]), .out(btn_ok[4]));
anti_jitter Aj_btn_5(.clk(clk), .in(btn_in[5]), .out(btn_ok[5]));
anti_jitter Aj_btn_6(.clk(clk), .in(btn_in[6]), .out(btn_ok[6]));
anti_jitter Aj_btn_7(.clk(clk), .in(btn_in[7]), .out(btn_ok[7]));
anti_jitter Aj_btn_8(.clk(clk), .in(btn_in[8]), .out(btn_ok[8]));
anti_jitter Aj_btn_9(.clk(clk), .in(btn_in[9]), .out(btn_ok[9]));

anti_jitter Aj_btn_10(.clk(clk), .in(btn_in[10]), .out(btn_ok[10]));
anti_jitter Aj_btn_11(.clk(clk), .in(btn_in[11]), .out(btn_ok[11]));
anti_jitter Aj_btn_12(.clk(clk), .in(btn_in[12]), .out(btn_ok[12]));
anti_jitter Aj_btn_13(.clk(clk), .in(btn_in[13]), .out(btn_ok[13]));
anti_jitter Aj_btn_14(.clk(clk), .in(btn_in[14]), .out(btn_ok[14]));
anti_jitter Aj_btn_15(.clk(clk), .in(btn_in[15]), .out(btn_ok[15]));
anti_jitter Aj_btn_16(.clk(clk), .in(btn_in[16]), .out(btn_ok[16]));
anti_jitter Aj_btn_17(.clk(clk), .in(btn_in[17]), .out(btn_ok[17]));
anti_jitter Aj_btn_18(.clk(clk), .in(btn_in[18]), .out(btn_ok[18]));
anti_jitter Aj_btn_19(.clk(clk), .in(btn_in[19]), .out(btn_ok[19]));

anti_jitter Aj_btn_20(.clk(clk), .in(btn_in[20]), .out(btn_ok[20]));
anti_jitter Aj_btn_21(.clk(clk), .in(btn_in[21]), .out(btn_ok[21]));
anti_jitter Aj_btn_22(.clk(clk), .in(btn_in[22]), .out(btn_ok[22]));
anti_jitter Aj_btn_23(.clk(clk), .in(btn_in[23]), .out(btn_ok[23]));
anti_jitter Aj_btn_24(.clk(clk), .in(btn_in[24]), .out(btn_ok[24]));
///////////////////////////////////////////////////////////////////////////////////////
anti_jitter Aj_sw_0(.clk(clk), .in(sw_in[0]), .out(sw_ok[0]));
anti_jitter Aj_sw_1(.clk(clk), .in(sw_in[1]), .out(sw_ok[1]));
anti_jitter Aj_sw_2(.clk(clk), .in(sw_in[2]), .out(sw_ok[2]));
anti_jitter Aj_sw_3(.clk(clk), .in(sw_in[3]), .out(sw_ok[3]));
anti_jitter Aj_sw_4(.clk(clk), .in(sw_in[4]), .out(sw_ok[4]));
anti_jitter Aj_sw_5(.clk(clk), .in(sw_in[5]), .out(sw_ok[5]));
anti_jitter Aj_sw_6(.clk(clk), .in(sw_in[6]), .out(sw_ok[6]));
anti_jitter Aj_sw_7(.clk(clk), .in(sw_in[7]), .out(sw_ok[7]));
anti_jitter Aj_sw_8(.clk(clk), .in(sw_in[8]), .out(sw_ok[8]));
anti_jitter Aj_sw_9(.clk(clk), .in(sw_in[9]), .out(sw_ok[9]));

anti_jitter Aj_sw_10(.clk(clk), .in(sw_in[10]), .out(sw_ok[10]));
anti_jitter Aj_sw_11(.clk(clk), .in(sw_in[11]), .out(sw_ok[11]));
anti_jitter Aj_sw_12(.clk(clk), .in(sw_in[12]), .out(sw_ok[12]));
anti_jitter Aj_sw_13(.clk(clk), .in(sw_in[13]), .out(sw_ok[13]));
anti_jitter Aj_sw_14(.clk(clk), .in(sw_in[14]), .out(sw_ok[14]));
anti_jitter Aj_sw_15(.clk(clk), .in(sw_in[15]), .out(sw_ok[15]));
///////////////////////////////////////////////////////////////////////////////////////
anti_jitter Aj_rst(.clk(clk), .in(RSTN), .out(rst_ok));

endmodule