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

module ep_box_muxdemux(/*AUTOARG*/
   // Outputs
   ep0_inbox_read, ep1_inbox_read, ep2_inbox_read, ep3_inbox_read, 
   ep0_to_se0_vc0_d, ep0_to_se0_vc0_full, ep0_to_se1_vc0_d, 
   ep0_to_se1_vc0_full, /*ep0_to_se2_vc0_d, ep0_to_se2_vc0_full, 
   ep0_to_se3_vc0_d, ep0_to_se3_vc0_full,*/ ep1_to_se0_vc0_d, 
   ep1_to_se0_vc0_full, ep1_to_se1_vc0_d, ep1_to_se1_vc0_full, 
   /*ep1_to_se2_vc0_d, ep1_to_se2_vc0_full, ep1_to_se3_vc0_d, 
   ep1_to_se3_vc0_full,*/ ep2_to_se0_vc0_d, ep2_to_se0_vc0_full, 
   ep2_to_se1_vc0_d, ep2_to_se1_vc0_full, /*ep2_to_se2_vc0_d, 
   ep2_to_se2_vc0_full, ep2_to_se3_vc0_d, ep2_to_se3_vc0_full,*/ 
   ep3_to_se0_vc0_d, ep3_to_se0_vc0_full, ep3_to_se1_vc0_d, 
   ep3_to_se1_vc0_full,/* ep3_to_se2_vc0_d, ep3_to_se2_vc0_full, 
   ep3_to_se3_vc0_d, ep3_to_se3_vc0_full,*/ ep0_inbox_vc0G_d, 
   ep0_inbox_vc0G_full, ep1_inbox_vc0G_d, ep1_inbox_vc0G_full, 
   ep2_inbox_vc0G_d, ep2_inbox_vc0G_full, ep3_inbox_vc0G_d, 
   ep3_inbox_vc0G_full, ep0_inbox_vc1L_d, ep0_inbox_vc1L_full, 
   ep1_inbox_vc1L_d, ep1_inbox_vc1L_full, ep2_inbox_vc1L_d, 
   ep2_inbox_vc1L_full, ep3_inbox_vc1L_d, ep3_inbox_vc1L_full, 
   epe_1G_for_nA_vc1_r, epe_1G_for_nA_vc1_d, epe_1G_for_nA_vc1_h, 
   epe_1G_for_nB_vc1_r, epe_1G_for_nB_vc1_d, epe_1G_for_nB_vc1_h, 
   ep0_outbox, ep1_outbox, ep2_outbox, ep3_outbox, 
   ep_nA_vc3_incoming_read, ep_nB_vc3_incoming_read, 
   se0_for_ep0_vc3_gnt, se0_for_ep1_vc3_gnt, se0_for_ep2_vc3_gnt, 
   se0_for_ep3_vc3_gnt, se1_for_ep0_vc3_gnt, se1_for_ep1_vc3_gnt, 
   se1_for_ep2_vc3_gnt, se1_for_ep3_vc3_gnt, /*se2_for_ep0_vc3_gnt, 
   se2_for_ep1_vc3_gnt, se2_for_ep2_vc3_gnt, se2_for_ep3_vc3_gnt, 
   se3_for_ep0_vc3_gnt, se3_for_ep1_vc3_gnt, se3_for_ep2_vc3_gnt, 
   se3_for_ep3_vc3_gnt,*/ sm1L_for_ep0_gnt, sm1L_for_ep1_gnt, 
   sm1L_for_ep2_gnt, sm1L_for_ep3_gnt, 
   // Inputs
   CLK, rst, ep0_inbox, ep1_inbox, ep2_inbox, ep3_inbox, 
   ep0_to_se0_vc0_read, ep0_to_se1_vc0_read, /*ep0_to_se2_vc0_read, 
   ep0_to_se3_vc0_read,*/ ep1_to_se0_vc0_read, ep1_to_se1_vc0_read, 
   /*ep1_to_se2_vc0_read, ep1_to_se3_vc0_read,*/ ep2_to_se0_vc0_read, 
   ep2_to_se1_vc0_read, /*ep2_to_se2_vc0_read, ep2_to_se3_vc0_read,*/ 
   ep3_to_se0_vc0_read, ep3_to_se1_vc0_read, /*ep3_to_se2_vc0_read, 
   ep3_to_se3_vc0_read,*/ ep0_inbox_vc0G_read, ep1_inbox_vc0G_read, 
   ep2_inbox_vc0G_read, ep3_inbox_vc0G_read, ep0_inbox_vc1L_read, 
   ep1_inbox_vc1L_read, ep2_inbox_vc1L_read, ep3_inbox_vc1L_read, 
   epe_1G_for_nA_vc1_gnt, epe_1G_for_nB_vc1_gnt, ep0_outbox_read, 
   ep1_outbox_read, ep2_outbox_read, ep3_outbox_read, 
   ep_nA_vc3_incoming_d, ep_nA_vc3_incoming_e, ep_nB_vc3_incoming_d, 
   ep_nB_vc3_incoming_e, se0_for_ep0_vc3_d, se0_for_ep0_vc3_full, 
   se0_for_ep1_vc3_d, se0_for_ep1_vc3_full, se0_for_ep2_vc3_d, 
   se0_for_ep2_vc3_full, se0_for_ep3_vc3_d, se0_for_ep3_vc3_full, 
   se1_for_ep0_vc3_d, se1_for_ep0_vc3_full, se1_for_ep1_vc3_d, 
   se1_for_ep1_vc3_full, se1_for_ep2_vc3_d, se1_for_ep2_vc3_full, 
   se1_for_ep3_vc3_d, se1_for_ep3_vc3_full, /*se2_for_ep0_vc3_d, 
   se2_for_ep0_vc3_full, se2_for_ep1_vc3_d, se2_for_ep1_vc3_full, 
   se2_for_ep2_vc3_d, se2_for_ep2_vc3_full, se2_for_ep3_vc3_d, 
   se2_for_ep3_vc3_full, se3_for_ep0_vc3_d, se3_for_ep0_vc3_full, 
   se3_for_ep1_vc3_d, se3_for_ep1_vc3_full, se3_for_ep2_vc3_d, 
   se3_for_ep2_vc3_full, se3_for_ep3_vc3_d, se3_for_ep3_vc3_full,*/ 
   sm1L_for_ep0_d, sm1L_for_ep0_full, sm1L_for_ep1_d, 
   sm1L_for_ep1_full, sm1L_for_ep2_d, sm1L_for_ep2_full, 
   sm1L_for_ep3_d, sm1L_for_ep3_full
   );

 
   parameter who_am_i = `OCM_NODE_OCM_SD0;
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
   
   //Input conversion:
   //124:0 mailbox (122: full, 124:123: VC)
   //       to 1L mailbox
   //       to 0G mailbox
   //       to 0L mailbox
   //       to 1G network (arbitrated...)
   input [124:0] ep0_inbox;
   output 	 ep0_inbox_read; //todo: assign out the reads
   input [124:0] ep1_inbox;
   output 	 ep1_inbox_read;
   input [124:0] ep2_inbox;
   output 	 ep2_inbox_read;
   input [124:0] ep3_inbox;
   output 	 ep3_inbox_read;

   wire 	 ep0_goes_to_1L = ep0_inbox[122] & (ep0_inbox[124:123] == 2'd1) &
						     does_this_addr_goto_me(ep0_inbox[31:0]);
   wire 	 ep0_goes_to_1G = ep0_inbox[122] & (ep0_inbox[124:123] == 2'd1) &
						     ~does_this_addr_goto_me(ep0_inbox[31:0]);
   wire 	 ep0_goes_to_0G = ep0_inbox[122] & (ep0_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep0_inbox[69:64]);
   wire 	 ep0_goes_to_0L = ep0_inbox[122] & (ep0_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep0_inbox[69:64]);
   
   wire 	 ep0_goes_to_my_se0 = ep0_inbox[122] & 
		 does_this_dst_goto_me(ep0_inbox[69:64]) & ep0_inbox[67:64] == 4'd8;
   wire 	 ep0_goes_to_my_se1 = ep0_inbox[122] & 
		 does_this_dst_goto_me(ep0_inbox[69:64]) & ep0_inbox[67:64] == 4'd9;
   
   wire 	 ep1_goes_to_1L = ep1_inbox[122] & (ep1_inbox[124:123] == 2'd1) &
						     does_this_addr_goto_me(ep1_inbox[31:0]);
   wire 	 ep1_goes_to_1G = ep1_inbox[122] & (ep1_inbox[124:123] == 2'd1) &
						     ~does_this_addr_goto_me(ep1_inbox[31:0]);
   wire 	 ep1_goes_to_0G = ep1_inbox[122] & (ep1_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep1_inbox[69:64]);
   wire 	 ep1_goes_to_0L = ep1_inbox[122] & (ep1_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep1_inbox[69:64]);

   wire 	 ep1_goes_to_my_se0 = ep1_inbox[122] & 
		 does_this_dst_goto_me(ep1_inbox[69:64]) & ep1_inbox[67:64] == 4'd8;
   wire 	 ep1_goes_to_my_se1 = ep1_inbox[122] & 
		 does_this_dst_goto_me(ep1_inbox[69:64]) & ep1_inbox[67:64] == 4'd9;

   wire 	 ep2_goes_to_1L = ep2_inbox[122] & (ep2_inbox[124:123] == 2'd1) &
						     does_this_addr_goto_me(ep2_inbox[31:0]);
   wire 	 ep2_goes_to_1G = ep2_inbox[122] & (ep2_inbox[124:123] == 2'd1) &
						     ~does_this_addr_goto_me(ep2_inbox[31:0]);
   wire 	 ep2_goes_to_0G = ep2_inbox[122] & (ep2_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep2_inbox[69:64]);
   wire 	 ep2_goes_to_0L = ep2_inbox[122] & (ep2_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep2_inbox[69:64]);
   /*wire 	 ep2_goes_to_my_se0 = ep2_goes_to_0L & (ep2_inbox[65:64] == 2'd0); //encoding spec
    wire 	 ep2_goes_to_my_se1 = ep2_goes_to_0L & (ep2_inbox[65:64] == 2'd1); //encoding spec
    wire 	 ep2_goes_to_my_se2 = ep2_goes_to_0L & (ep2_inbox[65:64] == 2'd2); //encoding spec
    wire 	 ep2_goes_to_my_se3 = ep2_goes_to_0L & (ep2_inbox[65:64] == 2'd3); //encoding spec*/

   wire 	 ep2_goes_to_my_se0 = ep2_inbox[122] & 
		 does_this_dst_goto_me(ep2_inbox[69:64]) & ep2_inbox[65:64] == 4'd8;
   wire 	 ep2_goes_to_my_se1 = ep2_inbox[122] & 
		 does_this_dst_goto_me(ep2_inbox[69:64]) & ep2_inbox[65:64] == 4'd9;
   //wire 	 ep2_goes_to_my_se2 = ep2_inbox[122] & 
   //does_this_dst_goto_me(ep2_inbox[69:64]) & ep2_inbox[65:64] == 4'd10;
   //wire 	 ep2_goes_to_my_se3 = ep2_inbox[122] & 
   //does_this_dst_goto_me(ep2_inbox[69:64]) & ep2_inbox[65:64] == 4'd11;
   
   
   wire 	 ep3_goes_to_1L = ep3_inbox[122] & (ep3_inbox[124:123] == 2'd1) &
						     does_this_addr_goto_me(ep3_inbox[31:0]);
   wire 	 ep3_goes_to_1G = ep3_inbox[122] & (ep3_inbox[124:123] == 2'd1) &
						     ~does_this_addr_goto_me(ep3_inbox[31:0]);
   wire 	 ep3_goes_to_0G = ep3_inbox[122] & (ep3_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep3_inbox[69:64]);
   wire 	 ep3_goes_to_0L = ep3_inbox[122] & (ep3_inbox[124:123] == 2'd0) &
						     ~does_this_dst_goto_me(ep3_inbox[69:64]);
   /*wire 	 ep3_goes_to_my_se0 = ep3_goes_to_0L & (ep3_inbox[65:64] == 2'd0); //encoding spec
    wire 	 ep3_goes_to_my_se1 = ep3_goes_to_0L & (ep3_inbox[65:64] == 2'd1); //encoding spec
    wire 	 ep3_goes_to_my_se2 = ep3_goes_to_0L & (ep3_inbox[65:64] == 2'd2); //encoding spec
   wire 	 ep3_goes_to_my_se3 = ep3_goes_to_0L & (ep3_inbox[65:64] == 2'd3); //encoding spec//*/
   
   wire 	 ep3_goes_to_my_se0 = ep3_inbox[122] & 
		 does_this_dst_goto_me(ep3_inbox[69:64]) & ep3_inbox[65:64] == 4'd8;
   wire 	 ep3_goes_to_my_se1 = ep3_inbox[122] & 
		 does_this_dst_goto_me(ep3_inbox[69:64]) & ep3_inbox[65:64] == 4'd9;
   //wire 	 ep3_goes_to_my_se2 = ep3_inbox[122] & 
   //does_this_dst_goto_me(ep3_inbox[69:64]) & ep3_inbox[65:64] == 4'd10;
   //wire 	 ep3_goes_to_my_se3 = ep3_inbox[122] & 
   //does_this_dst_goto_me(ep3_inbox[69:64]) & ep3_inbox[65:64] == 4'd11;
   
   
      
   output [121:0] ep0_to_se0_vc0_d;
   assign 	  ep0_to_se0_vc0_d = ep0_goes_to_my_se0 ? ep0_inbox[121:0] : 122'd0;
   output 	  ep0_to_se0_vc0_full;
   assign 	  ep0_to_se0_vc0_full	  = ep0_goes_to_my_se0;
   input 	  ep0_to_se0_vc0_read;
   output [121:0] ep0_to_se1_vc0_d;
   assign ep0_to_se1_vc0_d = ep0_goes_to_my_se1 ? ep0_inbox[121:0] : 122'd0;
   output ep0_to_se1_vc0_full;
   assign ep0_to_se1_vc0_full = ep0_goes_to_my_se1;
   input  ep0_to_se1_vc0_read;
   //output [121:0] ep0_to_se2_vc0_d;
   //assign 	  ep0_to_se2_vc0_d = ep0_goes_to_my_se2 ? ep0_inbox[121:0] : 122'd0;
   //output 	  ep0_to_se2_vc0_full;
   //assign 	  ep0_to_se2_vc0_full = ep0_goes_to_my_se2;
   //input 	  ep0_to_se2_vc0_read;
   //output [121:0] ep0_to_se3_vc0_d;
   //assign 	  ep0_to_se3_vc0_d = ep0_goes_to_my_se3 ? ep0_inbox[121:0] : 122'd0;
   //output 	  ep0_to_se3_vc0_full;
   //assign 	  ep0_to_se3_vc0_full = ep0_goes_to_my_se3;
   //input 	  ep0_to_se3_vc0_read;
   output [121:0] ep1_to_se0_vc0_d;
   assign 	  ep1_to_se0_vc0_d = ep1_goes_to_my_se0 ? ep1_inbox[121:0] : 122'd0;
   output 	  ep1_to_se0_vc0_full;
   assign 	  ep1_to_se0_vc0_full = ep1_goes_to_my_se0;
   input 	  ep1_to_se0_vc0_read;
   output [121:0] ep1_to_se1_vc0_d;
   assign 	  ep1_to_se1_vc0_d = ep1_goes_to_my_se1 ? ep1_inbox[121:0] : 122'd0;
   output 	  ep1_to_se1_vc0_full;
   assign 	  ep1_to_se1_vc0_full = ep1_goes_to_my_se1;
   input 	  ep1_to_se1_vc0_read;
   //output [121:0] ep1_to_se2_vc0_d;
   //assign 	  ep1_to_se2_vc0_d = ep1_goes_to_my_se2 ? ep1_inbox[121:0] : 122'd0;
   //output 	  ep1_to_se2_vc0_full;
   //assign 	  ep1_to_se2_vc0_full = ep1_goes_to_my_se2;
   //input 	  ep1_to_se2_vc0_read;
   //output [121:0] ep1_to_se3_vc0_d;
   //assign 	  ep1_to_se3_vc0_d = ep1_goes_to_my_se3 ? ep1_inbox[121:0] : 122'd0;
   //output 	  ep1_to_se3_vc0_full;
   //assign 	  ep1_to_se3_vc0_full = ep1_goes_to_my_se3;
   //input 	  ep1_to_se3_vc0_read;
   output [121:0] ep2_to_se0_vc0_d;
   assign 	  ep2_to_se0_vc0_d = ep2_goes_to_my_se0 ? ep2_inbox[121:0] : 122'd0;
   output 	  ep2_to_se0_vc0_full;
   assign 	  ep2_to_se0_vc0_full = ep2_goes_to_my_se0;
   input 	  ep2_to_se0_vc0_read;
   output [121:0] ep2_to_se1_vc0_d;
   assign 	  ep2_to_se1_vc0_d = ep2_goes_to_my_se1 ? ep2_inbox[121:0] : 122'd0;
   output 	  ep2_to_se1_vc0_full;
   assign 	  ep2_to_se1_vc0_full = ep2_goes_to_my_se1;
   input 	  ep2_to_se1_vc0_read;
   //output [121:0] ep2_to_se2_vc0_d;
   //assign 	  ep2_to_se2_vc0_d = ep2_goes_to_my_se2 ? ep2_inbox[121:0] : 122'd0;
   //output 	  ep2_to_se2_vc0_full;
   //assign 	  ep2_to_se2_vc0_full = ep2_goes_to_my_se2;
   //input 	  ep2_to_se2_vc0_read;
   //output [121:0] ep2_to_se3_vc0_d;
   //assign 	  ep2_to_se3_vc0_d = ep2_goes_to_my_se3 ? ep2_inbox[121:0] : 122'd0;
   //output 	  ep2_to_se3_vc0_full;
   //assign 	  ep2_to_se3_vc0_full = ep2_goes_to_my_se3;
   //input 	  ep2_to_se3_vc0_read;
   output [121:0] ep3_to_se0_vc0_d;
   assign 	  ep3_to_se0_vc0_d = ep3_goes_to_my_se0 ? ep3_inbox[121:0] : 122'd0;
   output 	  ep3_to_se0_vc0_full;
   assign 	  ep3_to_se0_vc0_full = ep3_goes_to_my_se0;
   input 	  ep3_to_se0_vc0_read;
   output [121:0] ep3_to_se1_vc0_d;
   assign 	  ep3_to_se1_vc0_d = ep3_goes_to_my_se1 ? ep3_inbox[121:0] : 122'd0;
   output 	  ep3_to_se1_vc0_full;
   assign 	  ep3_to_se1_vc0_full  = ep3_goes_to_my_se1;
   input 	  ep3_to_se1_vc0_read;
   //output [121:0] ep3_to_se2_vc0_d;
   //assign 	  ep3_to_se2_vc0_d = ep3_goes_to_my_se2 ? ep3_inbox[121:0] : 122'd0;
   //output 	  ep3_to_se2_vc0_full;
   //assign 	  ep3_to_se2_vc0_full = ep3_goes_to_my_se2;
   //input 	  ep3_to_se2_vc0_read;
   //output [121:0] ep3_to_se3_vc0_d;
   //assign 	  ep3_to_se3_vc0_d = ep3_goes_to_my_se3 ? ep3_inbox[121:0] : 122'd0;
   //output 	  ep3_to_se3_vc0_full;
   //assign 	  ep3_to_se3_vc0_full = ep3_goes_to_my_se3;
   //input 	  ep3_to_se3_vc0_read;
   
   output [121:0] ep0_inbox_vc0G_d;
   assign 	  ep0_inbox_vc0G_d = ep0_goes_to_0G ? ep0_inbox[121:0] : 122'd0;
   output 	  ep0_inbox_vc0G_full;
   assign 	  ep0_inbox_vc0G_full = ep0_goes_to_0G;
   input 	  ep0_inbox_vc0G_read;
   output [121:0] ep1_inbox_vc0G_d;
   assign 	  ep1_inbox_vc0G_d = ep1_goes_to_0G ? ep1_inbox[121:0] : 122'd0;
   output 	  ep1_inbox_vc0G_full;
   assign 	  ep1_inbox_vc0G_full = ep1_goes_to_0G;
   input 	  ep1_inbox_vc0G_read;
   output [121:0] ep2_inbox_vc0G_d;
   assign 	  ep2_inbox_vc0G_d = ep2_goes_to_0G ? ep2_inbox[121:0] : 122'd0;
   output 	  ep2_inbox_vc0G_full;
   assign 	  ep2_inbox_vc0G_full = ep2_goes_to_0G;
   input 	  ep2_inbox_vc0G_read;
   output [121:0] ep3_inbox_vc0G_d;
   assign 	  ep3_inbox_vc0G_d = ep3_goes_to_0G ? ep3_inbox[121:0] : 122'd0;
   output 	  ep3_inbox_vc0G_full;
   assign 	  ep3_inbox_vc0G_full = ep3_goes_to_0G;
   input 	  ep3_inbox_vc0G_read;

   output [121:0] ep0_inbox_vc1L_d;
   assign 	  ep0_inbox_vc1L_d = ep0_goes_to_1L ? ep0_inbox[121:0] : 122'd0;
   output 	  ep0_inbox_vc1L_full;
   assign 	  ep0_inbox_vc1L_full = ep0_goes_to_1L;
   input 	  ep0_inbox_vc1L_read;
   output [121:0] ep1_inbox_vc1L_d;
   assign 	  ep1_inbox_vc1L_d = ep1_goes_to_1L ? ep1_inbox[121:0] : 122'd0;
   output 	  ep1_inbox_vc1L_full;
   assign 	  ep1_inbox_vc1L_full = ep1_goes_to_1L;
   input 	  ep1_inbox_vc1L_read;
   output [121:0] ep2_inbox_vc1L_d;
   assign 	  ep2_inbox_vc1L_d = ep2_goes_to_1L ? ep2_inbox[121:0] : 122'd0;
   output 	  ep2_inbox_vc1L_full;
   assign 	  ep2_inbox_vc1L_full = ep2_goes_to_1L;
   input 	  ep2_inbox_vc1L_read;
   output [121:0] ep3_inbox_vc1L_d;
   assign 	  ep3_inbox_vc1L_d = ep3_goes_to_1L ? ep3_inbox[121:0] : 122'd0;
   output 	  ep3_inbox_vc1L_full;
   assign 	  ep3_inbox_vc1L_full = ep3_goes_to_1L;
   input 	  ep3_inbox_vc1L_read;
   
   output 	  epe_1G_for_nA_vc1_r;
   output [32:0]  epe_1G_for_nA_vc1_d;
   output 	  epe_1G_for_nA_vc1_h;
   input 	  epe_1G_for_nA_vc1_gnt;
   output 	  epe_1G_for_nB_vc1_r;
   output [32:0]  epe_1G_for_nB_vc1_d;
   output 	  epe_1G_for_nB_vc1_h;
   input 	  epe_1G_for_nB_vc1_gnt;

   parameter 	  st_1G_idle = 3'd0;
   parameter 	  st_1G_header = 3'd1;
   parameter 	  st_1G_w1 = 3'd2;
   parameter 	  st_1G_w2 = 3'd3;
   parameter 	  st_1G_w3 = 3'd4;
   parameter 	  st_1G_done = 3'd5;

   reg 		  slurp_ep0, slurp_ep1, slurp_ep2, slurp_ep3;
   reg 		  send_1G_nA, send_1G_nB;

   reg 		  epe_1G_vc1_r;
   reg 		  epe_1G_vc1_h;
   reg [32:0] 	  epe_1G_vc1_d;
   reg 		  inbox_1G_read;

   wire 	  ep0_inbox_vc1G_read = inbox_1G_read & slurp_ep0;
   wire 	  ep1_inbox_vc1G_read = inbox_1G_read & slurp_ep1;
   wire 	  ep2_inbox_vc1G_read = inbox_1G_read & slurp_ep2;
   wire 	  ep3_inbox_vc1G_read = inbox_1G_read & slurp_ep3;
      
   assign 	  epe_1G_for_nA_vc1_r = epe_1G_vc1_r & send_1G_nA;
   assign 	  epe_1G_for_nA_vc1_h = epe_1G_vc1_h & send_1G_nA;
   assign 	  epe_1G_for_nA_vc1_d = send_1G_nA ? epe_1G_vc1_d : 33'd0;
   
   assign 	  epe_1G_for_nB_vc1_r = epe_1G_vc1_r & send_1G_nB;
   assign 	  epe_1G_for_nB_vc1_h = epe_1G_vc1_h & send_1G_nB;
   assign 	  epe_1G_for_nB_vc1_d = send_1G_nB ? epe_1G_vc1_d : 33'd0;
   
   wire [121:0]   inbox_1G = slurp_ep0 ? ep0_inbox[121:0] :
		  slurp_ep1 ? ep1_inbox[121:0] :
		  slurp_ep2 ? ep2_inbox[121:0] :
		  slurp_ep3 ? ep3_inbox[121:0] : 122'd0;
   wire send_1G_gnt = (send_1G_nA & epe_1G_for_nA_vc1_gnt) |
			(send_1G_nB & epe_1G_for_nB_vc1_gnt) ;
   
   
   
   reg [2:0] 	  state_1G;
   reg [2:0] 	  st_nxt_1G;

   always@(posedge CLK or posedge rst)
     if(rst) state_1G <= st_1G_idle;
     else state_1G <= st_nxt_1G;
   
   always@(*) begin
      case(state_1G)
	st_1G_idle: begin
	   if(ep0_goes_to_1G | ep1_goes_to_1G | ep2_goes_to_1G | ep3_goes_to_1G)
	     st_nxt_1G = st_1G_header;
	   else
	     st_nxt_1G = st_1G_idle;
	end
	st_1G_header: begin
	   if(send_1G_gnt)
	     st_nxt_1G = st_1G_w1;
	   else
	     st_nxt_1G = st_1G_header;
	end
	st_1G_w1: begin
	   if(send_1G_gnt)
	     if(inbox_1G[121:118] == `OCM_CMD_VC1_READ)
	       st_nxt_1G = st_1G_done;
	     else
	       st_nxt_1G = st_1G_w2;
	   else
	     st_nxt_1G = st_1G_w1;
	end
	st_1G_w2: begin
	   if(send_1G_gnt)
	     if(inbox_1G[121:118] == `OCM_CMD_VC1_CPNSWP |
		(inbox_1G[121:118] == `OCM_CMD_VC1_WRITE  &
		 inbox_1G[109:102] != 8'd1))
	       st_nxt_1G = st_1G_w3;
	     else
	       st_nxt_1G = st_1G_done;
	   else
	     st_nxt_1G = st_1G_w2;
	end // case: st_1G_w2
	st_1G_w3: begin
	   if(send_1G_gnt)
	     st_nxt_1G = st_1G_done;
	   else
	     st_nxt_1G = st_1G_w3;
	end
	st_1G_done: begin
	   st_nxt_1G = st_1G_idle;
	end
	default:
	  st_nxt_1G = st_1G_idle;
      endcase // case(state)
   end // always@ (*)

   always@(posedge CLK or posedge rst) begin
      if(rst) begin
	 slurp_ep0 <= 1'b0;
	 slurp_ep1 <= 1'b0;
	 slurp_ep2 <= 1'b0;
	 slurp_ep3 <= 1'b0;
	 send_1G_nA <= 1'b0;
	 send_1G_nB <= 1'b0;
      end
      else begin
	 case(state_1G)
	   st_1G_idle: begin
	      if(st_nxt_1G != st_1G_idle) begin
		 slurp_ep0 <= ep0_goes_to_1G;
		 slurp_ep1 <= ~ep0_goes_to_1G & ep1_goes_to_1G;
		 slurp_ep2 <= ~ep0_goes_to_1G & ~ep1_goes_to_1G & ep2_goes_to_1G;
		 slurp_ep3 <= ~ep0_goes_to_1G & ~ep1_goes_to_1G & 
			      ~ep2_goes_to_1G & ep3_goes_to_1G;
		 if(ep0_goes_to_1G) begin
		    send_1G_nA <= does_this_addr_goto_nA(ep0_inbox[31:0]);
		    send_1G_nB <= does_this_addr_goto_nB(ep0_inbox[31:0]);
		 end
		 else if(ep1_goes_to_1G) begin
		    send_1G_nA <= does_this_addr_goto_nA(ep1_inbox[31:0]);
		    send_1G_nB <= does_this_addr_goto_nB(ep1_inbox[31:0]);
		 end
		 else if(ep1_goes_to_1G) begin
		    send_1G_nA <= does_this_addr_goto_nA(ep2_inbox[31:0]);
		    send_1G_nB <= does_this_addr_goto_nB(ep2_inbox[31:0]);
		 end
		 else begin
		    send_1G_nA <= does_this_addr_goto_nA(ep3_inbox[31:0]);
		    send_1G_nB <= does_this_addr_goto_nB(ep3_inbox[31:0]);
		 end
	      end // if (st_nxt_1G != st_1G_idle)
	   end // case: st_1G_idle
	   st_1G_done: begin
	      slurp_ep0 <= 1'b0;
	      slurp_ep0 <= 1'b0;
	      slurp_ep0 <= 1'b0;
	      slurp_ep0 <= 1'b0;
	      send_1G_nA <= 1'b0;
	      send_1G_nB <= 1'b0;
	   end
	   default: begin
	   end
	endcase // case(state)
      end // else: !if(rst)
   end // always@ (posedge CLK)

   always@(*) begin
      epe_1G_vc1_r = 1'b0;
      epe_1G_vc1_h = 1'b0;
      epe_1G_vc1_d = 33'd0;
      inbox_1G_read = 1'b0;
      case(state_1G) 
	st_1G_idle: begin
	end
	st_1G_header: begin
	   epe_1G_vc1_r = 1'b1;
	   epe_1G_vc1_h = 1'b1;
	   epe_1G_vc1_d[32] = 1'b1;
	   epe_1G_vc1_d[31:26] = send_1G_nA ? nA_node_name : nB_node_name;
	   epe_1G_vc1_d[25:20] = inbox_1G[101:96];
	   epe_1G_vc1_d[19:0] = inbox_1G[121:102];
	end
	st_1G_w1: begin
	   epe_1G_vc1_r = 1'b1;
	   epe_1G_vc1_h = 1'b1;
	   epe_1G_vc1_d = {1'b0, inbox_1G[31:0]};
	end
	st_1G_w2: begin
	   epe_1G_vc1_r = 1'b1;
	   epe_1G_vc1_h = 1'b1;
	   epe_1G_vc1_d = {1'b0, inbox_1G[63:32]};
	end
	st_1G_w3: begin
	   epe_1G_vc1_r = 1'b1;
	   epe_1G_vc1_h = 1'b1;
	   epe_1G_vc1_d = {1'b0, inbox_1G[95:64]};
	end
	st_1G_done: begin
	   inbox_1G_read = 1'b1;
	end
	default: begin
	end
      endcase // case(state)
   end // always@ (*)
   
   assign ep0_inbox_read = (ep0_goes_to_1L & ep0_inbox_vc1L_read) |
			   (ep0_goes_to_1G & ep0_inbox_vc1G_read) |
			   (ep0_goes_to_0G & ep0_inbox_vc0G_read) |
			   (ep0_goes_to_my_se0 & ep0_to_se0_vc0_read) |
			   (ep0_goes_to_my_se1 & ep0_to_se1_vc0_read)/* |
			   (ep0_goes_to_my_se2 & ep0_to_se2_vc0_read) |
			   (ep0_goes_to_my_se3 & ep0_to_se3_vc0_read)*/;

   assign ep1_inbox_read = (ep1_goes_to_1L & ep1_inbox_vc1L_read) |
			   (ep1_goes_to_1G & ep1_inbox_vc1G_read) |
			   (ep1_goes_to_0G & ep1_inbox_vc0G_read) |
			   (ep1_goes_to_my_se0 & ep1_to_se0_vc0_read) |
			   (ep1_goes_to_my_se1 & ep1_to_se1_vc0_read)/* |
			   (ep1_goes_to_my_se2 & ep1_to_se2_vc0_read) |
			   (ep1_goes_to_my_se3 & ep1_to_se3_vc0_read)*/;

   assign ep2_inbox_read = (ep2_goes_to_1L & ep2_inbox_vc1L_read) |
			   (ep2_goes_to_1G & ep2_inbox_vc1G_read) |
			   (ep2_goes_to_0G & ep2_inbox_vc0G_read) |
			   (ep2_goes_to_my_se0 & ep2_to_se0_vc0_read) |
			   (ep2_goes_to_my_se1 & ep2_to_se1_vc0_read)/* |
			   (ep2_goes_to_my_se2 & ep2_to_se2_vc0_read) |
			   (ep2_goes_to_my_se3 & ep2_to_se3_vc0_read)*/;

   assign ep3_inbox_read = (ep3_goes_to_1L & ep3_inbox_vc1L_read) |
			   (ep3_goes_to_1G & ep3_inbox_vc1G_read) |
			   (ep3_goes_to_0G & ep3_inbox_vc0G_read) |
			   (ep3_goes_to_my_se0 & ep3_to_se0_vc0_read) |
			   (ep3_goes_to_my_se1 & ep3_to_se1_vc0_read) /*|
			   (ep3_goes_to_my_se2 & ep3_to_se2_vc0_read) |
			   (ep3_goes_to_my_se3 & ep3_to_se3_vc0_read)*/;
   
   //Output Conversion:
   //nA VC3, nB VC3 -> CONVERT -> inbox 
   //se0 VC3, se1 VC3, se2 VC3, se3 VC3 -> inbox
   //sm1L -> inbox
   output [124:0] ep0_outbox; //todo: take into account the outbox reads...
   input 	  ep0_outbox_read; 
   output [124:0] ep1_outbox;
   input 	  ep1_outbox_read;
   output [124:0] ep2_outbox;
   input 	  ep2_outbox_read;
   output [124:0] ep3_outbox;
   input 	  ep3_outbox_read;

   reg [124:0] 	  ep0_outbox;
   reg [124:0] 	  ep1_outbox;
   reg [124:0] 	  ep2_outbox;
   reg [124:0] 	  ep3_outbox;

   //Note that the arb for steering vc3 happens in e0_top_level
   //That's stupid, I'm steering here...
   input [32:0]   ep_nA_vc3_incoming_d;
   input 	  ep_nA_vc3_incoming_e;
   output 	  ep_nA_vc3_incoming_read;
   input [32:0]   ep_nB_vc3_incoming_d;
   input 	  ep_nB_vc3_incoming_e;
   output 	  ep_nB_vc3_incoming_read;

   input [121:0]  se0_for_ep0_vc3_d;
   input 	  se0_for_ep0_vc3_full;
   output 	  se0_for_ep0_vc3_gnt;
   input [121:0]  se0_for_ep1_vc3_d;
   input 	  se0_for_ep1_vc3_full;
   output 	  se0_for_ep1_vc3_gnt;
   input [121:0]  se0_for_ep2_vc3_d;
   input 	  se0_for_ep2_vc3_full;
   output 	  se0_for_ep2_vc3_gnt;
   input [121:0]  se0_for_ep3_vc3_d;
   input 	  se0_for_ep3_vc3_full;
   output 	  se0_for_ep3_vc3_gnt;
   input [121:0]  se1_for_ep0_vc3_d;
   input 	  se1_for_ep0_vc3_full;
   output 	  se1_for_ep0_vc3_gnt;
   input [121:0]  se1_for_ep1_vc3_d;
   input 	  se1_for_ep1_vc3_full;
   output 	  se1_for_ep1_vc3_gnt;
   input [121:0]  se1_for_ep2_vc3_d;
   input 	  se1_for_ep2_vc3_full;
   output 	  se1_for_ep2_vc3_gnt;
   input [121:0]  se1_for_ep3_vc3_d;
   input 	  se1_for_ep3_vc3_full;
   output 	  se1_for_ep3_vc3_gnt;
   //input [121:0]  se2_for_ep0_vc3_d;
   //input 	  se2_for_ep0_vc3_full;
   //output 	  se2_for_ep0_vc3_gnt;
   //input [121:0]  se2_for_ep1_vc3_d;
   //input 	  se2_for_ep1_vc3_full;
   //output 	  se2_for_ep1_vc3_gnt;
   //input [121:0]  se2_for_ep2_vc3_d;
   //input 	  se2_for_ep2_vc3_full;
   //output 	  se2_for_ep2_vc3_gnt;
   //input [121:0]  se2_for_ep3_vc3_d;
   //input 	  se2_for_ep3_vc3_full;
   //output 	  se2_for_ep3_vc3_gnt;
   //input [121:0]  se3_for_ep0_vc3_d;
   //input 	  se3_for_ep0_vc3_full;
   //output 	  se3_for_ep0_vc3_gnt;
   //input [121:0]  se3_for_ep1_vc3_d;
   //input 	  se3_for_ep1_vc3_full;
   //output 	  se3_for_ep1_vc3_gnt;
   //input [121:0]  se3_for_ep2_vc3_d;
   //input 	  se3_for_ep2_vc3_full;
   //output 	  se3_for_ep2_vc3_gnt;
   //input [121:0]  se3_for_ep3_vc3_d;
   //input 	  se3_for_ep3_vc3_full;
   //output 	  se3_for_ep3_vc3_gnt;

   input [121:0]  sm1L_for_ep0_d;
   input 	  sm1L_for_ep0_full;
   output 	  sm1L_for_ep0_gnt;
   input [121:0]  sm1L_for_ep1_d;
   input 	  sm1L_for_ep1_full;
   output 	  sm1L_for_ep1_gnt;
   input [121:0]  sm1L_for_ep2_d;
   input 	  sm1L_for_ep2_full;
   output 	  sm1L_for_ep2_gnt;
   input [121:0]  sm1L_for_ep3_d;
   input 	  sm1L_for_ep3_full;
   output 	  sm1L_for_ep3_gnt;

   
   reg 		  slurp_nA_vc3, slurp_nB_vc3;
   reg 		  send_3G_ep0, send_3G_ep1, send_3G_ep2, send_3G_ep3;
   wire [32:0] 	  ep_vc3_incoming_d = slurp_nA_vc3 ? ep_nA_vc3_incoming_d :
		  slurp_nB_vc3 ? ep_nB_vc3_incoming_d : 33'd0;
   wire 	  ep_vc3_incoming_e = slurp_nA_vc3 ? ep_nA_vc3_incoming_e :
		  slurp_nB_vc3 ? ep_nB_vc3_incoming_e : 1'b1;
   reg 		  ep_vc3_incoming_read;
   assign 	  ep_nA_vc3_incoming_read = ep_vc3_incoming_read & slurp_nA_vc3;
   assign 	  ep_nB_vc3_incoming_read = ep_vc3_incoming_read & slurp_nB_vc3;
      
   reg 		  vc3G_going_2;
   
   //todo the vector reads from EP don't work
   parameter 	  st_3G_idle = 3'd0;
   //parameter 	  st_3G_service = 4'd1;
   parameter 	  st_3G_header = 3'd2;
   parameter 	  st_3G_w1 = 3'd3;
   parameter 	  st_3G_w2 = 3'd4;
   parameter 	  st_3G_done = 3'd5;

   reg [2:0] 	  state_3G;
   reg [2:0] 	  st_nxt_3G;

   always@(posedge CLK or posedge rst)
     if(rst) state_3G <= st_3G_idle;
     else state_3G <= st_nxt_3G;

   wire 	  can_i_move_A = (ep_nA_vc3_incoming_d[27:26] == 2'd0 & ~ep0_outbox[122]) |
				   (ep_nA_vc3_incoming_d[27:26] == 2'd1 & ~ep1_outbox[122]) |
				     (ep_nA_vc3_incoming_d[27:26] == 2'd2 & ~ep2_outbox[122]) |
		  (ep_nA_vc3_incoming_d[27:26] == 2'd3 && ~ep3_outbox[122]);
   
   wire 	  can_i_move_B = (ep_nB_vc3_incoming_d[27:26] == 2'd0 & ~ep0_outbox[122]) |
				   (ep_nB_vc3_incoming_d[27:26] == 2'd1 & ~ep1_outbox[122]) |
				     (ep_nB_vc3_incoming_d[27:26] == 2'd2 & ~ep2_outbox[122]) |
		  (ep_nB_vc3_incoming_d[27:26] == 2'd3 && ~ep3_outbox[122]);
   
   always@(*) begin
      st_nxt_3G = state_3G;
      case(state_3G)
	st_3G_idle: begin
	   if((can_i_move_A && ~ep_nA_vc3_incoming_e) | (can_i_move_B && ~ep_nB_vc3_incoming_e))
	     st_nxt_3G = st_3G_header;
	end
	st_3G_header: begin
	   if(ep_vc3_incoming_d[19:16] == `OCM_CMD_VC3_READ_P |
	      ep_vc3_incoming_d[19:16] == `OCM_CMD_VC3_CPNSWP_P)
	     st_nxt_3G = st_3G_w1;
	   else
	     st_nxt_3G = st_3G_done;
	end
	st_3G_w1: begin
	   if(~ep_vc3_incoming_e)
	     if(vc3G_going_2)
	       st_nxt_3G = st_3G_w2;
	     else
	       st_nxt_3G = st_3G_done;
	end
	st_3G_w2: begin
	   if(~ep_vc3_incoming_e)
	     st_nxt_3G = st_3G_done;
	end
	st_3G_done: begin
	   st_nxt_3G = st_3G_idle;
	end
	default: begin
	end
      endcase
   end // always@ (*)
      
   
   always@(posedge CLK or posedge rst) begin
      if(rst) begin
	 slurp_nA_vc3 <= 1'b0;
	 slurp_nB_vc3 <= 1'b0;
	 send_3G_ep0 <= 1'b0;
	 send_3G_ep1 <= 1'b0;
	 send_3G_ep2 <= 1'b0;
	 send_3G_ep3 <= 1'b0;
	 vc3G_going_2 <= 1'b0;
	 ep0_outbox <= 125'd0;
	 ep1_outbox <= 125'd0;
	 ep2_outbox <= 125'd0;
	 ep3_outbox <= 125'd0;
      end
      else begin
	 case(state_3G)
	   st_3G_idle: begin
	      if(st_nxt_3G != st_3G_idle) begin
		 slurp_nA_vc3 <= ~ep_nA_vc3_incoming_e & can_i_move_A;
		 slurp_nB_vc3 <= (ep_nA_vc3_incoming_e | ~can_i_move_A) & 
				 (~ep_nB_vc3_incoming_e & can_i_move_B);
		 //This is encoding specific.....
		 if(~ep_nA_vc3_incoming_e) begin
		    send_3G_ep0 <= ep_nA_vc3_incoming_d[27:26] == 2'd0;
		    send_3G_ep1 <= ep_nA_vc3_incoming_d[27:26] == 2'd1;
		    send_3G_ep2 <= ep_nA_vc3_incoming_d[27:26] == 2'd2;
		    send_3G_ep3 <= ep_nA_vc3_incoming_d[27:26] == 2'd3;
		    vc3G_going_2 <= ep_nA_vc3_incoming_d[19:16] == `OCM_CMD_VC3_READ_P &
				    ep_nA_vc3_incoming_d[7:0] == 8'd2;
		 end
		 if(~ep_nB_vc3_incoming_e) begin
		    send_3G_ep0 <= ep_nB_vc3_incoming_d[27:26] == 2'd0;
		    send_3G_ep1 <= ep_nB_vc3_incoming_d[27:26] == 2'd1;
		    send_3G_ep2 <= ep_nB_vc3_incoming_d[27:26] == 2'd2;
		    send_3G_ep3 <= ep_nB_vc3_incoming_d[27:26] == 2'd3;
		    vc3G_going_2 <= ep_nB_vc3_incoming_d[19:16] == `OCM_CMD_VC3_READ_P &
				    ep_nB_vc3_incoming_d[7:0] == 8'd2;
		 end
	      end // if (st_nxt_3G != st_3G_idle)
	      else begin
		 if(~ep0_outbox[122]) begin
		    if(se0_for_ep0_vc3_full) begin
		       ep0_outbox <= {3'b111, se0_for_ep0_vc3_d};
		    end
		    else if(se1_for_ep0_vc3_full) begin
		       ep0_outbox <= {3'b111, se1_for_ep0_vc3_d};
		    end
		    /*else if(se2_for_ep0_vc3_full) begin
		       ep0_outbox <= {3'b111, se2_for_ep0_vc3_d};
		    end
		    else if(se3_for_ep0_vc3_full) begin
		       ep0_outbox <= {3'b111, se3_for_ep0_vc3_d};
		    end*/
		    else if(sm1L_for_ep0_full) begin
		       ep0_outbox <= {3'b111, sm1L_for_ep0_d};
		    end
		 end // if (~ep0_outbox[122])
		 else if(ep0_outbox[122] && ep0_outbox_read)
		   ep0_outbox <= 125'd0;
		 
		 if(~ep1_outbox[122]) begin
		    if(se0_for_ep1_vc3_full) begin
		       ep1_outbox <= {3'b111, se0_for_ep1_vc3_d};
		    end
		    else if(se1_for_ep1_vc3_full) begin
		       ep1_outbox <= {3'b111, se1_for_ep1_vc3_d};
		    end
		   /* else if(se2_for_ep1_vc3_full) begin
		       ep1_outbox <= {3'b111, se2_for_ep1_vc3_d};
		    end
		    else if(se3_for_ep1_vc3_full) begin
		       ep1_outbox <= {3'b111, se3_for_ep1_vc3_d};
		    end*/
		    else if(sm1L_for_ep1_full) begin
		       ep1_outbox <= {3'b111, sm1L_for_ep1_d};
		    end
		 end // if (~ep1_outbox[122])
		 else if(ep1_outbox[122] && ep1_outbox_read)
		   ep1_outbox <= 125'd0;
		 
		 if(~ep2_outbox[122]) begin
		    if(se0_for_ep2_vc3_full) begin
		       ep2_outbox <= {3'b111, se0_for_ep2_vc3_d};
		    end
		    else if(se1_for_ep2_vc3_full) begin
		       ep2_outbox <= {3'b111, se1_for_ep2_vc3_d};
		    end
		   /* else if(se2_for_ep2_vc3_full) begin
		       ep2_outbox <= {3'b111, se2_for_ep2_vc3_d};
		    end
		    else if(se3_for_ep2_vc3_full) begin
		       ep2_outbox <= {3'b111, se3_for_ep2_vc3_d};
		    end*/
		    else if(sm1L_for_ep2_full) begin
		       ep2_outbox <= {3'b111, sm1L_for_ep2_d};
		    end
		 end // if (~ep2_outbox[122]) 
		 else if(ep2_outbox[122] && ep2_outbox_read)
		   ep2_outbox <= 125'd0;
		 
		 if(~ep3_outbox[122]) begin
		    if(se0_for_ep3_vc3_full) begin
		       ep3_outbox <= {3'b111, se0_for_ep3_vc3_d};
		    end
		    else if(se1_for_ep3_vc3_full) begin
		       ep3_outbox <= {3'b111, se1_for_ep3_vc3_d};
		    end
		    /*else if(se2_for_ep3_vc3_full) begin
		       ep3_outbox <= {3'b111, se2_for_ep3_vc3_d};
		    end
		    else if(se3_for_ep3_vc3_full) begin
		       ep3_outbox <= {3'b111, se3_for_ep3_vc3_d};
		    end*/
		    else if(sm1L_for_ep3_full) begin
		       ep3_outbox <= {3'b111, sm1L_for_ep3_d};
		    end
		 end // if (~ep3_outbox[122]) 
		 else if(ep3_outbox[122] && ep3_outbox_read)
		   ep3_outbox <= 125'd0;
		 
	      end // else: !if(st_nxt_3G != st_3G_idle)
	   end // case: st_3G_idle
	   st_3G_header: begin
	      if(send_3G_ep0) begin
		 ep0_outbox[121:118] <= ep_vc3_incoming_d[19:16]; //command
		 ep0_outbox[117:102] <= ep_vc3_incoming_d[15:0]; //id and size
		 ep0_outbox[101:96] <= ep_vc3_incoming_d[25:20];
		 ep0_outbox[95:0] <= 96'd0;
	      end
	      if(send_3G_ep1) begin
		 ep1_outbox[121:118] <= ep_vc3_incoming_d[19:16]; //command
		 ep1_outbox[117:102] <= ep_vc3_incoming_d[15:0]; //id and size
		 ep1_outbox[101:96] <= ep_vc3_incoming_d[25:20];
		 ep1_outbox[95:0] <= 96'd0;
	      end
	      if(send_3G_ep2) begin
		 ep2_outbox[121:118] <= ep_vc3_incoming_d[19:16]; //command
		 ep2_outbox[117:102] <= ep_vc3_incoming_d[15:0]; //id and size
		 ep2_outbox[101:96] <= ep_vc3_incoming_d[25:20];
		 ep2_outbox[95:0] <= 96'd0;
	      end
	      if(send_3G_ep3) begin
		 ep3_outbox[121:118] <= ep_vc3_incoming_d[19:16]; //command
		 ep3_outbox[117:102] <= ep_vc3_incoming_d[15:0]; //id and size
		 ep3_outbox[101:96] <= ep_vc3_incoming_d[25:20];
		 ep3_outbox[95:0] <= 96'd0;
	      end
	   end // case: st_3G_header
	   st_3G_w1: begin
	      if(st_nxt_3G != st_3G_w1) begin
		 if(send_3G_ep0)
		   ep0_outbox[31:0] <= ep_vc3_incoming_d[31:0];
		 if(send_3G_ep1)
		   ep1_outbox[31:0] <= ep_vc3_incoming_d[31:0];
		 if(send_3G_ep2)
		   ep2_outbox[31:0] <= ep_vc3_incoming_d[31:0];
		 if(send_3G_ep3)
		   ep3_outbox[31:0] <= ep_vc3_incoming_d[31:0];
	      end
	   end // case: st_3G_w1
	   st_3G_w2: begin
	      if(st_nxt_3G != st_3G_w1) begin
		 if(send_3G_ep0)
		   ep0_outbox[63:32] <= ep_vc3_incoming_d[31:0];
		 if(send_3G_ep1)
		   ep1_outbox[63:32] <= ep_vc3_incoming_d[31:0];
		 if(send_3G_ep2)
		   ep2_outbox[63:32] <= ep_vc3_incoming_d[31:0];
		 if(send_3G_ep3)
		   ep3_outbox[63:32] <= ep_vc3_incoming_d[31:0];
	      end
	   end
	   st_3G_done: begin
	      if(send_3G_ep0)
		ep0_outbox[124:122] <= 3'b111;
	      if(send_3G_ep1)
		ep1_outbox[124:122] <= 3'b111;
	      if(send_3G_ep2)
		ep2_outbox[124:122] <= 3'b111;
	      if(send_3G_ep3)
		ep3_outbox[124:122] <= 3'b111;
	      send_3G_ep0 <= 1'b0;
	      send_3G_ep1 <= 1'b0;
	      send_3G_ep2 <= 1'b0;
	      send_3G_ep3 <= 1'b0;
	   end // case: st_3G_done
	   default: begin
	   end
	 endcase // case(state)
      end // else: !if(rst)
   end // always@ (posedge CLK)
   
   assign se0_for_ep0_vc3_gnt = ~ep0_outbox[122] & 
				~(send_3G_ep0 | st_nxt_3G == st_3G_header) &
				se0_for_ep0_vc3_full;
   
   assign se1_for_ep0_vc3_gnt = ~ep0_outbox[122] & 
	  ~(send_3G_ep0 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep0_vc3_full & se1_for_ep0_vc3_full;

   /*assign se2_for_ep0_vc3_gnt = ~ep0_outbox[122] & 
    ~(send_3G_ep0 | st_nxt_3G == st_3G_header) &
    ~se0_for_ep0_vc3_full & ~se1_for_ep0_vc3_full &
    se2_for_ep0_vc3_full;*/
   
   /*   assign se3_for_ep0_vc3_gnt = ~ep0_outbox[122] & 
    ~(send_3G_ep0 | st_nxt_3G == st_3G_header) &
    ~se0_for_ep0_vc3_full & ~se1_for_ep0_vc3_full &
    ~se2_for_ep0_vc3_full & se3_for_ep0_vc3_full;*/
   
   assign sm1L_for_ep0_gnt = ~ep0_outbox[122] & 
	  ~(send_3G_ep0 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep0_vc3_full & ~se1_for_ep0_vc3_full &
	  /*~se2_for_ep0_vc3_full & ~se3_for_ep0_vc3_full &*/
	  sm1L_for_ep0_full;
   /*
   always@(posedge CLK) begin
      if(rst) begin
	 ep0_outbox <= 125'd0;
      end
      else /*I'm not doing much arb.../ begin
	 if(ep0_outbox[122]) begin
	    if(ep0_outbox_read) begin
	       ep0_outbox <= 125'd0;
	    end
	 end
   	 else begin
	    if(send_3G_ep0 | st_nxt_3G == st_3G_header) begin
	       //The state machine called shotgun on the mailbox
	    end
	    else if(se0_for_ep0_vc3_full) begin
	       ep0_outbox <= {3'b111, se0_for_ep0_vc3_d};
	    end
	    else if(se1_for_ep0_vc3_full) begin
	       ep0_outbox <= {3'b111, se1_for_ep0_vc3_d};
	    end
	    else if(se2_for_ep0_vc3_full) begin
	       ep0_outbox <= {3'b111, se2_for_ep0_vc3_d};
	    end
	    else if(se3_for_ep0_vc3_full) begin
	       ep0_outbox <= {3'b111, se3_for_ep0_vc3_d};
	    end
	    else if(sm1L_for_ep0_full) begin
	       ep0_outbox <= {3'b111, sm1L_for_ep0_d};
	    end
	 end // else: !if(ep0_outbox[122])
      end // else: !if(rst)
   end // always@ (posedge CLK)*/
   
   assign se0_for_ep1_vc3_gnt = ~ep1_outbox[122] & 
	~(send_3G_ep1 | st_nxt_3G == st_3G_header) &
	se0_for_ep1_vc3_full;
   
   assign se1_for_ep1_vc3_gnt = ~ep1_outbox[122] & 
	  ~(send_3G_ep1 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep1_vc3_full & se1_for_ep1_vc3_full;

   /*assign se2_for_ep1_vc3_gnt = ~ep1_outbox[122] & 
	  ~(send_3G_ep1 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep1_vc3_full & ~se1_for_ep1_vc3_full &
	  se2_for_ep1_vc3_full;
   
   assign se3_for_ep1_vc3_gnt = ~ep1_outbox[122] & 
	  ~(send_3G_ep1 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep1_vc3_full & ~se1_for_ep1_vc3_full &
	  ~se2_for_ep1_vc3_full & se3_for_ep1_vc3_full;*/

   assign sm1L_for_ep1_gnt = ~ep1_outbox[122] & 
	  ~(send_3G_ep1 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep1_vc3_full & ~se1_for_ep1_vc3_full &
	/*~se2_for_ep1_vc3_full & ~se3_for_ep1_vc3_full &*/
	  sm1L_for_ep1_full;
   
  /* always@(posedge CLK) begin
      if(rst) begin
	 ep1_outbox <= 125'd0;
      end
      else /*I'm not doing much arb.../ begin
	 if(ep1_outbox[122])
	   if(ep1_outbox[122]) begin
	      if(ep1_outbox_read) begin
		 ep1_outbox <= 125'd0;
	      end
	   end
   	   else begin
	      if(send_3G_ep1 | st_nxt_3G == st_3G_header) begin
		 //The state machine called shotgun on the mailbox
	      end
	      else if(se0_for_ep1_vc3_full) begin
		 ep1_outbox <= {3'b111, se0_for_ep1_vc3_d};
	      end
	      else if(se1_for_ep1_vc3_full) begin
		 ep1_outbox <= {3'b111, se1_for_ep1_vc3_d};
	      end
	      else if(se2_for_ep1_vc3_full) begin
		 ep1_outbox <= {3'b111, se2_for_ep1_vc3_d};
	      end
	      else if(se3_for_ep1_vc3_full) begin
		 ep1_outbox <= {3'b111, se3_for_ep1_vc3_d};
	      end
	      else if(sm1L_for_ep1_full) begin
		 ep1_outbox <= {3'b111, sm1L_for_ep1_d};
	      end
	   end // else: !if(ep1_outbox[122])
      end // else: !if(rst)
   end // always@ (posedge CLK)*/
   
    
  assign se0_for_ep2_vc3_gnt = ~ep2_outbox[122] & 
				~(send_3G_ep2 | st_nxt_3G == st_3G_header) &
				se0_for_ep2_vc3_full;
   
   assign se1_for_ep2_vc3_gnt = ~ep2_outbox[122] & 
	  ~(send_3G_ep2 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep2_vc3_full & se1_for_ep2_vc3_full;

   /*assign se2_for_ep2_vc3_gnt = ~ep2_outbox[122] & 
	  ~(send_3G_ep2 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep2_vc3_full & ~se1_for_ep2_vc3_full &
	  se2_for_ep2_vc3_full;
   
   assign se3_for_ep2_vc3_gnt = ~ep2_outbox[122] & 
	  ~(send_3G_ep2 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep2_vc3_full & ~se1_for_ep2_vc3_full &
	  ~se2_for_ep2_vc3_full & se3_for_ep2_vc3_full;*/

   assign sm1L_for_ep2_gnt = ~ep2_outbox[122] & 
	  ~(send_3G_ep2 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep2_vc3_full & ~se1_for_ep2_vc3_full &
	  /*~se2_for_ep2_vc3_full & ~se3_for_ep2_vc3_full &*/
	  sm1L_for_ep2_full;
   
/*   always@(posedge CLK) begin
      if(rst) begin
	 ep2_outbox <= 125'd0;
      end
      else /*I'm not doing much arb.../ begin
	 if(ep2_outbox[122])
	   if(ep2_outbox[122]) begin
	      if(ep2_outbox_read) begin
		 ep2_outbox <= 125'd0;
	      end
	   end
   	   else begin
	      if(send_3G_ep2 | st_nxt_3G == st_3G_header) begin
		 //The state machine called shotgun on the mailbox
	      end
	      else if(se0_for_ep2_vc3_full) begin
		 ep2_outbox <= {3'b111, se0_for_ep2_vc3_d};
	      end
	      else if(se1_for_ep2_vc3_full) begin
		 ep2_outbox <= {3'b111, se1_for_ep2_vc3_d};
	      end
	      else if(se2_for_ep2_vc3_full) begin
		 ep2_outbox <= {3'b111, se2_for_ep2_vc3_d};
	      end
	      else if(se3_for_ep2_vc3_full) begin
		 ep2_outbox <= {3'b111, se3_for_ep2_vc3_d};
	      end
	      else if(sm1L_for_ep2_full) begin
		 ep2_outbox <= {3'b111, sm1L_for_ep2_d};
	      end
	   end // else: !if(ep2_outbox[122])
      end // else: !if(rst)
   end // always@ (posedge CLK) */
   
   
   assign se0_for_ep3_vc3_gnt = ~ep3_outbox[122] &
				~(send_3G_ep3 | st_nxt_3G == st_3G_header) &
				se0_for_ep3_vc3_full;
   
   assign se1_for_ep3_vc3_gnt = ~ep3_outbox[122] & 
	  ~(send_3G_ep3 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep3_vc3_full & se1_for_ep3_vc3_full;

   /*assign se2_for_ep3_vc3_gnt = ~ep3_outbox[122] & 
	  ~(send_3G_ep3 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep3_vc3_full & ~se1_for_ep3_vc3_full &
	  se2_for_ep3_vc3_full;
   
   assign se3_for_ep3_vc3_gnt = ~ep3_outbox[122] & 
	  ~(send_3G_ep3 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep3_vc3_full & ~se1_for_ep3_vc3_full &
	  ~se2_for_ep3_vc3_full & se3_for_ep3_vc3_full;*/

   assign sm1L_for_ep3_gnt = ~ep3_outbox[122] & 
	  ~(send_3G_ep3 | st_nxt_3G == st_3G_header) &
	  ~se0_for_ep3_vc3_full & ~se1_for_ep3_vc3_full &
	 /*~se2_for_ep3_vc3_full & ~se3_for_ep3_vc3_full &*/
	  sm1L_for_ep3_full;
   /*
   always@(posedge CLK) begin
      if(rst) begin
	 ep3_outbox <= 125'd0;
      end
      else /*I'm not doing much arb... begin
	 if(ep3_outbox[122])
	   if(ep3_outbox[122]) begin
	      if(ep3_outbox_read) begin
		 ep3_outbox <= 125'd0;
	      end
	   end
   	   else begin
	      if(send_3G_ep3 | st_nxt_3G == st_3G_header) begin
		 //The state machine called shotgun on the mailbox
	      end
	      else if(se0_for_ep3_vc3_full) begin
		 ep3_outbox <= {3'b111, se0_for_ep3_vc3_d};
	      end
	      else if(se1_for_ep3_vc3_full) begin
		 ep3_outbox <= {3'b111, se1_for_ep3_vc3_d};
	      end
	      else if(se2_for_ep3_vc3_full) begin
		 ep3_outbox <= {3'b111, se2_for_ep3_vc3_d};
	      end
	      else if(se3_for_ep3_vc3_full) begin
		 ep3_outbox <= {3'b111, se3_for_ep3_vc3_d};
	      end
	      else if(sm1L_for_ep3_full) begin
		 ep3_outbox <= {3'b111, sm1L_for_ep3_d};
	      end
	   end // else: !if(ep3_outbox[122])
      end // else: !if(rst)
   end // always@ (posedge CLK)*/
   		      

   always@(*) begin
      if(state_3G == st_3G_header | state_3G == st_3G_w1 | state_3G == st_3G_w2)
	ep_vc3_incoming_read = 1'b1;
      else
	ep_vc3_incoming_read = 1'b0;
   end
   
    function does_this_addr_goto_me;
      input [31:0] dst;
      begin
      	 if((dst[30] & my_addr_header_30) | 
	    (dst[29:16] == my_addr_header_2916))
           does_this_addr_goto_me = 1'b1;
         else
           does_this_addr_goto_me = 1'b0;
      end
   endfunction // does_this_addr_goto_nC
   
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
   endfunction // does_this_addr_goto_nB

   
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

      
	  


endmodule // ep_box_muxdemux

/*input [32:0]   ep0_nA_vc3_incoming_d;
 input 	  ep0_nA_vc3_incoming_e;
 output 	  ep0_nA_vc3_incoming_read;
 input [32:0]   ep0_nB_vc3_incoming_d;
 input 	  ep0_nB_vc3_incoming_e;
 output 	  ep0_nB_vc3_incoming_read;
 input [32:0]   ep1_nA_vc3_incoming_d;
 input 	  ep1_nA_vc3_incoming_e;
 output 	  ep1_nA_vc3_incoming_read;
 input [32:0]   ep1_nB_vc3_incoming_d;
 input 	  ep1_nB_vc3_incoming_e;
 output 	  ep1_nB_vc3_incoming_read;
 input [32:0]   ep2_nA_vc3_incoming_d;
 input 	  ep2_nA_vc3_incoming_e;
 output 	  ep2_nA_vc3_incoming_read;
 input [32:0]   ep2_nB_vc3_incoming_d;
 input 	  ep2_nB_vc3_incoming_e;
 output 	  ep2_nB_vc3_incoming_read;
 input [32:0]   ep3_nA_vc3_incoming_d;
 input 	  ep3_nA_vc3_incoming_e;
 output 	  ep3_nA_vc3_incoming_read;
 input [32:0]   ep3_nB_vc3_incoming_d;
 input 	  ep3_nB_vc3_incoming_e;
 output 	  ep3_nB_vc3_incoming_read;*/
   
