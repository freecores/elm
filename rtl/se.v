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

module se(/*AUTOARG*/
   // Outputs
   ep0_to_se_vc0_read, ep1_to_se_vc0_read, ep2_to_se_vc0_read, 
   ep3_to_se_vc0_read, nA_vc0_incoming_read, nB_vc0_incoming_read, 
   nA_vc3_incoming_read, nB_vc3_incoming_read, se_for_nA_vc1_r, 
   se_for_nA_vc1_h, se_for_nA_vc1_d, se_for_nB_vc1_r, 
   se_for_nB_vc1_h, se_for_nB_vc1_d, se_for_ep0_vc3_d, 
   se_for_ep0_vc3_full, se_for_ep1_vc3_d, se_for_ep1_vc3_full, 
   se_for_ep2_vc3_d, se_for_ep2_vc3_full, se_for_ep3_vc3_d, 
   se_for_ep3_vc3_full, se_for_nA_vc3_r, se_for_nA_vc3_h, 
   se_for_nA_vc3_d, se_for_nB_vc3_r, se_for_nB_vc3_h, 
   se_for_nB_vc3_d, se_mem_req, se_mem_wen_b, se_mem_addr, 
   se_mem_write_data, se_mem_write_mask, 
   // Inputs
   CLK, rst, ep0_to_se_vc0_d, ep0_to_se_vc0_full, ep1_to_se_vc0_full, 
   ep1_to_se_vc0_d, ep2_to_se_vc0_full, ep2_to_se_vc0_d, 
   ep3_to_se_vc0_full, ep3_to_se_vc0_d, nA_vc0_incoming_e, 
   nA_vc0_incoming_d, nB_vc0_incoming_e, nB_vc0_incoming_d, 
   nA_vc3_incoming_e, nA_vc3_incoming_d, nB_vc3_incoming_e, 
   nB_vc3_incoming_d, se_for_nA_vc1_gnt, se_for_nB_vc1_gnt, 
   se_for_ep0_vc3_gnt, se_for_ep1_vc3_gnt, se_for_ep2_vc3_gnt, 
   se_for_ep3_vc3_gnt, se_for_nA_vc3_gnt, se_for_nB_vc3_gnt, 
   se_mem_read_data, se_mem_gnt
   );

   input CLK;
   input rst;   
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
      

   //VC0 inputs from the EPs
   // //todo, eval the size of these boxes
   input [121:0] ep0_to_se_vc0_d;
   //input [3:0] 	 ep0_to_se_vc0_cmd;
   input 	ep0_to_se_vc0_full;
   output 	ep0_to_se_vc0_read;
   
   input 	ep1_to_se_vc0_full;
   input [121:0] ep1_to_se_vc0_d;
   //input [3:0] 	ep1_to_se_vc0_cmd;
   output 	ep1_to_se_vc0_read;
   
   input 	ep2_to_se_vc0_full;
   input [121:0] ep2_to_se_vc0_d;
   //   input [3:0] 	ep2_to_se_vc0_cmd;
   output 	 ep2_to_se_vc0_read;
   
   input 	ep3_to_se_vc0_full;
   input [121:0] ep3_to_se_vc0_d;
   //input [3:0] 	ep3_to_se_vc0_cmd;
   output 	ep3_to_se_vc0_read;

   //Sequential
   reg 		get_from_vc0_ep0;
   reg 		get_from_vc0_ep1;
   reg 		get_from_vc0_ep2;
   reg 		get_from_vc0_ep3;
   
   //Combinational
   reg 		ep_to_se_vc0_read;
   wire 	ep_to_se_vc0_full;
   wire [121:0] ep_to_se_vc0_d;
   //wire [3:0] 	ep_to_se_vc0_cmd;
   //todo: any of the ep to se communcication channels are broken...
   assign 	ep0_to_se_vc0_read = ep_to_se_vc0_read & get_from_vc0_ep0;
   assign 	ep1_to_se_vc0_read = ep_to_se_vc0_read & get_from_vc0_ep1;
   assign 	ep2_to_se_vc0_read = ep_to_se_vc0_read & get_from_vc0_ep2;
   assign 	ep3_to_se_vc0_read = ep_to_se_vc0_read & get_from_vc0_ep3;

   assign 	ep_to_se_vc0_full = (get_from_vc0_ep0 & ep0_to_se_vc0_full) |
				   (get_from_vc0_ep1 & ep1_to_se_vc0_full) |
				     (get_from_vc0_ep2 & ep2_to_se_vc0_full) |
		(get_from_vc0_ep3 & ep3_to_se_vc0_full);
   
   assign 	ep_to_se_vc0_d = get_from_vc0_ep0 ? ep0_to_se_vc0_d :
		get_from_vc0_ep1 ? ep1_to_se_vc0_d :
		get_from_vc0_ep2 ? ep2_to_se_vc0_d :
		get_from_vc0_ep3 ? ep3_to_se_vc0_d : 122'd0;
      
   //VC0 inputs from the global network
   input 	nA_vc0_incoming_e;
   input [32:0] nA_vc0_incoming_d;
   output 	nA_vc0_incoming_read;

   input 	nB_vc0_incoming_e;
   input [32:0] nB_vc0_incoming_d;
   output 	nB_vc0_incoming_read;

   //Sequential
   reg 		get_nA_vc0;
   reg 		get_nB_vc0;

   //Combinational
   reg 		n_vc0_incoming_read;
   wire 	n_vc0_incoming_e;
   wire [32:0] 	n_vc0_incoming_d;

   assign 	nA_vc0_incoming_read = get_nA_vc0 & n_vc0_incoming_read;
   assign 	nB_vc0_incoming_read = get_nB_vc0 & n_vc0_incoming_read;

   assign 	n_vc0_incoming_e = (get_nA_vc0 & nA_vc0_incoming_e) | 
				     (get_nB_vc0 & nB_vc0_incoming_e);
   assign 	n_vc0_incoming_d = ({33{get_nA_vc0}} & nA_vc0_incoming_d) |
				     ({33{get_nB_vc0}} & nB_vc0_incoming_d);
   
   //VC3 input from the network
   input 	nA_vc3_incoming_e;
   input [32:0] nA_vc3_incoming_d;
   output 	nA_vc3_incoming_read;
   
   input 	nB_vc3_incoming_e;
   input [32:0] nB_vc3_incoming_d;
   output 	nB_vc3_incoming_read;

   //Sequential
   reg 		get_nA_vc3;
   reg 		get_nB_vc3;

   //Combinational
   reg 		n_vc3_incoming_read;
   wire 	n_vc3_incoming_e;
   wire [32:0] 	n_vc3_incoming_d;

   assign 	nA_vc3_incoming_read = get_nA_vc3 & n_vc3_incoming_read;
   assign 	nB_vc3_incoming_read = get_nB_vc3 & n_vc3_incoming_read;

   assign 	n_vc3_incoming_e = (get_nA_vc3 & nA_vc3_incoming_e) | 
				     (get_nB_vc3 & nB_vc3_incoming_e);
   assign 	n_vc3_incoming_d = ({33{get_nA_vc3}} & nA_vc3_incoming_d) |
				     ({33{get_nB_vc3}} & nB_vc3_incoming_d);
   
   //VC1 outgoing to the network
   output 	se_for_nA_vc1_r;
   output 	se_for_nA_vc1_h;
   output [32:0] se_for_nA_vc1_d;
   input 	 se_for_nA_vc1_gnt;

   output 	 se_for_nB_vc1_r;
   output 	 se_for_nB_vc1_h;
   output [32:0] se_for_nB_vc1_d;
   input 	 se_for_nB_vc1_gnt;

   //Sequential
   reg 		 send_to_nA_vc1;
   reg 		 send_to_nB_vc1;
   
   //Combinational
   reg 		 send_to_n_vc1_r;
   reg 		 send_to_n_vc1_h;
   reg [32:0] 	 send_to_n_vc1_d;
   wire 	 send_to_n_vc1_gnt;

   assign 	 se_for_nA_vc1_r = send_to_nA_vc1 & send_to_n_vc1_r;
   assign 	 se_for_nB_vc1_r = send_to_nB_vc1 & send_to_n_vc1_r;

   assign 	 se_for_nA_vc1_h = send_to_nA_vc1 & send_to_n_vc1_h;
   assign 	 se_for_nB_vc1_h = send_to_nB_vc1 & send_to_n_vc1_h;
   
   assign 	 se_for_nA_vc1_d = send_to_nA_vc1 ? send_to_n_vc1_d : 33'd0;
   assign 	 se_for_nB_vc1_d = send_to_nB_vc1 ? send_to_n_vc1_d : 33'd0;
   
   assign 	 send_to_n_vc1_gnt = (send_to_nA_vc1 & se_for_nA_vc1_gnt) | 
				       (send_to_nB_vc1 & se_for_nB_vc1_gnt);
   
   //VC3 outgoing to the EPs
   //todo, figure this out...
   output [121:0] se_for_ep0_vc3_d;
   output 	  se_for_ep0_vc3_full;
   input 	  se_for_ep0_vc3_gnt;
   
   //output 	  se_for_ep1_vc3_r;
   output [121:0] se_for_ep1_vc3_d;
   output 	  se_for_ep1_vc3_full;
   input 	  se_for_ep1_vc3_gnt;
   
   //output 	  se_for_ep2_vc3_r;
   output [121:0] se_for_ep2_vc3_d;
   output 	  se_for_ep2_vc3_full;
   input 	  se_for_ep2_vc3_gnt;
   
   //output 	  se_for_ep3_vc3_r;
   output [121:0] se_for_ep3_vc3_d;
   output 	  se_for_ep3_vc3_full;
   input 	  se_for_ep3_vc3_gnt;
   
   //Sequential
   reg 		 send_to_ep0_vc3;
   reg 		 send_to_ep1_vc3;
   reg 		 send_to_ep2_vc3;
   reg 		 send_to_ep3_vc3;
   
   //Combinational
   //reg 		 send_to_ep_vc3_r;
   reg 		 send_to_ep_vc3_full;
   reg [121:0] 	 send_to_ep_vc3_d;
   wire 	 send_to_ep_vc3_gnt;
   
   assign 	 se_for_ep0_vc3_d = send_to_ep0_vc3 ? send_to_ep_vc3_d : 122'd0;
   assign 	 se_for_ep1_vc3_d = send_to_ep1_vc3 ? send_to_ep_vc3_d : 122'd0;
   assign 	 se_for_ep2_vc3_d = send_to_ep2_vc3 ? send_to_ep_vc3_d : 122'd0;
   assign 	 se_for_ep3_vc3_d = send_to_ep3_vc3 ? send_to_ep_vc3_d : 122'd0;

   assign 	 se_for_ep0_vc3_full = send_to_ep0_vc3 & send_to_ep_vc3_full;
   assign 	 se_for_ep1_vc3_full = send_to_ep1_vc3 & send_to_ep_vc3_full;
   assign 	 se_for_ep2_vc3_full = send_to_ep2_vc3 & send_to_ep_vc3_full;
   assign 	 se_for_ep3_vc3_full = send_to_ep3_vc3 & send_to_ep_vc3_full;
   
   assign 	 send_to_ep_vc3_gnt = 
		 (send_to_ep0_vc3 & se_for_ep0_vc3_gnt) |
		   (send_to_ep1_vc3 & se_for_ep1_vc3_gnt) |
		 (send_to_ep2_vc3 & se_for_ep2_vc3_gnt) |
		 (send_to_ep3_vc3 & se_for_ep3_vc3_gnt);

   //VC3 outgoing to the network
   output 	 se_for_nA_vc3_r;
   output 	 se_for_nA_vc3_h;
   output [32:0] se_for_nA_vc3_d;
   input 	 se_for_nA_vc3_gnt;

   output 	 se_for_nB_vc3_r;
   output 	 se_for_nB_vc3_h;
   output [32:0] se_for_nB_vc3_d;
   input 	 se_for_nB_vc3_gnt;

   //Sequential
   reg 		 send_to_nA_vc3;
   reg 		 send_to_nB_vc3;
   
   //Combinational
   reg 		 send_to_n_vc3_r;
   reg 		 send_to_n_vc3_h;
   reg [32:0] 	 send_to_n_vc3_d;
   wire 	 send_to_n_vc3_gnt;

   assign 	 se_for_nA_vc3_r = send_to_nA_vc3 & send_to_n_vc3_r;
   assign 	 se_for_nB_vc3_r = send_to_nB_vc3 & send_to_n_vc3_r;

   assign 	 se_for_nA_vc3_h = send_to_nA_vc3 & send_to_n_vc3_h;
   assign 	 se_for_nB_vc3_h = send_to_nB_vc3 & send_to_n_vc3_h;
   
   assign 	 se_for_nA_vc3_d = {33{send_to_nA_vc3}} & send_to_n_vc3_d;
   assign 	 se_for_nB_vc3_d = {33{send_to_nB_vc3}} & send_to_n_vc3_d;
   
   assign 	 send_to_n_vc3_gnt = (send_to_nA_vc3 & se_for_nA_vc3_gnt) | 
				       (send_to_nB_vc3 & se_for_nB_vc3_gnt);
   //Going to and from Memory
   output 	 se_mem_req;
   output 	 se_mem_wen_b;
   //output 	 se_mem_lock;  not used, since not CPNSWP commands
   output [15:0] se_mem_addr;
   output [63:0] se_mem_write_data;
   output [1:0] se_mem_write_mask;
   input [63:0]  se_mem_read_data;
   input 	 se_mem_gnt;

   reg 		 se_mem_req;
   reg 		 se_mem_wen_b;
   //reg 	 se_mem_lock;  not used, since not CPNSWP commands
   reg [15:0] 	 se_mem_addr;
   reg [63:0] 	 se_mem_write_data;
   reg [1:0] 	 se_mem_write_mask;
      
   /* A summary of the declared variables...shoot me now
    *
    * Sequential:
    * get_from_vc0_ep0
    * get_from_vc0_ep1
    * get_from_vc0_ep2
    * get_from_vc0_ep3
    * get_nA_vc0
    * get_nB_vc0
    * get_nA_vc3
    * get_nB_vc3
    * send_to_nA_vc1
    * send_to_nB_vc1
    * send_to_ep0_vc3
    * send_to_ep1_vc3
    * send_to_ep2_vc3
    * send_to_ep3_vc3
    * send_to_nA_vc3
    * send_to_nB_vc3
    * 
    * Combinational:
    * ep_to_se_vc0_read
    * n_vc0_incoming_read
    * n_vc3_incoming_read
    * send_to_n_vc1_r
    * send_to_n_vc1_h
    * send_to_n_vc1_d
    * send_to_ep_vc3_r
    * send_to_ep_vc3_h
    * send_to_ep_vc3_d
    * send_to_n_vc3_r
    * send_to_n_vc3_h
    * send_to_n_vc3_d
    * se_mem_req
    * se_mem_wen_b
    * se_mem_addr
    * se_mem_write_data
    * se_mem_write_mask
    *  
    * Incoming:
    * ep_to_se_vc0_e
    * ep_to_se_vc0_d
    * n_vc0_incoming_e
    * n_vc0_incoming_d
    * n_vc3_incoming_e
    * n_vc3_incoming_d
    * send_to_n_vc1_gnt
    * send_to_ep_vc3_gnt
    * send_to_n_vc3_gnt
    * 
    */
   
   parameter 	 st_idle = 7'd0;
   parameter 	 st_serv_ep_vc0 = 7'd1;
   parameter 	 st_epvc0_ldsdL_read_A = 7'd2;
   parameter     st_epvc0_ldsdL_read_B = 7'd3;
   parameter 	 st_epvc0_ldsdL_read_C = 7'd4;
   parameter     st_epvc0_ldsdL_ack = 7'd5;
   
   parameter 	 st_epvc0_ldsdG_req = 7'd6;
   parameter     st_epvc0_ldsdG_r_addr = 7'd43;
   parameter 	 st_epvc0_ldsdG_wait = 7'd7;
   parameter 	 st_epvc0_ldsdG_read_A = 7'd8;
   parameter 	 st_epvc0_ldsdG_read_B = 7'd9;
   parameter 	 st_epvc0_ldsdG_read_C = 7'd10;
   parameter 	 st_epvc0_ldsdG_read_D = 7'd11;
   parameter 	 st_epvc0_ldsdG_ack = 7'd12;

   parameter 	 st_serv_n_vc0 = 7'd13;
   parameter 	 st_nvc0_get_addr = 7'd14;
   parameter 	 st_nvc0_ldsdL_read_A = 7'd15;
   parameter 	 st_nvc0_ldsdL_read_B = 7'd16;
   parameter 	 st_nvc0_ldsdL_read_C = 7'd17;
   parameter 	 st_nvc0_ldsdL_ack = 7'd18;

   parameter 	 st_nvc0_ldsdG_req = 7'd19;
   parameter 	 st_nvc0_ldsdG_r_addr = 7'd44;
   parameter 	 st_nvc0_ldsdG_wait = 7'd20;
   parameter 	 st_nvc0_ldsdG_read_A = 7'd21;
   parameter 	 st_nvc0_ldsdG_read_B = 7'd22;
   parameter 	 st_nvc0_ldsdG_read_C = 7'd23;
   parameter 	 st_nvc0_ldsdG_read_D = 7'd24;
   parameter 	 st_nvc0_ldsdG_ack = 7'd25;

   parameter 	 st_nvc0_ldsdI_read_A = 7'd26;
   parameter 	 st_nvc0_ldsdI_read_B = 7'd27;
   parameter 	 st_nvc0_ldsdI_read_C = 7'd28;
   parameter 	 st_nvc0_ldsdI_read_D = 7'd29;
   parameter 	 st_nvc0_ldsdI_ack = 7'd30;

   parameter 	 st_stsdL_write_A = 7'd31;
   parameter 	 st_stsdL_write_B = 7'd32;
   parameter 	 st_stsdL_write_C = 7'd33;
   parameter 	 st_stsdL_ack = 7'd34;
   
   parameter 	 st_stsdG_send_r= 7'd35;
   parameter 	 st_stsdG_send_addr = 7'd36;
   parameter 	 st_stsdG_send_A = 7'd37;
   parameter 	 st_stsdG_send_B = 7'd38;
   parameter 	 st_stsdG_send_C = 7'd39;
   parameter 	 st_stsdG_send_D = 7'd40;
   parameter 	 st_stsdG_wait = 7'd41;
   parameter 	 st_stsdG_ack = 7'd42;
   
   parameter 	 st_str_gath_addr = 7'd45;
   parameter 	 st_str_scat_addr = 7'd46;
   parameter 	 st_str_ide_dist = 7'd47;
   parameter 	 st_str_ide_done = 7'd48;

   parameter 	 st_str_idxL_read_mem = 7'd49;
   parameter 	 st_str_idxL_save_idx = 7'd50;
   parameter 	 st_str_idxG_send_read = 7'd51;
   parameter 	 st_str_idxG_send_iaddr = 7'd52;
   parameter 	 st_str_idxG_wait_idx = 7'd53;
   parameter 	 st_str_idxG_wait_idx_addr = 7'd53;
   parameter 	 st_str_idx_dist = 7'd54;
   parameter 	 st_str_idx_done = 7'd55;
   
   parameter 	 st_str_GG_gocpy = 7'd56;
   parameter 	 st_str_GG_goscat_addr = 7'd57;
   parameter 	 st_str_GG_gogath_addr = 7'd58;
   parameter 	 st_str_GG_cpywait = 7'd59;

   parameter 	 st_str_LG_wr_header = 7'd60;
   parameter 	 st_str_LG_wr_addr = 7'd61;
   parameter 	 st_str_LG_readSram = 7'd62;
   parameter 	 st_str_LG_send_A = 7'd63;
   parameter 	 st_str_LG_send_B = 7'd64;
   parameter 	 st_str_LG_wait = 7'd65;
   
   parameter 	 st_str_GL_rd_header = 7'd66;
   parameter 	 st_str_GL_rd_addr = 7'd67;
   parameter 	 st_str_GL_wait = 7'd68;
   parameter 	 st_str_GL_data_A = 7'd69;
   parameter 	 st_str_GL_data_B = 7'd70;
   parameter 	 st_str_GL_write_SRAM = 7'd71;
   //parameter     st_str_GL_wrrd_SRAM = 7'd76; //
   
   parameter 	 st_str_LL_rdSRAM_A = 7'd72;
   parameter 	 st_str_LL_rdSRAM_B = 7'd73;
   //parameter 	 st_str_LL_wrrdSRAM = 7'd74; //
   parameter 	 st_str_LL_wrSRAM = 7'd75;
   		 
   //parameter 	 st_write32_read = 7'd97;  //
   //parameter 	 st_write32_write = 7'd98; //
   
   
   //reg [15:0] 	 wr32_addr;
   reg 		 that_just_happened;
   
   //The stream descriptor
   reg [127:0] 	 sd;

   //The address for loading/storing sd's
   reg [31:0] 	 ldsd_daddr;

   //When streaming, stuff that updates
   reg [31:0] 	 stream_cur_element; //+1
   reg [31:0] 	 cur_gath_addr; // + record size
   reg [31:0] 	 cur_to_transfer; // -1
   reg [31:0] 	 cur_iaddr; //The address of the list o' indices
   
   reg [31:0] 	 cur_offset; //Just gets set, then not updated


   reg [31:0] 	 cmd_servicing;
   wire 	 read_stream = (cmd_servicing[19:16] == `OCM_CMD_VC0_RDSTRM);   
  

   reg [41:0] 	 scratchpad;
   reg [63:0] 	 sram_data;
      
   //Data that is computed
   reg [31:0] 	 cur_scat_addr; //reg, no offset
   reg [31:0] 	 cur_scat_addr_plus_offset;
      
   wire [31:0] 	 record_size = sd[127:96];
   wire [31:0] 	 stream_len = sd[95:64];
   wire [31:0]	 stride_len = sd[63:32];
   wire [31:0]	 index_addr = sd[31:0];
   wire 	 strided_mode = (index_addr == 32'd0);
   
   wire 	 maxed_out_sd = (stream_cur_element == (stream_len - 1));
   wire 	 maxed_out_cmd = (cur_to_transfer == 32'd0);

   
   reg [31:0] 	 cur_word_cnt;
   reg [31:0] 	 cur_from_address;
   reg [31:0] 	 cur_to_address;
   //reg [127:0] 	 scratchpad;
   
   wire [31:0] 	 cur_word_cnt_p1 = cur_word_cnt + 1;
   wire [31:0] 	 cur_word_cnt_p2 = cur_word_cnt + 2;
   wire [31:0] 	 cur_from_address_p1 = cur_from_address + 1;
   wire [31:0] 	 cur_from_address_p2 = cur_from_address + 2;
   wire [31:0] 	 cur_to_address_p1 = cur_to_address + 1;
   wire [31:0] 	 cur_to_address_p2 = cur_to_address + 2;
   
   
   reg [6:0] 	 state;
   reg [6:0] 	 st_nxt;
   //reg [6:0] 	 st_save_nxt;
      
   always@(posedge CLK or posedge rst)
     if(rst)
       state <= st_idle;
     else
       state <= st_nxt;
   
   always@(*)
     begin
	st_nxt = st_idle; //todo, figure out where the bad case statement is...
	case(state)
          st_idle: begin
	     if(ep0_to_se_vc0_full | ep1_to_se_vc0_full | 
		ep2_to_se_vc0_full | ep3_to_se_vc0_full)
               st_nxt = st_serv_ep_vc0;
	     else if(~nA_vc0_incoming_e | ~nB_vc0_incoming_e)
	       st_nxt = st_serv_n_vc0;
	     else
	       st_nxt = st_idle;
	  end
	  st_serv_ep_vc0: begin
	     if(ep_to_se_vc0_d[121:118] == `OCM_CMD_VC0_LDSD)
	       begin
		  if(does_this_addr_goto_me(ep_to_se_vc0_d[31:0]))
		    st_nxt = st_epvc0_ldsdL_read_A;
		  else
		    st_nxt = st_epvc0_ldsdG_req;
	       end
	     else if(ep_to_se_vc0_d[121:118] == `OCM_CMD_VC0_STSD)
	       begin
		  if(does_this_addr_goto_me(ep_to_se_vc0_d[31:0]))
		    st_nxt = st_stsdL_write_A;
		  else
		    st_nxt = st_stsdG_send_r;
	       end
	     else if(ep_to_se_vc0_d[121:118] == `OCM_CMD_VC0_RDSTRM |
		     ep_to_se_vc0_d[121:118] == `OCM_CMD_VC0_WRSTRM)
	       begin
		  if(strided_mode)
		    st_nxt = st_str_ide_dist;
		  else
		    if(does_this_addr_goto_me(cur_iaddr))
		      st_nxt = st_str_idxL_read_mem;
		    else
		      st_nxt = st_str_idxG_send_read;
	       end // if (ep_to_se_vc0_cmd == `RDSTRM |...
	     else
	       st_nxt = st_idle;
	  end // case: st_serv_ep_vc0
	  st_epvc0_ldsdL_read_A: begin
	     if(se_mem_gnt)
	       st_nxt = st_epvc0_ldsdL_read_B;
	     else
	       st_nxt = st_epvc0_ldsdL_read_A;
	  end
	  st_epvc0_ldsdL_read_B: begin
	     if(se_mem_gnt)
	       if(ldsd_daddr[0])
		 st_nxt = st_epvc0_ldsdL_read_C;
	       else
		 st_nxt = st_epvc0_ldsdL_ack;
	     else
	       st_nxt = st_epvc0_ldsdL_read_B;
	  end
	  st_epvc0_ldsdL_read_C: begin
	     if(se_mem_gnt)
	       st_nxt = st_epvc0_ldsdL_ack;
	     else
	       st_nxt = st_epvc0_ldsdL_read_C;
	  end
	  st_epvc0_ldsdL_ack: begin
	     if(send_to_ep_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_epvc0_ldsdL_ack;
	  end
	  st_epvc0_ldsdG_req: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_epvc0_ldsdG_r_addr;
	     else
	       st_nxt = st_epvc0_ldsdG_req;
	  end
	  st_epvc0_ldsdG_r_addr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_epvc0_ldsdG_wait;
	     else
	       st_nxt = st_epvc0_ldsdG_r_addr;
	  end
	  st_epvc0_ldsdG_wait: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_epvc0_ldsdG_read_A;
	     else
	       st_nxt = st_epvc0_ldsdG_wait;
	  end
	  st_epvc0_ldsdG_read_A: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_epvc0_ldsdG_read_B;
	     else
	       st_nxt = st_epvc0_ldsdG_read_A;
	  end
	  st_epvc0_ldsdG_read_B: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_epvc0_ldsdG_read_C;
	     else
	       st_nxt = st_epvc0_ldsdG_read_B;
	  end
	  st_epvc0_ldsdG_read_C: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_epvc0_ldsdG_read_D;
	     else
	       st_nxt = st_epvc0_ldsdG_read_C;
	  end
	  st_epvc0_ldsdG_read_D: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_epvc0_ldsdG_ack;
	     else
	       st_nxt = st_epvc0_ldsdG_read_D;
	  end
	  st_epvc0_ldsdG_ack: begin
	     if(send_to_ep_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_epvc0_ldsdG_ack;
	  end
	  st_serv_n_vc0: begin
	     if(n_vc0_incoming_d[19:16] == `OCM_CMD_VC0_LDSDI)
	       st_nxt = st_nvc0_ldsdI_read_A;
	     else if(n_vc0_incoming_d[19:16] == `OCM_CMD_VC0_RDSTRM | 
		     n_vc0_incoming_d[19:16] == `OCM_CMD_VC0_WRSTRM)
	       st_nxt = st_str_gath_addr;
	     else
	       st_nxt = st_nvc0_get_addr;
	  end
	  st_nvc0_get_addr: begin
	     if(~n_vc0_incoming_e) begin
	       if(cmd_servicing[19:16] == `OCM_CMD_VC0_LDSD)
		 begin
		    if(does_this_addr_goto_me(n_vc0_incoming_d))
		      st_nxt = st_nvc0_ldsdL_read_A;
		    else
		      st_nxt = st_nvc0_ldsdG_req;
		 end
	       else if(cmd_servicing[19:16] == `OCM_CMD_VC0_STSD)
		 begin
		    if(does_this_addr_goto_me(n_vc0_incoming_d))
		      //if(n_vc0_incoming_d[0])
		      //st_nxt = st_write32_read;
		      //else
		      st_nxt = st_stsdL_write_A;
		    else
		      st_nxt = st_stsdG_send_r;
		 end
	     end // if (~n_vc0_incoming_e)
	     else
	       st_nxt = st_nvc0_get_addr;
	  end // case: st_nvc0_get_addr
	  st_nvc0_ldsdL_read_A: begin
	     if(se_mem_gnt)
	       st_nxt = st_nvc0_ldsdL_read_B;
	     else
	       st_nxt = st_nvc0_ldsdL_read_A;
	  end
	  st_nvc0_ldsdL_read_B: begin
	     if(se_mem_gnt)
	       if(ldsd_daddr[0])
		 st_nxt = st_nvc0_ldsdL_read_C;
	       else
		 st_nxt = st_nvc0_ldsdL_ack;
	     else
	       st_nxt = st_nvc0_ldsdL_read_B;
	  end
	  st_nvc0_ldsdL_read_C: begin
	     if(se_mem_gnt)
	       st_nxt = st_nvc0_ldsdL_ack;
	     else
	       st_nxt = st_nvc0_ldsdL_read_C;
	  end
	  st_nvc0_ldsdL_ack: begin
	     if(send_to_n_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_nvc0_ldsdL_ack;
	  end
	  st_nvc0_ldsdG_req: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_nvc0_ldsdG_r_addr;
	     else
	       st_nxt = st_nvc0_ldsdG_req;
	  end
	  st_nvc0_ldsdG_r_addr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_nvc0_ldsdG_wait;
	     else
	       st_nxt = st_nvc0_ldsdG_r_addr;
	  end
	  st_nvc0_ldsdG_wait: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_epvc0_ldsdG_read_A;
	     else
	       st_nxt = st_epvc0_ldsdG_wait;
	  end
	  st_nvc0_ldsdG_read_A: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_nvc0_ldsdG_read_B;
	     else
	       st_nxt = st_nvc0_ldsdG_read_A;
	  end
	  st_nvc0_ldsdG_read_B: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_nvc0_ldsdG_read_C;
	     else
	       st_nxt = st_nvc0_ldsdG_read_B;
	  end
	  st_nvc0_ldsdG_read_C: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_nvc0_ldsdG_read_D;
	     else
	       st_nxt = st_nvc0_ldsdG_read_C;
	  end
	  st_nvc0_ldsdG_read_D: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_nvc0_ldsdG_ack;
	     else
	       st_nxt = st_nvc0_ldsdG_read_D;
	  end
	  st_nvc0_ldsdG_ack: begin
	     if(send_to_n_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_nvc0_ldsdG_ack;
	  end
	  st_nvc0_ldsdI_read_A: begin
	     if(~n_vc0_incoming_e)
	       st_nxt = st_nvc0_ldsdI_read_B;
	     else
	       st_nxt = st_nvc0_ldsdI_read_A;
	  end
	  st_nvc0_ldsdI_read_B: begin
	     if(~n_vc0_incoming_e)
	       st_nxt = st_nvc0_ldsdI_read_C;
	     else
	       st_nxt = st_nvc0_ldsdI_read_B;
	  end
	  st_nvc0_ldsdI_read_C: begin
	     if(~n_vc0_incoming_e)
	       st_nxt = st_nvc0_ldsdI_read_D;
	     else
	       st_nxt = st_nvc0_ldsdI_read_C;
	  end
	  st_nvc0_ldsdI_read_D: begin
	     if(~n_vc0_incoming_e)
	       st_nxt = st_nvc0_ldsdI_ack;
	     else
	       st_nxt = st_nvc0_ldsdI_read_D;
	  end
	  st_nvc0_ldsdI_ack: begin
	     if(send_to_n_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_nvc0_ldsdI_ack;
	  end
	  /*st_write32_read: begin
	   if(se_mem_gnt)
	   st_nxt = st_write32_write;
	   else
	   st_nxt = st_write32_read;
 	   end
	   st_write32_write: begin
	   if(se_mem_gnt)
	   st_nxt = st_save_nxt;
	   else
	   st_nxt = st_write32_write;
	  end
	   */
	  st_stsdL_write_A: begin
	     if(se_mem_gnt)
	       st_nxt = st_stsdL_write_B;
	     else
	       st_nxt = st_stsdL_write_A;
	  end
	  st_stsdL_write_B: begin
	     if(se_mem_gnt)
	       if(ldsd_daddr[0])
		 st_nxt = st_stsdL_write_C;
	       else
		 st_nxt = st_stsdL_ack;
	     else
	       st_nxt = st_stsdL_write_B;
	  end
	  st_stsdL_write_C: begin
	     if(se_mem_gnt)
	       st_nxt = st_stsdL_ack;
	     else
	       st_nxt = st_stsdL_write_C;
	  end
	  st_stsdL_ack: begin
	     if(send_to_n_vc3_gnt | send_to_ep_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_stsdL_ack;
	  end
	  st_stsdG_send_r: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_stsdG_send_addr;
	     else
	       st_nxt = st_stsdG_send_r;
	  end
	  st_stsdG_send_addr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_stsdG_send_A;
	     else
	       st_nxt = st_stsdG_send_addr;
	  end
	  st_stsdG_send_A: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_stsdG_send_B;
	     else
	       st_nxt = st_stsdG_send_A;
	  end
	  st_stsdG_send_B: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_stsdG_send_C;
	     else
	       st_nxt = st_stsdG_send_B;
		  end
	  st_stsdG_send_C: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_stsdG_send_D;
	     else
	       st_nxt = st_stsdG_send_C;
	  end
	  st_stsdG_send_D: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_stsdG_wait;
	     else
	       st_nxt = st_stsdG_send_D;
	  end
	  st_stsdG_wait: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_stsdG_ack;
	     else
	       st_nxt = st_stsdG_wait;
	  end
	  st_stsdG_ack: begin
	     if(send_to_n_vc3_gnt | send_to_ep_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_stsdG_ack;
	  end
	  st_str_gath_addr: begin
	     if(~n_vc0_incoming_e)
	       st_nxt = st_str_scat_addr;
	     else
	       st_nxt = st_str_gath_addr;
	  end
	  st_str_scat_addr: begin
	     if(~n_vc0_incoming_e)
	       if(strided_mode)
		 st_nxt = st_str_ide_dist;
	       else
		 if(does_this_addr_goto_me(cur_iaddr))
		   st_nxt = st_str_idxL_read_mem;
		 else
		   st_nxt = st_str_idxG_send_read;
	     else
	       st_nxt = st_str_scat_addr;
	  end
	  st_str_ide_dist: begin
	     case({read_stream,
		   does_this_addr_goto_me(cur_scat_addr_plus_offset),
		   does_this_addr_goto_me(cur_gath_addr)})
	       3'b000: st_nxt = st_str_GG_gocpy;
	       3'b001: st_nxt = st_str_LG_wr_header;
	       3'b010: st_nxt = st_str_GL_rd_header;
	       3'b011: st_nxt = st_str_LL_rdSRAM_A;
	       
	       3'b100: st_nxt = st_str_GG_gocpy;
	       3'b101: st_nxt = st_str_GL_rd_header;
	       3'b110: st_nxt = st_str_LG_wr_header;
	       3'b111: st_nxt = st_str_LL_rdSRAM_A;
	       default: st_nxt = st_idle;
	     endcase // case({read_stream,...
	  end // case: st_str_ide_dist
	  st_str_ide_done: begin
	     if(send_to_n_vc3_gnt | send_to_ep_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_str_ide_done;
	  end
	  st_str_idxL_read_mem: begin
	     if(se_mem_gnt)
	       st_nxt = st_str_idxL_save_idx;
	     else
	       st_nxt = st_str_idxL_read_mem;
	  end
	  st_str_idxL_save_idx: begin
	     st_nxt = st_str_idx_dist;
	  end
	  st_str_idxG_send_read: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_idxG_send_iaddr;
	     else
	       st_nxt = st_str_idxG_send_read;
	  end
	  st_str_idxG_send_iaddr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_idxG_wait_idx;
	     else
	       st_nxt = st_str_idxG_send_iaddr;
	  end	  
	  st_str_idxG_wait_idx: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_str_idxG_wait_idx_addr;
	     else
	       st_nxt = st_str_idxG_wait_idx;
	  end
	  //st_str_idxG_wait_idx_addr: begin
	  //   if(~n_vc3_incoming_e)
	  //     st_nxt = st_str_idx_dist;
	  //   else
	 //      st_nxt = st_str_idxG_wait_idx_addr;
	 // end
	  st_str_idx_dist: begin
	     case({read_stream,
		   does_this_addr_goto_me(cur_scat_addr_plus_offset),
		   does_this_addr_goto_me(cur_gath_addr)})
	       3'b000: st_nxt = st_str_GG_gocpy;
	       3'b001: st_nxt = st_str_GL_rd_header;
	       3'b010: st_nxt = st_str_LG_wr_header;
	       3'b011: st_nxt = st_str_LL_rdSRAM_A;
	       3'b100: st_nxt = st_str_GG_gocpy;
	       3'b101: st_nxt = st_str_LG_wr_header;
	       3'b110: st_nxt = st_str_GL_rd_header;
	       3'b111: st_nxt = st_str_LL_rdSRAM_A;
	       default: st_nxt = st_idle;
	     endcase
	  end // case: st_str_idx_dist
	  st_str_idx_done: begin
	     if(send_to_n_vc3_gnt | send_to_ep_vc3_gnt)
	       st_nxt = st_idle;
	     else
	       st_nxt = st_str_ide_done;
	  end
	  st_str_GG_gocpy: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_GG_goscat_addr;
	     else
	       st_nxt = st_str_GG_gocpy;
	  end
	  st_str_GG_goscat_addr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_GG_gogath_addr;
	     else
	       st_nxt = st_str_GG_goscat_addr;
	  end
	  st_str_GG_gogath_addr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_GG_cpywait;
	     else
	       st_nxt = st_str_GG_gogath_addr;
	  end
	  st_str_GG_cpywait: begin
	     if(~n_vc3_incoming_e) begin
		case({maxed_out_cmd, strided_mode})
		  2'b00: begin
		     if(does_this_addr_goto_me(cur_iaddr))
		       st_nxt = st_str_idxL_read_mem;
		     else
		       st_nxt = st_str_idxG_send_read;
		  end
		  2'b01: st_nxt = st_str_ide_dist;
		  2'b10: st_nxt = st_str_ide_done;
		  2'b11: st_nxt = st_str_idx_done;
		endcase // case({maxed_out_cmd, strided_mode})
	     end
	     else
	       st_nxt = st_str_GG_cpywait;
	  end
	  st_str_LG_wr_header: begin
	     if(send_to_n_vc1_gnt)
	       
	       st_nxt = st_str_LG_wr_addr;
	     else
	       st_nxt = st_str_LG_wr_header;
	  end
	  st_str_LG_wr_addr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_LG_readSram;
	     else
	       st_nxt = st_str_LG_wr_addr;
	  end
	  st_str_LG_readSram: begin
	     if(se_mem_gnt)
	       if(~cur_from_address[0])
		 st_nxt = st_str_LG_send_A;
	       else
		 st_nxt = st_str_LG_send_B;
	     else
	       st_nxt = st_str_LG_readSram;
	  end
	  st_str_LG_send_A: begin
	     if(send_to_n_vc1_gnt)
	       if(cur_word_cnt_p1 == record_size)
		 st_nxt = st_str_LG_wait;
	       else
		 st_nxt = st_str_LG_send_B;
	     else
	       st_nxt = st_str_LG_send_A;
	  end
	  st_str_LG_send_B: begin
	     if(send_to_n_vc1_gnt)
	       if(cur_word_cnt_p1 == record_size)
		 st_nxt = st_str_LG_wait;
	       else
		 st_nxt = st_str_LG_readSram;
	     else
	       st_nxt = st_str_LG_send_B;
	  end
	  st_str_LG_wait: begin
	     if(~n_vc3_incoming_e) begin
		case({maxed_out_cmd, strided_mode})
		  2'b00: begin
		     if(does_this_addr_goto_me(cur_iaddr))
		       st_nxt = st_str_idxL_read_mem;
		     else
		       st_nxt = st_str_idxG_send_read;
		  end
		  2'b01: st_nxt = st_str_ide_dist;
		  2'b10: st_nxt = st_str_ide_done;
		  2'b11: st_nxt = st_str_idx_done;
		endcase // case({maxed_out_cmd, strided_mode})
	     end // if (~n_vc3_incoming_e)
	     else
	       st_nxt = st_str_LG_wait;
	  end // case: st_str_LG_wait
	  st_str_GL_rd_header: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_GL_rd_addr;
	     else
	       st_nxt = st_str_GL_rd_header;
	  end
	  st_str_GL_rd_addr: begin
	     if(send_to_n_vc1_gnt)
	       st_nxt = st_str_GL_wait;
	     else
	       st_nxt = st_str_GL_rd_addr;
	  end
	  st_str_GL_wait: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_str_GL_data_A;
	     else
	       st_nxt = st_str_GL_wait;
	  end
	  st_str_GL_data_A: begin
	     if(~n_vc3_incoming_e) begin
		if(cur_word_cnt_p1 == record_size | cur_to_address[0])
		  st_nxt = st_str_GL_write_SRAM;
		else
		  st_nxt = st_str_GL_data_B;
	     end
	     else
	       st_nxt = st_str_GL_data_A;
	  end
	  st_str_GL_data_B: begin
	     if(~n_vc3_incoming_e)
	       st_nxt = st_str_GL_write_SRAM;
	     else
	       st_nxt = st_str_GL_data_B;
	  end
	  st_str_GL_write_SRAM: begin
	     if(se_mem_gnt) begin
		if(cur_word_cnt_p1 == record_size |
		   cur_word_cnt_p2 == record_size )
		  case({maxed_out_cmd, strided_mode})
		    2'b00: begin
		       if(does_this_addr_goto_me(cur_iaddr))
			 st_nxt = st_str_idxL_read_mem;
		       else
			 st_nxt = st_str_idxG_send_read;
		    end
		    2'b01: st_nxt = st_str_ide_dist;
		    2'b10: st_nxt = st_str_ide_done;
		    2'b11: st_nxt = st_str_idx_done;
		  endcase // case({maxed_out_cmd, strided_mode})
		else
		  st_nxt = st_str_GL_data_A;
	     end
	     else
	       st_nxt = st_str_GL_write_SRAM;
	  end // case: st_str_GL_write_SRAM
	  /*st_str_GL_wrrd_SRAM: begin
	   if(se_mem_gnt)
	   st_nxt = st_str_GL_write_SRAM;
	   else
	   st_nxt = st_str_GL_wrrd_SRAM;
	  end*/
	  st_str_LL_rdSRAM_A: begin
	     if(se_mem_gnt) begin
		if(~(cur_word_cnt_p1 == record_size)) begin
		   case({cur_from_address[0], cur_to_address[0]})
		     2'b00: st_nxt = st_str_LL_wrSRAM;
		     2'b01: st_nxt = st_str_LL_wrSRAM; //only should happen once!
		     2'b10:
		       if(~scratchpad[33])
			 st_nxt = st_str_LL_rdSRAM_B;
		       else 
			 st_nxt = st_str_LL_wrSRAM;
		     2'b11: st_nxt = st_str_LL_wrSRAM;
		 endcase // case({cur_address[0], cur_daddr[0]})
		end // if (~(cur_word_cnt_p1 == record_size))
		else //one word to go...
		 case({cur_from_address[0], cur_to_address[0]})
		   2'b00: st_nxt = st_str_LL_wrSRAM;
		   2'b01: st_nxt = st_str_LL_wrSRAM;
		   2'b10: st_nxt = st_str_LL_wrSRAM; //Just need to make sure we write
		   2'b11: st_nxt = st_str_LL_wrSRAM; //the correct word
		 endcase // case({cur_address[0], cur_daddr[0]})
	     end // if (se_mem_gnt)
	     else
	       st_nxt = st_str_LL_rdSRAM_A;
	  end
	  st_str_LL_rdSRAM_B: begin
	     if(se_mem_gnt)
	       st_nxt = st_str_LL_wrSRAM;
	     else
	       st_nxt = st_str_LL_rdSRAM_B;
	  end
	  /*st_str_LL_wrrdSRAM: begin
	     if(se_mem_gnt)
	       st_nxt = st_str_LL_wrSRAM;
	     else
	       st_nxt = st_str_LL_wrrdSRAM;
	  end*/
	  st_str_LL_wrSRAM: begin
	     if(se_mem_gnt)
	       if((cur_word_cnt_p2 == record_size & 
		   ~(cur_to_address[0] & cur_from_address[0]))
		  |  (cur_word_cnt_p1 == record_size))
		 case({maxed_out_cmd, strided_mode})
		   2'b00: begin
		      if(does_this_addr_goto_me(cur_iaddr))
			st_nxt = st_str_idxL_read_mem;
		      else
			st_nxt = st_str_idxG_send_read;
		   end
		   2'b01: st_nxt = st_str_ide_dist;
		   2'b10: st_nxt = st_str_ide_done;
		   2'b11: st_nxt = st_str_idx_done;
		 endcase // case({maxed_out_cmd, strided_mode})
	       else
		 st_nxt = st_str_LL_rdSRAM_A;
	     else
	       st_nxt = st_str_LL_wrSRAM;
	  end // case: st_str_LL_wrSRAM
	  default: begin
             st_nxt = st_idle;
          end
	endcase // case(state)
     end // always@ (*)
   
   always@(posedge CLK or posedge rst) 
     begin
	if(rst) begin
           get_from_vc0_ep0 <= 1'b0;
           get_from_vc0_ep1 <= 1'b0;
           get_from_vc0_ep2 <= 1'b0;
           get_from_vc0_ep3 <= 1'b0;
           get_nA_vc0 <= 1'b0;
           get_nB_vc0 <= 1'b0;
           get_nA_vc3 <= 1'b0;
	   get_nB_vc3 <= 1'b0;
           send_to_nA_vc1 <= 1'b0;
           send_to_nB_vc1 <= 1'b0;
           send_to_ep0_vc3 <= 1'b0;
	   send_to_ep1_vc3 <= 1'b0;
           send_to_ep2_vc3 <= 1'b0;
           send_to_ep3_vc3 <= 1'b0;
	   send_to_nA_vc3 <= 1'b0;
           send_to_nB_vc3 <= 1'b0;
	   sd <= 128'd0;
	   ldsd_daddr <= 32'd0;
	   stream_cur_element <= 32'd0;
	   cur_gath_addr <= 32'd0;
	   cur_to_transfer <= 32'd0;
	   cur_iaddr <= 32'd0;
	   cur_offset <= 32'd0;
	   cur_from_address <= 32'd0;
	   cur_to_address <= 32'd0;
	   //read_stream <= 1'b0;
	   scratchpad <= 42'd0;
	   sram_data <= 64'd0;
	   cur_scat_addr <= 32'd0;
	   cur_scat_addr_plus_offset <= 32'd0;
	   //wr32_addr <= 16'd0;
	   that_just_happened <= 1'b0;//
	   //st_save_nxt <= 7'd0;
	   cmd_servicing <= 32'd0;
	end // if (rst)
	else begin
           case(state)
             st_idle: begin
		if(st_nxt != st_idle) begin
		   if(st_nxt == st_serv_ep_vc0) begin
		      //todo: fix priorities
		      get_from_vc0_ep0 <= ep0_to_se_vc0_full;
		      get_from_vc0_ep1 <= ~ep0_to_se_vc0_full
					  & ep1_to_se_vc0_full;
		      get_from_vc0_ep2 <= ~ep0_to_se_vc0_full &
					  ~ep1_to_se_vc0_full &
					  ep2_to_se_vc0_full;
		      get_from_vc0_ep3 <= ~ep0_to_se_vc0_full &
					  ~ep1_to_se_vc0_full &
					  ~ep2_to_se_vc0_full &
					  ep3_to_se_vc0_full;
		      
		      send_to_ep0_vc3 <= ep0_to_se_vc0_full;
		      send_to_ep1_vc3 <=  ~ep0_to_se_vc0_full 
					  & ep1_to_se_vc0_full;
		      send_to_ep2_vc3 <= ~ep0_to_se_vc0_full &
					 ~ep1_to_se_vc0_full &
					 ep2_to_se_vc0_full;
		      send_to_ep3_vc3 <= ~ep0_to_se_vc0_full &
					 ~ep1_to_se_vc0_full &
					 ~ep2_to_se_vc0_full &
					 ep3_to_se_vc0_full;
		      
		      get_nA_vc0 <= 1'b0;
		      get_nB_vc0 <= 1'b0;
		      send_to_nA_vc3 <= 1'b0;
		      send_to_nB_vc3 <= 1'b0;
		   end
		   else if(st_nxt == st_serv_n_vc0) begin
		      get_nA_vc0 <= ~nA_vc0_incoming_e;
		      get_nB_vc0 <=  nA_vc0_incoming_e & 
				     ~nB_vc0_incoming_e;
		      send_to_nA_vc3 <= ~nA_vc0_incoming_e;
		      send_to_nB_vc3 <= nA_vc0_incoming_e & 
					~nB_vc0_incoming_e;
		      
		      get_from_vc0_ep0 <= 1'b0;
		      get_from_vc0_ep1 <= 1'b0;
		      get_from_vc0_ep2 <= 1'b0;
		      get_from_vc0_ep3 <= 1'b0;
		      
		      send_to_ep0_vc3 <= 1'b0;
		      send_to_ep1_vc3 <= 1'b0;
		      send_to_ep2_vc3 <= 1'b0;
		      send_to_ep3_vc3 <= 1'b0;
		   end
		   get_nA_vc3 <= 1'b0;
		   get_nB_vc3 <= 1'b0;
		   send_to_nA_vc1 <= 1'b0;
		   send_to_nB_vc1 <= 1'b0;
		   //send_to_nA_vc3 <= 1'b0;
		   //send_to_nB_vc3 <= 1'b0;
		   //sd <= 128'd0;
		   //ldsd_daddr <= 32'd0;
		   //stream_cur_element <= 32'd0;
		   cur_gath_addr <= 32'd0;
		   cur_to_transfer <= 32'd0;
		   //cur_iaddr <= 32'd0;
		   cur_offset <= 32'd0;
		   //read_stream <= 1'b0;
		   scratchpad <= 42'd0;
		   sram_data <= 64'd0;
		   that_just_happened <= 1'b0;
		   //cur_scat_addr <= 32'd0;
		   //cur_scat_addr_plus_offset <= 32'd0;
		end // if (st_nxt != st_idle)
	     end // case: st_idle
	     st_serv_ep_vc0: begin
		if(st_nxt != st_serv_ep_vc0) begin
		   ldsd_daddr <= ep_to_se_vc0_d[31:0];
		   cmd_servicing <= {who_am_i, ep_to_se_vc0_d[101:96], ep_to_se_vc0_d[121:118],
				     ep_to_se_vc0_d[117:102]};
		   if(st_nxt == st_epvc0_ldsdL_read_A)
		     ;//ldsd_daddr <= ep_to_se_vc0_d[31:0];
		   else if(st_nxt == st_epvc0_ldsdG_req | 
			   st_nxt == st_stsdG_send_r) begin
		      send_to_nA_vc1 <= does_this_addr_goto_nA(ep_to_se_vc0_d[31:0]);
		      send_to_nB_vc1 <= does_this_addr_goto_nB(ep_to_se_vc0_d[31:0]);
		      get_nA_vc3 <= does_this_addr_goto_nA(ep_to_se_vc0_d[31:0]);
		      get_nB_vc3 <= does_this_addr_goto_nB(ep_to_se_vc0_d[31:0]);
		   end
		   else if(ep_to_se_vc0_d[121:118] == `OCM_CMD_VC0_RDSTRM |
			   ep_to_se_vc0_d[121:118] == `OCM_CMD_VC0_WRSTRM) begin
		      cur_gath_addr <= ep_to_se_vc0_d[31:0];
		      cur_offset <= ep_to_se_vc0_d[63:32];
		      cur_to_transfer <= {24'd0, ep_to_se_vc0_d[109:102]};
		      cur_scat_addr_plus_offset <= ep_to_se_vc0_d[63:32] + cur_scat_addr;
		   end
		end // if (st_nxt != st_serv_ep_vc0)
	     end // case: st_serv_ep_vc0
	     st_epvc0_ldsdL_read_A: begin
		if(se_mem_gnt) begin
		   that_just_happened <= 1'b1;
		   ldsd_daddr <= ldsd_daddr + 2;
		end
	     end
	     st_epvc0_ldsdL_read_B: begin
		if(that_just_happened) begin
		   that_just_happened <= 1'b0;
		   if(ldsd_daddr[0])
		     sd[31:0] <= se_mem_read_data[63:32];
		   else
		     sd[63:0] <= se_mem_read_data[63:0];
		end
		if(se_mem_gnt) begin
		   that_just_happened <= 1'b1;
		   ldsd_daddr <= ldsd_daddr + 2;
		end
	     end
	     st_epvc0_ldsdL_read_C: begin
		if(that_just_happened) begin
		   that_just_happened <= 1'b0;
		   sd[95:32] <= se_mem_read_data[63:0];
		end
		if(se_mem_gnt) begin
		   that_just_happened <= 1'b1;
		end
	     end
	     st_epvc0_ldsdL_ack: begin
		if(that_just_happened) begin
		   stream_cur_element <= 32'd0;
		   that_just_happened <= 1'b0;
		   if(ldsd_daddr[0])
		     sd[127:96] <= se_mem_read_data[31:0];
		   else
		     sd[127:64] <= se_mem_read_data[63:0];
		end
		if(st_nxt != st_epvc0_ldsdL_ack)
		  cur_iaddr <= index_addr;
	     end
	     st_epvc0_ldsdG_req: begin
		//no delta
	     end 
	     st_epvc0_ldsdG_r_addr: begin
		//no delta
	     end
	     st_epvc0_ldsdG_wait: begin
		//no delta
	     end
	     st_epvc0_ldsdG_read_A: begin
		if(st_nxt != st_epvc0_ldsdG_read_A)
		  sd[31:0] <= n_vc3_incoming_d[31:0];
	     end
	     st_epvc0_ldsdG_read_B: begin
		if(st_nxt != st_epvc0_ldsdG_read_B)
		  sd[63:32] <= n_vc3_incoming_d[31:0];
	     end
	     st_epvc0_ldsdG_read_C: begin
		if(st_nxt != st_epvc0_ldsdG_read_C)
		  sd[95:64] <= n_vc3_incoming_d[31:0];
	     end
	     st_epvc0_ldsdG_read_D: begin
		if(st_nxt != st_epvc0_ldsdG_read_D)
		  sd[127:96] <= n_vc3_incoming_d[31:0];
	     end
	     st_epvc0_ldsdG_ack: begin
		if(st_nxt != st_epvc0_ldsdG_ack) begin
		   stream_cur_element <= 32'd0;
		   cur_iaddr <= index_addr;
		end
	     end
	     st_serv_n_vc0: begin
		if(st_nxt != st_serv_n_vc0)
		  cmd_servicing <= n_vc0_incoming_d[31:0];
	     end
	     st_nvc0_get_addr: begin
		if(st_nxt != st_nvc0_get_addr) begin
		   ldsd_daddr <= n_vc0_incoming_d[31:0];
		   if(st_nxt == st_nvc0_ldsdG_req | 
		      st_nxt == st_stsdG_send_r) begin
		      send_to_nA_vc1 <= does_this_addr_goto_nA(n_vc0_incoming_d[31:0]);
		      send_to_nB_vc1 <= does_this_addr_goto_nB(n_vc0_incoming_d[31:0]);
		      get_nA_vc3 <= does_this_addr_goto_nA(n_vc0_incoming_d[31:0]);
		      get_nB_vc3 <= does_this_addr_goto_nB(n_vc0_incoming_d[31:0]);
		   end
		   /*if(st_nxt == st_write32_write)
		    begin
		    st_save_nxt <= st_stsdL_write_C;
		    wr32_addr <= n_vc0_incoming_d;
		    sram_data[63:32] <= sd[31:0];
		     end*/
		end
	     end // case: st_nvc0_get_addr
	     st_nvc0_ldsdL_read_A: begin
		if(se_mem_gnt) begin
		   that_just_happened <= 1'b1;
		   ldsd_daddr <= ldsd_daddr + 2;
		end
	     end
	     st_nvc0_ldsdL_read_B: begin
		if(that_just_happened) begin
		   that_just_happened <= 1'b0;
		   if(ldsd_daddr[0])
		     sd[31:0] <= se_mem_read_data[63:32];
		   else
		     sd[63:0] <= se_mem_read_data[63:0];
		end
		if(se_mem_gnt) begin
		   that_just_happened <= 1'b1;
		   ldsd_daddr <= ldsd_daddr + 2;
		end
	     end
	     st_nvc0_ldsdL_read_C: begin
		if(that_just_happened) begin
		   that_just_happened <= 1'b0;
		   sd[95:32] <= se_mem_read_data[63:0];
		end
		if(se_mem_gnt) begin
		   that_just_happened <= 1'b1;
		end
	     end
	     st_nvc0_ldsdL_ack: begin
		if(that_just_happened) begin
		   stream_cur_element <= 32'd0;
		   that_just_happened <= 1'b0;
		   if(ldsd_daddr[0])
		     sd[127:96] <= se_mem_read_data[31:0];
		   else
		     sd[127:64] <= se_mem_read_data[63:0];
		end
		if(st_nxt != st_nvc0_ldsdL_ack) begin
		  cur_iaddr <= index_addr;
		end
	     end
	     st_nvc0_ldsdG_req: begin
		//no delta
	     end
	     st_nvc0_ldsdG_r_addr: begin
		//no delta
	     end
	     st_nvc0_ldsdG_wait: begin
		//no delta
	     end
	     st_nvc0_ldsdG_read_A: begin
		if(st_nxt != st_nvc0_ldsdG_read_A)
		  sd[31:0] <= n_vc3_incoming_d[31:0];
	     end
	     st_nvc0_ldsdG_read_B: begin
		if(st_nxt != st_epvc0_ldsdG_read_B)
		  sd[63:32] <= n_vc3_incoming_d[31:0];
	     end
	     st_nvc0_ldsdG_read_C: begin
		if(st_nxt != st_epvc0_ldsdG_read_C)
		  sd[95:64] <= n_vc3_incoming_d[31:0];
	     end
	     st_nvc0_ldsdG_read_D: begin
		if(st_nxt != st_epvc0_ldsdG_read_D)
		  sd[127:96] <= n_vc3_incoming_d[31:0];
	     end
	     st_nvc0_ldsdG_ack: begin
		stream_cur_element <= 32'd0;
		cur_iaddr <= index_addr;
	     end
	     st_nvc0_ldsdI_read_A: begin
		if(st_nxt != st_nvc0_ldsdI_read_A)
		  sd[31:0] <= n_vc0_incoming_d[31:0];
	     end
	     st_nvc0_ldsdI_read_B: begin
		if(st_nxt != st_nvc0_ldsdI_read_B)
		  sd[63:32] <= n_vc0_incoming_d[31:0];
	     end
	     st_nvc0_ldsdI_read_C: begin
		if(st_nxt != st_nvc0_ldsdI_read_C)
		  sd[95:64] <= n_vc0_incoming_d[31:0];
	     end
	     st_nvc0_ldsdI_read_D: begin
   		if(st_nxt != st_nvc0_ldsdI_read_D)
		  sd[127:96] <= n_vc0_incoming_d[31:0];
	     end
	     st_nvc0_ldsdI_ack: begin
		stream_cur_element <= 32'd0;
		cur_iaddr <= index_addr;
	     end
	     /*st_write32_read: begin
		if(st_nxt != st_write32_read)
		  that_just_happened <= 1'b1;
	     end
	     st_write32_write: begin
		if(that_just_happened)
		  if(wr32_addr[0]) //Write the MSW
		    sram_data[31:0] <= se_mem_read_data[31:0];
		  else
		    sram_data[63:32] <= se_mem_read_data[63:32];
	     end*/
	     st_stsdL_write_A: begin
		if(st_nxt != st_stsdL_write_A)
		  ldsd_daddr <= ldsd_daddr + 2;
	     end
	     st_stsdL_write_B: begin
		if(st_nxt != st_stsdL_write_B)
		  ldsd_daddr <= ldsd_daddr + 2;
	     end
	     st_stsdL_write_C: begin
		//no delta
	     end
	     st_stsdL_ack: begin
		//no delta
	     end
	     st_stsdG_send_r: begin
		//no detla
	     end
	     st_stsdG_send_addr: begin
		//no delta
	     end
	     st_stsdG_send_A: begin
		//no delta
	     end
	     st_stsdG_send_B: begin
		//no delta
	     end
	     st_stsdG_send_C: begin
		//no delta
	     end
	     st_stsdG_send_D: begin
		//no delta
	     end
	     st_stsdG_wait: begin
		//no delta
	     end
	     st_stsdG_ack: begin
		//no delta
	     end
	     st_str_gath_addr: begin
		if(st_nxt != st_str_gath_addr) begin
		   cur_gath_addr <= n_vc0_incoming_d[31:0];
		   cur_to_transfer <= {24'd0, cmd_servicing[7:0]};
		end
	     end
	     st_str_scat_addr: begin
		if(st_nxt != st_str_scat_addr) begin
		   cur_offset <= n_vc0_incoming_d[31:0];
		   cur_scat_addr_plus_offset <= n_vc0_incoming_d[31:0] + cur_scat_addr;
		end
	     end
	     st_str_ide_dist: begin
		if(st_nxt != st_str_ide_dist) begin
		   if(read_stream) begin
		      cur_from_address <= cur_scat_addr_plus_offset[31:0];
		      cur_to_address <= cur_gath_addr[31:0];
		      cur_word_cnt <= 32'd0;
		      scratchpad[33] <= 1'b0;
		   end
		   else begin //write stream
		      cur_from_address <= cur_gath_addr[31:0];
		      cur_to_address <= cur_scat_addr_plus_offset[31:0];
		      cur_word_cnt <= 32'd0;
		         scratchpad[33] <= 1'b0;
		   end
		   case({read_stream,
			 does_this_addr_goto_me(cur_scat_addr_plus_offset),
			 does_this_addr_goto_me(cur_gath_addr)})
		     3'b000: begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_scat_addr_plus_offset);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_gath_addr);
		     end
		     3'b001: begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_scat_addr_plus_offset);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_scat_addr_plus_offset);
		     end
		       
		     3'b010: begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_gath_addr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_gath_addr);
		     end
		     3'b011: begin
			send_to_nA_vc1 <= 1'b0;
			send_to_nB_vc1 <= 1'b0;// 
			get_nA_vc3 <= 1'b0;// 
			get_nB_vc3 <= 1'b0;// 
		     end
		     3'b100:begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_gath_addr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_scat_addr_plus_offset);
		     end
		     3'b101:begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_scat_addr_plus_offset);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_scat_addr_plus_offset);
		     end
		     3'b110:begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_gath_addr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_gath_addr);
		     end
		     3'b111:begin
			send_to_nA_vc1 <= 1'b0;
			send_to_nB_vc1 <= 1'b0;// 
			get_nA_vc3 <= 1'b0;// 
			get_nB_vc3 <= 1'b0;// 
		     end 
		   endcase // case({read_stream,...
		   //Need to update all the current states for future use
		   cur_scat_addr <= maxed_out_sd ? 32'd0 :
				    cur_scat_addr + stride_len;
		   cur_scat_addr_plus_offset <= maxed_out_sd ? cur_offset :
						cur_scat_addr_plus_offset +
						stride_len;
		   stream_cur_element <= maxed_out_sd ? 32'd0 : 
					 stream_cur_element  + 1;
		   cur_gath_addr <= cur_gath_addr + record_size;
		   cur_to_transfer <= cur_to_transfer-1;
		end
	     end // case: st_str_ide_dist
	     st_str_ide_done: begin
		//no delta? Let's get the hell out of here....
	     end
	     st_str_idxL_read_mem: begin
		if(st_nxt != st_str_idxL_read_mem)
		  that_just_happened <= 1'b1;
	     end
	     st_str_idxL_save_idx: begin
		if(that_just_happened)
		  begin
		     that_just_happened <= 1'b0;
		     cur_scat_addr <= cur_iaddr[0] ? se_mem_read_data[63:32] : 
				      se_mem_read_data[31:0];
		     cur_scat_addr_plus_offset <= cur_iaddr[0] ? 
						  se_mem_read_data[63:32] + cur_offset : 
						  se_mem_read_data[31:0] + cur_offset;
		  end
	     end
	     st_str_idxG_send_read: begin
		//No delta?
	     end
	     st_str_idxG_send_iaddr: begin
		//No delta?
	     end
	     st_str_idxG_wait_idx: begin
		//No delta, throw away header
	     end
	     //st_str_idxG_wait_idx_addr: begin
	//	if(st_nxt != st_str_idxG_wait_idx_addr) begin
	//	   cur_scat_addr <= n_vc3_incoming_d[31:0];
	//	   cur_scat_addr_plus_offset <= n_vc3_incoming_d[31:0] + cur_offset;
	//	end
	//     end
	     st_str_idx_dist: begin
		if(st_nxt != st_str_idx_dist) begin
		   if(read_stream) begin
		      cur_from_address <= cur_scat_addr_plus_offset;
		      cur_to_address <= cur_gath_addr;
		   end
		   else begin
		      cur_from_address <= cur_gath_addr;
		      cur_to_address <= cur_scat_addr_plus_offset;
		   end
		   case({read_stream,
			 does_this_addr_goto_me(cur_scat_addr_plus_offset),
			 does_this_addr_goto_me(cur_gath_addr)})
		     3'b000: begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			send_to_nB_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nB_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
		     end
		     3'b001: begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			send_to_nB_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nB_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
		     end
		       
		     3'b010: begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			send_to_nB_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nB_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
		     end
		     3'b011: begin
			send_to_nA_vc1 <= 1'b0;
			send_to_nB_vc1 <= 1'b0;// 
			get_nA_vc3 <= 1'b0;// 
			get_nB_vc3 <= 1'b0;// 
		     end
		     3'b100:begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			send_to_nB_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nB_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
		     end
		     3'b101:begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			send_to_nB_vc1 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
			get_nB_vc3 <= does_this_addr_goto_nA(cur_gath_addr);
		     end
		     3'b110:begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			send_to_nB_vc1 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
			get_nB_vc3 <= does_this_addr_goto_nA(cur_scat_addr_plus_offset);
		     end
		     3'b111:begin
			send_to_nA_vc1 <= 1'b0;
			send_to_nB_vc1 <= 1'b0;// 
			get_nA_vc3 <= 1'b0;// 
			get_nB_vc3 <= 1'b0;// 
		     end 
		   endcase // case({read_stream,...
		   cur_iaddr <= maxed_out_sd ? index_addr : cur_iaddr + 1;
		   stream_cur_element <= maxed_out_sd ? 32'd0 : stream_cur_element +1;
		   cur_gath_addr <= cur_gath_addr + record_size;
		   cur_word_cnt <= 32'd0;
		   scratchpad <= 42'd0;
		   cur_to_transfer <= cur_to_transfer - 1;
		end // if (st_nxt != st_str_idx_dist)
	     end // case: st_str_idx_dist
	     st_str_idx_done: begin
		//No delta...just bail?
	     end
	     //todo: None of the setting up of routes (send_nA, etc)
	     //todo: setting up the read_stream variable
	     st_str_GG_gocpy: begin
		//no delta
	     end
	     st_str_GG_goscat_addr: begin
		//no delta
	     end
	     st_str_GG_gogath_addr: begin
		//no delta
	     end
	     st_str_GG_cpywait: begin
		if(st_nxt == st_str_idxG_send_read)
		  begin
		     send_to_nA_vc1 <= does_this_addr_goto_nA(cur_iaddr);
		     send_to_nB_vc1 <= does_this_addr_goto_nB(cur_iaddr);
		     get_nA_vc3 <= does_this_addr_goto_nA(cur_iaddr);
		     get_nB_vc3 <= does_this_addr_goto_nB(cur_iaddr);
		  end	
	     end
	     //reading from the SRAM, then shipping a write
	     st_str_LG_wr_header: begin
		//no delta
	     end
	     st_str_LG_wr_addr: begin
		//no delta
	     end
	     st_str_LG_readSram: begin
		if(st_nxt != st_str_LG_readSram) begin
		   that_just_happened <= 1'b1;
		end		
	     end
	     st_str_LG_send_A: begin
		if(that_just_happened) begin
		   that_just_happened <= 1'b0;
		   sram_data <= se_mem_read_data;
		end
		if(st_nxt != st_str_LG_send_A) begin
		   cur_from_address <= cur_from_address_p1;
		   cur_word_cnt <= cur_word_cnt_p1;
		end		  
	     end
	     st_str_LG_send_B: begin
		if(that_just_happened) begin
		   that_just_happened <= 1'b0;
		   sram_data <= se_mem_read_data;
		end
		if(st_nxt != st_str_LG_send_B) begin
		   cur_from_address <= cur_from_address_p1;
		   cur_word_cnt <= cur_word_cnt_p1;
		end
	     end
	     st_str_LG_wait: begin
		//no delta?
		if(st_nxt == st_str_idxG_send_read)
		  begin
		     send_to_nA_vc1 <= does_this_addr_goto_nA(cur_iaddr);
		     send_to_nB_vc1 <= does_this_addr_goto_nB(cur_iaddr);
		     get_nA_vc3 <= does_this_addr_goto_nA(cur_iaddr);
		     get_nB_vc3 <= does_this_addr_goto_nB(cur_iaddr);
		  end
	     end
	     //We're going to issue a read request and wait...
	     st_str_GL_rd_header: begin
		//no delta
	     end
	     st_str_GL_rd_addr: begin
		//no delta
	     end
	     st_str_GL_wait: begin
		//no delta
	     end
	     st_str_GL_data_A: begin
		if(st_nxt != st_str_GL_data_A) begin
		   if(cur_to_address[0])
		     sram_data[63:32] <= n_vc3_incoming_d[31:0];
		   else
		     sram_data[31:0] <= n_vc3_incoming_d[31:0];
		end
	     end
	     st_str_GL_data_B: begin
		if(st_nxt != st_str_GL_data_B)
		  sram_data[63:32] <= n_vc3_incoming_d[31:0];
	     end
	     st_str_GL_write_SRAM: begin
		if(st_nxt != st_str_GL_write_SRAM) begin
		   cur_word_cnt <= cur_to_address[0] ? cur_word_cnt_p1 : cur_word_cnt_p2;
		   cur_to_address <= cur_to_address[0] ? cur_to_address_p1 :
				     cur_to_address_p2;
		   if(st_nxt == st_str_idxG_send_read)
		     begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_iaddr);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_iaddr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_iaddr);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_iaddr);
		     end
		end
	     end // case: st_str_GL_data_A
	     /*st_str_GL_wrrd_SRAM: begin
	      if(st_nxt != st_str_GL_wrrd_SRAM)
	      that_just_happened <= 1'b1;
	      //end	     */
	     st_str_LL_rdSRAM_A: begin
		if(st_nxt != st_str_LL_rdSRAM_A) begin
		   that_just_happened <= 1'b1;
		   scratchpad[41:35] <= st_str_LL_rdSRAM_A;
		end
	     end
	     st_str_LL_rdSRAM_B: begin
		if(that_just_happened) begin
		   sram_data[31:0] <= se_mem_read_data[63:32];
		   scratchpad[31:0] <= se_mem_read_data[63:32];
		   that_just_happened <= 1'b0;
		end
		if(st_nxt != st_str_LL_rdSRAM_B) begin
		   scratchpad[41:35] <= st_str_LL_rdSRAM_B;
		   scratchpad[33] <= 1'b1;
		   that_just_happened <= 1'b1;
		   cur_from_address <= cur_from_address_p2;
		end		   
	     end
	     /*st_str_LL_wrrdSRAM: begin
	      if(that_just_happened) begin
	      case({cur_from_address[0], cur_to_address[0]})
	      2'b00: begin //last word of a dual read
	      sram_data[31:0] <= se_mem_read_data[31:0];  
		     end
	      2'b01: begin //
	      sram_data[63:32] <=se_mem_read_data[31:0];
	      scratchpad[31:0] <=se_mem_read_data[63:32];
	      scratchpad[33] <= 1'b1;
		     end
	      2'b10: begin //
	      sram_data[31:0] <= scratchpad[31:0];
		     end
	      2'b11: begin //
	      sram_data[63:32] <=se_mem_read_data[63:32];
		     end
		   endcase // case({cur_address[0], cur_daddr[0]})
	      that_just_happened <= 1'b0;
		end // if (sratchpad[32])
	      if(~(st_nxt == st_str_LL_wrrdSRAM)) begin
	      scratchpad[41:35] <= st_str_LL_wrrdSRAM;
	      that_just_happened <= 1'b1;
		end
	     end*/
	     st_str_LL_wrSRAM: begin
		if(that_just_happened) begin
		   if(scratchpad[41:35] == st_str_LL_rdSRAM_A) begin
		      case({cur_from_address[0], cur_to_address[0]})
			2'b00: sram_data <= se_mem_read_data;
			2'b01: begin
			   sram_data[63:32] <=  se_mem_read_data[31:0];
			   sram_data[31:0]  <= scratchpad[31:0];
			   scratchpad[31:0] <=  se_mem_read_data[63:32];
			end
			2'b10: begin
			   sram_data[63:32] <= se_mem_read_data[31:0];
			   sram_data[31:0]  <= 
			       (cur_word_cnt_p1 == record_size
				& ~scratchpad[33]) ?
			       se_mem_read_data[63:32] : scratchpad[31:0];
			   scratchpad[31:0] <= se_mem_read_data[63:32];
			end
			2'b11: sram_data <= se_mem_read_data;
		      endcase // case({cur_address[0], cur_daddr[0]})
		   end // if (scratchpad[41:35] == st_str_LL_rdSRAM_A)
		   else if(scratchpad[41:35] == st_str_LL_rdSRAM_B)
		     begin
			sram_data[63:32] <= se_mem_read_data[31:0];
			scratchpad[31:0] <= se_mem_read_data[63:32];
		     end
		   that_just_happened <= 1'b0;
		end // if (that_just_happened)
		if(~(st_nxt == st_str_LL_wrSRAM)) begin			
		   cur_word_cnt <= cur_to_address[0] ? cur_word_cnt_p1 : 
				   cur_word_cnt_p2;
 		   cur_from_address <= cur_to_address[0] ? cur_from_address_p1 :
				       cur_from_address_p2;
		   cur_to_address <= cur_to_address[0] ? cur_to_address_p1 :
				     cur_to_address_p2;
		   if(st_nxt == st_str_idxG_send_read)
		     begin
			send_to_nA_vc1 <= does_this_addr_goto_nA(cur_iaddr);
			send_to_nB_vc1 <= does_this_addr_goto_nB(cur_iaddr);
			get_nA_vc3 <= does_this_addr_goto_nA(cur_iaddr);
			get_nB_vc3 <= does_this_addr_goto_nB(cur_iaddr);
		     end
		end // if (~(st_nxt == st_str_LL_wrSRAM))
		//ONLY ADD 1 if ~saddr & daddr
		//ONLY ADD 1 if both addr[0]==1
		//ADD 2 OTHERWISE
	     end // case: st_str_LL_wrSRAM
	     default: begin
	     end
	   endcase // case(state)
	end // else: !if(rst)
     end // always@ (posedge CLK)
   
   always@(*)
     begin
	ep_to_se_vc0_read = 1'b0;
	n_vc0_incoming_read = 1'b0;
        n_vc3_incoming_read = 1'b0;
        send_to_n_vc1_r = 1'b0;
        send_to_n_vc1_h = 1'b0;
        send_to_n_vc1_d = 33'd0;
        //send_to_ep_vc3_r = 1'b0;
        send_to_ep_vc3_full = 1'b0;
        send_to_ep_vc3_d = 122'd0;
        send_to_n_vc3_r = 1'b0;
        send_to_n_vc3_h = 1'b0;
        send_to_n_vc3_d = 33'd0;
        se_mem_req = 1'b0;
        se_mem_wen_b = 1'b1;
        se_mem_addr = 16'd0;
        se_mem_write_data = 64'd0;
	se_mem_write_mask = 2'd0;
        case(state)
          st_idle: begin
          end // case: st_idle
	  st_serv_ep_vc0: begin
             ep_to_se_vc0_read = 1'b1;
          end // case:
	  st_epvc0_ldsdL_read_A: begin
             se_mem_req = 1'b1;
             se_mem_wen_b = 1'b1;
             se_mem_addr = ldsd_daddr[15:0];
             se_mem_write_data = 64'd0;
          end // case:
	  st_epvc0_ldsdL_read_B: begin
             se_mem_req = 1'b1;
             se_mem_wen_b = 1'b1;
             se_mem_addr = ldsd_daddr[15:0];
             se_mem_write_data = 64'd0;
          end // case:
	  st_epvc0_ldsdL_read_C: begin
             se_mem_req = 1'b1;
             se_mem_wen_b = 1'b1;
             se_mem_addr = ldsd_daddr[15:0];
             se_mem_write_data = 64'd0;
          end // case:
	  st_epvc0_ldsdL_ack: begin
             send_to_ep_vc3_full = 1'b1;
	     send_to_ep_vc3_d = {`OCM_CMD_VC3_LDSD_P,cmd_servicing[15:0], 
				 who_am_i,96'd0};
	  end // case:
	  st_epvc0_ldsdG_req: begin
             send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d[32] = 1'b1;
	     if(send_to_nA_vc1)
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     else
	       send_to_n_vc1_d[31:26] = nB_node_name;
	     send_to_n_vc1_d[25:0] = {who_am_i, `OCM_CMD_VC1_READ, 8'd0, 8'd4};
	  end 
	  st_epvc0_ldsdG_r_addr: begin
             send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d = {1'b0, ldsd_daddr};
	  end
	  st_epvc0_ldsdG_wait: begin
	  end
	  st_epvc0_ldsdG_read_A: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_epvc0_ldsdG_read_B: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_epvc0_ldsdG_read_C: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_epvc0_ldsdG_read_D: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_epvc0_ldsdG_ack: begin
	     send_to_ep_vc3_full = 1'b1;
	     send_to_ep_vc3_d = {`OCM_CMD_VC3_LDSD_P,cmd_servicing[15:0], 
				 who_am_i,96'd0};
	  end // case: st_epvc0_ldsdG_ack
	  st_serv_n_vc0: begin
             n_vc0_incoming_read = 1'b1;
	  end
	  st_nvc0_get_addr: begin
	     n_vc0_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdL_read_A: begin
             se_mem_req = 1'b1;
             se_mem_wen_b = 1'b1;
             se_mem_addr = ldsd_daddr[15:0];
             se_mem_write_data = 64'd0;
	  end
	  st_nvc0_ldsdL_read_B: begin
             se_mem_req = 1'b1;
             se_mem_wen_b = 1'b1;
             se_mem_addr = ldsd_daddr[15:0];
             se_mem_write_data = 64'd0;
	  end
	  st_nvc0_ldsdL_read_C: begin
             se_mem_req = 1'b1;
             se_mem_wen_b = 1'b1;
             se_mem_addr = ldsd_daddr[15:0];
             se_mem_write_data = 64'd0;
	  end
	  st_nvc0_ldsdL_ack: begin
             send_to_n_vc3_r = 1'b1;
             send_to_n_vc3_h = 1'b1;
             send_to_n_vc3_d = {1'b1, cmd_servicing[25:20], who_am_i,
				`OCM_CMD_VC3_LDSD_P, cmd_servicing[15:0]};
	  end
	  st_nvc0_ldsdG_req: begin
             send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d[32] = 1'b1;
	     if(send_to_nA_vc1)
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     else
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     send_to_n_vc1_d[25:0] = {who_am_i, `OCM_CMD_VC1_READ, 16'd4};
	  end
	  st_nvc0_ldsdG_r_addr: begin
             send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d = {1'b0, ldsd_daddr};
	  end
	  st_nvc0_ldsdG_wait: begin
          end
	  st_nvc0_ldsdG_read_A: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdG_read_B: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdG_read_C: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdG_read_D: begin
             n_vc3_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdG_ack: begin
             send_to_n_vc3_r = 1'b1;
             send_to_n_vc3_h = 1'b1;
             send_to_n_vc3_d = {1'b1, cmd_servicing[25:20], cmd_servicing[31:26], 
				`OCM_CMD_VC3_LDSD_P, cmd_servicing[15:0]};
	  end
	  st_nvc0_ldsdI_read_A: begin
	     n_vc0_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdI_read_B: begin
	     n_vc0_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdI_read_C: begin
	     n_vc0_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdI_read_D: begin
	     n_vc0_incoming_read = 1'b1;
	  end
	  st_nvc0_ldsdI_ack: begin
             send_to_n_vc3_r = 1'b1;
             send_to_n_vc3_h = 1'b1;
             send_to_n_vc3_d = {1'b1, cmd_servicing[25:20], cmd_servicing[31:26], 
				`OCM_CMD_VC3_LDSD_P, cmd_servicing[15:0]};
	  end
	  /*st_write32_read: begin
	     se_mem_req = 1'b1;
	     se_mem_wen_b = 1'b1;
	     se_mem_addr = wr32_addr[15:0];
	     se_mem_write_data = 64'd0;
	  end
	  st_write32_write: begin
	     se_mem_req = ~that_just_happened;
	     se_mem_wen_b = 1'b0;
	     se_mem_addr = wr32_addr[15:0];
	     se_mem_write_data = sram_data[63:0];
	  end*/
	  st_stsdL_write_A: begin
	     se_mem_req = 1'b1;
	     se_mem_wen_b = 1'b0;
	     se_mem_addr = ldsd_daddr[15:0];
	     if(ldsd_daddr[0]) begin
		se_mem_write_data = {sd[31:0], 32'd0};
		se_mem_write_mask = 2'b01;
	     end
	     else begin
		se_mem_write_data = sd[63:0];
		se_mem_write_mask = 2'd0;
	     end
	  end // case: st_stsdL_write_A
	  st_stsdL_write_B: begin
	     se_mem_req = 1'b1;
	     se_mem_wen_b = 1'b0;
	     se_mem_addr = ldsd_daddr[15:0];
	     se_mem_write_mask = 2'd0;
	     if(ldsd_daddr[0]) begin
		se_mem_write_data = sd[95:32];
	     end
	     else begin
		se_mem_write_data = sd[127:64];
	     end
	  end // case: st_stsdL_write_B
	  st_stsdL_write_C: begin
	     se_mem_req = 1'b1;
	     se_mem_wen_b = 1'b0;
	     se_mem_addr = ldsd_daddr[15:0];
	     se_mem_write_data = {32'd0, sd[127:96]};
	     se_mem_write_mask = 2'b10;
	  end
	  st_stsdL_ack: begin
	     if(send_to_nA_vc3 | send_to_nB_vc3) begin
		send_to_n_vc3_r = 1'b1;
		send_to_n_vc3_h = 1'b1;
		send_to_n_vc3_d = {1'b1, cmd_servicing[25:20], cmd_servicing[31:26],
					 `OCM_CMD_VC3_STSD_P, cmd_servicing[15:0]};
	     end
	     else begin
		send_to_ep_vc3_full = 1'b1;
		send_to_ep_vc3_d = {`OCM_CMD_VC3_STSD_P,cmd_servicing[15:0], 
				    who_am_i,96'd0};
	     end
	  end
	  st_stsdG_send_r: begin
	     send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d[32] = 1'b1;
	     if(send_to_nA_vc1)
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     else
	       send_to_n_vc1_d[31:26] = nB_node_name;
	     send_to_n_vc1_d[25:0] = {who_am_i, `OCM_CMD_VC1_WRITE, 16'd4};
	  end
	  st_stsdG_send_addr: begin
	     send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d = {1'b0, ldsd_daddr};
	  end
	  st_stsdG_send_A: begin
	     	     send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d = {1'b0, sd[31:0]};
	  end
	  st_stsdG_send_B: begin
	     send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d = {1'b0, sd[63:32]};
	  end
	  st_stsdG_send_C: begin
	     send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d = {1'b0, sd[95:64]};
	  end
	  st_stsdG_send_D: begin
	     send_to_n_vc1_r = 1'b1;
             send_to_n_vc1_h = 1'b1;
             send_to_n_vc1_d = {1'b0, sd[127:96]};
	  end
	  st_stsdG_wait: begin
	     send_to_n_vc1_r = 1'b0;
	     send_to_n_vc1_h = 1'b0;
	     send_to_n_vc1_d = 33'd0;
	     //need to read vc3
	     n_vc3_incoming_read = 1'b1;
	  end
	  st_stsdG_ack: begin
	     if(send_to_nA_vc3 | send_to_nB_vc3) begin
		send_to_n_vc3_r = 1'b1;
		send_to_n_vc3_h = 1'b1;
		send_to_n_vc3_d[32] = 1'b1;
		send_to_n_vc3_d[31:0] = {cmd_servicing[25:20],
					 who_am_i, `OCM_CMD_VC3_STSD_P, 16'd0};
	     end
	     else begin
		send_to_ep_vc3_full = 1'b1;
		send_to_ep_vc3_d = {`OCM_CMD_VC3_STSD_P,cmd_servicing[15:0], 
				    who_am_i,96'd0};
	     end
	  end // case: st_stsdG_ack
	  st_str_gath_addr: begin
	     n_vc0_incoming_read = 1'b1;
	  end
	  st_str_scat_addr: begin
	     n_vc0_incoming_read = 1'b1;
	  end
	  st_str_ide_dist: begin
	     //nada
	  end
	  st_str_ide_done: begin
	     if(send_to_nA_vc3 | send_to_nB_vc3) begin
		send_to_n_vc3_r = 1'b1;
		send_to_n_vc3_h = 1'b1;
		send_to_n_vc3_d[32:20] = {1'b1, cmd_servicing[25:20], 
					  cmd_servicing[31:26]};
		if(read_stream)
		  send_to_n_vc3_d[19:16] = `OCM_CMD_VC3_RDSTRM_P;
		else
		  send_to_n_vc3_d[19:16] = `OCM_CMD_VC3_WRSTRM_P;
		send_to_n_vc3_d[15:0] = cmd_servicing[15:0];
	     end // if (send_to_nA_vc3 | send_to_nB_vc3)
	     else begin //sending to eps
		send_to_ep_vc3_full = 1'b1;
		if(read_stream)
		  send_to_ep_vc3_d = {`OCM_CMD_VC3_RDSTRM_P,cmd_servicing[15:0], 
				      who_am_i,96'd0};
		else
		  send_to_ep_vc3_d = {`OCM_CMD_VC3_WRSTRM_P,cmd_servicing[15:0], 
				      who_am_i,96'd0};
	     end // else: !if(send_to_nA_vc3 | send_to_nB_vc3)
	  end
	  st_str_idxL_read_mem: begin
	     se_mem_req = 1'b1;
	     se_mem_wen_b = 1'b1;
	     se_mem_addr = cur_iaddr[15:0];
	  end
	  st_str_idxL_save_idx: begin
	     //nada
	  end
	  st_str_idxG_send_read: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d[32] = 1'b1;
	     if(does_this_addr_goto_nA(cur_iaddr))
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     else
	       send_to_n_vc1_d[31:26] = nB_node_name;
	     send_to_n_vc1_d[25:0] = {who_am_i, `OCM_CMD_VC1_READ, 8'd0, 8'd1};
	  end
	  st_str_idxG_send_iaddr: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d = {1'b0,cur_iaddr};
	  end
	  st_str_idxG_wait_idx: begin
	     n_vc3_incoming_read = 1'b1;
	  end
//	  st_str_idxG_wait_idx_addr: begin
//	     n_vc3_incoming_read = 1'b1;
//	  end 
	  st_str_idx_dist: begin
	     //nada
	  end
	  st_str_idx_done: begin
	     if(send_to_nA_vc3 | send_to_nB_vc3) begin
		send_to_n_vc3_r = 1'b1;
		send_to_n_vc3_h = 1'b1;
		send_to_n_vc3_d[32:20] = {1'b1, cmd_servicing[25:20], 
					  cmd_servicing[31:26]};
		if(read_stream)
		  send_to_n_vc3_d[19:16] = `OCM_CMD_VC3_RDSTRM_P;
		else
		  send_to_n_vc3_d[19:16] = `OCM_CMD_VC3_WRSTRM_P;
		send_to_n_vc3_d[15:0] = cmd_servicing[15:0];
	     end
	     else begin //sending to eps
		send_to_ep_vc3_full = 1'b1;
		if(read_stream)
		  send_to_ep_vc3_d = {`OCM_CMD_VC3_RDSTRM_P,cmd_servicing[15:0], 
				      who_am_i,96'd0};
		else
		  send_to_ep_vc3_d = {`OCM_CMD_VC3_WRSTRM_P,cmd_servicing[15:0], 
				      who_am_i,96'd0};
	     end // else: !if(send_to_nA_vc3 | send_to_nB_vc3)
	  end // case: st_str_idx_done
	  st_str_GG_gocpy: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d[32] = 1'b1;
	     if(does_this_addr_goto_nA(cur_from_address))
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     else
	       send_to_n_vc1_d[31:26] = nB_node_name;
	     //todo, can only support an 8 bit record size
	     send_to_n_vc1_d[25:0] = {who_am_i, `OCM_CMD_VC1_COPY, 8'd0, record_size[7:0]};
	  end // case: st_str_GG_gocpy
	  st_str_GG_goscat_addr: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d = {1'b0, cur_from_address};
	     
	  end
	  st_str_GG_gogath_addr: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d = {1'b0, cur_to_address}; 
	  end
	  st_str_GG_cpywait: begin
	     n_vc3_incoming_read = 1'b1;
	  end
	  

	  st_str_LG_wr_header: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d[32] = 1'b1;
	     if(does_this_addr_goto_nA(cur_to_address))
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     else
	       send_to_n_vc1_d[31:26] = nB_node_name;
	     //todo, can only support an 8 bit record size
	     send_to_n_vc1_d[25:0] = {who_am_i, `OCM_CMD_VC1_WRITE, 
				      8'd0, record_size[7:0]};
	  end
	  st_str_LG_wr_addr: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d = {1'b0, cur_to_address};
	  end
	  st_str_LG_readSram: begin
	     send_to_n_vc1_h = 1'b1;
	     se_mem_req = 1'b1;
	     se_mem_wen_b = 1'b1;
	     se_mem_addr = cur_from_address[15:0];
	  end
	  st_str_LG_send_A: begin
	     send_to_n_vc1_r = ~that_just_happened;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d = {1'b0, sram_data[31:0]};
	  end
	  st_str_LG_send_B: begin
	     send_to_n_vc1_r = ~that_just_happened;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d = {1'b0, sram_data[63:32]};
	  end
	  st_str_LG_wait: begin
	     n_vc3_incoming_read = 1'b1;
	  end
	  
	  st_str_GL_rd_header: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d[32] = 1'b1;
	     if(does_this_addr_goto_nA(cur_from_address))
	       send_to_n_vc1_d[31:26] = nA_node_name;
	     else
	       send_to_n_vc1_d[31:26] = nB_node_name;
	     send_to_n_vc1_d[25:0] = {who_am_i, `OCM_CMD_VC1_READ, 
				      8'd0, record_size[7:0]};
	     //todo: only an 8 bit record size
	  end
	  st_str_GL_rd_addr: begin
	     send_to_n_vc1_r = 1'b1;
	     send_to_n_vc1_h = 1'b1;
	     send_to_n_vc1_d = {1'b0, cur_from_address};
	  end
	  st_str_GL_wait: begin
	     //hopefully we won't eat the fifo...
	     n_vc3_incoming_read = 1'b1;
	  end
	  st_str_GL_data_A: begin
	     n_vc3_incoming_read = 1'b1;
	  end
	  st_str_GL_data_B: begin
	     n_vc3_incoming_read = 1'b1;
	  end
	  st_str_GL_write_SRAM: begin
	     se_mem_req = 1'b1;
	     se_mem_wen_b = 1'b0;
	     se_mem_addr = cur_to_address[15:0];
	     se_mem_write_data = sram_data[63:0];
	     if(cur_to_address[0])
	       se_mem_write_mask = 2'b01;
	     else if(cur_word_cnt_p1 == record_size)
	       se_mem_write_mask = 2'b10;
	     else
	       se_mem_write_mask = 2'd0;
	  end
	  /* st_str_GL_wrrd_SRAM: begin
	   se_mem_req = 1'b1;
	   se_mem_wen_b = 1'b1;
	   se_mem_addr = cur_to_address[15:0];
	  end*/
	  st_str_LL_rdSRAM_A: begin
	     se_mem_req = ~that_just_happened;
	     se_mem_wen_b = 1'b1;
	     se_mem_addr = cur_from_address[15:0];
	     se_mem_write_data = 64'd0;
	  end
	  st_str_LL_rdSRAM_B: begin
	     se_mem_req = ~that_just_happened;
	     se_mem_wen_b = 1'b1;
	     se_mem_addr = cur_from_address_p2[15:0];
	     se_mem_write_data = 64'd0;
	  end
	  /*st_str_LL_wrrdSRAM: begin
	   se_mem_req = ~that_just_happened;
	   se_mem_wen_b = 1'b1;
	   se_mem_addr = cur_to_address[15:0];
	   se_mem_write_data = 64'd0;
	  end*/
	  st_str_LL_wrSRAM: begin
	     se_mem_req = ~that_just_happened;
	     se_mem_wen_b = 1'b0;
	     se_mem_addr = cur_to_address[15:0];
	     se_mem_write_data = sram_data[63:0];
	     case({cur_word_cnt_p1 == record_size,
		   cur_from_address[0], cur_to_address[0]})
	       3'b000: se_mem_write_mask = 2'b00;
	       3'b001: se_mem_write_mask = 2'b01;
	       3'b010: se_mem_write_mask = 2'b00;
	       3'b011: se_mem_write_mask = 2'b01; //
	       3'b100: se_mem_write_mask = 2'b10; //
	       3'b101: se_mem_write_mask = 2'b01; //
	       3'b110: se_mem_write_mask = 2'b10; //
	       3'b111: se_mem_write_mask = 2'b01; //
	       default: se_mem_write_mask = 2'd0;
	     endcase // case({cur_word_cnt_p1 == cmd_servicing[7:0],...
	  end // case: st_str_LL_wrSRAM
	  default: begin
	     ep_to_se_vc0_read = 1'b0;
             n_vc0_incoming_read = 1'b0;
             n_vc3_incoming_read = 1'b0;
             send_to_n_vc1_r = 1'b0;
             send_to_n_vc1_h = 1'b0;
             send_to_n_vc1_d = 33'b0;
             //
	     // send_to_ep_vc3_r = 1'b0;
             //send_to_ep_vc3_h = 1'b0;
             //send_to_ep_vc3_d = 33'd0;
             send_to_n_vc3_r = 1'b0;
             send_to_n_vc3_h = 1'b0;
	     send_to_n_vc3_d = 33'd0;
             se_mem_req = 1'b0;
             se_mem_wen_b = 1'b1;
             se_mem_addr = 16'd0;
             se_mem_write_data = 64'd0;
          end // case: default
	  
        endcase
     end // always@ (*)
   
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
   endfunction


 
endmodule // se


   
