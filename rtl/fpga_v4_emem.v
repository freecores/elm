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


module v4_emem(/*AUTOARG*/
   // Outputs
   test_b0_read_data, test_b1_read_data, test_b2_read_data,
   test_b3_read_data, ep0_xmu_read_data, ep0_xmu_gnt_late,
   ep1_xmu_read_data, ep1_xmu_gnt_late, ep2_xmu_read_data,
   ep2_xmu_gnt_late, ep3_xmu_read_data, ep3_xmu_gnt_late,
   nie_sm1_mem_read_data, nie_sm1_mem_gnt, nie_sm2_mem_read_data,
   nie_sm2_mem_gnt, epe_sm0_mem_read_data, epe_sm0_mem_gnt,
   epe_sm1_mem_read_data, epe_sm1_mem_gnt, se0_mem_read_data,
   se0_mem_gnt, se1_mem_read_data, se1_mem_gnt,
   // Inputs
   CLK, rst, TEST_MODE, test_b0_csn, test_b0_addr, test_b0_write_data,
   test_b0_write_mask, test_b0_wen_b, test_b1_csn, test_b1_addr,
   test_b1_write_data, test_b1_write_mask, test_b1_wen_b, test_b2_csn,
   test_b2_addr, test_b2_write_data, test_b2_write_mask,
   test_b2_wen_b, test_b3_csn, test_b3_addr, test_b3_write_data,
   test_b3_write_mask, test_b3_wen_b, ep0_xmu_req, ep0_xmu_ld,
   ep0_xmu_st, ep0_xmu_addr, ep0_xmu_write_data, ep1_xmu_req,
   ep1_xmu_ld, ep1_xmu_st, ep1_xmu_addr, ep1_xmu_write_data,
   ep2_xmu_req, ep2_xmu_ld, ep2_xmu_st, ep2_xmu_addr,
   ep2_xmu_write_data, ep3_xmu_req, ep3_xmu_ld, ep3_xmu_st,
   ep3_xmu_addr, ep3_xmu_write_data, nie_sm1_mem_req,
   nie_sm1_mem_addr, nie_sm1_mem_wen_b, nie_sm1_mem_write_data,
   nie_sm1_mem_write_mask, nie_sm1_mem_lock, nie_sm2_mem_req,
   nie_sm2_mem_addr, nie_sm2_mem_wen_b, nie_sm2_mem_write_data,
   nie_sm2_mem_write_mask, epe_sm0_mem_req, epe_sm0_mem_addr,
   epe_sm0_mem_wen_b, epe_sm0_mem_write_data, epe_sm0_mem_write_mask,
   epe_sm1_mem_req, epe_sm1_mem_addr, epe_sm1_mem_wen_b,
   epe_sm1_mem_write_data, epe_sm1_mem_write_mask, epe_sm1_mem_lock,
   se0_mem_req, se0_mem_wen_b, se0_mem_addr, se0_mem_write_data,
   se0_mem_write_mask, se1_mem_req, se1_mem_wen_b, se1_mem_addr,
   se1_mem_write_data, se1_mem_write_mask
   );


   input CLK;
   input rst;

   //Test mode
   input TEST_MODE;
   input test_b0_csn;
   input [7:0] test_b0_addr;
   input [63:0] test_b0_write_data;
   input [63:0] test_b0_write_mask;
   input 	test_b0_wen_b;
   output [63:0] test_b0_read_data;
   
   input 	 test_b1_csn;
   input [7:0] 	 test_b1_addr;
   input [63:0]  test_b1_write_data;
   input [63:0]  test_b1_write_mask;
   input 	 test_b1_wen_b;
   output [63:0] test_b1_read_data;

   input 	 test_b2_csn;
   input [7:0] 	 test_b2_addr;
   input [63:0]  test_b2_write_data;
   input [63:0]  test_b2_write_mask;
   input 	 test_b2_wen_b;
   output [63:0] test_b2_read_data;

   input 	 test_b3_csn;
   input [7:0] 	 test_b3_addr;
   input [63:0]  test_b3_write_data;
   input [63:0]  test_b3_write_mask;
   input 	 test_b3_wen_b;
   output [63:0] test_b3_read_data;

   wire [63:0] 	 emem_b0_read_data;
   wire [63:0] 	 emem_b1_read_data;
   wire [63:0] 	 emem_b2_read_data;
   wire [63:0] 	 emem_b3_read_data;
   
   assign      test_b0_read_data = TEST_MODE ? emem_b0_read_data : 64'd0;
   assign      test_b1_read_data = TEST_MODE ? emem_b1_read_data : 64'd0;
   assign      test_b2_read_data = TEST_MODE ? emem_b2_read_data : 64'd0;
   assign      test_b3_read_data = TEST_MODE ? emem_b3_read_data : 64'd0;

   
   input         ep0_xmu_req;
   input 	 ep0_xmu_ld;
   input 	 ep0_xmu_st;
   wire 	 ep0_xmu_wen_b = ep0_xmu_ld;
   input [15:0]  ep0_xmu_addr;
   input [63:0]  ep0_xmu_write_data;
   input         ep1_xmu_req;
   input 	 ep1_xmu_ld;
   input 	 ep1_xmu_st;
   wire 	 ep1_xmu_wen_b = ep1_xmu_ld;
   input [15:0]  ep1_xmu_addr;
   input [63:0]  ep1_xmu_write_data;
   input         ep2_xmu_req;
   input 	 ep2_xmu_ld;
   input 	 ep2_xmu_st;
   wire 	 ep2_xmu_wen_b = ep2_xmu_ld;
   input [15:0]  ep2_xmu_addr;
   input [63:0]  ep2_xmu_write_data;
   input         ep3_xmu_req;
   input 	 ep3_xmu_ld;
   input 	 ep3_xmu_st;
   wire 	 ep3_xmu_wen_b = ep3_xmu_ld;
   input [15:0]  ep3_xmu_addr;
   input [63:0]  ep3_xmu_write_data;

   wire 	 ep0_direct_req = does_this_addr_goto_b0(ep0_xmu_addr) & ep0_xmu_req;
   wire 	 ep1_direct_req = does_this_addr_goto_b1(ep1_xmu_addr) & ep1_xmu_req;
   wire 	 ep2_direct_req = does_this_addr_goto_b2(ep2_xmu_addr) & ep2_xmu_req;   
   wire 	 ep3_direct_req = does_this_addr_goto_b3(ep3_xmu_addr) & ep3_xmu_req;
   
   reg 		 r_ep0_xmu_req;
   reg 		 r_ep0_xmu_wen_b;
   reg [15:0] 	 r_ep0_xmu_addr;
   reg [63:0] 	 r_ep0_xmu_write_data;
   wire [1:0] 	 r_ep0_xmu_write_mask = r_ep0_xmu_addr[0] ? 
		 2'b01 : 2'b10;
   
   reg 		 r_ep1_xmu_req;
   reg 		 r_ep1_xmu_wen_b;
   reg [15:0] 	 r_ep1_xmu_addr;
   reg [63:0] 	 r_ep1_xmu_write_data;
   wire [1:0] 	 r_ep1_xmu_write_mask = r_ep1_xmu_addr[0] ? 
		 2'b01 : 2'b10;	// 
   
   reg 		 r_ep2_xmu_req;
   reg 		 r_ep2_xmu_wen_b;
   reg [15:0] 	 r_ep2_xmu_addr;
   reg [63:0] 	 r_ep2_xmu_write_data;
   wire [1:0] 	 r_ep2_xmu_write_mask = r_ep2_xmu_addr[0] ? 
		 2'b01 : 2'b10;	// 
   
   reg 		 r_ep3_xmu_req;
   reg 		 r_ep3_xmu_wen_b;
   reg [15:0] 	 r_ep3_xmu_addr;
   reg [63:0] 	 r_ep3_xmu_write_data;
   wire [1:0] 	 r_ep3_xmu_write_mask = r_ep3_xmu_addr[0] ? 
		 2'b01 : 2'b10;	// 
   
   always@(posedge CLK or posedge rst)
     begin
	if(rst) begin
	   r_ep0_xmu_req <= 1'b0;
	   r_ep0_xmu_wen_b <= 1'b1;
	   r_ep0_xmu_addr <= 16'd0;
	   r_ep0_xmu_write_data <= 64'd0;
	   r_ep1_xmu_req <= 1'b0;
	   r_ep1_xmu_wen_b <= 1'b1;
	   r_ep1_xmu_addr <= 16'd0;
	   r_ep1_xmu_write_data <= 64'd0;
	   r_ep2_xmu_req <= 1'b0;
	   r_ep2_xmu_wen_b <= 1'b1;
	   r_ep2_xmu_addr <= 16'd0;
	   r_ep2_xmu_write_data <= 64'd0;
	   r_ep3_xmu_req <= 1'b0;
	   r_ep3_xmu_wen_b <= 1'b1;
	   r_ep3_xmu_addr <= 16'd0;
	   r_ep3_xmu_write_data <= 64'd0;
	end
	else begin
	   if(ep0_xmu_req & ~ep0_direct_req) begin
	      r_ep0_xmu_req <= ep0_xmu_req;
	      r_ep0_xmu_wen_b <= ep0_xmu_wen_b;
	      r_ep0_xmu_addr <= ep0_xmu_addr;
	      r_ep0_xmu_write_data <= ep0_xmu_write_data;
	   end
	   else
	     r_ep0_xmu_req <= 1'b0;
	   
	   if(ep1_xmu_req & ~ep1_direct_req) begin
	      r_ep1_xmu_req <= ep1_xmu_req;
	      r_ep1_xmu_wen_b <= ep1_xmu_wen_b;
	      r_ep1_xmu_addr <= ep1_xmu_addr;
	      r_ep1_xmu_write_data <= ep1_xmu_write_data;
	   end
	   else
	     r_ep1_xmu_req <= 1'b0;
	   if(ep2_xmu_req & ~ep2_direct_req) begin
	      r_ep2_xmu_req <= ep2_xmu_req;
	      r_ep2_xmu_wen_b <= ep2_xmu_wen_b;
	      r_ep2_xmu_addr <= ep2_xmu_addr;
	      r_ep2_xmu_write_data <= ep2_xmu_write_data;
	   end
	   else
	     r_ep2_xmu_req <= 1'b0;
	   if(ep3_xmu_req & ~ep3_direct_req) begin
	      r_ep3_xmu_req <= ep3_xmu_req;
	      r_ep3_xmu_wen_b <= ep3_xmu_wen_b;
	      r_ep3_xmu_addr <= ep3_xmu_addr;
	      r_ep3_xmu_write_data <= ep3_xmu_write_data;
	   end
	   else
	     r_ep3_xmu_req <= 1'b0;
	end // else: !if(rst)
     end // always@ (posedge CLK or posedge rst)
   
   wire [63:0] 	 ep0_xmu_write_mask = ep0_xmu_addr[0] ? 64'h00000000ffffffff : 64'hffffffff00000000;
   wire [63:0] 	 ep1_xmu_write_mask = ep1_xmu_addr[0] ? 64'h00000000ffffffff : 64'hffffffff00000000;
   wire [63:0] 	 ep2_xmu_write_mask = ep2_xmu_addr[0] ? 64'h00000000ffffffff : 64'hffffffff00000000;   
   wire [63:0] 	 ep3_xmu_write_mask = ep3_xmu_addr[0] ? 64'h00000000ffffffff : 64'hffffffff00000000;

   output [63:0] ep0_xmu_read_data;
   output 	 ep0_xmu_gnt_late;
   
   //From EP1 EXEC
   output [63:0] ep1_xmu_read_data;
   output 	 ep1_xmu_gnt_late;

   //From EP2 EXEC
   output [63:0] ep2_xmu_read_data;
   output 	 ep2_xmu_gnt_late;

   //From EP3 EXEC
   output [63:0] ep3_xmu_read_data;
   output 	 ep3_xmu_gnt_late;

     //From NIE_SM1
   input 	 nie_sm1_mem_req;
   input [15:0]  nie_sm1_mem_addr;
   input 	 nie_sm1_mem_wen_b;
   input [63:0]  nie_sm1_mem_write_data;
   input [1:0]  nie_sm1_mem_write_mask;
   input 	 nie_sm1_mem_lock;
   
   input 	 nie_sm2_mem_req;
   input [15:0]  nie_sm2_mem_addr;
   input 	 nie_sm2_mem_wen_b;
   input [63:0]  nie_sm2_mem_write_data;
   input [1:0]  nie_sm2_mem_write_mask;

   input 	 epe_sm0_mem_req;
   input [15:0]  epe_sm0_mem_addr;
   input 	 epe_sm0_mem_wen_b;
   input [63:0]  epe_sm0_mem_write_data;
   input [1:0]  epe_sm0_mem_write_mask;
   
   input 	 epe_sm1_mem_req;   
   input [15:0]  epe_sm1_mem_addr;
   input 	 epe_sm1_mem_wen_b;
   input [63:0]  epe_sm1_mem_write_data;
   input [1:0]  epe_sm1_mem_write_mask;
   input 	 epe_sm1_mem_lock;

   input 	 se0_mem_req;
   input 	 se0_mem_wen_b;
   input [15:0]  se0_mem_addr;
   input [63:0]  se0_mem_write_data;
   input [1:0]  se0_mem_write_mask;

   input 	 se1_mem_req;
   input 	 se1_mem_wen_b;
   input [15:0]  se1_mem_addr;
   input [63:0]  se1_mem_write_data;
   input [1:0]  se1_mem_write_mask;
   
   reg 		 r_nie_sm1_mem_req;
   reg [15:0] 	 r_nie_sm1_mem_addr;
   reg 		 r_nie_sm1_mem_wen_b;
   reg [63:0] 	 r_nie_sm1_mem_write_data;
   reg [1:0] 	 r_nie_sm1_mem_write_mask;
   reg 		 r_nie_sm2_mem_req;
   reg [15:0] 	 r_nie_sm2_mem_addr;
   reg 		 r_nie_sm2_mem_wen_b;
   reg [63:0] 	 r_nie_sm2_mem_write_data;
   reg [1:0] 	 r_nie_sm2_mem_write_mask;
   reg 		 r_epe_sm0_mem_req;
   reg [15:0] 	 r_epe_sm0_mem_addr;
   reg 		 r_epe_sm0_mem_wen_b;
   reg [63:0] 	 r_epe_sm0_mem_write_data;
   reg [1:0] 	 r_epe_sm0_mem_write_mask;
   reg 		 r_epe_sm1_mem_req;
   reg [15:0] 	 r_epe_sm1_mem_addr;
   reg 		 r_epe_sm1_mem_wen_b;
   reg [63:0] 	 r_epe_sm1_mem_write_data;
   reg [1:0] 	 r_epe_sm1_mem_write_mask;
   reg 		 r_se0_mem_req;
   reg [15:0] 	 r_se0_mem_addr;
   reg 		 r_se0_mem_wen_b;
   reg [63:0] 	 r_se0_mem_write_data;
   reg [1:0] 	 r_se0_mem_write_mask;
   reg 		 r_se1_mem_req;
   reg [15:0] 	 r_se1_mem_addr;
   reg 		 r_se1_mem_wen_b;
   reg [63:0] 	 r_se1_mem_write_data;
   reg [1:0] 	 r_se1_mem_write_mask;

   wire 	 ep0_mem_req_qual;
   wire 	 ep1_mem_req_qual;
   wire 	 ep2_mem_req_qual;
   wire 	 ep3_mem_req_qual;
   wire 	 nie_sm1_req_qual;
   wire 	 nie_sm2_req_qual;
   wire 	 epe_sm0_req_qual;
   wire 	 epe_sm1_req_qual;
   wire 	 se0_mem_req_qual;
   wire 	 se1_mem_req_qual;
   
   always@(posedge CLK or posedge rst) begin
      if(rst) begin
	 r_nie_sm1_mem_req <= 1'b0;
	 r_nie_sm1_mem_addr <= 16'd0;
	 r_nie_sm1_mem_wen_b <= 1'b1;
	 r_nie_sm1_mem_write_data <= 64'd0;
	 r_nie_sm1_mem_write_mask <= 2'd0;
	 r_nie_sm2_mem_req <= 1'b0;
	 r_nie_sm2_mem_addr <= 16'd0;
	 r_nie_sm2_mem_wen_b <= 1'b1;
	 r_nie_sm2_mem_write_data <= 64'd0;
	 r_nie_sm2_mem_write_mask <= 2'd0;
	 r_epe_sm0_mem_req <= 1'b0;
	 r_epe_sm0_mem_addr <= 16'd0;
	 r_epe_sm0_mem_wen_b <= 1'b1;
	 r_epe_sm0_mem_write_data <= 64'd0;
	 r_epe_sm0_mem_write_mask <= 2'd0;
	 r_epe_sm1_mem_req <= 1'b0;
	 r_epe_sm1_mem_addr <= 16'd0;
	 r_epe_sm1_mem_wen_b <= 1'b1;
	 r_epe_sm1_mem_write_data <= 64'd0;
	 r_epe_sm1_mem_write_mask <= 2'd0;
	 r_se0_mem_req <= 1'b0;
	 r_se0_mem_addr <= 16'd0;
	 r_se0_mem_wen_b <= 1'b1;
	 r_se0_mem_write_data <= 64'd0;
	 r_se0_mem_write_mask <= 2'd0;
	 r_se1_mem_req <= 1'b0;
	 r_se1_mem_addr <= 16'd0;
	 r_se1_mem_wen_b <= 1'b1;
	 r_se1_mem_write_data <= 64'd0;
	 r_se1_mem_write_mask <= 2'd0;
      end // if (rst)
      else begin
	 if(nie_sm1_mem_req) begin
	    r_nie_sm1_mem_req <= nie_sm1_mem_req;
	    r_nie_sm1_mem_addr <= nie_sm1_mem_addr;
	    r_nie_sm1_mem_wen_b <= nie_sm1_mem_wen_b;
	    r_nie_sm1_mem_write_data <= nie_sm1_mem_write_data;
	    r_nie_sm1_mem_write_mask <= nie_sm1_mem_write_mask;
	 end
	 else
	   r_nie_sm1_mem_req <= 1'b0;
	 if(nie_sm2_mem_req) begin
	    r_nie_sm2_mem_req <= nie_sm2_mem_req;
	    r_nie_sm2_mem_addr <= nie_sm2_mem_addr;
	    r_nie_sm2_mem_wen_b <= nie_sm2_mem_wen_b;
	    r_nie_sm2_mem_write_data <= nie_sm2_mem_write_data;
	    r_nie_sm2_mem_write_mask <= nie_sm2_mem_write_mask;
	 end
	 else
	   r_nie_sm2_mem_req <= 1'b0;
	 if(epe_sm0_mem_req) begin
	    r_epe_sm0_mem_req <= epe_sm0_mem_req; // 
	    r_epe_sm0_mem_addr <= epe_sm0_mem_addr;
	    r_epe_sm0_mem_wen_b <= epe_sm0_mem_wen_b;
	    r_epe_sm0_mem_write_data <= epe_sm0_mem_write_data;
	    r_epe_sm0_mem_write_mask <= epe_sm0_mem_write_mask;
	 end
	 else
	   r_epe_sm0_mem_req <= 1'b0;
	 if(epe_sm1_mem_req) begin
	    r_epe_sm1_mem_req <= epe_sm1_mem_req; // 
	    r_epe_sm1_mem_addr <= epe_sm1_mem_addr;
	    r_epe_sm1_mem_wen_b <= epe_sm1_mem_wen_b;
	    r_epe_sm1_mem_write_data <= epe_sm1_mem_write_data;
	    r_epe_sm1_mem_write_mask <= epe_sm1_mem_write_mask;
	 end
	 else
	   r_epe_sm1_mem_req <= 1'b0;
	 if(se0_mem_req) begin
	    r_se0_mem_req <= se0_mem_req; // 
	    r_se0_mem_addr <= se0_mem_addr;
	    r_se0_mem_wen_b <= se0_mem_wen_b;
	    r_se0_mem_write_data <= se0_mem_write_data;
	    r_se0_mem_write_mask <= se0_mem_write_mask;
	 end
	 else
	   r_se0_mem_req <= 1'b0;
	 if(se1_mem_req) begin
	    r_se1_mem_req <= se1_mem_req; // 
	    r_se1_mem_addr <= se1_mem_addr;
	    r_se1_mem_wen_b <= se1_mem_wen_b;
	    r_se1_mem_write_data <= se1_mem_write_data;
	    r_se1_mem_write_mask <= se1_mem_write_mask;
	 end
	 else
	   r_se1_mem_req <= 1'b0;
      end // else: !if(rst)
   end // always@ (posedge CLK or posedge rst)

   wire peon_se0_gnt;
   wire peon_se1_gnt;
   wire peon_nie_sm1_gnt;
   wire peon_nie_sm2_gnt;
   wire peon_epe_sm0_gnt;
   wire peon_epe_sm1_gnt;

   wire peon_se0_gnt_last;
   wire peon_se1_gnt_last;
   wire peon_nie_sm1_gnt_last;
   wire peon_nie_sm2_gnt_last;
   wire peon_epe_sm0_gnt_last;
   wire peon_epe_sm1_gnt_last;
   

   arb6to1_hold arb_the_trash(
			      // Outputs
			      .gnt_0		(peon_se0_gnt),
			      .gnt_1		(peon_se1_gnt),
			      .gnt_2		(peon_nie_sm1_gnt),
			      .gnt_3		(peon_nie_sm2_gnt),
			      .gnt_4		(peon_epe_sm0_gnt),
			      .gnt_5		(peon_epe_sm1_gnt),
			      .last_gnt0	(peon_se0_gnt_last),
			      .last_gnt1	(peon_se1_gnt_last),
			      .last_gnt2	(peon_nie_sm1_gnt_last),
			      .last_gnt3	(peon_nie_sm2_gnt_last),
			      .last_gnt4	(peon_epe_sm0_gnt_last),
			      .last_gnt5	(peon_epe_sm1_gnt_last),
			      // Inputs
			      .CLK		(CLK),
			      .rst		(rst),
			      .req_0		(se0_mem_req_qual),
			      .req_1		(se1_mem_req_qual),
			      .req_2		(nie_sm1_req_qual),
			      .req_3		(nie_sm2_req_qual),
			      .req_4		(epe_sm0_req_qual),
			      .req_5		(epe_sm1_req_qual),
			      .hold_0		(1'b0),
			      .hold_1		(1'b0),
			      .hold_2		(nie_sm1_mem_lock),
			      .hold_3		(1'b0),
			      .hold_4		(1'b0),
			      .hold_5		(epe_sm1_mem_lock));


   wire peon_mem_req = (peon_nie_sm1_gnt & nie_sm1_req_qual) | peon_nie_sm2_gnt | peon_epe_sm0_gnt 
	| (peon_epe_sm1_gnt & epe_sm1_req_qual) | peon_se0_gnt | peon_se1_gnt;

   wire [15:0] peon_addr = peon_se0_gnt ? r_se0_mem_addr : 
	       peon_se1_gnt ? r_se1_mem_addr :
	       peon_nie_sm1_gnt ? r_nie_sm1_mem_addr : 
	       peon_nie_sm2_gnt ? r_nie_sm2_mem_addr :
	       peon_epe_sm0_gnt ? r_epe_sm0_mem_addr : r_epe_sm1_mem_addr;

   wire        peon_wen_b = peon_se0_gnt ? r_se0_mem_wen_b :
	       peon_se1_gnt ? r_se1_mem_wen_b :
	       peon_nie_sm1_gnt ? r_nie_sm1_mem_wen_b : 
	       peon_nie_sm2_gnt ? r_nie_sm2_mem_wen_b :
	       peon_epe_sm0_gnt ? r_epe_sm0_mem_wen_b : r_epe_sm1_mem_wen_b;

   wire [63:0] peon_write_data = peon_se0_gnt ? r_se0_mem_write_data : 
	       peon_se1_gnt ? r_se1_mem_write_data :
	       peon_nie_sm1_gnt ? r_nie_sm1_mem_write_data : 
	       peon_nie_sm2_gnt ? r_nie_sm2_mem_write_data :
	       peon_epe_sm0_gnt ? r_epe_sm0_mem_write_data : r_epe_sm1_mem_write_data;

   wire [1:0] peon_write_mask = peon_se0_gnt ? r_se0_mem_write_mask :
	       peon_se1_gnt ? r_se1_mem_write_mask :
	       peon_nie_sm1_gnt ? r_nie_sm1_mem_write_mask : 
	       peon_nie_sm2_gnt ? r_nie_sm2_mem_write_mask :
	       peon_epe_sm0_gnt ? r_epe_sm0_mem_write_mask : r_epe_sm1_mem_write_mask;

   wire        ep0_xmu_req_b0 = does_this_addr_goto_b0(r_ep0_xmu_addr) & ep0_mem_req_qual;
   wire        ep0_xmu_req_b1 = does_this_addr_goto_b1(r_ep0_xmu_addr) & ep0_mem_req_qual;
   wire        ep0_xmu_req_b2 = does_this_addr_goto_b2(r_ep0_xmu_addr) & ep0_mem_req_qual;
   wire        ep0_xmu_req_b3 = does_this_addr_goto_b3(r_ep0_xmu_addr) & ep0_mem_req_qual;
   
   wire        ep1_xmu_req_b0 = does_this_addr_goto_b0(r_ep1_xmu_addr) & ep1_mem_req_qual;
   wire        ep1_xmu_req_b1 = does_this_addr_goto_b1(r_ep1_xmu_addr) & ep1_mem_req_qual;
   wire        ep1_xmu_req_b2 = does_this_addr_goto_b2(r_ep1_xmu_addr) & ep1_mem_req_qual;
   wire        ep1_xmu_req_b3 = does_this_addr_goto_b3(r_ep1_xmu_addr) & ep1_mem_req_qual;
   
   wire        ep2_xmu_req_b0 = does_this_addr_goto_b0(r_ep2_xmu_addr) & ep2_mem_req_qual;
   wire        ep2_xmu_req_b1 = does_this_addr_goto_b1(r_ep2_xmu_addr) & ep2_mem_req_qual;
   wire        ep2_xmu_req_b2 = does_this_addr_goto_b2(r_ep2_xmu_addr) & ep2_mem_req_qual;
   wire        ep2_xmu_req_b3 = does_this_addr_goto_b3(r_ep2_xmu_addr) & ep2_mem_req_qual;
   
   wire        ep3_xmu_req_b0 = does_this_addr_goto_b0(r_ep3_xmu_addr) & ep3_mem_req_qual;
   wire        ep3_xmu_req_b1 = does_this_addr_goto_b1(r_ep3_xmu_addr) & ep3_mem_req_qual;
   wire        ep3_xmu_req_b2 = does_this_addr_goto_b2(r_ep3_xmu_addr) & ep3_mem_req_qual;
   wire        ep3_xmu_req_b3 = does_this_addr_goto_b3(r_ep3_xmu_addr) & ep3_mem_req_qual;
   
   wire        peon_req_b0 = does_this_addr_goto_b0(peon_addr) & peon_mem_req;
   wire        peon_req_b1 = does_this_addr_goto_b1(peon_addr) & peon_mem_req;
   wire        peon_req_b2 = does_this_addr_goto_b2(peon_addr) & peon_mem_req;
   wire        peon_req_b3 = does_this_addr_goto_b3(peon_addr) & peon_mem_req;

   wire        peon_hold_b0 = (peon_nie_sm1_gnt & r_nie_sm1_mem_req) |
	       (peon_epe_sm1_gnt & r_epe_sm1_mem_req);
   wire        peon_hold_b1 = (peon_nie_sm1_gnt & r_nie_sm1_mem_req) |
	       (peon_epe_sm1_gnt & r_epe_sm1_mem_req);
   wire        peon_hold_b2 = (peon_nie_sm1_gnt & r_nie_sm1_mem_req) |
	       (peon_epe_sm1_gnt & r_epe_sm1_mem_req);
   wire        peon_hold_b3 = (peon_nie_sm1_gnt & r_nie_sm1_mem_req) |
	       (peon_epe_sm1_gnt & r_epe_sm1_mem_req);
   
   wire        final_gnt_ep0_b0;
   wire        final_gnt_ep1_b0;
   wire        final_gnt_ep2_b0;
   wire        final_gnt_ep3_b0;
   wire        final_gnt_peon_b0;
   wire        final_gnt_ep0_b0_last;
   wire        final_gnt_ep1_b0_last;
   wire        final_gnt_ep2_b0_last;
   wire        final_gnt_ep3_b0_last;
   wire        final_gnt_peon_b0_last;
   
   wire        final_gnt_ep0_b1;
   wire        final_gnt_ep1_b1;
   wire        final_gnt_ep2_b1;
   wire        final_gnt_ep3_b1;
   wire        final_gnt_peon_b1;
   wire        final_gnt_ep0_b1_last;
   wire        final_gnt_ep1_b1_last;
   wire        final_gnt_ep2_b1_last;
   wire        final_gnt_ep3_b1_last;
   wire        final_gnt_peon_b1_last;
   
   wire        final_gnt_ep0_b2;
   wire        final_gnt_ep1_b2;
   wire        final_gnt_ep2_b2;
   wire        final_gnt_ep3_b2;
   wire        final_gnt_peon_b2;
   wire        final_gnt_ep0_b2_last;
   wire        final_gnt_ep1_b2_last;
   wire        final_gnt_ep2_b2_last;
   wire        final_gnt_ep3_b2_last;
   wire        final_gnt_peon_b2_last;

   wire        final_gnt_ep0_b3;
   wire        final_gnt_ep1_b3;
   wire        final_gnt_ep2_b3;
   wire        final_gnt_ep3_b3;
   wire        final_gnt_peon_b3;
   wire        final_gnt_ep0_b3_last;
   wire        final_gnt_ep1_b3_last;
   wire        final_gnt_ep2_b3_last;
   wire        final_gnt_ep3_b3_last;
   wire        final_gnt_peon_b3_last;
   
   arb5to1_hold arb_b0(
		       // Outputs
		       .gnt_0		(final_gnt_ep0_b0),
		       .gnt_1		(final_gnt_ep1_b0),
		       .gnt_2		(final_gnt_ep2_b0),
		       .gnt_3		(final_gnt_ep3_b0),
		       .gnt_4		(final_gnt_peon_b0),
		       .last_gnt0	(final_gnt_ep0_b0_last),
		       .last_gnt1	(final_gnt_ep1_b0_last),
		       .last_gnt2	(final_gnt_ep2_b0_last),
		       .last_gnt3	(final_gnt_ep3_b0_last),
		       .last_gnt4	(final_gnt_peon_b0_last),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(ep0_xmu_req_b0),
		       .req_1		(ep1_xmu_req_b0),
		       .req_2		(ep2_xmu_req_b0),
		       .req_3		(ep3_xmu_req_b0),
		       .req_4		(peon_req_b0),
		       .hold_0		(1'b0),
		       .hold_1		(1'b0),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0),
		       .hold_4		(peon_hold_b0));

   arb5to1_hold arb_b1(
		       // Outputs
		       .gnt_0		(final_gnt_ep0_b1),
		       .gnt_1		(final_gnt_ep1_b1),
		       .gnt_2		(final_gnt_ep2_b1),
		       .gnt_3		(final_gnt_ep3_b1),
		       .gnt_4		(final_gnt_peon_b1),
		       .last_gnt0	(final_gnt_ep0_b1_last),
		       .last_gnt1	(final_gnt_ep1_b1_last),
		       .last_gnt2	(final_gnt_ep2_b1_last),
		       .last_gnt3	(final_gnt_ep3_b1_last),
		       .last_gnt4	(final_gnt_peon_b1_last),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(ep0_xmu_req_b1),
		       .req_1		(ep1_xmu_req_b1),
		       .req_2		(ep2_xmu_req_b1),
		       .req_3		(ep3_xmu_req_b1),
		       .req_4		(peon_req_b1),
		       .hold_0		(1'b0),
		       .hold_1		(1'b0),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0),
		       .hold_4		(peon_hold_b1));

   arb5to1_hold arb_b2(
		       // Outputs
		       .gnt_0		(final_gnt_ep0_b2),
		       .gnt_1		(final_gnt_ep1_b2),
		       .gnt_2		(final_gnt_ep2_b2),
		       .gnt_3		(final_gnt_ep3_b2),
		       .gnt_4		(final_gnt_peon_b2),
		       .last_gnt0	(final_gnt_ep0_b2_last),
		       .last_gnt1	(final_gnt_ep1_b2_last),
		       .last_gnt2	(final_gnt_ep2_b2_last),
		       .last_gnt3	(final_gnt_ep3_b2_last),
		       .last_gnt4	(final_gnt_peon_b2_last),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(ep0_xmu_req_b2),
		       .req_1		(ep1_xmu_req_b2),
		       .req_2		(ep2_xmu_req_b2),
		       .req_3		(ep3_xmu_req_b2),
		       .req_4		(peon_req_b2),
		       .hold_0		(1'b0),
		       .hold_1		(1'b0),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0),
		       .hold_4		(peon_hold_b2));

   
   arb5to1_hold arb_b3(
		       // Outputs
		       .gnt_0		(final_gnt_ep0_b3),
		       .gnt_1		(final_gnt_ep1_b3),
		       .gnt_2		(final_gnt_ep2_b3),
		       .gnt_3		(final_gnt_ep3_b3),
		       .gnt_4		(final_gnt_peon_b3),
		       .last_gnt0	(final_gnt_ep0_b3_last),
		       .last_gnt1	(final_gnt_ep1_b3_last),
		       .last_gnt2	(final_gnt_ep2_b3_last),
		       .last_gnt3	(final_gnt_ep3_b3_last),
		       .last_gnt4	(final_gnt_peon_b3_last),
		       // Inputs
		       .CLK		(CLK),
		       .rst		(rst),
		       .req_0		(ep0_xmu_req_b3),
		       .req_1		(ep1_xmu_req_b3),
		       .req_2		(ep2_xmu_req_b3),
		       .req_3		(ep3_xmu_req_b3),
		       .req_4		(peon_req_b3),
		       .hold_0		(1'b0),
		       .hold_1		(1'b0),
		       .hold_2		(1'b0),
		       .hold_3		(1'b0),
		       .hold_4		(peon_hold_b3));
   
   
   output [63:0] nie_sm1_mem_read_data;
   output 	 nie_sm1_mem_gnt;

   //From NIE_SM2
   output [63:0] nie_sm2_mem_read_data;
   output 	 nie_sm2_mem_gnt;

   //From EPE_SM0
   output [63:0] epe_sm0_mem_read_data;
   output 	 epe_sm0_mem_gnt;

   //From EPE_SM1
   output [63:0] epe_sm1_mem_read_data;
   output 	 epe_sm1_mem_gnt;

   //From SE0
   output [63:0] se0_mem_read_data;
   output 	 se0_mem_gnt;

   //From SE1
   output [63:0] se1_mem_read_data;
   output 	 se1_mem_gnt;

   wire 	 b0_not_locked = ~peon_hold_b0;
   wire 	 b1_not_locked = ~peon_hold_b1;
   wire 	 b2_not_locked = ~peon_hold_b2;
   wire 	 b3_not_locked = ~peon_hold_b3;

   
   wire 	 b0_bigmux_csn = ~(final_gnt_ep0_b0 | final_gnt_ep1_b0 | final_gnt_ep2_b0 | 
				   final_gnt_ep3_b0 | final_gnt_peon_b0);
   
   wire 	 b0_bigmux_wen_b = final_gnt_ep0_b0 ? r_ep0_xmu_wen_b :
		 final_gnt_ep1_b0 ? r_ep1_xmu_wen_b :
		 final_gnt_ep2_b0 ? r_ep2_xmu_wen_b :
		 final_gnt_ep3_b0 ? r_ep3_xmu_wen_b :
		 final_gnt_peon_b0 ? peon_wen_b : 1'b1;
   
   wire [7:0] 	 b0_bigmux_addr = final_gnt_ep0_b0 ? convert_addr(r_ep0_xmu_addr) :
		 final_gnt_ep1_b0 ? convert_addr(r_ep1_xmu_addr) :
		 final_gnt_ep2_b0 ? convert_addr(r_ep2_xmu_addr) :
		 final_gnt_ep3_b0 ? convert_addr(r_ep3_xmu_addr) :
		 final_gnt_peon_b0 ? convert_addr(peon_addr) : 8'd0;

   wire [63:0] 	 b0_bigmux_write_data = final_gnt_ep0_b0 ? r_ep0_xmu_write_data :
		 final_gnt_ep1_b0 ? r_ep1_xmu_write_data :
		 final_gnt_ep2_b0 ? r_ep2_xmu_write_data :
		 final_gnt_ep3_b0 ? r_ep3_xmu_write_data :
		 final_gnt_peon_b0 ? peon_write_data : 64'd0;
   
   wire [1:0] 	 b0_bigmux_write_mask_small = final_gnt_ep0_b0 ? r_ep0_xmu_write_mask :
		 final_gnt_ep1_b0 ? r_ep1_xmu_write_mask :
		 final_gnt_ep2_b0 ? r_ep2_xmu_write_mask :
		 final_gnt_ep3_b0 ? r_ep3_xmu_write_mask :
		 final_gnt_peon_b0 ? peon_write_mask : 64'd0;

   wire [63:0] 	 b0_bigmux_write_mask;
   assign b0_bigmux_write_mask[31:0] = b0_bigmux_write_mask_small[0] ? 32'hffffffff : 32'd0;
   assign b0_bigmux_write_mask[63:32] = b0_bigmux_write_mask_small[1] ? 32'hffffffff : 32'd0;
   
   wire 	 b1_bigmux_csn = ~(final_gnt_ep0_b1 | final_gnt_ep1_b1 | final_gnt_ep2_b1 | 
				   final_gnt_ep3_b1 | final_gnt_peon_b1);
   
   wire 	 b1_bigmux_wen_b = final_gnt_ep0_b1 ? r_ep0_xmu_wen_b :
		 final_gnt_ep1_b1 ? r_ep1_xmu_wen_b :
		 final_gnt_ep2_b1 ? r_ep2_xmu_wen_b :
		 final_gnt_ep3_b1 ? r_ep3_xmu_wen_b :
		 final_gnt_peon_b1 ? peon_wen_b : 1'b1;
   
   wire [7:0] 	 b1_bigmux_addr = final_gnt_ep0_b1 ? convert_addr(r_ep0_xmu_addr) :
		 final_gnt_ep1_b1 ? convert_addr(r_ep1_xmu_addr) :
		 final_gnt_ep2_b1 ? convert_addr(r_ep2_xmu_addr) :
		 final_gnt_ep3_b1 ? convert_addr(r_ep3_xmu_addr) :
		 final_gnt_peon_b1 ? convert_addr(peon_addr) : 8'd0;

   wire [63:0] 	 b1_bigmux_write_data = final_gnt_ep0_b1 ? r_ep0_xmu_write_data :
		 final_gnt_ep1_b1 ? r_ep1_xmu_write_data :
		 final_gnt_ep2_b1 ? r_ep2_xmu_write_data :
		 final_gnt_ep3_b1 ? r_ep3_xmu_write_data :
		 final_gnt_peon_b1 ? peon_write_data : 64'd0;
   
   wire [1:0] 	 b1_bigmux_write_mask_small = final_gnt_ep0_b1 ? r_ep0_xmu_write_mask :
		 final_gnt_ep1_b1 ? r_ep1_xmu_write_mask :
		 final_gnt_ep2_b1 ? r_ep2_xmu_write_mask :
		 final_gnt_ep3_b1 ? r_ep3_xmu_write_mask :
		 final_gnt_peon_b1 ? peon_write_mask : 64'd0;
   
   wire [63:0] 	 b1_bigmux_write_mask;
   assign b1_bigmux_write_mask[31:0] = b1_bigmux_write_mask_small[0] ? 32'hffffffff : 32'd0;
   assign b1_bigmux_write_mask[63:32] = b1_bigmux_write_mask_small[1] ? 32'hffffffff : 32'd0;

   wire 	 b2_bigmux_csn = ~(final_gnt_ep0_b2 | final_gnt_ep1_b2 | final_gnt_ep2_b2 | 
				   final_gnt_ep3_b2 | final_gnt_peon_b2);
   
   wire 	 b2_bigmux_wen_b = final_gnt_ep0_b2 ? r_ep0_xmu_wen_b :
		 final_gnt_ep1_b2 ? r_ep1_xmu_wen_b :
		 final_gnt_ep2_b2 ? r_ep2_xmu_wen_b :
		 final_gnt_ep3_b2 ? r_ep3_xmu_wen_b :
		 final_gnt_peon_b2 ? peon_wen_b : 1'b1;
   
   wire [7:0] 	 b2_bigmux_addr = final_gnt_ep0_b2 ? convert_addr(r_ep0_xmu_addr) :
		 final_gnt_ep1_b2 ? convert_addr(r_ep1_xmu_addr) :
		 final_gnt_ep2_b2 ? convert_addr(r_ep2_xmu_addr) :
		 final_gnt_ep3_b2 ? convert_addr(r_ep3_xmu_addr) :
		 final_gnt_peon_b2 ? convert_addr(peon_addr) : 8'd0;

   wire [63:0] 	 b2_bigmux_write_data = final_gnt_ep0_b2 ? r_ep0_xmu_write_data :
		 final_gnt_ep1_b2 ? r_ep1_xmu_write_data :
		 final_gnt_ep2_b2 ? r_ep2_xmu_write_data :
		 final_gnt_ep3_b2 ? r_ep3_xmu_write_data :
		 final_gnt_peon_b2 ? peon_write_data : 64'd0;
   
   wire [1:0] 	 b2_bigmux_write_mask_small = final_gnt_ep0_b2 ? r_ep0_xmu_write_mask :
		 final_gnt_ep1_b2 ? r_ep1_xmu_write_mask :
		 final_gnt_ep2_b2 ? r_ep2_xmu_write_mask :
		 final_gnt_ep3_b2 ? r_ep3_xmu_write_mask :
		 final_gnt_peon_b2 ? peon_write_mask : 64'd0;

   wire [63:0] 	 b2_bigmux_write_mask;
   assign b2_bigmux_write_mask[31:0] = b2_bigmux_write_mask_small[0] ? 32'hffffffff : 32'd0;
   assign b2_bigmux_write_mask[63:32] = b2_bigmux_write_mask_small[1] ? 32'hffffffff : 32'd0;
   
   wire 	 b3_bigmux_csn = ~(final_gnt_ep0_b3 | final_gnt_ep1_b3 | final_gnt_ep2_b3 | 
				   final_gnt_ep3_b3 | final_gnt_peon_b3);
   
   wire 	 b3_bigmux_wen_b = final_gnt_ep0_b3 ? r_ep0_xmu_wen_b :
		 final_gnt_ep1_b3 ? r_ep1_xmu_wen_b :
		 final_gnt_ep2_b3 ? r_ep2_xmu_wen_b :
		 final_gnt_ep3_b3 ? r_ep3_xmu_wen_b :
		 final_gnt_peon_b3 ? peon_wen_b : 1'b1;
   
   wire [7:0] 	 b3_bigmux_addr = final_gnt_ep0_b3 ? convert_addr(r_ep0_xmu_addr) :
		 final_gnt_ep1_b3 ? convert_addr(r_ep1_xmu_addr) :
		 final_gnt_ep2_b3 ? convert_addr(r_ep2_xmu_addr) :
		 final_gnt_ep3_b3 ? convert_addr(r_ep3_xmu_addr) :
		 final_gnt_peon_b3 ? convert_addr(peon_addr) : 8'd0;

   wire [63:0] 	 b3_bigmux_write_data = final_gnt_ep0_b3 ? r_ep0_xmu_write_data :
		 final_gnt_ep1_b3 ? r_ep1_xmu_write_data :
		 final_gnt_ep2_b3 ? r_ep2_xmu_write_data :
		 final_gnt_ep3_b3 ? r_ep3_xmu_write_data :
		 final_gnt_peon_b3 ? peon_write_data : 64'd0;
   
   wire [1:0] 	 b3_bigmux_write_mask_small = final_gnt_ep0_b3 ? r_ep0_xmu_write_mask :
		 final_gnt_ep1_b3 ? r_ep1_xmu_write_mask :
		 final_gnt_ep2_b3 ? r_ep2_xmu_write_mask :
		 final_gnt_ep3_b3 ? r_ep3_xmu_write_mask :
		 final_gnt_peon_b3 ? peon_write_mask : 64'd0;
   
   wire [63:0] 	 b3_bigmux_write_mask;
   assign b3_bigmux_write_mask[31:0] = b3_bigmux_write_mask_small[0] ? 32'hffffffff : 32'd0;
   assign b3_bigmux_write_mask[63:32] = b3_bigmux_write_mask_small[1] ? 32'hffffffff : 32'd0;
   
   wire 	 emem_b0_csn = (b0_not_locked & ep0_direct_req) ? 1'b0 : 
		 b0_bigmux_csn;

      wire 	 emem_b0_wen_b = (b0_not_locked & ep0_direct_req) ? 
		 ep0_xmu_wen_b : b0_bigmux_wen_b;
   wire [7:0] 	 emem_b0_addr = (b0_not_locked & ep0_direct_req) ? 
		 convert_addr(ep0_xmu_addr) : b0_bigmux_addr;
   wire [63:0] 	 emem_b0_write_data = (b0_not_locked & ep0_direct_req) ?
		 ep0_xmu_write_data : b0_bigmux_write_data;
   wire [63:0] 	 emem_b0_write_mask = (b0_not_locked & ep0_direct_req) ?
		 ep0_xmu_write_mask : b0_bigmux_write_mask;
 
   wire 	 emem_b1_csn = (b1_not_locked & ep1_direct_req) ? 1'b0 : 
		 b1_bigmux_csn;
   
   wire 	 emem_b1_wen_b = (b1_not_locked & ep1_direct_req) ? 
		 ep1_xmu_wen_b : b1_bigmux_wen_b;
   wire [7:0] 	 emem_b1_addr = (b1_not_locked & ep1_direct_req) ? 
		 convert_addr(ep1_xmu_addr) : b1_bigmux_addr;
   wire [63:0] 	 emem_b1_write_data = (b1_not_locked & ep1_direct_req) ?
		 ep1_xmu_write_data : b1_bigmux_write_data;
   wire [63:0] 	 emem_b1_write_mask = (b1_not_locked & ep1_direct_req) ?
		 ep1_xmu_write_mask : b1_bigmux_write_mask;
      
   wire 	 emem_b2_csn = (b2_not_locked & ep2_direct_req) ? 1'b0 : 
		 b2_bigmux_csn;
   wire 	 emem_b2_wen_b = (b2_not_locked & ep2_direct_req) ? 
		 ep2_xmu_wen_b : b2_bigmux_wen_b;
   wire [7:0] 	 emem_b2_addr = (b2_not_locked & ep2_direct_req) ? 
		 convert_addr(ep2_xmu_addr) : b2_bigmux_addr;
   wire [63:0] 	 emem_b2_write_data = (b2_not_locked & ep2_direct_req) ?
		 ep2_xmu_write_data : b2_bigmux_write_data;
   wire [63:0] 	 emem_b2_write_mask = (b2_not_locked & ep2_direct_req) ?
		 ep2_xmu_write_mask : b2_bigmux_write_mask;

   wire 	 emem_b3_csn = (b3_not_locked & ep3_direct_req) ? 1'b0 : 
		 b3_bigmux_csn;
   wire 	 emem_b3_wen_b = (b3_not_locked & ep3_direct_req) ? 
		 ep3_xmu_wen_b : b3_bigmux_wen_b;
   wire [7:0] 	 emem_b3_addr = (b3_not_locked & ep3_direct_req) ? 
		 convert_addr(ep3_xmu_addr) : b3_bigmux_addr;
   wire [63:0] 	 emem_b3_write_data = (b3_not_locked & ep3_direct_req) ?
		 ep3_xmu_write_data : b3_bigmux_write_data;
   wire [63:0] 	 emem_b3_write_mask = (b3_not_locked & ep3_direct_req) ?
		 ep3_xmu_write_mask : b3_bigmux_write_mask;

   wire 	 ep0_xmu_dir_gnt_l0 = (b0_not_locked & ep0_direct_req);
   wire 	 ep1_xmu_dir_gnt_l0 = (b1_not_locked & ep1_direct_req);
   wire 	 ep2_xmu_dir_gnt_l0 = (b2_not_locked & ep2_direct_req);
   wire 	 ep3_xmu_dir_gnt_l0 = (b3_not_locked & ep3_direct_req);
   
   reg 		 ep0_xmu_dir_gnt_l1;
   reg 		 ep1_xmu_dir_gnt_l1;
   reg 		 ep2_xmu_dir_gnt_l1;
   reg 		 ep3_xmu_dir_gnt_l1;
   
   wire 	 ep0_xmu_gnt_l0_b0 = final_gnt_ep0_b0; // 
   wire 	 ep0_xmu_gnt_l0_b1 = final_gnt_ep0_b1;
   wire 	 ep0_xmu_gnt_l0_b2 = final_gnt_ep0_b2;
   wire 	 ep0_xmu_gnt_l0_b3 = final_gnt_ep0_b3;
   wire 	 ep1_xmu_gnt_l0_b0 = final_gnt_ep1_b0;
   wire 	 ep1_xmu_gnt_l0_b1 = final_gnt_ep1_b1;
   wire 	 ep1_xmu_gnt_l0_b2 = final_gnt_ep1_b2;
   wire 	 ep1_xmu_gnt_l0_b3 = final_gnt_ep1_b3;
   wire 	 ep2_xmu_gnt_l0_b0 = final_gnt_ep2_b0;
   wire 	 ep2_xmu_gnt_l0_b1 = final_gnt_ep2_b1;
   wire 	 ep2_xmu_gnt_l0_b2 = final_gnt_ep2_b2;
   wire 	 ep2_xmu_gnt_l0_b3 = final_gnt_ep2_b3;
   wire 	 ep3_xmu_gnt_l0_b0 = final_gnt_ep3_b0;
   wire 	 ep3_xmu_gnt_l0_b1 = final_gnt_ep3_b1;
   wire 	 ep3_xmu_gnt_l0_b2 = final_gnt_ep3_b2;
   wire 	 ep3_xmu_gnt_l0_b3 = final_gnt_ep3_b3;
   wire 	 nie_sm1_mem_gnt_l0_b0 = final_gnt_peon_b0 & peon_nie_sm1_gnt;
   wire 	 nie_sm1_mem_gnt_l0_b1 = final_gnt_peon_b1 & peon_nie_sm1_gnt;
   wire 	 nie_sm1_mem_gnt_l0_b2 = final_gnt_peon_b2 & peon_nie_sm1_gnt;
   wire 	 nie_sm1_mem_gnt_l0_b3 = final_gnt_peon_b3 & peon_nie_sm1_gnt;
   wire 	 nie_sm2_mem_gnt_l0_b0 = final_gnt_peon_b0 & peon_nie_sm2_gnt;
   wire 	 nie_sm2_mem_gnt_l0_b1 = final_gnt_peon_b1 & peon_nie_sm2_gnt;
   wire 	 nie_sm2_mem_gnt_l0_b2 = final_gnt_peon_b2 & peon_nie_sm2_gnt;
   wire 	 nie_sm2_mem_gnt_l0_b3 = final_gnt_peon_b3 & peon_nie_sm2_gnt;
   wire 	 epe_sm0_mem_gnt_l0_b0 = final_gnt_peon_b0 & peon_epe_sm0_gnt; 
   wire 	 epe_sm0_mem_gnt_l0_b1 = final_gnt_peon_b1 & peon_epe_sm0_gnt; 
   wire 	 epe_sm0_mem_gnt_l0_b2 = final_gnt_peon_b2 & peon_epe_sm0_gnt; 
   wire 	 epe_sm0_mem_gnt_l0_b3 = final_gnt_peon_b3 & peon_epe_sm0_gnt; 
   wire 	 epe_sm1_mem_gnt_l0_b0 = final_gnt_peon_b0 & peon_epe_sm1_gnt; 
   wire 	 epe_sm1_mem_gnt_l0_b1 = final_gnt_peon_b1 & peon_epe_sm1_gnt; 
   wire 	 epe_sm1_mem_gnt_l0_b2 = final_gnt_peon_b2 & peon_epe_sm1_gnt; 
   wire 	 epe_sm1_mem_gnt_l0_b3 = final_gnt_peon_b3 & peon_epe_sm1_gnt; 
   wire 	 se0_mem_gnt_l0_b0 = final_gnt_peon_b0 & peon_se0_gnt;
   wire 	 se0_mem_gnt_l0_b1 = final_gnt_peon_b1 & peon_se0_gnt;
   wire 	 se0_mem_gnt_l0_b2 = final_gnt_peon_b2 & peon_se0_gnt;
   wire 	 se0_mem_gnt_l0_b3 = final_gnt_peon_b3 & peon_se0_gnt;
   wire 	 se1_mem_gnt_l0_b0 = final_gnt_peon_b0 & peon_se1_gnt;
   wire 	 se1_mem_gnt_l0_b1 = final_gnt_peon_b1 & peon_se1_gnt;
   wire 	 se1_mem_gnt_l0_b2 = final_gnt_peon_b2 & peon_se1_gnt;
   wire 	 se1_mem_gnt_l0_b3 = final_gnt_peon_b3 & peon_se1_gnt;
   
   reg 	 ep0_xmu_gnt_l1_b0;
   reg 	 ep0_xmu_gnt_l1_b1;
   reg 	 ep0_xmu_gnt_l1_b2;
   reg 	 ep0_xmu_gnt_l1_b3;
   reg 	 ep1_xmu_gnt_l1_b0;
   reg 	 ep1_xmu_gnt_l1_b1;
   reg 	 ep1_xmu_gnt_l1_b2;
   reg 	 ep1_xmu_gnt_l1_b3;
   reg 	 ep2_xmu_gnt_l1_b0;
   reg 	 ep2_xmu_gnt_l1_b1;
   reg 	 ep2_xmu_gnt_l1_b2;
   reg 	 ep2_xmu_gnt_l1_b3;
   reg 	 ep3_xmu_gnt_l1_b0;
   reg 	 ep3_xmu_gnt_l1_b1;
   reg 	 ep3_xmu_gnt_l1_b2;
   reg 	 ep3_xmu_gnt_l1_b3;
   reg 	 nie_sm1_mem_gnt_l1_b0;
   reg 	 nie_sm1_mem_gnt_l1_b1;
   reg 	 nie_sm1_mem_gnt_l1_b2;
   reg 	 nie_sm1_mem_gnt_l1_b3;
   reg 	 nie_sm2_mem_gnt_l1_b0;
   reg 	 nie_sm2_mem_gnt_l1_b1;
   reg 	 nie_sm2_mem_gnt_l1_b2;
   reg 	 nie_sm2_mem_gnt_l1_b3;
   reg 	 epe_sm0_mem_gnt_l1_b0;
   reg 	 epe_sm0_mem_gnt_l1_b1;
   reg 	 epe_sm0_mem_gnt_l1_b2;
   reg 	 epe_sm0_mem_gnt_l1_b3;
   reg 	 epe_sm1_mem_gnt_l1_b0;
   reg 	 epe_sm1_mem_gnt_l1_b1;
   reg 	 epe_sm1_mem_gnt_l1_b2;
   reg 	 epe_sm1_mem_gnt_l1_b3;
   reg 	 se0_mem_gnt_l1_b0;
   reg 	 se0_mem_gnt_l1_b1;
   reg 	 se0_mem_gnt_l1_b2;
   reg 	 se0_mem_gnt_l1_b3;
   reg 	 se1_mem_gnt_l1_b0;
   reg 	 se1_mem_gnt_l1_b1;
   reg 	 se1_mem_gnt_l1_b2;
   reg 	 se1_mem_gnt_l1_b3;

   reg 	 ep0_xmu_gnt_l2;
   reg 	 ep1_xmu_gnt_l2;
   reg 	 ep2_xmu_gnt_l2;
   reg 	 ep3_xmu_gnt_l2;
   reg 	 nie_sm1_mem_gnt_l2;
   reg 	 nie_sm2_mem_gnt_l2;
   reg 	 epe_sm0_mem_gnt_l2;
   reg 	 epe_sm1_mem_gnt_l2;
   reg 	 se0_mem_gnt_l2;
   reg 	 se1_mem_gnt_l2;

   //there is no l0
   wire [63:0] 	 ep0_xmu_data_l1 = 
		 ep0_xmu_gnt_l1_b0 ? emem_b0_read_data :
		 ep0_xmu_gnt_l1_b1 ? emem_b1_read_data :
		 ep0_xmu_gnt_l1_b2 ? emem_b2_read_data :
		 ep0_xmu_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 ep1_xmu_data_l1= 
		 ep1_xmu_gnt_l1_b0 ? emem_b0_read_data :
		 ep1_xmu_gnt_l1_b1 ? emem_b1_read_data :
		 ep1_xmu_gnt_l1_b2 ? emem_b2_read_data :
		 ep1_xmu_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 ep2_xmu_data_l1= 
		 ep2_xmu_gnt_l1_b0 ? emem_b0_read_data :
		 ep2_xmu_gnt_l1_b1 ? emem_b1_read_data :
		 ep2_xmu_gnt_l1_b2 ? emem_b2_read_data :
		 ep2_xmu_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 ep3_xmu_data_l1= 
		 ep3_xmu_gnt_l1_b0 ? emem_b0_read_data :
		 ep3_xmu_gnt_l1_b1 ? emem_b1_read_data :
		 ep3_xmu_gnt_l1_b2 ? emem_b2_read_data :
		 ep3_xmu_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   
   wire [63:0] 	 nie_sm1_mem_data_l1 = 
		 nie_sm1_mem_gnt_l1_b0 ? emem_b0_read_data :
		 nie_sm1_mem_gnt_l1_b1 ? emem_b1_read_data :
		 nie_sm1_mem_gnt_l1_b2 ? emem_b2_read_data :
		 nie_sm1_mem_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 nie_sm2_mem_data_l1 = 
		 nie_sm2_mem_gnt_l1_b0 ? emem_b0_read_data :
		 nie_sm2_mem_gnt_l1_b1 ? emem_b1_read_data :
		 nie_sm2_mem_gnt_l1_b2 ? emem_b2_read_data :
		 nie_sm2_mem_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 epe_sm0_mem_data_l1 = 
		 epe_sm0_mem_gnt_l1_b0 ? emem_b0_read_data :
		 epe_sm0_mem_gnt_l1_b1 ? emem_b1_read_data :
		 epe_sm0_mem_gnt_l1_b2 ? emem_b2_read_data :
		 epe_sm0_mem_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 epe_sm1_mem_data_l1 = 
		 epe_sm1_mem_gnt_l1_b0 ? emem_b0_read_data :
		 epe_sm1_mem_gnt_l1_b1 ? emem_b1_read_data :
		 epe_sm1_mem_gnt_l1_b2 ? emem_b2_read_data :
		 epe_sm1_mem_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 se0_mem_data_l1= 
		 se0_mem_gnt_l1_b0 ? emem_b0_read_data :
		 se0_mem_gnt_l1_b1 ? emem_b1_read_data :
		 se0_mem_gnt_l1_b2 ? emem_b2_read_data :
		 se0_mem_gnt_l1_b3 ? emem_b3_read_data : 64'd0;
   wire [63:0] 	 se1_mem_data_l1= 
		 se1_mem_gnt_l1_b0 ? emem_b0_read_data :
		 se1_mem_gnt_l1_b1 ? emem_b1_read_data :
		 se1_mem_gnt_l1_b2 ? emem_b2_read_data :
		 se1_mem_gnt_l1_b3 ? emem_b3_read_data : 64'd0;

   reg [63:0] 	 ep0_xmu_data_l2;
   reg [63:0] 	 ep1_xmu_data_l2;
   reg [63:0] 	 ep2_xmu_data_l2;
   reg [63:0] 	 ep3_xmu_data_l2;
   reg [63:0] 	 nie_sm1_mem_data_l2;
   reg [63:0] 	 nie_sm2_mem_data_l2;
   reg [63:0] 	 epe_sm0_mem_data_l2;
   reg [63:0] 	 epe_sm1_mem_data_l2;
   reg [63:0] 	 se0_mem_data_l2;
   reg [63:0] 	 se1_mem_data_l2;

   assign ep0_mem_req_qual = r_ep0_xmu_req & ~(ep0_xmu_gnt_l1_b0 | ep0_xmu_gnt_l1_b1 |
					       ep0_xmu_gnt_l1_b2 | ep0_xmu_gnt_l1_b3 |
					       ep0_xmu_gnt_l2);
   assign ep1_mem_req_qual = r_ep1_xmu_req & ~(ep1_xmu_gnt_l1_b0 | ep1_xmu_gnt_l1_b1 |
					       ep1_xmu_gnt_l1_b2 | ep1_xmu_gnt_l1_b3 |
					       ep1_xmu_gnt_l2);
   assign ep2_mem_req_qual = r_ep2_xmu_req & ~(ep2_xmu_gnt_l1_b0 | ep2_xmu_gnt_l1_b1 |
					       ep2_xmu_gnt_l1_b2 | ep2_xmu_gnt_l1_b3 |
					       ep2_xmu_gnt_l2);
   assign ep3_mem_req_qual = r_ep3_xmu_req & ~(ep3_xmu_gnt_l1_b0 | ep3_xmu_gnt_l1_b1 |
					       ep3_xmu_gnt_l1_b2 | ep3_xmu_gnt_l1_b3 |
					       ep3_xmu_gnt_l2);
   assign nie_sm1_req_qual = r_nie_sm1_mem_req & ~(nie_sm1_mem_gnt_l1_b0 | nie_sm1_mem_gnt_l1_b1 |
						   nie_sm1_mem_gnt_l1_b2 | nie_sm1_mem_gnt_l1_b3 |
						   nie_sm1_mem_gnt_l2);
   assign nie_sm2_req_qual = r_nie_sm2_mem_req & ~(nie_sm2_mem_gnt_l1_b0 | nie_sm2_mem_gnt_l1_b1 |
						   nie_sm2_mem_gnt_l1_b2 | nie_sm2_mem_gnt_l1_b3 |
						   nie_sm2_mem_gnt_l2);
   assign epe_sm0_req_qual = r_epe_sm0_mem_req & ~(epe_sm0_mem_gnt_l1_b0 | epe_sm0_mem_gnt_l1_b1 |
						   epe_sm0_mem_gnt_l1_b2 | epe_sm0_mem_gnt_l1_b3 |
						   epe_sm0_mem_gnt_l2);
   assign epe_sm1_req_qual = r_epe_sm1_mem_req & ~(epe_sm1_mem_gnt_l1_b0 | epe_sm1_mem_gnt_l1_b1 |
						   epe_sm1_mem_gnt_l1_b2 | epe_sm1_mem_gnt_l1_b3 |
						   epe_sm1_mem_gnt_l2);
   assign se0_mem_req_qual = r_se0_mem_req & ~(se0_mem_gnt_l1_b0 | se0_mem_gnt_l1_b1 |
					       se0_mem_gnt_l1_b2 | se0_mem_gnt_l1_b3 |
					       se0_mem_gnt_l2);
   assign se1_mem_req_qual = r_se1_mem_req & ~(se1_mem_gnt_l1_b0 | se1_mem_gnt_l1_b1 |
					       se1_mem_gnt_l1_b2 | se1_mem_gnt_l1_b3 |
					       se1_mem_gnt_l2);
  

   assign ep0_xmu_gnt_late = ep0_xmu_dir_gnt_l1 | ep0_xmu_gnt_l2;
   assign ep1_xmu_gnt_late = ep1_xmu_dir_gnt_l1 | ep1_xmu_gnt_l2;
   assign ep2_xmu_gnt_late = ep2_xmu_dir_gnt_l1 | ep2_xmu_gnt_l2;
   assign ep3_xmu_gnt_late = ep3_xmu_dir_gnt_l1 | ep3_xmu_gnt_l2;
   
   assign ep0_xmu_read_data = ep0_xmu_dir_gnt_l1 ? emem_b0_read_data :
			      ep0_xmu_data_l2;
   assign ep1_xmu_read_data = ep1_xmu_dir_gnt_l1 ? emem_b1_read_data :
			      ep1_xmu_data_l2;
   assign ep2_xmu_read_data = ep2_xmu_dir_gnt_l1 ? emem_b2_read_data :
			      ep2_xmu_data_l2;
   assign ep3_xmu_read_data = ep3_xmu_dir_gnt_l1 ? emem_b3_read_data :
			      ep3_xmu_data_l2;
   
               
   assign nie_sm1_mem_gnt = nie_sm1_mem_gnt_l1_b0 | nie_sm1_mem_gnt_l1_b1 |
			    nie_sm1_mem_gnt_l1_b2 | nie_sm1_mem_gnt_l1_b3;
   assign nie_sm1_mem_read_data = nie_sm1_mem_data_l2;
   
   assign nie_sm2_mem_gnt = nie_sm1_mem_gnt_l1_b0 | nie_sm2_mem_gnt_l1_b1 | 
			    nie_sm1_mem_gnt_l1_b2 | nie_sm2_mem_gnt_l1_b3;
   assign nie_sm2_mem_read_data = nie_sm2_mem_data_l2;
   
   assign epe_sm0_mem_gnt = epe_sm0_mem_gnt_l1_b0 | epe_sm0_mem_gnt_l1_b1 |
			    epe_sm0_mem_gnt_l1_b2 | epe_sm0_mem_gnt_l1_b3;
   assign epe_sm0_mem_read_data = epe_sm0_mem_data_l2;

   assign epe_sm1_mem_gnt = epe_sm1_mem_gnt_l1_b0 | epe_sm1_mem_gnt_l1_b1 |
			    epe_sm1_mem_gnt_l1_b2 | epe_sm1_mem_gnt_l1_b3;
   assign epe_sm1_mem_read_data = epe_sm1_mem_data_l2;

   assign se0_mem_gnt = se0_mem_gnt_l1_b0 | se0_mem_gnt_l1_b1 |
			se0_mem_gnt_l1_b2 | se0_mem_gnt_l1_b3;
   assign se0_mem_read_data = se0_mem_data_l2;

   assign se1_mem_gnt = se1_mem_gnt_l1_b0 | se1_mem_gnt_l1_b1 |
			se1_mem_gnt_l1_b2 | se1_mem_gnt_l1_b3;
   assign se1_mem_read_data = se1_mem_data_l2;
   
 
   always@(posedge CLK or posedge rst) begin
      if(rst) begin
	 ep0_xmu_gnt_l1_b0 <= 1'b0;
	 ep0_xmu_gnt_l1_b1 <= 1'b0;
	 ep0_xmu_gnt_l1_b2 <= 1'b0;
	 ep0_xmu_gnt_l1_b3 <= 1'b0;
	 ep1_xmu_gnt_l1_b0 <= 1'b0;
	 ep1_xmu_gnt_l1_b1 <= 1'b0;
	 ep1_xmu_gnt_l1_b2 <= 1'b0;
	 ep1_xmu_gnt_l1_b3 <= 1'b0;
	 ep2_xmu_gnt_l1_b0 <= 1'b0;
	 ep2_xmu_gnt_l1_b1 <= 1'b0;
	 ep2_xmu_gnt_l1_b2 <= 1'b0;
	 ep2_xmu_gnt_l1_b3 <= 1'b0;
	 ep3_xmu_gnt_l1_b0 <= 1'b0;
    	 ep3_xmu_gnt_l1_b1 <= 1'b0;
	 ep3_xmu_gnt_l1_b2 <= 1'b0;
	 ep3_xmu_gnt_l1_b3 <= 1'b0;
	 nie_sm1_mem_gnt_l1_b0 <= 1'b0;
	 nie_sm1_mem_gnt_l1_b1 <= 1'b0;
    	 nie_sm1_mem_gnt_l1_b2 <= 1'b0;
    	 nie_sm1_mem_gnt_l1_b3 <= 1'b0;
    	 nie_sm2_mem_gnt_l1_b0 <= 1'b0;
    	 nie_sm2_mem_gnt_l1_b1 <= 1'b0;
    	 nie_sm2_mem_gnt_l1_b2 <= 1'b0;
    	 nie_sm2_mem_gnt_l1_b3 <= 1'b0;
    	 epe_sm0_mem_gnt_l1_b0 <= 1'b0;
    	 epe_sm0_mem_gnt_l1_b1 <= 1'b0;
    	 epe_sm0_mem_gnt_l1_b2 <= 1'b0;
    	 epe_sm0_mem_gnt_l1_b3 <= 1'b0;
    	 epe_sm1_mem_gnt_l1_b0 <= 1'b0;
    	 epe_sm1_mem_gnt_l1_b1 <= 1'b0;
    	 epe_sm1_mem_gnt_l1_b2 <= 1'b0;
    	 epe_sm1_mem_gnt_l1_b3 <= 1'b0;
    	 se0_mem_gnt_l1_b0 <= 1'b0;
    	 se0_mem_gnt_l1_b1 <= 1'b0;
    	 se0_mem_gnt_l1_b2 <= 1'b0;
    	 se0_mem_gnt_l1_b3 <= 1'b0;
    	 se1_mem_gnt_l1_b0 <= 1'b0;
    	 se1_mem_gnt_l1_b1 <= 1'b0;
    	 se1_mem_gnt_l1_b2 <= 1'b0;
    	 se1_mem_gnt_l1_b3 <= 1'b0;
	 
  	 ep0_xmu_gnt_l2 <= 1'b0;
    	 ep1_xmu_gnt_l2 <= 1'b0;
    	 ep2_xmu_gnt_l2 <= 1'b0;
    	 ep3_xmu_gnt_l2 <= 1'b0;
    	 nie_sm1_mem_gnt_l2 <= 1'b0;
    	 nie_sm2_mem_gnt_l2 <= 1'b0;
    	 epe_sm0_mem_gnt_l2 <= 1'b0;
    	 epe_sm1_mem_gnt_l2 <= 1'b0;
    	 se0_mem_gnt_l2 <= 1'b0;
    	 se1_mem_gnt_l2 <= 1'b0;

	 ep0_xmu_data_l2 <= 64'd0;
	 ep1_xmu_data_l2 <= 64'd0;
     	 ep2_xmu_data_l2 <= 64'd0;
     	 ep3_xmu_data_l2 <= 64'd0;
     	 nie_sm1_mem_data_l2 <= 64'd0;
     	 nie_sm2_mem_data_l2 <= 64'd0;
     	 epe_sm0_mem_data_l2 <= 64'd0;
     	 epe_sm1_mem_data_l2 <= 64'd0;
	 se0_mem_data_l2 <= 64'd0;
    	 se1_mem_data_l2 <= 64'd0;

	 ep0_xmu_dir_gnt_l1 <= 1'b0;
	 ep1_xmu_dir_gnt_l1 <= 1'b0;
	 ep2_xmu_dir_gnt_l1 <= 1'b0;
	 ep3_xmu_dir_gnt_l1 <= 1'b0;
      end // if (rst)
      else begin
	 ep0_xmu_gnt_l1_b0 <= ep0_xmu_gnt_l0_b0;
	 ep0_xmu_gnt_l1_b1 <= ep0_xmu_gnt_l0_b1;
	 ep0_xmu_gnt_l1_b2 <= ep0_xmu_gnt_l0_b2;
	 ep0_xmu_gnt_l1_b3 <= ep0_xmu_gnt_l0_b3;
	 ep1_xmu_gnt_l1_b0 <= ep1_xmu_gnt_l0_b0;
	 ep1_xmu_gnt_l1_b1 <= ep1_xmu_gnt_l0_b1;
	 ep1_xmu_gnt_l1_b2 <= ep1_xmu_gnt_l0_b2;
	 ep1_xmu_gnt_l1_b3 <= ep1_xmu_gnt_l0_b3;
	 ep2_xmu_gnt_l1_b0 <= ep2_xmu_gnt_l0_b0;
	 ep2_xmu_gnt_l1_b1 <= ep2_xmu_gnt_l0_b1;
	 ep2_xmu_gnt_l1_b2 <= ep2_xmu_gnt_l0_b2;
	 ep2_xmu_gnt_l1_b3 <= ep2_xmu_gnt_l0_b3;
	 ep3_xmu_gnt_l1_b0 <= ep3_xmu_gnt_l0_b0;
    	 ep3_xmu_gnt_l1_b1 <= ep3_xmu_gnt_l0_b1;
	 ep3_xmu_gnt_l1_b2 <= ep3_xmu_gnt_l0_b2;
	 ep3_xmu_gnt_l1_b3 <= ep3_xmu_gnt_l0_b3;
	 nie_sm1_mem_gnt_l1_b0 <= nie_sm1_mem_gnt_l0_b0;
	 nie_sm1_mem_gnt_l1_b1 <= nie_sm1_mem_gnt_l0_b1;
    	 nie_sm1_mem_gnt_l1_b2 <= nie_sm1_mem_gnt_l0_b2;
    	 nie_sm1_mem_gnt_l1_b3 <= nie_sm1_mem_gnt_l0_b3;
    	 nie_sm2_mem_gnt_l1_b0 <= nie_sm2_mem_gnt_l0_b0;
    	 nie_sm2_mem_gnt_l1_b1 <= nie_sm2_mem_gnt_l0_b1;
    	 nie_sm2_mem_gnt_l1_b2 <= nie_sm2_mem_gnt_l0_b2;
    	 nie_sm2_mem_gnt_l1_b3 <= nie_sm2_mem_gnt_l0_b3;
    	 epe_sm0_mem_gnt_l1_b0 <= epe_sm0_mem_gnt_l0_b0;
    	 epe_sm0_mem_gnt_l1_b1 <= epe_sm0_mem_gnt_l0_b1;
    	 epe_sm0_mem_gnt_l1_b2 <= epe_sm0_mem_gnt_l0_b2;
    	 epe_sm0_mem_gnt_l1_b3 <= epe_sm0_mem_gnt_l0_b3;
    	 epe_sm1_mem_gnt_l1_b0 <= epe_sm1_mem_gnt_l0_b0;
    	 epe_sm1_mem_gnt_l1_b1 <= epe_sm1_mem_gnt_l0_b1;
    	 epe_sm1_mem_gnt_l1_b2 <= epe_sm1_mem_gnt_l0_b2;
    	 epe_sm1_mem_gnt_l1_b3 <= epe_sm1_mem_gnt_l0_b3;
    	 se0_mem_gnt_l1_b0 <= se0_mem_gnt_l0_b0;
    	 se0_mem_gnt_l1_b1 <= se0_mem_gnt_l0_b1;
    	 se0_mem_gnt_l1_b2 <= se0_mem_gnt_l0_b2;
    	 se0_mem_gnt_l1_b3 <= se0_mem_gnt_l0_b3;
    	 se1_mem_gnt_l1_b0 <= se1_mem_gnt_l0_b0;
    	 se1_mem_gnt_l1_b1 <= se1_mem_gnt_l0_b1;
    	 se1_mem_gnt_l1_b2 <= se1_mem_gnt_l0_b2;
    	 se1_mem_gnt_l1_b3 <= se1_mem_gnt_l0_b3;
	 //todo, the gating here
	 ep0_xmu_gnt_l2 <= ep0_xmu_gnt_l1_b0 | ep0_xmu_gnt_l1_b1 | 
			   ep0_xmu_gnt_l1_b2 | ep0_xmu_gnt_l1_b3;
    	 ep1_xmu_gnt_l2 <= ep1_xmu_gnt_l1_b0 | ep1_xmu_gnt_l1_b1 |
			   ep1_xmu_gnt_l1_b2 | ep1_xmu_gnt_l1_b3;
	 ep2_xmu_gnt_l2 <= ep2_xmu_gnt_l1_b0 | ep2_xmu_gnt_l1_b1 |
			   ep2_xmu_gnt_l1_b2 | ep3_xmu_gnt_l1_b3;
	 ep3_xmu_gnt_l2 <= ep3_xmu_gnt_l1_b0 | ep3_xmu_gnt_l1_b1 |
			   ep3_xmu_gnt_l1_b2 | ep3_xmu_gnt_l1_b3;
	 nie_sm1_mem_gnt_l2 <= nie_sm1_mem_gnt_l1_b0 | nie_sm1_mem_gnt_l1_b1 |
			       nie_sm1_mem_gnt_l1_b2 | nie_sm1_mem_gnt_l1_b3;
	 nie_sm2_mem_gnt_l2 <= nie_sm2_mem_gnt_l1_b0 | nie_sm2_mem_gnt_l1_b1 |
			       nie_sm2_mem_gnt_l1_b2 | nie_sm2_mem_gnt_l1_b3;
	 epe_sm0_mem_gnt_l2 <= epe_sm0_mem_gnt_l1_b0 | epe_sm0_mem_gnt_l1_b1 |
			       epe_sm0_mem_gnt_l1_b2 | epe_sm0_mem_gnt_l1_b3;
	 epe_sm1_mem_gnt_l2 <= epe_sm1_mem_gnt_l1_b0 | epe_sm1_mem_gnt_l1_b2 |
			       epe_sm1_mem_gnt_l1_b2 | epe_sm1_mem_gnt_l1_b3;
	 se0_mem_gnt_l2 <= se0_mem_gnt_l1_b0 | se0_mem_gnt_l1_b1 |
			   se0_mem_gnt_l1_b2 | se0_mem_gnt_l1_b3;
	 se1_mem_gnt_l2 <= se1_mem_gnt_l1_b0 | se1_mem_gnt_l1_b1 |
			   se1_mem_gnt_l1_b2 | se1_mem_gnt_l1_b3;

	 //todo, gating...
	 ep0_xmu_data_l2 <= ep0_xmu_data_l1;
     	 ep1_xmu_data_l2 <= ep1_xmu_data_l1;
     	 ep2_xmu_data_l2 <= ep2_xmu_data_l1;
     	 ep3_xmu_data_l2 <= ep3_xmu_data_l1;
     	 nie_sm1_mem_data_l2 <= nie_sm1_mem_data_l1;
     	 nie_sm2_mem_data_l2 <= nie_sm2_mem_data_l1;
     	 epe_sm0_mem_data_l2 <= epe_sm0_mem_data_l1;
     	 epe_sm1_mem_data_l2 <= epe_sm1_mem_data_l1;
	 se0_mem_data_l2 <= se0_mem_data_l1;
    	 se1_mem_data_l2 <= se1_mem_data_l1;

	 ep0_xmu_dir_gnt_l1 <= ep0_xmu_dir_gnt_l0;
	 ep1_xmu_dir_gnt_l1 <= ep1_xmu_dir_gnt_l0;
	 ep2_xmu_dir_gnt_l1 <= ep2_xmu_dir_gnt_l0;
	 ep3_xmu_dir_gnt_l1 <= ep3_xmu_dir_gnt_l0;
      end // else: !if(rst)
   end // always@ (posedge CLK or posedge rst)


     /* Emem bank 0 signals */
   wire b0_csn = 
	TEST_MODE ? test_b0_csn : 
	emem_b0_csn;
  
   wire b0_wen =
	TEST_MODE ? test_b0_wen_b : 
	emem_b0_wen_b;
 
   wire [7:0] b0_a =
	      TEST_MODE ? test_b0_addr :
	      emem_b0_addr[7:0];
   
   wire [63:0] b0_d = 
	       TEST_MODE ? test_b0_write_data : 
	       emem_b0_write_data[63:0];


   wire [63:0] b0_m = 
	       TEST_MODE ? test_b0_write_mask : 
	       emem_b0_write_mask[63:0];

   /* Emem bank 1 signals */
   wire        b1_csn = 
	       TEST_MODE ? test_b1_csn : 
	       emem_b1_csn;
   
   wire        b1_wen =
	       TEST_MODE ? test_b1_wen_b : 
	       emem_b1_wen_b;
   
   wire [7:0]  b1_a =
	       TEST_MODE ? test_b1_addr :
	       emem_b1_addr[7:0];
   
   wire [63:0] b1_d = 
	       TEST_MODE ? test_b1_write_data : 
	       emem_b1_write_data[63:0];
   

   wire [63:0] b1_m = 
	       TEST_MODE ? test_b1_write_mask : 
	       emem_b1_write_mask[63:0];

   /* Emem bank 2 signals */
   wire        b2_csn = 
	       TEST_MODE ? test_b2_csn : 
	       emem_b2_csn;
   
   wire        b2_wen =
	       TEST_MODE ? test_b2_wen_b : 
	       emem_b2_wen_b;
   
   wire [7:0]  b2_a =
	       TEST_MODE ? test_b2_addr :
	       emem_b2_addr[7:0];
   
   wire [63:0] b2_d = 
	       TEST_MODE ? test_b2_write_data : 
	       emem_b2_write_data[63:0];
   

   wire [63:0] b2_m = 
	       TEST_MODE ? test_b2_write_mask : 
	       emem_b2_write_mask[63:0];

   /* Emem bank 2 signals */
   wire        b3_csn = 
	       TEST_MODE ? test_b3_csn : 
	       emem_b3_csn;
   
   wire        b3_wen =
	       TEST_MODE ? test_b3_wen_b : 
	       emem_b3_wen_b;
   
   wire [7:0]  b3_a =
	       TEST_MODE ? test_b3_addr :
	       emem_b3_addr[7:0];
   
   wire [63:0] b3_d = 
	       TEST_MODE ? test_b3_write_data : 
	       emem_b3_write_data[63:0];
   

   wire [63:0] b3_m = 
	       TEST_MODE ? test_b3_write_mask : 
	       emem_b3_write_mask[63:0];


   
   fpga_emem
     the_emem_b0(
		 // Outputs
		 .dout			(emem_b0_read_data[63:0]),
		 // Inputs
		 .clk			(CLK),
		 .wen			(b0_wen),
		 .csn			(b0_csn),
		 .addr			(b0_a),
		 .din			(b0_d),
		 .mask			(b0_m)
		 );
   
   fpga_emem
     the_emem_b1(
		 // Outputs
		 .dout			(emem_b1_read_data[63:0]),
		 // Inputs
		 .clk			(CLK),
		 .wen			(b1_wen),
		 .csn			(b1_csn),
		 .addr			(b1_a),
		 .din			(b1_d),
		 .mask			(b1_m)
		 );
 
   fpga_emem
     the_emem_b2(
		 // Outputs
		 .dout			(emem_b2_read_data[63:0]),
		 // Inputs
		 .clk			(CLK),
		 .wen			(b2_wen),
		 .csn			(b2_csn),
		 .addr			(b2_a),
		 .din			(b2_d),
		 .mask			(b2_m)
		 );
   fpga_emem
     the_emem_b3(
		 // Outputs
		 .dout			(emem_b3_read_data[63:0]),
		 // Inputs
		 .clk			(CLK),
		 .wen			(b3_wen),
		 .csn			(b3_csn),
		 .addr			(b3_a),
		 .din			(b3_d),
		 .mask			(b3_m)
		 );
		 
   function does_this_addr_goto_b0;
      input [15:0] addr;
      begin
	 if((addr[15:9] == 7'd0) | (addr[15] & addr[2:1] == 2'h0))
	   does_this_addr_goto_b0 = 1'b1;
	 else
	   does_this_addr_goto_b0 = 1'b0;
      end
   endfunction // does_this_addr_goto_b0

    function does_this_addr_goto_b1;
      input [15:0] addr;
      begin
	 if((addr[15:9] == 7'd1) | (addr[15] & addr[2:1] == 2'h1))
	   does_this_addr_goto_b1 = 1'b1;
	 else
	   does_this_addr_goto_b1 = 1'b0;
      end
   endfunction // does_this_addr_goto_b0

    function does_this_addr_goto_b2;
      input [15:0] addr;
      begin
	 if((addr[15:9] == 7'd2) | (addr[15] & addr[2:1] == 2'h2))
	   does_this_addr_goto_b2 = 1'b1;
	 else
	   does_this_addr_goto_b2 = 1'b0;
      end
   endfunction // does_this_addr_goto_b0
   
   function does_this_addr_goto_b3;
      input [15:0] addr;
      begin
	 if((addr[15:9] == 7'd3) | (addr[15] & addr[2:1] == 2'h3))
	   does_this_addr_goto_b3 = 1'b1;
	 else
	   does_this_addr_goto_b3 = 1'b0;
      end
   endfunction // does_this_addr_goto_b0

   function can_i_steal_this;
      input [1:0] bank_num;
      input [7:0] set_addr;
      input [15:0] my_addr;
      begin
	 if(my_addr[15])
	   if(my_addr[2:1] == bank_num[1:0])
	     can_i_steal_this = my_addr[10:3] == set_addr[7:0];
	   else
	     can_i_steal_this = 1'b0;
	 else
	   if(my_addr[10:9] == bank_num[1:0])
	     can_i_steal_this = my_addr[8:1] == set_addr[7:0];
	   else
	     can_i_steal_this = 1'b0;
      end
   endfunction // can_i_steal_this
   
   function [7:0] convert_addr;
      input [15:0] addr;
      begin
	 if(addr[15])
	   convert_addr = addr[10:3];
	 else
	   convert_addr = addr[8:1];
      end
   endfunction // convert_addr
endmodule // v2_emem
