`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:48:28 09/04/2017 
// Design Name: 
// Module Name:    input_switch_btn 
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
module input_switch_btn(
	input clk,
	input RSTN,
	input [15:0]switch,
	output [4:0]btn_x,
	input [3:0]btn_y,
	output [15:0]sw_ok,
	output [19:0]btn_ok,
	output cr,
	output rst
    );

wire [24:0]btn_result;
btn_scan Btn_scan(
    .clk(clk), 
    .btn_x(btn_x), 
    .btn_y(btn_y), 
    .btn_result(btn_result)
    );

santi_jitter Santi_jitter(
    .clk(clk), 
    .RSTN(~RSTN), 
    .btn_in(btn_result), 
    .sw_in(switch), 
    .btn_ok(btn_ok), 
    .sw_ok(sw_ok), 
    .rst_ok(cr)
    );

reg [31:0]counter = 0;
always @(posedge clk) begin
	if (cr)
		if (counter <200000000)
			counter<=counter+1;
		else
			counter <= counter;
	else
		counter <= 0;
end

assign rst = counter >= 200000000;

endmodule