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


module alu_accrf(/*AUTOARG*/
   // Outputs
   alu_read_value, xmu_read_value, alu_mac_read,
   // Inputs
   clk, rst, alu_read_ptr, xmu_read_ptr, alu_mac_wr_ptr,
   alu_mac_wr_valid, alu_mac_wr_value, alu_write_value,
   xmu_write_value, alu_write_ptr, xmu_write_ptr, alu_write_valid,
   xmu_write_valid
   );
   input clk;
   input rst;

   input alu_read_ptr;
   input xmu_read_ptr;

   input alu_mac_wr_ptr;
   input alu_mac_wr_valid;
   input [31:0] alu_mac_wr_value;
   
   
   input [31:0] alu_write_value;
   input [31:0] xmu_write_value;

   input 	alu_write_ptr;
   input 	xmu_write_ptr;
      
   input 	alu_write_valid;
   input 	xmu_write_valid;
      
   output [31:0] alu_read_value;
   output [31:0] xmu_read_value;


   output [31:0] alu_mac_read;
   

   reg [31:0] 	 acc0;
   reg [31:0] 	 acc1;

   wire 	 alu_mac_acc0 = alu_mac_wr_valid & !alu_mac_wr_ptr;
   wire 	 alu_write_acc0 = alu_write_valid & !alu_write_ptr;
   wire 	 xmu_write_acc0 = xmu_write_valid & !xmu_write_ptr;


   wire 	 alu_mac_acc1 = alu_mac_wr_valid & alu_mac_wr_ptr;
   wire 	 alu_write_acc1 = alu_write_valid & alu_write_ptr;
   wire 	 xmu_write_acc1 = xmu_write_valid & xmu_write_ptr;
   

   assign alu_read_value = !alu_read_ptr ? acc0 : acc1;
   assign xmu_read_value = !xmu_read_ptr ? acc0 : acc1;

   //this is cool because the mac reads / writes same acc
   assign alu_mac_read = !alu_mac_wr_ptr ? acc0 : acc1;
   
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     acc0 <= 32'd0;
	     acc1 <= 32'd0;
	  end
	else
	  begin
	     acc0 <= alu_mac_acc0   ? alu_mac_wr_value :
		     alu_write_acc0 ? alu_write_value :
		     xmu_write_acc0 ? xmu_write_value :
		     acc0;

	     acc1 <= alu_mac_acc1   ? alu_mac_wr_value :
		     alu_write_acc1 ? alu_write_value :
		     xmu_write_acc1 ? xmu_write_value :
		     acc1;
	     
	  end // else: !if(rst)
		
     end
   


endmodule // alu_accrf


   