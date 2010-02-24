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

module e1_top_level(/*AUTOARG*/
   // Outputs
   test_b0_read_data, test_b1_read_data, test_b2_read_data, 
   test_b3_read_data, gated_outgoing_A, ungated_outgoing_A, 
   gated_outgoing_B, ungated_outgoing_B, ep0_inbox_read, 
   ep1_inbox_read, ep2_inbox_read, ep3_inbox_read, ep0_outbox, 
   ep1_outbox, ep2_outbox, ep3_outbox, ep0_irf_read_data, 
   ep1_irf_read_data, ep2_irf_read_data, ep3_irf_read_data, 
   ep0_irf_gnt_late, ep1_irf_gnt_late, ep2_irf_gnt_late, 
   ep3_irf_gnt_late, ep0_xmu_read_data, ep1_xmu_read_data, 
   ep2_xmu_read_data, ep3_xmu_read_data, ep0_xmu_gnt_late, 
   ep1_xmu_gnt_late, ep2_xmu_gnt_late, ep3_xmu_gnt_late, 
   // Inputs
   CLK, rst, TEST_MODE, test_b0_csn, test_b0_addr, 
   test_b0_write_data, test_b0_write_mask, test_b0_wen_b, 
   test_b1_csn, test_b1_addr, test_b1_write_data, test_b1_write_mask, 
   test_b1_wen_b, test_b2_csn, test_b2_addr, test_b2_write_data, 
   test_b2_write_mask, test_b2_wen_b, test_b3_csn, test_b3_addr, 
   test_b3_write_data, test_b3_write_mask, test_b3_wen_b, 
   gated_incoming_A, ungated_incoming_A, gated_incoming_B, 
   ungated_incoming_B, ep0_inbox, ep1_inbox, ep2_inbox, ep3_inbox, 
   ep0_outbox_read, ep1_outbox_read, ep2_outbox_read, 
   ep3_outbox_read, ep0_irf_req, ep0_irf_addr, ep0_xmu_req, 
   ep0_xmu_addr, ep0_xmu_ld, ep0_xmu_st, ep0_xmu_write_data, 
   ep1_irf_req, ep1_irf_addr, ep1_xmu_req, ep1_xmu_addr, ep1_xmu_ld, 
   ep1_xmu_st, ep1_xmu_write_data, ep2_irf_req, ep2_irf_addr, 
   ep2_xmu_req, ep2_xmu_addr, ep2_xmu_ld, ep2_xmu_st, 
   ep2_xmu_write_data, ep3_irf_req, ep3_irf_addr, ep3_xmu_req, 
   ep3_xmu_addr, ep3_xmu_ld, ep3_xmu_st, ep3_xmu_write_data
   );

   parameter my_dst_header = 2'b01;
   parameter nA_dst_header = 2'b00;
   parameter nB_dst_header = 2'b10;
   parameter my_addr_header_30 = 1'b0;
   parameter nA_addr_header_30 = 1'b0;
   parameter nB_addr_header_30 = 1'b1;
   parameter my_addr_header_2916 = 14'd2;
   parameter nA_addr_header_2916 = 14'd1;
   parameter nB_addr_header_2916 = 14'd0;
   parameter nA_node_name = `OCM_NODE_ENS0;
   parameter nB_node_name = `OCM_NODE_OCM;

   input     CLK;
   input     rst;
   input     TEST_MODE;
   
   output [63:0] test_b0_read_data;
   output [63:0] test_b1_read_data;
   output [63:0] test_b2_read_data;
   output [63:0] test_b3_read_data;
   input 	 test_b0_csn;
   input [7:0] 	 test_b0_addr;
   input [63:0]  test_b0_write_data;
   input [63:0]  test_b0_write_mask;
   input 	 test_b0_wen_b;
   input 	 test_b1_csn;
   input [7:0] 	 test_b1_addr;
   input [63:0]  test_b1_write_data;
   input [63:0]  test_b1_write_mask;
   input 	 test_b1_wen_b;
   input 	 test_b2_csn;
   input [7:0] 	 test_b2_addr;
   input [63:0]  test_b2_write_data;
   input [63:0]  test_b2_write_mask;
   input 	 test_b2_wen_b;
   input 	 test_b3_csn;
   input [7:0] 	 test_b3_addr;
   input [63:0]  test_b3_write_data;
   input [63:0]  test_b3_write_mask;
   input 	 test_b3_wen_b;

   //Networks going to and fro
   output [34:0] gated_outgoing_A;
   output [4:0]  ungated_outgoing_A;
   output [34:0] gated_outgoing_B;
   output [4:0]  ungated_outgoing_B;
   input [34:0]  gated_incoming_A;
   input [4:0] 	 ungated_incoming_A;
   input [34:0]  gated_incoming_B;
   input [4:0] 	 ungated_incoming_B;

   //Mailboxes for goint to and fro
   input [124:0] ep0_inbox;
   output 	 ep0_inbox_read;
   input [124:0] ep1_inbox;
   output 	 ep1_inbox_read;
   input [124:0] ep2_inbox;
   output 	 ep2_inbox_read;
   input [124:0] ep3_inbox;
   output 	 ep3_inbox_read;
   
   output [124:0] ep0_outbox;
   input 	  ep0_outbox_read;
   output [124:0] ep1_outbox;
   input 	  ep1_outbox_read;
   output [124:0] ep2_outbox;
   input 	  ep2_outbox_read;
   output [124:0] ep3_outbox;
   input 	  ep3_outbox_read;

   
   //Copied Muxing from ocm_top
      wire			see_for_nA_vc1_gnt;
   wire			see_for_nA_vc1_r;
   wire			see_for_nA_vc1_h;
   wire [32:0] 		see_for_nA_vc1_d;
   wire			see_for_nB_vc1_gnt;
   wire 		see_for_nB_vc1_r;
   wire			see_for_nB_vc1_h;
   wire [32:0] 		see_for_nB_vc1_d;
   
   wire [32:0] 		se0_for_nA_vc1_d;
   wire			se0_for_nA_vc1_h;
   wire			se0_for_nA_vc1_r;
   wire 		se0_for_nA_vc1_gnt;
   wire [32:0] 		se0_for_nB_vc1_d;
   wire 		se0_for_nB_vc1_h;
   wire			se0_for_nB_vc1_r;
   wire 		se0_for_nB_vc1_gnt;
   wire [32:0] 		se1_for_nA_vc1_d;
   wire			se1_for_nA_vc1_h;
   wire			se1_for_nA_vc1_r;
   wire 		se1_for_nA_vc1_gnt;
   wire [32:0] 		se1_for_nB_vc1_d;
   wire 		se1_for_nB_vc1_h;
   wire			se1_for_nB_vc1_r;
   wire 		se1_for_nB_vc1_gnt;
   wire [32:0] 		se2_for_nA_vc1_d;
   wire			se2_for_nA_vc1_h;
   wire			se2_for_nA_vc1_r;
   wire 		se2_for_nA_vc1_gnt;
   wire [32:0] 		se2_for_nB_vc1_d;
   wire 		se2_for_nB_vc1_h;
   wire			se2_for_nB_vc1_r;
   wire 		se2_for_nB_vc1_gnt;
   wire [32:0] 		se3_for_nA_vc1_d;
   wire			se3_for_nA_vc1_h;
   wire			se3_for_nA_vc1_r;
   wire 		se3_for_nA_vc1_gnt;
   wire [32:0] 		se3_for_nB_vc1_d;
   wire 		se3_for_nB_vc1_h;
   wire			se3_for_nB_vc1_r;
   wire 		se3_for_nB_vc1_gnt;

   wire 		se0_see_vc1_nA_gnt;
   wire 		se1_see_vc1_nA_gnt;
   wire 		se2_see_vc1_nA_gnt;
   wire 		se3_see_vc1_nA_gnt;
   wire 		se0_see_vc1_nB_gnt;
   wire 		se1_see_vc1_nB_gnt;
   wire 		se2_see_vc1_nB_gnt;
   wire 		se3_see_vc1_nB_gnt;

   assign 		se0_for_nA_vc1_gnt = se0_see_vc1_nA_gnt & see_for_nA_vc1_gnt;
   assign 		se1_for_nA_vc1_gnt = se1_see_vc1_nA_gnt & see_for_nA_vc1_gnt;
   assign 		se2_for_nA_vc1_gnt = se2_see_vc1_nA_gnt & see_for_nA_vc1_gnt;
   assign 		se3_for_nA_vc1_gnt = se3_see_vc1_nA_gnt & see_for_nA_vc1_gnt;

   assign 		se0_for_nB_vc1_gnt = se0_see_vc1_nB_gnt & see_for_nB_vc1_gnt;
   assign 		se1_for_nB_vc1_gnt = se1_see_vc1_nB_gnt & see_for_nB_vc1_gnt;
   assign 		se2_for_nB_vc1_gnt = se2_see_vc1_nB_gnt & see_for_nB_vc1_gnt;
   assign 		se3_for_nB_vc1_gnt = se3_see_vc1_nB_gnt & see_for_nB_vc1_gnt;

   assign 		see_for_nA_vc1_r = 
			se0_see_vc1_nA_gnt ? se0_for_nA_vc1_r :
			se1_see_vc1_nA_gnt ? se1_for_nA_vc1_r : 
			se2_see_vc1_nA_gnt ? se2_for_nA_vc1_r : 
			se3_see_vc1_nA_gnt ? se3_for_nA_vc1_r : 1'b0;
   
   assign 		see_for_nA_vc1_h = 
			se0_see_vc1_nA_gnt ? se0_for_nA_vc1_h :
			se1_see_vc1_nA_gnt ? se1_for_nA_vc1_h : 
			se2_see_vc1_nA_gnt ? se2_for_nA_vc1_h : 
			se3_see_vc1_nA_gnt ? se3_for_nA_vc1_h : 1'b0;

   assign 		see_for_nA_vc1_d = 
			se0_see_vc1_nA_gnt ? se0_for_nA_vc1_d :
			se1_see_vc1_nA_gnt ? se1_for_nA_vc1_d : 
			se2_see_vc1_nA_gnt ? se2_for_nA_vc1_d : 
			se3_see_vc1_nA_gnt ? se3_for_nA_vc1_d : 33'b0;
   
   assign 		see_for_nB_vc1_r = 
			se0_see_vc1_nB_gnt ? se0_for_nB_vc1_r :
			se1_see_vc1_nB_gnt ? se1_for_nB_vc1_r : 
			se2_see_vc1_nB_gnt ? se2_for_nB_vc1_r : 
			se3_see_vc1_nB_gnt ? se3_for_nB_vc1_r : 1'b0;
   
   assign 		see_for_nB_vc1_h = 
			se0_see_vc1_nB_gnt ? se0_for_nB_vc1_h :
			se1_see_vc1_nB_gnt ? se1_for_nB_vc1_h : 
			se2_see_vc1_nB_gnt ? se2_for_nB_vc1_h : 
			se3_see_vc1_nB_gnt ? se3_for_nB_vc1_h : 1'b0;

   assign 		see_for_nB_vc1_d = 
			se0_see_vc1_nB_gnt ? se0_for_nB_vc1_d :
			se1_see_vc1_nB_gnt ? se1_for_nB_vc1_d : 
			se2_see_vc1_nB_gnt ? se2_for_nB_vc1_d : 
			se3_see_vc1_nB_gnt ? se3_for_nB_vc1_d : 33'b0;
   

   arb4to1_hold see_nA_vc1(
		       // Outputs
		       .gnt_0		(se0_see_vc1_nA_gnt),
		       .gnt_1		(se1_see_vc1_nA_gnt),
		       .gnt_2		(se2_see_vc1_nA_gnt),
		       .gnt_3		(se3_see_vc1_nA_gnt),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nA_vc1_r),
		       .req_1		(se1_for_nA_vc1_r),
		       .req_2		(se2_for_nA_vc1_r),
		       .req_3		(se3_for_nA_vc1_r),
		       .hold_0		(se0_for_nA_vc1_h),
		       .hold_1		(se1_for_nA_vc1_h),
		       .hold_2		(se2_for_nA_vc1_h),
		       .hold_3		(se3_for_nA_vc1_h));
   
   arb4to1_hold see_nB_vc1(
		       // Outputs
		       .gnt_0		(se0_see_vc1_nB_gnt),
		       .gnt_1		(se1_see_vc1_nB_gnt),
		       .gnt_2		(se2_see_vc1_nB_gnt),
		       .gnt_3		(se3_see_vc1_nB_gnt),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nB_vc1_r),
		       .req_1		(se1_for_nB_vc1_r),
		       .req_2		(se2_for_nB_vc1_r),
		       .req_3		(se3_for_nB_vc1_r),
		       .hold_0		(se0_for_nB_vc1_h),
		       .hold_1		(se1_for_nB_vc1_h),
		       .hold_2		(se2_for_nB_vc1_h),
		       .hold_3		(se3_for_nB_vc1_h));

  wire [32:0] 		nA_vc0_incoming_d;
   wire			nA_vc0_incoming_e;
   wire			nA_vc0_incoming_read;
   wire [32:0] 		nA_vc3_incoming_d;
   wire			nA_vc3_incoming_e;
   wire			nA_vc3_incoming_read;
   wire [32:0] 		nB_vc0_incoming_d;
   wire			nB_vc0_incoming_e;
   wire			nB_vc0_incoming_read;
   wire [32:0] 		nB_vc3_incoming_d;
   wire			nB_vc3_incoming_e;	
   wire			nB_vc3_incoming_read;	
   
   wire 		see_for_nA_vc3_gnt;
   wire 		see_for_nA_vc3_r;
   wire 		see_for_nA_vc3_h;
   wire [32:0] 		see_for_nA_vc3_d;
   wire 		see_for_nB_vc3_gnt;
   wire 		see_for_nB_vc3_r;
   wire 		see_for_nB_vc3_h;
   wire [32:0] 		see_for_nB_vc3_d;

   wire [32:0] 		se0_for_nA_vc3_d;
   wire			se0_for_nA_vc3_h;
   wire			se0_for_nA_vc3_r;
   wire 		se0_for_nA_vc3_gnt;
   wire [32:0] 		se0_for_nB_vc3_d;
   wire 		se0_for_nB_vc3_h;
   wire			se0_for_nB_vc3_r;
   wire 		se0_for_nB_vc3_gnt;
   wire [32:0] 		se1_for_nA_vc3_d;
   wire			se1_for_nA_vc3_h;
   wire			se1_for_nA_vc3_r;
   wire 		se1_for_nA_vc3_gnt;
   wire [32:0] 		se1_for_nB_vc3_d;
   wire 		se1_for_nB_vc3_h;
   wire			se1_for_nB_vc3_r;
   wire 		se1_for_nB_vc3_gnt;
   wire [32:0] 		se2_for_nA_vc3_d;
   wire			se2_for_nA_vc3_h;
   wire			se2_for_nA_vc3_r;
   wire 		se2_for_nA_vc3_gnt;
   wire [32:0] 		se2_for_nB_vc3_d;
   wire 		se2_for_nB_vc3_h;
   wire 		se2_for_nB_vc3_r;
   wire 		se2_for_nB_vc3_gnt;
   wire [32:0] 		se3_for_nA_vc3_d;
   wire 		se3_for_nA_vc3_h;
   wire			se3_for_nA_vc3_r;
   wire 		se3_for_nA_vc3_gnt;
   wire [32:0] 		se3_for_nB_vc3_d;
   wire 		se3_for_nB_vc3_h;
   wire			se3_for_nB_vc3_r;
   wire 		se3_for_nB_vc3_gnt;

   wire 		se0_see_vc3_nA_gnt;
   wire 		se1_see_vc3_nA_gnt;
   wire 		se2_see_vc3_nA_gnt;
   wire 		se3_see_vc3_nA_gnt;
   wire 		se0_see_vc3_nB_gnt;
   wire 		se1_see_vc3_nB_gnt;
   wire 		se2_see_vc3_nB_gnt;
   wire 		se3_see_vc3_nB_gnt;

   assign 		se0_for_nA_vc3_gnt = se0_see_vc3_nA_gnt & see_for_nA_vc3_gnt;
   assign 		se1_for_nA_vc3_gnt = se1_see_vc3_nA_gnt & see_for_nA_vc3_gnt;
   assign 		se2_for_nA_vc3_gnt = se2_see_vc3_nA_gnt & see_for_nA_vc3_gnt;
   assign 		se3_for_nA_vc3_gnt = se3_see_vc3_nA_gnt & see_for_nA_vc3_gnt;

   assign 		se0_for_nB_vc3_gnt = se0_see_vc3_nB_gnt & see_for_nB_vc3_gnt;
   assign 		se1_for_nB_vc3_gnt = se1_see_vc3_nB_gnt & see_for_nB_vc3_gnt;
   assign 		se2_for_nB_vc3_gnt = se2_see_vc3_nB_gnt & see_for_nB_vc3_gnt;
   assign 		se3_for_nB_vc3_gnt = se3_see_vc3_nB_gnt & see_for_nB_vc3_gnt;

   assign 		see_for_nA_vc3_r = 
			se0_see_vc3_nA_gnt ? se0_for_nA_vc3_r :
			se1_see_vc3_nA_gnt ? se1_for_nA_vc3_r : 
			se2_see_vc3_nA_gnt ? se2_for_nA_vc3_r : 
			se3_see_vc3_nA_gnt ? se3_for_nA_vc3_r : 1'b0;
   
   assign 		see_for_nA_vc3_h = 
			se0_see_vc3_nA_gnt ? se0_for_nA_vc3_h :
			se1_see_vc3_nA_gnt ? se1_for_nA_vc3_h : 
			se2_see_vc3_nA_gnt ? se2_for_nA_vc3_h : 
			se3_see_vc3_nA_gnt ? se3_for_nA_vc3_h : 1'b0;

   assign 		see_for_nA_vc3_d = 
			se0_see_vc3_nA_gnt ? se0_for_nA_vc3_d :
			se1_see_vc3_nA_gnt ? se1_for_nA_vc3_d : 
			se2_see_vc3_nA_gnt ? se2_for_nA_vc3_d : 
			se3_see_vc3_nA_gnt ? se3_for_nA_vc3_d : 33'b0;
   
   assign 		see_for_nB_vc3_r = 
			se0_see_vc3_nB_gnt ? se0_for_nB_vc3_r :
			se1_see_vc3_nB_gnt ? se1_for_nB_vc3_r : 
			se2_see_vc3_nB_gnt ? se2_for_nB_vc3_r : 
			se3_see_vc3_nB_gnt ? se3_for_nB_vc3_r : 1'b0;
   
   assign 		see_for_nB_vc3_h = 
			se0_see_vc3_nB_gnt ? se0_for_nB_vc3_h :
			se1_see_vc3_nB_gnt ? se1_for_nB_vc3_h : 
			se2_see_vc3_nB_gnt ? se2_for_nB_vc3_h : 
			se3_see_vc3_nB_gnt ? se3_for_nB_vc3_h : 1'b0;

   assign 		see_for_nB_vc3_d = 
			se0_see_vc3_nB_gnt ? se0_for_nB_vc3_d :
			se1_see_vc3_nB_gnt ? se1_for_nB_vc3_d : 
			se2_see_vc3_nB_gnt ? se2_for_nB_vc3_d : 
			se3_see_vc3_nB_gnt ? se3_for_nB_vc3_d : 33'b0;
   

   arb4to1_hold see_nA_vc3(
		       // Outputs
		       .gnt_0		(se0_see_vc3_nA_gnt),
		       .gnt_1		(se1_see_vc3_nA_gnt),
		       .gnt_2		(se2_see_vc3_nA_gnt),
		       .gnt_3		(se3_see_vc3_nA_gnt),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nA_vc3_r),
		       .req_1		(se1_for_nA_vc3_r),
		       .req_2		(se2_for_nA_vc3_r),
		       .req_3		(se3_for_nA_vc3_r),
		       .hold_0		(se0_for_nA_vc3_h),
		       .hold_1		(se1_for_nA_vc3_h),
		       .hold_2		(se2_for_nA_vc3_h),
		       .hold_3		(se3_for_nA_vc3_h));
   
   arb4to1_hold see_nB_vc3(
		       // Outputs
		       .gnt_0		(se0_see_vc3_nB_gnt),
		       .gnt_1		(se1_see_vc3_nB_gnt),
		       .gnt_2		(se2_see_vc3_nB_gnt),
		       .gnt_3		(se3_see_vc3_nB_gnt),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nB_vc3_r),
		       .req_1		(se1_for_nB_vc3_r),
		       .req_2		(se2_for_nB_vc3_r),
		       .req_3		(se3_for_nB_vc3_r),
		       .hold_0		(se0_for_nB_vc3_h),
		       .hold_1		(se1_for_nB_vc3_h),
		       .hold_2		(se2_for_nB_vc3_h),
		       .hold_3		(se3_for_nB_vc3_h));

   /*
   wire 		nA_vc0_incoming_read;
   wire 		nA_vc0_incoming_e;
   wire [32:0] 		nA_vc0_incoming_d
   wire 		nB_vc0_incoming_read;
   wire 		nB_vc0_incoming_e;
   wire [32:0] 		nB_vc0_incoming_d;
   wire 		nA_vc3_incoming_read;
   wire 		nA_vc3_incoming_e;
   wire [32:0] 		nA_vc3_incoming_d;
   wire 		nB_vc3_incoming_read;
   wire 		nB_vc3_incoming_e;
   wire [32:0] 		nB_vc3_incoming_d;*/

   reg 			incoming_nA_vc0_for_se0;
   reg 			incoming_nA_vc0_for_se1;
   reg 			incoming_nA_vc0_for_se2;
   reg 			incoming_nA_vc0_for_se3;
   reg 			incoming_nB_vc0_for_se0;
   reg 			incoming_nB_vc0_for_se1;
   reg 			incoming_nB_vc0_for_se2;
   reg 			incoming_nB_vc0_for_se3;
   
   reg 			incoming_nA_vc3_for_se0;
   reg 			incoming_nA_vc3_for_se1;
   reg 			incoming_nA_vc3_for_se2;
   reg 			incoming_nA_vc3_for_se3;
   reg 			incoming_nA_vc3_for_ep;
   reg 			incoming_nB_vc3_for_se0;
   reg 			incoming_nB_vc3_for_se1;
   reg 			incoming_nB_vc3_for_se2;
   reg 			incoming_nB_vc3_for_se3;
   reg 			incoming_nB_vc3_for_ep;
   
   

   wire incoming_nA_vc0_for_se0_nxt = nA_vc0_incoming_d[32] ?
	(nA_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD0)  : incoming_nA_vc0_for_se0;
   wire	incoming_nA_vc0_for_se1_nxt = nA_vc0_incoming_d[32] ?
	(nA_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD1)  : incoming_nA_vc0_for_se1;
   wire	incoming_nA_vc0_for_se2_nxt = nA_vc0_incoming_d[32] ?
	(nA_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD2)  : incoming_nA_vc0_for_se2;
   wire	incoming_nA_vc0_for_se3_nxt = nA_vc0_incoming_d[32] ?
	(nA_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD3)  : incoming_nA_vc0_for_se3;
  
   wire	incoming_nB_vc0_for_se0_nxt = nB_vc0_incoming_d[32] ?
	(nB_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD0)  : incoming_nB_vc0_for_se0;
   wire	incoming_nB_vc0_for_se1_nxt = nB_vc0_incoming_d[32] ?
	(nB_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD1)  : incoming_nB_vc0_for_se1;
   wire	incoming_nB_vc0_for_se2_nxt = nB_vc0_incoming_d[32] ?
	(nB_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD2)  : incoming_nB_vc0_for_se2;
   wire	incoming_nB_vc0_for_se3_nxt = nB_vc0_incoming_d[32] ?
	(nB_vc0_incoming_d[31:26] == `OCM_NODE_E0_SD3)  : incoming_nB_vc0_for_se3;
   
   wire	incoming_nA_vc3_for_se0_nxt = nA_vc3_incoming_d[32] ?
	(nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD0)  : incoming_nA_vc3_for_se0;
   wire	incoming_nA_vc3_for_se1_nxt = nA_vc3_incoming_d[32] ?
	(nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD1)  : incoming_nA_vc3_for_se1;
   wire	incoming_nA_vc3_for_se2_nxt = nA_vc3_incoming_d[32] ?
	(nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD2)  : incoming_nA_vc3_for_se2;

   wire	incoming_nA_vc3_for_se3_nxt = nA_vc3_incoming_d[32] ?
	(nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD3)  : incoming_nA_vc3_for_se3;
   wire incoming_nA_vc3_for_ep_nxt =  nA_vc3_incoming_d[32] ?
	(nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP0 | nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP1 |
	 nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP2 | nA_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP3) :
	  incoming_nA_vc3_for_ep;
      
   wire	incoming_nB_vc3_for_se0_nxt = nB_vc3_incoming_d[32] ?
	(nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD0)  : incoming_nB_vc3_for_se0;
   wire	incoming_nB_vc3_for_se1_nxt = nB_vc3_incoming_d[32] ?
	(nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD1)  : incoming_nB_vc3_for_se1;
   wire	incoming_nB_vc3_for_se2_nxt = nB_vc3_incoming_d[32] ?
	(nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD2)  : incoming_nB_vc3_for_se2;
   wire	incoming_nB_vc3_for_se3_nxt = nB_vc3_incoming_d[32] ?
	(nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_SD3)  : incoming_nB_vc3_for_se3;
   wire incoming_nB_vc3_for_ep_nxt =  nB_vc3_incoming_d[32] ?
	(nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP0 | nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP1 |
	 nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP2 | nB_vc3_incoming_d[31:26] == `OCM_NODE_E0_EP3) :
	  incoming_nB_vc3_for_ep;
   
   

   always@(posedge CLK or posedge rst) begin
      if(rst) begin
	 incoming_nA_vc0_for_se0 <= 1'b0;
	 incoming_nA_vc0_for_se1 <= 1'b0;
	 incoming_nA_vc0_for_se2 <= 1'b0;
   	 incoming_nA_vc0_for_se3 <= 1'b0;
    	 incoming_nB_vc0_for_se0 <= 1'b0;
    	 incoming_nB_vc0_for_se1 <= 1'b0;
   	 incoming_nB_vc0_for_se2 <= 1'b0;
   	 incoming_nB_vc0_for_se3 <= 1'b0;
   	 incoming_nA_vc3_for_se0 <= 1'b0;
	 incoming_nA_vc3_for_se1 <= 1'b0;
	 incoming_nA_vc3_for_se2 <= 1'b0;
	 incoming_nA_vc3_for_se3 <= 1'b0;
	 incoming_nA_vc3_for_ep  <= 1'b0;// 
   	 incoming_nB_vc3_for_se0 <= 1'b0;
   	 incoming_nB_vc3_for_se1 <= 1'b0;
   	 incoming_nB_vc3_for_se2 <= 1'b0;
   	 incoming_nB_vc3_for_se3 <= 1'b0;
	 incoming_nB_vc3_for_ep  <= 1'b0;
      end // if (rst)
      else begin
	 incoming_nA_vc0_for_se0 <= incoming_nA_vc0_for_se0_nxt;
	 incoming_nA_vc0_for_se1 <= incoming_nA_vc0_for_se1_nxt;
	 incoming_nA_vc0_for_se2 <= incoming_nA_vc0_for_se2_nxt;
	 incoming_nA_vc0_for_se3 <= incoming_nA_vc0_for_se3_nxt;
	 incoming_nB_vc0_for_se0 <= incoming_nB_vc0_for_se0_nxt;
	 incoming_nB_vc0_for_se1 <= incoming_nB_vc0_for_se1_nxt;
	 incoming_nB_vc0_for_se2 <= incoming_nB_vc0_for_se2_nxt;
	 incoming_nB_vc0_for_se3 <= incoming_nB_vc0_for_se3_nxt;
	 incoming_nA_vc3_for_se0 <= incoming_nA_vc3_for_se0_nxt;
	 incoming_nA_vc3_for_se1 <= incoming_nA_vc3_for_se1_nxt;
	 incoming_nA_vc3_for_se2 <= incoming_nA_vc3_for_se2_nxt;
	 incoming_nA_vc3_for_se3 <= incoming_nA_vc3_for_se3_nxt;
	 incoming_nA_vc3_for_ep  <= incoming_nA_vc3_for_ep_nxt;
	 incoming_nB_vc3_for_se0 <= incoming_nB_vc3_for_se0_nxt;
	 incoming_nB_vc3_for_se1 <= incoming_nB_vc3_for_se1_nxt;
	 incoming_nB_vc3_for_se2 <= incoming_nB_vc3_for_se2_nxt;
	 incoming_nB_vc3_for_se3 <= incoming_nB_vc3_for_se3_nxt;
	 incoming_nB_vc3_for_ep  <= incoming_nB_vc3_for_ep_nxt;
	 
      end // else: !if(rst) 
   end // always@ (posedge CLK)
   
   wire 		se0_nA_vc0_incoming_e = incoming_nA_vc0_for_se0_nxt ? nA_vc0_incoming_e : 1'b1;
   wire [32:0] 		se0_nA_vc0_incoming_d = incoming_nA_vc0_for_se0_nxt ? nA_vc0_incoming_d : 33'd0;
   wire 		se0_nB_vc0_incoming_e = incoming_nB_vc0_for_se0_nxt ? nB_vc0_incoming_e : 1'b1;
   wire [32:0] 		se0_nB_vc0_incoming_d = incoming_nB_vc0_for_se0_nxt ? nB_vc0_incoming_d : 33'd0;
   wire 		se1_nA_vc0_incoming_e = incoming_nA_vc0_for_se1_nxt ? nA_vc0_incoming_e : 1'b1;
   wire [32:0] 		se1_nA_vc0_incoming_d = incoming_nA_vc0_for_se1_nxt ? nA_vc0_incoming_d : 33'd0;
   wire 		se1_nB_vc0_incoming_e = incoming_nB_vc0_for_se1_nxt ? nB_vc0_incoming_e : 1'b1;
   wire [32:0] 		se1_nB_vc0_incoming_d = incoming_nB_vc0_for_se1_nxt ? nB_vc0_incoming_d : 33'd0;
   wire 		se2_nA_vc0_incoming_e = incoming_nA_vc0_for_se2_nxt ? nA_vc0_incoming_e : 1'b1;
   wire [32:0] 		se2_nA_vc0_incoming_d = incoming_nA_vc0_for_se2_nxt ? nA_vc0_incoming_d : 33'd0;
   wire 		se2_nB_vc0_incoming_e = incoming_nB_vc0_for_se2_nxt ? nB_vc0_incoming_e : 1'b1;
   wire [32:0] 		se2_nB_vc0_incoming_d = incoming_nB_vc0_for_se2_nxt ? nB_vc0_incoming_d : 33'd0;
   wire 		se3_nA_vc0_incoming_e = incoming_nA_vc0_for_se3_nxt ? nA_vc0_incoming_e : 1'b1;
   wire [32:0] 		se3_nA_vc0_incoming_d = incoming_nA_vc0_for_se3_nxt ? nA_vc0_incoming_d : 33'd0;
   wire 		se3_nB_vc0_incoming_e = incoming_nB_vc0_for_se3_nxt ? nB_vc0_incoming_e : 1'b1;
   wire [32:0] 		se3_nB_vc0_incoming_d = incoming_nB_vc0_for_se3_nxt ? nB_vc0_incoming_d : 33'd0;
   
   wire 		se0_nA_vc3_incoming_e = incoming_nA_vc3_for_se0_nxt ? nA_vc3_incoming_e : 1'b1;
   wire [32:0] 		se0_nA_vc3_incoming_d = incoming_nA_vc3_for_se0_nxt ? nA_vc3_incoming_d : 33'd0;
   wire 		se0_nB_vc3_incoming_e = incoming_nB_vc3_for_se0_nxt ? nB_vc3_incoming_e : 1'b1;
   wire [32:0] 		se0_nB_vc3_incoming_d = incoming_nB_vc3_for_se0_nxt ? nB_vc3_incoming_d : 33'd0;
   wire 		se1_nA_vc3_incoming_e = incoming_nA_vc3_for_se1_nxt ? nA_vc3_incoming_e : 1'b1;
   wire [32:0] 		se1_nA_vc3_incoming_d = incoming_nA_vc3_for_se1_nxt ? nA_vc3_incoming_d : 33'd0;
   wire 		se1_nB_vc3_incoming_e = incoming_nB_vc3_for_se1_nxt ? nB_vc3_incoming_e : 1'b1;
   wire [32:0] 		se1_nB_vc3_incoming_d = incoming_nB_vc3_for_se1_nxt ? nB_vc3_incoming_d : 33'd0;
   wire 		se2_nA_vc3_incoming_e = incoming_nA_vc3_for_se2_nxt ? nA_vc3_incoming_e : 1'b1;
   wire [32:0] 		se2_nA_vc3_incoming_d = incoming_nA_vc3_for_se2_nxt ? nA_vc3_incoming_d : 33'd0;
   wire 		se2_nB_vc3_incoming_e = incoming_nB_vc3_for_se2_nxt ? nB_vc3_incoming_e : 1'b1;
   wire [32:0] 		se2_nB_vc3_incoming_d = incoming_nB_vc3_for_se2_nxt ? nB_vc3_incoming_d : 33'd0;
   wire 		se3_nA_vc3_incoming_e = incoming_nA_vc3_for_se3_nxt ? nA_vc3_incoming_e : 1'b1;
   wire [32:0] 		se3_nA_vc3_incoming_d = incoming_nA_vc3_for_se3_nxt ? nA_vc3_incoming_d : 33'd0;
   wire 		se3_nB_vc3_incoming_e = incoming_nB_vc3_for_se3_nxt ? nB_vc3_incoming_e : 1'b1;
   wire [32:0] 		se3_nB_vc3_incoming_d = incoming_nB_vc3_for_se3_nxt ? nB_vc3_incoming_d : 33'd0;
   wire 		ep_nA_vc3_incoming_e  = incoming_nA_vc3_for_ep_nxt ?  nA_vc3_incoming_e : 1'b1;
   wire [32:0] 		ep_nA_vc3_incoming_d  = incoming_nA_vc3_for_ep_nxt ?  nA_vc3_incoming_d : 33'd0;
   wire 		ep_nB_vc3_incoming_e  = incoming_nB_vc3_for_ep_nxt ?  nB_vc3_incoming_e : 1'b1;
   wire [32:0] 		ep_nB_vc3_incoming_d  = incoming_nB_vc3_for_ep_nxt ?  nB_vc3_incoming_d : 33'd0;
 		
   
   wire 		se0_nA_vc0_incoming_read;
   wire 		se0_nB_vc0_incoming_read;
   wire 		se0_nA_vc3_incoming_read;
   wire 		se0_nB_vc3_incoming_read;
   wire 		se1_nA_vc0_incoming_read;
   wire 		se1_nB_vc0_incoming_read;
   wire 		se1_nA_vc3_incoming_read;
   wire 		se1_nB_vc3_incoming_read;
   wire 		se2_nA_vc0_incoming_read;
   wire 		se2_nB_vc0_incoming_read;
   wire 		se2_nA_vc3_incoming_read;
   wire 		se2_nB_vc3_incoming_read;
   wire 		se3_nA_vc0_incoming_read;
   wire 		se3_nB_vc0_incoming_read;
   wire 		se3_nA_vc3_incoming_read;
   wire 		se3_nB_vc3_incoming_read;
   wire 		ep_nA_vc3_incoming_read;
   wire 		ep_nB_vc3_incoming_read;
   
 
   assign 		nA_vc0_incoming_read = 
			(incoming_nA_vc0_for_se0_nxt & se0_nA_vc0_incoming_read) |
			(incoming_nA_vc0_for_se1_nxt & se1_nA_vc0_incoming_read) |
			(incoming_nA_vc0_for_se2_nxt & se2_nA_vc0_incoming_read) |
			(incoming_nA_vc0_for_se3_nxt & se3_nA_vc0_incoming_read);
   assign 		nB_vc0_incoming_read = 
			(incoming_nB_vc0_for_se0_nxt & se0_nB_vc0_incoming_read) |
			(incoming_nB_vc0_for_se1_nxt & se1_nB_vc0_incoming_read) |
			(incoming_nB_vc0_for_se2_nxt & se2_nB_vc0_incoming_read) |
			(incoming_nB_vc0_for_se3_nxt & se3_nB_vc0_incoming_read);
   assign 		nA_vc3_incoming_read = 
			(incoming_nA_vc3_for_se0_nxt & se0_nA_vc3_incoming_read) |
			(incoming_nA_vc3_for_se1_nxt & se1_nA_vc3_incoming_read) |
			(incoming_nA_vc3_for_se2_nxt & se2_nA_vc3_incoming_read) |
			(incoming_nA_vc3_for_ep_nxt  & ep_nA_vc3_incoming_read) | 
			(incoming_nA_vc3_for_se3_nxt & se3_nA_vc3_incoming_read);
   assign 		nB_vc3_incoming_read = 
			(incoming_nB_vc3_for_se0_nxt & se0_nB_vc3_incoming_read) |
			(incoming_nB_vc3_for_se1_nxt & se1_nB_vc3_incoming_read) |
			(incoming_nB_vc3_for_se2_nxt & se2_nB_vc3_incoming_read) |
			(incoming_nB_vc3_for_ep_nxt  &  ep_nB_vc3_incoming_read) | 
			(incoming_nB_vc3_for_se3_nxt & se3_nB_vc3_incoming_read);
   
   
      
   //network sm1 interchange
   wire			nie_sm1_for_nA_vc2_gnt;
   wire			nie_sm1_for_nA_vc3_gnt;
   wire			nie_sm1_for_nB_vc2_gnt;
   wire			nie_sm1_for_nB_vc3_gnt;
   wire [32:0] 		nie_sm1_for_nA_vc2_d;
   wire			nie_sm1_for_nA_vc2_h;
   wire			nie_sm1_for_nA_vc2_r;
   wire [32:0]		nie_sm1_for_nA_vc3_d;
   wire			nie_sm1_for_nA_vc3_h;
   wire			nie_sm1_for_nA_vc3_r;
   wire [32:0]		nie_sm1_for_nB_vc2_d;
   wire			nie_sm1_for_nB_vc2_h;
   wire			nie_sm1_for_nB_vc2_r;
   wire [32:0]		nie_sm1_for_nB_vc3_d;
   wire			nie_sm1_for_nB_vc3_h;
   wire			nie_sm1_for_nB_vc3_r;
   wire [32:0] 		nA_vc1_incoming_d;
   wire			nA_vc1_incoming_e;
   wire			nA_vc1_incoming_read;
   wire [32:0] 		nB_vc1_incoming_d;
   wire			nB_vc1_incoming_e;
   wire			nB_vc1_incoming_read;

   //network sm2 interchange
   wire			nie_sm2_for_nA_vc3_gnt;
   wire			nie_sm2_for_nB_vc3_gnt;
   wire [32:0] 		nA_vc2_incoming_d;
   wire			nA_vc2_incoming_e;
   wire			nA_vc2_incoming_read;
   wire [32:0] 		nB_vc2_incoming_d;
   wire			nB_vc2_incoming_e;
   wire			nB_vc2_incoming_read;
   wire [32:0] 		nie_sm2_for_nA_vc3_d;
   wire			nie_sm2_for_nA_vc3_h;
   wire			nie_sm2_for_nA_vc3_r;
   wire [32:0]		nie_sm2_for_nB_vc3_d;
   wire			nie_sm2_for_nB_vc3_h;
   wire			nie_sm2_for_nB_vc3_r;
   //Why in the hell do we need these??? todo
   wire [32:0] 		nie_sm2_for_se0_vc3_d;
   wire			nie_sm2_for_se0_vc3_r;
   wire [32:0]		nie_sm2_for_se1_vc3_d;
   wire			nie_sm2_for_se1_vc3_r;
   wire [32:0]		nie_sm2_for_se2_vc3_d;
   wire			nie_sm2_for_se2_vc3_r;
   wire [32:0]		nie_sm2_for_se3_vc3_d;
   wire			nie_sm2_for_se3_vc3_r;
   wire 		nie_sm2_for_se0_vc3_gnt = 1'b0;
   wire 		nie_sm2_for_se1_vc3_gnt = 1'b0;
   wire 		nie_sm2_for_se2_vc3_gnt = 1'b0;
   wire 		nie_sm2_for_se3_vc3_gnt = 1'b0;
		
   
   //memory sm1 interchange
   wire [15:0]		nie_sm1_mem_addr;	
   wire			nie_sm1_mem_gnt;	
   wire			nie_sm1_mem_lock;	
   wire [63:0]		nie_sm1_mem_read_data;	
   wire			nie_sm1_mem_req;	
   wire			nie_sm1_mem_wen_b;	
   wire [63:0] 		nie_sm1_mem_write_data;
   wire [63:0] 		nie_sm1_mem_write_mask;	
   
   //memory sm2 interchange
   wire [15:0] 		nie_sm2_mem_addr;	
   wire 		nie_sm2_mem_gnt;	
   wire [63:0] 		nie_sm2_mem_read_data;	
   wire			nie_sm2_mem_req;	
   wire			nie_sm2_mem_wen_b;	
   wire [63:0]		nie_sm2_mem_write_data;
   wire [63:0] 		nie_sm2_mem_write_mask;
   

   // Beginning of automatic wires (for undeclared instantiated-module outputs)
  /*wire			ep0_to_se_vc0_read;	// From se0 of se.v, ...
   wire			ep1_to_se_vc0_read;	// From se0 of se.v, ...
   wire			ep2_to_se_vc0_read;	// From se0 of se.v, ...
   wire			ep3_to_se_vc0_read;	// From se0 of se.v, ...
   wire			epe_1g_for_nA_vc1_gnt;	// From the_ni of all_port_ni.v
   wire			epe_1g_for_nB_vc1_gnt;	// From the_ni of all_port_ni.v
   */
     
   //for the memory and ses
   wire			se0_mem_gnt;		
   wire [63:0]		se0_mem_read_data;	
   wire			se1_mem_gnt;		
   wire [63:0]		se1_mem_read_data;	
   wire			se2_mem_gnt;		
   wire [63:0]		se2_mem_read_data;	
   wire			se3_mem_gnt;		
   wire [63:0]		se3_mem_read_data;	
   wire [15:0] 		se0_mem_addr;		
   wire			se0_mem_req;		
   wire			se0_mem_wen_b;		
   wire [63:0]		se0_mem_write_data;
   wire [63:0] 		se0_mem_write_mask;	
   wire [15:0] 		se1_mem_addr;		
   wire			se1_mem_req;		
   wire			se1_mem_wen_b;		
   wire [63:0]		se1_mem_write_data;
   wire [63:0] 		se1_mem_write_mask;	
   wire [15:0] 		se2_mem_addr;		
   wire			se2_mem_req;		
   wire			se2_mem_wen_b;		
   wire [63:0]		se2_mem_write_data;
   wire [63:0] 		se2_mem_write_mask;	
   wire [15:0] 		se3_mem_addr;		
   wire			se3_mem_req;		
   wire			se3_mem_wen_b;		
   wire [63:0]		se3_mem_write_data;
   wire [63:0] 		se3_mem_write_mask;	
   
   //EP to SE communciations...
   wire [121:0] 	ep0_to_se0_vc0_d;
   wire [121:0] 	ep0_to_se1_vc0_d;
   wire [121:0] 	ep0_to_se2_vc0_d;
   wire [121:0] 	ep0_to_se3_vc0_d;
   wire [121:0] 	ep1_to_se0_vc0_d;
   wire [121:0] 	ep1_to_se1_vc0_d;
   wire [121:0] 	ep1_to_se2_vc0_d;
   wire [121:0] 	ep1_to_se3_vc0_d;
   wire [121:0] 	ep2_to_se0_vc0_d;
   wire [121:0] 	ep2_to_se1_vc0_d;
   wire [121:0] 	ep2_to_se2_vc0_d;
   wire [121:0] 	ep2_to_se3_vc0_d;
   wire [121:0] 	ep3_to_se0_vc0_d;
   wire [121:0] 	ep3_to_se1_vc0_d;
   wire [121:0] 	ep3_to_se2_vc0_d;
   wire [121:0] 	ep3_to_se3_vc0_d;
   
   wire 		ep0_to_se0_vc0_full;
   wire 		ep0_to_se1_vc0_full;
   wire 		ep0_to_se2_vc0_full;
   wire 		ep0_to_se3_vc0_full;
   wire 		ep1_to_se0_vc0_full;
   wire 		ep1_to_se1_vc0_full;
   wire 		ep1_to_se2_vc0_full;
   wire 		ep1_to_se3_vc0_full;
   wire 		ep2_to_se0_vc0_full;
   wire 		ep2_to_se1_vc0_full;
   wire 		ep2_to_se2_vc0_full;
   wire 		ep2_to_se3_vc0_full;
   wire 		ep3_to_se0_vc0_full;
   wire 		ep3_to_se1_vc0_full;
   wire 		ep3_to_se2_vc0_full;
   wire 		ep3_to_se3_vc0_full;

   wire 		ep0_to_se0_vc0_read;
   wire 		ep0_to_se1_vc0_read;
   wire 		ep0_to_se2_vc0_read;
   wire 		ep0_to_se3_vc0_read;
   wire 		ep1_to_se0_vc0_read;
   wire 		ep1_to_se1_vc0_read;
   wire 		ep1_to_se2_vc0_read;
   wire 		ep1_to_se3_vc0_read;
   wire 		ep2_to_se0_vc0_read;
   wire 		ep2_to_se1_vc0_read;
   wire 		ep2_to_se2_vc0_read;
   wire 		ep2_to_se3_vc0_read;
   wire 		ep3_to_se0_vc0_read;
   wire 		ep3_to_se1_vc0_read;
   wire 		ep3_to_se2_vc0_read;
   wire 		ep3_to_se3_vc0_read;

   wire [121:0] 	se0_for_ep0_vc3_d;
   wire [121:0] 	se0_for_ep1_vc3_d;
   wire [121:0] 	se0_for_ep2_vc3_d;
   wire [121:0] 	se0_for_ep3_vc3_d;
   wire [121:0] 	se1_for_ep0_vc3_d;
   wire [121:0] 	se1_for_ep1_vc3_d;
   wire [121:0] 	se1_for_ep2_vc3_d;
   wire [121:0] 	se1_for_ep3_vc3_d;
   wire [121:0] 	se2_for_ep0_vc3_d;
   wire [121:0] 	se2_for_ep1_vc3_d;
   wire [121:0] 	se2_for_ep2_vc3_d;
   wire [121:0] 	se2_for_ep3_vc3_d;
   wire [121:0] 	se3_for_ep0_vc3_d;
   wire [121:0] 	se3_for_ep1_vc3_d;
   wire [121:0] 	se3_for_ep2_vc3_d;
   wire [121:0] 	se3_for_ep3_vc3_d;

   wire 		se0_for_ep0_vc3_full;
   wire 		se0_for_ep1_vc3_full;
   wire 		se0_for_ep2_vc3_full;
   wire 		se0_for_ep3_vc3_full;
   wire 		se1_for_ep0_vc3_full;
   wire 		se1_for_ep1_vc3_full;
   wire 		se1_for_ep2_vc3_full;
   wire 		se1_for_ep3_vc3_full;
   wire 		se2_for_ep0_vc3_full;
   wire 		se2_for_ep1_vc3_full;
   wire 		se2_for_ep2_vc3_full;
   wire 		se2_for_ep3_vc3_full;
   wire 		se3_for_ep0_vc3_full;
   wire 		se3_for_ep1_vc3_full;
   wire 		se3_for_ep2_vc3_full;
   wire 		se3_for_ep3_vc3_full;

   wire [121:0] 	ep0_inbox_vc0G_d;
   wire 		ep0_inbox_vc0G_full;
   wire [121:0] 	ep1_inbox_vc0G_d;
   wire 		ep1_inbox_vc0G_full;
   wire [121:0] 	ep2_inbox_vc0G_d;
   wire 		ep2_inbox_vc0G_full;
   wire [121:0] 	ep3_inbox_vc0G_d;
   wire 		ep3_inbox_vc0G_full;
   
   wire [121:0] 	ep0_inbox_vc1L_d;
   wire 		ep0_inbox_vc1L_full;
   wire [121:0] 	ep1_inbox_vc1L_d;
   wire 		ep1_inbox_vc1L_full;
   wire [121:0] 	ep2_inbox_vc1L_d;
   wire 		ep2_inbox_vc1L_full;
   wire [121:0] 	ep3_inbox_vc1L_d;
   wire 		ep3_inbox_vc1L_full;
		
   wire 		epe_1G_for_nA_vc1_r;
   wire 		epe_1G_for_nA_vc1_h;
   wire [32:0] 		epe_1G_for_nA_vc1_d;
   wire 		epe_1G_for_nB_vc1_r;
   wire 		epe_1G_for_nB_vc1_h;
   wire [32:0] 		epe_1G_for_nB_vc1_d;
   wire 		epe_1G_for_nA_vc1_gnt;
   wire 		epe_1G_for_nB_vc1_gnt;

   wire 		se0_for_ep0_vc3_gnt;
   wire 		se1_for_ep0_vc3_gnt;
   wire 		se2_for_ep0_vc3_gnt;
   wire 		se3_for_ep0_vc3_gnt;
   wire 		se0_for_ep1_vc3_gnt;
   wire 		se1_for_ep1_vc3_gnt;
   wire 		se2_for_ep1_vc3_gnt;
   wire 		se3_for_ep1_vc3_gnt;
   wire 		se0_for_ep2_vc3_gnt;
   wire 		se1_for_ep2_vc3_gnt;
   wire 		se2_for_ep2_vc3_gnt;
   wire 		se3_for_ep2_vc3_gnt;
   wire 		se0_for_ep3_vc3_gnt;
   wire 		se1_for_ep3_vc3_gnt;
   wire 		se2_for_ep3_vc3_gnt;
   wire 		se3_for_ep3_vc3_gnt;

   wire 		sm1L_for_ep0_gnt;
   wire 		sm1L_for_ep1_gnt;
   wire 		sm1L_for_ep2_gnt;
   wire 		sm1L_for_ep3_gnt;
   wire 		sm1L_for_ep0_full;
   wire [121:0] 	sm1L_for_ep0_d;
   wire 		sm1L_for_ep1_full;
   wire [121:0] 	sm1L_for_ep1_d;
   wire 		sm1L_for_ep2_full;
   wire [121:0] 	sm1L_for_ep2_d;
   wire 		sm1L_for_ep3_full;
   wire [121:0] 	sm1L_for_ep3_d;

   wire 		ep0_inbox_vc0G_read;
   wire 		ep1_inbox_vc0G_read;
   wire 		ep2_inbox_vc0G_read;
   wire 		ep3_inbox_vc0G_read;
   
   wire 		ep0_inbox_vc1L_read;
   wire 		ep1_inbox_vc1L_read;
   wire 		ep2_inbox_vc1L_read;
   wire 		ep3_inbox_vc1L_read;

   //wire [32:0] 		ep_nA_vc3_incoming_d;
   //wire 		ep_nA_vc3_incoming_e;
   //wire 		ep_nA_vc3_incoming_read;
   
   //wire [32:0] 		ep_nB_vc3_incoming_d;
   //wire 		ep_nB_vc3_incoming_e;
   //wire 		ep_nB_vc3_incoming_read;
   
   // End of automatics

   ep_box_muxdemux #(.who_am_i(`OCM_NODE_ENS1), 
	     .my_dst_header(my_dst_header), 
	     .nA_dst_header(nA_dst_header), 
	     .nB_dst_header(nB_dst_header), 
	     .my_addr_header_30(my_addr_header_30), 
	     .nA_addr_header_30(nA_addr_header_30), 
	     .nB_addr_header_30(nB_addr_header_30),
	     .my_addr_header_2916(my_addr_header_2916), 
	     .nA_addr_header_2916(nA_addr_header_2916), 
	     .nB_addr_header_2916(nB_addr_header_2916), 
	     .nA_node_name(nA_node_name), 
	     .nB_node_name(nB_node_name))
   the_ep_mD(
	     // Outputs
	     .ep0_inbox_read(ep0_inbox_read), //
	     .ep1_inbox_read(ep1_inbox_read), //
	     .ep2_inbox_read(ep2_inbox_read), //
	     .ep3_inbox_read(ep3_inbox_read), //
	     .ep0_to_se0_vc0_d(ep0_to_se0_vc0_d[121:0]), //
	     .ep0_to_se0_vc0_full(ep0_to_se0_vc0_full), //
	     .ep0_to_se1_vc0_d(ep0_to_se1_vc0_d[121:0]), //
	     .ep0_to_se1_vc0_full(ep0_to_se1_vc0_full), //
	     .ep0_to_se2_vc0_d(ep0_to_se2_vc0_d[121:0]), //
	     .ep0_to_se2_vc0_full(ep0_to_se2_vc0_full), //
	     .ep0_to_se3_vc0_d(ep0_to_se3_vc0_d[121:0]), //
	     .ep0_to_se3_vc0_full(ep0_to_se3_vc0_full), //
	     .ep1_to_se0_vc0_d(ep1_to_se0_vc0_d[121:0]), //
	     .ep1_to_se0_vc0_full(ep1_to_se0_vc0_full), //
	     .ep1_to_se1_vc0_d(ep1_to_se1_vc0_d[121:0]), //
	     .ep1_to_se1_vc0_full(ep1_to_se1_vc0_full), //
	     .ep1_to_se2_vc0_d(ep1_to_se2_vc0_d[121:0]), //
	     .ep1_to_se2_vc0_full(ep1_to_se2_vc0_full), //
	     .ep1_to_se3_vc0_d(ep1_to_se3_vc0_d[121:0]), //
	     .ep1_to_se3_vc0_full(ep1_to_se3_vc0_full), //
	     .ep2_to_se0_vc0_d(ep2_to_se0_vc0_d[121:0]), //
	     .ep2_to_se0_vc0_full(ep2_to_se0_vc0_full), //
	     .ep2_to_se1_vc0_d(ep2_to_se1_vc0_d[121:0]), //
	     .ep2_to_se1_vc0_full(ep2_to_se1_vc0_full), //
	     .ep2_to_se2_vc0_d(ep2_to_se2_vc0_d[121:0]), //
	     .ep2_to_se2_vc0_full(ep2_to_se2_vc0_full), //
	     .ep2_to_se3_vc0_d(ep2_to_se3_vc0_d[121:0]), //
	     .ep2_to_se3_vc0_full(ep2_to_se3_vc0_full), //
	     .ep3_to_se0_vc0_d(ep3_to_se0_vc0_d[121:0]), //
	     .ep3_to_se0_vc0_full(ep3_to_se0_vc0_full), //
	     .ep3_to_se1_vc0_d(ep3_to_se1_vc0_d[121:0]), //
	     .ep3_to_se1_vc0_full(ep3_to_se1_vc0_full), //
	     .ep3_to_se2_vc0_d(ep3_to_se2_vc0_d[121:0]), //
	     .ep3_to_se2_vc0_full(ep3_to_se2_vc0_full), //
	     .ep3_to_se3_vc0_d(ep3_to_se3_vc0_d[121:0]), //
	     .ep3_to_se3_vc0_full(ep3_to_se3_vc0_full), //
	     .ep0_inbox_vc0G_d(ep0_inbox_vc0G_d[121:0]), //
	     .ep0_inbox_vc0G_full(ep0_inbox_vc0G_full), //
	     .ep1_inbox_vc0G_d(ep1_inbox_vc0G_d[121:0]), //
	     .ep1_inbox_vc0G_full(ep1_inbox_vc0G_full), //
	     .ep2_inbox_vc0G_d(ep2_inbox_vc0G_d[121:0]), //
	     .ep2_inbox_vc0G_full(ep2_inbox_vc0G_full), //
	     .ep3_inbox_vc0G_d(ep3_inbox_vc0G_d[121:0]), //
	     .ep3_inbox_vc0G_full(ep3_inbox_vc0G_full), //
	     .ep0_inbox_vc1L_d(ep0_inbox_vc1L_d[121:0]),//
	     .ep0_inbox_vc1L_full(ep0_inbox_vc1L_full),//
	     .ep1_inbox_vc1L_d(ep1_inbox_vc1L_d[121:0]),//
	     .ep1_inbox_vc1L_full(ep1_inbox_vc1L_full),//
	     .ep2_inbox_vc1L_d(ep2_inbox_vc1L_d[121:0]),//
	     .ep2_inbox_vc1L_full(ep2_inbox_vc1L_full),//
	     .ep3_inbox_vc1L_d(ep3_inbox_vc1L_d[121:0]),//
	     .ep3_inbox_vc1L_full(ep3_inbox_vc1L_full),// 
	     .epe_1G_for_nA_vc1_r(epe_1G_for_nA_vc1_r),// 
	     .epe_1G_for_nA_vc1_d(epe_1G_for_nA_vc1_d[32:0]),// 
	     .epe_1G_for_nA_vc1_h(epe_1G_for_nA_vc1_h),// 
	     .epe_1G_for_nB_vc1_r(epe_1G_for_nB_vc1_r),// 
	     .epe_1G_for_nB_vc1_d(epe_1G_for_nB_vc1_d[32:0]),// 
	     .epe_1G_for_nB_vc1_h(epe_1G_for_nB_vc1_h),// 
	     .ep0_outbox(ep0_outbox[124:0]),// 
	     .ep1_outbox(ep1_outbox[124:0]),// 
	     .ep2_outbox(ep2_outbox[124:0]),// 
	     .ep3_outbox(ep3_outbox[124:0]),// 
			     .ep_nA_vc3_incoming_read(ep_nA_vc3_incoming_read),
			     .ep_nB_vc3_incoming_read(ep_nB_vc3_incoming_read),
	     .se0_for_ep0_vc3_gnt(se0_for_ep0_vc3_gnt), //
	     .se0_for_ep1_vc3_gnt(se0_for_ep1_vc3_gnt), //
	     .se0_for_ep2_vc3_gnt(se0_for_ep2_vc3_gnt), //
	     .se0_for_ep3_vc3_gnt(se0_for_ep3_vc3_gnt), //
	     .se1_for_ep0_vc3_gnt(se1_for_ep0_vc3_gnt), //
	     .se1_for_ep1_vc3_gnt(se1_for_ep1_vc3_gnt), //
	     .se1_for_ep2_vc3_gnt(se1_for_ep2_vc3_gnt), //
	     .se1_for_ep3_vc3_gnt(se1_for_ep3_vc3_gnt), //
	     .se2_for_ep0_vc3_gnt(se2_for_ep0_vc3_gnt), //
	     .se2_for_ep1_vc3_gnt(se2_for_ep1_vc3_gnt), //
	     .se2_for_ep2_vc3_gnt(se2_for_ep2_vc3_gnt), //
	     .se2_for_ep3_vc3_gnt(se2_for_ep3_vc3_gnt), //
	     .se3_for_ep0_vc3_gnt(se3_for_ep0_vc3_gnt), //
	     .se3_for_ep1_vc3_gnt(se3_for_ep1_vc3_gnt), //
	     .se3_for_ep2_vc3_gnt(se3_for_ep2_vc3_gnt), //
	     .se3_for_ep3_vc3_gnt(se3_for_ep3_vc3_gnt), //
			     .sm1L_for_ep0_gnt(sm1L_for_ep0_gnt),
			     .sm1L_for_ep1_gnt(sm1L_for_ep1_gnt),
			     .sm1L_for_ep2_gnt(sm1L_for_ep2_gnt),
			     .sm1L_for_ep3_gnt(sm1L_for_ep3_gnt),
			     // Inputs
			     .CLK	(CLK),
			     .rst	(rst),
			     .ep0_inbox	(ep0_inbox[124:0]), //
			     .ep1_inbox	(ep1_inbox[124:0]), //
			     .ep2_inbox	(ep2_inbox[124:0]), //
			     .ep3_inbox	(ep3_inbox[124:0]), //
			     .ep0_to_se0_vc0_read(ep0_to_se0_vc0_read), //
			     .ep0_to_se1_vc0_read(ep0_to_se1_vc0_read), //
			     .ep0_to_se2_vc0_read(ep0_to_se2_vc0_read), //
			     .ep0_to_se3_vc0_read(ep0_to_se3_vc0_read), //
			     .ep1_to_se0_vc0_read(ep1_to_se0_vc0_read), //
			     .ep1_to_se1_vc0_read(ep1_to_se1_vc0_read), //
			     .ep1_to_se2_vc0_read(ep1_to_se2_vc0_read), //
			     .ep1_to_se3_vc0_read(ep1_to_se3_vc0_read), //
			     .ep2_to_se0_vc0_read(ep2_to_se0_vc0_read), //
			     .ep2_to_se1_vc0_read(ep2_to_se1_vc0_read), //
			     .ep2_to_se2_vc0_read(ep2_to_se2_vc0_read), //
			     .ep2_to_se3_vc0_read(ep2_to_se3_vc0_read), //
			     .ep3_to_se0_vc0_read(ep3_to_se0_vc0_read), //
			     .ep3_to_se1_vc0_read(ep3_to_se1_vc0_read), //
			     .ep3_to_se2_vc0_read(ep3_to_se2_vc0_read), //
			     .ep3_to_se3_vc0_read(ep3_to_se3_vc0_read), //
			     .ep0_inbox_vc0G_read(ep0_inbox_vc0G_read),  //
			     .ep1_inbox_vc0G_read(ep1_inbox_vc0G_read), //
			     .ep2_inbox_vc0G_read(ep2_inbox_vc0G_read), //
			     .ep3_inbox_vc0G_read(ep3_inbox_vc0G_read), //
			     .ep0_inbox_vc1L_read(ep0_inbox_vc1L_read), //
			     .ep1_inbox_vc1L_read(ep1_inbox_vc1L_read), //
			     .ep2_inbox_vc1L_read(ep2_inbox_vc1L_read), //
			     .ep3_inbox_vc1L_read(ep3_inbox_vc1L_read), //
			     .epe_1G_for_nA_vc1_gnt(epe_1G_for_nA_vc1_gnt),//
			     .epe_1G_for_nB_vc1_gnt(epe_1G_for_nB_vc1_gnt),//
			     .ep0_outbox_read(ep0_outbox_read),//
			     .ep1_outbox_read(ep1_outbox_read),//
			     .ep2_outbox_read(ep2_outbox_read),//
			     .ep3_outbox_read(ep3_outbox_read),//
	     .ep_nA_vc3_incoming_d(ep_nA_vc3_incoming_d[32:0]), //
	     .ep_nA_vc3_incoming_e(ep_nA_vc3_incoming_e), //
	     .ep_nB_vc3_incoming_d(ep_nB_vc3_incoming_d[32:0]), //
	     .ep_nB_vc3_incoming_e(ep_nB_vc3_incoming_e), //
			     .se0_for_ep0_vc3_d(se0_for_ep0_vc3_d[121:0]), //
			     .se0_for_ep0_vc3_full(se0_for_ep0_vc3_full), //
			     .se0_for_ep1_vc3_d(se0_for_ep1_vc3_d[121:0]), //
			     .se0_for_ep1_vc3_full(se0_for_ep1_vc3_full), //
			     .se0_for_ep2_vc3_d(se0_for_ep2_vc3_d[121:0]), //
			     .se0_for_ep2_vc3_full(se0_for_ep2_vc3_full), //
			     .se0_for_ep3_vc3_d(se0_for_ep3_vc3_d[121:0]), //
			     .se0_for_ep3_vc3_full(se0_for_ep3_vc3_full), //
			     .se1_for_ep0_vc3_d(se1_for_ep0_vc3_d[121:0]), //
			     .se1_for_ep0_vc3_full(se1_for_ep0_vc3_full), //
			     .se1_for_ep1_vc3_d(se1_for_ep1_vc3_d[121:0]), //
			     .se1_for_ep1_vc3_full(se1_for_ep1_vc3_full), //
			     .se1_for_ep2_vc3_d(se1_for_ep2_vc3_d[121:0]), //
			     .se1_for_ep2_vc3_full(se1_for_ep2_vc3_full), //
			     .se1_for_ep3_vc3_d(se1_for_ep3_vc3_d[121:0]), //
			     .se1_for_ep3_vc3_full(se1_for_ep3_vc3_full), //
			     .se2_for_ep0_vc3_d(se2_for_ep0_vc3_d[121:0]), //
			     .se2_for_ep0_vc3_full(se2_for_ep0_vc3_full), //
			     .se2_for_ep1_vc3_d(se2_for_ep1_vc3_d[121:0]), //
			     .se2_for_ep1_vc3_full(se2_for_ep1_vc3_full), //
			     .se2_for_ep2_vc3_d(se2_for_ep2_vc3_d[121:0]), //
			     .se2_for_ep2_vc3_full(se2_for_ep2_vc3_full), //
			     .se2_for_ep3_vc3_d(se2_for_ep3_vc3_d[121:0]), //
			     .se2_for_ep3_vc3_full(se2_for_ep3_vc3_full), //
			     .se3_for_ep0_vc3_d(se3_for_ep0_vc3_d[121:0]), //
			     .se3_for_ep0_vc3_full(se3_for_ep0_vc3_full), //
			     .se3_for_ep1_vc3_d(se3_for_ep1_vc3_d[121:0]), //
			     .se3_for_ep1_vc3_full(se3_for_ep1_vc3_full), //
			     .se3_for_ep2_vc3_d(se3_for_ep2_vc3_d[121:0]), //
			     .se3_for_ep2_vc3_full(se3_for_ep2_vc3_full), //
			     .se3_for_ep3_vc3_d(se3_for_ep3_vc3_d[121:0]), //
			     .se3_for_ep3_vc3_full(se3_for_ep3_vc3_full), //
			     .sm1L_for_ep0_d(sm1L_for_ep0_d[121:0]), //
			     .sm1L_for_ep0_full(sm1L_for_ep0_full), //
			     .sm1L_for_ep1_d(sm1L_for_ep1_d[121:0]), //
			     .sm1L_for_ep1_full(sm1L_for_ep1_full), //
			     .sm1L_for_ep2_d(sm1L_for_ep2_d[121:0]), //
			     .sm1L_for_ep2_full(sm1L_for_ep2_full), //
			     .sm1L_for_ep3_d(sm1L_for_ep3_d[121:0]), //
			     .sm1L_for_ep3_full(sm1L_for_ep3_full)); //
   
   
   nie_sm1 #(.who_am_i(`OCM_NODE_ENS1), 
	     .my_dst_header(my_dst_header), 
	     .nA_dst_header(nA_dst_header), 
	     .nB_dst_header(nB_dst_header), 
	     .my_addr_header_30(my_addr_header_30), 
	     .nA_addr_header_30(nA_addr_header_30), 
	     .nB_addr_header_30(nB_addr_header_30),
	     .my_addr_header_2916(my_addr_header_2916), 
	     .nA_addr_header_2916(nA_addr_header_2916), 
	     .nB_addr_header_2916(nB_addr_header_2916), 
	     .nA_node_name(nA_node_name), 
	     .nB_node_name(nB_node_name))
   the_nie_sm1(/**/
	       // Outputs
	       .nie_sm1_for_nA_vc2_r	(nie_sm1_for_nA_vc2_r),
	       .nie_sm1_for_nA_vc2_h	(nie_sm1_for_nA_vc2_h),
	       .nie_sm1_for_nA_vc2_d	(nie_sm1_for_nA_vc2_d[32:0]),
	       .nie_sm1_for_nB_vc2_r	(nie_sm1_for_nB_vc2_r),
	       .nie_sm1_for_nB_vc2_h	(nie_sm1_for_nB_vc2_h),
	       .nie_sm1_for_nB_vc2_d	(nie_sm1_for_nB_vc2_d[32:0]),
	       .nie_sm1_for_nA_vc3_r	(nie_sm1_for_nA_vc3_r),
	       .nie_sm1_for_nA_vc3_h	(nie_sm1_for_nA_vc3_h),
	       .nie_sm1_for_nA_vc3_d	(nie_sm1_for_nA_vc3_d[32:0]),
	       .nie_sm1_for_nB_vc3_r	(nie_sm1_for_nB_vc3_r),
	       .nie_sm1_for_nB_vc3_h	(nie_sm1_for_nB_vc3_h),
	       .nie_sm1_for_nB_vc3_d	(nie_sm1_for_nB_vc3_d[32:0]),
	       .nA_vc1_incoming_read	(nA_vc1_incoming_read),
	       .nB_vc1_incoming_read	(nB_vc1_incoming_read),
	       .nie_sm1_mem_req		(nie_sm1_mem_req),
	       .nie_sm1_mem_wen_b	(nie_sm1_mem_wen_b),
	       .nie_sm1_mem_lock	(nie_sm1_mem_lock),
	       .nie_sm1_mem_addr	(nie_sm1_mem_addr[15:0]),
	       .nie_sm1_mem_write_data	(nie_sm1_mem_write_data[63:0]),
	       .nie_sm1_mem_write_mask	(nie_sm1_mem_write_mask[63:0]),
	       // Inputs
	       .CLK			(CLK),
	       .rst			(rst),
	       .nie_sm1_for_nA_vc2_gnt	(nie_sm1_for_nA_vc2_gnt),
	       .nie_sm1_for_nB_vc2_gnt	(nie_sm1_for_nB_vc2_gnt),
	       .nie_sm1_for_nA_vc3_gnt	(nie_sm1_for_nA_vc3_gnt),
	       .nie_sm1_for_nB_vc3_gnt	(nie_sm1_for_nB_vc3_gnt),
	       .nA_vc1_incoming_e	(nA_vc1_incoming_e),
	       .nA_vc1_incoming_d	(nA_vc1_incoming_d[32:0]),
	       .nB_vc1_incoming_e	(nB_vc1_incoming_e),
	       .nB_vc1_incoming_d	(nB_vc1_incoming_d[32:0]),
	       .nie_sm1_mem_read_data	(nie_sm1_mem_read_data[63:0]),
	       .nie_sm1_mem_gnt		(nie_sm1_mem_gnt));

   nie_sm2 #(.who_am_i(`OCM_NODE_ENS1), 
	     .my_dst_header(my_dst_header), 
	     .nA_dst_header(nA_dst_header), 
	     .nB_dst_header(nB_dst_header))
   the_nie_sm2(/**/
	       // Outputs
	       .nie_sm2_for_nA_vc3_r	(nie_sm2_for_nA_vc3_r),
	       .nie_sm2_for_nA_vc3_h	(nie_sm2_for_nA_vc3_h),
	       .nie_sm2_for_nA_vc3_d	(nie_sm2_for_nA_vc3_d[32:0]),
	       .nie_sm2_for_nB_vc3_r	(nie_sm2_for_nB_vc3_r),
	       .nie_sm2_for_nB_vc3_h	(nie_sm2_for_nB_vc3_h),
	       .nie_sm2_for_nB_vc3_d	(nie_sm2_for_nB_vc3_d[32:0]),
	       .nie_sm2_for_se0_vc3_r	(nie_sm2_for_se0_vc3_r),
	       .nie_sm2_for_se0_vc3_d	(nie_sm2_for_se0_vc3_d[32:0]),
	       .nie_sm2_for_se1_vc3_r	(nie_sm2_for_se1_vc3_r),
	       .nie_sm2_for_se1_vc3_d	(nie_sm2_for_se1_vc3_d[32:0]),
	       .nie_sm2_for_se2_vc3_r	(nie_sm2_for_se2_vc3_r),
	       .nie_sm2_for_se2_vc3_d	(nie_sm2_for_se2_vc3_d[32:0]),
	       .nie_sm2_for_se3_vc3_r	(nie_sm2_for_se3_vc3_r),
	       .nie_sm2_for_se3_vc3_d	(nie_sm2_for_se3_vc3_d[32:0]),
	       .nA_vc2_incoming_read	(nA_vc2_incoming_read),
	       .nB_vc2_incoming_read	(nB_vc2_incoming_read),
	       .nie_sm2_mem_req		(nie_sm2_mem_req),
	       .nie_sm2_mem_addr	(nie_sm2_mem_addr[15:0]),
	       .nie_sm2_mem_wen_b	(nie_sm2_mem_wen_b),
	       .nie_sm2_mem_wr_data	(nie_sm2_mem_write_data[63:0]),
	       .nie_sm2_mem_write_mask	(nie_sm2_mem_write_mask[63:0]),
	       // Inputs
	       .CLK			(CLK),
	       .rst			(rst),
	       .nie_sm2_for_nA_vc3_gnt	(nie_sm2_for_nA_vc3_gnt),
	       .nie_sm2_for_nB_vc3_gnt	(nie_sm2_for_nB_vc3_gnt),
	       .nie_sm2_for_se0_vc3_gnt	(nie_sm2_for_se0_vc3_gnt),
	       .nie_sm2_for_se1_vc3_gnt	(nie_sm2_for_se1_vc3_gnt),
	       .nie_sm2_for_se2_vc3_gnt	(nie_sm2_for_se2_vc3_gnt),
	       .nie_sm2_for_se3_vc3_gnt	(nie_sm2_for_se3_vc3_gnt),
	       .nA_vc2_incoming_e	(nA_vc2_incoming_e),
	       .nA_vc2_incoming_d	(nA_vc2_incoming_d[32:0]),
	       .nB_vc2_incoming_e	(nB_vc2_incoming_e),
	       .nB_vc2_incoming_d	(nB_vc2_incoming_d[32:0]),
	       .nie_sm2_mem_rd_data	(nie_sm2_mem_read_data[63:0]),
	       .nie_sm2_mem_gnt		(nie_sm2_mem_gnt));

   wire 		epe_sm0g_for_nA_vc0_r;
   wire 		epe_sm0g_for_nA_vc0_h;
   wire [32:0] 		epe_sm0g_for_nA_vc0_d;
      wire 		epe_sm0g_for_nB_vc0_r;
   wire 		epe_sm0g_for_nB_vc0_h;
   wire [32:0] 		epe_sm0g_for_nB_vc0_d;
   wire 		epe_sm0g_for_nA_vc0_gnt;
   wire 		epe_sm0g_for_nB_vc0_gnt;
   wire 		epe_sm0_mem_req;
      wire 		epe_sm0_mem_lock;
   wire 		epe_sm0_mem_wen_b;
   wire [15:0] 		epe_sm0_mem_addr;
   wire [63:0] 		epe_sm0_mem_write_data;
   wire [63:0] 		epe_sm0_mem_write_mask;
   wire [63:0] 		epe_sm0_mem_read_data;
   wire 		epe_sm0_mem_gnt;
   
   epe_sm0 #(.who_am_i(`OCM_NODE_ENS1), 
	     .my_dst_header(my_dst_header), 
	     .nA_dst_header(nA_dst_header), 
	     .nB_dst_header(nB_dst_header), 
	     .my_addr_header_30(my_addr_header_30), 
	     .nA_addr_header_30(nA_addr_header_30), 
	     .nB_addr_header_30(nB_addr_header_30),
	     .my_addr_header_2916(my_addr_header_2916), 
	     .nA_addr_header_2916(nA_addr_header_2916), 
	     .nB_addr_header_2916(nB_addr_header_2916), 
	     .nA_node_name(nA_node_name), 
	     .nB_node_name(nB_node_name))
   the_epe_sm0(/**/
	       // Outputs
	       .epe_sm0_for_nA_vc0_r	(epe_sm0g_for_nA_vc0_r),
	       .epe_sm0_for_nA_vc0_h	(epe_sm0g_for_nA_vc0_h),
	       .epe_sm0_for_nA_vc0_d	(epe_sm0g_for_nA_vc0_d[32:0]),
	       .epe_sm0_for_nB_vc0_r	(epe_sm0g_for_nB_vc0_r),
	       .epe_sm0_for_nB_vc0_h	(epe_sm0g_for_nB_vc0_h),
	       .epe_sm0_for_nB_vc0_d	(epe_sm0g_for_nB_vc0_d[32:0]),
	       .ep0_inbox_read		(ep0_inbox_vc0G_read),
	       .ep1_inbox_read		(ep1_inbox_vc0G_read),
	       .ep2_inbox_read		(ep2_inbox_vc0G_read),
	       .ep3_inbox_read		(ep3_inbox_vc0G_read),
	       .epe_sm0_mem_req		(epe_sm0_mem_req),
	       .epe_sm0_mem_wen_b	(epe_sm0_mem_wen_b),
	       .epe_sm0_mem_lock	(epe_sm0_mem_lock),
	       .epe_sm0_mem_addr	(epe_sm0_mem_addr[15:0]),
	       .epe_sm0_mem_write_data	(epe_sm0_mem_write_data[63:0]),
	       .epe_sm0_mem_write_mask	(epe_sm0_mem_write_mask[63:0]),
	       // Inputs
	       .CLK			(CLK),
	       .rst			(rst),
	       .epe_sm0_for_nA_vc0_gnt	(epe_sm0g_for_nA_vc0_gnt),
	       .epe_sm0_for_nB_vc0_gnt	(epe_sm0g_for_nB_vc0_gnt),
	       .ep0_inbox_full		(ep0_inbox_vc0G_full),
	       .ep0_inbox_d		(ep0_inbox_vc0G_d[121:0]),
	       .ep1_inbox_full		(ep1_inbox_vc0G_full),
	       .ep1_inbox_d		(ep1_inbox_vc0G_d[121:0]),
	       .ep2_inbox_full		(ep2_inbox_vc0G_full),
	       .ep2_inbox_d		(ep2_inbox_vc0G_d[121:0]),
	       .ep3_inbox_full		(ep3_inbox_vc0G_full),
	       .ep3_inbox_d		(ep3_inbox_vc0G_d[121:0]),
	       .epe_sm0_mem_read_data	(epe_sm0_mem_read_data[63:0]),
	       .epe_sm0_mem_gnt		(epe_sm0_mem_gnt));

   wire 		epe_sm1_mem_req;
   wire 		epe_sm1_mem_lock;
   wire 		epe_sm1_mem_wen_b;
   wire [15:0] 		epe_sm1_mem_addr;
   wire [63:0] 		epe_sm1_mem_write_data;
   wire [63:0] 		epe_sm1_mem_write_mask;
   wire [63:0] 		epe_sm1_mem_read_data;
   wire 		epe_sm1_mem_gnt;

   epe_sm1 #(.who_am_i(`OCM_NODE_ENS1), 
	     .my_dst_header(my_dst_header), 
	     .nA_dst_header(nA_dst_header), 
	     .nB_dst_header(nB_dst_header), 
	     .my_addr_header_30(my_addr_header_30), 
	     .nA_addr_header_30(nA_addr_header_30), 
	     .nB_addr_header_30(nB_addr_header_30),
	     .my_addr_header_2916(my_addr_header_2916), 
	     .nA_addr_header_2916(nA_addr_header_2916), 
	     .nB_addr_header_2916(nB_addr_header_2916), 
	     .nA_node_name(nA_node_name), 
	     .nB_node_name(nB_node_name))
   the_epe_sm1(/**/
	       // Outputs
	       .ep0_outbox_d		(sm1L_for_ep0_d[121:0]),
	       .ep0_outbox_full		(sm1L_for_ep0_full),
	       .ep1_outbox_d		(sm1L_for_ep1_d[121:0]),
	       .ep1_outbox_full		(sm1L_for_ep1_full),
	       .ep2_outbox_d		(sm1L_for_ep2_d[121:0]),
	       .ep2_outbox_full		(sm1L_for_ep2_full),
	       .ep3_outbox_d		(sm1L_for_ep3_d[121:0]),
	       .ep3_outbox_full		(sm1L_for_ep3_full),
	       .ep0_inbox_read		(ep0_inbox_vc1L_read),
	       .ep1_inbox_read		(ep1_inbox_vc1L_read),
	       .ep2_inbox_read		(ep2_inbox_vc1L_read),
	       .ep3_inbox_read		(ep3_inbox_vc1L_read),
	       .epe_sm1_mem_req		(epe_sm1_mem_req),
	       .epe_sm1_mem_wen_b	(epe_sm1_mem_wen_b),
	       .epe_sm1_mem_lock	(epe_sm1_mem_lock),
	       .epe_sm1_mem_addr	(epe_sm1_mem_addr[15:0]),
	       .epe_sm1_mem_write_data	(epe_sm1_mem_write_data[63:0]),
	       .epe_sm1_mem_write_mask	(epe_sm1_mem_write_mask[63:0]),
	       // Inputs
	       .CLK			(CLK),
	       .rst			(rst),
	       .ep0_outbox_gnt		(sm1L_for_ep0_gnt),
	       .ep1_outbox_gnt		(sm1L_for_ep1_gnt),
	       .ep2_outbox_gnt		(sm1L_for_ep2_gnt),
	       .ep3_outbox_gnt		(sm1L_for_ep3_gnt),
	       .ep0_inbox_full		(ep0_inbox_vc1L_full),
	       .ep0_inbox_d		(ep0_inbox_vc1L_d[121:0]),
	       .ep1_inbox_full		(ep1_inbox_vc1L_full),
	       .ep1_inbox_d		(ep1_inbox_vc1L_d[121:0]),
	       .ep2_inbox_full		(ep2_inbox_vc1L_full),
	       .ep2_inbox_d		(ep2_inbox_vc1L_d[121:0]),
	       .ep3_inbox_full		(ep3_inbox_vc1L_full),
	       .ep3_inbox_d		(ep3_inbox_vc1L_d[121:0]),
	       .epe_sm1_mem_read_data	(epe_sm1_mem_read_data[63:0]),
	       .epe_sm1_mem_gnt		(epe_sm1_mem_gnt));

    
   se #(.who_am_i(`OCM_NODE_E0_SD0), 
	.my_dst_header(my_dst_header), 
	.nA_dst_header(nA_dst_header), 
	.nB_dst_header(nB_dst_header), 
	.my_addr_header_30(my_addr_header_30), 
	.nA_addr_header_30(nA_addr_header_30), 
	.nB_addr_header_30(nB_addr_header_30),
	.my_addr_header_2916(my_addr_header_2916), 
	.nA_addr_header_2916(nA_addr_header_2916), 
	.nB_addr_header_2916(nB_addr_header_2916), 
	.nA_node_name(nA_node_name), 
	.nB_node_name(nB_node_name))
   se0(/**/
       // Outputs
       .ep0_to_se_vc0_read		(ep0_to_se0_vc0_read), //
       .ep1_to_se_vc0_read		(ep1_to_se0_vc0_read), //
       .ep2_to_se_vc0_read		(ep2_to_se0_vc0_read), //
       .ep3_to_se_vc0_read		(ep3_to_se0_vc0_read), //
       .nA_vc0_incoming_read		(se0_nA_vc0_incoming_read),
       .nB_vc0_incoming_read		(se0_nB_vc0_incoming_read),
       .nA_vc3_incoming_read		(se0_nA_vc3_incoming_read),
       .nB_vc3_incoming_read		(se0_nB_vc3_incoming_read),
       .se_for_nA_vc1_r			(se0_for_nA_vc1_r),
       .se_for_nA_vc1_h			(se0_for_nA_vc1_h),
       .se_for_nA_vc1_d			(se0_for_nA_vc1_d[32:0]),
       .se_for_nB_vc1_r			(se0_for_nB_vc1_r),
       .se_for_nB_vc1_h			(se0_for_nB_vc1_h),
       .se_for_nB_vc1_d			(se0_for_nB_vc1_d[32:0]),
       .se_for_ep0_vc3_d		(se0_for_ep0_vc3_d[121:0]),
       .se_for_ep0_vc3_full		(se0_for_ep0_vc3_full),
       .se_for_ep1_vc3_d		(se0_for_ep1_vc3_d[121:0]),
       .se_for_ep1_vc3_full		(se0_for_ep1_vc3_full),
       .se_for_ep2_vc3_d		(se0_for_ep2_vc3_d[121:0]),
       .se_for_ep2_vc3_full		(se0_for_ep2_vc3_full),
       .se_for_ep3_vc3_d		(se0_for_ep3_vc3_d[121:0]),
       .se_for_ep3_vc3_full		(se0_for_ep3_vc3_full),
       .se_for_nA_vc3_r			(se0_for_nA_vc3_r),
       .se_for_nA_vc3_h			(se0_for_nA_vc3_h),
       .se_for_nA_vc3_d			(se0_for_nA_vc3_d[32:0]),
       .se_for_nB_vc3_r			(se0_for_nB_vc3_r),
       .se_for_nB_vc3_h			(se0_for_nB_vc3_h),
       .se_for_nB_vc3_d			(se0_for_nB_vc3_d[32:0]),
       .se_mem_req			(se0_mem_req),
       .se_mem_wen_b			(se0_mem_wen_b),
       .se_mem_addr			(se0_mem_addr[15:0]),
       .se_mem_write_data		(se0_mem_write_data[63:0]),
       .se_mem_write_mask		(se0_mem_write_mask[63:0]),
       // Inputs
       .CLK				(CLK),
       .rst				(rst),
       .ep0_to_se_vc0_d			(ep0_to_se0_vc0_d[121:0]), //
       .ep0_to_se_vc0_full		(ep0_to_se0_vc0_full), //
       .ep1_to_se_vc0_full		(ep1_to_se0_vc0_full), //
       .ep1_to_se_vc0_d			(ep1_to_se0_vc0_d[121:0]), //
       .ep2_to_se_vc0_full		(ep2_to_se0_vc0_full), //
       .ep2_to_se_vc0_d			(ep2_to_se0_vc0_d[121:0]), //
       .ep3_to_se_vc0_full		(ep3_to_se0_vc0_full), //
       .ep3_to_se_vc0_d			(ep3_to_se0_vc0_d[121:0]), //
       .nA_vc0_incoming_e		(se0_nA_vc0_incoming_e),
       .nA_vc0_incoming_d		(se0_nA_vc0_incoming_d[32:0]),
       .nB_vc0_incoming_e		(se0_nB_vc0_incoming_e),
       .nB_vc0_incoming_d		(se0_nB_vc0_incoming_d[32:0]),
       .nA_vc3_incoming_e		(se0_nA_vc3_incoming_e),
       .nA_vc3_incoming_d		(se0_nA_vc3_incoming_d[32:0]),
       .nB_vc3_incoming_e		(se0_nB_vc3_incoming_e),
       .nB_vc3_incoming_d		(se0_nB_vc3_incoming_d[32:0]),
       .se_for_nA_vc1_gnt		(se0_for_nA_vc1_gnt),
       .se_for_nB_vc1_gnt		(se0_for_nB_vc1_gnt),
       .se_for_ep0_vc3_gnt		(se0_for_ep0_vc3_gnt), //
       .se_for_ep1_vc3_gnt		(se0_for_ep1_vc3_gnt), //
       .se_for_ep2_vc3_gnt		(se0_for_ep2_vc3_gnt), //
       .se_for_ep3_vc3_gnt		(se0_for_ep3_vc3_gnt), //
       .se_for_nA_vc3_gnt		(se0_for_nA_vc3_gnt),
       .se_for_nB_vc3_gnt		(se0_for_nB_vc3_gnt),
       .se_mem_read_data		(se0_mem_read_data[63:0]),
       .se_mem_gnt			(se0_mem_gnt));
   
   se #(.who_am_i(`OCM_NODE_E0_SD1), 
	.my_dst_header(my_dst_header), 
	.nA_dst_header(nA_dst_header), 
	.nB_dst_header(nB_dst_header), 
	.my_addr_header_30(my_addr_header_30), 
	.nA_addr_header_30(nA_addr_header_30), 
	.nB_addr_header_30(nB_addr_header_30),
	.my_addr_header_2916(my_addr_header_2916), 
	.nA_addr_header_2916(nA_addr_header_2916), 
	.nB_addr_header_2916(nB_addr_header_2916), 
	.nA_node_name(nA_node_name), 
	.nB_node_name(nB_node_name))
   se1(/**/
       // Outputs
       .ep0_to_se_vc0_read		(ep0_to_se1_vc0_read),
       .ep1_to_se_vc0_read		(ep1_to_se1_vc0_read),
       .ep2_to_se_vc0_read		(ep2_to_se1_vc0_read),
       .ep3_to_se_vc0_read		(ep3_to_se1_vc0_read),
       .nA_vc0_incoming_read		(se1_nA_vc0_incoming_read),
       .nB_vc0_incoming_read		(se1_nB_vc0_incoming_read),
       .nA_vc3_incoming_read		(se1_nA_vc3_incoming_read),
       .nB_vc3_incoming_read		(se1_nB_vc3_incoming_read),
       .se_for_nA_vc1_r			(se1_for_nA_vc1_r),
       .se_for_nA_vc1_h			(se1_for_nA_vc1_h),
       .se_for_nA_vc1_d			(se1_for_nA_vc1_d[32:0]),
       .se_for_nB_vc1_r			(se1_for_nB_vc1_r),
       .se_for_nB_vc1_h			(se1_for_nB_vc1_h),
       .se_for_nB_vc1_d			(se1_for_nB_vc1_d[32:0]),
       .se_for_ep0_vc3_d		(se1_for_ep0_vc3_d[121:0]),
       .se_for_ep0_vc3_full		(se1_for_ep0_vc3_full),
       .se_for_ep1_vc3_d		(se1_for_ep1_vc3_d[121:0]),
       .se_for_ep1_vc3_full		(se1_for_ep1_vc3_full),
       .se_for_ep2_vc3_d		(se1_for_ep2_vc3_d[121:0]),
       .se_for_ep2_vc3_full		(se1_for_ep2_vc3_full),
       .se_for_ep3_vc3_d		(se1_for_ep3_vc3_d[121:0]),
       .se_for_ep3_vc3_full		(se1_for_ep3_vc3_full),
       .se_for_nA_vc3_r			(se1_for_nA_vc3_r),
       .se_for_nA_vc3_h			(se1_for_nA_vc3_h),
       .se_for_nA_vc3_d			(se1_for_nA_vc3_d[32:0]),
       .se_for_nB_vc3_r			(se1_for_nB_vc3_r),
       .se_for_nB_vc3_h			(se1_for_nB_vc3_h),
       .se_for_nB_vc3_d			(se1_for_nB_vc3_d[32:0]),
       .se_mem_req			(se1_mem_req),
       .se_mem_wen_b			(se1_mem_wen_b),
       .se_mem_addr			(se1_mem_addr[15:0]),
       .se_mem_write_data		(se1_mem_write_data[63:0]),
       .se_mem_write_mask		(se1_mem_write_mask[63:0]),
       // Inputs
       .CLK				(CLK),
       .rst				(rst),
       .ep0_to_se_vc0_d			(ep0_to_se1_vc0_d[121:0]),
       .ep0_to_se_vc0_full		(ep0_to_se1_vc0_full),
       .ep1_to_se_vc0_full		(ep1_to_se1_vc0_full),
       .ep1_to_se_vc0_d			(ep1_to_se1_vc0_d[121:0]),
       .ep2_to_se_vc0_full		(ep2_to_se1_vc0_full),
       .ep2_to_se_vc0_d			(ep2_to_se1_vc0_d[121:0]),
       .ep3_to_se_vc0_full		(ep3_to_se1_vc0_full),
       .ep3_to_se_vc0_d			(ep3_to_se1_vc0_d[121:0]),
       .nA_vc0_incoming_e		(se1_nA_vc0_incoming_e),
       .nA_vc0_incoming_d		(se1_nA_vc0_incoming_d[32:0]),
       .nB_vc0_incoming_e		(se1_nB_vc0_incoming_e),
       .nB_vc0_incoming_d		(se1_nB_vc0_incoming_d[32:0]),
       .nA_vc3_incoming_e		(se1_nA_vc3_incoming_e),
       .nA_vc3_incoming_d		(se1_nA_vc3_incoming_d[32:0]),
       .nB_vc3_incoming_e		(se1_nB_vc3_incoming_e),
       .nB_vc3_incoming_d		(se1_nB_vc3_incoming_d[32:0]),
       .se_for_nA_vc1_gnt		(se1_for_nA_vc1_gnt),
       .se_for_nB_vc1_gnt		(se1_for_nB_vc1_gnt),
       .se_for_ep0_vc3_gnt		(se1_for_ep0_vc3_gnt),
       .se_for_ep1_vc3_gnt		(se1_for_ep1_vc3_gnt),
       .se_for_ep2_vc3_gnt		(se1_for_ep2_vc3_gnt),
       .se_for_ep3_vc3_gnt		(se1_for_ep3_vc3_gnt),
       .se_for_nA_vc3_gnt		(se1_for_nA_vc3_gnt),
       .se_for_nB_vc3_gnt		(se1_for_nB_vc3_gnt),
       .se_mem_read_data		(se1_mem_read_data[63:0]),
       .se_mem_gnt			(se1_mem_gnt));
   
   se #(.who_am_i(`OCM_NODE_E0_SD2), 
	.my_dst_header(my_dst_header), 
	.nA_dst_header(nA_dst_header), 
	.nB_dst_header(nB_dst_header), 
	.my_addr_header_30(my_addr_header_30), 
	.nA_addr_header_30(nA_addr_header_30), 
	.nB_addr_header_30(nB_addr_header_30),
	.my_addr_header_2916(my_addr_header_2916), 
	.nA_addr_header_2916(nA_addr_header_2916), 
	.nB_addr_header_2916(nB_addr_header_2916), 
	.nA_node_name(nA_node_name), 
	.nB_node_name(nB_node_name))
   se2(/**/
       // Outputs
       .ep0_to_se_vc0_read		(ep0_to_se2_vc0_read),
       .ep1_to_se_vc0_read		(ep1_to_se2_vc0_read),
       .ep2_to_se_vc0_read		(ep2_to_se2_vc0_read),
       .ep3_to_se_vc0_read		(ep3_to_se2_vc0_read),
       .nA_vc0_incoming_read		(se2_nA_vc0_incoming_read),
       .nB_vc0_incoming_read		(se2_nB_vc0_incoming_read),
       .nA_vc3_incoming_read		(se2_nA_vc3_incoming_read),
       .nB_vc3_incoming_read		(se2_nB_vc3_incoming_read),
       .se_for_nA_vc1_r			(se2_for_nA_vc1_r),
       .se_for_nA_vc1_h			(se2_for_nA_vc1_h),
       .se_for_nA_vc1_d			(se2_for_nA_vc1_d[32:0]),
       .se_for_nB_vc1_r			(se2_for_nB_vc1_r),
       .se_for_nB_vc1_h			(se2_for_nB_vc1_h),
       .se_for_nB_vc1_d			(se2_for_nB_vc1_d[32:0]),
       .se_for_ep0_vc3_d		(se2_for_ep0_vc3_d[121:0]),
       .se_for_ep0_vc3_full		(se2_for_ep0_vc3_full),
       .se_for_ep1_vc3_d		(se2_for_ep1_vc3_d[121:0]),
       .se_for_ep1_vc3_full		(se2_for_ep1_vc3_full),
       .se_for_ep2_vc3_d		(se2_for_ep2_vc3_d[121:0]),
       .se_for_ep2_vc3_full		(se2_for_ep2_vc3_full),
       .se_for_ep3_vc3_d		(se2_for_ep3_vc3_d[121:0]),
       .se_for_ep3_vc3_full		(se2_for_ep3_vc3_full),
       .se_for_nA_vc3_r			(se2_for_nA_vc3_r),
       .se_for_nA_vc3_h			(se2_for_nA_vc3_h),
       .se_for_nA_vc3_d			(se2_for_nA_vc3_d[32:0]),
       .se_for_nB_vc3_r			(se2_for_nB_vc3_r),
       .se_for_nB_vc3_h			(se2_for_nB_vc3_h),
       .se_for_nB_vc3_d			(se2_for_nB_vc3_d[32:0]),
       .se_mem_req			(se2_mem_req),
       .se_mem_wen_b			(se2_mem_wen_b),
       .se_mem_addr			(se2_mem_addr[15:0]),
       .se_mem_write_data		(se2_mem_write_data[63:0]),
       .se_mem_write_mask		(se2_mem_write_mask[63:0]),
       // Inputs
       .CLK				(CLK),
       .rst				(rst),
       .ep0_to_se_vc0_d			(ep0_to_se2_vc0_d[121:0]),
       .ep0_to_se_vc0_full		(ep0_to_se2_vc0_full),
       .ep1_to_se_vc0_full		(ep1_to_se2_vc0_full),
       .ep1_to_se_vc0_d			(ep1_to_se2_vc0_d[121:0]),
       .ep2_to_se_vc0_full		(ep2_to_se2_vc0_full),
       .ep2_to_se_vc0_d			(ep2_to_se2_vc0_d[121:0]),
       .ep3_to_se_vc0_full		(ep3_to_se2_vc0_full),
       .ep3_to_se_vc0_d			(ep3_to_se2_vc0_d[121:0]),
       .nA_vc0_incoming_e		(se2_nA_vc0_incoming_e),
       .nA_vc0_incoming_d		(se2_nA_vc0_incoming_d[32:0]),
       .nB_vc0_incoming_e		(se2_nB_vc0_incoming_e),
       .nB_vc0_incoming_d		(se2_nB_vc0_incoming_d[32:0]),
       .nA_vc3_incoming_e		(se2_nA_vc3_incoming_e),
       .nA_vc3_incoming_d		(se2_nA_vc3_incoming_d[32:0]),
       .nB_vc3_incoming_e		(se2_nB_vc3_incoming_e),
       .nB_vc3_incoming_d		(se2_nB_vc3_incoming_d[32:0]),
       .se_for_nA_vc1_gnt		(se2_for_nA_vc1_gnt),
       .se_for_nB_vc1_gnt		(se2_for_nB_vc1_gnt),
       .se_for_ep0_vc3_gnt		(se2_for_ep0_vc3_gnt),
       .se_for_ep1_vc3_gnt		(se2_for_ep1_vc3_gnt),
       .se_for_ep2_vc3_gnt		(se2_for_ep2_vc3_gnt),
       .se_for_ep3_vc3_gnt		(se2_for_ep3_vc3_gnt),
       .se_for_nA_vc3_gnt		(se2_for_nA_vc3_gnt),
       .se_for_nB_vc3_gnt		(se2_for_nB_vc3_gnt),
       .se_mem_read_data		(se2_mem_read_data[63:0]),
       .se_mem_gnt			(se2_mem_gnt));

   se #(.who_am_i(`OCM_NODE_E0_SD3), 
	.my_dst_header(my_dst_header), 
	.nA_dst_header(nA_dst_header), 
	.nB_dst_header(nB_dst_header), 
	.my_addr_header_30(my_addr_header_30), 
	.nA_addr_header_30(nA_addr_header_30), 
	.nB_addr_header_30(nB_addr_header_30),
	.my_addr_header_2916(my_addr_header_2916), 
	.nA_addr_header_2916(nA_addr_header_2916), 
	.nB_addr_header_2916(nB_addr_header_2916), 
	.nA_node_name(nA_node_name), 
	.nB_node_name(nB_node_name))
   se3(/**/
       // Outputs
       .ep0_to_se_vc0_read		(ep0_to_se3_vc0_read),
       .ep1_to_se_vc0_read		(ep1_to_se3_vc0_read),
       .ep2_to_se_vc0_read		(ep2_to_se3_vc0_read),
       .ep3_to_se_vc0_read		(ep3_to_se3_vc0_read),
       .nA_vc0_incoming_read		(se3_nA_vc0_incoming_read),
       .nB_vc0_incoming_read		(se3_nB_vc0_incoming_read),
       .nA_vc3_incoming_read		(se3_nA_vc3_incoming_read),
       .nB_vc3_incoming_read		(se3_nB_vc3_incoming_read),
       .se_for_nA_vc1_r			(se3_for_nA_vc1_r),
       .se_for_nA_vc1_h			(se3_for_nA_vc1_h),
       .se_for_nA_vc1_d			(se3_for_nA_vc1_d[32:0]),
       .se_for_nB_vc1_r			(se3_for_nB_vc1_r),
       .se_for_nB_vc1_h			(se3_for_nB_vc1_h),
       .se_for_nB_vc1_d			(se3_for_nB_vc1_d[32:0]),
       .se_for_ep0_vc3_d		(se3_for_ep0_vc3_d[121:0]),
       .se_for_ep0_vc3_full		(se3_for_ep0_vc3_full),
       .se_for_ep1_vc3_d		(se3_for_ep1_vc3_d[121:0]),
       .se_for_ep1_vc3_full		(se3_for_ep1_vc3_full),
       .se_for_ep2_vc3_d		(se3_for_ep2_vc3_d[121:0]),
       .se_for_ep2_vc3_full		(se3_for_ep2_vc3_full),
       .se_for_ep3_vc3_d		(se3_for_ep3_vc3_d[121:0]),
       .se_for_ep3_vc3_full		(se3_for_ep3_vc3_full),
       .se_for_nA_vc3_r			(se3_for_nA_vc3_r),
       .se_for_nA_vc3_h			(se3_for_nA_vc3_h),
       .se_for_nA_vc3_d			(se3_for_nA_vc3_d[32:0]),
       .se_for_nB_vc3_r			(se3_for_nB_vc3_r),
       .se_for_nB_vc3_h			(se3_for_nB_vc3_h),
       .se_for_nB_vc3_d			(se3_for_nB_vc3_d[32:0]),
       .se_mem_req			(se3_mem_req),
       .se_mem_wen_b			(se3_mem_wen_b),
       .se_mem_addr			(se3_mem_addr[15:0]),
       .se_mem_write_data		(se3_mem_write_data[63:0]),
       .se_mem_write_mask		(se3_mem_write_mask[63:0]),
       // Inputs
       .CLK				(CLK),
       .rst				(rst),
       .ep0_to_se_vc0_d			(ep0_to_se3_vc0_d[121:0]),
       .ep0_to_se_vc0_full		(ep0_to_se3_vc0_full),
       .ep1_to_se_vc0_full		(ep1_to_se3_vc0_full),
       .ep1_to_se_vc0_d			(ep1_to_se3_vc0_d[121:0]),
       .ep2_to_se_vc0_full		(ep2_to_se3_vc0_full),
       .ep2_to_se_vc0_d			(ep2_to_se3_vc0_d[121:0]),
       .ep3_to_se_vc0_full		(ep3_to_se3_vc0_full),
       .ep3_to_se_vc0_d			(ep3_to_se3_vc0_d[121:0]),
       .nA_vc0_incoming_e		(se3_nA_vc0_incoming_e),
       .nA_vc0_incoming_d		(se3_nA_vc0_incoming_d[32:0]),
       .nB_vc0_incoming_e		(se3_nB_vc0_incoming_e),
       .nB_vc0_incoming_d		(se3_nB_vc0_incoming_d[32:0]),
       .nA_vc3_incoming_e		(se3_nA_vc3_incoming_e),
       .nA_vc3_incoming_d		(se3_nA_vc3_incoming_d[32:0]),
       .nB_vc3_incoming_e		(se3_nB_vc3_incoming_e),
       .nB_vc3_incoming_d		(se3_nB_vc3_incoming_d[32:0]),
       .se_for_nA_vc1_gnt		(se3_for_nA_vc1_gnt),
       .se_for_nB_vc1_gnt		(se3_for_nB_vc1_gnt),
       .se_for_ep0_vc3_gnt		(se3_for_ep0_vc3_gnt),
       .se_for_ep1_vc3_gnt		(se3_for_ep1_vc3_gnt),
       .se_for_ep2_vc3_gnt		(se3_for_ep2_vc3_gnt),
       .se_for_ep3_vc3_gnt		(se3_for_ep3_vc3_gnt),
       .se_for_nA_vc3_gnt		(se3_for_nA_vc3_gnt),
       .se_for_nB_vc3_gnt		(se3_for_nB_vc3_gnt),
       .se_mem_read_data		(se3_mem_read_data[63:0]),
       .se_mem_gnt			(se3_mem_gnt));

   all_port_ni the_ni(/**/
		      // Outputs
		      .gated_outgoing_A	(gated_outgoing_A[34:0]),
		      .ungated_outgoing_A(ungated_outgoing_A[4:0]),
		      .gated_outgoing_B	(gated_outgoing_B[34:0]),
		      .ungated_outgoing_B(ungated_outgoing_B[4:0]),
		      .epe_sm0g_for_nA_vc0_gnt(epe_sm0g_for_nA_vc0_gnt),
		      .epe_sm0g_for_nB_vc0_gnt(epe_sm0g_for_nB_vc0_gnt),
		      .epe_1g_for_nA_vc1_gnt(epe_1G_for_nA_vc1_gnt),
		      .see_for_nA_vc1_gnt(see_for_nA_vc1_gnt),
		      .epe_1g_for_nB_vc1_gnt(epe_1G_for_nB_vc1_gnt),
		      .see_for_nB_vc1_gnt(see_for_nB_vc1_gnt),
		      .nie_sm1_for_nA_vc2_gnt(nie_sm1_for_nA_vc2_gnt),
		      .nie_sm1_for_nB_vc2_gnt(nie_sm1_for_nB_vc2_gnt),
		      .see_for_nA_vc3_gnt(see_for_nA_vc3_gnt),
		      .nie_sm1_for_nA_vc3_gnt(nie_sm1_for_nA_vc3_gnt),
		      .nie_sm2_for_nA_vc3_gnt(nie_sm2_for_nA_vc3_gnt),
		      .see_for_nB_vc3_gnt(see_for_nB_vc3_gnt),
		      .nie_sm1_for_nB_vc3_gnt(nie_sm1_for_nB_vc3_gnt),
		      .nie_sm2_for_nB_vc3_gnt(nie_sm2_for_nB_vc3_gnt),
		      .nA_vc0_incoming_d(nA_vc0_incoming_d[32:0]),
		      .nA_vc1_incoming_d(nA_vc1_incoming_d[32:0]),
		      .nA_vc2_incoming_d(nA_vc2_incoming_d[32:0]),
		      .nA_vc3_incoming_d(nA_vc3_incoming_d[32:0]),
		      .nB_vc0_incoming_d(nB_vc0_incoming_d[32:0]),
		      .nB_vc1_incoming_d(nB_vc1_incoming_d[32:0]),
		      .nB_vc2_incoming_d(nB_vc2_incoming_d[32:0]),
		      .nB_vc3_incoming_d(nB_vc3_incoming_d[32:0]),
		      .nA_vc0_incoming_e(nA_vc0_incoming_e),
		      .nA_vc1_incoming_e(nA_vc1_incoming_e),
		      .nA_vc2_incoming_e(nA_vc2_incoming_e),
		      .nA_vc3_incoming_e(nA_vc3_incoming_e),
		      .nB_vc0_incoming_e(nB_vc0_incoming_e),
		      .nB_vc1_incoming_e(nB_vc1_incoming_e),
		      .nB_vc2_incoming_e(nB_vc2_incoming_e),
		      .nB_vc3_incoming_e(nB_vc3_incoming_e),
		      // Inputs
		      .CLK		(CLK),
		      .rst		(rst),
		      .gated_incoming_A	(gated_incoming_A[34:0]),
		      .ungated_incoming_A(ungated_incoming_A[4:0]),
		      .gated_incoming_B	(gated_incoming_B[34:0]),
		      .ungated_incoming_B(ungated_incoming_B[4:0]),
		      .epe_sm0g_for_nA_vc0_r(epe_sm0g_for_nA_vc0_r),
		      .epe_sm0g_for_nA_vc0_h(epe_sm0g_for_nA_vc0_h),
		      .epe_sm0g_for_nA_vc0_d(epe_sm0g_for_nA_vc0_d[32:0]),
		      .epe_sm0g_for_nB_vc0_r(epe_sm0g_for_nB_vc0_r),
		      .epe_sm0g_for_nB_vc0_h(epe_sm0g_for_nB_vc0_h),
		      .epe_sm0g_for_nB_vc0_d(epe_sm0g_for_nB_vc0_d[32:0]),
		      .epe_1g_for_nA_vc1_r(epe_1G_for_nA_vc1_r),
		      .epe_1g_for_nA_vc1_h(epe_1G_for_nA_vc1_h),
		      .epe_1g_for_nA_vc1_d(epe_1G_for_nA_vc1_d[32:0]),
		      .see_for_nA_vc1_r	(see_for_nA_vc1_r),
		      .see_for_nA_vc1_h	(see_for_nA_vc1_h),
		      .see_for_nA_vc1_d	(see_for_nA_vc1_d[32:0]),
		      .epe_1g_for_nB_vc1_r(epe_1G_for_nB_vc1_r),
		      .epe_1g_for_nB_vc1_h(epe_1G_for_nB_vc1_h),
		      .epe_1g_for_nB_vc1_d(epe_1G_for_nB_vc1_d[32:0]),
		      .see_for_nB_vc1_r	(see_for_nB_vc1_r),
		      .see_for_nB_vc1_h	(see_for_nB_vc1_h),
		      .see_for_nB_vc1_d	(see_for_nB_vc1_d[32:0]),
		      .nie_sm1_for_nA_vc2_r(nie_sm1_for_nA_vc2_r),
		      .nie_sm1_for_nA_vc2_h(nie_sm1_for_nA_vc2_h),
		      .nie_sm1_for_nA_vc2_d(nie_sm1_for_nA_vc2_d[32:0]),
		      .nie_sm1_for_nB_vc2_r(nie_sm1_for_nB_vc2_r),
		      .nie_sm1_for_nB_vc2_h(nie_sm1_for_nB_vc2_h),
		      .nie_sm1_for_nB_vc2_d(nie_sm1_for_nB_vc2_d[32:0]),
		      .see_for_nA_vc3_r	(see_for_nA_vc3_r),
		      .see_for_nA_vc3_h	(see_for_nA_vc3_h),
		      .see_for_nA_vc3_d	(see_for_nA_vc3_d[32:0]),
		      .nie_sm1_for_nA_vc3_r(nie_sm1_for_nA_vc3_r),
		      .nie_sm1_for_nA_vc3_h(nie_sm1_for_nA_vc3_h),
		      .nie_sm1_for_nA_vc3_d(nie_sm1_for_nA_vc3_d[32:0]),
		      .nie_sm2_for_nA_vc3_r(nie_sm2_for_nA_vc3_r),
		      .nie_sm2_for_nA_vc3_h(nie_sm2_for_nA_vc3_h),
		      .nie_sm2_for_nA_vc3_d(nie_sm2_for_nA_vc3_d[32:0]),
		      .see_for_nB_vc3_r	(see_for_nB_vc3_r),
		      .see_for_nB_vc3_h	(see_for_nB_vc3_h),
		      .see_for_nB_vc3_d	(see_for_nB_vc3_d[32:0]),
		      .nie_sm1_for_nB_vc3_r(nie_sm1_for_nB_vc3_r),
		      .nie_sm1_for_nB_vc3_h(nie_sm1_for_nB_vc3_h),
		      .nie_sm1_for_nB_vc3_d(nie_sm1_for_nB_vc3_d[32:0]),
		      .nie_sm2_for_nB_vc3_r(nie_sm2_for_nB_vc3_r),
		      .nie_sm2_for_nB_vc3_h(nie_sm2_for_nB_vc3_h),
		      .nie_sm2_for_nB_vc3_d(nie_sm2_for_nB_vc3_d[32:0]),
		      .nA_vc0_incoming_read(nA_vc0_incoming_read),
		      .nA_vc1_incoming_read(nA_vc1_incoming_read),
		      .nA_vc2_incoming_read(nA_vc2_incoming_read),
		      .nA_vc3_incoming_read(nA_vc3_incoming_read),
		      .nB_vc0_incoming_read(nB_vc0_incoming_read),
		      .nB_vc1_incoming_read(nB_vc1_incoming_read),
		      .nB_vc2_incoming_read(nB_vc2_incoming_read),
		      .nB_vc3_incoming_read(nB_vc3_incoming_read));
   

   output [31:0] 	ep0_irf_read_data;
   output [31:0] 	ep1_irf_read_data;
   output [31:0] 	ep2_irf_read_data;
   output [31:0] 	ep3_irf_read_data;
   output 		ep0_irf_gnt_late;
   output 		ep1_irf_gnt_late;
   output 		ep2_irf_gnt_late;
   output 		ep3_irf_gnt_late;
   output [31:0] 	ep0_xmu_read_data;
   output [31:0] 	ep1_xmu_read_data;
   output [31:0] 	ep2_xmu_read_data;
   output [31:0] 	ep3_xmu_read_data;
   output 		ep0_xmu_gnt_late;
   output 		ep1_xmu_gnt_late;
   output 		ep2_xmu_gnt_late;
   output 		ep3_xmu_gnt_late;

   input 		ep0_irf_req;
   input [15:0] 	ep0_irf_addr;
   input 		ep0_xmu_req;
   input [15:0] 	ep0_xmu_addr;
   input 		ep0_xmu_ld;
   input 		ep0_xmu_st;
   input [63:0] 	ep0_xmu_write_data;
   
   input 		ep1_irf_req;
   input [15:0] 	ep1_irf_addr;
   input 		ep1_xmu_req;
   input [15:0] 	ep1_xmu_addr;
   input 		ep1_xmu_ld;
   input 		ep1_xmu_st;
   input [63:0] 	ep1_xmu_write_data;

   input 		ep2_irf_req;
   input [15:0] 	ep2_irf_addr;
   input 		ep2_xmu_req;
   input [15:0] 	ep2_xmu_addr;
   input 		ep2_xmu_ld;
   input 		ep2_xmu_st;
   input [63:0] 	ep2_xmu_write_data;

   input 		ep3_irf_req;
   input [15:0] 	ep3_irf_addr;
   input 		ep3_xmu_req;
   input [15:0] 	ep3_xmu_addr;
   input 		ep3_xmu_ld;
   input 		ep3_xmu_st;
   input [63:0] 	ep3_xmu_write_data;
   
   
   v2_emem the_emem(/**/
		    // Outputs
		    .test_b0_read_data	(test_b0_read_data[63:0]),
		    .test_b1_read_data	(test_b1_read_data[63:0]),
		    .test_b2_read_data	(test_b2_read_data[63:0]),
		    .test_b3_read_data	(test_b3_read_data[63:0]),
		    .ep0_irf_read_data	(ep0_irf_read_data[31:0]),
		    .ep0_irf_gnt_late	(ep0_irf_gnt_late),
		    .ep1_irf_read_data	(ep1_irf_read_data[31:0]),
		    .ep1_irf_gnt_late	(ep1_irf_gnt_late),
		    .ep2_irf_read_data	(ep2_irf_read_data[31:0]),
		    .ep2_irf_gnt_late	(ep2_irf_gnt_late),
		    .ep3_irf_read_data	(ep3_irf_read_data[31:0]),
		    .ep3_irf_gnt_late	(ep3_irf_gnt_late),
		    .ep0_xmu_read_data	(ep0_xmu_read_data[31:0]),
		    .ep0_xmu_gnt_late	(ep0_xmu_gnt_late),
		    .ep1_xmu_read_data	(ep1_xmu_read_data[31:0]),
		    .ep1_xmu_gnt_late	(ep1_xmu_gnt_late),
		    .ep2_xmu_read_data	(ep2_xmu_read_data[31:0]),
		    .ep2_xmu_gnt_late	(ep2_xmu_gnt_late),
		    .ep3_xmu_read_data	(ep3_xmu_read_data[31:0]),
		    .ep3_xmu_gnt_late	(ep3_xmu_gnt_late),
		    .nie_sm1_mem_read_data(nie_sm1_mem_read_data[63:0]),
		    .nie_sm1_mem_gnt	(nie_sm1_mem_gnt),
		    .nie_sm2_mem_read_data(nie_sm2_mem_read_data[63:0]),
		    .nie_sm2_mem_gnt	(nie_sm2_mem_gnt),
		    .epe_sm0_mem_read_data(epe_sm0_mem_read_data[63:0]),
		    .epe_sm0_mem_gnt	(epe_sm0_mem_gnt),
		    .epe_sm1_mem_read_data(epe_sm1_mem_read_data[63:0]),
		    .epe_sm1_mem_gnt	(epe_sm1_mem_gnt),
		    .se0_mem_read_data	(se0_mem_read_data[63:0]),
		    .se0_mem_gnt	(se0_mem_gnt),
		    .se1_mem_read_data	(se1_mem_read_data[63:0]),
		    .se1_mem_gnt	(se1_mem_gnt),
		    .se2_mem_read_data	(se2_mem_read_data[63:0]),
		    .se2_mem_gnt	(se2_mem_gnt),
		    .se3_mem_read_data	(se3_mem_read_data[63:0]),
		    .se3_mem_gnt	(se3_mem_gnt),
		    // Inputs
		    .CLK		(CLK),
		    .rst		(rst),
		    .TEST_MODE		(TEST_MODE),
		    .test_b0_csn	(test_b0_csn),
		    .test_b0_addr	(test_b0_addr[7:0]),
		    .test_b0_write_data	(test_b0_write_data[63:0]),
		    .test_b0_write_mask	(test_b0_write_mask[63:0]),
		    .test_b0_wen_b	(test_b0_wen_b),
		    .test_b1_csn	(test_b1_csn),
		    .test_b1_addr	(test_b1_addr[7:0]),
		    .test_b1_write_data	(test_b1_write_data[63:0]),
		    .test_b1_write_mask	(test_b1_write_mask[63:0]),
		    .test_b1_wen_b	(test_b1_wen_b),
		    .test_b2_csn	(test_b2_csn),
		    .test_b2_addr	(test_b2_addr[7:0]),
		    .test_b2_write_data	(test_b2_write_data[63:0]),
		    .test_b2_write_mask	(test_b2_write_mask[63:0]),
		    .test_b2_wen_b	(test_b2_wen_b),
		    .test_b3_csn	(test_b3_csn),
		    .test_b3_addr	(test_b3_addr[7:0]),
		    .test_b3_write_data	(test_b3_write_data[63:0]),
		    .test_b3_write_mask	(test_b3_write_mask[63:0]),
		    .test_b3_wen_b	(test_b3_wen_b),
		    .ep0_irf_req	(ep0_irf_req),
		    .ep0_irf_addr	(ep0_irf_addr[15:0]),
		    .ep1_irf_req	(ep1_irf_req),
		    .ep1_irf_addr	(ep1_irf_addr[15:0]),
		    .ep2_irf_req	(ep2_irf_req),
		    .ep2_irf_addr	(ep2_irf_addr[15:0]),
		    .ep3_irf_req	(ep3_irf_req),
		    .ep3_irf_addr	(ep3_irf_addr[15:0]),
		    .ep0_xmu_req	(ep0_xmu_req),
		    .ep0_xmu_ld		(ep0_xmu_ld),
		    .ep0_xmu_st		(ep0_xmu_st),
		    .ep0_xmu_addr	(ep0_xmu_addr[15:0]),
		    .ep0_xmu_write_data	(ep0_xmu_write_data[63:0]),
		    .ep1_xmu_req	(ep1_xmu_req),
		    .ep1_xmu_ld		(ep1_xmu_ld),
		    .ep1_xmu_st		(ep1_xmu_st),
		    .ep1_xmu_addr	(ep1_xmu_addr[15:0]),
		    .ep1_xmu_write_data	(ep1_xmu_write_data[63:0]),
		    .ep2_xmu_req	(ep2_xmu_req),
		    .ep2_xmu_ld		(ep2_xmu_ld),
		    .ep2_xmu_st		(ep2_xmu_st),
		    .ep2_xmu_addr	(ep2_xmu_addr[15:0]),
		    .ep2_xmu_write_data	(ep2_xmu_write_data[63:0]),
		    .ep3_xmu_req	(ep3_xmu_req),
		    .ep3_xmu_ld		(ep3_xmu_ld),
		    .ep3_xmu_st		(ep3_xmu_st),
		    .ep3_xmu_addr	(ep3_xmu_addr[15:0]),
		    .ep3_xmu_write_data	(ep3_xmu_write_data[63:0]),
		    .nie_sm1_mem_req	(nie_sm1_mem_req),
		    .nie_sm1_mem_addr	(nie_sm1_mem_addr[15:0]),
		    .nie_sm1_mem_wen_b	(nie_sm1_mem_wen_b),
		    .nie_sm1_mem_write_data(nie_sm1_mem_write_data[63:0]),
		    .nie_sm1_mem_write_mask(nie_sm1_mem_write_mask[63:0]),
		    .nie_sm1_mem_lock	(nie_sm1_mem_lock),
		    .nie_sm2_mem_req	(nie_sm2_mem_req),
		    .nie_sm2_mem_addr	(nie_sm2_mem_addr[15:0]),
		    .nie_sm2_mem_wen_b	(nie_sm2_mem_wen_b),
		    .nie_sm2_mem_write_data(nie_sm2_mem_write_data[63:0]),
		    .nie_sm2_mem_write_mask(nie_sm2_mem_write_mask[63:0]),
		    .epe_sm0_mem_req	(epe_sm0_mem_req),
		    .epe_sm0_mem_addr	(epe_sm0_mem_addr[15:0]),
		    .epe_sm0_mem_wen_b	(epe_sm0_mem_wen_b),
		    .epe_sm0_mem_write_data(epe_sm0_mem_write_data[63:0]),
		    .epe_sm0_mem_write_mask(epe_sm0_mem_write_mask[63:0]),
		    .epe_sm1_mem_req	(epe_sm1_mem_req),
		    .epe_sm1_mem_addr	(epe_sm1_mem_addr[15:0]),
		    .epe_sm1_mem_wen_b	(epe_sm1_mem_wen_b),
		    .epe_sm1_mem_write_data(epe_sm1_mem_write_data[63:0]),
		    .epe_sm1_mem_write_mask(epe_sm1_mem_write_mask[63:0]),
		    .epe_sm1_mem_lock	(epe_sm1_mem_lock),
		    .se0_mem_req	(se0_mem_req),
		    .se0_mem_wen_b	(se0_mem_wen_b),
		    .se0_mem_addr	(se0_mem_addr[15:0]),
		    .se0_mem_write_data	(se0_mem_write_data[63:0]),
		    .se0_mem_write_mask	(se0_mem_write_mask[63:0]),
		    .se1_mem_req	(se1_mem_req),
		    .se1_mem_wen_b	(se1_mem_wen_b),
		    .se1_mem_addr	(se1_mem_addr[15:0]),
		    .se1_mem_write_data	(se1_mem_write_data[63:0]),
		    .se1_mem_write_mask	(se1_mem_write_mask[63:0]),
		    .se2_mem_req	(se2_mem_req),
		    .se2_mem_wen_b	(se2_mem_wen_b),
		    .se2_mem_addr	(se2_mem_addr[15:0]),
		    .se2_mem_write_data	(se2_mem_write_data[63:0]),
		    .se2_mem_write_mask	(se2_mem_write_mask[63:0]),
		    .se3_mem_req	(se3_mem_req),
		    .se3_mem_wen_b	(se3_mem_wen_b),
		    .se3_mem_addr	(se3_mem_addr[15:0]),
		    .se3_mem_write_data	(se3_mem_write_data[63:0]),
		    .se3_mem_write_mask	(se3_mem_write_mask[63:0]));
   
endmodule // e1_top_level
