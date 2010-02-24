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

module simd_unit(/*AUTOARG*/
   // Outputs
   ep0_inst_mask, ep1_inst_mask, ep2_inst_mask, ep3_inst_mask,
   simd_inst_out, simd_inst_valid, simd_force_stall,
   // Inputs
   CLK, ep0_rst, ep1_rst, ep2_rst, ep3_rst, ep0_inst_in,
   ep0_inst_valid, ep0_simd_req, ep0_simd_mine, ep0_simd_stall,
   ep1_inst_in, ep1_inst_valid, ep1_simd_req, ep1_simd_mine,
   ep1_simd_stall, ep2_inst_in, ep2_inst_valid, ep2_simd_req,
   ep2_simd_mine, ep2_simd_stall, ep3_inst_in, ep3_inst_valid,
   ep3_simd_req, ep3_simd_mine, ep3_simd_stall
   );


   input CLK;
   input ep0_rst;
   input ep1_rst;
   input ep2_rst;
   input ep3_rst;

   wire  rst = ep0_rst | ep1_rst | ep2_rst | ep3_rst;


   //EPx treat output inst as nop
   output ep0_inst_mask;
   output ep1_inst_mask;
   output ep2_inst_mask;
   output ep3_inst_mask;
   
   
   output [63:0] simd_inst_out;
   output 	 simd_inst_valid;
   output 	 simd_force_stall;
   reg 		 simd_force_stall;
      
   input [63:0]  ep0_inst_in;
   input	 ep0_inst_valid;
   input 	 ep0_simd_req;
   input 	 ep0_simd_mine;
   input 	 ep0_simd_stall;
   
   input [63:0]  ep1_inst_in;
   input	 ep1_inst_valid;
   input 	 ep1_simd_req;
   input 	 ep1_simd_mine;
   input 	 ep1_simd_stall;
      
   input [63:0]  ep2_inst_in;
   input	 ep2_inst_valid;
   input 	 ep2_simd_req;
   input 	 ep2_simd_mine;
   input 	 ep2_simd_stall;

   input [63:0]  ep3_inst_in;
   input	 ep3_inst_valid;
   input 	 ep3_simd_req;
   input 	 ep3_simd_mine;
   input 	 ep3_simd_stall;

   //reg [1:0] 	 whose_the_boss;
   reg 		 ep0_the_boss;
   reg 		 ep1_the_boss;
   reg 		 ep2_the_boss;
   reg 		 ep3_the_boss;
      
   reg 		 simd_mode;
   wire [1:0] 	 whose_the_boss_nxt;
   wire 	 simd_mode_nxt;
   
   reg [63:0] r_simd_inst_out;
   reg 	      r_simd_inst_valid;
   reg [63:0] simd_inst_out_nxt;
   reg 	      simd_inst_valid_nxt;
   
   assign simd_inst_out = r_simd_inst_out;
   assign simd_inst_valid = r_simd_inst_valid /*& ~(ep0_fetch_stall | ep1_fetch_stall | 
		ep2_fetch_stall | ep3_fetch_stall)*/;

   reg 	      ep0_simd_req_r;
   reg 	      ep1_simd_req_r;
   reg 	      ep2_simd_req_r;
   reg 	      ep3_simd_req_r;
   
   //How to get into SIMD mode
   wire       simd_enter = 
	      (ep0_simd_req | ep0_simd_req_r) & 
	      (ep1_simd_req | ep1_simd_req_r) & 
	      (ep2_simd_req | ep2_simd_req_r) & 
	      (ep3_simd_req | ep3_simd_req_r);
   
   assign whose_the_boss_nxt = simd_enter ? (ep0_simd_mine ? 2'b00 : ep1_simd_mine ? 2'b01 :
					     ep2_simd_mine ? 2'b10 : 2'b11) :
			       2'd0;

   always@(posedge CLK or posedge rst)
     begin
	if(rst) begin
	   ep0_simd_req_r <= 1'b0;
	   ep1_simd_req_r <= 1'b0;
	   ep2_simd_req_r <= 1'b0;
	   ep3_simd_req_r <= 1'b0;
	end
	else
	  begin
	     ep0_simd_req_r <= ~simd_enter & (ep0_simd_req | ep0_simd_req_r);
	     ep1_simd_req_r <= ~simd_enter & (ep1_simd_req | ep1_simd_req_r);
	     ep2_simd_req_r <= ~simd_enter & (ep2_simd_req | ep2_simd_req_r);
	     ep3_simd_req_r <= ~simd_enter & (ep3_simd_req | ep3_simd_req_r);
	  end // else: !if(rst)
     end // always@ (posedge CLK or posedge rst)

   wire simd_exit_inst = 
	(simd_inst_out[63:56] == `X_JUMPSCALAR) |
	(simd_inst_out[63:56] == `X_JFETCH_A_I) |
	(simd_inst_out[63:56] == `X_JFETCH_A_R) |
	(simd_inst_out[63:56] == `X_JFETCH_R_I) |
	(simd_inst_out[63:56] == `X_JFETCH_R_R);

   
   //How to bail from SIMD mode
   wire       simd_exit = simd_exit_inst & simd_inst_valid;
   

   assign simd_mode_nxt = simd_mode ?  ~simd_exit : simd_enter;


   wire       ep0_boss = ((ep0_the_boss) & ep0_inst_valid);
   wire       ep1_boss = ((ep1_the_boss) & ep1_inst_valid);
   wire       ep2_boss = ((ep2_the_boss) & ep2_inst_valid);
   wire       ep3_boss = ((ep3_the_boss) & ep3_inst_valid);
   
   wire [7:0] boss_opcode = 
	       ep0_boss ? ep0_inst_in[63:56] :
	       ep1_boss ? ep1_inst_in[63:56] :
	       ep2_boss ? ep2_inst_in[63:56] :
	       ep3_boss ? ep3_inst_in[63:56] :
	       8'd0;
   
   wire        is_jump = 
	(boss_opcode == `X_JUMP_R) | 
	(boss_opcode == `X_JUMP_A) |
	(boss_opcode == `X_JUMPS_R) |
	(boss_opcode == `X_JUMPS_A) |
	(boss_opcode == `X_JUMPC_R) |
	(boss_opcode == `X_JUMPC_A);
    
   wire        is_loopi = 
	(boss_opcode == `X_LOOP_RI) | 
	(boss_opcode == `X_LOOP_AI) |
	(boss_opcode == `X_LOOPS_RI) |
	(boss_opcode == `X_LOOPS_AI) |
	(boss_opcode == `X_LOOPC_RI) |
	(boss_opcode == `X_LOOPC_AI);
   
   wire        is_loop = 
	(boss_opcode == `X_LOOPS_R) |
	(boss_opcode == `X_LOOPS_A) |
	(boss_opcode == `X_LOOPC_R) |
	(boss_opcode == `X_LOOPC_A) |
 	(boss_opcode == `X_LOOPS_RI) |
	(boss_opcode == `X_LOOPS_AI) |
	(boss_opcode == `X_LOOPC_RI) |
	(boss_opcode == `X_LOOPC_AI);


   wire is_boss_ctrl_op =
	(is_jump | is_loopi | is_loop);

   reg 	ep0_inst_mask;
   reg 	ep1_inst_mask;
   reg 	ep2_inst_mask;
   reg 	ep3_inst_mask;
   
   //CP: step 1
   
   assign ep0_inst_mask_nxt = ~simd_force_stall ? (~ep0_boss & is_boss_ctrl_op) : ep0_inst_mask;
   assign ep1_inst_mask_nxt = ~simd_force_stall ? (~ep1_boss & is_boss_ctrl_op) : ep1_inst_mask; 
   assign ep2_inst_mask_nxt = ~simd_force_stall ? (~ep2_boss & is_boss_ctrl_op) : ep2_inst_mask; 
   assign ep3_inst_mask_nxt = ~simd_force_stall ? (~ep3_boss & is_boss_ctrl_op) : ep3_inst_mask;
 
   //Combinational for when in SIMD mode....
   always@(*)
     begin
	simd_inst_out_nxt = 64'd0;
	simd_inst_valid_nxt = 1'b0;
	simd_force_stall = 1'b0;
	if(simd_mode) begin
	   if(~(ep0_simd_stall | ep1_simd_stall | 
		ep2_simd_stall | ep3_simd_stall)) begin
	      if(ep0_the_boss & ep0_inst_valid)
		begin
		   simd_inst_out_nxt = ep0_inst_in;
		   simd_inst_valid_nxt = 1'b1;
		end
	      else if (ep1_the_boss & ep1_inst_valid)
		begin
		   simd_inst_out_nxt = ep1_inst_in;
		   simd_inst_valid_nxt = 1'b1;
		end
	      else if(ep2_the_boss == 2'd2 & ep2_inst_valid)
		begin
		   simd_inst_out_nxt = ep2_inst_in;
		   simd_inst_valid_nxt = 1'b1;
		end
	      else if(ep3_the_boss == 2'd3 & ep0_inst_valid)
		begin
		   simd_inst_out_nxt = ep3_inst_in;
		   simd_inst_valid_nxt = 1'b1;
		end
	   end // if (~(ep0_simd_stall | ep1_simd_stall |...
	   else
	     begin
		simd_force_stall = 1'b1;
		simd_inst_out_nxt = simd_inst_out;
		simd_inst_valid_nxt = 1'b1;
	     end
	end // if (simd_mode)
	else
	  simd_force_stall = 1'b1;
     end

   
   
   always@(posedge CLK or posedge rst)
     begin
     if(rst)
       begin
	  simd_mode <= 1'b0;
	  //whose_the_boss <= 2'd0;
	  ep0_the_boss <= 1'b0;
	  ep1_the_boss <= 1'b0;
	  ep2_the_boss <= 1'b0;
	  ep3_the_boss <= 1'b0;
	  ep0_inst_mask <= 1'b0;
	  ep1_inst_mask <= 1'b0;
	  ep2_inst_mask <= 1'b0;
	  ep3_inst_mask <= 1'b0;
	  r_simd_inst_out <= 64'd0;
	  r_simd_inst_valid <= 1'b0;
       end
     else
       begin
	  simd_mode <= simd_mode_nxt;
	  ep0_the_boss <= whose_the_boss_nxt == 2'b00;
	  ep1_the_boss <= whose_the_boss_nxt == 2'b01;
	  ep2_the_boss <= whose_the_boss_nxt == 2'b10;
	  ep3_the_boss <= whose_the_boss_nxt == 2'b11;
	  ep0_inst_mask <= ep0_inst_mask_nxt;
	  ep1_inst_mask <= ep1_inst_mask_nxt;
	  ep2_inst_mask <= ep2_inst_mask_nxt;
	  ep3_inst_mask <= ep3_inst_mask_nxt;
	  r_simd_inst_out <= simd_inst_out_nxt;
	  r_simd_inst_valid <= simd_inst_valid_nxt;
       end
     end // always@ (posedge CLK or posedge rst)
      






endmodule // simd_unit
