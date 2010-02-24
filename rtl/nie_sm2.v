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


`include "ocm_defs.v"

module nie_sm2(/*AUTOARG*/
   // Outputs
   nie_sm2_for_nA_vc3_r, nie_sm2_for_nA_vc3_h, nie_sm2_for_nA_vc3_d, 
   nie_sm2_for_nB_vc3_r, nie_sm2_for_nB_vc3_h, nie_sm2_for_nB_vc3_d, 
   nie_sm2_for_se0_vc3_r, nie_sm2_for_se0_vc3_d, 
   nie_sm2_for_se1_vc3_r, nie_sm2_for_se1_vc3_d, 
   /*nie_sm2_for_se2_vc3_r, nie_sm2_for_se2_vc3_d, 
   nie_sm2_for_se3_vc3_r, nie_sm2_for_se3_vc3_d,*/
   nA_vc2_incoming_read, nB_vc2_incoming_read, nie_sm2_mem_req, 
   nie_sm2_mem_addr, nie_sm2_mem_wen_b, nie_sm2_mem_wr_data, 
   nie_sm2_mem_write_mask, 
   // Inputs
   CLK, rst, nie_sm2_for_nA_vc3_gnt, nie_sm2_for_nB_vc3_gnt, 
   nie_sm2_for_se0_vc3_gnt, nie_sm2_for_se1_vc3_gnt, 
   /*nie_sm2_for_se2_vc3_gnt, nie_sm2_for_se3_vc3_gnt,*/ 
   nA_vc2_incoming_e, nA_vc2_incoming_d, nB_vc2_incoming_e, 
   nB_vc2_incoming_d, nie_sm2_mem_rd_data, nie_sm2_mem_gnt
   );

   input CLK;
   input rst;


   //For sending out to the network
   output nie_sm2_for_nA_vc3_r;
   output nie_sm2_for_nA_vc3_h; //technically not needed...
   output [32:0] nie_sm2_for_nA_vc3_d;
   input 	 nie_sm2_for_nA_vc3_gnt;
   
   output 	 nie_sm2_for_nB_vc3_r;
   output 	 nie_sm2_for_nB_vc3_h;
   output [32:0] nie_sm2_for_nB_vc3_d;
   input 	 nie_sm2_for_nB_vc3_gnt;
   
   //For sending to the SEs
   output 	 nie_sm2_for_se0_vc3_r;
   output [32:0] nie_sm2_for_se0_vc3_d;
   input 	 nie_sm2_for_se0_vc3_gnt;
   output 	 nie_sm2_for_se1_vc3_r;
   output [32:0] nie_sm2_for_se1_vc3_d;
   input 	 nie_sm2_for_se1_vc3_gnt;
   //output 	 nie_sm2_for_se2_vc3_r;
   //output [32:0] nie_sm2_for_se2_vc3_d;
   //input 	 nie_sm2_for_se2_vc3_gnt;
   //output 	 nie_sm2_for_se3_vc3_r;
   //output [32:0] nie_sm2_for_se3_vc3_d;
   //input 	 nie_sm2_for_se3_vc3_gnt;
   
   //For reading from the networks
   input 	 nA_vc2_incoming_e;
   input [32:0]  nA_vc2_incoming_d;
   output 	 nA_vc2_incoming_read;

   input 	 nB_vc2_incoming_e;
   input [32:0]  nB_vc2_incoming_d;
   output 	 nB_vc2_incoming_read;

   //For getting to and from the memory
   output 	 nie_sm2_mem_req;
   output [15:0] nie_sm2_mem_addr;
   output 	 nie_sm2_mem_wen_b;
   output [63:0] nie_sm2_mem_wr_data;
   output [1:0] nie_sm2_mem_write_mask;
   input [63:0]  nie_sm2_mem_rd_data;
   input 	 nie_sm2_mem_gnt;

   reg 	 nie_sm2_mem_req;
   reg [15:0] nie_sm2_mem_addr;
   reg 	 nie_sm2_mem_wen_b;
   reg [63:0] nie_sm2_mem_wr_data;
   reg [1:0] nie_sm2_mem_write_mask;
   
   parameter 	 st_idle = 4'd0;
   parameter 	 st_service = 4'd1;
   parameter 	 st_daddr = 4'd2;
   parameter 	 st_dataA = 4'd3;
   parameter 	 st_dataB = 4'd4;
   parameter 	 st_write_SRAM = 4'd5;
   //parameter 	 st_read_SRAM = 4'd6;
   parameter 	 st_respond = 4'd7;
	 
   
   reg [3:0] 	 state;
   reg [3:0] 	 st_nxt;

   reg [31:0] 	 cmd_servicing;
   reg [63:0] 	 sram_data;
   reg [7:0] 	 cur_word_cnt;
   reg [15:0] 	 cur_address;
   reg [1:0] 	 scratchpad;
   
   reg 		 service_A;
   reg 		 service_B;
   
   reg 		 send_to_nA;
   reg 		 send_to_nB;
   reg 		 send_to_se0;
   reg 		 send_to_se1;
   //reg 		 send_to_se2;
   //reg 		 send_to_se3;
   
   reg 		 outgoing_r;
   reg [32:0] 	 outgoing_d;
   reg 		 incoming_read;

   parameter 	 who_am_i = 6'b101100;
   parameter 	 my_dst_header = 2'b10;
   parameter 	 nA_dst_header = 2'b00;
   parameter 	 nB_dst_header = 2'b01;
   
   wire [32:0] 	 in_data = service_A ? nA_vc2_incoming_d : 
		 service_B ? nB_vc2_incoming_d : 33'd0;
   
   wire 	 in_empty = (service_A & nA_vc2_incoming_e) |
			      (service_B & nB_vc2_incoming_e);

   assign   nA_vc2_incoming_read = service_A & incoming_read;
   assign   nB_vc2_incoming_read = service_B & incoming_read;
      

   wire [7:0] 	 cur_word_cnt_p1 = cur_word_cnt + 1;
   wire [7:0] 	 cur_word_cnt_p2 = cur_word_cnt + 2;
   wire [15:0] 	 cur_address_p1 = cur_address + 1;
   wire [15:0] 	 cur_address_p2 = cur_address + 2;
   
   wire out_granted = (send_to_nA & nie_sm2_for_nA_vc3_gnt) |
			(send_to_nB & nie_sm2_for_nB_vc3_gnt) |
			  (send_to_se0 & nie_sm2_for_se0_vc3_gnt) |
	(send_to_se1 & nie_sm2_for_se1_vc3_gnt) /*|
	(send_to_se2 & nie_sm2_for_se2_vc3_gnt) |
	(send_to_se3 & nie_sm2_for_se3_vc3_gnt)*/;
   
   assign nie_sm2_for_nA_vc3_r = send_to_nA & outgoing_r;
   assign nie_sm2_for_nB_vc3_r = send_to_nB & outgoing_r;
   assign nie_sm2_for_se0_vc3_r = send_to_se0 & outgoing_r;
   assign nie_sm2_for_se1_vc3_r = send_to_se1 & outgoing_r;
   //assign nie_sm2_for_se2_vc3_r = send_to_se2 & outgoing_r;
   //assign nie_sm2_for_se3_vc3_r = send_to_se3 & outgoing_r;
   
   assign nie_sm2_for_nA_vc3_d = send_to_nA ? outgoing_d : 33'd0;
   assign nie_sm2_for_nB_vc3_d = send_to_nB ? outgoing_d : 33'd0;
   assign nie_sm2_for_se0_vc3_d = send_to_se0 ? outgoing_d : 33'd0;
   assign nie_sm2_for_se1_vc3_d = send_to_se1 ? outgoing_d : 33'd0;
   //assign nie_sm2_for_se2_vc3_d = send_to_se2 ? outgoing_d : 33'd0;
   //assign nie_sm2_for_se3_vc3_d = send_to_se3 ? outgoing_d : 33'd0;
   
   assign nie_sm2_for_nA_vc3_h = 1'b0; //
   assign nie_sm2_for_nB_vc3_h = 1'b0; // 
  
   always@(posedge CLK or posedge rst)
     begin
	if(rst)
	  state <= st_idle;
	else
	  state <= st_nxt;
     end
   
   always@(*)
     begin
	st_nxt = st_idle;
	case(state)
	  st_idle: begin
	     if((nA_vc2_incoming_d[32] & ~nA_vc2_incoming_e) | 
		(nB_vc2_incoming_d[32] & ~nB_vc2_incoming_e))
	       st_nxt = st_service;
	     else
	       st_nxt = st_idle;
	  end
	  st_service: begin
	     //dont need to check the command...
	     //if(in_data[19:16] == `OCM_CMD_VC2_CPYDATA)
	     st_nxt = st_daddr;
	     //else
	     //ERROR
	  end
	  st_daddr: begin
	     if(~in_empty)
	       st_nxt = st_dataA;
	     else
	       st_nxt = st_daddr;
	  end
	  st_dataA: begin
	     if(~in_empty)
	       begin
		  if(cur_word_cnt_p1 == cmd_servicing[7:0] | 
		     cur_address[0])
		    st_nxt = st_write_SRAM;
		  else
		    st_nxt = st_dataB;
	       end
	     else
	       st_nxt = st_dataA;
	  end // case: st_dataA
	  st_dataB: begin
	     if(~in_empty)
	       st_nxt = st_write_SRAM;
	     else
	       st_nxt = st_dataB;
	  end
	  st_write_SRAM: begin
	     if(nie_sm2_mem_gnt)
	       begin
		  if(cur_word_cnt_p1 == cmd_servicing[7:0] |
		     cur_word_cnt_p2 == cmd_servicing[7:0])
		    st_nxt = st_respond;
		  else
		    st_nxt = st_dataA;
	       end
	     else
	       st_nxt = st_write_SRAM;
	  end // case: st_write_SRAM
	  st_respond: begin
	     if(out_granted)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_respond;
	  end
	  default: begin
	     st_nxt = st_idle;
	  end
	endcase // case(state)
     end // always@ (*)
   	  
   
   always@(posedge CLK or posedge rst)
     begin
	if(rst) begin
	   service_A <= 1'b0;
	   service_B <= 1'b0;
	   sram_data <= 64'd0;
	   cmd_servicing <= 32'd0;
	   cur_word_cnt <= 8'd0;
	   cur_address <= 16'd0;
	   scratchpad <= 2'd0;
	end
	else begin
	   case(state)
	     st_idle: begin
		if(st_nxt == st_service)
		  begin
		     service_A <= ~nA_vc2_incoming_e & nA_vc2_incoming_d[32];
		     service_B <= nA_vc2_incoming_e;
		  end
		else
		  begin
		     service_A <= 1'b0;
		     service_B <= 1'b0;
		  end
		send_to_nA <= 1'b0;
		send_to_nB <= 1'b0;
		send_to_se0 <= 1'b0;
		send_to_se1 <= 1'b0;
		//send_to_se2 <= 1'b0;
		//send_to_se3 <= 1'b0;
	
	     end
	     st_service: begin

		sram_data <= 64'd0;
		cur_word_cnt <= 8'd0;
		cur_address <= 16'd0;
		scratchpad <= 2'd0;
		cmd_servicing <= in_data[31:0];
		send_to_nA <= does_this_dst_goto_nA(in_data[25:20]);
		send_to_nB <= does_this_dst_goto_nA(in_data[25:20]);
		send_to_se0 <= does_this_dst_goto_me(in_data[25:20]) &
			       in_data[23:20] == 4'b1000;
		send_to_se1 <= does_this_dst_goto_me(in_data[25:20]) &
			       in_data[23:20] == 4'b1001;
		/*send_to_se2 <= does_this_dst_goto_me(in_data[25:20]) &
			       in_data[23:20] == 4'b1010;
		send_to_se3 <= does_this_dst_goto_me(in_data[25:20]) &
			       in_data[23:20] == 4'b1011;*/
	     end
	     st_daddr: begin
		if(~(st_nxt == st_daddr)) begin
		   cur_address <= in_data[15:0];
		end
	     end
	     st_dataA: begin
		if(~(st_nxt == st_dataA)) begin
		   if(cur_address[0])
		     sram_data[63:32] <= in_data[31:0];
		   else
		     sram_data[31:0] <= in_data[31:0];
		   scratchpad[1] <= 1'b0;
		   scratchpad[0] <= cur_address[0];
		end
	     end
	     st_dataB: begin
		if(~(st_nxt == st_dataB)) begin
		   sram_data[63:32] <= in_data[31:0];
		end
	     end
	     st_write_SRAM: begin
		if(~(st_nxt == st_write_SRAM)) 
		  begin
		     cur_word_cnt <= scratchpad[0] ? cur_word_cnt_p1 
				     : cur_word_cnt_p2;
		     cur_address  <= scratchpad[0] ? cur_address_p1 
				     : cur_address_p2;
		  end
	     end
	     st_respond: begin
	     end
	     default: begin
	     end
	   endcase // case(state)
	end // else: !if(rst)
     end // always@ (posedge CLK)

   always@(*)
     begin
	outgoing_r = 1'b0;
	outgoing_d = 33'd0;
	incoming_read = 1'b0;
	nie_sm2_mem_req = 1'b0;
	nie_sm2_mem_addr = 16'd0;
	nie_sm2_mem_wen_b = 1'b1;
	nie_sm2_mem_wr_data = 64'd0;
	nie_sm2_mem_write_mask = 2'd0;
	case(state)
	  st_idle: begin
	     outgoing_r = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b0;

	     nie_sm2_mem_req = 1'b0;
	     nie_sm2_mem_addr = 16'd0;
	     nie_sm2_mem_wen_b = 1'b1;
	     nie_sm2_mem_wr_data = 64'd0;
	     nie_sm2_mem_write_mask = 2'd0;
	  end
	  st_service: begin
	     outgoing_r = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b1;
	     
	     nie_sm2_mem_req = 1'b0;
	     nie_sm2_mem_addr = 16'd0;
	     nie_sm2_mem_wen_b = 1'b1;
	     nie_sm2_mem_wr_data = 64'd0;
	     nie_sm2_mem_write_mask = 2'd0;
	  end
	  st_daddr: begin
	     outgoing_r = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b1;

	     nie_sm2_mem_req = 1'b0;
	     nie_sm2_mem_addr = 16'd0;
	     nie_sm2_mem_wen_b = 1'b1;
	     nie_sm2_mem_wr_data = 64'd0;
	     nie_sm2_mem_write_mask = 2'd0;
	  end
	  st_dataA: begin
	     outgoing_r = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b1;

	     nie_sm2_mem_req = 1'b0;
	     nie_sm2_mem_addr = 16'd0;
	     nie_sm2_mem_wen_b = 1'b1;
	     nie_sm2_mem_wr_data = 64'd0;
	     nie_sm2_mem_write_mask = 2'd0;
	  end
	  st_dataB: begin
	     outgoing_r = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b1;

	     nie_sm2_mem_req = 1'b0;
	     nie_sm2_mem_addr = 16'd0;
	     nie_sm2_mem_wen_b = 1'b1;
	     nie_sm2_mem_wr_data = 64'd0;
	     nie_sm2_mem_write_mask = 2'd0;
	  end
	  st_write_SRAM: begin
	     outgoing_r = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0;
	     nie_sm2_mem_req = 1'b1;
	     nie_sm2_mem_addr = cur_address[15:0];
	     nie_sm2_mem_wen_b = 1'b0;
	     nie_sm2_mem_wr_data = sram_data[63:0];
	     if(cur_address[0])
	       nie_sm2_mem_write_mask = 2'b01;
	     else if(cur_word_cnt_p1 == cmd_servicing[7:0])
	       nie_sm2_mem_write_mask = 2'b10;
	     else
	       nie_sm2_mem_write_mask = 2'd0;
	  end
	  st_respond: begin
	     outgoing_r = 1'b1;
	     outgoing_d = {1'b1,cmd_servicing[25:20],who_am_i, 
			    `OCM_CMD_VC3_COPY_P, cmd_servicing[15:0]};
	     incoming_read = 1'b0;
	     nie_sm2_mem_req = 1'b0;
	     nie_sm2_mem_addr = 16'd0;
	     nie_sm2_mem_wen_b = 1'b1;
	     nie_sm2_mem_wr_data = 64'd0;
	     nie_sm2_mem_write_mask = 2'd0;
	  end
	  default: begin
	     outgoing_r = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b0;

	     nie_sm2_mem_req = 1'b0;
	     nie_sm2_mem_addr = 16'd0;
	     nie_sm2_mem_wen_b = 1'b1;
	     nie_sm2_mem_wr_data = 64'd0;
	     nie_sm2_mem_write_mask = 2'd0;
	  end
	endcase // case(state)
     end // always@ (*)

   function does_this_dst_goto_nA;
      input [5:0] dst;
      begin
	 if(dst[5:4] == nA_dst_header)
	   does_this_dst_goto_nA = 1'b1;
	 else
	   does_this_dst_goto_nA = 1'b0;
      end
   endfunction // does_this_goto_nA
   
   function does_this_dst_goto_nB;
      input [5:0] dst;
      begin
	 if(dst[5:4] == nB_dst_header)
	   does_this_dst_goto_nB = 1'b1;
	 else
	   does_this_dst_goto_nB = 1'b0;
      end
   endfunction // does_this_dst_goto_nB

   function does_this_dst_goto_me;
      input [5:0] dst;
      begin
	 if(dst[5:4] == my_dst_header)
	   does_this_dst_goto_me = 1'b1;
	 else
	   does_this_dst_goto_me = 1'b0;
      end
   endfunction // does_this_dst_goto_nB
   
endmodule // nie_sm2
