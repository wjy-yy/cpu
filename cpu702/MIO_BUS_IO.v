/*`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:04:14 06/30/2012 
// Design Name: 
// Module Name:    MIO_BUS 
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
module MIO_BUS(input clk,
					input rst,
					input[3:0]BTN,
					input[15:0]SW,
					input mem_w,
					input[31:0]Cpu_data2bus,				//data from CPU
					input[31:0]addr_bus,
					input[31:0]ram_data_out,
					input[15:0]led_out,
					input[31:0]counter_out,
					input counter0_out,
					input counter1_out,
					input counter2_out,
					
					output reg[31:0]Cpu_data4bus,				//write to CPU
					output reg[31:0]ram_data_in,				//from CPU write to Memory
					output reg[9:0]ram_addr,						//Memory Address signals
					output reg data_ram_we,
					output reg GPIOf0000000_we,
					output reg GPIOe0000000_we,
					output reg counter_we,
					output reg[31:0]Peripheral_in
					);
	always@*	begin
		if(rst)	begin
			Cpu_data4bus <= 32'b0;				//write to CPU
			ram_data_in <= 32'b0;				//from CPU write to Memory
			ram_addr <= 9'b0;						//Memory Address signals
			data_ram_we <= 1'b0;
			GPIOf0000000_we <= 1'b0;
			GPIOe0000000_we <= 1'b0;
			counter_we <= 1'b0;
			Peripheral_in <= 32'b0;
		end
		else	begin
			case(addr_bus[31:28])
				4'b1111:	begin
					Cpu_data4bus <= ram_data_out;
					ram_data_in <= Cpu_data2bus;
					ram_addr <= addr_bus[11:2];
					data_ram_we <= 1'b0;
					//GPIOf0000000_we <= 1'b1;
					GPIOe0000000_we <= 1'b0;
					GPIOe0000000_we <= mem_w;
					counter_we <= counter0_out | counter1_out | counter2_out;
					Peripheral_in <= {14'b0, SW, {counter2_out, counter1_out}};
				end
				4'b1110:	begin
					Cpu_data4bus <= ram_data_out;
					ram_data_in <= Cpu_data2bus;
					ram_addr <= addr_bus[11:2];
					data_ram_we <= 1'b0;
					//GPIOf0000000_we <= 1'b0;
					GPIOf0000000_we <= 1'b0;
					GPIOe0000000_we <= mem_w;
					counter_we <= counter0_out | counter1_out | counter2_out;
					Peripheral_in <= {14'b0, 8'h20220627, {counter2_out, counter1_out}};
				end
				default:	begin
					Cpu_data4bus <= ram_data_out;
					ram_data_in <= Cpu_data2bus;
					ram_addr <= addr_bus[11:2];
					data_ram_we <= mem_w;
					//GPIOf0000000_we <= 1'b0;
					//GPIOe0000000_we <= 1'b0;
					GPIOf0000000_we <= 1'b0;
					GPIOe0000000_we <= 1'b0;
					counter_we <= counter0_out | counter1_out | counter2_out;
					Peripheral_in <= {14'b0, 8'h20204071, {counter2_out, counter1_out}};
				end
			endcase
		end
	end
endmodule
*/

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:39 08/30/2015 
// Design Name: 
// Module Name:    MIO_BUS 
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
module MIO_BUS(input clk,
					input rst,
					input[3:0]BTN,
					input[15:0]SW,
					input mem_w,
					input[31:0]Cpu_data2bus,				//data from CPU
					input[31:0]addr_bus,
					input[31:0]ram_data_out,
					input[15:0]led_out,
					input[31:0]counter_out,
					input counter0_out,
					input counter1_out,
					input counter2_out,
					input [5:0]btn_in,
					input btn_en,
					
					output reg[31:0]Cpu_data4bus,				//write to CPU
					output reg[31:0]ram_data_in,				//from CPU write to Memory
					output reg[11:0]ram_addr,						//Memory Address signals
					output reg data_ram_we,
					output reg GPIOf0000000_we,
					output reg GPIOe0000000_we,
					output reg counter_we,
					output reg [31:0]Peripheral_in,
					output reg [31:0]score
					);
reg [5:0] btn;
//++++++++RAM & IO decode signals:
/*	always @(posedge btn_en)	begin
		btn = btn_in;
		used = 0;
	end*/
	integer lst=0;
	always @* begin
		data_ram_we = 0;
		counter_we = 0;
		GPIOf0000000_we = 0;
		GPIOe0000000_we = 0;
		ram_addr = 12'h000;
		ram_data_in = 32'h00000000;
		Peripheral_in = 32'h0;
		Cpu_data4bus = 32'h0;
		case(addr_bus[31:28])
			4'h0: begin//data_ram(0000-0ffc)
				data_ram_we = mem_w;
				ram_addr = addr_bus[13:2];
				ram_data_in = Cpu_data2bus;
				Cpu_data4bus = ram_data_out;
				end
			4'hc:	begin//score
				data_ram_we = 1'b0;
				/*if(addr_bus==32'hcffff000)
					score = Cpu_data2bus;*/
				ram_addr = addr_bus[31:20];
				ram_data_in = Cpu_data2bus;
				end
			4'hd:	begin//button
				/*if(lst==btn_in)
					btn = 6'b0;
				else	begin
					btn = btn_in;
					lst=btn;
				end*/
				//btn <= 0;
				Cpu_data4bus = btn_in;
				end
			4'he: begin//7 segment leds(e0000000-efffffff)
				GPIOe0000000_we = mem_w;
				Peripheral_in = Cpu_data2bus;
				Cpu_data4bus = counter_out;
				end
			4'hf: begin//led(f0000000-fffffff0, 8 leds&counter, f0000004-fffffff4)
				if(addr_bus[2]) begin//f0000004
					counter_we = mem_w;
					Peripheral_in = Cpu_data2bus;
					Cpu_data4bus = counter_out;
					end
				else begin //f0000000
					GPIOf0000000_we = mem_w;
					Peripheral_in = Cpu_data2bus; //writer counter set & Initialization& led
					Cpu_data4bus = {counter0_out, counter1_out, counter2_out, 9'h000, led_out, BTN, SW};
					end
				end
		endcase
	end
endmodule