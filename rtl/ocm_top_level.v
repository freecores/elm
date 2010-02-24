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

module ocm_top_level(/*AUTOARG*/
   // Outputs
   test_tile_read_data, gated_outgoing_A, ungated_outgoing_A, 
   gated_outgoing_B, ungated_outgoing_B, 
   // Inputs
   CLK, rst, TEST_MODE, test_tile_addr, test_tile_csn, 
   test_tile_write_data, test_tile_write_mask, test_tile_wen_b, 
   gated_incoming_A, ungated_incoming_A, gated_incoming_B, 
   ungated_incoming_B
   );

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

   input TEST_MODE;
   input [11:0] test_tile_addr;
   input 	test_tile_csn;
   input [63:0] test_tile_write_data;
   input [63:0] test_tile_write_mask;
   output [63:0] test_tile_read_data;
   input         test_tile_wen_b;

   //The outgoing networks
   output [34:0] gated_outgoing_A;
   output [4:0]  ungated_outgoing_A;
   output [34:0] gated_outgoing_B;
   output [4:0]  ungated_outgoing_B;
   input [34:0]  gated_incoming_A;
   input [4:0] 	 ungated_incoming_A;
   input [34:0]  gated_incoming_B;
   input [4:0] 	 ungated_incoming_B;
   

   //Throw away wires, since there are no EPs...
   wire			epe_sm0g_for_nA_vc0_gnt;
   wire			epe_sm0g_for_nB_vc0_gnt;
   //wire 		se0_for_ep0_vc3_r;
   wire 		se0_for_ep0_vc3_full;
   wire [121:0] 	se0_for_ep0_vc3_d;
   //wire 		se0_for_ep1_vc3_r;
   wire 		se0_for_ep1_vc3_full;
   wire [121:0] 	se0_for_ep1_vc3_d;
   //wire 		se0_for_ep2_vc3_r;
   wire 		se0_for_ep2_vc3_full;
   wire [121:0] 	se0_for_ep2_vc3_d;
   //wire 		se0_for_ep3_vc3_r;
   wire 		se0_for_ep3_vc3_full;
   wire [121:0] 	se0_for_ep3_vc3_d;
   //wire 		se1_for_ep0_vc3_r;
   wire 		se1_for_ep0_vc3_full;
   wire [121:0] 	se1_for_ep0_vc3_d;
   //wire 		se1_for_ep1_vc3_r;
   wire 		se1_for_ep1_vc3_full;
   wire [121:0] 	se1_for_ep1_vc3_d;
   //wire 		se1_for_ep2_vc3_r;
   wire 		se1_for_ep2_vc3_full;
   wire [121:0] 	se1_for_ep2_vc3_d;
   //wire 		se1_for_ep3_vc3_r;
   wire 		se1_for_ep3_vc3_full;
   wire [121:0] 	se1_for_ep3_vc3_d;
   /*//wire 		se2_for_ep0_vc3_r;
   wire 		se2_for_ep0_vc3_full;
   wire [121:0] 	se2_for_ep0_vc3_d;
   //wire 		se2_for_ep1_vc3_r;
   wire 		se2_for_ep1_vc3_full;
   wire [121:0] 	se2_for_ep1_vc3_d;
   //wire 		se2_for_ep2_vc3_r;
   wire 		se2_for_ep2_vc3_full;
   wire [121:0] 	se2_for_ep2_vc3_d;
   //wire 		se2_for_ep3_vc3_r;
   wire 		se2_for_ep3_vc3_full;
   wire [121:0] 	se2_for_ep3_vc3_d;
   //wire 		se3_for_ep0_vc3_r;
   wire 		se3_for_ep0_vc3_full;
   wire [121:0] 	se3_for_ep0_vc3_d;
   //wire 		se3_for_ep1_vc3_r;
   wire 		se3_for_ep1_vc3_full;
   wire [121:0] 	se3_for_ep1_vc3_d;
   //wire 		se3_for_ep2_vc3_r;
   wire 		se3_for_ep2_vc3_full;
   wire [121:0] 	se3_for_ep2_vc3_d;
   //wire 		se3_for_ep3_vc3_r;
   wire 		se3_for_ep3_vc3_full;
   wire [121:0] 	se3_for_ep3_vc3_d;*/
   
   wire 		ep0_to_se0_vc0_read;
   wire 		ep1_to_se0_vc0_read;
   wire 		ep2_to_se0_vc0_read;
   wire 		ep3_to_se0_vc0_read;
   wire 		ep0_to_se1_vc0_read;
   wire 		ep1_to_se1_vc0_read;
   wire 		ep2_to_se1_vc0_read;
   wire 		ep3_to_se1_vc0_read;
   /*wire 		ep0_to_se2_vc0_read;
   wire 		ep1_to_se2_vc0_read;
   wire 		ep2_to_se2_vc0_read;
   wire 		ep3_to_se2_vc0_read;
   wire 		ep0_to_se3_vc0_read;
   wire 		ep1_to_se3_vc0_read;
   wire 		ep2_to_se3_vc0_read;
   wire 		ep3_to_se3_vc0_read;*/

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
   /*wire [32:0] 		se2_for_nA_vc1_d;
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
   wire 		se3_for_nB_vc1_gnt;*/

   wire 		se0_see_vc1_nA_gnt;
   wire 		se1_see_vc1_nA_gnt;
   //wire 		se2_see_vc1_nA_gnt;
   //wire 		se3_see_vc1_nA_gnt;
   wire 		se0_see_vc1_nB_gnt;
   wire 		se1_see_vc1_nB_gnt;
   //wire 		se2_see_vc1_nB_gnt;
   //wire 		se3_see_vc1_nB_gnt;

   assign 		se0_for_nA_vc1_gnt = se0_see_vc1_nA_gnt & see_for_nA_vc1_gnt;
   assign 		se1_for_nA_vc1_gnt = se1_see_vc1_nA_gnt & see_for_nA_vc1_gnt;
   //assign 		se2_for_nA_vc1_gnt = se2_see_vc1_nA_gnt & see_for_nA_vc1_gnt;
   //assign 		se3_for_nA_vc1_gnt = se3_see_vc1_nA_gnt & see_for_nA_vc1_gnt;

   assign 		se0_for_nB_vc1_gnt = se0_see_vc1_nB_gnt & see_for_nB_vc1_gnt;
   assign 		se1_for_nB_vc1_gnt = se1_see_vc1_nB_gnt & see_for_nB_vc1_gnt;
//   assign 		se2_for_nB_vc1_gnt = se2_see_vc1_nB_gnt & see_for_nB_vc1_gnt;
//   assign 		se3_for_nB_vc1_gnt = se3_see_vc1_nB_gnt & see_for_nB_vc1_gnt;

   assign 		see_for_nA_vc1_r = 
			se0_see_vc1_nA_gnt ? se0_for_nA_vc1_r :
			se1_see_vc1_nA_gnt ? se1_for_nA_vc1_r : 
			/*se2_see_vc1_nA_gnt ? se2_for_nA_vc1_r : 
			se3_see_vc1_nA_gnt ? se3_for_nA_vc1_r :*/ 1'b0;
   
   assign 		see_for_nA_vc1_h = 
			se0_see_vc1_nA_gnt ? se0_for_nA_vc1_h :
			se1_see_vc1_nA_gnt ? se1_for_nA_vc1_h : 
		/*	se2_see_vc1_nA_gnt ? se2_for_nA_vc1_h : 
			se3_see_vc1_nA_gnt ? se3_for_nA_vc1_h :*/ 1'b0;

   assign 		see_for_nA_vc1_d = 
			se0_see_vc1_nA_gnt ? se0_for_nA_vc1_d :
			se1_see_vc1_nA_gnt ? se1_for_nA_vc1_d : 
			/*se2_see_vc1_nA_gnt ? se2_for_nA_vc1_d : 
			se3_see_vc1_nA_gnt ? se3_for_nA_vc1_d :*/ 33'b0;
   
   assign 		see_for_nB_vc1_r = 
			se0_see_vc1_nB_gnt ? se0_for_nB_vc1_r :
			se1_see_vc1_nB_gnt ? se1_for_nB_vc1_r : 
			/*se2_see_vc1_nB_gnt ? se2_for_nB_vc1_r : 
			se3_see_vc1_nB_gnt ? se3_for_nB_vc1_r :*/ 1'b0;
   
   assign 		see_for_nB_vc1_h = 
			se0_see_vc1_nB_gnt ? se0_for_nB_vc1_h :
			se1_see_vc1_nB_gnt ? se1_for_nB_vc1_h : 
			/*se2_see_vc1_nB_gnt ? se2_for_nB_vc1_h : 
			se3_see_vc1_nB_gnt ? se3_for_nB_vc1_h :*/ 1'b0;

   assign 		see_for_nB_vc1_d = 
			se0_see_vc1_nB_gnt ? se0_for_nB_vc1_d :
			se1_see_vc1_nB_gnt ? se1_for_nB_vc1_d : 
			/*se2_see_vc1_nB_gnt ? se2_for_nB_vc1_d : 
			se3_see_vc1_nB_gnt ? se3_for_nB_vc1_d :*/ 33'b0;
   

   wire [3:0] 		foo;
   
   arb4to1_hold see_nA_vc1(
		       // Outputs
		       .gnt_0		(se0_see_vc1_nA_gnt),
		       .gnt_1		(se1_see_vc1_nA_gnt),
		       .gnt_2		(foo[0]),
		       .gnt_3		(foo[1]),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nA_vc1_r),
		       .req_1		(se1_for_nA_vc1_r),
		       .req_2		(1'b0),
		       .req_3		(1'b0),
		       .hold_0		(se0_for_nA_vc1_h),
		       .hold_1		(se1_for_nA_vc1_h),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0));
   
   arb4to1_hold see_nB_vc1(
		       // Outputs
		       .gnt_0		(se0_see_vc1_nB_gnt),
		       .gnt_1		(se1_see_vc1_nB_gnt),
		       .gnt_2		(foo[2]),
		       .gnt_3		(foo[3]),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nB_vc1_r),
		       .req_1		(se1_for_nB_vc1_r),
		       .req_2		(1'b0),
		       .req_3		(1'b0),
		       .hold_0		(se0_for_nB_vc1_h),
		       .hold_1		(se1_for_nB_vc1_h),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0));


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
   /*wire [32:0] 		se2_for_nA_vc3_d;
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
   wire 		se3_for_nB_vc3_gnt;*/

   wire 		se0_see_vc3_nA_gnt;
   wire 		se1_see_vc3_nA_gnt;
   //wire 		se2_see_vc3_nA_gnt;
   //wire 		se3_see_vc3_nA_gnt;
   wire 		se0_see_vc3_nB_gnt;
   wire 		se1_see_vc3_nB_gnt;
   //wire 		se2_see_vc3_nB_gnt;
   //wire 		se3_see_vc3_nB_gnt;

   assign 		se0_for_nA_vc3_gnt = se0_see_vc3_nA_gnt & see_for_nA_vc3_gnt;
   assign 		se1_for_nA_vc3_gnt = se1_see_vc3_nA_gnt & see_for_nA_vc3_gnt;
   //assign 		se2_for_nA_vc3_gnt = se2_see_vc3_nA_gnt & see_for_nA_vc3_gnt;
   //assign 		se3_for_nA_vc3_gnt = se3_see_vc3_nA_gnt & see_for_nA_vc3_gnt;

   assign 		se0_for_nB_vc3_gnt = se0_see_vc3_nB_gnt & see_for_nB_vc3_gnt;
   assign 		se1_for_nB_vc3_gnt = se1_see_vc3_nB_gnt & see_for_nB_vc3_gnt;
   //assign 		se2_for_nB_vc3_gnt = se2_see_vc3_nB_gnt & see_for_nB_vc3_gnt;
   //assign 		se3_for_nB_vc3_gnt = se3_see_vc3_nB_gnt & see_for_nB_vc3_gnt;

   assign 		see_for_nA_vc3_r = 
			se0_see_vc3_nA_gnt ? se0_for_nA_vc3_r :
			se1_see_vc3_nA_gnt ? se1_for_nA_vc3_r : 
			/*se2_see_vc3_nA_gnt ? se2_for_nA_vc3_r : 
			se3_see_vc3_nA_gnt ? se3_for_nA_vc3_r :*/ 1'b0;
   
   assign 		see_for_nA_vc3_h = 
			se0_see_vc3_nA_gnt ? se0_for_nA_vc3_h :
			se1_see_vc3_nA_gnt ? se1_for_nA_vc3_h : 
			/*se2_see_vc3_nA_gnt ? se2_for_nA_vc3_h : 
			se3_see_vc3_nA_gnt ? se3_for_nA_vc3_h :*/ 1'b0;

   assign 		see_for_nA_vc3_d = 
			se0_see_vc3_nA_gnt ? se0_for_nA_vc3_d :
			se1_see_vc3_nA_gnt ? se1_for_nA_vc3_d : 
			/*se2_see_vc3_nA_gnt ? se2_for_nA_vc3_d : 
			se3_see_vc3_nA_gnt ? se3_for_nA_vc3_d :*/ 33'b0;
   
   assign 		see_for_nB_vc3_r = 
			se0_see_vc3_nB_gnt ? se0_for_nB_vc3_r :
			se1_see_vc3_nB_gnt ? se1_for_nB_vc3_r : 
			/*se2_see_vc3_nB_gnt ? se2_for_nB_vc3_r : 
			se3_see_vc3_nB_gnt ? se3_for_nB_vc3_r :*/ 1'b0;
   
   assign 		see_for_nB_vc3_h = 
			se0_see_vc3_nB_gnt ? se0_for_nB_vc3_h :
			se1_see_vc3_nB_gnt ? se1_for_nB_vc3_h : 
			/*se2_see_vc3_nB_gnt ? se2_for_nB_vc3_h : 
			se3_see_vc3_nB_gnt ? se3_for_nB_vc3_h :*/ 1'b0;

   assign 		see_for_nB_vc3_d = 
			se0_see_vc3_nB_gnt ? se0_for_nB_vc3_d :
			se1_see_vc3_nB_gnt ? se1_for_nB_vc3_d : 
			/*se2_see_vc3_nB_gnt ? se2_for_nB_vc3_d : 
			se3_see_vc3_nB_gnt ? se3_for_nB_vc3_d :*/ 33'b0;
   
   wire [3:0]		foo_a;
    
   arb4to1_hold see_nA_vc3(
		       // Outputs
		       .gnt_0		(se0_see_vc3_nA_gnt),
		       .gnt_1		(se1_see_vc3_nA_gnt),
		       .gnt_2		(foo_a[0]),
		       .gnt_3		(foo_a[1]),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nA_vc3_r),
		       .req_1		(se1_for_nA_vc3_r),
		       .req_2		(1'b0),
		       .req_3		(1'b0),
		       .hold_0		(se0_for_nA_vc3_h),
		       .hold_1		(se1_for_nA_vc3_h),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0));
   
   arb4to1_hold see_nB_vc3(
		       // Outputs
		       .gnt_0		(se0_see_vc3_nB_gnt),
		       .gnt_1		(se1_see_vc3_nB_gnt),
		       .gnt_2		(foo_a[2]),
		       .gnt_3		(foo_a[3]),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(se0_for_nB_vc3_r),
		       .req_1		(se1_for_nB_vc3_r),
		       .req_2		(1'b0),
		       .req_3		(1'b0),
		       .hold_0		(se0_for_nB_vc3_h),
		       .hold_1		(se1_for_nB_vc3_h),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0));

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
   //reg 			incoming_nA_vc0_for_se2;
   //reg 			incoming_nA_vc0_for_se3;
   reg 			incoming_nB_vc0_for_se0;
   reg 			incoming_nB_vc0_for_se1;
   //reg 			incoming_nB_vc0_for_se2;
   //reg 			incoming_nB_vc0_for_se3;
   reg 			incoming_nA_vc3_for_se0;
   reg 			incoming_nA_vc3_for_se1;
   //reg 			incoming_nA_vc3_for_se2;
   //reg 			incoming_nA_vc3_for_se3;
   reg 			incoming_nB_vc3_for_se0;
   reg 			incoming_nB_vc3_for_se1;
   //reg 			incoming_nB_vc3_for_se2;
   //reg 			incoming_nB_vc3_for_se3;

   wire incoming_nA_vc0_for_se0_nxt = nA_vc0_incoming_d[32] ?
	(nA_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD0)  : incoming_nA_vc0_for_se0;
   wire	incoming_nA_vc0_for_se1_nxt = nA_vc0_incoming_d[32] ?
	(nA_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD1)  : incoming_nA_vc0_for_se1;
   //wire	incoming_nA_vc0_for_se2_nxt = nA_vc0_incoming_d[32] ?
   //(nA_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD2)  : incoming_nA_vc0_for_se2;
   //wire	incoming_nA_vc0_for_se3_nxt = nA_vc0_incoming_d[32] ?
   //(nA_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD3)  : incoming_nA_vc0_for_se3;
  
   wire	incoming_nB_vc0_for_se0_nxt = nB_vc0_incoming_d[32] ?
	(nB_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD0)  : incoming_nB_vc0_for_se0;
   wire	incoming_nB_vc0_for_se1_nxt = nB_vc0_incoming_d[32] ?
	(nB_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD1)  : incoming_nB_vc0_for_se1;
   //wire	incoming_nB_vc0_for_se2_nxt = nB_vc0_incoming_d[32] ?
   //(nB_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD2)  : incoming_nB_vc0_for_se2;
   //wire	incoming_nB_vc0_for_se3_nxt = nB_vc0_incoming_d[32] ?
   //(nB_vc0_incoming_d[31:26] == `OCM_NODE_OCM_SD3)  : incoming_nB_vc0_for_se3;
   
   wire	incoming_nA_vc3_for_se0_nxt = nA_vc3_incoming_d[32] ?
	(nA_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD0)  : incoming_nA_vc3_for_se0;
   wire	incoming_nA_vc3_for_se1_nxt = nA_vc3_incoming_d[32] ?
	(nA_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD1)  : incoming_nA_vc3_for_se1;
   //wire	incoming_nA_vc3_for_se2_nxt = nA_vc3_incoming_d[32] ?
   //(nA_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD2)  : incoming_nA_vc3_for_se2;
   //wire	incoming_nA_vc3_for_se3_nxt = nA_vc3_incoming_d[32] ?
   //(nA_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD3)  : incoming_nA_vc3_for_se3;
   
   wire	incoming_nB_vc3_for_se0_nxt = nB_vc3_incoming_d[32] ?
	(nB_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD0)  : incoming_nB_vc3_for_se0;
   wire	incoming_nB_vc3_for_se1_nxt = nB_vc3_incoming_d[32] ?
	(nB_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD1)  : incoming_nB_vc3_for_se1;
   //wire	incoming_nB_vc3_for_se2_nxt = nB_vc3_incoming_d[32] ?
   //(nB_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD2)  : incoming_nB_vc3_for_se2;
   //wire	incoming_nB_vc3_for_se3_nxt = nB_vc3_incoming_d[32] ?
   //(nB_vc3_incoming_d[31:26] == `OCM_NODE_OCM_SD3)  : incoming_nB_vc3_for_se3;
   

   always@(posedge CLK or posedge rst) begin
      if(rst) begin
	 incoming_nA_vc0_for_se0 <= 1'b0;
	 incoming_nA_vc0_for_se1 <= 1'b0;
	 //incoming_nA_vc0_for_se2 <= 1'b0;
   	 //incoming_nA_vc0_for_se3 <= 1'b0;
    	 incoming_nB_vc0_for_se0 <= 1'b0;
    	 incoming_nB_vc0_for_se1 <= 1'b0;
   	 //incoming_nB_vc0_for_se2 <= 1'b0;
   	 //incoming_nB_vc0_for_se3 <= 1'b0;
   	 incoming_nA_vc3_for_se0 <= 1'b0;
	 incoming_nA_vc3_for_se1 <= 1'b0;
	 //incoming_nA_vc3_for_se2 <= 1'b0;
	 //incoming_nA_vc3_for_se3 <= 1'b0;
   	 incoming_nB_vc3_for_se0 <= 1'b0;
   	 incoming_nB_vc3_for_se1 <= 1'b0;
   	 //incoming_nB_vc3_for_se2 <= 1'b0;
   	 //incoming_nB_vc3_for_se3 <= 1'b0;
      end // if (rst)
      else begin
	 incoming_nA_vc0_for_se0 <= incoming_nA_vc0_for_se0_nxt;
	 incoming_nA_vc0_for_se1 <= incoming_nA_vc0_for_se1_nxt;
	 //incoming_nA_vc0_for_se2 <= incoming_nA_vc0_for_se2_nxt;
	 //incoming_nA_vc0_for_se3 <= incoming_nA_vc0_for_se3_nxt;
	 incoming_nB_vc0_for_se0 <= incoming_nB_vc0_for_se0_nxt;
	 incoming_nB_vc0_for_se1 <= incoming_nB_vc0_for_se1_nxt;
	 //incoming_nB_vc0_for_se2 <= incoming_nB_vc0_for_se2_nxt;
	 //incoming_nB_vc0_for_se3 <= incoming_nB_vc0_for_se3_nxt;
	 incoming_nA_vc3_for_se0 <= incoming_nA_vc3_for_se0_nxt;
	 incoming_nA_vc3_for_se1 <= incoming_nA_vc3_for_se1_nxt;
	 //incoming_nA_vc3_for_se2 <= incoming_nA_vc3_for_se2_nxt;
	 //incoming_nA_vc3_for_se3 <= incoming_nA_vc3_for_se3_nxt;
	 incoming_nB_vc3_for_se0 <= incoming_nB_vc3_for_se0_nxt;
	 incoming_nB_vc3_for_se1 <= incoming_nB_vc3_for_se1_nxt;
	 //incoming_nB_vc3_for_se2 <= incoming_nB_vc3_for_se2_nxt;
	 //incoming_nB_vc3_for_se3 <= incoming_nB_vc3_for_se3_nxt;
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
   //wire 		se2_nA_vc0_incoming_e = incoming_nA_vc0_for_se2_nxt ? nA_vc0_incoming_e : 1'b1;
   //wire [32:0] 		se2_nA_vc0_incoming_d = incoming_nA_vc0_for_se2_nxt ? nA_vc0_incoming_d : 33'd0;
   //wire 		se2_nB_vc0_incoming_e = incoming_nB_vc0_for_se2_nxt ? nB_vc0_incoming_e : 1'b1;
   //wire [32:0] 		se2_nB_vc0_incoming_d = incoming_nB_vc0_for_se2_nxt ? nB_vc0_incoming_d : 33'd0;
   //wire 		se3_nA_vc0_incoming_e = incoming_nA_vc0_for_se3_nxt ? nA_vc0_incoming_e : 1'b1;
   //wire [32:0] 		se3_nA_vc0_incoming_d = incoming_nA_vc0_for_se3_nxt ? nA_vc0_incoming_d : 33'd0;
   //wire 		se3_nB_vc0_incoming_e = incoming_nB_vc0_for_se3_nxt ? nB_vc0_incoming_e : 1'b1;
   //wire [32:0] 		se3_nB_vc0_incoming_d = incoming_nB_vc0_for_se3_nxt ? nB_vc0_incoming_d : 33'd0;
   wire 		se0_nA_vc3_incoming_e = incoming_nA_vc3_for_se0_nxt ? nA_vc3_incoming_e : 1'b1;
   wire [32:0] 		se0_nA_vc3_incoming_d = incoming_nA_vc3_for_se0_nxt ? nA_vc3_incoming_d : 33'd0;
   wire 		se0_nB_vc3_incoming_e = incoming_nB_vc3_for_se0_nxt ? nB_vc3_incoming_e : 1'b1;
   wire [32:0] 		se0_nB_vc3_incoming_d = incoming_nB_vc3_for_se0_nxt ? nB_vc3_incoming_d : 33'd0;
   wire 		se1_nA_vc3_incoming_e = incoming_nA_vc3_for_se1_nxt ? nA_vc3_incoming_e : 1'b1;
   wire [32:0] 		se1_nA_vc3_incoming_d = incoming_nA_vc3_for_se1_nxt ? nA_vc3_incoming_d : 33'd0;
   wire 		se1_nB_vc3_incoming_e = incoming_nB_vc3_for_se1_nxt ? nB_vc3_incoming_e : 1'b1;
   wire [32:0] 		se1_nB_vc3_incoming_d = incoming_nB_vc3_for_se1_nxt ? nB_vc3_incoming_d : 33'd0;
   //wire 		se2_nA_vc3_incoming_e = incoming_nA_vc3_for_se2_nxt ? nA_vc3_incoming_e : 1'b1;
   //wire [32:0] 		se2_nA_vc3_incoming_d = incoming_nA_vc3_for_se2_nxt ? nA_vc3_incoming_d : 33'd0;
   //wire 		se2_nB_vc3_incoming_e = incoming_nB_vc3_for_se2_nxt ? nB_vc3_incoming_e : 1'b1;
   //wire [32:0] 		se2_nB_vc3_incoming_d = incoming_nB_vc3_for_se2_nxt ? nB_vc3_incoming_d : 33'd0;
   //wire 		se3_nA_vc3_incoming_e = incoming_nA_vc3_for_se3_nxt ? nA_vc3_incoming_e : 1'b1;
   //wire [32:0] 		se3_nA_vc3_incoming_d = incoming_nA_vc3_for_se3_nxt ? nA_vc3_incoming_d : 33'd0;
   //wire 		se3_nB_vc3_incoming_e = incoming_nB_vc3_for_se3_nxt ? nB_vc3_incoming_e : 1'b1;
   //wire [32:0] 		se3_nB_vc3_incoming_d = incoming_nB_vc3_for_se3_nxt ? nB_vc3_incoming_d : 33'd0;
   
   wire 		se0_nA_vc0_incoming_read;
   wire 		se0_nB_vc0_incoming_read;
   wire 		se0_nA_vc3_incoming_read;
   wire 		se0_nB_vc3_incoming_read;
   wire 		se1_nA_vc0_incoming_read;
   wire 		se1_nB_vc0_incoming_read;
   wire 		se1_nA_vc3_incoming_read;
   wire 		se1_nB_vc3_incoming_read;
   //wire 		se2_nA_vc0_incoming_read;
   //wire 		se2_nB_vc0_incoming_read;
   //wire 		se2_nA_vc3_incoming_read;
   //wire 		se2_nB_vc3_incoming_read;
   //wire 		se3_nA_vc0_incoming_read;
   //wire 		se3_nB_vc0_incoming_read;
   //wire 		se3_nA_vc3_incoming_read;
   //wire 		se3_nB_vc3_incoming_read;
 
   assign 		nA_vc0_incoming_read = 
			(incoming_nA_vc0_for_se0_nxt & se0_nA_vc0_incoming_read) |
			(incoming_nA_vc0_for_se1_nxt & se1_nA_vc0_incoming_read) /*|
			(incoming_nA_vc0_for_se2_nxt & se2_nA_vc0_incoming_read) |
			(incoming_nA_vc0_for_se3_nxt & se3_nA_vc0_incoming_read)*/;
   assign 		nB_vc0_incoming_read = 
			(incoming_nB_vc0_for_se0_nxt & se0_nB_vc0_incoming_read) |
			(incoming_nB_vc0_for_se1_nxt & se1_nB_vc0_incoming_read)/* |
			(incoming_nB_vc0_for_se2_nxt & se2_nB_vc0_incoming_read) |
			(incoming_nB_vc0_for_se3_nxt & se3_nB_vc0_incoming_read)*/;
   assign 		nA_vc3_incoming_read = 
			(incoming_nA_vc3_for_se0_nxt & se0_nA_vc3_incoming_read) |
			(incoming_nA_vc3_for_se1_nxt & se1_nA_vc3_incoming_read)/* |
			(incoming_nA_vc3_for_se2_nxt & se2_nA_vc3_incoming_read) |
			(incoming_nA_vc3_for_se3_nxt & se3_nA_vc3_incoming_read)*/;
   assign 		nB_vc3_incoming_read = 
			(incoming_nB_vc3_for_se0_nxt & se0_nB_vc3_incoming_read) |
			(incoming_nB_vc3_for_se1_nxt & se1_nB_vc3_incoming_read) /*|
			(incoming_nB_vc3_for_se2_nxt & se2_nB_vc3_incoming_read) |
			(incoming_nB_vc3_for_se3_nxt & se3_nB_vc3_incoming_read)*/;
   
   
   
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
   //wire [32:0] 		nie_sm2_for_se2_vc3_d;
   //wire			nie_sm2_for_se2_vc3_r;
   //wire [32:0] 		nie_sm2_for_se3_vc3_d;
   //wire			nie_sm2_for_se3_vc3_r;
   wire 		nie_sm2_for_se0_vc3_gnt = 1'b0;
   wire 		nie_sm2_for_se1_vc3_gnt = 1'b0;
   //wire 		nie_sm2_for_se2_vc3_gnt = 1'b0;
   //wire 		nie_sm2_for_se3_vc3_gnt = 1'b0;
		
   
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
   wire			ep0_to_se_vc0_read;	// From se0 of se.v, ...
   wire			ep1_to_se_vc0_read;	// From se0 of se.v, ...
   wire			ep2_to_se_vc0_read;	// From se0 of se.v, ...
   wire			ep3_to_se_vc0_read;	// From se0 of se.v, ...
   wire			epe_1g_for_nA_vc1_gnt;	// From the_ni of all_port_ni.v
   wire			epe_1g_for_nB_vc1_gnt;	// From the_ni of all_port_ni.v

   //for the memory and ses
   wire			se0_mem_gnt;		
   wire [63:0]		se0_mem_read_data;	
   wire			se1_mem_gnt;		
   wire [63:0]		se1_mem_read_data;	
   //wire			se2_mem_gnt;		
   //wire [63:0] 		se2_mem_read_data;	
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
   //wire [15:0] 		se2_mem_addr;		
   //wire			se2_mem_req;		
   //wire			se2_mem_wen_b;		
   //wire [63:0]		se2_mem_write_data;
   //wire [63:0] 		se2_mem_write_mask;	
   //wire [15:0] 		se3_mem_addr;		
   //wire			se3_mem_req;		
   //wire			se3_mem_wen_b;		
   //wire [63:0]		se3_mem_write_data;
   //wire [63:0] 		se3_mem_write_mask;	
   
   
   // End of automatics
   
   nie_sm1 #(.who_am_i(`OCM_NODE_OCM), 
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
	       .nie_sm1_for_nA_vc2_r(nie_sm1_for_nA_vc2_r),//
	       .nie_sm1_for_nA_vc2_h(nie_sm1_for_nA_vc2_h),//
	       .nie_sm1_for_nA_vc2_d(nie_sm1_for_nA_vc2_d[32:0]),//
	       .nie_sm1_for_nB_vc2_r(nie_sm1_for_nB_vc2_r),//
	       .nie_sm1_for_nB_vc2_h(nie_sm1_for_nB_vc2_h),//
	       .nie_sm1_for_nB_vc2_d(nie_sm1_for_nB_vc2_d[32:0]),//
	       .nie_sm1_for_nA_vc3_r(nie_sm1_for_nA_vc3_r),//
	       .nie_sm1_for_nA_vc3_h(nie_sm1_for_nA_vc3_h),//
	       .nie_sm1_for_nA_vc3_d(nie_sm1_for_nA_vc3_d[32:0]),//
	       .nie_sm1_for_nB_vc3_r(nie_sm1_for_nB_vc3_r),//
	       .nie_sm1_for_nB_vc3_h(nie_sm1_for_nB_vc3_h),//
	       .nie_sm1_for_nB_vc3_d(nie_sm1_for_nB_vc3_d[32:0]),//
	       .nA_vc1_incoming_read(nA_vc1_incoming_read),//
	       .nB_vc1_incoming_read(nB_vc1_incoming_read),//
	       .nie_sm1_mem_req	(nie_sm1_mem_req),//
	       .nie_sm1_mem_wen_b(nie_sm1_mem_wen_b),//
	       .nie_sm1_mem_lock(nie_sm1_mem_lock),//
	       .nie_sm1_mem_addr(nie_sm1_mem_addr[15:0]),//
	       .nie_sm1_mem_write_data(nie_sm1_mem_write_data[63:0]),//
	       .nie_sm1_mem_write_mask(nie_sm1_mem_write_mask[63:0]),//
	       // Inputs
	       .CLK		(CLK),
	       .rst		(rst),
	       .nie_sm1_for_nA_vc2_gnt(nie_sm1_for_nA_vc2_gnt),//
	       .nie_sm1_for_nB_vc2_gnt(nie_sm1_for_nB_vc2_gnt),//
	       .nie_sm1_for_nA_vc3_gnt(nie_sm1_for_nA_vc3_gnt),//
	       .nie_sm1_for_nB_vc3_gnt(nie_sm1_for_nB_vc3_gnt),//
	       .nA_vc1_incoming_e(nA_vc1_incoming_e),//
	       .nA_vc1_incoming_d(nA_vc1_incoming_d[32:0]),//
	       .nB_vc1_incoming_e(nB_vc1_incoming_e),//
	       .nB_vc1_incoming_d(nB_vc1_incoming_d[32:0]),//
	       .nie_sm1_mem_read_data(nie_sm1_mem_read_data[63:0]),//
	       .nie_sm1_mem_gnt	(nie_sm1_mem_gnt));//
 

   nie_sm2 #(.who_am_i(`OCM_NODE_OCM), 
	     .my_dst_header(my_dst_header), 
	     .nA_dst_header(nA_dst_header), 
	     .nB_dst_header(nB_dst_header))
   the_nie_sm2(/**/
	       // Outputs
	       .nie_sm2_for_nA_vc3_r(nie_sm2_for_nA_vc3_r),//
	       .nie_sm2_for_nA_vc3_h(nie_sm2_for_nA_vc3_h),//
	       .nie_sm2_for_nA_vc3_d(nie_sm2_for_nA_vc3_d[32:0]),//
	       .nie_sm2_for_nB_vc3_r(nie_sm2_for_nB_vc3_r),//
	       .nie_sm2_for_nB_vc3_h(nie_sm2_for_nB_vc3_h),//
	       .nie_sm2_for_nB_vc3_d(nie_sm2_for_nB_vc3_d[32:0]),//
	       .nie_sm2_for_se0_vc3_r(nie_sm2_for_se0_vc3_r),//
	       .nie_sm2_for_se0_vc3_d(nie_sm2_for_se0_vc3_d[32:0]),//
	       .nie_sm2_for_se1_vc3_r(nie_sm2_for_se1_vc3_r),//
	       .nie_sm2_for_se1_vc3_d(nie_sm2_for_se1_vc3_d[32:0]),//
	       //.nie_sm2_for_se2_vc3_r(nie_sm2_for_se2_vc3_r),//
	       //.nie_sm2_for_se2_vc3_d(nie_sm2_for_se2_vc3_d[32:0]),//
	       //.nie_sm2_for_se3_vc3_r(nie_sm2_for_se3_vc3_r),//
	       //.nie_sm2_for_se3_vc3_d(nie_sm2_for_se3_vc3_d[32:0]),//
	       .nA_vc2_incoming_read(nA_vc2_incoming_read),//
	       .nB_vc2_incoming_read(nB_vc2_incoming_read),//
	       .nie_sm2_mem_req	(nie_sm2_mem_req),//
	       .nie_sm2_mem_addr(nie_sm2_mem_addr[15:0]),//
	       .nie_sm2_mem_wen_b(nie_sm2_mem_wen_b),//
	       .nie_sm2_mem_wr_data(nie_sm2_mem_write_data[63:0]),//
	       .nie_sm2_mem_write_mask(nie_sm2_mem_write_mask[63:0]),//
	       // Inputs
	       .CLK		(CLK),
	       .rst		(rst),
	       .nie_sm2_for_nA_vc3_gnt(nie_sm2_for_nA_vc3_gnt),//
	       .nie_sm2_for_nB_vc3_gnt(nie_sm2_for_nB_vc3_gnt),//
	       .nie_sm2_for_se0_vc3_gnt(nie_sm2_for_se0_vc3_gnt),//todo
	       .nie_sm2_for_se1_vc3_gnt(nie_sm2_for_se1_vc3_gnt),//
	       //.nie_sm2_for_se2_vc3_gnt(nie_sm2_for_se2_vc3_gnt),//
	       //.nie_sm2_for_se3_vc3_gnt(nie_sm2_for_se3_vc3_gnt),//
	       .nA_vc2_incoming_e(nA_vc2_incoming_e),//
	       .nA_vc2_incoming_d(nA_vc2_incoming_d[32:0]),//
	       .nB_vc2_incoming_e(nB_vc2_incoming_e),//
	       .nB_vc2_incoming_d(nB_vc2_incoming_d[32:0]),//
	       .nie_sm2_mem_rd_data(nie_sm2_mem_read_data[63:0]),//
	       .nie_sm2_mem_gnt	(nie_sm2_mem_gnt));//
   
   se #(.who_am_i(`OCM_NODE_OCM_SD0), 
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
       .ep0_to_se_vc0_read		(ep0_to_se0_vc0_read),//
       .ep1_to_se_vc0_read		(ep1_to_se0_vc0_read),//
       .ep2_to_se_vc0_read		(ep2_to_se0_vc0_read),//
       .ep3_to_se_vc0_read		(ep3_to_se0_vc0_read),//
       .nA_vc0_incoming_read		(se0_nA_vc0_incoming_read),//
       .nB_vc0_incoming_read		(se0_nB_vc0_incoming_read),//
       .nA_vc3_incoming_read		(se0_nA_vc3_incoming_read),//
       .nB_vc3_incoming_read		(se0_nB_vc3_incoming_read),//
       .se_for_nA_vc1_r		(se0_for_nA_vc1_r),//
       .se_for_nA_vc1_h		(se0_for_nA_vc1_h),//
       .se_for_nA_vc1_d		(se0_for_nA_vc1_d[32:0]),//
       .se_for_nB_vc1_r		(se0_for_nB_vc1_r),//
       .se_for_nB_vc1_h		(se0_for_nB_vc1_h),//
       .se_for_nB_vc1_d		(se0_for_nB_vc1_d[32:0]),//
       
       //.se_for_ep0_vc3_r		(se0_for_ep0_vc3_r),//
       .se_for_ep0_vc3_d		(se0_for_ep0_vc3_d[121:0]),//
       .se_for_ep0_vc3_full		(se0_for_ep0_vc3_full),//
       //.se_for_ep1_vc3_r		(se0_for_ep1_vc3_r),//
       .se_for_ep1_vc3_d		(se0_for_ep1_vc3_d[121:0]),//
       .se_for_ep1_vc3_full		(se0_for_ep1_vc3_full),//
       //.se_for_ep2_vc3_r		(se0_for_ep2_vc3_r),//
       .se_for_ep2_vc3_d		(se0_for_ep2_vc3_d[121:0]),//
       .se_for_ep2_vc3_full		(se0_for_ep2_vc3_full),//
       //.se_for_ep3_vc3_r		(se0_for_ep3_vc3_r),//
       .se_for_ep3_vc3_d		(se0_for_ep3_vc3_d[121:0]),//
       .se_for_ep3_vc3_full		(se0_for_ep3_vc3_full),//
       
       .se_for_nA_vc3_r		(se0_for_nA_vc3_r),//
       .se_for_nA_vc3_h		(se0_for_nA_vc3_h),//
       .se_for_nA_vc3_d		(se0_for_nA_vc3_d[32:0]),//
       .se_for_nB_vc3_r		(se0_for_nB_vc3_r),//
       .se_for_nB_vc3_h		(se0_for_nB_vc3_h),//
       .se_for_nB_vc3_d		(se0_for_nB_vc3_d[32:0]),//
       .se_mem_req			(se0_mem_req),//
       .se_mem_wen_b			(se0_mem_wen_b),//
       .se_mem_addr			(se0_mem_addr[15:0]),//
       .se_mem_write_data		(se0_mem_write_data[63:0]),//
       .se_mem_write_mask		(se0_mem_write_mask[63:0]),//
       // Inputs
       .CLK				(CLK),
       .rst				(rst),
       .ep0_to_se_vc0_d		(122'd0),
       .ep0_to_se_vc0_full		(1'b0),
       .ep1_to_se_vc0_full		(1'b0),
       .ep1_to_se_vc0_d		(122'd0),
       .ep2_to_se_vc0_full		(1'b0),
       .ep2_to_se_vc0_d		(122'd0),
       .ep3_to_se_vc0_full		(1'b0),
       .ep3_to_se_vc0_d		(122'd0),
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
       .se_for_ep0_vc3_gnt		(1'b0),
       .se_for_ep1_vc3_gnt		(1'b0),
       .se_for_ep2_vc3_gnt		(1'b0),
       .se_for_ep3_vc3_gnt		(1'b0),
       .se_for_nA_vc3_gnt		(se0_for_nA_vc3_gnt),
       .se_for_nB_vc3_gnt		(se0_for_nB_vc3_gnt),
       .se_mem_read_data		(se0_mem_read_data[63:0]),
       .se_mem_gnt			(se0_mem_gnt));
   
   se #(.who_am_i(`OCM_NODE_OCM_SD1), 
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
	  .se_for_nA_vc1_r		(se1_for_nA_vc1_r),
	  .se_for_nA_vc1_h		(se1_for_nA_vc1_h),
	  .se_for_nA_vc1_d		(se1_for_nA_vc1_d[32:0]),
	  .se_for_nB_vc1_r		(se1_for_nB_vc1_r),
	  .se_for_nB_vc1_h		(se1_for_nB_vc1_h),
	  .se_for_nB_vc1_d		(se1_for_nB_vc1_d[32:0]),
       
       //.se_for_ep0_vc3_r		(se1_for_ep0_vc3_r),
       .se_for_ep0_vc3_d		(se1_for_ep0_vc3_d[121:0]),
       .se_for_ep0_vc3_full		(se1_for_ep0_vc3_full),
       //.se_for_ep1_vc3_r		(se1_for_ep1_vc3_r),
       .se_for_ep1_vc3_d		(se1_for_ep1_vc3_d[121:0]),
       .se_for_ep1_vc3_full		(se1_for_ep1_vc3_full),
       // .se_for_ep2_vc3_r		(se1_for_ep2_vc3_r),
       .se_for_ep2_vc3_d		(se1_for_ep2_vc3_d[121:0]),
       .se_for_ep2_vc3_full	        (se1_for_ep2_vc3_full),
       // .se_for_ep3_vc3_r		(se1_for_ep3_vc3_r),
       .se_for_ep3_vc3_d		(se1_for_ep3_vc3_d[121:0]),
       .se_for_ep3_vc3_full		(se1_for_ep3_vc3_full),
       
	  .se_for_nA_vc3_r		(se1_for_nA_vc3_r),
	  .se_for_nA_vc3_h		(se1_for_nA_vc3_h),
	  .se_for_nA_vc3_d		(se1_for_nA_vc3_d[32:0]),
	  .se_for_nB_vc3_r		(se1_for_nB_vc3_r),
	  .se_for_nB_vc3_h		(se1_for_nB_vc3_h),
	  .se_for_nB_vc3_d		(se1_for_nB_vc3_d[32:0]),
	  .se_mem_req			(se1_mem_req),
	  .se_mem_wen_b			(se1_mem_wen_b),
	  .se_mem_addr			(se1_mem_addr[15:0]),
	  .se_mem_write_data		(se1_mem_write_data[63:0]),
	  .se_mem_write_mask		(se1_mem_write_mask[63:0]),
	  // Inputs
	  .CLK				(CLK),
	  .rst				(rst),
       .ep0_to_se_vc0_d		(122'd0),
       .ep0_to_se_vc0_full		(1'b0),
       .ep1_to_se_vc0_full		(1'b0),
       .ep1_to_se_vc0_d		(122'd0),
       .ep2_to_se_vc0_full		(1'b0),
       .ep2_to_se_vc0_d		(122'd0),
       .ep3_to_se_vc0_full		(1'b0),
       .ep3_to_se_vc0_d		(122'd0),
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
	  .se_for_ep0_vc3_gnt		(1'b0),
	  .se_for_ep1_vc3_gnt		(1'b0),
	  .se_for_ep2_vc3_gnt		(1'b0),
	  .se_for_ep3_vc3_gnt		(1'b0),
	  .se_for_nA_vc3_gnt		(se1_for_nA_vc3_gnt),
	  .se_for_nB_vc3_gnt		(se1_for_nB_vc3_gnt),
	  .se_mem_read_data		(se1_mem_read_data[63:0]),
	  .se_mem_gnt			(se1_mem_gnt));
   /*
   se #(.who_am_i(`OCM_NODE_OCM_SD2), 
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
   se2(
	  // Outputs
	  .ep0_to_se_vc0_read		(ep0_to_se2_vc0_read),
	  .ep1_to_se_vc0_read		(ep1_to_se2_vc0_read),
	  .ep2_to_se_vc0_read		(ep2_to_se2_vc0_read),
	  .ep3_to_se_vc0_read		(ep3_to_se2_vc0_read),
	  .nA_vc0_incoming_read		(se2_nA_vc0_incoming_read),
	  .nB_vc0_incoming_read		(se2_nB_vc0_incoming_read),
	  .nA_vc3_incoming_read		(se2_nA_vc3_incoming_read),
	  .nB_vc3_incoming_read		(se2_nB_vc3_incoming_read),
	  .se_for_nA_vc1_r		(se2_for_nA_vc1_r),
	  .se_for_nA_vc1_h		(se2_for_nA_vc1_h),
	  .se_for_nA_vc1_d		(se2_for_nA_vc1_d[32:0]),
	  .se_for_nB_vc1_r		(se2_for_nB_vc1_r),
	  .se_for_nB_vc1_h		(se2_for_nB_vc1_h),
	  .se_for_nB_vc1_d		(se2_for_nB_vc1_d[32:0]),
       
       .se_for_ep0_vc3_d		(se2_for_ep0_vc3_d[121:0]),
       .se_for_ep0_vc3_full		(se2_for_ep0_vc3_full),
       .se_for_ep1_vc3_d		(se2_for_ep1_vc3_d[121:0]),
       .se_for_ep1_vc3_full		(se2_for_ep1_vc3_full),
       .se_for_ep2_vc3_d		(se2_for_ep2_vc3_d[121:0]),
       .se_for_ep2_vc3_full		(se2_for_ep2_vc3_full),
       .se_for_ep3_vc3_d		(se2_for_ep3_vc3_d[121:0]),
       .se_for_ep3_vc3_full		(se2_for_ep3_vc3_full),
       .se_for_nA_vc3_r		(se2_for_nA_vc3_r),
	  .se_for_nA_vc3_h		(se2_for_nA_vc3_h),
	  .se_for_nA_vc3_d		(se2_for_nA_vc3_d[32:0]),
	  .se_for_nB_vc3_r		(se2_for_nB_vc3_r),
	  .se_for_nB_vc3_h		(se2_for_nB_vc3_h),
	  .se_for_nB_vc3_d		(se2_for_nB_vc3_d[32:0]),
	  .se_mem_req			(se2_mem_req),
	  .se_mem_wen_b			(se2_mem_wen_b),
	  .se_mem_addr			(se2_mem_addr[15:0]),
	  .se_mem_write_data		(se2_mem_write_data[63:0]),
	  .se_mem_write_mask		(se2_mem_write_mask[63:0]),
	  // Inputs
	  .CLK				(CLK),
	  .rst				(rst),
	  .ep0_to_se_vc0_d		(122'd0),
	  .ep0_to_se_vc0_full		(1'b0),
	  .ep1_to_se_vc0_full		(1'b0),
	  .ep1_to_se_vc0_d		(122'd0),
	  .ep2_to_se_vc0_full		(1'b0),
	  .ep2_to_se_vc0_d		(122'd0),
	  .ep3_to_se_vc0_full		(1'b0),
	  .ep3_to_se_vc0_d		(122'd0),
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
	  .se_for_ep0_vc3_gnt		(1'b0),
	  .se_for_ep1_vc3_gnt		(1'b0),
	  .se_for_ep2_vc3_gnt		(1'b0),
	  .se_for_ep3_vc3_gnt		(1'b0),
	  .se_for_nA_vc3_gnt		(se2_for_nA_vc3_gnt),
	  .se_for_nB_vc3_gnt		(se2_for_nB_vc3_gnt),
	  .se_mem_read_data		(se2_mem_read_data[63:0]),
	  .se_mem_gnt			(se2_mem_gnt));
   
   se #(.who_am_i(`OCM_NODE_OCM_SD3), 
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
   se3(
       // Outputs
       .ep0_to_se_vc0_read		(ep0_to_se3_vc0_read),//
	  .ep1_to_se_vc0_read		(ep1_to_se3_vc0_read),//
	  .ep2_to_se_vc0_read		(ep2_to_se3_vc0_read),//
	  .ep3_to_se_vc0_read		(ep3_to_se3_vc0_read),//
	  .nA_vc0_incoming_read		(se3_nA_vc0_incoming_read),//
	  .nB_vc0_incoming_read		(se3_nB_vc0_incoming_read),//
	  .nA_vc3_incoming_read		(se3_nA_vc3_incoming_read),//
	  .nB_vc3_incoming_read		(se3_nB_vc3_incoming_read),//
	  .se_for_nA_vc1_r		(se3_for_nA_vc1_r), //
	  .se_for_nA_vc1_h		(se3_for_nA_vc1_h), //
	  .se_for_nA_vc1_d		(se3_for_nA_vc1_d[32:0]), //
	  .se_for_nB_vc1_r		(se3_for_nB_vc1_r), //
	  .se_for_nB_vc1_h		(se3_for_nB_vc1_h), // 
	  .se_for_nB_vc1_d		(se3_for_nB_vc1_d[32:0]),//
       .se_for_ep0_vc3_d		(se3_for_ep0_vc3_d[121:0]),//
       .se_for_ep0_vc3_full		(se3_for_ep0_vc3_full),//
       .se_for_ep1_vc3_d		(se3_for_ep1_vc3_d[121:0]),//
       .se_for_ep1_vc3_full		(se3_for_ep1_vc3_full),//
       .se_for_ep2_vc3_d		(se3_for_ep2_vc3_d[121:0]),//
       .se_for_ep2_vc3_full		(se3_for_ep2_vc3_full),//
       .se_for_ep3_vc3_d		(se3_for_ep3_vc3_d[121:0]),//
       .se_for_ep3_vc3_full		(se3_for_ep3_vc3_full),//
	  .se_for_nA_vc3_r		(se3_for_nA_vc3_r),//
	  .se_for_nA_vc3_h		(se3_for_nA_vc3_h),//
	  .se_for_nA_vc3_d		(se3_for_nA_vc3_d[32:0]),//
	  .se_for_nB_vc3_r		(se3_for_nB_vc3_r),//
	  .se_for_nB_vc3_h		(se3_for_nB_vc3_h),//
	  .se_for_nB_vc3_d		(se3_for_nB_vc3_d[32:0]),//
	  .se_mem_req			(se3_mem_req),//
	  .se_mem_wen_b			(se3_mem_wen_b),//
	  .se_mem_addr			(se3_mem_addr[15:0]),//
	  .se_mem_write_data		(se3_mem_write_data[63:0]),//
	  .se_mem_write_mask		(se3_mem_write_mask[63:0]),//
	  // Inputs
       .CLK				(CLK),
       .rst				(rst),
       .ep0_to_se_vc0_d		(122'd0),
       .ep0_to_se_vc0_full		(1'b0),
       .ep1_to_se_vc0_full		(1'b0),
       .ep1_to_se_vc0_d		(122'd0),
       .ep2_to_se_vc0_full		(1'b0),
       .ep2_to_se_vc0_d		(122'd0),
       .ep3_to_se_vc0_full		(1'd0),
       .ep3_to_se_vc0_d		(122'd0),
       .nA_vc0_incoming_e		(se3_nA_vc0_incoming_e),//
       .nA_vc0_incoming_d		(se3_nA_vc0_incoming_d[32:0]),//
       .nB_vc0_incoming_e		(se3_nB_vc0_incoming_e),//
       .nB_vc0_incoming_d		(se3_nB_vc0_incoming_d[32:0]),//
       .nA_vc3_incoming_e		(se3_nA_vc3_incoming_e),//
       .nA_vc3_incoming_d		(se3_nA_vc3_incoming_d[32:0]),//
       .nB_vc3_incoming_e		(se3_nB_vc3_incoming_e),//
       .nB_vc3_incoming_d		(se3_nB_vc3_incoming_d[32:0]),//
       .se_for_nA_vc1_gnt		(se3_for_nA_vc1_gnt),//
       .se_for_nB_vc1_gnt		(se3_for_nB_vc1_gnt),//
       .se_for_ep0_vc3_gnt		(1'b0),
       .se_for_ep1_vc3_gnt		(1'b0),
       .se_for_ep2_vc3_gnt		(1'b0),
       .se_for_ep3_vc3_gnt		(1'b0),
       .se_for_nA_vc3_gnt		(se3_for_nA_vc3_gnt),//
       .se_for_nB_vc3_gnt		(se3_for_nB_vc3_gnt),//
       .se_mem_read_data		(se3_mem_read_data[63:0]),//
	  .se_mem_gnt			(se3_mem_gnt));//

   */
   all_port_ni the_ni(/**/
		      //Network Outs
		      .gated_outgoing_A	(gated_outgoing_A[34:0]),
		      .ungated_outgoing_A(ungated_outgoing_A[4:0]),
		      .gated_outgoing_B	(gated_outgoing_B[34:0]),
		      .ungated_outgoing_B(ungated_outgoing_B[4:0]),
		      //Thow aways
		      .epe_sm0g_for_nA_vc0_gnt(epe_sm0g_for_nA_vc0_gnt),
		      .epe_sm0g_for_nB_vc0_gnt(epe_sm0g_for_nB_vc0_gnt),
		      .epe_1g_for_nA_vc1_gnt(epe_1g_for_nA_vc1_gnt),
		      .epe_1g_for_nB_vc1_gnt(epe_1g_for_nB_vc1_gnt),
		      //State machines
		      .nie_sm1_for_nA_vc2_gnt(nie_sm1_for_nA_vc2_gnt),
		      .nie_sm1_for_nB_vc2_gnt(nie_sm1_for_nB_vc2_gnt),
		      .nie_sm1_for_nA_vc3_gnt(nie_sm1_for_nA_vc3_gnt),
		      .nie_sm2_for_nA_vc3_gnt(nie_sm2_for_nA_vc3_gnt),
		      .nie_sm1_for_nB_vc3_gnt(nie_sm1_for_nB_vc3_gnt),
		      .nie_sm2_for_nB_vc3_gnt(nie_sm2_for_nB_vc3_gnt),
		      //stream engine engine
		      .see_for_nA_vc1_gnt(see_for_nA_vc1_gnt),
		      .see_for_nB_vc1_gnt(see_for_nB_vc1_gnt),
		      .see_for_nA_vc3_gnt(see_for_nA_vc3_gnt),
		      .see_for_nB_vc3_gnt(see_for_nB_vc3_gnt),
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
		      .epe_sm0g_for_nA_vc0_r(1'b0),
		      .epe_sm0g_for_nA_vc0_h(1'b0),
		      .epe_sm0g_for_nA_vc0_d(33'd0),
		      .epe_sm0g_for_nB_vc0_r(1'b0),
		      .epe_sm0g_for_nB_vc0_h(1'b0),
		      .epe_sm0g_for_nB_vc0_d(33'd0),
		      .epe_1g_for_nA_vc1_r(1'b0),
		      .epe_1g_for_nA_vc1_h(1'b0),
		      .epe_1g_for_nA_vc1_d(33'd0),
		      .see_for_nA_vc1_r	(see_for_nA_vc1_r),
		      .see_for_nA_vc1_h	(see_for_nA_vc1_h),
		      .see_for_nA_vc1_d	(see_for_nA_vc1_d[32:0]),
		      .epe_1g_for_nB_vc1_r(1'b0),
		      .epe_1g_for_nB_vc1_h(1'b0),
		      .epe_1g_for_nB_vc1_d(33'd0),
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
   
   ocm_controller the_mem(/**/
			  // Outputs
			  .test_tile_read_data(test_tile_read_data[63:0]),
			  .nie_sm1_mem_read_data(nie_sm1_mem_read_data[63:0]),
			  .nie_sm1_mem_gnt(nie_sm1_mem_gnt),
			  .nie_sm2_mem_read_data(nie_sm2_mem_read_data[63:0]),
			  .nie_sm2_mem_gnt(nie_sm2_mem_gnt),
			  .se0_mem_read_data(se0_mem_read_data[63:0]),
			  .se0_mem_gnt	(se0_mem_gnt),
			  .se1_mem_read_data(se1_mem_read_data[63:0]),
			  .se1_mem_gnt	(se1_mem_gnt),
			  //.se2_mem_read_data(se2_mem_read_data[63:0]),
			  //.se2_mem_gnt	(se2_mem_gnt),
			  //.se3_mem_read_data(se3_mem_read_data[63:0]),
			  //.se3_mem_gnt	(se3_mem_gnt),
			  // Inputs
			  .CLK		(CLK),
			  .rst		(rst),
			  .TEST_MODE	(TEST_MODE),
			  .test_tile_addr(test_tile_addr[11:0]),
			  .test_tile_csn(test_tile_csn),
			  .test_tile_write_data(test_tile_write_data[63:0]),
			  .test_tile_write_mask(test_tile_write_mask[63:0]),
			  .test_tile_wen_b(test_tile_wen_b),
			  .nie_sm1_mem_req(nie_sm1_mem_req),
			  .nie_sm1_mem_addr(nie_sm1_mem_addr[15:0]),
			  .nie_sm1_mem_wen_b(nie_sm1_mem_wen_b),
			  .nie_sm1_mem_write_data(nie_sm1_mem_write_data[63:0]),
			  .nie_sm1_mem_write_mask(nie_sm1_mem_write_mask[63:0]),
			  .nie_sm1_mem_lock(nie_sm1_mem_lock),
			  .nie_sm2_mem_req(nie_sm2_mem_req),
			  .nie_sm2_mem_addr(nie_sm2_mem_addr[15:0]),
			  .nie_sm2_mem_wen_b(nie_sm2_mem_wen_b),
			  .nie_sm2_mem_write_data(nie_sm2_mem_write_data[63:0]),
			  .nie_sm2_mem_write_mask(nie_sm2_mem_write_mask[63:0]),
			  .se0_mem_req	(se0_mem_req),
			  .se0_mem_wen_b(se0_mem_wen_b),
			  .se0_mem_addr	(se0_mem_addr[15:0]),
			  .se0_mem_write_data(se0_mem_write_data[63:0]),
			  .se0_mem_write_mask(se0_mem_write_mask[63:0]),
			  .se1_mem_req (se1_mem_req),
			  .se1_mem_wen_b(se1_mem_wen_b),
			  .se1_mem_addr	(se1_mem_addr[15:0]),
			  .se1_mem_write_data(se1_mem_write_data[63:0]),
			  .se1_mem_write_mask(se1_mem_write_mask[63:0]));
   
			  //.se2_mem_req	(se2_mem_req),
			  //.se2_mem_wen_b(se2_mem_wen_b),
			  //.se2_mem_addr	(se2_mem_addr[15:0]),
			  //.se2_mem_write_data(se2_mem_write_data[63:0]),
			  //.se2_mem_write_mask(se2_mem_write_mask[63:0]),
			  //.se3_mem_req	(se3_mem_req),
			  //.se3_mem_wen_b(se3_mem_wen_b),
			  //.se3_mem_addr	(se3_mem_addr[15:0]),
			  //.se3_mem_write_mask(se3_mem_write_mask[63:0]),
   			  //.se3_mem_write_data(se3_mem_write_data[63:0]));

   

endmodule // ocm_top_level
