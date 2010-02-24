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

module xmu_writeback(/*AUTOARG*/
   // Outputs
   grf_wb_valid, grf_wb_ptr, mr_wb_valid, mr_wb_ptr, pr_wb_valid,
   pr_wb_ptr,
   // Inputs
   rd_ptr, rd_valid, ld_invalidate
   );
   input [6:0] rd_ptr;
   input       rd_valid;

   input       ld_invalidate;
   
   
   output 	grf_wb_valid;
   output [4:0]	grf_wb_ptr;
   
   output 	mr_wb_valid;
   output [2:0] mr_wb_ptr;
   
   output 	pr_wb_valid;
   output [2:0] pr_wb_ptr;

   
   reg 		t_grf_wb_valid;
   reg [4:0]	t_grf_wb_ptr;
   
      
   reg 		t_mr_wb_valid;
   reg [2:0] 	t_mr_wb_ptr;

   reg [2:0] 	t_pr_wb_ptr;
   reg 		t_pr_wb_valid;


   assign grf_wb_ptr = t_grf_wb_ptr;
   assign grf_wb_valid = t_grf_wb_valid;
   
   assign pr_wb_ptr = t_pr_wb_ptr;
   assign pr_wb_valid = t_pr_wb_valid;
   
   assign mr_wb_ptr = t_mr_wb_ptr;
   assign mr_wb_valid = t_mr_wb_valid;
   
   
   always@(*)
     begin
	t_grf_wb_valid = 1'b0;
	t_grf_wb_ptr = 5'd0;

	t_mr_wb_valid = 1'b0;
	t_mr_wb_ptr = 3'b0;
	
	t_pr_wb_valid = 1'b0;
	t_pr_wb_ptr = 3'd0;


	if(rd_valid | ld_invalidate)
	  begin
	     //grf pointer
	     if(rd_ptr[6:5] == 2'b01)
	       begin
		  t_grf_wb_valid = 1'b1;
		  t_grf_wb_ptr = rd_ptr[4:0];
	       end

	     //message register
	     else if(rd_ptr[6:3] == 4'b0011)
	       begin
		  t_mr_wb_valid = 1'b1;
		  t_mr_wb_ptr = rd_ptr[2:0];
	       end
	     //predicate register
	     else if((rd_ptr[6:0] == `PR0) | 
		     (rd_ptr[6:0] == `PR1) | 
		     (rd_ptr[6:0] == `PR2) | 
		     (rd_ptr[6:0] == `PR3) |
		     (rd_ptr[6:0] == `PR4) |
		     (rd_ptr[6:0] == `PR5) |
		     (rd_ptr[6:0] == `PR6) |
		     (rd_ptr[6:0] == `PR7))
	       begin
		  t_pr_wb_valid = 1'b1;
		  t_pr_wb_ptr = {rd_ptr[6], rd_ptr[1:0]}; 
	       end
	  end
	
     end
   
   
endmodule // xmu_writeback

