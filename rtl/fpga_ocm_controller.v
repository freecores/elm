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


module ocm_controller(/*AUTOARG*/
   // Outputs
   test_tile_read_data, nie_sm1_mem_read_data, nie_sm1_mem_gnt,
   nie_sm2_mem_read_data, nie_sm2_mem_gnt, se0_mem_read_data,
   se0_mem_gnt, se1_mem_read_data, se1_mem_gnt, /*se2_mem_read_data,
   se2_mem_gnt, se3_mem_read_data, se3_mem_gnt,*/
   // Inputs
   CLK, rst, TEST_MODE, test_tile_addr, test_tile_csn,
   test_tile_write_data, test_tile_wen_b, test_tile_write_mask,
   nie_sm1_mem_req, nie_sm1_mem_addr, nie_sm1_mem_wen_b,
   nie_sm1_mem_write_data, nie_sm1_mem_write_mask, nie_sm1_mem_lock,
   nie_sm2_mem_req, nie_sm2_mem_addr, nie_sm2_mem_wen_b,
   nie_sm2_mem_write_data, nie_sm2_mem_write_mask, se0_mem_req,
   se0_mem_wen_b, se0_mem_addr, se0_mem_write_data,
   se0_mem_write_mask, se1_mem_req, se1_mem_wen_b, se1_mem_addr,
   se1_mem_write_data, se1_mem_write_mask /*se2_mem_req, se2_mem_wen_b,
   se2_mem_addr, se2_mem_write_data, se2_mem_write_mask, se3_mem_req,
   se3_mem_wen_b, se3_mem_addr, se3_mem_write_data,
   se3_mem_write_mask*/
   );
   //This module is OCM tile specific and wraps 
   // the on chip SRAM with a whole bunch of arbs
   //It does NOT take inputs from EPs, as they don't
   //exist on the OCM tile

   input CLK;
   input rst;
   
   //Test Mode Circuitry...
   input TEST_MODE;
   input [11:0] test_tile_addr;
   input 	test_tile_csn;
   input [63:0] test_tile_write_data;
   output [63:0] test_tile_read_data;
   input         test_tile_wen_b;
   input [63:0]  test_tile_write_mask;
   
   
   //From NIE_SM1
   input 	 nie_sm1_mem_req;
   input [15:0]  nie_sm1_mem_addr;
   input 	 nie_sm1_mem_wen_b;
   input [63:0]  nie_sm1_mem_write_data;
   input [1:0]  nie_sm1_mem_write_mask;
   input 	 nie_sm1_mem_lock;
   output [63:0] nie_sm1_mem_read_data;
   output 	 nie_sm1_mem_gnt;
   
   
   //From NIE_SM2
   input 	 nie_sm2_mem_req;
   input [15:0]  nie_sm2_mem_addr;
   input 	 nie_sm2_mem_wen_b;
   input [63:0]  nie_sm2_mem_write_data;
   input [1:0]  nie_sm2_mem_write_mask;
   output [63:0] nie_sm2_mem_read_data;
   output 	 nie_sm2_mem_gnt;

   //From SE0
   input 	 se0_mem_req;
   input 	 se0_mem_wen_b;
   input [15:0]  se0_mem_addr;
   input [63:0]  se0_mem_write_data;
   input [1:0]  se0_mem_write_mask;
   output [63:0] se0_mem_read_data;
   output 	 se0_mem_gnt;

   //From SE1
   input 	 se1_mem_req;
   input 	 se1_mem_wen_b;
   input [15:0]  se1_mem_addr;
   input [63:0]  se1_mem_write_data;
   input [1:0]  se1_mem_write_mask;
   output [63:0] se1_mem_read_data;
   output 	 se1_mem_gnt;

   /*
   //From SE2
   input 	 se2_mem_req;
   input 	 se2_mem_wen_b;
   input [15:0]  se2_mem_addr;
   input [63:0]  se2_mem_write_data;
   input [63:0]  se2_mem_write_mask;
   output [63:0] se2_mem_read_data;
   output 	 se2_mem_gnt;
   
   //From SE3
   input 	 se3_mem_req;
   input 	 se3_mem_wen_b;
   input [15:0]  se3_mem_addr;
   input [63:0]  se3_mem_write_data;
   input [63:0]  se3_mem_write_mask;
   output [63:0] se3_mem_read_data;
   output 	 se3_mem_gnt;
*/
   wire 	 arb_gnt_sm1;
   wire		 arb_gnt_sm2;
   wire		 arb_gnt_se0;
   wire		 arb_gnt_se1;
   //wire		 arb_gnt_se2;
   //wire		 arb_gnt_se3;
   
   wire 	 arb_last_gnt_sm1;
   wire 	 arb_last_gnt_sm2;
   wire 	 arb_last_gnt_se0;
   wire 	 arb_last_gnt_se1;
   //wire 	 arb_last_gnt_se2;
   //wire		 arb_last_gnt_se3;

   wire [63:0] 	 tile_read_data;
   assign 	 test_tile_read_data = TEST_MODE ? tile_read_data : 64'd0;
   
   
   assign 	 nie_sm1_mem_gnt = arb_gnt_sm1 & nie_sm1_mem_req;
   assign 	 nie_sm2_mem_gnt = arb_gnt_sm2 & nie_sm2_mem_req;
   assign 	 se0_mem_gnt = arb_gnt_se0 & se0_mem_req;
   assign 	 se1_mem_gnt = arb_gnt_se1 & se1_mem_req;
   //assign 	 se2_mem_gnt = arb_gnt_se2 & se2_mem_req;
   //assign 	 se3_mem_gnt = arb_gnt_se3 & se3_mem_req;

   
   assign 	 nie_sm1_mem_read_data = arb_last_gnt_sm1 ? 
		 tile_read_data : 64'd0;
   assign 	 nie_sm2_mem_read_data = arb_last_gnt_sm2 ? 
		 tile_read_data : 64'd0;
   assign 	 se0_mem_read_data = arb_last_gnt_se0 ? 
		 tile_read_data : 64'd0;
   assign 	 se1_mem_read_data = arb_last_gnt_se1 ? 
		 tile_read_data : 64'd0;
   //assign 	 se2_mem_read_data = arb_last_gnt_se2 ? 
   //tile_read_data : 64'd0;
   //assign 	 se3_mem_read_data = arb_last_gnt_se3 ? 
   //tile_read_data : 64'd0;

   wire [3:0] 	 foo_a;
   
   arb6to1_hold who_gets_mem(
			     // Outputs
			     .gnt_0	(arb_gnt_sm1),
			     .gnt_1	(arb_gnt_sm2),
			     .gnt_2	(arb_gnt_se0),
			     .gnt_3	(arb_gnt_se1),
			     .gnt_4	(foo_a[0]),
			     .gnt_5	(foo_a[1]),
			     .last_gnt0	(arb_last_gnt_sm1),
			     .last_gnt1	(arb_last_gnt_sm2),
			     .last_gnt2	(arb_last_gnt_se0),
			     .last_gnt3	(arb_last_gnt_se1),
			     .last_gnt4	(foo_a[2]),
			     .last_gnt5	(foo_a[3]),
			     // Inputs
			     .CLK	(CLK),
			     .rst	(rst),
			     .req_0	(nie_sm1_mem_req),
			     .req_1	(nie_sm2_mem_req),
			     .req_2	(se0_mem_req),
			     .req_3	(se1_mem_req),
			     .req_4	(1'b0),
			     .req_5	(1'b0),
			     .hold_0	(nie_sm1_mem_lock),
			     .hold_1	(1'b0),
			     .hold_2	(1'b0),
			     .hold_3	(1'b0),
			     .hold_4	(1'b0),
			     .hold_5	(1'b0));

   wire [11:0] 	 tile_addr = 
		 arb_gnt_sm1 ? nie_sm1_mem_addr[12:1] :
		 arb_gnt_sm2 ? nie_sm2_mem_addr[12:1]  :
		 arb_gnt_se0 ? se0_mem_addr[12:1]  :
		 arb_gnt_se1 ? se1_mem_addr[12:1]  :
		 /*arb_gnt_se2 ? se2_mem_addr[12:1]  :
		 arb_gnt_se3 ? se3_mem_addr[12:1]  :*/ 12'd0;
   
   wire [63:0] 	 tile_write_data = 
		 arb_gnt_sm1 ? nie_sm1_mem_write_data :
		 arb_gnt_sm2 ? nie_sm2_mem_write_data :
		 arb_gnt_se0 ? se0_mem_write_data :
		 arb_gnt_se1 ? se1_mem_write_data :
		 /*arb_gnt_se2 ? se2_mem_write_data :
		 arb_gnt_se3 ? se3_mem_write_data :*/ 63'd0;
   
   wire [1:0] 	 tile_write_mask_short = 
		 arb_gnt_sm1 ? nie_sm1_mem_write_mask :
		 arb_gnt_sm2 ? nie_sm2_mem_write_mask :
		 arb_gnt_se0 ? se0_mem_write_mask :
		 arb_gnt_se1 ? se1_mem_write_mask :
		 /*arb_gnt_se2 ? se2_mem_write_mask :
		 arb_gnt_se3 ? se3_mem_write_mask :*/ 2'b11;

   wire [63:0] 	 tile_write_mask;
   assign tile_write_mask[31:0] = tile_write_mask_short[0] ? 32'hffffffff : 32'd0;
   assign tile_write_mask[63:32] = tile_write_mask_short[1] ? 32'hffffffff : 32'd0;
      
   wire 	 tile_wen_b = 
		 arb_gnt_sm1 ? nie_sm1_mem_wen_b :
		 arb_gnt_sm2 ? nie_sm2_mem_wen_b :
		 arb_gnt_se0 ? se0_mem_wen_b :
		 arb_gnt_se1 ? se1_mem_wen_b :
		 /*arb_gnt_se2 ? se2_mem_wen_b :
		 arb_gnt_se3 ? se3_mem_wen_b :*/ 1'd0;
   
   wire 	 tile_csn = 
   		 arb_gnt_sm1 ? ~nie_sm1_mem_req :
		 arb_gnt_sm2 ? ~nie_sm2_mem_req :
		 arb_gnt_se0 ? ~se0_mem_req :
		 arb_gnt_se1 ? ~se1_mem_req :
		 /*arb_gnt_se2 ? ~se2_mem_req :
		 arb_gnt_se3 ? ~se3_mem_req :*/ 1'd1;
   wire [5:0] 	 foo;
   
   fpga_tmem tmem(
		   // Outputs
		   .dout		( tile_read_data  ),
		   // Inputs
		   .clk			(CLK),
		   .csn                 (TEST_MODE ? test_tile_csn : tile_csn ),
		   .wen			(TEST_MODE ? test_tile_wen_b : tile_wen_b  ),
		   .addr		(TEST_MODE ? test_tile_addr : tile_addr ),
		  .din			(TEST_MODE ? test_tile_write_data : tile_write_data  ),
		   .mask		( TEST_MODE ? test_tile_write_mask : tile_write_mask )
		  );


endmodule // ocm_controller
