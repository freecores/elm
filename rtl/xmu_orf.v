/*
 Copyright (c) 2007-2010, Trustees of The Leland Stanford Junior University
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without 
 modification,are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, 
 this list of conditions and the following disclaimer. Redistributions in 
 binary form must reproduce the above copyright notice, this list of 
 conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution. Neither the name of the 
 Stanford University nor the names of its contributors may be used to 
 endorse or promote products derived from this software without
 specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE.
 */


`include "elm_defs.v"

module xmu_orf(/*AUTOARG*/
   // Outputs
   orf_read_ptr1_out, orf_read_ptr2_out, 
   // Inputs
   clk, rst, orf_read_ptr1, orf_read_ptr1_valid, orf_read_ptr2, 
   orf_read_ptr2_valid, orf_write_ptr, orf_write_ptr_valid, 
   orf_write_value, alu_ex_mem_ptr, alu_ex_mem_valid, alu_ex_mem_in
   );
   input clk;
   input rst;
   
   input [1:0] orf_read_ptr1;
   input       orf_read_ptr1_valid;
   output [31:0] orf_read_ptr1_out;
   
   
   input [1:0] orf_read_ptr2;
   input       orf_read_ptr2_valid;
   output [31:0] orf_read_ptr2_out;


   input [1:0] 	 orf_write_ptr;
   input 	 orf_write_ptr_valid;
   input [31:0]  orf_write_value;
   

   input [6:0] 	 alu_ex_mem_ptr;
   input 	 alu_ex_mem_valid;
   input [31:0]  alu_ex_mem_in;
      
   
   reg [31:0] 	 r0;
   reg [31:0] 	 r1;
   reg [31:0] 	 r2;
   reg [31:0] 	 r3;

   wire 	 w0 = (orf_write_ptr == 2'd0) & orf_write_ptr_valid;
   wire 	 w1 = (orf_write_ptr == 2'd1) & orf_write_ptr_valid;   
   wire 	 w2 = (orf_write_ptr == 2'd2) & orf_write_ptr_valid;
   wire 	 w3 = (orf_write_ptr == 2'd3) & orf_write_ptr_valid;

   wire 	 w0a = (alu_ex_mem_ptr == `AR0 ) & alu_ex_mem_valid;
   wire 	 w1a = (alu_ex_mem_ptr == `AR1 ) & alu_ex_mem_valid;  
   wire 	 w2a = (alu_ex_mem_ptr == `AR2 ) & alu_ex_mem_valid;
   wire 	 w3a = (alu_ex_mem_ptr == `AR3 ) & alu_ex_mem_valid;
   
 
   reg [31:0] 	 t_read0, t_read1;

   assign orf_read_ptr1_out = t_read0;
   assign orf_read_ptr2_out = t_read1;
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r0 <= 32'd0;
	     r1 <= 32'd0;
	     r2 <= 32'd0;
	     r3 <= 32'd0;
	  end
	else
	  begin
	     r0 <= w0 ? orf_write_value : w0a ? alu_ex_mem_in : r0;
	     r1 <= w1 ? orf_write_value : w1a ? alu_ex_mem_in : r1;
	     r2 <= w2 ? orf_write_value : w2a ? alu_ex_mem_in : r2;
	     r3 <= w3 ? orf_write_value : w3a ? alu_ex_mem_in : r3;
	  end
     end


   always@(*)
     begin
	t_read0 = 32'd0;
	t_read1 = 32'd0;

	if(orf_read_ptr1_valid)
	  begin
	     t_read0 = (orf_read_ptr1 == 2'd0) ? r0 :
		       (orf_read_ptr1 == 2'd1) ? r1 :
		       (orf_read_ptr1 == 2'd2) ? r2 :
		       r3;
	  end


	if(orf_read_ptr2_valid)
	  begin
	     t_read1 = (orf_read_ptr2 == 2'd0) ? r0 :
		       (orf_read_ptr2 == 2'd1) ? r1 :
		       (orf_read_ptr2 == 2'd2) ? r2 :
		       r3;
	  end
	

     end
      
   
endmodule // xmu_orf

