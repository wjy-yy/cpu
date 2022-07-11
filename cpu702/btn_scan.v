`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:11:39 09/06/2017 
// Design Name: 
// Module Name:    btn_scan 
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
module btn_scan(
	input clk,
	output[4:0]btn_x,
	input [3:0]btn_y,
	output reg [19:0]btn_result = 20'b0
    );

reg [4:0]state = 5'b11110;
always @(posedge clk) begin
	case (state)
		5'b11110: begin
					btn_result <= {btn_result[19:4], ~btn_y};
					state <= 5'b11101;
					end
		5'b11101: begin
					btn_result <= {btn_result[19:8], ~btn_y, btn_result[3:0]};
					state <= 5'b11011;
					end
		5'b11011: begin
					btn_result <= {btn_result[19:12], ~btn_y, btn_result[7:0]};
					state <= 5'b10111;
					end
		5'b10111: begin
					btn_result <= {btn_result[19:16], ~btn_y, btn_result[11:0]};
					state <= 5'b01111;
					end
		5'b01111: begin
					btn_result <= {~btn_y, btn_result[14:0]};
					state <= 5'b11110;
					end
		default: begin
					btn_result <= 0;
					state <= 5'b11110;
					end
	endcase
end

assign btn_x = state;

endmodule