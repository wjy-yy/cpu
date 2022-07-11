`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:21:03 06/29/2022 
// Design Name: 
// Module Name:    op 
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
module op(
	input [24:0] btn_ok,
	output reg [5:0] btn,
	output btn_en
    );
	integer i, j;
	always@*	begin
		j=0;
		for(i=0;i<=24;i=i+1)
			if(btn_ok[i]) begin
				btn <= i;
				j=1;
			end
		if(!j)
			btn <= 0;
		end
	assign btn_en = j;
endmodule
