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

module epe_sm0(/*AUTOARG*/
   // Outputs
   epe_sm0_for_nA_vc0_r, epe_sm0_for_nA_vc0_h, epe_sm0_for_nA_vc0_d, 
   epe_sm0_for_nB_vc0_r, epe_sm0_for_nB_vc0_h, epe_sm0_for_nB_vc0_d, 
   ep0_inbox_read, ep1_inbox_read, ep2_inbox_read, ep3_inbox_read, 
   epe_sm0_mem_req, epe_sm0_mem_wen_b, epe_sm0_mem_lock, 
   epe_sm0_mem_addr, epe_sm0_mem_write_data, epe_sm0_mem_write_mask, 
   // Inputs
   CLK, rst, epe_sm0_for_nA_vc0_gnt, epe_sm0_for_nB_vc0_gnt, 
   ep0_inbox_full, ep0_inbox_d, ep1_inbox_full, ep1_inbox_d, 
   ep2_inbox_full, ep2_inbox_d, ep3_inbox_full, ep3_inbox_d, 
   epe_sm0_mem_read_data, epe_sm0_mem_gnt
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

   //Out to networks...
   //For sending out on vc0
   output        epe_sm0_for_nA_vc0_r;
   output 	 epe_sm0_for_nA_vc0_h;
   output [32:0] epe_sm0_for_nA_vc0_d;
   input         epe_sm0_for_nA_vc0_gnt;

   output        epe_sm0_for_nB_vc0_r;
   output 	 epe_sm0_for_nB_vc0_h;
   output [32:0] epe_sm0_for_nB_vc0_d;
   input         epe_sm0_for_nB_vc0_gnt;

   //Sequential
   reg 		 send_to_nA_vc0;
   reg 		 send_to_nB_vc0;

   //Combinational
   reg 		 outgoing_r;
   reg 		 outgoing_h;
   reg [32:0] 	 outgoing_d;
   wire 	 outgoing_gnt;

   assign 	 epe_sm0_for_nA_vc0_r = outgoing_r & send_to_nA_vc0;
   assign 	 epe_sm0_for_nB_vc0_r = outgoing_r & send_to_nB_vc0;

   assign 	 epe_sm0_for_nA_vc0_h = outgoing_h & send_to_nA_vc0;
   assign 	 epe_sm0_for_nB_vc0_h = outgoing_h & send_to_nB_vc0;

   assign 	 epe_sm0_for_nA_vc0_d = send_to_nA_vc0 ? outgoing_d : 33'd0;
   assign 	 epe_sm0_for_nB_vc0_d = send_to_nB_vc0 ? outgoing_d : 33'd0;

   assign 	 outgoing_gnt = (send_to_nA_vc0 & epe_sm0_for_nA_vc0_gnt) |
				  (send_to_nB_vc0 & epe_sm0_for_nB_vc0_gnt);

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
   reg 		 service_ep1;
   reg 		 service_ep2;
   reg 		 service_ep3;

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
   output 	 epe_sm0_mem_req;
   output 	 epe_sm0_mem_wen_b;
   output 	 epe_sm0_mem_lock;
   output [15:0] epe_sm0_mem_addr;
   output [63:0] epe_sm0_mem_write_data;
   output [1:0] epe_sm0_mem_write_mask;
   input [63:0]  epe_sm0_mem_read_data;
   input 	 epe_sm0_mem_gnt;

   reg 		 epe_sm0_mem_req;
   reg 		 epe_sm0_mem_wen_b;
   reg 		 epe_sm0_mem_lock;
   reg [15:0] 	 epe_sm0_mem_addr;
   reg [63:0] 	 epe_sm0_mem_write_data;
   reg [1:0] 	 epe_sm0_mem_write_mask;

   reg [3:0] 	 cmd_cmd;
   reg [7:0] 	 cmd_id;
   reg [5:0] 	 cmd_dst;
   reg [5:0] 	 cmd_src;
   reg [63:0] 	 sram_data;
   reg [31:0] 	 cur_address;
   reg [7:0] 	 cmd_size;
   reg 		 that_just_happened;
      
   wire [31:0] 	 cur_address_p2 = cur_address + 2;

   parameter 	 st_idle = 4'd0;
   parameter 	 st_service = 4'd1;
   parameter 	 st_ldsdL_header = 4'd2;
   parameter 	 st_ldsdL_read_A = 4'd3;
   parameter 	 st_ldsdL_send_A1 = 4'd4;
   parameter 	 st_ldsdL_send_A2 = 4'd5;
   parameter 	 st_ldsdL_read_B = 4'd6;
   parameter 	 st_ldsdL_send_B1 = 4'd7;
   parameter 	 st_ldsdL_send_B2 = 4'd8;
   parameter 	 st_ldsdL_read_C = 4'd9;
   parameter 	 st_ldsdL_send_C1 = 4'd10;
   parameter 	 st_fwd_ldst = 4'd11;
   parameter 	 st_fwd_ldst_A = 4'd12;
   parameter 	 st_fwd_stream = 4'd13;
   parameter 	 st_fwd_stream_A = 4'd14;
   parameter 	 st_fwd_stream_B = 4'd15;

   reg [3:0] 	 state;
   reg [3:0] 	 st_nxt ;

   always@(posedge CLK or posedge rst)
     if(rst)
       state <= st_idle;
     else
       state <= st_nxt;

   always@(*)
     begin
	st_nxt = st_idle;
	case(state)
	  st_idle: begin
	     if(ep0_inbox_full | ep1_inbox_full | ep2_inbox_full | ep3_inbox_full)
	       st_nxt = st_service;
	     else
	       st_nxt = st_idle;
	  end
	  st_service: begin
	     case(incoming_d[121:118])
	       `OCM_CMD_VC0_LDSD: st_nxt = does_this_addr_goto_me(incoming_d[31:0]) ? st_ldsdL_header : st_fwd_ldst;
	       `OCM_CMD_VC0_STSD: st_nxt = st_fwd_ldst;
	       `OCM_CMD_VC0_RDSTRM: st_nxt = st_fwd_stream;
	       `OCM_CMD_VC0_WRSTRM: st_nxt = st_fwd_stream;
	       default: begin //$display("ERROR, EPESM0: %h", incoming_d[105:102]);
		  st_nxt = st_idle; end
	     endcase // case(incoming_d[19:16])
	  end
	  st_ldsdL_header: begin
	     if(outgoing_gnt) st_nxt = st_ldsdL_read_A;
	     else st_nxt = st_ldsdL_header;
	  end
	  st_ldsdL_read_A: begin
	     if(epe_sm0_mem_gnt)
	       if(cur_address[0])
		 st_nxt = st_ldsdL_send_A2;
	       else
		 st_nxt = st_ldsdL_send_A1;
	     else
	       st_nxt = st_ldsdL_read_A;
	  end
	  st_ldsdL_send_A1: begin
	     if(outgoing_gnt) st_nxt = st_ldsdL_send_A2;
	     else st_nxt = st_ldsdL_send_A1;
	  end
	  st_ldsdL_send_A2: begin
	     if(outgoing_gnt) st_nxt = st_ldsdL_read_B;
	     else st_nxt = st_ldsdL_send_A2;
	  end
	  st_ldsdL_read_B: begin
	     if(epe_sm0_mem_gnt) st_nxt = st_ldsdL_send_B1;
	     else st_nxt = st_ldsdL_read_B;
	  end
	  st_ldsdL_send_B1: begin
	     if(outgoing_gnt) st_nxt = st_ldsdL_send_B2;
	     else st_nxt = st_ldsdL_send_B1;
	  end
	  st_ldsdL_send_B2: begin
	     if(outgoing_gnt)
	       st_nxt = cur_address[0] ? st_ldsdL_read_C : st_idle;
	     else
	       st_nxt = st_ldsdL_send_B2;
	  end
	  st_ldsdL_read_C: begin
	     if(epe_sm0_mem_gnt) st_nxt = st_ldsdL_send_C1;
	     else st_nxt = st_ldsdL_read_C;
	  end
	  st_ldsdL_send_C1: begin
	     if(outgoing_gnt) st_nxt = st_idle;
	     else st_nxt = st_ldsdL_send_C1;
	  end
	  st_fwd_ldst: begin
	     if(outgoing_gnt) st_nxt = st_fwd_ldst_A;
	     else st_nxt = st_fwd_ldst;
	  end
	  st_fwd_ldst_A: begin
	     if(outgoing_gnt) st_nxt = st_idle;
	     else st_nxt = st_fwd_ldst_A;
	  end
	  st_fwd_stream: begin
	     if(outgoing_gnt) st_nxt = st_fwd_stream_A;
	     else st_nxt = st_fwd_stream;
	  end
	  st_fwd_stream_A: begin
	     if(outgoing_gnt) st_nxt = st_fwd_stream_B;
	     else st_nxt = st_fwd_stream_A;
	  end
	  st_fwd_stream_B: begin
	     if(outgoing_gnt) st_nxt = st_idle;
	     else st_nxt = st_fwd_stream_B;
	  end
	  default: st_nxt = st_idle;
	endcase // case(state)
     end // always@ (*)
   
   
   always@(posedge CLK or posedge rst)
     begin
	if(rst) begin
	   service_ep0 <= 1'b0;
	   service_ep1 <= 1'b0;
	   service_ep2 <= 1'b0;
	   service_ep3 <= 1'b0;
	   cmd_cmd <= 4'd0;
	   cmd_id <= 8'd0;
	   cmd_src <= 6'd0;
	   cmd_dst <= 6'd0;
	   sram_data <= 64'd0;
	   cur_address <= 32'd0;
	   that_just_happened <= 1'b0;
	   send_to_nA_vc0 <= 1'b0;
	   send_to_nB_vc0 <= 1'b0;
	end // if (rst)
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
		//cmd_id <= 8'd0;
		//cmd_cmd <= 4'd0;
		//cmd_dst <= 6'd0;
		//cmd_src <= 6'd0;
		//cmd_size <= 8'd0;
		//sram_data <= 64'd0;
		//cur_address <= 32'd0;
		//that_just_happened <= 1'b0;
	     end // case: st_idle
	     st_service: begin
		if(st_nxt != st_service) begin
		   cmd_id <= incoming_d[117:110];
		   cmd_src <= incoming_d[101:96];
		   cmd_dst <= incoming_d[69:64];
		   cmd_cmd <= incoming_d[121:118];
		   send_to_nA_vc0 <= does_this_dst_goto_nA(incoming_d[69:64]);
		   send_to_nB_vc0 <= does_this_dst_goto_nB(incoming_d[69:64]);
		   cur_address <= incoming_d[31:0];
		   that_just_happened <= 1'b0;
		   if(st_nxt != st_ldsdL_read_A) begin
		      sram_data[31:0] <= incoming_d[63:32];
		      cmd_size <= incoming_d[109:102];
		   end
		   else begin
		      cmd_size <= 8'd0;
		      sram_data <= 64'd0;
		   end
		end
	     end // case: st_service
	     
	     st_ldsdL_header: begin
		//no delta
	     end
	     st_ldsdL_read_A: begin
		if(st_nxt != st_ldsdL_read_A) begin
		   that_just_happened <= 1'b1;
		   cur_address <= cur_address_p2;
		end
	     end
	     st_ldsdL_send_A1: begin
		if(that_just_happened) begin
		   sram_data <= epe_sm0_mem_read_data;
		   that_just_happened <= 1'b0;
		end
	     end
	     st_ldsdL_send_A2: begin
		if(that_just_happened) begin
		   sram_data <= epe_sm0_mem_read_data;
		   that_just_happened <= 1'b0;
		end
	     end
	     st_ldsdL_read_B: begin
		if(st_nxt != st_ldsdL_read_B) begin
		   that_just_happened <= 1'b1;
		   cur_address <= cur_address_p2;
		end
	     end
	     st_ldsdL_send_B1: begin
		if(that_just_happened) begin
		   sram_data <= epe_sm0_mem_read_data;
		   that_just_happened <= 1'b0;
		end
	     end
	     st_ldsdL_send_B2: begin
	     end
	     st_ldsdL_read_C: begin
		if(st_nxt != st_ldsdL_read_C)
		  that_just_happened <= 1'b1;
	     end
	     st_ldsdL_send_C1: begin
		if(that_just_happened) begin
		   sram_data <= epe_sm0_mem_read_data;
		   that_just_happened <= 1'b0;
		end
	     end
	     st_fwd_ldst: begin
	     end
	     st_fwd_ldst_A: begin
	     end
	     st_fwd_stream: begin
	     end
	     st_fwd_stream_A: begin
	     end
	     st_fwd_stream_B: begin
	     end
	   endcase // case(state)
	end // else: !if(rst)
     end // always@ (posedge CLK)
   
   always@(*) begin
      incoming_read = 1'b0;
      
      outgoing_r = 1'b0;
      outgoing_h = 1'b0;
      outgoing_d = 33'd0;
      
      epe_sm0_mem_req = 1'b0;
      epe_sm0_mem_wen_b = 1'b1;
      epe_sm0_mem_lock = 1'b0;
      epe_sm0_mem_addr = 16'd0;
      epe_sm0_mem_write_data = 64'd0;
      epe_sm0_mem_write_mask = 2'd0;
      case(state)
	st_idle: begin
	end // case: st_idle
	st_service: begin
	   incoming_read = 1'b1;
	end
	st_ldsdL_header: begin
	   outgoing_r = 1'b1;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b1, cmd_dst, cmd_src, `OCM_CMD_VC0_LDSDI, cmd_id, cmd_size};
	end
	st_ldsdL_read_A: begin
	   outgoing_h = 1'b1;

	   epe_sm0_mem_req = 1'b1;
	   epe_sm0_mem_addr = cur_address[15:0];
	end
	st_ldsdL_send_A1: begin
	   outgoing_r = ~that_just_happened;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0, sram_data[31:0]};
	end
	st_ldsdL_send_A2: begin
	   outgoing_r = ~that_just_happened;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0,sram_data[63:32]};
	end
	st_ldsdL_read_B: begin
	   outgoing_h = 1'b1;

	   epe_sm0_mem_req = 1'b1;
	   epe_sm0_mem_addr = cur_address[15:0];
	end
	st_ldsdL_send_B1: begin
	   outgoing_r = ~that_just_happened;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0,sram_data[31:0]};
	end
	st_ldsdL_send_B2: begin
	   outgoing_r = ~that_just_happened;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0,sram_data[63:32]};
	end
	st_ldsdL_read_C: begin
	   
	   outgoing_h = 1'b1;
	   epe_sm0_mem_req = 1'b1;
	   epe_sm0_mem_addr = cur_address[15:0];
	end
	st_ldsdL_send_C1: begin
	   outgoing_r = ~that_just_happened;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0,sram_data[31:0]};
	end
	st_fwd_ldst: begin
	   outgoing_r = 1'b1;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b1, cmd_dst, cmd_src, cmd_cmd, cmd_id, cmd_size};
	end
	st_fwd_ldst_A: begin
	   outgoing_r = 1'b1;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0, cur_address};
	end
	st_fwd_stream: begin
	   outgoing_r = 1'b1;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b1, cmd_dst, cmd_src, cmd_cmd, cmd_id, cmd_size};
	end
	st_fwd_stream_A: begin
	   outgoing_r = 1'b1;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0, cur_address};
	end
	st_fwd_stream_B: begin
	   outgoing_r = 1'b1;
	   outgoing_h = 1'b1;
	   outgoing_d = {1'b0, sram_data[31:0]};
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
   endfunction // does_this_addr_goto_me

endmodule // epe_sm0
