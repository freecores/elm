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


`include "elm_defs.v"
`define FULL_SYSTEM 1
module pb_elm_wrapper(/*AUTOARG*/
   // Outputs
   pb_data_out,
   // Inputs
   clk, rst, pb_addr, pb_wr, pb_rd, pb_data_in
   );
   input clk;
   input rst;
   input [15:0] pb_addr;
   
   input 	pb_wr;
   input 	pb_rd;

   input [31:0] pb_data_in;
   output [31:0] pb_data_out;

   wire [7:0] 	 ens_addr;
   wire 	 ens_b0_csn;
   wire 	 ens_b1_csn;
   wire 	 ens_b2_csn;
   wire 	 ens_b3_csn;
   
   wire 	 ocm_csn;

   wire 	 ens_b4_csn;
   wire 	 ens_b5_csn;
   wire 	 ens_b6_csn;
   wire 	 ens_b7_csn;
   
   
   
   wire [63:0] 	 mask;
   wire [63:0] 	 ens_data_in;

   wire 	 wen = ~pb_wr;
    

   wire 	 ep0_hcf;
   wire 	 ep1_hcf;
   wire 	 ep2_hcf;
   wire 	 ep3_hcf;

   wire 	 ep4_hcf;
   wire 	 ep5_hcf;
   wire 	 ep6_hcf;
   wire 	 ep7_hcf;

   

   wire [7:0] 	 hcf;


   wire [11:0] 	 ocm_addr;
   assign ens_addr = ocm_addr[7:0];
   

   
   assign hcf = {ep7_hcf, ep6_hcf, ep5_hcf, ep4_hcf,
		 ep3_hcf, ep2_hcf, ep1_hcf, ep0_hcf};
   
   ensemble_addr_decoder ens_decoder 
     (
      // Outputs
      .ocm_addr		(ocm_addr),
      .ens_b0_csn	(ens_b0_csn),
      .ens_b1_csn	(ens_b1_csn),
      .ens_b2_csn	(ens_b2_csn),
      .ens_b3_csn	(ens_b3_csn),
      .ocm_csn          (ocm_csn),
      .ens_b4_csn	(ens_b4_csn),
      .ens_b5_csn	(ens_b5_csn),
      .ens_b6_csn	(ens_b6_csn),
      .ens_b7_csn	(ens_b7_csn),
      .mask		(mask),
      .ens_data_in	(ens_data_in),
      // Inputs
      .pb_addr		(pb_addr),
      .pb_data_in	(pb_data_in),
      .pb_wr            (pb_wr),
      .pb_rd            (pb_rd)
      );
  

   wire [63:0] 	 test_b0_read_data;
   wire [63:0] 	 test_b1_read_data;
   wire [63:0] 	 test_b2_read_data; 
   wire [63:0] 	 test_b3_read_data; 
   wire [63:0] 	 test_ocm_read_data;

   wire [63:0] 	 test_b4_read_data;
   wire [63:0] 	 test_b5_read_data;
   wire [63:0] 	 test_b6_read_data; 
   wire [63:0] 	 test_b7_read_data; 
   

   wire [31:0] b0_read = pb_addr[0] ? 
	       test_b0_read_data[63:32] :
	       test_b0_read_data[31:0];

   wire [31:0] b1_read = pb_addr[0] ?
	       test_b1_read_data[63:32] :
	       test_b1_read_data[31:0];

   wire [31:0] b2_read = pb_addr[0] ?
	       test_b2_read_data[63:32] :
	       test_b2_read_data[31:0];

   wire [31:0] b3_read = pb_addr[0] ?
	       test_b3_read_data[63:32] :
	       test_b3_read_data[31:0];
   
   wire [31:0] ocm_read = pb_addr[0] ?
	       test_ocm_read_data[63:32] :
	       test_ocm_read_data[31:0];



   wire [31:0] b4_read = pb_addr[0] ? 
	       test_b4_read_data[63:32] :
	       test_b4_read_data[31:0];

   wire [31:0] b5_read = pb_addr[0] ?
	       test_b5_read_data[63:32] :
	       test_b5_read_data[31:0];

   wire [31:0] b6_read = pb_addr[0] ?
	       test_b6_read_data[63:32] :
	       test_b6_read_data[31:0];

   wire [31:0] b7_read = pb_addr[0] ?
	       test_b7_read_data[63:32] :
	       test_b7_read_data[31:0];
   

   reg 	       r_test_mode;
   reg 	       r_ep0_stall;
   reg 	       r_ep1_stall;
   reg 	       r_ep2_stall;
   reg 	       r_ep3_stall;
   reg 	       r_mem_rst;
   reg 	       r_ep_rst;

   reg 	       r_cnt_enable;
   reg [7:0]   r_bulk_start;
     
   reg 	       r_done;
   
      
   reg [31:0]  r_data;

   reg [31:0]  r_count0;
   reg [31:0]  r_count1;
   reg [31:0]  r_count2;
   reg [31:0]  r_count3;

   reg 	       r_ep4_stall;
   reg 	       r_ep5_stall;
   reg 	       r_ep6_stall;
   reg 	       r_ep7_stall;
   
   reg [31:0]  r_count4;
   reg [31:0]  r_count5;
   reg [31:0]  r_count6;
   reg [31:0]  r_count7;

   reg [31:0]  r_ep0_boot_vector;
   reg [31:0]  r_ep1_boot_vector;
   reg [31:0]  r_ep2_boot_vector;
   reg [31:0]  r_ep3_boot_vector;
   reg [31:0]  r_ep4_boot_vector;
   reg [31:0]  r_ep5_boot_vector;
   reg [31:0]  r_ep6_boot_vector;
   reg [31:0]  r_ep7_boot_vector;


   
      
   wire w_mem_rst = ((pb_addr == 16'h8000) & pb_wr) ?
	pb_data_in[0] : r_mem_rst;

   wire w_ep_rst = ((pb_addr == 16'h8001) & pb_wr) ?
	pb_data_in[0] : r_ep_rst;

   wire w_ep0_stall = ((pb_addr == 16'h8002) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[0] : 
	r_ep0_stall;

   wire w_ep1_stall = ((pb_addr == 16'h8003) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[1] : 
	r_ep1_stall;
   
   wire w_ep2_stall = ((pb_addr == 16'h8004) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[2] : 
	r_ep2_stall;

   wire w_ep3_stall = ((pb_addr == 16'h8005) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[3] : 
	r_ep3_stall;

      
   wire w_test_mode = ((pb_addr == 16'h8006) & pb_wr) ? 
	pb_data_in[0] : r_test_mode;


   //2nd ensemble signals
   wire w_ep4_stall = ((pb_addr == 16'h800c) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[4] : 
	r_ep4_stall;

   wire w_ep5_stall = ((pb_addr == 16'h800d) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[5] : 
	r_ep5_stall;
   
   wire w_ep6_stall = ((pb_addr == 16'h800e) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[6] : 
	r_ep6_stall;

   wire w_ep7_stall = ((pb_addr == 16'h800f) & pb_wr) ? pb_data_in[0] : 
	((pb_addr == 16'h801d) & pb_wr) ? ~pb_data_in[7] : 
	r_ep7_stall;

   //boot vector registers
   wire [31:0] w_ep0_bv = ((pb_addr == 16'h8014) & pb_wr) ? 
	       pb_data_in : r_ep0_boot_vector;
   
   wire [31:0] w_ep1_bv = ((pb_addr == 16'h8015) & pb_wr) ? 
	       pb_data_in : r_ep1_boot_vector;
   
   wire [31:0] w_ep2_bv = ((pb_addr == 16'h8016) & pb_wr) ?
	       pb_data_in : r_ep2_boot_vector;
   
   wire [31:0] w_ep3_bv = ((pb_addr == 16'h8017) & pb_wr) ? 
	       pb_data_in : r_ep3_boot_vector;
   
   wire [31:0] w_ep4_bv = ((pb_addr == 16'h8018) & pb_wr) ? 
	       pb_data_in : r_ep4_boot_vector;
   
   wire [31:0] w_ep5_bv = ((pb_addr == 16'h8019) & pb_wr) ? 
	       pb_data_in : r_ep5_boot_vector;
   
   wire [31:0] w_ep6_bv = ((pb_addr == 16'h801a) & pb_wr) ? 
	       pb_data_in : r_ep6_boot_vector;
 
   wire [31:0] w_ep7_bv = ((pb_addr == 16'h801b) & pb_wr) ? 
	       pb_data_in : r_ep7_boot_vector;

   wire w_cnt_enable = ((pb_addr == 16'h801c) & pb_wr) ?
	      pb_data_in[0] : r_cnt_enable;
    
   wire [7:0] w_bulk_start  = ((pb_addr == 16'h801d) & pb_wr) ?
	      pb_data_in[7:0] : r_bulk_start;


   wire w_done = ((pb_addr == 16'h801d) & pb_wr) ?
	1'b0 : (r_bulk_start == hcf);
   
   
   wire [31:0] w_data =
	       (pb_addr == 16'h8000) & pb_rd ? {31'd0, r_mem_rst} :
	       (pb_addr == 16'h8001) & pb_rd ? {31'd0, r_ep_rst} :
	       (pb_addr == 16'h8002) & pb_rd ? {31'd0, r_ep0_stall} :
	       (pb_addr == 16'h8003) & pb_rd ? {31'd0, r_ep1_stall} :
	       (pb_addr == 16'h8004) & pb_rd ? {31'd0, r_ep2_stall} :
	       (pb_addr == 16'h8005) & pb_rd ? {31'd0, r_ep3_stall} :
	       (pb_addr == 16'h8006) & pb_rd ? {31'd0, r_test_mode} :
	       (pb_addr == 16'h8007) & pb_rd ? {24'd0, hcf} :
               (pb_addr == 16'h8008) & pb_rd ? 	r_count0 :
	       (pb_addr == 16'h8009) & pb_rd ?  r_count1 :
	       (pb_addr == 16'h800a) & pb_rd ?  r_count2 :
	       (pb_addr == 16'h800b) & pb_rd ?  r_count3 :
               (pb_addr == 16'h800c) & pb_rd ? 	{31'd0, r_ep4_stall} :
	       (pb_addr == 16'h800d) & pb_rd ?  {31'd0, r_ep5_stall} :
	       (pb_addr == 16'h800e) & pb_rd ?  {31'd0, r_ep6_stall} :
	       (pb_addr == 16'h800f) & pb_rd ?  {31'd0, r_ep7_stall} :
	       (pb_addr == 16'h8010) & pb_rd ? 	r_count4 :
	       (pb_addr == 16'h8011) & pb_rd ?  r_count5 :
	       (pb_addr == 16'h8012) & pb_rd ?  r_count6 :
	       (pb_addr == 16'h8013) & pb_rd ?  r_count7 :
	       (pb_addr == 16'h8014) & pb_rd ? r_ep0_boot_vector :
	       (pb_addr == 16'h8015) & pb_rd ? r_ep1_boot_vector :
	       (pb_addr == 16'h8016) & pb_rd ? r_ep2_boot_vector :
	       (pb_addr == 16'h8017) & pb_rd ? r_ep3_boot_vector :
	       (pb_addr == 16'h8018) & pb_rd ? r_ep4_boot_vector :
	       (pb_addr == 16'h8019) & pb_rd ? r_ep5_boot_vector :
	       (pb_addr == 16'h801a) & pb_rd ? r_ep6_boot_vector :
	       (pb_addr == 16'h801b) & pb_rd ? r_ep7_boot_vector :
	       (pb_addr == 16'h801c) & pb_rd ? {31'd0, r_cnt_enable}:
	       (pb_addr == 16'h801d) & pb_rd ? {24'd0, r_bulk_start} :
	       (pb_addr == 16'h801e) & pb_rd ? {31'd0, r_done} :						       
	       32'd0;
	   
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_data <= 32'd0;
	  end
	else
	  begin
	     r_data <= w_data;
	  end
     end // always@ (posedge clk)
   

   assign pb_data_out =
		       ~ens_b0_csn ? b0_read :
		       ~ens_b1_csn ? b1_read :
		       ~ens_b2_csn ? b2_read :
		       ~ens_b3_csn ? b3_read :
		       ~ocm_csn ? ocm_read :
		       ~ens_b4_csn ? b4_read :
		       ~ens_b5_csn ? b5_read :
		       ~ens_b6_csn ? b6_read :
		       ~ens_b7_csn ? b7_read :	     
		       r_data;
   
   
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_test_mode <= 1'b1;
	     r_ep0_stall <= 1'b1;
	     r_ep1_stall <= 1'b1;
	     r_ep2_stall <= 1'b1;
	     r_ep3_stall <= 1'b1;

	     r_ep4_stall <= 1'b1;
	     r_ep5_stall <= 1'b1;
	     r_ep6_stall <= 1'b1;
	     r_ep7_stall <= 1'b1;

	     r_cnt_enable <= 1'b0;
	     r_mem_rst <= 1'b1;
	     
	     r_ep_rst <= 1'b1;
	     r_bulk_start <= 8'd0;

	     r_done <= 1'b0;
	     
	  end
	else
	  begin
	     r_test_mode <= w_test_mode;
	     r_ep0_stall <= w_ep0_stall;
	     r_ep1_stall <= w_ep1_stall;
	     r_ep2_stall <= w_ep2_stall;
	     r_ep3_stall <= w_ep3_stall;

	     r_ep4_stall <= w_ep4_stall;
	     r_ep5_stall <= w_ep5_stall;
	     r_ep6_stall <= w_ep6_stall;
	     r_ep7_stall <= w_ep7_stall;
	     
	     r_mem_rst <= w_mem_rst;
	     r_ep_rst <= w_ep_rst;

	     r_cnt_enable <= w_cnt_enable;
	     r_bulk_start <= w_bulk_start;

	     r_done <= w_done;
	  end // else: !if(rst)
     end // always@ (posedge clk)


   wire [31:0] w_ep0_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h000, 6'd63};
   wire [31:0] w_ep1_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h200, 6'd63};
   wire [31:0] w_ep2_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h400, 6'd63};
   wire [31:0] w_ep3_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h600, 6'd63};

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_ep0_boot_vector <= w_ep0_rst_insn;
	     r_ep1_boot_vector <= w_ep1_rst_insn;
	     r_ep2_boot_vector <= w_ep2_rst_insn;
	     r_ep3_boot_vector <= w_ep3_rst_insn;
	     r_ep4_boot_vector <= w_ep0_rst_insn;
	     r_ep5_boot_vector <= w_ep1_rst_insn;
	     r_ep6_boot_vector <= w_ep2_rst_insn;
	     r_ep7_boot_vector <= w_ep3_rst_insn;
	  end // if (rst)
	else
	  begin
	     r_ep0_boot_vector <= w_ep0_bv;
	     r_ep1_boot_vector <= w_ep1_bv;
	     r_ep2_boot_vector <= w_ep2_bv;
	     r_ep3_boot_vector <= w_ep3_bv;
	     r_ep4_boot_vector <= w_ep4_bv;
	     r_ep5_boot_vector <= w_ep5_bv;
	     r_ep6_boot_vector <= w_ep6_bv;
	     r_ep7_boot_vector <= w_ep7_bv;
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)
   	     
   
   wire w_count0_en = ~(ep0_hcf | r_ep0_stall) & r_cnt_enable;
   wire w_count1_en = ~(ep1_hcf | r_ep1_stall) & r_cnt_enable;
   wire w_count2_en = ~(ep2_hcf | r_ep2_stall) & r_cnt_enable;
   wire w_count3_en = ~(ep3_hcf | r_ep3_stall) & r_cnt_enable;

   wire w_count4_en = ~(ep4_hcf | r_ep4_stall) & r_cnt_enable;
   wire w_count5_en = ~(ep5_hcf | r_ep5_stall) & r_cnt_enable;
   wire w_count6_en = ~(ep6_hcf | r_ep6_stall) & r_cnt_enable;
   wire w_count7_en = ~(ep7_hcf | r_ep7_stall) & r_cnt_enable;

   

   wire w_write_count0 = ((pb_addr == 16'h8008) & pb_wr);
   wire w_write_count1 = ((pb_addr == 16'h8009) & pb_wr);   
   wire w_write_count2 = ((pb_addr == 16'h800a) & pb_wr);
   wire w_write_count3 = ((pb_addr == 16'h800b) & pb_wr);
  
   wire w_write_count4 = ((pb_addr == 16'h8010) & pb_wr);
   wire w_write_count5 = ((pb_addr == 16'h8011) & pb_wr);   
   wire w_write_count6 = ((pb_addr == 16'h8012) & pb_wr);
   wire w_write_count7 = ((pb_addr == 16'h8013) & pb_wr);

 
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count0 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count0)
	       begin
		  r_count0 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count0 <= 32'd0;
	       end
	     else if(w_count0_en)
	       begin
		  r_count0 <= r_count0 + 32'd1;
	       end
	     else
	       begin
		  r_count0 <= r_count0;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count1 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count1)
	       begin
		  r_count1 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count1 <= 32'd0;
	       end
	     else if(w_count1_en)
	       begin
		  r_count1 <= r_count1 + 32'd1;
	       end
	     else
	       begin
		  r_count1 <= r_count1;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)   

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count2 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count2)
	       begin
		  r_count2 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count2 <= 32'd0;
	       end
	     else if(w_count2_en)
	       begin
		  r_count2 <= r_count2 + 32'd1;
	       end
	     else
	       begin
		  r_count2 <= r_count2;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)  

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count3 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count3)
	       begin
		  r_count3 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count3 <= 32'd0;
	       end
	     else if(w_count3_en)
	       begin
		  r_count3 <= r_count3 + 32'd1;
	       end
	     else
	       begin
		  r_count3 <= r_count3;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)


   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count4 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count4)
	       begin
		  r_count4 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count4 <= 32'd0;
	       end
	     else if(w_count4_en)
	       begin
		  r_count4 <= r_count4 + 32'd1;
	       end
	     else
	       begin
		  r_count4 <= r_count4;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count5 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count4)
	       begin
		  r_count5 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count5 <= 32'd0;
	       end
	     else if(w_count4_en)
	       begin
		  r_count5 <= r_count5 + 32'd1;
	       end
	     else
	       begin
		  r_count5 <= r_count5;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count6 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count4)
	       begin
		  r_count6 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count6 <= 32'd0;
	       end
	     else if(w_count4_en)
	       begin
		  r_count6 <= r_count6 + 32'd1;
	       end
	     else
	       begin
		  r_count6 <= r_count6;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_count7 <= 32'd0;
	  end
	else
	  begin
	     if(w_write_count4)
	       begin
		  r_count7 <= pb_data_in;
	       end
	     else if(r_ep_rst)
	       begin
		  r_count7 <= 32'd0;
	       end
	     else if(w_count4_en)
	       begin
		  r_count7 <= r_count7 + 32'd1;
	       end
	     else
	       begin
		  r_count7 <= r_count7;
	       end
	  end // else: !if(rst)
     end // always@ (posedge clk or posedge rst)

   

   wire [34:0] e0_to_ocm_gated;
   wire [4:0]  e0_to_ocm_ungated;
   wire [34:0] e0_to_e1_gated;
   wire [4:0]  e0_to_e1_ungated;

   wire [34:0] ocm_to_e0_gated;
   wire [4:0]  ocm_to_e0_ungated;
   wire [34:0] ocm_to_e1_gated;
   wire [4:0]  ocm_to_e1_ungated;

   wire [34:0] e1_to_ocm_gated ;
   wire [4:0]  e1_to_ocm_ungated;
   wire [34:0] e1_to_e0_gated ;
   wire [4:0]  e1_to_e0_ungated ;


   full_ens #(.am_i_ens1(1'b0)) 
   ensemble0 (
	      // Outputs
	      .ep0_hcf		(ep0_hcf),
		    .ep1_hcf		(ep1_hcf),
		    .ep2_hcf		(ep2_hcf),
		    .ep3_hcf		(ep3_hcf),
		    
		    .test_b0_read_data	(test_b0_read_data),
		    .test_b1_read_data	(test_b1_read_data),
		    .test_b2_read_data	(test_b2_read_data),
		    .test_b3_read_data	(test_b3_read_data),
		    
		    .gated_outgoing_A	(e0_to_ocm_gated[34:0]),
		    .ungated_outgoing_A	(e0_to_ocm_ungated[4:0]),
		    .gated_outgoing_B	(e0_to_e1_gated[34:0]),
		    .ungated_outgoing_B	(e0_to_e1_ungated[4:0]),
	
		    // Inputs
		    .CLK		(clk),
		    .mem_rst		(r_mem_rst),
		    .ep_rst		(r_ep_rst),
		    .TEST_MODE		(r_test_mode),
		    .ep0_stall		(r_ep0_stall),
		    .ep1_stall		(r_ep1_stall),
		    .ep2_stall		(r_ep2_stall),
		    .ep3_stall		(r_ep3_stall),

                    .ep0_rst_insn       (r_ep0_boot_vector),
		    .ep1_rst_insn       (r_ep1_boot_vector),
		    .ep2_rst_insn       (r_ep2_boot_vector),
		    .ep3_rst_insn       (r_ep3_boot_vector),
		    
		    .gated_incoming_A	(ocm_to_e0_gated),
		    .ungated_incoming_A	(ocm_to_e0_ungated),
		    .gated_incoming_B	(e1_to_e0_gated),
		    .ungated_incoming_B	(e1_to_e0_ungated),

		    .test_b0_csn	(ens_b0_csn),
		    .test_b0_addr	(ens_addr),
		    .test_b0_write_data	(ens_data_in),
		    .test_b0_write_mask	(mask),
		    .test_b0_wen_b	(wen),
		    
		    .test_b1_csn	(ens_b1_csn),
		    .test_b1_addr	(ens_addr),
		    .test_b1_write_data	(ens_data_in),
		    .test_b1_write_mask	(mask),
		    .test_b1_wen_b	(wen),
		    
		    .test_b2_csn	(ens_b2_csn),
		    .test_b2_addr	(ens_addr),
		    .test_b2_write_data	(ens_data_in),
		    .test_b2_write_mask	(mask),
		    .test_b2_wen_b	(wen),
		    
		    .test_b3_csn	(ens_b3_csn),
		    .test_b3_addr	(ens_addr),
		    .test_b3_write_data	(ens_data_in),
		    .test_b3_write_mask	(mask),
		    .test_b3_wen_b	(wen)
		    
		    );

`ifdef FULL_SYSTEM
   full_ens #(.am_i_ens1(1'b1)) 
   ensemble1 (
		    // Outputs
		    .ep0_hcf		(ep4_hcf),
		    .ep1_hcf		(ep5_hcf),
		    .ep2_hcf		(ep6_hcf),
		    .ep3_hcf		(ep7_hcf),
		    
		    .test_b0_read_data	(test_b4_read_data),
		    .test_b1_read_data	(test_b5_read_data),
		    .test_b2_read_data	(test_b6_read_data),
		    .test_b3_read_data	(test_b7_read_data),
		    
		    .gated_outgoing_A	(e1_to_e0_gated),
		    .ungated_outgoing_A	(e1_to_e0_ungated),
		    .gated_outgoing_B	(e1_to_ocm_gated),
		    .ungated_outgoing_B	(e1_to_ocm_ungated),
	
		    // Inputs
		    .CLK		(clk),
		    .mem_rst		(r_mem_rst),
		    .ep_rst		(r_ep_rst),
		    .TEST_MODE		(r_test_mode),
		    .ep0_stall		(r_ep4_stall),
		    .ep1_stall		(r_ep5_stall),
		    .ep2_stall		(r_ep6_stall),
		    .ep3_stall		(r_ep7_stall),

                    .ep0_rst_insn       (r_ep4_boot_vector),
		    .ep1_rst_insn       (r_ep5_boot_vector),
		    .ep2_rst_insn       (r_ep6_boot_vector),
		    .ep3_rst_insn       (r_ep7_boot_vector),		       
		       
		    .gated_incoming_A	(e0_to_e1_gated),
		    .ungated_incoming_A	(e0_to_e1_ungated),
		    .gated_incoming_B	(ocm_to_e1_gated),
		    .ungated_incoming_B	(ocm_to_e1_ungated),

		    .test_b0_csn	(ens_b4_csn),
		    .test_b0_addr	(ens_addr),
		    .test_b0_write_data	(ens_data_in),
		    .test_b0_write_mask	(mask),
		    .test_b0_wen_b	(wen),
		    
		    .test_b1_csn	(ens_b5_csn),
		    .test_b1_addr	(ens_addr),
		    .test_b1_write_data	(ens_data_in),
		    .test_b1_write_mask	(mask),
		    .test_b1_wen_b	(wen),
		    
		    .test_b2_csn	(ens_b6_csn),
		    .test_b2_addr	(ens_addr),
		    .test_b2_write_data	(ens_data_in),
		    .test_b2_write_mask	(mask),
		    .test_b2_wen_b	(wen),
		    
		    .test_b3_csn	(ens_b7_csn),
		    .test_b3_addr	(ens_addr),
		    .test_b3_write_data	(ens_data_in),
		    .test_b3_write_mask	(mask),
		    .test_b3_wen_b	(wen)
		    
		    );

   ocm_top_level tchip_ocm 
     (
      // Outputs
      .test_tile_read_data(test_ocm_read_data),
      
      .gated_outgoing_A	(ocm_to_e0_gated[34:0]),
      .ungated_outgoing_A(ocm_to_e0_ungated[4:0]),
      .gated_outgoing_B	(ocm_to_e1_gated[34:0]),
      .ungated_outgoing_B(ocm_to_e1_ungated[4:0]),
      
      
      // Inputs
      .CLK		(clk),
      .rst		(r_mem_rst),
      .TEST_MODE	(r_test_mode),
      
      .test_tile_addr	(ocm_addr),
      .test_tile_csn	(ocm_csn),
      .test_tile_write_data(ens_data_in),
      .test_tile_write_mask(mask),
      .test_tile_wen_b	(wen),
      
      .gated_incoming_A	(e0_to_ocm_gated[34:0]),
      .ungated_incoming_A(e0_to_ocm_ungated[4:0]),
      .gated_incoming_B	(e1_to_ocm_gated[34:0]),
      .ungated_incoming_B(e1_to_ocm_ungated[4:0])
      );
`else // !`ifdef FULL_SYSTEM
   
   assign test_ocm_read_data = 'd0;
   assign ocm_to_e0_gated = 'd0;
   assign ocm_to_e0_ungated = 'd0;
   assign ocm_to_e1_gated = 'd0;
   assign ocm_to_e1_ungated = 'd0;
   
   assign ep4_hcf = 'd0;
   assign ep5_hcf = 'd0;
   assign ep6_hcf = 'd0;
   assign ep7_hcf = 'd0;
   
   assign test_b4_read_data = 'd0;
   assign test_b5_read_data = 'd0;
   assign test_b6_read_data = 'd0;
   assign test_b7_read_data = 'd0; 


   assign e1_to_ocm_gated = 'd0;
   assign e1_to_ocm_ungated = 'd0;
   assign e1_to_e0_gated = 'd0;
   assign e1_to_e0_ungated = 'd0;
   	
  
`endif // !`ifdef FULL_SYSTEM
   

   

endmodule // pb_elm_wrapper
