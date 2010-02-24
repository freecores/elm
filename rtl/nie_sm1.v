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

module nie_sm1(/*AUTOARG*/
   // Outputs
   nie_sm1_for_nA_vc2_r, nie_sm1_for_nA_vc2_h, nie_sm1_for_nA_vc2_d, 
   nie_sm1_for_nB_vc2_r, nie_sm1_for_nB_vc2_h, nie_sm1_for_nB_vc2_d, 
   nie_sm1_for_nA_vc3_r, nie_sm1_for_nA_vc3_h, nie_sm1_for_nA_vc3_d, 
   nie_sm1_for_nB_vc3_r, nie_sm1_for_nB_vc3_h, nie_sm1_for_nB_vc3_d, 
   nA_vc1_incoming_read, nB_vc1_incoming_read, nie_sm1_mem_req, 
   nie_sm1_mem_wen_b, nie_sm1_mem_lock, nie_sm1_mem_addr, 
   nie_sm1_mem_write_data, nie_sm1_mem_write_mask, 
   // Inputs
   CLK, rst, nie_sm1_for_nA_vc2_gnt, nie_sm1_for_nB_vc2_gnt, 
   nie_sm1_for_nA_vc3_gnt, nie_sm1_for_nB_vc3_gnt, nA_vc1_incoming_e, 
   nA_vc1_incoming_d, nB_vc1_incoming_e, nB_vc1_incoming_d, 
   nie_sm1_mem_read_data, nie_sm1_mem_gnt
   );

   parameter who_am_i = 6'b101100;
   parameter my_dst_header = 2'b10;
   parameter nA_dst_header = 2'b00;
   parameter nB_dst_header = 2'b01;
   parameter my_addr_header_30 = 1'b1;
   parameter nA_addr_header_30 = 1'b0;
   parameter nB_addr_header_30 = 1'b0;
   parameter my_addr_header_2916 = 14'd0;
   parameter nA_addr_header_2916 = 14'd1;
   parameter nB_addr_header_2916 = 14'd2;
   parameter nA_node_name = `OCM_NODE_ENS0;
   parameter nB_node_name = `OCM_NODE_ENS1;
  
   	    
   
   input CLK;
   input rst;

   //For sending out on vc2
   output        nie_sm1_for_nA_vc2_r;
   output 	 nie_sm1_for_nA_vc2_h;
   output [32:0] nie_sm1_for_nA_vc2_d;
   input         nie_sm1_for_nA_vc2_gnt;

   output        nie_sm1_for_nB_vc2_r;
   output 	 nie_sm1_for_nB_vc2_h;
   output [32:0] nie_sm1_for_nB_vc2_d;
   input         nie_sm1_for_nB_vc2_gnt;
   
   //For sending out on vc3
   output        nie_sm1_for_nA_vc3_r;
   output 	 nie_sm1_for_nA_vc3_h;
   output [32:0] nie_sm1_for_nA_vc3_d;
   input         nie_sm1_for_nA_vc3_gnt;

   output        nie_sm1_for_nB_vc3_r;
   output 	 nie_sm1_for_nB_vc3_h;
   output [32:0] nie_sm1_for_nB_vc3_d;
   input         nie_sm1_for_nB_vc3_gnt;

   //Sequential
   reg 		 send_to_nA_vc2;
   reg 		 send_to_nA_vc3;
   reg 		 send_to_nB_vc2;
   reg 		 send_to_nB_vc3;

   //Combinational
   reg 		 outgoing_r;
   reg 		 outgoing_h;
   reg [32:0] 	 outgoing_d;
   wire 	 outgoing_gnt;
	 
   assign 	 nie_sm1_for_nA_vc2_r = outgoing_r & send_to_nA_vc2;
   assign 	 nie_sm1_for_nA_vc3_r = outgoing_r & send_to_nA_vc3;
   assign 	 nie_sm1_for_nB_vc2_r = outgoing_r & send_to_nB_vc2;
   assign 	 nie_sm1_for_nB_vc3_r = outgoing_r & send_to_nB_vc3;
   
   assign 	 nie_sm1_for_nA_vc2_h = outgoing_h & send_to_nA_vc2;
   assign 	 nie_sm1_for_nA_vc3_h = outgoing_h & send_to_nA_vc3;
   assign 	 nie_sm1_for_nB_vc2_h = outgoing_h & send_to_nB_vc2;
   assign 	 nie_sm1_for_nB_vc3_h = outgoing_h & send_to_nB_vc3;

   assign 	 nie_sm1_for_nA_vc2_d = send_to_nA_vc2 ? outgoing_d : 33'd0;
   assign 	 nie_sm1_for_nA_vc3_d = send_to_nA_vc3 ? outgoing_d : 33'd0;
   assign 	 nie_sm1_for_nB_vc2_d = send_to_nB_vc2 ? outgoing_d : 33'd0;
   assign 	 nie_sm1_for_nB_vc3_d = send_to_nB_vc3 ? outgoing_d : 33'd0;

   assign 	 outgoing_gnt = (send_to_nA_vc2 & nie_sm1_for_nA_vc2_gnt) |
				  (send_to_nA_vc3 & nie_sm1_for_nA_vc3_gnt) |
				    (send_to_nB_vc2 & nie_sm1_for_nB_vc2_gnt) |
		 (send_to_nB_vc3 & nie_sm1_for_nB_vc3_gnt);

   //For receiving from the networks
   input 	 nA_vc1_incoming_e;
   input [32:0]  nA_vc1_incoming_d;
   output 	 nA_vc1_incoming_read;

   input 	 nB_vc1_incoming_e;
   input [32:0]  nB_vc1_incoming_d;
   output 	 nB_vc1_incoming_read;

   //Sequential
   reg 		 service_A;
   reg 		 service_B;

   //Combinational
   reg 		 incoming_read;
   
   wire [32:0] 	 incoming_d = ({33{service_A}} & nA_vc1_incoming_d) |
				({33{service_B}} & nB_vc1_incoming_d);
   wire 	 incoming_e = (service_A & nA_vc1_incoming_e) |
				(service_B & nB_vc1_incoming_e);
   assign 	 nA_vc1_incoming_read = service_A & incoming_read;
   assign 	 nB_vc1_incoming_read = service_B & incoming_read;
   
   //To/from memory
   output 	 nie_sm1_mem_req;
   output 	 nie_sm1_mem_wen_b;
   output 	 nie_sm1_mem_lock;
   output [15:0] nie_sm1_mem_addr;
   output [63:0] nie_sm1_mem_write_data;
   output [1:0] nie_sm1_mem_write_mask;
   input [63:0]  nie_sm1_mem_read_data;
   input 	 nie_sm1_mem_gnt;

   reg 		 nie_sm1_mem_req;
   reg 		 nie_sm1_mem_wen_b;
   reg 		 nie_sm1_mem_lock;
   reg [15:0] 	 nie_sm1_mem_addr;
   reg [63:0] 	 nie_sm1_mem_write_data;
   reg [1:0] 	 nie_sm1_mem_write_mask;
   
   reg [31:0] 	 cmd_servicing;
   reg [63:0] 	 sram_data;
   reg [7:0] 	 cur_word_cnt;
   reg [15:0] 	 cur_address; //
   reg [15:0] 	 cur_daddr; //
   reg [127:0] 	 scratchpad;
   
   wire [7:0] 	 cur_word_cnt_p1 = cur_word_cnt + 1;
   wire [7:0] 	 cur_word_cnt_p2 = cur_word_cnt + 2;
   wire [15:0] 	 cur_address_p1 = cur_address + 1; //
   wire [15:0] 	 cur_address_p2 = cur_address + 2; //
   wire [15:0] 	 cur_daddr_p1 = cur_daddr + 1; //
   wire [15:0] 	 cur_daddr_p2 = cur_daddr + 2; //
   
   
   parameter 	 st_idle = 6'd0;
   parameter 	 st_service = 6'd1;
   parameter 	 st_read_saddr = 6'd2;
   parameter 	 st_read_header = 6'd3;
   parameter 	 st_read_sram = 6'd4;
   parameter 	 st_read_sendA = 6'd5;
   parameter 	 st_read_sendB = 6'd6;
   parameter 	 st_write_daddr = 6'd7;
   parameter 	 st_write_dataA = 6'd8;
   parameter 	 st_write_dataB = 6'd9;
   parameter 	 st_write_wrSRAM = 6'd10;
   //parameter 	 st_write_rdSRAM = 6'd11;
   parameter 	 st_write_reply = 6'd12;
   parameter 	 st_cns_addr = 6'd13;
   parameter 	 st_cns_rdSRAM = 6'd14;
   parameter 	 st_cns_cmp = 6'd15;
   parameter 	 st_cns_swap = 6'd16;
   parameter 	 st_cns_write = 6'd17;
   parameter 	 st_cns_header = 6'd18;
   parameter 	 st_cns_send_data = 6'd19;
   parameter 	 st_cpy_saddr = 6'd20;
   parameter 	 st_cpy_daddr = 6'd21;
   parameter 	 st_cpyL_rdSRAM_A = 6'd22;
   parameter 	 st_cpyL_rdSRAM_B = 6'd23;
   //parameter 	 st_cpyL_wrrdSRAM = 6'd24;
   parameter 	 st_cpyL_wrSRAM = 6'd25;
   parameter 	 st_cpyL_reply = 6'd26;
   parameter 	 st_cpyG_reply_h = 6'd27;
   parameter 	 st_cpyG_reply_daddr = 6'd28;
   parameter 	 st_cpyG_read = 6'd29;
   parameter 	 st_cpyG_sendA = 6'd30;
   parameter 	 st_cpyG_sendB = 6'd31;

   reg [5:0] 	 state;
   reg [5:0] 	 st_nxt;

   always@(posedge CLK or posedge rst)
     if(rst)
       state <= st_idle;
     else
       state <= st_nxt;
   
    
   always@(*)
     begin
	case(state)
	  st_idle: begin
	     if((nA_vc1_incoming_d[32] & ~nA_vc1_incoming_e) |
		(nB_vc1_incoming_d[32] & ~nB_vc1_incoming_e))
	       st_nxt = st_service;
	     else
	       st_nxt = st_idle;
	  end
	  st_service: begin
	     case(incoming_d[19:16])
	       `OCM_CMD_VC1_READ: st_nxt = st_read_saddr;
	       `OCM_CMD_VC1_WRITE: st_nxt = st_write_daddr;
	       `OCM_CMD_VC1_CPNSWP: st_nxt = st_cns_addr;
	       `OCM_CMD_VC1_COPY: st_nxt=st_cpy_saddr;
	       default: st_nxt = st_idle;
 	     endcase // case(incoming_d[19:16])
	  end
	  st_read_saddr: begin
	     if(~incoming_e)
	       st_nxt = st_read_header;
	     else
	       st_nxt = st_read_saddr;
	  end
	  st_read_header: begin
	     if(outgoing_gnt)
	       st_nxt = st_read_sram;
	     else
	       st_nxt = st_read_header;
	  end
	  st_read_sram: begin
	     if(nie_sm1_mem_gnt)
	       if(~cur_address[0])
		 st_nxt = st_read_sendA; //send the lsw
	       else
		 st_nxt = st_read_sendB; //send the msw
	     else
	       st_nxt = st_read_sram;
	  end
	  st_read_sendA: begin
	     if(outgoing_gnt) begin
		if(cur_word_cnt_p1 == cmd_servicing[7:0])
		  st_nxt = st_idle;
		else if(cur_word_cnt_p1 > cmd_servicing[7:0])
		  begin
		     st_nxt = st_idle;
		     //$display("ERROR: NIE SM1 too many words read");
		  end
		else
		  st_nxt = st_read_sendB;
	     end
	     else
	       st_nxt = st_read_sendA;
	  end // case: st_read_sendA
	  st_read_sendB: begin
	     if(outgoing_gnt) begin
		if(cur_word_cnt_p1 == cmd_servicing[7:0])
		  st_nxt = st_idle;
		else if (cur_word_cnt_p1 > cmd_servicing[7:0])
		  begin
		     st_nxt = st_idle;
		     //$display("ERROR: NIE SM1 too many words read");
		  end
		else
		  st_nxt = st_read_sram;
	     end // if (outgoing_gnt)
	     else
	       st_nxt = st_read_sendB;
	  end // case: st_read_sendB
	  /////////////////////////////////////////////////////////////////////
	  st_write_daddr: begin
	     if(~incoming_e)
	       st_nxt = st_write_dataA;
	     else
	       st_nxt = st_write_daddr;
	  end
	  st_write_dataA: begin
	     if(~incoming_e)
	       begin
		  if((cur_word_cnt_p1 == cmd_servicing[7:0]) |
		     cur_address[0])
		    st_nxt = st_write_wrSRAM;
		  else
		    st_nxt = st_write_dataB;
	       end
	     else
	       st_nxt = st_write_dataA;
	  end // case: st_write_dataA
	  st_write_dataB: begin
	     if(~incoming_e)
	       st_nxt = st_write_wrSRAM;
	     else
	       st_nxt = st_write_dataB;
	  end
	  st_write_wrSRAM: begin
	     if(nie_sm1_mem_gnt)
	       begin
		  if(cur_word_cnt_p1 == cmd_servicing[7:0] |
		     cur_word_cnt_p2 == cmd_servicing[7:0])
		    st_nxt = st_write_reply;
		  else
		    st_nxt = st_write_dataA;
	       end
	     else
	       st_nxt = st_write_wrSRAM;
	  end // case: st_write_wrSRAM
	  /*st_write_rdSRAM: begin
	     if(nie_sm1_mem_gnt)
	       st_nxt = st_write_wrSRAM;
	     else
	       st_nxt = st_write_rdSRAM;
	  end*/
	  st_write_reply: begin
	     if(outgoing_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_write_reply;
	  end
	  /////////////////////////////////////////////////////////////////////
	  st_cns_addr: begin
	     if(~incoming_e)
	       st_nxt = st_cns_rdSRAM;
	     else
	       st_nxt = st_cns_addr;
	  end
	  st_cns_rdSRAM: begin
	     if(nie_sm1_mem_gnt)
	       st_nxt = st_cns_cmp;
	     else
	       st_nxt = st_cns_rdSRAM;
	  end
	  st_cns_cmp: begin
	     if(~incoming_e)
	       st_nxt = st_cns_swap;
	     else
	       st_nxt = st_cns_cmp;
	  end
	  st_cns_swap: begin
	     if(~incoming_e)
	       if((cur_address[0] & (scratchpad[31:0] == sram_data[63:32]))
	          |(~cur_address[0] & (scratchpad[31:0] == sram_data[31:0])))
		 st_nxt = st_cns_write;
	       else
		 st_nxt = st_cns_header;
	     else
	       st_nxt = st_cns_swap;
	  end
	  st_cns_write: begin
	     if(nie_sm1_mem_gnt)
	       st_nxt = st_cns_header;
	     else
	       st_nxt = st_cns_write;
	  end
	  st_cns_header: begin
	     if(outgoing_gnt)
	       st_nxt = st_cns_send_data;
	     else
	       st_nxt = st_cns_header;
	  end
	  st_cns_send_data: begin
	     if(outgoing_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_cns_send_data;
	  end
	  ////////////////////////////////////////////////////////////////////////
	  st_cpy_saddr: begin
	     if(~incoming_e)
	       st_nxt = st_cpy_daddr;
	     else
	       st_nxt = st_cpy_saddr;
	  end
	  st_cpy_daddr: begin
	     if(~incoming_e)
	       if(incoming_d[30])  //todo: ocm specific
		 st_nxt = st_cpyL_rdSRAM_A;
	       else
		 st_nxt = st_cpyG_reply_h;
	     else
	       st_nxt = st_cpy_daddr ;
	  end
	  st_cpyL_rdSRAM_A: begin
	     if(nie_sm1_mem_gnt) begin
	       if(~(cur_word_cnt_p1 == cmd_servicing[7:0]))
		 case({cur_address[0], cur_daddr[0]})
		   2'b00: st_nxt = st_cpyL_wrSRAM;
		   2'b01: st_nxt = st_cpyL_wrSRAM; //only should happen once!
		   2'b10:
		     if(~scratchpad[33])
		       st_nxt = st_cpyL_rdSRAM_B;
		     else 
		       st_nxt = st_cpyL_wrSRAM;
		   2'b11: st_nxt = st_cpyL_wrSRAM;
		 endcase // case({cur_address[0], cur_daddr[0]})
	       else //one word to go...
		 case({cur_address[0], cur_daddr[0]})
		   2'b00: st_nxt = st_cpyL_wrSRAM;
		   2'b01: st_nxt = st_cpyL_wrSRAM;
		   2'b10: st_nxt = st_cpyL_wrSRAM; //Just need to make sure we write
		   2'b11: st_nxt = st_cpyL_wrSRAM; //the correct word
		 endcase // case({cur_address[0], cur_daddr[0]})
	     end // if (nie_sm1_mem_gnt)
	     else
	       st_nxt = st_cpyL_rdSRAM_A;
	  end // case: st_cpyL_rdSRAM_A
	  st_cpyL_rdSRAM_B: begin
	     if(nie_sm1_mem_gnt)
	       st_nxt = st_cpyL_wrSRAM;
	     else
	       st_nxt = st_cpyL_rdSRAM_B;
	  end
	  /*st_cpyL_wrrdSRAM: begin
	     if(nie_sm1_mem_gnt)
	       st_nxt = st_cpyL_wrSRAM;
	     else
	       st_nxt = st_cpyL_wrrdSRAM;
	  end*/
	  st_cpyL_wrSRAM: begin
	     if(nie_sm1_mem_gnt)
	       if((cur_word_cnt_p2 == cmd_servicing[7:0] & 
		   ~(cur_daddr[0] & cur_address[0]))
		  |  (cur_word_cnt_p1 == cmd_servicing[7:0]))
		 st_nxt = st_cpyL_reply;
	       else
		 st_nxt = st_cpyL_rdSRAM_A;
	     else
	       st_nxt = st_cpyL_wrSRAM;
	  end
	  st_cpyL_reply: begin
	     if(outgoing_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_cpyL_reply;
	  end
	  //////////////////////////////////////////////////////////
	  st_cpyG_reply_h: begin
	     if(outgoing_gnt)
	       st_nxt = st_cpyG_reply_daddr;
	     else
	       st_nxt = st_cpyG_reply_h;
	  end
	  st_cpyG_reply_daddr: begin
	     if(outgoing_gnt)
	       st_nxt = st_cpyG_read;
	     else
	       st_nxt = st_cpyG_reply_daddr;
	  end
	  st_cpyG_read: begin
	     if(nie_sm1_mem_gnt)
	       if(~cur_address[0])
		 st_nxt = st_cpyG_sendA;
	       else
		 st_nxt = st_cpyG_sendB;
	     else
	       st_nxt = st_cpyG_read;
	  end
	  st_cpyG_sendA: begin
	     if(outgoing_gnt)
	       if(cur_word_cnt_p1 == cmd_servicing[7:0])
		 st_nxt = st_idle;
	       else
		 st_nxt = st_cpyG_sendB;
	     else
	       st_nxt = st_cpyG_sendA;
	  end
	  st_cpyG_sendB: begin
	     if(outgoing_gnt)
	       if(cur_word_cnt_p1 == cmd_servicing[7:0])
		 st_nxt = st_idle;
	       else
		 st_nxt = st_cpyG_read;
	     else
	       st_nxt = st_cpyG_sendB;
	  end
	  default: begin
	     st_nxt = st_idle;
	  end
	endcase // case(state)
     end // always@ (*)
   
   

   always@(posedge CLK or posedge rst)
     begin
	if(rst) begin
	   send_to_nA_vc2 <= 1'b0;
	   send_to_nA_vc3 <= 1'b0;
	   send_to_nB_vc2 <= 1'b0;
	   send_to_nB_vc3 <= 1'b0;
	   service_A <= 1'b0;
	   service_B <= 1'b0;
	   cmd_servicing <= 32'd0;
	   sram_data <= 64'd0;
	   cur_word_cnt <= 8'd0;
	   cur_address <= 16'd0;
	   cur_daddr <=16'd0;
	   scratchpad <= 128'd0;
	end
	else begin
	   case(state)
	     st_idle: begin
		send_to_nA_vc2 <= 1'b0;
		send_to_nA_vc3 <= 1'b0;
		send_to_nB_vc2 <= 1'b0;
		send_to_nB_vc3 <= 1'b0;
		if(st_nxt == st_service) begin
		   service_A <= ~nA_vc1_incoming_e;
		   //A has complete priority over B
		   service_B <=  nA_vc1_incoming_e;  
		end
	
	     end // case: st_idle
	     st_service: begin
		sram_data <=  64'd0;
		cur_word_cnt <= 8'd0;
		cur_address <= 16'd0;
		cur_daddr <= 16'd0;
		scratchpad <=  128'd0;
		if(st_nxt != st_service) begin
		   send_to_nA_vc3 <= does_this_dst_goto_nA(incoming_d[25:20]);
		   send_to_nB_vc3 <= does_this_dst_goto_nB(incoming_d[25:20]);
		   cmd_servicing <= incoming_d[31:0];
		end
	     end
	     st_read_saddr: begin
		if(st_nxt != st_read_saddr) begin
		   cur_word_cnt <= 8'd0;
		   cur_address <=  incoming_d[15:0];
		end
	     end
	     st_read_header: begin
	     end
	     st_read_sram: begin
		if(st_nxt != st_read_sram) begin
		   scratchpad[0] <= cur_address[0];
		   scratchpad[32] <= 1'b1;
		end
	     end
	     st_read_sendA: begin
		if(scratchpad[32]) begin
		   sram_data <= nie_sm1_mem_read_data;
		   scratchpad[32] <= 1'b0;
		end
		if(st_nxt != st_read_sendA) begin
		   cur_word_cnt <= cur_word_cnt_p1;
		   cur_address <= cur_address_p1;
		end
	     end
	     st_read_sendB: begin
		if(scratchpad[32]) begin
		   sram_data <= nie_sm1_mem_read_data;
		   scratchpad[32] <= 1'b0;
		end
		if(st_nxt != st_read_sendB) begin
		   cur_word_cnt <= cur_word_cnt_p1;
		   cur_address <= cur_address_p1;
		end
	     end
	     st_write_daddr: begin
		if(st_nxt != st_write_daddr)
		  cur_address <= incoming_d[15:0];
	     end
	     st_write_dataA: begin
		if(st_nxt != st_write_dataA) begin
		   if(cur_address[0])
		     sram_data[63:32] <= incoming_d[31:0];
		   else
		     sram_data[31:0] <= incoming_d[31:0];
		   scratchpad[32]<= 1'b0;
		   scratchpad[0] <= cur_address[0];
		end
	     end
	     st_write_dataB: begin
		if(st_nxt != st_write_dataB) begin
		   sram_data[63:32] <= incoming_d[31:0];
		end
	     end
	     st_write_wrSRAM: begin
		/*if(scratchpad[32]) begin
		  scratchpad[32] <= 1'b0;
		  sram_data <= scratchpad[0] ? 
			{sram_data[63:32], nie_sm1_mem_read_data[31:0]} :
			{nie_sm1_mem_read_data[63:32], sram_data[31:0]};
		end*/
		if(st_nxt != st_write_wrSRAM) begin
		   cur_word_cnt <= scratchpad[0] ? cur_word_cnt_p1 :
				   cur_word_cnt_p2;
		   cur_address <= scratchpad[0] ? cur_address_p1 :
				  cur_address_p2;
		end
	     end // case: st_write_wrSRAM
	     /*st_write_rdSRAM: begin
		if(st_nxt != st_write_rdSRAM)
		  scratchpad[33] <= 1'b1;
	     end*/
	     st_write_reply: begin
	     end
	     st_cns_addr: begin
		if(st_nxt != st_cns_addr)
		  cur_address <= incoming_d[15:0];
	     end
	     st_cns_rdSRAM: begin
		scratchpad[32] <= 1'b1;
	     end
	     st_cns_cmp: begin
		if(scratchpad[32]) begin
		   scratchpad[32] <= 1'b0;
		   sram_data <= nie_sm1_mem_read_data;
		end
		if(st_nxt != st_cns_cmp) begin
		   scratchpad[31:0] <= incoming_d[31:0];
		end
	     end
	     st_cns_swap: begin
		if(st_nxt != st_cns_swap)
		  scratchpad[31:0] <= incoming_d[31:0];
	     end
	     st_cns_write: begin
	     end
	     st_cns_header: begin
	     end
	     st_cns_send_data: begin
	     end // case: st_cns_send_data
	     /////////////////////////////////////////////////// 
	     st_cpy_saddr: begin
		if(st_nxt != st_cpy_saddr) begin
		   cur_address <= incoming_d[15:0];
		end
		scratchpad <= 128'd0;
	     end // case: st_cpy_saddr
	     st_cpy_daddr: begin
		//Dont care right now
		//cur_word_cnt <=   ;
		//cur_address <=   ;
		if(st_nxt == st_cpyL_rdSRAM_A)
		  cur_daddr <= incoming_d[15:0];
		if(st_nxt == st_cpyG_reply_h) begin
		   scratchpad[31:0] <= incoming_d[31:0];
		   send_to_nA_vc2 <= does_this_addr_goto_nA(incoming_d[31:0]);
		   send_to_nB_vc2 <= does_this_addr_goto_nB(incoming_d[31:0]);
		   send_to_nA_vc3 <= 1'b0;
		   send_to_nB_vc3 <= 1'b0;
		end
	     end
	     //////////////////////////////////////////////////////
	     
	     st_cpyL_rdSRAM_A: begin
		//if read or write shifted? write_data 
		//needs to equal {lsw,scratch[w0]}
		//and scratch[w0] gets msb
		if(~(st_nxt == st_cpyL_rdSRAM_A)) begin
		   scratchpad[32] <= 1'b1;
		   scratchpad[41:36] <= st_cpyL_rdSRAM_A;
		     end
	     end
	     st_cpyL_rdSRAM_B: begin
		if(scratchpad[32]) begin
		   sram_data[31:0]  <= nie_sm1_mem_read_data[63:32];
		   scratchpad[31:0] <= nie_sm1_mem_read_data[63:32];
		   scratchpad[32] <= 1'b0;
		end
		if(~(st_nxt == st_cpyL_rdSRAM_B)) begin
		   scratchpad[41:36] <= st_cpyL_rdSRAM_B;
		   cur_address <= cur_address_p2;
		   scratchpad[33] <= 1'b1;
		   scratchpad[32] <= 1'b1;
		end
	     end
	     /*st_cpyL_wrrdSRAM: begin
		if(scratchpad[32]) begin
		   case({cur_address[0], cur_daddr[0]})
		     2'b00: begin //last word of a dual read
			sram_data[31:0] <=nie_sm1_mem_read_data[31:0];  
		     end
		     2'b01: begin //
			sram_data[63:32] <=nie_sm1_mem_read_data[31:0];
			scratchpad[31:0] <=nie_sm1_mem_read_data[63:32];
			scratchpad[33] <= 1'b1;
		     end
		     2'b10: begin //
			sram_data[31:0] <= scratchpad[31:0];
		     end
		     2'b11: begin //
			sram_data[63:32] <=nie_sm1_mem_read_data[63:32];
		     end
		   endcase // case({cur_address[0], cur_daddr[0]})
		   scratchpad[32] <= 1'b0;
		end // if (sratchpad[32])
	      if(~(st_nxt == st_cpyL_wrrdSRAM)) begin
	      scratchpad[41:36] <= st_cpyL_wrrdSRAM;
	      scratchpad[32] <= 1'b1;
		end
	     end*/
	     st_cpyL_wrSRAM: begin
		if(scratchpad[32]) begin
		   if(scratchpad[41:36] == st_cpyL_rdSRAM_A) begin
		      case({cur_address[0], cur_daddr[0]})
			2'b00: sram_data <= nie_sm1_mem_read_data;
			2'b01: begin
			   sram_data[63:32] <=  nie_sm1_mem_read_data[31:0];
			   sram_data[31:0] <= scratchpad[31:0];
			   scratchpad[31:0] <=nie_sm1_mem_read_data[63:32];
			end
			2'b10: begin
			   sram_data[63:32] <=nie_sm1_mem_read_data[31:0];
			   sram_data[31:0] <= (cur_word_cnt_p1 == cmd_servicing[7:0] 
					       & ~scratchpad[33]) ?
				       nie_sm1_mem_read_data[63:32] : scratchpad[31:0];
			   scratchpad[31:0] <=nie_sm1_mem_read_data[63:32];
			end
			2'b11: sram_data <= nie_sm1_mem_read_data;
		      endcase // case({cur_address[0], cur_daddr[0]})
		   end // if (scratchpad[41:36] == st_cpyL_rdSRAM_A)
		   /*  else if(scratchpad[41:36] == st_cpyL_wrrdSRAM)
		       begin
		       case({cur_address[0], cur_daddr[0]})
		       2'b00: begin
		       sram_data[63:32] <=nie_sm1_mem_read_data[63:32];
			  end
		       2'b01: begin
		       sram_data[31:0] <=nie_sm1_mem_read_data[31:0];
			  end
		       2'b10: begin
		       sram_data[63:32] <=nie_sm1_mem_read_data[63:32];
			  end
		       2'b11: begin
		       sram_data[31:0] <=nie_sm1_mem_read_data[31:0];
			  end
			endcase // case({cur_address[0], cur_daddr[0]})
		     end // if (scratchpad[41:36] == st_cpyL_wrrdSRAM)
		       */
		   else if(scratchpad[41:36] == st_cpyL_rdSRAM_B) begin
		      sram_data[63:32] <=nie_sm1_mem_read_data[31:0];
		      scratchpad[31:0] <=nie_sm1_mem_read_data[63:32];
		   end
		   scratchpad[32] <= 1'b0;
		end // if (scratchpad[32])
		if(~(st_nxt == st_cpyL_wrSRAM)) begin			
		      cur_word_cnt <= cur_daddr[0] ? cur_word_cnt_p1 : 
				      cur_word_cnt_p2;
 		      cur_address <= cur_daddr[0] ? cur_address_p1 :
				     cur_address_p2;
		      cur_daddr <= cur_daddr[0] ? cur_daddr_p1 :
				   cur_daddr_p2;
		   end
		   //ONLY ADD 1 if ~saddr & daddr
		   //ONLY ADD 1 if both addr[0]==1
		   //ADD 2 OTHERWISE
		end
		st_cpyL_reply: begin
		   //get the hell out of here...
		   scratchpad[33] <= 1'b0;
		end // case: st_cpyL_reply
	     ///////////////////////////////////////////////////////////
	     st_cpyG_reply_h: begin
	     end // case: st_cpyG_reply_h
	     //daddr is currently hidden in scratchpad[31:0]
	     st_cpyG_reply_daddr: begin
	     end
	     st_cpyG_read: begin
		if(st_nxt != st_cpyG_read) begin
		   scratchpad[0] <= cur_address[0];
		   scratchpad[32] <= 1'b1;
		end
	     end
	     st_cpyG_sendA: begin
		if(scratchpad[32]) begin
		   sram_data <= nie_sm1_mem_read_data;
		   scratchpad[32] <= 1'b0;
		end
		if(st_nxt != st_cpyG_sendA) begin
		   cur_word_cnt <= cur_word_cnt_p1;
		   cur_address <= cur_address_p1;
		end
	     end
	     st_cpyG_sendB: begin
		if(scratchpad[32]) begin
		   sram_data <= nie_sm1_mem_read_data;
		   scratchpad[32] <= 1'b0;
		end
		if(st_nxt != st_cpyG_sendB) begin
		   cur_word_cnt <= cur_word_cnt_p1;
		   cur_address <= cur_address_p1;
		end
	     end
	     default: begin
	     end
	   endcase // case(state)
	end // else: !if(rst)
     end // always@ (posedge CLK)
   
   always@(*)
     begin
	case(state)
	  st_idle: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_service: begin
	     outgoing_r =1'b0;
	     outgoing_h =1'b0;
	     outgoing_d =33'd0;
	     
	     incoming_read =1'b1;
	     
	     nie_sm1_mem_req =1'b0;
	     nie_sm1_mem_wen_b =1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'b0;
	     nie_sm1_mem_write_data =64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_read_saddr: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read =1'b1;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b0;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr = 16'b0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_read_header: begin
	     outgoing_r = 1'b1;
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b1, cmd_servicing[25:20], cmd_servicing[31:26], 
			    `OCM_CMD_VC3_READ_P, cmd_servicing[15:0]};
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock = 1'b0;
	     nie_sm1_mem_addr = 16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_read_sram: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b1;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b1;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock = 1'b0;
	     nie_sm1_mem_addr = cur_address[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_read_sendA: begin
	     outgoing_r = ~scratchpad[32];
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b0, sram_data[31:0]};
	     
	     incoming_read =  1'b0 ;
		     
	     nie_sm1_mem_req =  1'b0 ;
	     nie_sm1_mem_wen_b =  1'b1 ;
	     nie_sm1_mem_lock = 1'b0  ;
	     nie_sm1_mem_addr =  16'd0 ;
	     nie_sm1_mem_write_data = 64'd0  ;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_read_sendB: begin
	     outgoing_r = ~scratchpad[32];
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b0, sram_data[63:32]};
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_write_daddr: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b1;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_write_dataA: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b1;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_write_dataB: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b1;
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_write_wrSRAM: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b1;
	     nie_sm1_mem_wen_b = 1'b0;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr = cur_address[15:0];
	     nie_sm1_mem_write_data = sram_data[63:0];
	     if(cur_address[0])
	       nie_sm1_mem_write_mask = 2'b01;
	     else if(cur_word_cnt_p1 == cmd_servicing[7:0])
	       nie_sm1_mem_write_mask = 2'b10;
	     else
	       nie_sm1_mem_write_mask = 2'd0;
	  end
	  /*st_write_rdSRAM: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b1;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =cur_address[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     	     nie_sm1_mem_write_mask = 64'd0;
	  end*/
	  st_write_reply: begin
	     outgoing_r = 1'b1;
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b1, cmd_servicing[25:20], cmd_servicing[31:26],
			    `OCM_CMD_VC3_WRITE_P, cmd_servicing[15:0]};
	     
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_addr: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b1;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_rdSRAM: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b1;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b1;
	     nie_sm1_mem_addr =cur_address[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_cmp: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b1;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b1;
	     nie_sm1_mem_addr = cur_address[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_swap: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b1;
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b1;
	     nie_sm1_mem_addr =cur_address[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_write: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b1;
	     nie_sm1_mem_wen_b = 1'b0;
	     nie_sm1_mem_lock =1'b1;
	     nie_sm1_mem_addr = cur_address[15:0];
	     nie_sm1_mem_write_data =  cur_address[0] ? 
				 {scratchpad[31:0],sram_data[31:0]} :
				 {sram_data[63:32],scratchpad[31:0]};
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_header: begin
	     outgoing_r = 1'b1;
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b1, cmd_servicing[25:20], cmd_servicing[31:26], 
			    `OCM_CMD_VC3_CPNSWP_P, cmd_servicing[15:0]};
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_send_data: begin
	     outgoing_r = 1'b1;
	     outgoing_h = 1'b1;
	     outgoing_d[32] = 1'b0;
	     outgoing_d[31:0] = cur_address[0] ? sram_data[63:32] : sram_data[31:0];
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end // case: st_cns_send_data
	  
	  st_cpy_saddr: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b1;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock = 1'b0;
	     nie_sm1_mem_addr = 16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end // case: st_cpy_saddr
	  st_cpy_daddr: begin
	     outgoing_r =1'b0;
	     outgoing_h =1'b0;
	     outgoing_d =33'd0;
	     incoming_read = 1'b1;
	     nie_sm1_mem_req =1'b0 ;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock = 1'b0;
	     nie_sm1_mem_addr = 16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end // case: st_cpy_daddr
	  /////////////////////////////
	  st_cpyL_rdSRAM_A: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0;
	     nie_sm1_mem_req =1'b1 ;
	     nie_sm1_mem_wen_b =1'b1;
	     nie_sm1_mem_lock = 1'b1;
	     nie_sm1_mem_addr = cur_address[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cpyL_rdSRAM_B: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0 ;

	     nie_sm1_mem_req = ~scratchpad[32];
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock = 1'b1;
	     nie_sm1_mem_addr = cur_address_p2[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cpyL_wrSRAM: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0;
	     nie_sm1_mem_req =  ~scratchpad[32] ;
	     nie_sm1_mem_wen_b = 1'b0;
	     nie_sm1_mem_lock =  1'b1;
	     nie_sm1_mem_addr = cur_daddr[15:0];
	     /*cur_address[0], cur_daddr[0]})
	      3'b000: nie_sm1_mem_write_data = sram_data[63
	      3'b001: nie_sm1_mem_write_data = 64'h00000000ffffffff;
	      3'b010: nie_sm1_mem_write_data = 64'h0000000000000000;
	      3'b011: nie_sm1_mem_write_data = 64'h00000000ffffffff; //
	      3'b100: nie_sm1_mem_write_data = 64'hffffffff00000000; //
	      3'b101: nie_sm1_mem_write_data = 64'h00000000ffffffff; //
	      3'b110: nie_sm1_mem_write_data = 64'hffffffff00000000; //
	      3'b111: nie_sm1_mem_write_data = 64'h00000000ffffffff; //
	      default: nie_sm1_mem_write_mask = 64'd0;
	     endcase // case({cur_word_cnt_p1 == cmd_servicing[7:0],... */
	     nie_sm1_mem_write_data = sram_data[63:0];
	     case({cur_word_cnt_p1 == cmd_servicing[7:0],
		   cur_address[0], cur_daddr[0]})
	       3'b000: nie_sm1_mem_write_mask = 2'b00;
	       3'b001: nie_sm1_mem_write_mask = 2'b01;
	       3'b010: nie_sm1_mem_write_mask = 2'b00;
	       3'b011: nie_sm1_mem_write_mask = 2'b01; //
	       3'b100: nie_sm1_mem_write_mask = 2'b10; //
	       3'b101: nie_sm1_mem_write_mask = 2'b01; //
	       3'b110: nie_sm1_mem_write_mask = 2'b10; //
	       3'b111: nie_sm1_mem_write_mask = 2'b01; //
	       default: nie_sm1_mem_write_mask = 2'd0;
	     endcase // case({cur_word_cnt_p1 == cmd_servicing[7:0],...
	     /*
	     if(cur_address[0] & cur_daddr[0])
	       nie_sm1_mem_write_mask = 64'h00000000ffffffff;
	     else if(cur_word_cnt_p1 == cmd_servicing[7:0])
	       nie_sm1_mem_write_mask = 64'hffffffff00000000;
	     else
	       nie_sm1_mem_write_mask = 64'd0;*/
	  end
	  st_cpyL_reply: begin
	     outgoing_r = 1'b1;
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b1, cmd_servicing[25:20], cmd_servicing[31:26], 
			    `OCM_CMD_VC3_COPY_P, cmd_servicing[15:0]};
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end // case: st_cpyL_reply
	  //////////////////////////////////////////////////////////
	  st_cpyG_reply_h: begin
	     outgoing_r = 1'b1;
	     outgoing_h = 1'b1;
	     if(send_to_nA_vc2)
	       outgoing_d[32:26] = {1'b1, nA_node_name};
	     else
	       outgoing_d[32:26] = {1'b1, nB_node_name};
	     outgoing_d[25:0] = {cmd_servicing[25:20], `OCM_CMD_VC2_CPYDATA,
				  cmd_servicing[15:0]};
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cpyG_reply_daddr: begin
	     outgoing_r = 1'b1;
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b0,scratchpad[31:0]};
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cpyG_read: begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b1;
	     outgoing_d = 33'd0;
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b1;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b1;
	     nie_sm1_mem_addr = cur_address[15:0];
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cpyG_sendA: begin
	     outgoing_r = ~scratchpad[32];
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b0, sram_data[31:0]};
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  st_cpyG_sendB: begin
	     outgoing_r = ~scratchpad[32];
	     outgoing_h = 1'b1;
	     outgoing_d = {1'b0, sram_data[63:32]};
	     
	     incoming_read = 1'b0;
	     
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end
	  default:  begin
	     outgoing_r = 1'b0;
	     outgoing_h = 1'b0;
	     outgoing_d = 33'd0;
	     incoming_read = 1'b0;
	     nie_sm1_mem_req = 1'b0;
	     nie_sm1_mem_wen_b = 1'b1;
	     nie_sm1_mem_lock =1'b0;
	     nie_sm1_mem_addr =16'd0;
	     nie_sm1_mem_write_data = 64'd0;
	     nie_sm1_mem_write_mask = 2'd0;
	  end // case: default
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

      
   function does_this_addr_goto_nA;
      input [31:0] dst;
      begin
	 if((dst[30] & nA_addr_header_30) | 
	    (dst[29:16] == nA_addr_header_2916))
	   does_this_addr_goto_nA = 1'b1;
	 else
	   does_this_addr_goto_nA = 1'b0;
      end
   endfunction // does_this_goto_nA
   
   function does_this_addr_goto_nB;
      input [31:0] dst;
      begin
	 if((dst[30] & nB_addr_header_30) | 
	    (dst[29:16] == nB_addr_header_2916))
	   does_this_addr_goto_nB = 1'b1;
	 else
	   does_this_addr_goto_nB = 1'b0;
      end
   endfunction

   function does_this_addr_goto_me;
      input [31:0] dst;
      begin
	 if((dst[30] & my_addr_header_30) | 
	    (dst[29:16] == my_addr_header_2916))
	   does_this_addr_goto_me = 1'b1;
	 else
	   does_this_addr_goto_me = 1'b0;
      end
   endfunction

endmodule // nie_sm1
