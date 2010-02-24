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

module asr_rf(/*AUTOARG*/
   // Outputs
   xmu_read_ptr1_data, xmu_read_ptr2_data, xmu_strest_data,
   // Inputs
   clk, rst, xmu_read_req_ptr1, xmu_read_r1_req, xmu_read_req_ptr2,
   xmu_read_r2_req, xmu_strest_ptr, stall_exec, alu_md_write_port,
   xmu_md_write_port, alu_md_ptr, xmu_md_ptr, alu_md_valid,
   xmu_md_valid
   );


   input clk;
   input rst;

   input [1:0] xmu_read_req_ptr1;
   input       xmu_read_r1_req;
   
   input [1:0] xmu_read_req_ptr2;
   input       xmu_read_r2_req;

   input [6:0] xmu_strest_ptr;
  
   
   input       stall_exec;

   input [31:0] alu_md_write_port;
   input [31:0] xmu_md_write_port;

   input [6:0] 	alu_md_ptr;
   input [6:0] 	xmu_md_ptr;

   input 	alu_md_valid;
   input 	xmu_md_valid;
      

   output [31:0] xmu_read_ptr1_data;
   output [31:0] xmu_read_ptr2_data;

   output [31:0] xmu_strest_data;
   

   
   reg [63:0] 	 asr0;
   reg [63:0] 	 asr1;
   reg [63:0] 	 asr2;
   reg [63:0] 	 asr3;

   reg [63:0] 	 t_asr0_nxt;
   reg [63:0] 	 t_asr1_nxt;
   reg [63:0] 	 t_asr2_nxt;
   reg [63:0] 	 t_asr3_nxt;


   wire 	 xmu_load_asr0_lo = ((xmu_md_ptr == `ASL0) |(xmu_md_ptr == `AS0)) & xmu_md_valid;
   wire 	 xmu_load_asr0_hi = (xmu_md_ptr == `ASU0) & xmu_md_valid;
   wire 	 xmu_load_asr1_lo = ((xmu_md_ptr == `ASL1) |(xmu_md_ptr == `AS1)) & xmu_md_valid;
   wire 	 xmu_load_asr1_hi = (xmu_md_ptr == `ASU1) & xmu_md_valid;
   wire 	 xmu_load_asr2_lo = ((xmu_md_ptr == `ASL2) |(xmu_md_ptr == `AS2)) & xmu_md_valid;
   wire 	 xmu_load_asr2_hi = (xmu_md_ptr == `ASU2) & xmu_md_valid;
   wire 	 xmu_load_asr3_lo = ((xmu_md_ptr == `ASL3) |(xmu_md_ptr == `AS3)) & xmu_md_valid;
   wire 	 xmu_load_asr3_hi = (xmu_md_ptr == `ASU3) & xmu_md_valid;

   wire 	 alu_load_asr0_lo = ((alu_md_ptr == `ASL0) | (alu_md_ptr == `AS0)) & alu_md_valid;
   wire 	 alu_load_asr0_hi = (alu_md_ptr == `ASU0) & alu_md_valid;
   wire 	 alu_load_asr1_lo = ((alu_md_ptr == `ASL1) | (alu_md_ptr == `AS1)) & alu_md_valid;
   wire 	 alu_load_asr1_hi = (alu_md_ptr == `ASU1) & alu_md_valid;
   wire 	 alu_load_asr2_lo = ((alu_md_ptr == `ASL2) | (alu_md_ptr == `AS2)) & alu_md_valid;
   wire 	 alu_load_asr2_hi = (alu_md_ptr == `ASU2) & alu_md_valid;
   wire 	 alu_load_asr3_lo = ((alu_md_ptr == `ASL3) | (alu_md_ptr == `AS3)) & alu_md_valid;
   wire 	 alu_load_asr3_hi = (alu_md_ptr == `ASU3) & alu_md_valid;

   assign xmu_strest_data = 
			    (xmu_strest_ptr == `ASL0) ? asr0[31:0] :
			    (xmu_strest_ptr == `ASU0) ? asr0[63:32] :
			    (xmu_strest_ptr == `ASL1) ? asr1[31:0] :
			    (xmu_strest_ptr == `ASU1) ? asr1[63:32] :			    
			    (xmu_strest_ptr == `ASL2) ? asr2[31:0] :
			    (xmu_strest_ptr == `ASU2) ? asr2[63:32] :
			    (xmu_strest_ptr == `ASL3) ? asr3[31:0] :
			    asr3[63:32];
   

   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     asr0 <= 64'd0;
	     asr1 <= 64'd0;
	     asr2 <= 64'd0;
	     asr3 <= 64'd0;
	  end
	else
	  begin
	     asr0[31:0] <= xmu_load_asr0_lo ? xmu_md_write_port :
			   alu_load_asr0_lo ? alu_md_write_port : 
			   t_asr0_nxt[31:0] ;
	     asr0[63:32] <= xmu_load_asr0_hi ? xmu_md_write_port :
			    alu_load_asr0_hi ? alu_md_write_port : 
			    t_asr0_nxt[63:32] ;
	     
	     asr1[31:0] <= xmu_load_asr1_lo ? xmu_md_write_port :
			   alu_load_asr1_lo ? alu_md_write_port : 
			   t_asr1_nxt[31:0] ;
	     asr1[63:32] <= xmu_load_asr1_hi ? xmu_md_write_port :
			    alu_load_asr1_hi ? alu_md_write_port : 
			    t_asr1_nxt[63:32] ;
	     
	     asr2[31:0] <= xmu_load_asr2_lo ? xmu_md_write_port :
			   alu_load_asr2_lo ? alu_md_write_port : 
			   t_asr2_nxt[31:0] ;
	     asr2[63:32] <= xmu_load_asr2_hi ? xmu_md_write_port :
			    alu_load_asr2_hi ? alu_md_write_port : 
			    t_asr2_nxt[63:32] ;
	     
	     asr3[31:0] <= xmu_load_asr3_lo ? xmu_md_write_port :
			   alu_load_asr3_lo ? alu_md_write_port : 
			   t_asr3_nxt[31:0] ;
	     asr3[63:32] <= xmu_load_asr3_hi ? xmu_md_write_port :
			    alu_load_asr3_hi ? alu_md_write_port : 
			    t_asr3_nxt[63:32] ;
	  end // else: !if(rst)
     end // always@ (posedge clk)

   wire        ar0_mode = asr0[63:32] == 32'd0;
   wire        ar1_mode = asr1[63:32] == 32'd0;
   wire        ar2_mode = asr2[63:32] == 32'd0;
   wire        ar3_mode = asr3[63:32] == 32'd0;
   
   wire [31:0] asr0_se = ar0_mode ? asr0[31:0] : { {16{asr0[15]}}, asr0[15:0]};
   wire [31:0] asr1_se = ar1_mode ? asr1[31:0] : { {16{asr1[15]}}, asr1[15:0]};
   wire [31:0] asr2_se = ar2_mode ? asr2[31:0] : { {16{asr2[15]}}, asr2[15:0]};
   wire [31:0] asr3_se = ar3_mode ? asr3[31:0] : { {16{asr3[15]}}, asr3[15:0]};
   
   
   assign xmu_read_ptr1_data = xmu_read_req_ptr1 == 2'd0 ? asr0_se :
			       xmu_read_req_ptr1 == 2'd1 ? asr1_se :
			       xmu_read_req_ptr1 == 2'd2 ? asr2_se :
			       asr3_se;
   
   
   
   assign xmu_read_ptr2_data = xmu_read_req_ptr2 == 2'd0 ? asr0_se :
			       xmu_read_req_ptr2 == 2'd1 ? asr1_se :
			       xmu_read_req_ptr2 == 2'd2 ? asr2_se :
			       asr3_se;
   
   
   
   always@(*) 
     begin
	t_asr0_nxt = asr0;
	t_asr1_nxt = asr1;
	t_asr2_nxt = asr2;
	t_asr3_nxt = asr3;
	
	if(stall_exec)
	  begin
	     t_asr0_nxt = asr0;
	     t_asr1_nxt = asr1;
	     t_asr2_nxt = asr2;
	     t_asr3_nxt = asr3;
	  end
	
	else 
	  begin
	     if(((xmu_read_req_ptr1 == 2'd0 & xmu_read_r1_req)
		 | (xmu_read_req_ptr2 == 2'd0 & xmu_read_r2_req)) & ~ar0_mode)
	       begin
		  if(asr0[31:16]+1 >= asr0[63:48])
		    begin
		       t_asr0_nxt[31:0] = 32'd0;
		       t_asr0_nxt[63:32] = asr0[63:32];
		    end
		  else 
		    begin
		       t_asr0_nxt[15:0] = asr0[15:0] + asr0[47:32];
		       t_asr0_nxt[31:16] = asr0[31:16] + 16'd1;
		       t_asr0_nxt[63:32] = asr0[63:32];
		    end
	       end // if (xmu_read_req_ptr1 == 2'd0 | xmu_read_req_ptr2 == 2'd0)
	     if(((xmu_read_req_ptr1 == 2'd1 & xmu_read_r1_req)
		| (xmu_read_req_ptr2 == 2'd1 & xmu_read_r2_req)) & ~ar1_mode)
	       begin
		  if(asr1[31:16]+1 >= asr1[63:48]) 
		    begin
		       t_asr1_nxt[31:0] = 32'd0;
		       t_asr1_nxt[63:32] = asr1[63:32];
		    end
		  else 
		    begin
		       t_asr1_nxt[15:0] = asr1[15:0] + asr1[47:32];
		       t_asr1_nxt[31:16] = asr1[31:16] + 16'd1;
		       t_asr1_nxt[63:32] = asr1[63:32];
		    end
	       end // if (xmu_read_req_ptr1 == 2'd0 | xmu_read_req_ptr2 == 2'd0)
	     if(((xmu_read_req_ptr1 == 2'd2 & xmu_read_r1_req)
		| (xmu_read_req_ptr2 == 2'd2 & xmu_read_r2_req)) & ~ar2_mode) 
	       begin
		if(asr2[31:16]+1 >= asr2[63:48]) 
		  begin
		     t_asr2_nxt[31:0] = 32'd0;
		     t_asr2_nxt[63:32] = asr2[63:32];
		  end
		else 
		  begin
		     t_asr2_nxt[15:0] = asr2[15:0] + asr2[47:32];
		     t_asr2_nxt[31:16] = asr2[31:16] + 16'd1;
		     t_asr2_nxt[63:32] = asr2[63:32];
		  end
	       end // if (xmu_read_req_ptr1 == 2'd2 | xmu_read_req_ptr2 == 2'd2)

	     if(((xmu_read_req_ptr1 == 2'd3 & xmu_read_r1_req)
		| (xmu_read_req_ptr2 == 2'd3 & xmu_read_r2_req)) & ~ar3_mode) 
	       begin
		  if(asr3[31:16]+1 >= asr3[63:48]) 
		    begin
		       t_asr3_nxt[31:0] = 32'd0;
		       t_asr3_nxt[63:32] = asr3[63:32];
		end
		  else 
		    begin
		       t_asr3_nxt[15:0] = asr3[15:0] + asr3[47:32];
		       t_asr3_nxt[31:16] = asr3[31:16] + 16'd1;
		       t_asr3_nxt[63:32] = asr3[63:32];
		    end
	       end
	  end // else: !if(~stall_exec)
     end // always@ (*)

endmodule // asr_rf

   
      
	       
	       
	       
	       
	       
      