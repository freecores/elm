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


module pr_rf(/*AUTOARG*/
   // Outputs
   alu_pr1_out, alu_pr1_out_valid, alu_pr2_out, alu_pr2_out_valid,
   xmu_pr1_out, xmu_pr1_out_valid, xmu_pr2_out, xmu_pr2_out_valid,
   // Inputs
   clk, rst, alu_pr1_ptr, alu_pr1_ptr_valid, alu_pr2_ptr,
   alu_pr2_ptr_valid, xmu_pr1_ptr, xmu_pr1_ptr_valid, xmu_pr2_ptr,
   xmu_pr2_ptr_valid, xmu_wb_ptr, xmu_wb_valid, xmu_wb_value,
   alu_wb_ptr, alu_wb_valid, alu_wb_value
   );
   input clk;
   input rst;

   input [2:0] alu_pr1_ptr;
   input       alu_pr1_ptr_valid;
   
   input [2:0] alu_pr2_ptr;
   input       alu_pr2_ptr_valid;

   input [2:0] xmu_pr1_ptr;
   input       xmu_pr1_ptr_valid;
   
   input [2:0] xmu_pr2_ptr;
   input       xmu_pr2_ptr_valid;


   input [2:0] xmu_wb_ptr;
   input       xmu_wb_valid;
   input [31:0] xmu_wb_value;
   
   input [2:0] 	alu_wb_ptr;
   input 	alu_wb_valid;
   input [31:0] alu_wb_value;
   
 
   output [8:0] alu_pr1_out;
   output 	alu_pr1_out_valid;
   
   output [8:0] alu_pr2_out;
   output 	alu_pr2_out_valid;
  
   
   output [8:0] xmu_pr1_out;
   output 	 xmu_pr1_out_valid;
   
   output [8:0] xmu_pr2_out;
   output 	 xmu_pr2_out_valid;


   //if the input is valid...the output is valid
   assign alu_pr1_out_valid = alu_pr1_ptr_valid;
   assign alu_pr2_out_valid = alu_pr2_ptr_valid;
   assign xmu_pr1_out_valid = xmu_pr1_ptr_valid;
   assign xmu_pr2_out_valid = xmu_pr2_ptr_valid;
   

   
   //bit zero holds the predicate
   //bits 1 through 8 hold count
   
   reg [8:0] pr0;
   reg [8:0] pr1;
   reg [8:0] pr2;  
   reg [8:0] pr3;
   reg 	     pr4;
   reg 	     pr5;
   reg 	     pr6;  
   reg 	     pr7;

   wire      w0_a = ((alu_wb_ptr == 3'd0) & alu_wb_valid);
   wire      w1_a = ((alu_wb_ptr == 3'd1) & alu_wb_valid);  
   wire      w2_a = ((alu_wb_ptr == 3'd2) & alu_wb_valid);
   wire      w3_a = ((alu_wb_ptr == 3'd3) & alu_wb_valid);   
   wire      w4_a = ((alu_wb_ptr == 3'd4) & alu_wb_valid);
   wire      w5_a = ((alu_wb_ptr == 3'd5) & alu_wb_valid);  
   wire      w6_a = ((alu_wb_ptr == 3'd6) & alu_wb_valid);
   wire      w7_a = ((alu_wb_ptr == 3'd7) & alu_wb_valid);  
  
   wire      w0_x = ((xmu_wb_ptr == 3'd0) & xmu_wb_valid);
   wire      w1_x = ((xmu_wb_ptr == 3'd1) & xmu_wb_valid);  
   wire      w2_x = ((xmu_wb_ptr == 3'd2) & xmu_wb_valid);
   wire      w3_x = ((xmu_wb_ptr == 3'd3) & xmu_wb_valid);   
   wire      w4_x = ((xmu_wb_ptr == 3'd4) & xmu_wb_valid);
   wire      w5_x = ((xmu_wb_ptr == 3'd5) & xmu_wb_valid);  
   wire      w6_x = ((xmu_wb_ptr == 3'd6) & xmu_wb_valid);
   wire      w7_x = ((xmu_wb_ptr == 3'd7) & xmu_wb_valid);  

   wire      wb_xmu_set = ~(xmu_wb_value[7:0] == 8'd0);
   wire      wb_alu_set = ~(alu_wb_value[7:0] == 8'd0);
     
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     pr0 <= 9'b000000000;
	     pr1 <= 9'b000000000;	     
	     pr2 <= 9'b000000000;
	     pr3 <= 9'b000000000;
	     pr4 <= 1'b0;
	     pr5 <= 1'b0;
	     pr6 <= 1'b0;
	     pr7 <= 1'b0;
	  end
	else
	  begin
	     pr0 <= w0_a ? {alu_wb_value[7:0], wb_alu_set} :
		    w0_x ? {xmu_wb_value[7:0], wb_xmu_set} :
		    pr0;

	     pr1 <= w1_a ? {alu_wb_value[7:0], wb_alu_set} :
		    w1_x ? {xmu_wb_value[7:0], wb_xmu_set} :
		    pr1; 
	     
	     pr2 <= w2_a ? {alu_wb_value[7:0], wb_alu_set} :
		    w2_x ? {xmu_wb_value[7:0], wb_xmu_set} :
		    pr2; 

	     pr3 <= w3_a ? {alu_wb_value[7:0], wb_alu_set} :
		    w3_x ? {xmu_wb_value[7:0], wb_xmu_set} :
		    pr3; 

	     pr4 <= w4_a ? wb_alu_set :
		    w4_x ? wb_xmu_set :
		    pr4;

	     pr5 <= w5_a ? wb_alu_set :
		    w5_x ? wb_xmu_set :
		    pr5; 
	     
	     pr6 <= w6_a ?   wb_alu_set :
		    w6_x ?   wb_xmu_set :
		    pr6; 

	     pr7 <= w7_a ? wb_alu_set :
		    w7_x ? wb_xmu_set :
		    pr7;  

	  end
     end
   
   reg [8:0] t_alu_pr1_out;
   reg [8:0] t_alu_pr2_out;
   
   reg [8:0] t_xmu_pr1_out;
   reg [8:0] t_xmu_pr2_out;

   assign alu_pr1_out = t_alu_pr1_out;
   assign alu_pr2_out = t_alu_pr2_out;
   assign xmu_pr1_out = t_xmu_pr1_out;
   assign xmu_pr2_out = t_xmu_pr2_out;
      
   always@(*)
     begin
	t_alu_pr1_out = 9'd0;	
	if(alu_pr1_ptr_valid)
	  begin
	     t_alu_pr1_out = 
			     (alu_pr1_ptr == 3'd0) ? {8'd0, pr4} :
			     (alu_pr1_ptr == 3'd1) ? {8'd0, pr5} :
			     (alu_pr1_ptr == 3'd2) ? {8'd0, pr6} :
			     (alu_pr1_ptr == 3'd3) ? {8'd0, pr7} :
			     (alu_pr1_ptr == 3'd4) ? pr0 :
			     (alu_pr1_ptr == 3'd5) ? pr1 :
			     (alu_pr1_ptr == 3'd6) ? pr2 :
			     pr3;
	  end
     end
   
   always@(*)
     begin
	t_alu_pr2_out = 9'd0;
	if(alu_pr2_ptr_valid)
	  begin
	     t_alu_pr2_out = 
			     (alu_pr2_ptr == 3'd0) ? {8'd0, pr4} :
			     (alu_pr2_ptr == 3'd1) ? {8'd0, pr5} :
			     (alu_pr2_ptr == 3'd2) ? {8'd0, pr6} :
			     (alu_pr2_ptr == 3'd3) ? {8'd0, pr7} :
			     (alu_pr2_ptr == 3'd4) ? pr0 :
			     (alu_pr2_ptr == 3'd5) ? pr1 :
			     (alu_pr2_ptr == 3'd6) ? pr2 :
			     pr3;
	  end
     end


   always@(*)
     begin
	t_xmu_pr1_out = 9'd0;
	if(xmu_pr1_ptr_valid)
	  begin
	     t_xmu_pr1_out = 
			     (xmu_pr1_ptr == 3'd0) ? {8'd0, pr4} :
			     (xmu_pr1_ptr == 3'd1) ? {8'd0, pr5} :
			     (xmu_pr1_ptr == 3'd2) ? {8'd0, pr6} :
			     (xmu_pr1_ptr == 3'd3) ? {8'd0, pr7} :
			     (xmu_pr1_ptr == 3'd4) ? pr0 :
			     (xmu_pr1_ptr == 3'd5) ? pr1 :
			     (xmu_pr1_ptr == 3'd6) ? pr2 :
			     pr3;
	  end	
     end
   always@(*)
     begin
	t_xmu_pr2_out = 9'd0;
	if(xmu_pr2_ptr_valid)
	  begin
	     t_xmu_pr2_out = 
			     (xmu_pr2_ptr == 3'd0) ? {8'd0, pr4} :
			     (xmu_pr2_ptr == 3'd1) ? {8'd0, pr5} :
			     (xmu_pr2_ptr == 3'd2) ? {8'd0, pr6} :
			     (xmu_pr2_ptr == 3'd3) ? {8'd0, pr7} :
			     (xmu_pr2_ptr == 3'd4) ? pr0 :
			     (xmu_pr2_ptr == 3'd5) ? pr1 :
			     (xmu_pr2_ptr == 3'd6) ? pr2 :
			     pr3;
	  end	
     end
endmodule // pr_rf
