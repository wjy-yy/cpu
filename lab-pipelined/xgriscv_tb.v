//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// testbench for simulation
//
// ====================================================================

`include "xgriscv_defines.v"

module xgriscv_tb();
    
   reg                  clk, rstn;
   wire[`ADDR_SIZE-1:0] pcW;
    
   // instantiation of xgriscv 
   xgriscv_pipeline xgriscvp(clk, rstn, pcW);

   integer counter = 0;
   
   initial begin
      $readmemh("riscv32_sim1.dat", xgriscvp.U_imem.RAM);
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
   end
   
   always begin
      #(50) clk = ~clk;
     
      if (clk == 1'b1) 
      begin
         counter = counter + 1;
         // comment these four lines for online judge
         $display("clock: %d", counter);
         $display("pc:\t\t%h", xgriscvp.pcF);
         $display("instr:\t%h", xgriscvp.instr);
         $display("pcw:\t\t%h", pcW);
	//$display("rf08-11:\t %h %h %h %h", xgriscvp.U_xgriscv.dp.rf.rf[8], xgriscvp.U_xgriscv.dp.rf.rf[9], xgriscvp.U_xgriscv.dp.rf.rf[10], xgriscvp.U_xgriscv.dp.rf.rf[11]);
         //$display("rf12-15:\t %h %h %h %h", xgriscvp.U_xgriscv.dp.rf.rf[12], xgriscvp.U_xgriscv.dp.rf.rf[13], xgriscvp.U_xgriscv.dp.rf.rf[14], xgriscvp.U_xgriscv.dp.rf.rf[15]);
         if (pcW == 32'h00000078) // set to the address of the last instruction
          begin
            //$display("pcW:\t\t%h", pcW);
            //$finish;
            $stop;
          end
      end
      
   end //end always
   
endmodule
