`include "ctrl_encode_def.v"
// data memory
module dm(clk, DMWr, addr, din, DMType, dout);
   input          clk;
   input          DMWr;
   input  [8:0]   addr;
   input  [31:0]  din;
	input [2:0] DMType;
   output [31:0]  dout;

     reg [31:0] dd;
   reg [7:0] dmem[511:0];

//dm_word 3'b000
//dm_halfword 3'b001
//dm_halfword_unsigned 3'b010
//dm_byte 3'b011
//dm_byte_unsigned 3'b100

   always @(posedge clk) begin
      if (DMWr) begin
		case(DMType)
			`dm_word:begin
		dmem[addr] <= din[7:0];
		dmem[addr+1] <= din[15:8];
		dmem[addr+2] <= din[23:16];
		dmem[addr+3] <= din[31:24];
			end
			`dm_halfword:begin
		dmem[addr] <= din[7:0];
		dmem[addr+1] <= din[15:8];
			end
			`dm_halfword_unsigned:begin
		dmem[addr] <= din[7:0];
		dmem[addr+1] <= din[15:8];
			end
			`dm_byte:dmem[addr] <= din[7:0];
			`dm_byte_unsigned:dmem[addr] <= din[7:0];
		endcase
      end
	$display("DMTy = 0x%x,",DMType);
	$display("addr = 0x%x,",addr);
	//$display("dmem[addr] = 0x%2x",dmem[addr]);
	end
	
always @(*) begin

		case(DMType)
			`dm_word: dd <= {dmem[addr+3],dmem[addr+2],dmem[addr+1],dmem[addr]};
			`dm_halfword: dd <= {{16{dmem[addr+1][7]}},dmem[addr+1],dmem[addr]};
			`dm_halfword_unsigned: dd <= {16'b0,dmem[addr+1],dmem[addr]};
			`dm_byte: dd <= {{24{dmem[addr][7]}},dmem[addr]};
			`dm_byte_unsigned: dd <= {24'b0,dmem[addr]};
		endcase
end
assign dout=dd;
endmodule    
