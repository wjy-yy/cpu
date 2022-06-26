`include "xgriscv_defines.v"

module imem(input  [`ADDR_SIZE-1:0]   a,
            output [`INSTR_SIZE-1:0]  rd);

  reg  [`INSTR_SIZE-1:0] RAM[`IMEM_SIZE-1:0];

  assign rd = RAM[a[`ADDR_SIZE-1:2]]; // instruction size aligned
endmodule

module dmem(input           	         clk,
			input	[3:0]				wea,
            input  [`XLEN-1:0]        a, wd,
            output [`XLEN-1:0]        rd);

  reg  [7:0] RAM[4095:0];
	reg [31:0] rtmp;
	always @(*) 
		rtmp <= {RAM[a+3],RAM[a+2],RAM[a+1],RAM[a]};

  assign rd = rtmp; // word aligned

  always @(posedge clk)
      begin
		if(wea[0])
			RAM[a] <= wd[7:0];
		if(wea[1])
			RAM[a+1] <= wd[15:8];
		if(wea[2])
			RAM[a+2] <= wd[23:16];
		if(wea[3])
			RAM[a+3] <= wd[31:24];
		end
endmodule
