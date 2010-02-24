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

module epe_sm1(/*AUTOARG*/
   // Outputs
   ep0_outbox_d, ep0_outbox_full, ep1_outbox_d, ep1_outbox_full, 
   ep2_outbox_d, ep2_outbox_full, ep3_outbox_d, ep3_outbox_full, 
   ep0_inbox_read, ep1_inbox_read, ep2_inbox_read, ep3_inbox_read, 
   epe_sm1_mem_req, epe_sm1_mem_wen_b, epe_sm1_mem_lock, 
   epe_sm1_mem_addr, epe_sm1_mem_write_data, epe_sm1_mem_write_mask, 
   // Inputs
   CLK, rst, ep0_outbox_gnt, ep1_outbox_gnt, ep2_outbox_gnt, 
   ep3_outbox_gnt, ep0_inbox_full, ep0_inbox_d, ep1_inbox_full, 
   ep1_inbox_d, ep2_inbox_full, ep2_inbox_d, ep3_inbox_full, 
   ep3_inbox_d, epe_sm1_mem_read_data, epe_sm1_mem_gnt
	       );

   input CLK;
   input rst;
   
   parameter who_am_i = `OCM_NODE_ENS0;
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
  

   //For sending out on vc2
   //output        epe_sm1_for_nA_vc2_r;
   //output 	 epe_sm1_for_nA_vc2_h;
   //output [32:0] epe_sm1_for_nA_vc2_d;
   //input         epe_sm1_for_nA_vc2_gnt;

   //output        epe_sm1_for_nB_vc2_r;
   //output 	 epe_sm1_for_nB_vc2_h;
   //output [32:0] epe_sm1_for_nB_vc2_d;
   //input         epe_sm1_for_nB_vc2_gnt;

   //Anything on VC3 just gets popped into the outbox
   //todo: figure out the outboxes...
   output [121:0] ep0_outbox_d;
   output 	  ep0_outbox_full;
   input 	  ep0_outbox_gnt;
   
   output [121:0] ep1_outbox_d;
   output 	  ep1_outbox_full;
   input 	  ep1_outbox_gnt;
   
   output [121:0] ep2_outbox_d;
   output 	  ep2_outbox_full;
   input 	  ep2_outbox_gnt;
   
   output [121:0] ep3_outbox_d;
   output 	  ep3_outbox_full;
   input 	  ep3_outbox_gnt;
   

   //Sequential
   //reg 		 send_to_nA_vc2;
   //reg 		 send_to_nB_vc2;
   wire 		  send_to_ep0;
   wire			  send_to_ep1;
   wire		 send_to_ep2;
   wire		 send_to_ep3;
   		 
   //Combinational
   //reg 		 outgoing_r;
   //reg 		 outgoing_h;
   //reg [32:0] 	 outgoing_d;
   //wire 	 outgoing_gnt;

   reg [121:0] 	 outbox_d;
   reg 		 outbox_full;
   wire 	 outbox_gnt;
      
   //assign 	 epe_sm1_for_nA_vc2_r = outgoing_r & send_to_nA_vc2;
   //assign 	 epe_sm1_for_nB_vc2_r = outgoing_r & send_to_nB_vc2;
   
   //assign 	 epe_sm1_for_nA_vc2_h = outgoing_h & send_to_nA_vc2;
   //assign 	 epe_sm1_for_nB_vc2_h = outgoing_h & send_to_nB_vc2;

   //assign 	 epe_sm1_for_nA_vc2_d = send_to_nA_vc2 ? outgoing_d : 33'd0;
   //assign 	 epe_sm1_for_nB_vc2_d = send_to_nB_vc2 ? outgoing_d : 33'd0;

   //assign 	 outgoing_gnt = (send_to_nA_vc2 & epe_sm1_for_nA_vc2_gnt) |
   //(send_to_nB_vc2 & epe_sm1_for_nB_vc2_gnt);

   assign 	 ep0_outbox_d = send_to_ep0 ? outbox_d : 122'd0;
   assign 	 ep1_outbox_d = send_to_ep1 ? outbox_d : 122'd0;
   assign 	 ep2_outbox_d = send_to_ep2 ? outbox_d : 122'd0;
   assign 	 ep3_outbox_d = send_to_ep3 ? outbox_d : 122'd0;

   assign 	 ep0_outbox_full = send_to_ep0 & outbox_full;
   assign 	 ep1_outbox_full = send_to_ep1 & outbox_full;
   assign 	 ep2_outbox_full = send_to_ep2 & outbox_full;
   assign 	 ep3_outbox_full = send_to_ep3 & outbox_full;
   
   assign 	 outbox_gnt = (send_to_ep0 & ep0_outbox_gnt) |
				(send_to_ep1 & ep1_outbox_gnt) |
				  (send_to_ep2 & ep2_outbox_gnt) |
		 (send_to_ep3 & ep3_outbox_gnt);
   
   
   //In boxes
   input 	 ep0_inbox_full;
   input [121:0] ep0_inbox_d;
   output 	 ep0_inbox_read;

   input 	 ep1_inbox_full;
   input [121:0] ep1_inbox_d;
   output 	 ep1_inbox_read;

   input 	 ep2_inbox_full;
   input [121:0] ep2_inbox_d;
   output 	 ep2_inbox_read;

   input 	 ep3_inbox_full;
   input [121:0] ep3_inbox_d;
   output 	 ep3_inbox_read;
   
   //Sequential
   reg 		 service_ep0;
   assign 	 send_to_ep0 = service_ep0;
   reg 		 service_ep1;
   assign 	 send_to_ep1 = service_ep1;
   reg 		 service_ep2;
   assign 	 send_to_ep2 = service_ep2;
   reg 		 service_ep3;
   assign 	 send_to_ep3 = service_ep3;
   

   //Combinational
   reg 		 incoming_read;
   wire [121:0]  incoming_d = service_ep0 ? ep0_inbox_d :
		 service_ep1 ? ep1_inbox_d :
		 service_ep2 ? ep2_inbox_d :
		 service_ep3 ? ep3_inbox_d : 122'd0;
   wire 	 incoming_full = service_ep0 ? ep0_inbox_full :
		 service_ep1 ? ep1_inbox_full :
		 service_ep2 ? ep2_inbox_full :
		 service_ep3 ? ep3_inbox_full : 1'd0;

   assign 	 ep0_inbox_read = service_ep0 & incoming_read;
   assign 	 ep1_inbox_read = service_ep1 & incoming_read;
   assign 	 ep2_inbox_read = service_ep2 & incoming_read;
   assign 	 ep3_inbox_read = service_ep3 & incoming_read;

   //to/from memory
   output 	 epe_sm1_mem_req;
   output 	 epe_sm1_mem_wen_b;
   output 	 epe_sm1_mem_lock;
   output [15:0] epe_sm1_mem_addr;
   output [63:0] epe_sm1_mem_write_data;
   output [1:0] epe_sm1_mem_write_mask;
   input [63:0]  epe_sm1_mem_read_data;
   input 	 epe_sm1_mem_gnt;

   reg 		 epe_sm1_mem_req;
   reg 		 epe_sm1_mem_wen_b;
   reg 		 epe_sm1_mem_lock;
   reg [15:0] 	 epe_sm1_mem_addr;
   reg [63:0] 	 epe_sm1_mem_write_data;
   reg [1:0] 	 epe_sm1_mem_write_mask;
   
   //reg [32:0] 	 cmd_servicing;
   reg [7:0] 	 cmd_id;
   reg [7:0] 	 cmd_size;
   //reg [5:0] 	 cmd_dst;
   reg [5:0] 	 cmd_src;
   
   reg [63:0] 	 sram_data;
   reg [7:0] 	 cur_word_cnt;
   reg [15:0] 	 cur_address;
   reg [15:0] 	 cur_daddr;
   reg [127:0] 	 scratchpad;
   reg 		 that_just_happened;
   
   
   wire [7:0] 	 cur_word_cnt_p1 = cur_word_cnt + 1;
   wire [7:0] 	 cur_word_cnt_p2 = cur_word_cnt + 2;
   wire [15:0] 	 cur_address_p1 = cur_address + 1;
   wire [15:0] 	 cur_address_p2 = cur_address + 2;
   wire [15:0] 	 cur_daddr_p1 = cur_daddr + 1;
   wire [15:0] 	 cur_daddr_p2 = cur_daddr + 2;
   
   parameter 	 st_idle = 6'd0;
   parameter 	 st_service = 6'd1;
   //parameter 	 st_read_saddr = 6'd2;
   //parameter 	 st_read_header = 6'd3;
   parameter 	 st_read_sram = 6'd4;
   parameter 	 st_read_sendA = 6'd5;
   //parameter 	 st_read_sendB = 6'd6;
   //parameter 	 st_write_daddr = 6'd7;
   parameter 	 st_write_dataA = 6'd8;
   //parameter 	 st_write_dataB = 6'd9;
   parameter 	 st_write_wrSRAM = 6'd10;
   //parameter 	 st_write_rdSRAM = 6'd11;
   parameter 	 st_write_reply = 6'd12;
   //parameter 	 st_cns_addr = 6'd13;
   parameter 	 st_cns_rdSRAM = 6'd14;
   //parameter 	 st_cns_cmp = 6'd15;
   parameter 	 st_cns_swap = 6'd16;
   parameter 	 st_cns_write = 6'd17;
   //parameter 	 st_cns_header = 6'd18;
   parameter 	 st_cns_send_data = 6'd19;
   //The EPs cannot initiate a copy...
   //parameter 	 st_cpy_saddr = 6'd20;
   //parameter 	 st_cpy_dist = 6'd21;
   //parameter 	 st_cpyL_rdSRAM_A = 6'd22;
   //parameter 	 st_cpyL_rdSRAM_B = 6'd23;
   //parameter 	 st_cpyL_wrrdSRAM = 6'd24;
   //parameter 	 st_cpyL_wrSRAM = 6'd25;
   //parameter 	 st_cpyL_reply = 6'd26;
   //parameter 	 st_cpyG_reply_h = 6'd27;
   //parameter 	 st_cpyG_reply_daddr = 6'd28;
   //parameter 	 st_cpyG_read = 6'd29;
   //parameter 	 st_cpyG_sendA = 6'd30;
   //parameter 	 st_cpyG_sendB = 6'd31;

   reg [5:0] 	 state;
   reg [5:0] 	 st_nxt;

   always@(posedge CLK or posedge rst)
     if(rst)
       state <= st_idle;
     else
       state <= st_nxt;
 ////////////////////////////////////START OF REDUX//////////////////    
   always@(*)
     begin
	case(state)
	  st_idle: begin
	     if(ep0_inbox_full | ep1_inbox_full | ep2_inbox_full | ep3_inbox_full)
	       st_nxt = st_service;
	     else
	       st_nxt = st_idle;
	  end
	  st_service: begin
	     case(incoming_d[121:118])
	       `OCM_CMD_VC1_READ: st_nxt = st_read_sram;
	       `OCM_CMD_VC1_WRITE: st_nxt = st_write_wrSRAM;
	       `OCM_CMD_VC1_CPNSWP: st_nxt = st_cns_rdSRAM;
	       default: begin //$display("ERROR, EPESM1: %h", incoming_d[105:102]);
		  st_nxt = st_idle; end
	     endcase // case(incoming_d[19:16])
	  end
	  st_read_sram: begin
	     if(epe_sm1_mem_gnt)
	       st_nxt = st_read_sendA; //send the lsw
	     else
	       st_nxt = st_read_sram;
	  end
	  st_read_sendA: begin
	     if(outbox_gnt) begin
		if(cur_word_cnt_p1 == cmd_size[7:0] 
		   | cur_word_cnt_p2 == cmd_size[7:0])
		  st_nxt = st_idle;
		else
		  st_nxt = st_read_sram;
	     end
	     else
	       st_nxt = st_read_sendA;
	  end // case: st_read_sendA
	  /////////////////////////////////////////////////////////////////
	  st_write_dataA: begin
	     //if(incoming_full)
	       st_nxt = st_write_wrSRAM;
	     //	     else
	     //st_nxt = st_write_dataA;
	  end // case: st_write_dataA
	  st_write_wrSRAM: begin
	     if(epe_sm1_mem_gnt)
	       begin
		  if(cur_word_cnt_p1 == cmd_size[7:0] |
		     cur_word_cnt_p2 == cmd_size[7:0])
		    st_nxt = st_write_reply;
		  else
		    st_nxt = st_write_dataA;
	       end
	     else
	       st_nxt = st_write_wrSRAM;
	  end // case: st_write_wrSRAM
	  st_write_reply: begin
	     if(outbox_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_write_reply;
	  end
	  /////////////////////////////////////////////////////////////////////
	  st_cns_rdSRAM: begin
	     if(epe_sm1_mem_gnt)
	       st_nxt = st_cns_swap;
	     else
	       st_nxt = st_cns_rdSRAM;
	  end
	  st_cns_swap: begin
	     if(~that_just_happened)
	       if((cur_address[0] & (scratchpad[31:0] == sram_data[63:32]))
	          |(~cur_address[0] & (scratchpad[31:0] == sram_data[31:0])))
		 st_nxt = st_cns_write;
	       else
		 st_nxt = st_cns_send_data;
	     else
	       st_nxt = st_cns_swap;
	  end
	  st_cns_write: begin
	     if(epe_sm1_mem_gnt)
	       st_nxt = st_cns_send_data;
	     else
	       st_nxt = st_cns_write;
	  end
	  st_cns_send_data: begin
	     if(outbox_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_cns_send_data;
	  end
	  default: begin
	     st_nxt = st_idle;
	  end
	endcase // case(state)
     end // always@ (*)
   
   always@(posedge CLK or posedge rst)
     begin
	if(rst) begin
	   service_ep0 <= 1'b0;
	   service_ep1 <= 1'b0;
	   service_ep2 <= 1'b0;
	   service_ep3 <= 1'b0;
	   cmd_id <= 8'd0;
	   cmd_size <= 8'd0;
	   cmd_src <= 6'd0;
	   sram_data <=  64'd0;
	   cur_word_cnt <= 8'd0;
	   cur_address <= 16'd0;
	   cur_daddr <= 16'd0;
	   scratchpad <=  128'd0;
	   that_just_happened <= 1'b0;
	end
	else begin
	   case(state)
	     st_idle: begin
		if(st_nxt == st_service) begin
		   //todo: have some sort of arbitor
		   service_ep0 <= ep0_inbox_full;
		   service_ep1 <= ~ep0_inbox_full & ep1_inbox_full;
		   service_ep2 <= ~(ep0_inbox_full | ep1_inbox_full) & 
				  ep2_inbox_full;
		   service_ep3 <= ~(ep0_inbox_full | ep1_inbox_full | 
				    ep2_inbox_full) & ep3_inbox_full;
		end
		/*if(st_nxt != st_idle)
		  begin
		     
		     cmd_id <= 8'd0;
		     cmd_size <= 8'd0;
		     cmd_src <= 6'd0;
		     
		     sram_data <=  64'd0;
		     cur_word_cnt <= 8'd0;
		     cur_address <= 16'd0;
		     cur_daddr <= 16'd0;
		     scratchpad <=  128'd0;
		     that_just_happened <= 1'b0;
		  end // if (st_nxt != st_idle)*/
	     end // case: st_idle
	     st_service: begin
		if(st_nxt != st_service) begin
		   cmd_id <= incoming_d[117:110];
		   cmd_size <= incoming_d[109:102];
		   cmd_src <= incoming_d[101:96];
		   cur_word_cnt <= 8'd0;
		   cur_daddr <= 16'd0;
		   scratchpad[127:64]<=64'd0;
		   that_just_happened <= 1'b0;
		   
		   case(incoming_d[121:118])
		     `OCM_CMD_VC1_READ: begin
			sram_data <= 64'd0;
			cur_address <= incoming_d[15:0];
			scratchpad[63:0] <= 64'd0;
		     end
		     `OCM_CMD_VC1_WRITE: begin
			sram_data <= 64'd0;
			cur_address <= incoming_d[15:0];
			scratchpad[63:0] <= 64'd0;
			if(incoming_d[0])
			  sram_data   <= {incoming_d[63:32], 32'd0};
			else
			  sram_data <= incoming_d[95:32];
		     end
		     `OCM_CMD_VC1_CPNSWP: begin
			sram_data <= 64'd0;
			cur_address <= incoming_d[15:0];
			scratchpad[31:0] <= incoming_d[63:32];
			scratchpad[63:32] <= incoming_d[95:64];
		     end
		     default: begin
			scratchpad[63:0] <= 64'd0;
			sram_data <= 64'd0;
			cur_address <= 16'd0;
			
		     end
		     
		   endcase // case(incoming_d[105:102])
		end
	     end
	     st_read_sram: begin
		if(st_nxt != st_read_sram) begin
		   scratchpad[0] <= cur_address[0];
		   that_just_happened <= 1'b1;
		end
	     end
	     st_read_sendA: begin
		if(that_just_happened) begin
		   sram_data <= epe_sm1_mem_read_data;
		   that_just_happened <= 1'b0;
		end
		if(st_nxt != st_read_sendA) begin
		   cur_word_cnt <= cur_word_cnt_p2;
		   cur_address <= cur_address_p2;
		end
	     end
	     ////////////////////////////////////////
	     /*st_write_dataA: begin
		if(st_nxt != st_write_dataA) begin
		   if(incoming_d[0])
		     sram_data <= {incoming_d[63:32],32'd0};
		   else
		     sram_data <= incoming_d[95:32];
		end
	     end*/
	     st_write_wrSRAM: begin
		if(st_nxt != st_write_wrSRAM) begin
		   cur_word_cnt <= cur_address[0] ? cur_word_cnt_p1 :
				   cur_word_cnt_p2;
		   cur_address <= cur_address[0] ? cur_address_p1 :
				  cur_address_p2;
		end
	     end // case: st_write_wrSRAM
	     st_write_reply: begin
	     end
	     /////////////////////////////////////////
	     st_cns_rdSRAM: begin
		that_just_happened <= 1'b1;
	     end
	     st_cns_swap: begin
		if(that_just_happened) begin
		   sram_data <= epe_sm1_mem_read_data;
		   that_just_happened <= 1'b0;
		end
	     end
	     st_cns_send_data: begin
	     end // case: st_cns_send_data
	     /////////////////////////////////////////////////// 
	   endcase // case(state)
	end // else: !if(rst)
     end // always@ (posedge CLK)
   
   always@(*)
     begin
	incoming_read = 1'b0;
	outbox_d = 122'd0;
	outbox_full = 1'b0;
	epe_sm1_mem_req = 1'b0;
	epe_sm1_mem_wen_b = 1'b1;
	epe_sm1_mem_lock = 1'b0;
	epe_sm1_mem_addr = 16'd0;
	epe_sm1_mem_write_data = 64'd0;
	epe_sm1_mem_write_mask = 2'd0;
	
	case(state)
	  st_idle: begin
	  end
	  st_service: begin
	     incoming_read =1'b1;
	  end
	  st_read_sram: begin
	     epe_sm1_mem_req = 1'b1;
	     epe_sm1_mem_wen_b = 1'b1;
	     epe_sm1_mem_lock = 1'b0;
	     epe_sm1_mem_addr = cur_address[15:0];
	     epe_sm1_mem_write_data = 64'd0;
	     epe_sm1_mem_write_mask = 2'd0;
	  end
	  st_read_sendA: begin
	     //note: the reciever must parse which word...
	     //new note: Not anymore...
	     if(cur_address[0]) 
	       outbox_d = {`OCM_CMD_VC3_READ_P, cmd_id, cmd_size, who_am_i, 32'd0,
			   32'd0, sram_data[63:32]};
	     else
	       outbox_d = {`OCM_CMD_VC3_READ_P, cmd_id, cmd_size, who_am_i, 32'd0,
			   sram_data};
	     outbox_full = ~that_just_happened;
	  end
	  //////////////////////////////////////
	  st_write_dataA: begin
	     incoming_read = 1'b1;
	  end
	  st_write_wrSRAM: begin
	     epe_sm1_mem_req = 1'b1;
	     epe_sm1_mem_wen_b = 1'b0;
	     epe_sm1_mem_lock =1'b0;
	     epe_sm1_mem_addr = cur_address[15:0];
	     epe_sm1_mem_write_data = sram_data[63:0];
	     if(cur_address[0])
	       epe_sm1_mem_write_mask = 2'b01;
	     else if(cur_word_cnt_p1 == cmd_size[7:0])
	       epe_sm1_mem_write_mask = 2'b10;
	     else
	       epe_sm1_mem_write_mask = 2'd0;
	  end
	  st_write_reply: begin
	     outbox_d = {`OCM_CMD_VC3_WRITE_P, cmd_id, cmd_size, who_am_i, 96'd0};
	     outbox_full = 1'b1;
	  end
	  st_cns_rdSRAM: begin
	     epe_sm1_mem_req = 1'b1;
	     epe_sm1_mem_wen_b = 1'b1;
	     epe_sm1_mem_lock =1'b1;
	     epe_sm1_mem_addr =cur_address[15:0];
	     epe_sm1_mem_write_data = 64'd0;
	     epe_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_swap: begin
	     epe_sm1_mem_req = 1'b0;
	     epe_sm1_mem_wen_b = 1'b1;
	     epe_sm1_mem_lock =1'b1;
	     epe_sm1_mem_addr =cur_address[15:0];
	     epe_sm1_mem_write_data = 64'd0;
	     epe_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_write: begin
	     epe_sm1_mem_req = 1'b1;
	     epe_sm1_mem_wen_b = 1'b0;
	     epe_sm1_mem_lock =1'b1;
	     epe_sm1_mem_addr = cur_address[15:0];
	     epe_sm1_mem_write_data =  cur_address[0] ? 
				       {scratchpad[63:32],sram_data[31:0]} :
				       {sram_data[63:32],scratchpad[63:32]};
	     epe_sm1_mem_write_mask = 2'd0;
	  end
	  st_cns_send_data: begin
	     outbox_full = 1'b1;
	     outbox_d[121:32] = {`OCM_CMD_VC3_CPNSWP_P, cmd_id, cmd_size, 
				 who_am_i, 64'd0};
	     if(cur_address[0])
	       outbox_d[31:0] = sram_data[63:32];
	     else
	       outbox_d[31:0] = sram_data[31:0];
	  end // case: st_cns_send_data
	  default: begin
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


endmodule // epe_sm1
