`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:06:42 09/06/2017 
// Design Name: 
// Module Name:    anti_jitter 
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
module anti_jitter(
	input clk,
	input in,
	output out
    );

reg [31:0]counter = 32'b0;
always @(posedge clk) begin
	if (in)
		if (counter < 100000)
			counter <= counter+1;
		else
			counter <= counter;
	else
		counter <= 0;
end
assign out = counter >= 100000;


endmodule