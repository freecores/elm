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


module message_block(/*AUTOARG*/
   // Outputs
   ep0_rs1_data, ep0_rs2_data, ep1_rs1_data, ep1_rs2_data,
   ep2_rs1_data, ep2_rs2_data, ep3_rs1_data, ep3_rs2_data,
   ep0_mr0_empty, ep0_mr1_empty, ep0_mr2_empty, ep0_mr3_empty,
   ep0_mr4_empty, ep0_mr5_empty, ep0_mr6_empty, ep0_mr7_empty,
   ep1_mr0_empty, ep1_mr1_empty, ep1_mr2_empty, ep1_mr3_empty,
   ep1_mr4_empty, ep1_mr5_empty, ep1_mr6_empty, ep1_mr7_empty,
   ep2_mr0_empty, ep2_mr1_empty, ep2_mr2_empty, ep2_mr3_empty,
   ep2_mr4_empty, ep2_mr5_empty, ep2_mr6_empty, ep2_mr7_empty,
   ep3_mr0_empty, ep3_mr1_empty, ep3_mr2_empty, ep3_mr3_empty,
   ep3_mr4_empty, ep3_mr5_empty, ep3_mr6_empty, ep3_mr7_empty,
   ep0_mr0_full, ep0_mr1_full, ep0_mr2_full, ep0_mr3_full,
   ep0_mr4_full, ep0_mr5_full, ep0_mr6_full, ep0_mr7_full,
   ep1_mr0_full, ep1_mr1_full, ep1_mr2_full, ep1_mr3_full,
   ep1_mr4_full, ep1_mr5_full, ep1_mr6_full, ep1_mr7_full,
   ep2_mr0_full, ep2_mr1_full, ep2_mr2_full, ep2_mr3_full,
   ep2_mr4_full, ep2_mr5_full, ep2_mr6_full, ep2_mr7_full,
   ep3_mr0_full, ep3_mr1_full, ep3_mr2_full, ep3_mr3_full,
   ep3_mr4_full, ep3_mr5_full, ep3_mr6_full, ep3_mr7_full,
   // Inputs
   clk, rst, ep0_decode_stall, ep1_decode_stall, ep2_decode_stall,
   ep3_decode_stall, ep0_rs1_ptr, ep0_rs1_ptr_valid, ep0_rs2_ptr,
   ep0_rs2_ptr_valid, ep1_rs1_ptr, ep1_rs1_ptr_valid, ep1_rs2_ptr,
   ep1_rs2_ptr_valid, ep2_rs1_ptr, ep2_rs1_ptr_valid, ep2_rs2_ptr,
   ep2_rs2_ptr_valid, ep3_rs1_ptr, ep3_rs1_ptr_valid, ep3_rs2_ptr,
   ep3_rs2_ptr_valid, ep0_alu_rd_ptr, ep0_alu_rd_ptr_valid,
   ep0_xmu_rd_ptr, ep0_xmu_rd_ptr_valid, ep1_alu_rd_ptr,
   ep1_alu_rd_ptr_valid, ep1_xmu_rd_ptr, ep1_xmu_rd_ptr_valid,
   ep2_alu_rd_ptr, ep2_alu_rd_ptr_valid, ep2_xmu_rd_ptr,
   ep2_xmu_rd_ptr_valid, ep3_alu_rd_ptr, ep3_alu_rd_ptr_valid,
   ep3_xmu_rd_ptr, ep3_xmu_rd_ptr_valid, ep0_alu_rd_data,
   ep0_xmu_rd_data, ep1_alu_rd_data, ep1_xmu_rd_data, ep2_alu_rd_data,
   ep2_xmu_rd_data, ep3_alu_rd_data, ep3_xmu_rd_data
   );
   input clk;
   input rst;

   input ep0_decode_stall;
   input ep1_decode_stall;
   input ep2_decode_stall;
   input ep3_decode_stall;

   /* Read pointers for EP0 */
   input [2:0] ep0_rs1_ptr;
   input       ep0_rs1_ptr_valid;

   input [2:0] ep0_rs2_ptr;
   input       ep0_rs2_ptr_valid;

   /* Read pointers for EP1 */
   input [2:0] ep1_rs1_ptr;
   input       ep1_rs1_ptr_valid;

   input [2:0] ep1_rs2_ptr;
   input       ep1_rs2_ptr_valid;

   /* Read pointers for EP2 */
   input [2:0] ep2_rs1_ptr;
   input       ep2_rs1_ptr_valid;

   input [2:0] ep2_rs2_ptr;
   input       ep2_rs2_ptr_valid;

   /* Read pointers for EP3 */
   input [2:0] ep3_rs1_ptr;
   input       ep3_rs1_ptr_valid;

   input [2:0] ep3_rs2_ptr;
   input       ep3_rs2_ptr_valid;

   /* Write pointers for EP0 */
   input [2:0] ep0_alu_rd_ptr;
   input       ep0_alu_rd_ptr_valid;

   input [2:0] ep0_xmu_rd_ptr;
   input       ep0_xmu_rd_ptr_valid;

   /* Write pointers for EP1 */
   input [2:0] ep1_alu_rd_ptr;
   input       ep1_alu_rd_ptr_valid;

   input [2:0] ep1_xmu_rd_ptr;
   input       ep1_xmu_rd_ptr_valid;  

   /* Write pointers for EP2 */
   input [2:0] ep2_alu_rd_ptr;
   input       ep2_alu_rd_ptr_valid;

   input [2:0] ep2_xmu_rd_ptr;
   input       ep2_xmu_rd_ptr_valid;

   /* Write pointers for EP3 */
   input [2:0] ep3_alu_rd_ptr;
   input       ep3_alu_rd_ptr_valid;

   input [2:0] ep3_xmu_rd_ptr;
   input       ep3_xmu_rd_ptr_valid;

   /* EP0 write data */
   input [31:0] ep0_alu_rd_data;
   input [31:0] ep0_xmu_rd_data;

   /* EP1 write data */
   input [31:0] ep1_alu_rd_data;
   input [31:0] ep1_xmu_rd_data;

   /* EP2 write data */
   input [31:0] ep2_alu_rd_data;
   input [31:0] ep2_xmu_rd_data;

   /* EP3 write data */
   input [31:0] ep3_alu_rd_data;
   input [31:0] ep3_xmu_rd_data;

   /* EP0 read data */
   output [31:0] ep0_rs1_data;
   output [31:0] ep0_rs2_data;

   /* EP1 read data */
   output [31:0] ep1_rs1_data;
   output [31:0] ep1_rs2_data;

   /* EP2 read data */
   output [31:0] ep2_rs1_data;
   output [31:0] ep2_rs2_data;

   /* EP3 read data */
   output [31:0] ep3_rs1_data;
   output [31:0] ep3_rs2_data;
      
   output ep0_mr0_empty;
   output ep0_mr1_empty;
   output ep0_mr2_empty;
   output ep0_mr3_empty;
   output ep0_mr4_empty;
   output ep0_mr5_empty;
   output ep0_mr6_empty;
   output ep0_mr7_empty;
   
   output ep1_mr0_empty;
   output ep1_mr1_empty;
   output ep1_mr2_empty;
   output ep1_mr3_empty;
   output ep1_mr4_empty;
   output ep1_mr5_empty;
   output ep1_mr6_empty;
   output ep1_mr7_empty;
  
   output ep2_mr0_empty;
   output ep2_mr1_empty;
   output ep2_mr2_empty;
   output ep2_mr3_empty;
   output ep2_mr4_empty;
   output ep2_mr5_empty;
   output ep2_mr6_empty;
   output ep2_mr7_empty;
   
   output ep3_mr0_empty;
   output ep3_mr1_empty;
   output ep3_mr2_empty;
   output ep3_mr3_empty;
   output ep3_mr4_empty;
   output ep3_mr5_empty;
   output ep3_mr6_empty;
   output ep3_mr7_empty;

   
   output ep0_mr0_full;
   output ep0_mr1_full;
   output ep0_mr2_full;
   output ep0_mr3_full;
   output ep0_mr4_full;
   output ep0_mr5_full;
   output ep0_mr6_full;
   output ep0_mr7_full;
   
   output ep1_mr0_full;
   output ep1_mr1_full;
   output ep1_mr2_full;
   output ep1_mr3_full;
   output ep1_mr4_full;
   output ep1_mr5_full;
   output ep1_mr6_full;
   output ep1_mr7_full;
  
   output ep2_mr0_full;
   output ep2_mr1_full;
   output ep2_mr2_full;
   output ep2_mr3_full;
   output ep2_mr4_full;
   output ep2_mr5_full;
   output ep2_mr6_full;
   output ep2_mr7_full;
   
   output ep3_mr0_full;
   output ep3_mr1_full;
   output ep3_mr2_full;
   output ep3_mr3_full;
   output ep3_mr4_full;
   output ep3_mr5_full;
   output ep3_mr6_full;
   output ep3_mr7_full;

   /* Naming Scheme:
    * epXepY =
    * epX = receiver
    * epY = sender
    */

   
   /* MR0 */
   reg [31:0]	 ep0ep0_mr0;
   reg [31:0] 	 ep0ep1_mr0;
   reg [31:0] 	 ep0ep2_mr0;
   reg [31:0] 	 ep0ep3_mr0;

   reg 	 ep0ep0_mr0_full;
   reg 	 ep0ep1_mr0_full;
   reg 	 ep0ep2_mr0_full;
   reg 	 ep0ep3_mr0_full;

   reg 	 ep1ep0_mr1_full;
   reg 	 ep1ep1_mr1_full;
   reg 	 ep1ep2_mr1_full;
   reg 	 ep1ep3_mr1_full;

   reg 	 ep2ep0_mr2_full;
   reg 	 ep2ep1_mr2_full;
   reg 	 ep2ep2_mr2_full;
   reg 	 ep2ep3_mr2_full;

      
   reg 	 ep3ep0_mr3_full;
   reg 	 ep3ep1_mr3_full;
   reg 	 ep3ep2_mr3_full;
   reg 	 ep3ep3_mr3_full;

   reg 	 ep0ep1_mr4_full;
   reg 	 ep1ep2_mr4_full;
   reg 	 ep2ep3_mr4_full;
   reg 	 ep3ep0_mr4_full;
   
   
   reg 	 ep1ep0_mr5_full;
   reg 	 ep2ep1_mr5_full;
   reg 	 ep3ep2_mr5_full;
   reg 	 ep0ep3_mr5_full;
   

   
   assign ep0_mr0_empty = ~ep0ep0_mr0_full;
   assign ep0_mr0_full = ep0ep0_mr0_full;
   assign ep1_mr0_empty = ~ep1ep0_mr1_full; //when ep1 reads its MR0
   assign ep1_mr0_full = ep0ep1_mr0_full;  
   assign ep2_mr0_empty = ~ep2ep0_mr2_full; //when ep2 reads its MR0...
   assign ep2_mr0_full = ep0ep2_mr0_full;
   assign ep3_mr0_empty = ~ep3ep0_mr3_full;
   assign ep3_mr0_full = ep0ep3_mr0_full;
      

   
   /* MR1 */
   reg [31:0]	 ep1ep0_mr1;
   reg [31:0] 	 ep1ep1_mr1;
   reg [31:0] 	 ep1ep2_mr1;
   reg [31:0] 	 ep1ep3_mr1;



   assign ep0_mr1_empty = ~ep0ep1_mr0_full;  //When ep0 reads its mr1
   assign ep0_mr1_full = ep1ep0_mr1_full;
   assign ep1_mr1_empty = ~ep1ep1_mr1_full;
   assign ep1_mr1_full = ep1ep1_mr1_full;
   assign ep2_mr1_empty = ~ep2ep1_mr2_full;
   assign ep2_mr1_full = ep1ep2_mr1_full;
   assign ep3_mr1_empty = ~ep3ep1_mr3_full;
   assign ep3_mr1_full = ep1ep3_mr1_full;
   

   /* MR2 */
   reg [31:0]	 ep2ep0_mr2;
   reg [31:0] 	 ep2ep1_mr2;
   reg [31:0] 	 ep2ep2_mr2;
   reg [31:0] 	 ep2ep3_mr2;



   assign ep0_mr2_empty = ~ep0ep2_mr0_full; //when ep0 reads its mr2
   assign ep0_mr2_full = ep2ep0_mr2_full;
   assign ep1_mr2_empty = ~ep1ep2_mr1_full;
   assign ep1_mr2_full = ep2ep1_mr2_full;
   assign ep2_mr2_empty = ~ep2ep2_mr2_full;
   assign ep2_mr2_full = ep2ep2_mr2_full;
   assign ep3_mr2_empty = ~ep3ep2_mr3_full;
   assign ep3_mr2_full = ep2ep3_mr2_full;
  
   /* MR3 */
   reg [31:0] ep3ep0_mr3;
   reg [31:0] ep3ep1_mr3;
   reg [31:0] ep3ep2_mr3;
   reg [31:0] ep3ep3_mr3;

   assign ep0_mr3_empty = ~ep0ep3_mr0_full;
   assign ep0_mr3_full = ep3ep0_mr3_full;
   assign ep1_mr3_empty = ~ep1ep3_mr1_full;
   assign ep1_mr3_full = ep3ep1_mr3_full;
   assign ep2_mr3_empty = ~ep2ep3_mr2_full;
   assign ep2_mr3_full = ep3ep2_mr3_full;
   assign ep3_mr3_empty = ~ep3ep3_mr3_full;
   assign ep3_mr3_full = ep3ep3_mr3_full;

   
   /* MR4 */
   reg [31:0] ep0ep1_mr4;
   reg [31:0] ep1ep2_mr4;
   reg [31:0] ep2ep3_mr4;
   reg [31:0] ep3ep0_mr4;


   //1 -> 0 -> 3 -> 2 -> 1 ...
   assign ep0_mr4_empty = ~ep0ep1_mr4_full;  //ep0's mr4
   assign ep0_mr4_full =   ep3ep0_mr4_full;
   assign ep1_mr4_empty = ~ep1ep2_mr4_full;
   assign ep1_mr4_full =   ep0ep1_mr4_full;
   assign ep2_mr4_empty = ~ep2ep3_mr4_full;
   assign ep2_mr4_full =   ep1ep2_mr4_full;
   assign ep3_mr4_empty = ~ep3ep0_mr4_full;
   assign ep3_mr4_full =   ep2ep3_mr4_full;
   

   /* MR5 */
   reg [31:0] ep1ep0_mr5;
   reg [31:0] ep2ep1_mr5;
   reg [31:0] ep3ep2_mr5;
   reg [31:0] ep0ep3_mr5;

   //0->1->2->3->0
   assign ep0_mr5_empty = ~ep0ep3_mr5_full;
   assign ep0_mr5_full =   ep1ep0_mr5_full;
   assign ep1_mr5_empty = ~ep1ep0_mr5_full;
   assign ep1_mr5_full =   ep2ep1_mr5_full;
   assign ep2_mr5_empty = ~ep2ep1_mr5_full;
   assign ep2_mr5_full =   ep3ep2_mr5_full;
   assign ep3_mr5_empty = ~ep3ep2_mr5_full;
   assign ep3_mr5_full =   ep0ep3_mr5_full;

   assign ep0_mr6_empty = 1'b0;
   assign ep0_mr6_full = 1'b1;

   assign ep1_mr6_empty = 1'b0;
   assign ep1_mr6_full = 1'b1;

   assign ep2_mr6_empty = 1'b0;
   assign ep2_mr6_full = 1'b1;

   assign ep3_mr6_empty = 1'b0;
   assign ep3_mr6_full = 1'b1;

   assign ep0_mr7_empty = 1'b0;
   assign ep0_mr7_full = 1'b1;

   assign ep1_mr7_empty = 1'b0;
   assign ep1_mr7_full = 1'b1;

   assign ep2_mr7_empty = 1'b0;
   assign ep2_mr7_full = 1'b1;

   assign ep3_mr7_empty = 1'b0;
   assign ep3_mr7_full = 1'b1;


   assign ep0_rs1_data = 
			 (ep0_rs1_ptr == 3'd0) ? ep0ep0_mr0 :
			 (ep0_rs1_ptr == 3'd1) ? ep0ep1_mr0 :
			 (ep0_rs1_ptr == 3'd2) ? ep0ep2_mr0 :
			 (ep0_rs1_ptr == 3'd3) ? ep0ep3_mr0 :
			 (ep0_rs1_ptr == 3'd4) ? ep0ep1_mr4 :
			 (ep0_rs1_ptr == 3'd5) ? ep0ep3_mr5 :
			 (ep0_rs1_ptr == 3'd6) ? 32'd0 :
			 32'd0;

   assign ep0_rs2_data = 
			 (ep0_rs2_ptr == 3'd0) ? ep0ep0_mr0 :
			 (ep0_rs2_ptr == 3'd1) ? ep0ep1_mr0 :
			 (ep0_rs2_ptr == 3'd2) ? ep0ep2_mr0 :
			 (ep0_rs2_ptr == 3'd3) ? ep0ep3_mr0 :
			 (ep0_rs2_ptr == 3'd4) ? ep0ep1_mr4 :
			 (ep0_rs2_ptr == 3'd5) ? ep0ep3_mr5 :
			 (ep0_rs2_ptr == 3'd6) ? 32'd0 :
			 32'd0;

   assign ep1_rs1_data = 
			 (ep1_rs1_ptr == 3'd0) ? ep1ep0_mr1 :
			 (ep1_rs1_ptr == 3'd1) ? ep1ep1_mr1 :
			 (ep1_rs1_ptr == 3'd2) ? ep1ep2_mr1 :
			 (ep1_rs1_ptr == 3'd3) ? ep1ep3_mr1 :
			 (ep1_rs1_ptr == 3'd4) ? ep1ep2_mr4 :
			 (ep1_rs1_ptr == 3'd5) ? ep1ep0_mr5 :
			 (ep1_rs1_ptr == 3'd6) ? 32'd0 :
			 32'd0;

   assign ep1_rs2_data = 
			 (ep1_rs2_ptr == 3'd0) ? ep1ep0_mr1 :
			 (ep1_rs2_ptr == 3'd1) ? ep1ep1_mr1 :
			 (ep1_rs2_ptr == 3'd2) ? ep1ep2_mr1 :
			 (ep1_rs2_ptr == 3'd3) ? ep1ep3_mr1 :
			 (ep1_rs2_ptr == 3'd4) ? ep1ep2_mr4 :
			 (ep1_rs2_ptr == 3'd5) ? ep1ep0_mr5 :
			 (ep1_rs2_ptr == 3'd6) ? 32'd0 :
			 32'd0;


   assign ep2_rs1_data = 
			 (ep2_rs1_ptr == 3'd0) ? ep2ep0_mr2 :
			 (ep2_rs1_ptr == 3'd1) ? ep2ep1_mr2 :
			 (ep2_rs1_ptr == 3'd2) ? ep2ep2_mr2 :
			 (ep2_rs1_ptr == 3'd3) ? ep2ep3_mr2 :
			 (ep2_rs1_ptr == 3'd4) ? ep2ep3_mr4 :
			 (ep2_rs1_ptr == 3'd5) ? ep2ep1_mr5 :
			 (ep2_rs1_ptr == 3'd6) ? 32'd0 :
			 32'd0;

   assign ep2_rs2_data = 
			 (ep2_rs2_ptr == 3'd0) ? ep2ep0_mr2 :
			 (ep2_rs2_ptr == 3'd1) ? ep2ep1_mr2 :
			 (ep2_rs2_ptr == 3'd2) ? ep2ep2_mr2 :
			 (ep2_rs2_ptr == 3'd3) ? ep2ep3_mr2 :
			 (ep2_rs2_ptr == 3'd4) ? ep2ep3_mr4 :
			 (ep2_rs2_ptr == 3'd5) ? ep2ep1_mr5 :
			 (ep2_rs2_ptr == 3'd6) ? 32'd0 :
			 32'd0;


   assign ep3_rs1_data = 
			 (ep3_rs1_ptr == 3'd0) ? ep3ep0_mr3 :
			 (ep3_rs1_ptr == 3'd1) ? ep3ep1_mr3 :
			 (ep3_rs1_ptr == 3'd2) ? ep3ep2_mr3 :
			 (ep3_rs1_ptr == 3'd3) ? ep3ep3_mr3 :
			 (ep3_rs1_ptr == 3'd4) ? ep3ep0_mr4 :
			 (ep3_rs1_ptr == 3'd5) ? ep3ep2_mr5 :
			 (ep3_rs1_ptr == 3'd6) ? 32'd0 :
			 32'd0;

   assign ep3_rs2_data = 
			 (ep3_rs2_ptr == 3'd0) ? ep3ep0_mr3 :
			 (ep3_rs2_ptr == 3'd1) ? ep3ep1_mr3 :
			 (ep3_rs2_ptr == 3'd2) ? ep3ep2_mr3 :
			 (ep3_rs2_ptr == 3'd3) ? ep3ep3_mr3 :
			 (ep3_rs2_ptr == 3'd4) ? ep3ep0_mr4 :
			 (ep3_rs2_ptr == 3'd5) ? ep3ep2_mr5 :
			 (ep3_rs2_ptr == 3'd6) ? 32'd0 :
			 32'd0;

   /* Clear full bits for EP0 */
   wire w_ep0_clear_mr0 =
	!ep0_decode_stall & 
	((ep0_rs1_ptr == 3'd0) & ep0_rs1_ptr_valid |
	 (ep0_rs2_ptr == 3'd0) & ep0_rs2_ptr_valid );
   
    wire w_ep0_clear_mr1 =
	!ep0_decode_stall & 
	((ep0_rs1_ptr == 3'd1) & ep0_rs1_ptr_valid |
	 (ep0_rs2_ptr == 3'd1) & ep0_rs2_ptr_valid );

    wire w_ep0_clear_mr2 =
	!ep0_decode_stall & 
	((ep0_rs1_ptr == 3'd2) & ep0_rs1_ptr_valid |
	 (ep0_rs2_ptr == 3'd2) & ep0_rs2_ptr_valid );

    wire w_ep0_clear_mr3 =
	!ep0_decode_stall & 
	((ep0_rs1_ptr == 3'd3) & ep0_rs1_ptr_valid |
	 (ep0_rs2_ptr == 3'd3) & ep0_rs2_ptr_valid );

   wire  w_ep0_clear_mr4 =
	!ep0_decode_stall & 
	((ep0_rs1_ptr == 3'd4) & ep0_rs1_ptr_valid |
	 (ep0_rs2_ptr == 3'd4) & ep0_rs2_ptr_valid );

    wire w_ep0_clear_mr5 =
	!ep0_decode_stall & 
	((ep0_rs1_ptr == 3'd5) & ep0_rs1_ptr_valid |
	 (ep0_rs2_ptr == 3'd5) & ep0_rs2_ptr_valid );


   /* Clear full bits for EP1 */
   wire w_ep1_clear_mr0 =
	!ep1_decode_stall & 
	((ep1_rs1_ptr == 3'd0) & ep1_rs1_ptr_valid |
	 (ep1_rs2_ptr == 3'd0) & ep1_rs2_ptr_valid );
   
    wire w_ep1_clear_mr1 =
	!ep1_decode_stall & 
	((ep1_rs1_ptr == 3'd1) & ep1_rs1_ptr_valid |
	 (ep1_rs2_ptr == 3'd1) & ep1_rs2_ptr_valid );

    wire w_ep1_clear_mr2 =
	!ep1_decode_stall & 
	((ep1_rs1_ptr == 3'd2) & ep1_rs1_ptr_valid |
	 (ep1_rs2_ptr == 3'd2) & ep1_rs2_ptr_valid );

    wire w_ep1_clear_mr3 =
	!ep1_decode_stall & 
	((ep1_rs1_ptr == 3'd3) & ep1_rs1_ptr_valid |
	 (ep1_rs2_ptr == 3'd3) & ep1_rs2_ptr_valid );

   wire  w_ep1_clear_mr4 =
	!ep1_decode_stall & 
	((ep1_rs1_ptr == 3'd4) & ep1_rs1_ptr_valid |
	 (ep1_rs2_ptr == 3'd4) & ep1_rs2_ptr_valid );

    wire w_ep1_clear_mr5 =
	!ep1_decode_stall & 
	((ep1_rs1_ptr == 3'd5) & ep1_rs1_ptr_valid |
	 (ep1_rs2_ptr == 3'd5) & ep1_rs2_ptr_valid );
   
   /* Clear full bits for EP2 */
   wire  w_ep2_clear_mr0 =
	 !ep2_decode_stall & 
	 ((ep2_rs1_ptr == 3'd0) & ep2_rs1_ptr_valid |
	  (ep2_rs2_ptr == 3'd0) & ep2_rs2_ptr_valid );
   
   wire  w_ep2_clear_mr1 =
	 !ep2_decode_stall & 
	 ((ep2_rs1_ptr == 3'd1) & ep2_rs1_ptr_valid |
	  (ep2_rs2_ptr == 3'd1) & ep2_rs2_ptr_valid );
   
   wire  w_ep2_clear_mr2 =
	 !ep2_decode_stall & 
	 ((ep2_rs1_ptr == 3'd2) & ep2_rs1_ptr_valid |
	  (ep2_rs2_ptr == 3'd2) & ep2_rs2_ptr_valid );
   
   wire  w_ep2_clear_mr3 =
	 !ep2_decode_stall & 
	 ((ep2_rs1_ptr == 3'd3) & ep2_rs1_ptr_valid |
	  (ep2_rs2_ptr == 3'd3) & ep2_rs2_ptr_valid );
   
   wire  w_ep2_clear_mr4 =
	 !ep2_decode_stall & 
	 ((ep2_rs1_ptr == 3'd4) & ep2_rs1_ptr_valid |
	  (ep2_rs2_ptr == 3'd4) & ep2_rs2_ptr_valid );
   
   wire  w_ep2_clear_mr5 =
	 !ep2_decode_stall & 
	 ((ep2_rs1_ptr == 3'd5) & ep2_rs1_ptr_valid |
	  (ep2_rs2_ptr == 3'd5) & ep2_rs2_ptr_valid );

   /* Clear full bits for EP3 */
   wire  w_ep3_clear_mr0 =
	 !ep3_decode_stall & 
	 ((ep3_rs1_ptr == 3'd0) & ep3_rs1_ptr_valid |
	  (ep3_rs2_ptr == 3'd0) & ep3_rs2_ptr_valid );
   
   wire  w_ep3_clear_mr1 =
	 !ep3_decode_stall & 
	 ((ep3_rs1_ptr == 3'd1) & ep3_rs1_ptr_valid |
	  (ep3_rs2_ptr == 3'd1) & ep3_rs2_ptr_valid );
   
   wire  w_ep3_clear_mr2 =
	 !ep3_decode_stall & 
	 ((ep3_rs1_ptr == 3'd2) & ep3_rs1_ptr_valid |
	  (ep3_rs2_ptr == 3'd2) & ep3_rs2_ptr_valid );
   
   wire  w_ep3_clear_mr3 =
	 !ep3_decode_stall & 
	 ((ep3_rs1_ptr == 3'd3) & ep3_rs1_ptr_valid |
	  (ep3_rs2_ptr == 3'd3) & ep3_rs2_ptr_valid );
   
   wire  w_ep3_clear_mr4 =
	 !ep3_decode_stall & 
	 ((ep3_rs1_ptr == 3'd4) & ep3_rs1_ptr_valid |
	  (ep3_rs2_ptr == 3'd4) & ep3_rs2_ptr_valid );
   
   wire  w_ep3_clear_mr5 =
	 !ep3_decode_stall & 
	 ((ep3_rs1_ptr == 3'd5) & ep3_rs1_ptr_valid |
	  (ep3_rs2_ptr == 3'd5) & ep3_rs2_ptr_valid );

 
  /* Set full bits for EP0 */
   wire w_ep0_set_mr0 =
	((ep0_alu_rd_ptr == 3'd0) & ep0_alu_rd_ptr_valid |
	 (ep0_xmu_rd_ptr == 3'd0) & ep0_xmu_rd_ptr_valid );

   wire w_ep0_set_mr1 =
	((ep0_alu_rd_ptr == 3'd1) & ep0_alu_rd_ptr_valid |
	 (ep0_xmu_rd_ptr == 3'd1) & ep0_xmu_rd_ptr_valid );

   wire w_ep0_set_mr2 =
	((ep0_alu_rd_ptr == 3'd2) & ep0_alu_rd_ptr_valid |
	 (ep0_xmu_rd_ptr == 3'd2) & ep0_xmu_rd_ptr_valid );

   wire w_ep0_set_mr3 =
	((ep0_alu_rd_ptr == 3'd3) & ep0_alu_rd_ptr_valid |
	 (ep0_xmu_rd_ptr == 3'd3) & ep0_xmu_rd_ptr_valid );

   wire w_ep0_set_mr4 =
	((ep0_alu_rd_ptr == 3'd4) & ep0_alu_rd_ptr_valid |
	 (ep0_xmu_rd_ptr == 3'd4) & ep0_xmu_rd_ptr_valid );

   wire w_ep0_set_mr5 =
	((ep0_alu_rd_ptr == 3'd5) & ep0_alu_rd_ptr_valid |
	 (ep0_xmu_rd_ptr == 3'd5) & ep0_xmu_rd_ptr_valid );

   /* Set full bits for EP1 */
   wire w_ep1_set_mr0 =
	((ep1_alu_rd_ptr == 3'd0) & ep1_alu_rd_ptr_valid |
	 (ep1_xmu_rd_ptr == 3'd0) & ep1_xmu_rd_ptr_valid );

   wire w_ep1_set_mr1 =
	((ep1_alu_rd_ptr == 3'd1) & ep1_alu_rd_ptr_valid |
	 (ep1_xmu_rd_ptr == 3'd1) & ep1_xmu_rd_ptr_valid );

   wire w_ep1_set_mr2 =
	((ep1_alu_rd_ptr == 3'd2) & ep1_alu_rd_ptr_valid |
	 (ep1_xmu_rd_ptr == 3'd2) & ep1_xmu_rd_ptr_valid );

   wire w_ep1_set_mr3 =
	((ep1_alu_rd_ptr == 3'd3) & ep1_alu_rd_ptr_valid |
	 (ep1_xmu_rd_ptr == 3'd3) & ep1_xmu_rd_ptr_valid );

   wire w_ep1_set_mr4 =
	((ep1_alu_rd_ptr == 3'd4) & ep1_alu_rd_ptr_valid |
	 (ep1_xmu_rd_ptr == 3'd4) & ep1_xmu_rd_ptr_valid );

   wire w_ep1_set_mr5 =
	((ep1_alu_rd_ptr == 3'd5) & ep1_alu_rd_ptr_valid |
	 (ep1_xmu_rd_ptr == 3'd5) & ep1_xmu_rd_ptr_valid );

   /* Set full bits for EP2 */
   wire w_ep2_set_mr0 =
	((ep2_alu_rd_ptr == 3'd0) & ep2_alu_rd_ptr_valid |
	 (ep2_xmu_rd_ptr == 3'd0) & ep2_xmu_rd_ptr_valid );

   wire w_ep2_set_mr1 =
	((ep2_alu_rd_ptr == 3'd1) & ep2_alu_rd_ptr_valid |
	 (ep2_xmu_rd_ptr == 3'd1) & ep2_xmu_rd_ptr_valid );

   wire w_ep2_set_mr2 =
	((ep2_alu_rd_ptr == 3'd2) & ep2_alu_rd_ptr_valid |
	 (ep2_xmu_rd_ptr == 3'd2) & ep2_xmu_rd_ptr_valid );

   wire w_ep2_set_mr3 =
	((ep2_alu_rd_ptr == 3'd3) & ep2_alu_rd_ptr_valid |
	 (ep2_xmu_rd_ptr == 3'd3) & ep2_xmu_rd_ptr_valid );

   wire w_ep2_set_mr4 =
	((ep2_alu_rd_ptr == 3'd4) & ep2_alu_rd_ptr_valid |
	 (ep2_xmu_rd_ptr == 3'd4) & ep2_xmu_rd_ptr_valid );

   wire w_ep2_set_mr5 =
	((ep2_alu_rd_ptr == 3'd5) & ep2_alu_rd_ptr_valid |
	 (ep2_xmu_rd_ptr == 3'd5) & ep2_xmu_rd_ptr_valid );

   /* Set full bits for EP3*/
   wire w_ep3_set_mr0 =
	((ep3_alu_rd_ptr == 3'd0) & ep3_alu_rd_ptr_valid |
	 (ep3_xmu_rd_ptr == 3'd0) & ep3_xmu_rd_ptr_valid );

   wire w_ep3_set_mr1 =
	((ep3_alu_rd_ptr == 3'd1) & ep3_alu_rd_ptr_valid |
	 (ep3_xmu_rd_ptr == 3'd1) & ep3_xmu_rd_ptr_valid );

   wire w_ep3_set_mr2 =
	((ep3_alu_rd_ptr == 3'd2) & ep3_alu_rd_ptr_valid |
	 (ep3_xmu_rd_ptr == 3'd2) & ep3_xmu_rd_ptr_valid );

   wire w_ep3_set_mr3 =
	((ep3_alu_rd_ptr == 3'd3) & ep3_alu_rd_ptr_valid |
	 (ep3_xmu_rd_ptr == 3'd3) & ep3_xmu_rd_ptr_valid );

   wire w_ep3_set_mr4 =
	((ep3_alu_rd_ptr == 3'd4) & ep3_alu_rd_ptr_valid |
	 (ep3_xmu_rd_ptr == 3'd4) & ep3_xmu_rd_ptr_valid );

   wire w_ep3_set_mr5 =
	((ep3_alu_rd_ptr == 3'd5) & ep3_alu_rd_ptr_valid |
	 (ep3_xmu_rd_ptr == 3'd5) & ep3_xmu_rd_ptr_valid );

   /* MR0 present bits */
   wire w_ep0ep0_mr0_full = 
	w_ep0_set_mr0 ? 1'b1 :
	w_ep0_clear_mr0 ? 1'b0 :
	ep0ep0_mr0_full;

   wire w_ep0ep1_mr0_full =
	w_ep1_set_mr0 ? 1'b1 :
	w_ep0_clear_mr1 ? 1'b0 :
	ep0ep1_mr0_full;

   wire w_ep0ep2_mr0_full = 
	w_ep2_set_mr0 ? 1'b1 :
	w_ep0_clear_mr2 ? 1'b0 :
	ep0ep2_mr0_full;

   wire w_ep0ep3_mr0_full =
	w_ep3_set_mr0 ? 1'b1 :
	w_ep0_clear_mr3 ? 1'b0 :
	ep0ep3_mr0_full;


   /* MR1 present bits */
   wire w_ep1ep0_mr1_full = 
	w_ep0_set_mr1 ? 1'b1 :
	w_ep1_clear_mr0 ? 1'b0 :
	ep1ep0_mr1_full;

   wire w_ep1ep1_mr1_full =
	w_ep1_set_mr1 ? 1'b1 :
	w_ep1_clear_mr1 ? 1'b0 :
	ep1ep1_mr1_full;

   wire w_ep1ep2_mr1_full = 
	w_ep2_set_mr1 ? 1'b1 :
	w_ep1_clear_mr2 ? 1'b0 :
	ep1ep2_mr1_full;

   wire w_ep1ep3_mr1_full =
	w_ep3_set_mr1 ? 1'b1 :
	w_ep1_clear_mr3 ? 1'b0 :
	ep1ep3_mr1_full;

   /* MR2 present bits */
   wire w_ep2ep0_mr2_full = 
	w_ep0_set_mr2 ? 1'b1 :
	w_ep2_clear_mr0 ? 1'b0 :
	ep2ep0_mr2_full;

   wire w_ep2ep1_mr2_full =
	w_ep1_set_mr2 ? 1'b1 :
	w_ep2_clear_mr1 ? 1'b0 :
	ep2ep1_mr2_full;
   
   wire w_ep2ep2_mr2_full = 
	w_ep2_set_mr2 ? 1'b1 :
	w_ep2_clear_mr2 ? 1'b0 :
	ep2ep2_mr2_full;
   
   wire w_ep2ep3_mr2_full =
	w_ep3_set_mr2 ? 1'b1 :
	w_ep2_clear_mr3 ? 1'b0 :
	ep2ep3_mr2_full;
  
   /* MR3 present bits */
   wire w_ep3ep0_mr3_full = 
	w_ep0_set_mr3 ? 1'b1 :
	w_ep3_clear_mr0 ? 1'b0 :
	ep3ep0_mr3_full;

   wire w_ep3ep1_mr3_full =
	w_ep1_set_mr3 ? 1'b1 :
	w_ep3_clear_mr1 ? 1'b0 :
	ep3ep1_mr3_full;
   
   wire w_ep3ep2_mr3_full = 
	w_ep2_set_mr3 ? 1'b1 :
	w_ep3_clear_mr2 ? 1'b0 :
	ep3ep2_mr3_full;
   
   wire w_ep3ep3_mr3_full =
	w_ep3_set_mr3 ? 1'b1 :
	w_ep3_clear_mr3 ? 1'b0 :
	ep3ep3_mr3_full;

   //03210
   /* MR4 present bits */
   wire w_ep3ep0_mr4_full = 
	w_ep0_set_mr4 ? 1'b1 :
	w_ep3_clear_mr4 ? 1'b0 :
	ep3ep0_mr4_full;
   
   wire w_ep0ep1_mr4_full =
	w_ep1_set_mr4 ? 1'b1 :
	w_ep0_clear_mr4 ? 1'b0 :
	ep0ep1_mr4_full;
   
   wire w_ep1ep2_mr4_full = 
	w_ep2_set_mr4 ? 1'b1 :
	w_ep1_clear_mr4 ? 1'b0 :
	ep1ep2_mr4_full;
   
   wire w_ep2ep3_mr4_full =
	w_ep3_set_mr4 ? 1'b1 :
	w_ep2_clear_mr4 ? 1'b0 :
	ep2ep3_mr4_full;
   
   /* MR5 present bits */
   wire w_ep1ep0_mr5_full = 
	w_ep0_set_mr5 ? 1'b1 :
	w_ep1_clear_mr5 ? 1'b0 :
	ep1ep0_mr5_full;
   
   wire w_ep2ep1_mr5_full =
	w_ep1_set_mr5 ? 1'b1 :
	w_ep2_clear_mr5 ? 1'b0 :
	ep2ep1_mr5_full;
   
   wire w_ep3ep2_mr5_full = 
	w_ep2_set_mr5 ? 1'b1 :
	w_ep3_clear_mr5 ? 1'b0 :
	ep3ep2_mr5_full;
   
   wire w_ep0ep3_mr5_full =
	w_ep3_set_mr5 ? 1'b1 :
	w_ep0_clear_mr5 ? 1'b0 :
	ep0ep3_mr5_full;
   
   
   /* MR0 next value logic */
   wire [31:0] w_ep0ep0_mr0 =
	       (ep0_alu_rd_ptr == 3'd0) & ep0_alu_rd_ptr_valid ?
	       ep0_alu_rd_data :
	       (ep0_xmu_rd_ptr == 3'd0) & ep0_xmu_rd_ptr_valid ?
	       ep0_xmu_rd_data :
	       ep0ep0_mr0;
   
   wire [31:0] w_ep0ep1_mr0 =
	       (ep1_alu_rd_ptr == 3'd0) & ep1_alu_rd_ptr_valid ?
	       ep1_alu_rd_data :
	       (ep1_xmu_rd_ptr == 3'd0) & ep1_xmu_rd_ptr_valid ?
	       ep1_xmu_rd_data :
	       ep0ep1_mr0;

   wire [31:0] w_ep0ep2_mr0 =
	       (ep2_alu_rd_ptr == 3'd0) & ep2_alu_rd_ptr_valid ?
	       ep2_alu_rd_data :
	       (ep2_xmu_rd_ptr == 3'd0) & ep2_xmu_rd_ptr_valid ?
	       ep2_xmu_rd_data :
	       ep0ep2_mr0;

   wire [31:0] w_ep0ep3_mr0 =
	       (ep3_alu_rd_ptr == 3'd0) & ep3_alu_rd_ptr_valid ?
	       ep3_alu_rd_data :
	       (ep3_xmu_rd_ptr == 3'd0) & ep3_xmu_rd_ptr_valid ?
	       ep3_xmu_rd_data :
	       ep0ep3_mr0;
   

   /* MR1 next value logic */
   wire [31:0] w_ep1ep0_mr1 =
	       (ep0_alu_rd_ptr == 3'd1) & ep0_alu_rd_ptr_valid ?
	       ep0_alu_rd_data :
	       (ep0_xmu_rd_ptr == 3'd1) & ep0_xmu_rd_ptr_valid ?
	       ep0_xmu_rd_data :
	       ep1ep0_mr1;
   
   wire [31:0] w_ep1ep1_mr1 =
	       (ep1_alu_rd_ptr == 3'd1) & ep1_alu_rd_ptr_valid ?
	       ep1_alu_rd_data :
	       (ep1_xmu_rd_ptr == 3'd1) & ep1_xmu_rd_ptr_valid ?
	       ep1_xmu_rd_data :
	       ep1ep1_mr1;

   wire [31:0] w_ep1ep2_mr1 =
	       (ep2_alu_rd_ptr == 3'd1) & ep2_alu_rd_ptr_valid ?
	       ep2_alu_rd_data :
	       (ep2_xmu_rd_ptr == 3'd1) & ep2_xmu_rd_ptr_valid ?
	       ep2_xmu_rd_data :
	       ep1ep2_mr1;

   wire [31:0] w_ep1ep3_mr1 =
	       (ep3_alu_rd_ptr == 3'd1) & ep3_alu_rd_ptr_valid ?
	       ep3_alu_rd_data :
	       (ep3_xmu_rd_ptr == 3'd1) & ep3_xmu_rd_ptr_valid ?
	       ep3_xmu_rd_data :
	       ep1ep3_mr1;

   /* MR2 next value logic */
   wire [31:0] w_ep2ep0_mr2 =
	       (ep0_alu_rd_ptr == 3'd2) & ep0_alu_rd_ptr_valid ?
	       ep0_alu_rd_data :
	       (ep0_xmu_rd_ptr == 3'd2) & ep0_xmu_rd_ptr_valid ?
	       ep0_xmu_rd_data :
	       ep2ep0_mr2;
   
   wire [31:0] w_ep2ep1_mr2 =
	       (ep1_alu_rd_ptr == 3'd2) & ep1_alu_rd_ptr_valid ?
	       ep1_alu_rd_data :
	       (ep1_xmu_rd_ptr == 3'd2) & ep1_xmu_rd_ptr_valid ?
	       ep1_xmu_rd_data :
	       ep2ep1_mr2;

   wire [31:0] w_ep2ep2_mr2 =
	       (ep2_alu_rd_ptr == 3'd2) & ep2_alu_rd_ptr_valid ?
	       ep2_alu_rd_data :
	       (ep2_xmu_rd_ptr == 3'd2) & ep2_xmu_rd_ptr_valid ?
	       ep2_xmu_rd_data :
	       ep2ep2_mr2;

   wire [31:0] w_ep2ep3_mr2 =
	       (ep3_alu_rd_ptr == 3'd2) & ep3_alu_rd_ptr_valid ?
	       ep3_alu_rd_data :
	       (ep3_xmu_rd_ptr == 3'd2) & ep3_xmu_rd_ptr_valid ?
	       ep3_xmu_rd_data :
	       ep2ep3_mr2;
   
   /* MR3 next value logic */
   wire [31:0] w_ep3ep0_mr3 =
	       (ep0_alu_rd_ptr == 3'd3) & ep0_alu_rd_ptr_valid ?
	       ep0_alu_rd_data :
	       (ep0_xmu_rd_ptr == 3'd3) & ep0_xmu_rd_ptr_valid ?
	       ep0_xmu_rd_data :
	       ep3ep0_mr3;
   
   wire [31:0] w_ep3ep1_mr3 =
	       (ep1_alu_rd_ptr == 3'd3) & ep1_alu_rd_ptr_valid ?
	       ep1_alu_rd_data :
	       (ep1_xmu_rd_ptr == 3'd3) & ep1_xmu_rd_ptr_valid ?
	       ep1_xmu_rd_data :
	       ep3ep1_mr3;

   wire [31:0] w_ep3ep2_mr3 =
	       (ep2_alu_rd_ptr == 3'd3) & ep2_alu_rd_ptr_valid ?
	       ep2_alu_rd_data :
	       (ep2_xmu_rd_ptr == 3'd3) & ep2_xmu_rd_ptr_valid ?
	       ep2_xmu_rd_data :
	       ep3ep2_mr3;

   wire [31:0] w_ep3ep3_mr3 =
	       (ep3_alu_rd_ptr == 3'd3) & ep3_alu_rd_ptr_valid ?
	       ep3_alu_rd_data :
	       (ep3_xmu_rd_ptr == 3'd3) & ep3_xmu_rd_ptr_valid ?
	       ep3_xmu_rd_data :
	       ep3ep3_mr3;

   /* MR4 next value logic */
   wire [31:0] w_ep3ep0_mr4 =
	       (ep0_alu_rd_ptr == 3'd4) & ep0_alu_rd_ptr_valid ?
	       ep0_alu_rd_data :
	       (ep0_xmu_rd_ptr == 3'd4) & ep0_xmu_rd_ptr_valid ?
	       ep0_xmu_rd_data :
	       ep3ep0_mr4;
   
   wire [31:0] w_ep0ep1_mr4 =
	       (ep1_alu_rd_ptr == 3'd4) & ep1_alu_rd_ptr_valid ?
	       ep1_alu_rd_data :
	       (ep1_xmu_rd_ptr == 3'd4) & ep1_xmu_rd_ptr_valid ?
	       ep1_xmu_rd_data :
	       ep0ep1_mr4;

   wire [31:0] w_ep1ep2_mr4 =
	       (ep2_alu_rd_ptr == 3'd4) & ep2_alu_rd_ptr_valid ?
	       ep2_alu_rd_data :
	       (ep2_xmu_rd_ptr == 3'd4) & ep2_xmu_rd_ptr_valid ?
	       ep2_xmu_rd_data :
	       ep1ep2_mr4;

   wire [31:0] w_ep2ep3_mr4 =
	       (ep3_alu_rd_ptr == 3'd4) & ep3_alu_rd_ptr_valid ?
	       ep3_alu_rd_data :
	       (ep3_xmu_rd_ptr == 3'd4) & ep3_xmu_rd_ptr_valid ?
	       ep3_xmu_rd_data :
	       ep2ep3_mr4;

   /* MR5 next value logic */
   wire [31:0] w_ep1ep0_mr5 =
	       (ep0_alu_rd_ptr == 3'd5) & ep0_alu_rd_ptr_valid ?
	       ep0_alu_rd_data :
	       (ep0_xmu_rd_ptr == 3'd5) & ep0_xmu_rd_ptr_valid ?
	       ep0_xmu_rd_data :
	       ep1ep0_mr5;
   
   wire [31:0] w_ep2ep1_mr5 =
	       (ep1_alu_rd_ptr == 3'd5) & ep1_alu_rd_ptr_valid ?
	       ep1_alu_rd_data :
	       (ep1_xmu_rd_ptr == 3'd5) & ep1_xmu_rd_ptr_valid ?
	       ep1_xmu_rd_data :
	       ep2ep1_mr5;

   wire [31:0] w_ep3ep2_mr5 =
	       (ep2_alu_rd_ptr == 3'd5) & ep2_alu_rd_ptr_valid ?
	       ep2_alu_rd_data :
	       (ep2_xmu_rd_ptr == 3'd5) & ep2_xmu_rd_ptr_valid ?
	       ep2_xmu_rd_data :
	       ep3ep2_mr5;

   wire [31:0] w_ep0ep3_mr5 =
	       (ep3_alu_rd_ptr == 3'd5) & ep3_alu_rd_ptr_valid ?
	       ep3_alu_rd_data :
	       (ep3_xmu_rd_ptr == 3'd5) & ep3_xmu_rd_ptr_valid ?
	       ep3_xmu_rd_data :
	       ep0ep3_mr5;

   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     /* MR0 */
	     ep0ep0_mr0 <= 32'd0;
	     ep0ep1_mr0 <= 32'd0;
	     ep0ep2_mr0 <= 32'd0;
	     ep0ep3_mr0 <= 32'd0;
	     ep0ep0_mr0_full <= 1'b0;
	     ep0ep1_mr0_full <= 1'b0;
	     ep0ep2_mr0_full <= 1'b0;
	     ep0ep3_mr0_full <= 1'b0;

	     /* MR1 */
	     ep1ep0_mr1 <= 32'd0;
	     ep1ep1_mr1 <= 32'd0;
	     ep1ep2_mr1 <= 32'd0;
	     ep1ep3_mr1 <= 32'd0;
	     ep1ep0_mr1_full <= 1'b0;
	     ep1ep1_mr1_full <= 1'b0;
	     ep1ep2_mr1_full <= 1'b0;
	     ep1ep3_mr1_full <= 1'b0;

	     /* MR2 */
	     ep2ep0_mr2 <= 32'd0;
	     ep2ep1_mr2 <= 32'd0;
	     ep2ep2_mr2 <= 32'd0;
	     ep2ep3_mr2 <= 32'd0;
	     ep2ep0_mr2_full <= 1'b0;
	     ep2ep1_mr2_full <= 1'b0;
	     ep2ep2_mr2_full <= 1'b0;
	     ep2ep3_mr2_full <= 1'b0;   

	     /* MR3 */
	     ep3ep0_mr3 <= 32'd0;
	     ep3ep1_mr3 <= 32'd0;
	     ep3ep2_mr3 <= 32'd0;
	     ep3ep3_mr3 <= 32'd0;
	     ep3ep0_mr3_full <= 1'b0;
	     ep3ep1_mr3_full <= 1'b0;
	     ep3ep2_mr3_full <= 1'b0;
	     ep3ep3_mr3_full <= 1'b0;

	     /* MR4 */
	     ep0ep1_mr4 <= 32'd0;
	     ep1ep2_mr4 <= 32'd0;
	     ep2ep3_mr4 <= 32'd0;
	     ep3ep0_mr4 <= 32'd0;
	     ep0ep1_mr4_full <= 1'b0;
	     ep1ep2_mr4_full <= 1'b0;
	     ep2ep3_mr4_full <= 1'b0;
	     ep3ep0_mr4_full <= 1'b0;

	     /* MR5 */
	     ep1ep0_mr5 <= 32'd0;
	     ep2ep1_mr5 <= 32'd0;
	     ep3ep2_mr5 <= 32'd0;
	     ep0ep3_mr5 <= 32'd0;
	     ep1ep0_mr5_full <= 1'b0;
	     ep2ep1_mr5_full <= 1'b0;
	     ep3ep2_mr5_full <= 1'b0;
	     ep0ep3_mr5_full <= 1'b0;
	  end
	else
	  begin
	     /* MR0 */
	     ep0ep0_mr0 <= w_ep0ep0_mr0;
	     ep0ep1_mr0 <= w_ep0ep1_mr0;
	     ep0ep2_mr0 <= w_ep0ep2_mr0;
	     ep0ep3_mr0 <= w_ep0ep3_mr0;
	     ep0ep0_mr0_full <= w_ep0ep0_mr0_full;
	     ep0ep1_mr0_full <= w_ep0ep1_mr0_full;
	     ep0ep2_mr0_full <= w_ep0ep2_mr0_full;
	     ep0ep3_mr0_full <= w_ep0ep3_mr0_full;
	     	     

	     /* MR1 */
	     ep1ep0_mr1 <= w_ep1ep0_mr1;
	     ep1ep1_mr1 <= w_ep1ep1_mr1;
	     ep1ep2_mr1 <= w_ep1ep2_mr1;
	     ep1ep3_mr1 <= w_ep1ep3_mr1;
	     ep1ep0_mr1_full <= w_ep1ep0_mr1_full;
	     ep1ep1_mr1_full <= w_ep1ep1_mr1_full;
	     ep1ep2_mr1_full <= w_ep1ep2_mr1_full;
	     ep1ep3_mr1_full <= w_ep1ep3_mr1_full;
	     	     
	     /* MR2 */
	     ep2ep0_mr2 <= w_ep2ep0_mr2;
	     ep2ep1_mr2 <= w_ep2ep1_mr2;
	     ep2ep2_mr2 <= w_ep2ep2_mr2;
	     ep2ep3_mr2 <= w_ep2ep3_mr2;
	     ep2ep0_mr2_full <= w_ep2ep0_mr2_full;
	     ep2ep1_mr2_full <= w_ep2ep1_mr2_full;
	     ep2ep2_mr2_full <= w_ep2ep2_mr2_full;
	     ep2ep3_mr2_full <= w_ep2ep3_mr2_full;
	     	     
	     /* MR3 */
	     ep3ep0_mr3 <= w_ep3ep0_mr3;
	     ep3ep1_mr3 <= w_ep3ep1_mr3;
	     ep3ep2_mr3 <= w_ep3ep2_mr3;
	     ep3ep3_mr3 <= w_ep3ep3_mr3;
	     ep3ep0_mr3_full <= w_ep3ep0_mr3_full;
	     ep3ep1_mr3_full <= w_ep3ep1_mr3_full;
	     ep3ep2_mr3_full <= w_ep3ep2_mr3_full;
	     ep3ep3_mr3_full <= w_ep3ep3_mr3_full;
	     
	     
	     /* MR4 */
	     ep3ep0_mr4 <= w_ep3ep0_mr4;
	     ep0ep1_mr4 <= w_ep0ep1_mr4;
	     ep1ep2_mr4 <= w_ep1ep2_mr4;
	     ep2ep3_mr4 <= w_ep2ep3_mr4;
	     ep3ep0_mr4_full <= w_ep3ep0_mr4_full;
	     ep0ep1_mr4_full <= w_ep0ep1_mr4_full;
	     ep1ep2_mr4_full <= w_ep1ep2_mr4_full;
	     ep2ep3_mr4_full <= w_ep2ep3_mr4_full;  

	     /* MR5 */
	     ep1ep0_mr5 <= w_ep1ep0_mr5;
	     ep2ep1_mr5 <= w_ep2ep1_mr5;
	     ep3ep2_mr5 <= w_ep3ep2_mr5;
	     ep0ep3_mr5 <= w_ep0ep3_mr5;
	     ep1ep0_mr5_full <= w_ep1ep0_mr5_full;
	     ep2ep1_mr5_full <= w_ep2ep1_mr5_full;
	     ep3ep2_mr5_full <= w_ep3ep2_mr5_full;
	     ep0ep3_mr5_full <= w_ep0ep3_mr5_full;	     	    
	     
	  end // else: !if(rst)
     end // always@ (posedge clk)
   
   
endmodule // message_block

