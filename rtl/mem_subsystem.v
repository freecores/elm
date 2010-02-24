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


module mem_subsystem(/*AUTOARG*/
   // Outputs
   test_e0_b0_read_data, test_e0_b1_read_data, test_e0_b2_read_data, 
   test_e0_b3_read_data, test_e1_b0_read_data, test_e1_b1_read_data, 
   test_e1_b2_read_data, test_e1_b3_read_data, test_tile_read_data, 
   e0_ep0_inbox_read, e0_ep1_inbox_read, e0_ep2_inbox_read, 
   e0_ep3_inbox_read, e1_ep0_inbox_read, e1_ep1_inbox_read, 
   e1_ep2_inbox_read, e1_ep3_inbox_read, e0_ep0_outbox, 
   e0_ep1_outbox, e0_ep2_outbox, e0_ep3_outbox, e1_ep0_outbox, 
   e1_ep1_outbox, e1_ep2_outbox, e1_ep3_outbox, e0_ep0_irf_read_data, 
   e0_ep1_irf_read_data, e0_ep2_irf_read_data, e0_ep3_irf_read_data, 
   e0_ep0_irf_gnt_late, e0_ep1_irf_gnt_late, e0_ep2_irf_gnt_late, 
   e0_ep3_irf_gnt_late, e1_ep0_irf_read_data, e1_ep1_irf_read_data, 
   e1_ep2_irf_read_data, e1_ep3_irf_read_data, e1_ep0_irf_gnt_late, 
   e1_ep1_irf_gnt_late, e1_ep2_irf_gnt_late, e1_ep3_irf_gnt_late, 
   e0_ep0_xmu_read_data, e0_ep1_xmu_read_data, e0_ep2_xmu_read_data, 
   e0_ep3_xmu_read_data, e0_ep0_xmu_gnt_late, e0_ep1_xmu_gnt_late, 
   e0_ep2_xmu_gnt_late, e0_ep3_xmu_gnt_late, e1_ep0_xmu_read_data, 
   e1_ep1_xmu_read_data, e1_ep2_xmu_read_data, e1_ep3_xmu_read_data, 
   e1_ep0_xmu_gnt_late, e1_ep1_xmu_gnt_late, e1_ep2_xmu_gnt_late, 
   e1_ep3_xmu_gnt_late, 
   // Inputs
   CLK, rst, TEST_MODE, test_e0_b0_csn, test_e0_b0_addr, 
   test_e0_b0_write_data, test_e0_b0_write_mask, test_e0_b0_wen_b, 
   test_e0_b1_csn, test_e0_b1_addr, test_e0_b1_write_data, 
   test_e0_b1_write_mask, test_e0_b1_wen_b, test_e0_b2_csn, 
   test_e0_b2_addr, test_e0_b2_write_data, test_e0_b2_write_mask, 
   test_e0_b2_wen_b, test_e0_b3_csn, test_e0_b3_addr, 
   test_e0_b3_write_data, test_e0_b3_write_mask, test_e0_b3_wen_b, 
   test_e1_b0_csn, test_e1_b0_addr, test_e1_b0_write_data, 
   test_e1_b0_write_mask, test_e1_b0_wen_b, test_e1_b1_csn, 
   test_e1_b1_addr, test_e1_b1_write_data, test_e1_b1_write_mask, 
   test_e1_b1_wen_b, test_e1_b2_csn, test_e1_b2_addr, 
   test_e1_b2_write_data, test_e1_b2_write_mask, test_e1_b2_wen_b, 
   test_e1_b3_csn, test_e1_b3_addr, test_e1_b3_write_data, 
   test_e1_b3_write_mask, test_e1_b3_wen_b, test_tile_addr, 
   test_tile_csn, test_tile_write_data, test_tile_write_mask, 
   test_tile_wen_b, e0_ep0_inbox, e0_ep1_inbox, e0_ep2_inbox, 
   e0_ep3_inbox, e1_ep0_inbox, e1_ep1_inbox, e1_ep2_inbox, 
   e1_ep3_inbox, e0_ep0_outbox_read, e0_ep1_outbox_read, 
   e0_ep2_outbox_read, e0_ep3_outbox_read, e1_ep0_outbox_read, 
   e1_ep1_outbox_read, e1_ep2_outbox_read, e1_ep3_outbox_read, 
   e0_ep0_irf_req, e0_ep0_irf_addr, e0_ep1_irf_req, e0_ep1_irf_addr, 
   e0_ep2_irf_req, e0_ep2_irf_addr, e0_ep3_irf_req, e0_ep3_irf_addr, 
   e1_ep0_irf_req, e1_ep0_irf_addr, e1_ep1_irf_req, e1_ep1_irf_addr, 
   e1_ep2_irf_req, e1_ep2_irf_addr, e1_ep3_irf_req, e1_ep3_irf_addr, 
   e0_ep0_xmu_req, e0_ep0_xmu_addr, e0_ep0_xmu_ld, e0_ep0_xmu_st, 
   e0_ep0_xmu_write_data, e0_ep1_xmu_req, e0_ep1_xmu_addr, 
   e0_ep1_xmu_ld, e0_ep1_xmu_st, e0_ep1_xmu_write_data, 
   e0_ep2_xmu_req, e0_ep2_xmu_addr, e0_ep2_xmu_ld, e0_ep2_xmu_st, 
   e0_ep2_xmu_write_data, e0_ep3_xmu_req, e0_ep3_xmu_addr, 
   e0_ep3_xmu_ld, e0_ep3_xmu_st, e0_ep3_xmu_write_data, 
   e1_ep0_xmu_req, e1_ep0_xmu_addr, e1_ep0_xmu_ld, e1_ep0_xmu_st, 
   e1_ep0_xmu_write_data, e1_ep1_xmu_req, e1_ep1_xmu_addr, 
   e1_ep1_xmu_ld, e1_ep1_xmu_st, e1_ep1_xmu_write_data, 
   e1_ep2_xmu_req, e1_ep2_xmu_addr, e1_ep2_xmu_ld, e1_ep2_xmu_st, 
   e1_ep2_xmu_write_data, e1_ep3_xmu_req, e1_ep3_xmu_addr, 
   e1_ep3_xmu_ld, e1_ep3_xmu_st, e1_ep3_xmu_write_data
   );

   input CLK;
   input rst;
   input TEST_MODE;

   input test_e0_b0_csn;
   input [7:0] test_e0_b0_addr;
   input [63:0] test_e0_b0_write_data;
   input [63:0] test_e0_b0_write_mask;
   input 	test_e0_b0_wen_b;
   input 	test_e0_b1_csn;
   input [7:0] 	test_e0_b1_addr;
   input [63:0] test_e0_b1_write_data;
   input [63:0] test_e0_b1_write_mask;
   input 	test_e0_b1_wen_b;
   input 	test_e0_b2_csn;
   input [7:0] 	test_e0_b2_addr;
   input [63:0] test_e0_b2_write_data;
   input [63:0] test_e0_b2_write_mask;
   input 	test_e0_b2_wen_b;
   input 	test_e0_b3_csn;
   input [7:0] 	test_e0_b3_addr;
   input [63:0] test_e0_b3_write_data;
   input [63:0] test_e0_b3_write_mask;
   input 	test_e0_b3_wen_b;

   input 	test_e1_b0_csn;
   input [7:0] 	test_e1_b0_addr;
   input [63:0] test_e1_b0_write_data;
   input [63:0] test_e1_b0_write_mask;
   input 	test_e1_b0_wen_b;
   input 	test_e1_b1_csn;
   input [7:0] 	test_e1_b1_addr;
   input [63:0] test_e1_b1_write_data;
   input [63:0] test_e1_b1_write_mask;
   input 	test_e1_b1_wen_b;
   input 	test_e1_b2_csn;
   input [7:0] 	test_e1_b2_addr;
   input [63:0] test_e1_b2_write_data;
   input [63:0] test_e1_b2_write_mask;
   input 	test_e1_b2_wen_b;
   input 	test_e1_b3_csn;
   input [7:0] 	test_e1_b3_addr;
   input [63:0] test_e1_b3_write_data;
   input [63:0] test_e1_b3_write_mask;
   input 	test_e1_b3_wen_b;

   
   output [63:0] test_e0_b0_read_data;
   output [63:0] test_e0_b1_read_data;
   output [63:0] test_e0_b2_read_data;
   output [63:0] test_e0_b3_read_data;
   output [63:0] test_e1_b0_read_data;
   output [63:0] test_e1_b1_read_data;
   output [63:0] test_e1_b2_read_data;
   output [63:0] test_e1_b3_read_data;
   
   output [63:0] test_tile_read_data;
   input [11:0]  test_tile_addr;
   input 	 test_tile_csn;
   input [63:0]  test_tile_write_data;
   input [63:0]  test_tile_write_mask;
   input 	 test_tile_wen_b;

   input [124:0] e0_ep0_inbox;
   input [124:0] e0_ep1_inbox;
   input [124:0] e0_ep2_inbox;
   input [124:0] e0_ep3_inbox;
   input [124:0] e1_ep0_inbox;
   input [124:0] e1_ep1_inbox;
   input [124:0] e1_ep2_inbox;
   input [124:0] e1_ep3_inbox;
   output 	 e0_ep0_inbox_read;
   output 	 e0_ep1_inbox_read;
   output 	 e0_ep2_inbox_read;
   output 	 e0_ep3_inbox_read;
   output 	 e1_ep0_inbox_read;
   output 	 e1_ep1_inbox_read;
   output 	 e1_ep2_inbox_read;
   output 	 e1_ep3_inbox_read;
   
   output [124:0] e0_ep0_outbox;
   output [124:0] e0_ep1_outbox;
   output [124:0] e0_ep2_outbox;
   output [124:0] e0_ep3_outbox;
   output [124:0] e1_ep0_outbox;
   output [124:0] e1_ep1_outbox;
   output [124:0] e1_ep2_outbox;
   output [124:0] e1_ep3_outbox;
   input 	  e0_ep0_outbox_read;
   input 	  e0_ep1_outbox_read;
   input 	  e0_ep2_outbox_read;
   input 	  e0_ep3_outbox_read;
   input 	  e1_ep0_outbox_read;
   input 	  e1_ep1_outbox_read;
   input 	  e1_ep2_outbox_read;
   input 	  e1_ep3_outbox_read;

   input 	  e0_ep0_irf_req;
   input [15:0]   e0_ep0_irf_addr;
   input 	  e0_ep1_irf_req;
   input [15:0]   e0_ep1_irf_addr;
   input 	  e0_ep2_irf_req;
   input [15:0]   e0_ep2_irf_addr;
   input 	  e0_ep3_irf_req;
   input [15:0]   e0_ep3_irf_addr;
   input 	  e1_ep0_irf_req;
   input [15:0]   e1_ep0_irf_addr;
   input 	  e1_ep1_irf_req;
   input [15:0]   e1_ep1_irf_addr;
   input 	  e1_ep2_irf_req;
   input [15:0]   e1_ep2_irf_addr;
   input 	  e1_ep3_irf_req;
   input [15:0]   e1_ep3_irf_addr;
   output [31:0]  e0_ep0_irf_read_data;
   output [31:0]  e0_ep1_irf_read_data;
   output [31:0]  e0_ep2_irf_read_data;
   output [31:0]  e0_ep3_irf_read_data;
   output 	  e0_ep0_irf_gnt_late;
   output 	  e0_ep1_irf_gnt_late;
   output 	  e0_ep2_irf_gnt_late;
   output 	  e0_ep3_irf_gnt_late;
   output [31:0]  e1_ep0_irf_read_data;
   output [31:0]  e1_ep1_irf_read_data;
   output [31:0]  e1_ep2_irf_read_data;
   output [31:0]  e1_ep3_irf_read_data;
   output 	  e1_ep0_irf_gnt_late;
   output 	  e1_ep1_irf_gnt_late;
   output 	  e1_ep2_irf_gnt_late;
   output 	  e1_ep3_irf_gnt_late;

   input 	  e0_ep0_xmu_req;
   input [15:0]   e0_ep0_xmu_addr;
   input 	  e0_ep0_xmu_ld;
   input 	  e0_ep0_xmu_st;
   input [63:0]   e0_ep0_xmu_write_data;
   input 	  e0_ep1_xmu_req;
   input [15:0]   e0_ep1_xmu_addr;
   input 	  e0_ep1_xmu_ld;
   input 	  e0_ep1_xmu_st;
   input [63:0]   e0_ep1_xmu_write_data;
   input 	  e0_ep2_xmu_req;
   input [15:0]   e0_ep2_xmu_addr;
   input 	  e0_ep2_xmu_ld;
   input 	  e0_ep2_xmu_st;
   input [63:0]   e0_ep2_xmu_write_data;
   input 	  e0_ep3_xmu_req;
   input [15:0]   e0_ep3_xmu_addr;
   input 	  e0_ep3_xmu_ld;
   input 	  e0_ep3_xmu_st;
   input [63:0]   e0_ep3_xmu_write_data;
   input 	  e1_ep0_xmu_req;
   input [15:0]   e1_ep0_xmu_addr;
   input 	  e1_ep0_xmu_ld;
   input 	  e1_ep0_xmu_st;
   input [63:0]   e1_ep0_xmu_write_data;
   input 	  e1_ep1_xmu_req;
   input [15:0]   e1_ep1_xmu_addr;
   input 	  e1_ep1_xmu_ld;
   input 	  e1_ep1_xmu_st;
   input [63:0]   e1_ep1_xmu_write_data;
   input 	  e1_ep2_xmu_req;
   input [15:0]   e1_ep2_xmu_addr;
   input 	  e1_ep2_xmu_ld;
   input 	  e1_ep2_xmu_st;
   input [63:0]   e1_ep2_xmu_write_data;
   input 	  e1_ep3_xmu_req;
   input [15:0]   e1_ep3_xmu_addr;
   input 	  e1_ep3_xmu_ld;
   input 	  e1_ep3_xmu_st;
   input [63:0]   e1_ep3_xmu_write_data;
  
   output [31:0]  e0_ep0_xmu_read_data;
   output [31:0]  e0_ep1_xmu_read_data;
   output [31:0]  e0_ep2_xmu_read_data;
   output [31:0]  e0_ep3_xmu_read_data;
   output 	  e0_ep0_xmu_gnt_late;
   output 	  e0_ep1_xmu_gnt_late;
   output 	  e0_ep2_xmu_gnt_late;
   output 	  e0_ep3_xmu_gnt_late;
   output [31:0]  e1_ep0_xmu_read_data;
   output [31:0]  e1_ep1_xmu_read_data;
   output [31:0]  e1_ep2_xmu_read_data;
   output [31:0]  e1_ep3_xmu_read_data;
   output 	  e1_ep0_xmu_gnt_late;
   output 	  e1_ep1_xmu_gnt_late;
   output 	  e1_ep2_xmu_gnt_late;
   output 	  e1_ep3_xmu_gnt_late;

   
   
   wire [34:0] 	  e0_2_ocm_gated;
   wire [4:0] 	 e0_2_ocm_ungated;
   wire [34:0] 	 e0_2_e1_gated;
   wire [4:0] 	 e0_2_e1_ungated;

   wire [34:0] 	 ocm_2_e0_gated;
   wire [4:0] 	 ocm_2_e0_ungated;
   wire [34:0] 	 ocm_2_e1_gated;
   wire [4:0] 	 ocm_2_e1_ungated;
   
   wire [34:0] 	 e1_2_e0_gated;
   wire [4:0] 	 e1_2_e0_ungated;
   wire [34:0] 	 e1_2_ocm_gated;
   wire [4:0] 	 e1_2_ocm_ungated;

   
   reg [34:0] 	 e0_2_ocm_gated_delay;
   reg [4:0] 	 e0_2_ocm_ungated_delay;
   reg [34:0] 	 e0_2_e1_gated_delay;
   reg [4:0] 	 e0_2_e1_ungated_delay;

   reg [34:0] 	 ocm_2_e0_gated_delay;
   reg [4:0] 	 ocm_2_e0_ungated_delay;
   reg [34:0] 	 ocm_2_e1_gated_delay;
   reg [4:0] 	 ocm_2_e1_ungated_delay;

   reg [34:0] 	 e1_2_e0_gated_delay;
   reg [4:0] 	 e1_2_e0_ungated_delay;
   reg [34:0] 	 e1_2_ocm_gated_delay;
   reg [4:0] 	 e1_2_ocm_ungated_delay;

   always@(posedge CLK or posedge rst) begin
      if(rst) begin
	 e0_2_ocm_gated_delay <= 35'd0;
	 e0_2_ocm_ungated_delay <= 5'd0;
	 e0_2_e1_gated_delay <= 35'd0;
	 e0_2_e1_ungated_delay <= 5'd0;
	 ocm_2_e0_gated_delay <= 35'd0;
	 ocm_2_e0_ungated_delay <= 5'd0;
	 ocm_2_e1_gated_delay <= 35'd0;
	 ocm_2_e1_ungated_delay <= 5'd0;
	 e1_2_e0_gated_delay <= 35'd0;
	 e1_2_e0_ungated_delay <= 5'd0;
	 e1_2_ocm_gated_delay <= 35'd0;
	 e1_2_ocm_ungated_delay <= 5'd0;
      end // if (rst)
      else
	begin
	   e0_2_ocm_ungated_delay <= e0_2_ocm_ungated;
	   e0_2_e1_ungated_delay <= e0_2_e1_ungated;
	   ocm_2_e0_ungated_delay <= ocm_2_e0_ungated;
	   ocm_2_e1_ungated_delay <= ocm_2_e1_ungated;
	   e1_2_e0_ungated_delay <= e1_2_e0_ungated;
	   e1_2_ocm_ungated_delay <= e1_2_ocm_ungated;
	   //if(e0_2_ocm_ungated[0])
	   e0_2_ocm_gated_delay <= e0_2_ocm_ungated[0] ? e0_2_ocm_gated : e0_2_ocm_gated_delay;
	   if(e0_2_e1_ungated[0])
	     e0_2_e1_gated_delay <= e0_2_e1_gated;
	   if(ocm_2_e0_ungated[0])
	     ocm_2_e0_gated_delay <= ocm_2_e0_gated;
	   if(ocm_2_e1_ungated[0])
	     ocm_2_e1_gated_delay <= ocm_2_e1_gated;
	   if(e1_2_e0_ungated[0])
	     e1_2_e0_gated_delay <= e1_2_e0_gated;
	   if(e1_2_ocm_ungated[0])
	     e1_2_ocm_gated_delay <= e1_2_ocm_gated;
	end // else: !if(rst)
   end // always@ (posedge CLK)
   
   
  
   e0_top_level the_ens0(
			 // Outputs
			 .test_b0_read_data(test_e0_b0_read_data[63:0]), //
			 .test_b1_read_data(test_e0_b1_read_data[63:0]), //
			 .test_b2_read_data(test_e0_b2_read_data[63:0]), //
			 .test_b3_read_data(test_e0_b3_read_data[63:0]), //
			 .gated_outgoing_A(e0_2_ocm_gated[34:0]), //
			 .ungated_outgoing_A(e0_2_ocm_ungated[4:0]), //
			 .gated_outgoing_B(e0_2_e1_gated[34:0]), //
			 .ungated_outgoing_B(e0_2_e1_ungated[4:0]), //
			 .ep0_inbox_read(e0_ep0_inbox_read), //
			 .ep1_inbox_read(e0_ep1_inbox_read), //
			 .ep2_inbox_read(e0_ep2_inbox_read), //
			 .ep3_inbox_read(e0_ep3_inbox_read), //
			 .ep0_outbox	(e0_ep0_outbox[124:0]), //
			 .ep1_outbox	(e0_ep1_outbox[124:0]), //
			 .ep2_outbox	(e0_ep2_outbox[124:0]), //
			 .ep3_outbox	(e0_ep3_outbox[124:0]), //
			 .ep0_irf_read_data(e0_ep0_irf_read_data[31:0]), //
			 .ep1_irf_read_data(e0_ep1_irf_read_data[31:0]), //
			 .ep2_irf_read_data(e0_ep2_irf_read_data[31:0]), //
			 .ep3_irf_read_data(e0_ep3_irf_read_data[31:0]), //
			 .ep0_irf_gnt_late(e0_ep0_irf_gnt_late), //
			 .ep1_irf_gnt_late(e0_ep1_irf_gnt_late), //
			 .ep2_irf_gnt_late(e0_ep2_irf_gnt_late), //
			 .ep3_irf_gnt_late(e0_ep3_irf_gnt_late), //
			 .ep0_xmu_read_data(e0_ep0_xmu_read_data[31:0]), //
			 .ep1_xmu_read_data(e0_ep1_xmu_read_data[31:0]), //
			 .ep2_xmu_read_data(e0_ep2_xmu_read_data[31:0]), //
			 .ep3_xmu_read_data(e0_ep3_xmu_read_data[31:0]), //
			 .ep0_xmu_gnt_late(e0_ep0_xmu_gnt_late), //
			 .ep1_xmu_gnt_late(e0_ep1_xmu_gnt_late), //
			 .ep2_xmu_gnt_late(e0_ep2_xmu_gnt_late), //
			 .ep3_xmu_gnt_late(e0_ep3_xmu_gnt_late), //
			 // Inputs
			 .CLK		(CLK),
			 .rst		(rst),
			 .TEST_MODE	(TEST_MODE),
			 .test_b0_csn	(test_e0_b0_csn), //
			 .test_b0_addr	(test_e0_b0_addr[7:0]), //
			 .test_b0_write_data(test_e0_b0_write_data[63:0]), //
			 .test_b0_write_mask(test_e0_b0_write_mask[63:0]), //
			 .test_b0_wen_b	(test_e0_b0_wen_b), //
			 .test_b1_csn	(test_e0_b1_csn), //
			 .test_b1_addr	(test_e0_b1_addr[7:0]), //
			 .test_b1_write_data(test_e0_b1_write_data[63:0]), //
			 .test_b1_write_mask(test_e0_b1_write_mask[63:0]), //
			 .test_b1_wen_b	(test_e0_b1_wen_b), //
			 .test_b2_csn	(test_e0_b2_csn), //
			 .test_b2_addr	(test_e0_b2_addr[7:0]), //
			 .test_b2_write_data(test_e0_b2_write_data[63:0]), //
			 .test_b2_write_mask(test_e0_b2_write_mask[63:0]), //
			 .test_b2_wen_b	(test_e0_b2_wen_b), //
			 .test_b3_csn	(test_e0_b3_csn), //
			 .test_b3_addr	(test_e0_b3_addr[7:0]), //
			 .test_b3_write_data(test_e0_b3_write_data[63:0]), //
			 .test_b3_write_mask(test_e0_b3_write_mask[63:0]), //
			 .test_b3_wen_b	(test_e0_b3_wen_b), //
			 .gated_incoming_A(ocm_2_e0_gated_delay[34:0]),    //
			 .ungated_incoming_A(ocm_2_e0_ungated_delay[4:0]), //
			 .gated_incoming_B(e1_2_e0_gated_delay[34:0]),     //
			 .ungated_incoming_B(e1_2_e0_ungated_delay[4:0]),  //
			 .ep0_inbox	(e0_ep0_inbox[124:0]), //
			 .ep1_inbox	(e0_ep1_inbox[124:0]), //
			 .ep2_inbox	(e0_ep2_inbox[124:0]), //
			 .ep3_inbox	(e0_ep3_inbox[124:0]), //
			 .ep0_outbox_read(e0_ep0_outbox_read), //
			 .ep1_outbox_read(e0_ep1_outbox_read), //
			 .ep2_outbox_read(e0_ep2_outbox_read), //
			 .ep3_outbox_read(e0_ep3_outbox_read), //
			 .ep0_irf_req	(e0_ep0_irf_req), //
			 .ep0_irf_addr	(e0_ep0_irf_addr[15:0]), //
			 .ep0_xmu_req	(e0_ep0_xmu_req),
			 .ep0_xmu_addr	(e0_ep0_xmu_addr[15:0]),
			 .ep0_xmu_ld	(e0_ep0_xmu_ld), 
			 .ep0_xmu_st	(e0_ep0_xmu_st),
			 .ep0_xmu_write_data(e0_ep0_xmu_write_data[63:0]),
			 .ep1_irf_req	(e0_ep1_irf_req),
			 .ep1_irf_addr	(e0_ep1_irf_addr[15:0]),
			 .ep1_xmu_req	(e0_ep1_xmu_req),
			 .ep1_xmu_addr	(e0_ep1_xmu_addr[15:0]),
			 .ep1_xmu_ld	(e0_ep1_xmu_ld),
			 .ep1_xmu_st	(e0_ep1_xmu_st),
			 .ep1_xmu_write_data(e0_ep1_xmu_write_data[63:0]),
			 .ep2_irf_req	(e0_ep2_irf_req),
			 .ep2_irf_addr	(e0_ep2_irf_addr[15:0]),
			 .ep2_xmu_req	(e0_ep2_xmu_req),
			 .ep2_xmu_addr	(e0_ep2_xmu_addr[15:0]),
			 .ep2_xmu_ld	(e0_ep2_xmu_ld),
			 .ep2_xmu_st	(e0_ep2_xmu_st),
			 .ep2_xmu_write_data(e0_ep2_xmu_write_data[63:0]),
			 .ep3_irf_req	(e0_ep3_irf_req),
			 .ep3_irf_addr	(e0_ep3_irf_addr[15:0]),
			 .ep3_xmu_req	(e0_ep3_xmu_req),
			 .ep3_xmu_addr	(e0_ep3_xmu_addr[15:0]),
			 .ep3_xmu_ld	(e0_ep3_xmu_ld),
			 .ep3_xmu_st	(e0_ep3_xmu_st),
			 .ep3_xmu_write_data(e0_ep3_xmu_write_data[63:0]));
   e1_top_level the_ens1(
			 // Outputs
			 .test_b0_read_data(test_e1_b0_read_data[63:0]), //
			 .test_b1_read_data(test_e1_b1_read_data[63:0]), //
			 .test_b2_read_data(test_e1_b2_read_data[63:0]), //
			 .test_b3_read_data(test_e1_b3_read_data[63:0]), //
			 .gated_outgoing_A(e1_2_e0_gated[34:0]), //
			 .ungated_outgoing_A(e1_2_e0_ungated[4:0]), //
			 .gated_outgoing_B(e1_2_ocm_gated[34:0]), //
			 .ungated_outgoing_B(e1_2_ocm_ungated[4:0]), //
			 .ep0_inbox_read(e1_ep0_inbox_read),  //
			 .ep1_inbox_read(e1_ep1_inbox_read), //
			 .ep2_inbox_read(e1_ep2_inbox_read), //
			 .ep3_inbox_read(e1_ep3_inbox_read), //
			 .ep0_outbox	(e1_ep0_outbox[124:0]), //
			 .ep1_outbox	(e1_ep1_outbox[124:0]), //
			 .ep2_outbox	(e1_ep2_outbox[124:0]), //
			 .ep3_outbox	(e1_ep3_outbox[124:0]), //
			 .ep0_irf_read_data(e1_ep0_irf_read_data[31:0]), //
			 .ep1_irf_read_data(e1_ep1_irf_read_data[31:0]), //
			 .ep2_irf_read_data(e1_ep2_irf_read_data[31:0]), //
			 .ep3_irf_read_data(e1_ep3_irf_read_data[31:0]), //
			 .ep0_irf_gnt_late(e1_ep0_irf_gnt_late), //
			 .ep1_irf_gnt_late(e1_ep1_irf_gnt_late), //
			 .ep2_irf_gnt_late(e1_ep2_irf_gnt_late), //
			 .ep3_irf_gnt_late(e1_ep3_irf_gnt_late), //
			 .ep0_xmu_read_data(e1_ep0_xmu_read_data[31:0]), //
			 .ep1_xmu_read_data(e1_ep1_xmu_read_data[31:0]),//
			 .ep2_xmu_read_data(e1_ep2_xmu_read_data[31:0]), //
			 .ep3_xmu_read_data(e1_ep3_xmu_read_data[31:0]), //
			 .ep0_xmu_gnt_late(e1_ep0_xmu_gnt_late), //
			 .ep1_xmu_gnt_late(e1_ep1_xmu_gnt_late), //
			 .ep2_xmu_gnt_late(e1_ep2_xmu_gnt_late), //
			 .ep3_xmu_gnt_late(e1_ep3_xmu_gnt_late), //
			 // Inputs
			 .CLK		(CLK),
			 .rst		(rst),
			 .TEST_MODE	(TEST_MODE),
			 .test_b0_csn	(test_e1_b0_csn), //
			 .test_b0_addr	(test_e1_b0_addr[7:0]), //
			 .test_b0_write_data(test_e1_b0_write_data[63:0]), //
			 .test_b0_write_mask(test_e1_b0_write_mask[63:0]), //
			 .test_b0_wen_b	(test_e1_b0_wen_b), //
			 .test_b1_csn	(test_e1_b1_csn), //
			 .test_b1_addr	(test_e1_b1_addr[7:0]), //
			 .test_b1_write_data(test_e1_b1_write_data[63:0]), //
			 .test_b1_write_mask(test_e1_b1_write_mask[63:0]), //
			 .test_b1_wen_b	(test_e1_b1_wen_b), //
			 .test_b2_csn	(test_e1_b2_csn), //
			 .test_b2_addr	(test_e1_b2_addr[7:0]), //
			 .test_b2_write_data(test_e1_b2_write_data[63:0]), //
			 .test_b2_write_mask(test_e1_b2_write_mask[63:0]), //
			 .test_b2_wen_b	(test_e1_b2_wen_b), //
			 .test_b3_csn	(test_e1_b3_csn), //
			 .test_b3_addr	(test_e1_b3_addr[7:0]), //
			 .test_b3_write_data(test_e1_b3_write_data[63:0]), //
			 .test_b3_write_mask(test_e1_b3_write_mask[63:0]), //
			 .test_b3_wen_b	(test_e1_b3_wen_b), //
			 .gated_incoming_A(e0_2_e1_gated_delay[34:0]), //
			 .ungated_incoming_A(e0_2_e1_ungated_delay[4:0]), //
			 .gated_incoming_B(ocm_2_e1_gated_delay[34:0]), //
			 .ungated_incoming_B(ocm_2_e1_ungated_delay[4:0]), //
			 .ep0_inbox	(e1_ep0_inbox[124:0]),
			 .ep1_inbox	(e1_ep1_inbox[124:0]),
			 .ep2_inbox	(e1_ep2_inbox[124:0]),
			 .ep3_inbox	(e1_ep3_inbox[124:0]),
			 .ep0_outbox_read(e1_ep0_outbox_read),
			 .ep1_outbox_read(e1_ep1_outbox_read),
			 .ep2_outbox_read(e1_ep2_outbox_read),
			 .ep3_outbox_read(e1_ep3_outbox_read),
			 .ep0_irf_req	(e1_ep0_irf_req),
			 .ep0_irf_addr	(e1_ep0_irf_addr[15:0]),
			 .ep0_xmu_req	(e1_ep0_xmu_req),
			 .ep0_xmu_addr	(e1_ep0_xmu_addr[15:0]),
			 .ep0_xmu_ld	(e1_ep0_xmu_ld),
			 .ep0_xmu_st	(e1_ep0_xmu_st),
			 .ep0_xmu_write_data(e1_ep0_xmu_write_data[63:0]),
			 .ep1_irf_req	(e1_ep1_irf_req),
			 .ep1_irf_addr	(e1_ep1_irf_addr[15:0]),
			 .ep1_xmu_req	(e1_ep1_xmu_req),
			 .ep1_xmu_addr	(e1_ep1_xmu_addr[15:0]),
			 .ep1_xmu_ld	(e1_ep1_xmu_ld),
			 .ep1_xmu_st	(e1_ep1_xmu_st),
			 .ep1_xmu_write_data(e1_ep1_xmu_write_data[63:0]),
			 .ep2_irf_req	(e1_ep2_irf_req),
			 .ep2_irf_addr	(e1_ep2_irf_addr[15:0]),
			 .ep2_xmu_req	(e1_ep2_xmu_req),
			 .ep2_xmu_addr	(e1_ep2_xmu_addr[15:0]),
			 .ep2_xmu_ld	(e1_ep2_xmu_ld),
			 .ep2_xmu_st	(e1_ep2_xmu_st),
			 .ep2_xmu_write_data(e1_ep2_xmu_write_data[63:0]),
			 .ep3_irf_req	(e1_ep3_irf_req),
			 .ep3_irf_addr	(e1_ep3_irf_addr[15:0]),
			 .ep3_xmu_req	(e1_ep3_xmu_req),
			 .ep3_xmu_addr	(e1_ep3_xmu_addr[15:0]),
			 .ep3_xmu_ld	(e1_ep3_xmu_ld),
			 .ep3_xmu_st	(e1_ep3_xmu_st),
			 .ep3_xmu_write_data(e1_ep3_xmu_write_data[63:0]));
   ocm_top_level the_ocm(//all done
			 // Outputs
			 .test_tile_read_data(test_tile_read_data[63:0]),
			 .gated_outgoing_A(ocm_2_e0_gated[34:0]), //
			 .ungated_outgoing_A(ocm_2_e0_ungated[4:0]), //
			 .gated_outgoing_B(ocm_2_e1_gated[34:0]), //
			 .ungated_outgoing_B(ocm_2_e1_ungated[4:0]), //
			 // Inputs
			 .CLK		(CLK),
			 .rst		(rst),
			 .TEST_MODE	(TEST_MODE),
			 .test_tile_addr(test_tile_addr[11:0]),
			 .test_tile_csn	(test_tile_csn),
			 .test_tile_write_data(test_tile_write_data[63:0]),
			 .test_tile_write_mask(test_tile_write_mask[63:0]),
			 .test_tile_wen_b(test_tile_wen_b),
			 .gated_incoming_A(e0_2_ocm_gated_delay[34:0]), //
			 .ungated_incoming_A(e0_2_ocm_ungated_delay[4:0]), //
			 .gated_incoming_B(e1_2_ocm_gated_delay[34:0]), //
			 .ungated_incoming_B(e1_2_ocm_gated_delay[4:0])); //
   
   

endmodule // mem_subsystem

