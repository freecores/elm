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


module mr_rs_sel(/*AUTOARG*/
   // Outputs
   mr_rs1_ptr, mr_rs2_ptr, mr_rs1_ptr_valid, mr_rs2_ptr_valid,
   alu_mr_rs1_data, alu_mr_rs2_data, xmu_mr_rs1_data, xmu_mr_rs2_data,
   // Inputs
   alu_mr_rs1_ptr, alu_mr_rs2_ptr, xmu_mr_rs1_ptr, xmu_mr_rs2_ptr,
   alu_mr_rs1_ptr_valid, alu_mr_rs2_ptr_valid, xmu_mr_rs1_ptr_valid,
   xmu_mr_rs2_ptr_valid, mr_rs1_data, mr_rs2_data
   );

   /* Requests from XMU and ALU */
   input [2:0] alu_mr_rs1_ptr;
   input [2:0] alu_mr_rs2_ptr;  
   input [2:0] xmu_mr_rs1_ptr;
   input [2:0] xmu_mr_rs2_ptr;
   
   input       alu_mr_rs1_ptr_valid;
   input       alu_mr_rs2_ptr_valid;  
   input       xmu_mr_rs1_ptr_valid;
   input       xmu_mr_rs2_ptr_valid;  

   /* Arbitated pointers */
   output [2:0] mr_rs1_ptr;
   output [2:0] mr_rs2_ptr;
   
   output 	mr_rs1_ptr_valid;
   output 	mr_rs2_ptr_valid;

   /* Data back from message registers */
   input [31:0] mr_rs1_data;
   input [31:0] mr_rs2_data;

   output [31:0] alu_mr_rs1_data;
   output [31:0] alu_mr_rs2_data;

   output [31:0] xmu_mr_rs1_data;
   output [31:0] xmu_mr_rs2_data;
      
   wire [2:0] w_rs1_gnt = 
	      alu_mr_rs1_ptr_valid ? 3'd0 :
	      alu_mr_rs2_ptr_valid ? 3'd1 :
	      alu_mr_rs1_ptr_valid ? 3'd2 :
	      alu_mr_rs2_ptr_valid ? 3'd3 :
	      3'd4;

   wire       w_req_alu_rs1 = alu_mr_rs1_ptr_valid 
	      & (w_rs1_gnt != 3'd0);
   
   wire       w_req_alu_rs2 = alu_mr_rs2_ptr_valid 
	      & (w_rs1_gnt != 3'd1);

   wire       w_req_xmu_rs1 = xmu_mr_rs1_ptr_valid 
	      & (w_rs1_gnt != 3'd2);
   
   wire       w_req_xmu_rs2 = xmu_mr_rs2_ptr_valid 
	      & (w_rs1_gnt != 3'd3);

   wire [2:0] w_rs2_gnt =
	      w_req_alu_rs1 ? 3'd0 :
	      w_req_alu_rs2 ? 3'd1 :
	      w_req_xmu_rs1 ? 3'd2 :
	      w_req_xmu_rs2 ? 3'd3 :
	      3'd4;

   assign mr_rs1_ptr = (w_rs1_gnt == 3'd0) ? alu_mr_rs1_ptr :
		       (w_rs1_gnt == 3'd1) ? alu_mr_rs2_ptr :
		       (w_rs1_gnt == 3'd2) ? xmu_mr_rs1_ptr :
		       xmu_mr_rs2_ptr;

   assign mr_rs1_ptr_valid = (w_rs1_gnt != 3'd4);


   assign mr_rs2_ptr = (w_rs2_gnt == 3'd0) ? alu_mr_rs1_ptr :
		       (w_rs2_gnt == 3'd1) ? alu_mr_rs2_ptr :
		       (w_rs2_gnt == 3'd2) ? xmu_mr_rs1_ptr :
		       xmu_mr_rs2_ptr;

   assign mr_rs2_ptr_valid = (w_rs2_gnt != 3'd4);

   
   assign alu_mr_rs1_data = (w_rs1_gnt == 3'd0) ? mr_rs1_data :
			    (w_rs2_gnt == 3'd0) ? mr_rs2_data :
			    32'd0;

   assign alu_mr_rs2_data = (w_rs1_gnt == 3'd1) ? mr_rs1_data :
			    (w_rs2_gnt == 3'd1) ? mr_rs2_data :
			    32'd0;
   
   assign xmu_mr_rs1_data = (w_rs1_gnt == 3'd2) ? mr_rs1_data :
			    (w_rs2_gnt == 3'd2) ? mr_rs2_data :
			    32'd0;

   assign xmu_mr_rs2_data = (w_rs1_gnt == 3'd3) ? mr_rs1_data :
			    (w_rs2_gnt == 3'd3) ? mr_rs2_data :
			    32'd0;
   
endmodule // mr_rs_sel
