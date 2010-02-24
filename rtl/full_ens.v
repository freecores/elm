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
`include "ocm_defs.v"

module full_ens(/*AUTOARG*/
   // Outputs
   ep0_hcf, ep1_hcf, ep2_hcf, ep3_hcf, test_b0_read_data,
   test_b1_read_data, test_b2_read_data, test_b3_read_data,
   gated_outgoing_A, ungated_outgoing_A, gated_outgoing_B,
   ungated_outgoing_B,
   // Inputs
   CLK, mem_rst, ep_rst, TEST_MODE, ep0_stall, ep1_stall, ep2_stall,
   ep3_stall, gated_incoming_A, ungated_incoming_A, gated_incoming_B,
   ungated_incoming_B, test_b0_csn, test_b0_addr, test_b0_write_data,
   test_b0_write_mask, test_b0_wen_b, test_b1_csn, test_b1_addr,
   test_b1_write_data, test_b1_write_mask, test_b1_wen_b, test_b2_csn,
   test_b2_addr, test_b2_write_data, test_b2_write_mask,
   test_b2_wen_b, test_b3_csn, test_b3_addr, test_b3_write_data,
   test_b3_write_mask, test_b3_wen_b, ep0_rst_insn, ep1_rst_insn,
   ep2_rst_insn, ep3_rst_insn
   );
   
   parameter am_i_ens1 = 1'b0;
   
   
   input CLK;
   input mem_rst;
   input ep_rst;

    
   wire  ep0_rst = ep_rst;
   wire  ep1_rst = ep_rst;
   wire  ep2_rst = ep_rst;
   wire  ep3_rst = ep_rst;
   
   
   input TEST_MODE;
   input ep0_stall;
   input ep1_stall;
   input ep2_stall;
   input ep3_stall;

   output ep0_hcf;
   output ep1_hcf;
   output ep2_hcf;
   output ep3_hcf;
   
   output [63:0] test_b0_read_data;
   output [63:0] test_b1_read_data;
   output [63:0] test_b2_read_data;
   output [63:0] test_b3_read_data;

   output [34:0] gated_outgoing_A;
   output [4:0]  ungated_outgoing_A;
   output [34:0] gated_outgoing_B;
   output [4:0]  ungated_outgoing_B;

   input [34:0]  gated_incoming_A;
   input [4:0] 	 ungated_incoming_A;
   input [34:0]  gated_incoming_B;
   input [4:0] 	 ungated_incoming_B;
   
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

   wire 	 mem_to_ep0_box_read;
   wire 	 mem_to_ep1_box_read;
   wire 	 mem_to_ep2_box_read;
   wire 	 mem_to_ep3_box_read;

   reg [124:0] 	 ep0_to_mem_box;
   reg [124:0] 	 ep1_to_mem_box;
   reg [124:0] 	 ep2_to_mem_box;
   reg [124:0] 	 ep3_to_mem_box;
   
   wire 	 ep0_to_mem_box_read;
   wire 	 ep1_to_mem_box_read;
   wire 	 ep2_to_mem_box_read;
   wire 	 ep3_to_mem_box_read;
   
   wire [124:0]  mem_to_ep0_box;
   wire [124:0]  mem_to_ep1_box;
   wire [124:0]  mem_to_ep2_box;
   wire [124:0]  mem_to_ep3_box;

   
   wire [31:0] ep0_rs1_data;
   wire [31:0] ep0_rs2_data;
   wire [31:0] ep1_rs1_data;
   wire [31:0] ep1_rs2_data;
   wire [31:0] ep2_rs1_data;
   wire [31:0] ep2_rs2_data;
   wire [31:0] ep3_rs1_data;
   wire [31:0] ep3_rs2_data;

   wire        ep0_mr0_empty;
   wire        ep0_mr1_empty;
   wire        ep0_mr2_empty;
   wire        ep0_mr3_empty;
   wire        ep0_mr4_empty;
   wire        ep0_mr5_empty;
   wire        ep0_mr6_empty;
   wire        ep0_mr7_empty;
   wire        ep1_mr0_empty;
   wire        ep1_mr1_empty;
   wire        ep1_mr2_empty;
   wire        ep1_mr3_empty;
   wire        ep1_mr4_empty;
   wire        ep1_mr5_empty;
   wire        ep1_mr6_empty;
   wire        ep1_mr7_empty;
   wire        ep2_mr0_empty;
   wire        ep2_mr1_empty;
   wire        ep2_mr2_empty;
   wire        ep2_mr3_empty;
   wire        ep2_mr4_empty;
   wire        ep2_mr5_empty;
   wire        ep2_mr6_empty;
   wire        ep2_mr7_empty;
   wire        ep3_mr0_empty;
   wire        ep3_mr1_empty;
   wire        ep3_mr2_empty;
   wire        ep3_mr3_empty;
   wire        ep3_mr4_empty;
   wire        ep3_mr5_empty;
   wire        ep3_mr6_empty;
   wire        ep3_mr7_empty;


   wire        ep0_mr0_full;
   wire        ep0_mr1_full;
   wire        ep0_mr2_full;
   wire        ep0_mr3_full;
   wire        ep0_mr4_full;
   wire        ep0_mr5_full;
   wire        ep0_mr6_full;
   wire        ep0_mr7_full;
   wire        ep1_mr0_full;
   wire        ep1_mr1_full;
   wire        ep1_mr2_full;
   wire        ep1_mr3_full;
   wire        ep1_mr4_full;
   wire        ep1_mr5_full;
   wire        ep1_mr6_full;
   wire        ep1_mr7_full;
   wire        ep2_mr0_full;
   wire        ep2_mr1_full;
   wire        ep2_mr2_full;
   wire        ep2_mr3_full;
   wire        ep2_mr4_full;
   wire        ep2_mr5_full;
   wire        ep2_mr6_full;
   wire        ep2_mr7_full;
   wire        ep3_mr0_full;
   wire        ep3_mr1_full;
   wire        ep3_mr2_full;
   wire        ep3_mr3_full;
   wire        ep3_mr4_full;
   wire        ep3_mr5_full;
   wire        ep3_mr6_full;
   wire        ep3_mr7_full;

   wire        ep0_decode_stall;
   wire        ep1_decode_stall;
   wire        ep2_decode_stall;
   wire        ep3_decode_stall;
   wire [2:0]  ep0_rs1_ptr;
   wire        ep0_rs1_ptr_valid;
   wire [2:0]  ep0_rs2_ptr;
   wire        ep0_rs2_ptr_valid;
   wire [2:0]  ep1_rs1_ptr;
   wire        ep1_rs1_ptr_valid;
   wire [2:0]  ep1_rs2_ptr;
   wire        ep1_rs2_ptr_valid;
   wire [2:0]  ep2_rs1_ptr;
   wire        ep2_rs1_ptr_valid;
   wire [2:0]  ep2_rs2_ptr;
   wire        ep2_rs2_ptr_valid;
   wire [2:0]  ep3_rs1_ptr;
   wire        ep3_rs1_ptr_valid;
   wire [2:0]  ep3_rs2_ptr;
   wire        ep3_rs2_ptr_valid;

   wire [2:0]  ep0_alu_rd_ptr;
   wire        ep0_alu_rd_ptr_valid;
   wire [2:0]  ep0_xmu_rd_ptr;
   wire        ep0_xmu_rd_ptr_valid;
   wire [31:0] ep0_alu_rd_data;
   wire [31:0] ep0_xmu_rd_data;
   
   wire [2:0]  ep1_alu_rd_ptr;
   wire        ep1_alu_rd_ptr_valid;
   wire [2:0]  ep1_xmu_rd_ptr;
   wire        ep1_xmu_rd_ptr_valid;
   wire [31:0] ep1_alu_rd_data;
   wire [31:0] ep1_xmu_rd_data;

   wire [2:0]  ep2_alu_rd_ptr;
   wire        ep2_alu_rd_ptr_valid;
   wire [2:0]  ep2_xmu_rd_ptr;
   wire        ep2_xmu_rd_ptr_valid;
   wire [31:0] ep2_alu_rd_data;
   wire [31:0] ep2_xmu_rd_data;

   wire [2:0]  ep3_alu_rd_ptr;
   wire        ep3_alu_rd_ptr_valid;
   wire [2:0]  ep3_xmu_rd_ptr;
   wire        ep3_xmu_rd_ptr_valid;
   wire [31:0] ep3_alu_rd_data;
   wire [31:0] ep3_xmu_rd_data;

   /*
   wire [31:0] ep0_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h000, 6'd63};
   wire [31:0] ep1_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h200, 6'd63};
   wire [31:0] ep2_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h400, 6'd63};
   wire [31:0] ep3_rst_insn = {`X_JFETCH_A_I, 6'd0, 12'h600, 6'd63};
    */

   //just the xmu instruction, alu exec nop
   input [31:0] ep0_rst_insn;
   input [31:0] ep1_rst_insn;
   input [31:0] ep2_rst_insn;
   input [31:0] ep3_rst_insn;
     
   
   wire 	 ep0_barrier_req;
   wire 	 ep1_barrier_req;
   wire 	 ep2_barrier_req;
   wire 	 ep3_barrier_req;
      
   reg 		 ep0_barrier_r;
   reg 		 ep1_barrier_r;
   reg 		 ep2_barrier_r;
   reg 		 ep3_barrier_r;

   wire 	 ensemble_barrier_release = ep0_barrier_r & ep1_barrier_r &
		 ep2_barrier_r & ep3_barrier_r;

   always@(posedge CLK  or posedge ep_rst)
     if(ep_rst) begin
	ep0_barrier_r <= 1'b0;
	ep1_barrier_r <= 1'b0;
	ep2_barrier_r <= 1'b0;
	ep3_barrier_r <= 1'b0;
     end
     else begin
	ep0_barrier_r <= ep0_barrier_r ? ~ensemble_barrier_release : ep0_barrier_req;
	ep1_barrier_r <= ep1_barrier_r ? ~ensemble_barrier_release : ep1_barrier_req;
	ep2_barrier_r <= ep2_barrier_r ? ~ensemble_barrier_release : ep2_barrier_req;
	ep3_barrier_r <= ep3_barrier_r ? ~ensemble_barrier_release : ep3_barrier_req;
     end // else: !if(ep_rst)
   
   
   
   //wire [15:0] 	 ep0_irf_addr;
   //wire 	 ep0_irf_req;
   wire 	 ep0_xmu_req;
   wire 	 ep0_xmu_req_local;
   
   wire [15:0] 	 ep0_xmu_addr;
   wire 	 ep0_xmu_ld;
   wire 	 ep0_xmu_st;
   //todo make all of these interfaces 64b
   wire [31:0] 	 ep0_xmu_write_data_temp;
   wire [63:0] 	 ep0_xmu_write_data;
   assign 	 ep0_xmu_write_data = ep0_xmu_addr[0] ? {ep0_xmu_write_data_temp, 32'd0} :
		 {32'd0, ep0_xmu_write_data_temp};
   
   //wire [15:0] 	 ep0_toss_irf_addr;
   wire [15:0] 	 ep0_toss_xmu_addr;
   //wire 	 ep0_irf_gnt_late;
   //wire [63:0] 	 ep0_irf_read_data;

   
   reg 		 ep0_block_req;
   
   wire 	 ep0_xmu_gnt_late;
   wire 	 ep0_xmu_gnt_late_emem;
   wire [63:0] 	 ep0_xmu_read_data;
   wire [63:0] 	 ep0_xmu_read_data_emem;
   wire [31:0] 	 ep0_stream_offset;
   
   wire [31:0] 	 ep0_mem_swap_value;
   //wire [7:0] 	 ep0_stream_num_elements;
   //wire [5:0] 	 ep0_steam_descriptor_id;
   wire 	 ep0_mem_cswap;
   wire 	 ep0_mem_ldsd;
   wire 	 ep0_mem_stsd;
   wire 	 ep0_mem_lds;
   wire 	 ep0_mem_sts;
      
   wire 	 ep0_to_rem_mem;
   wire 	 ep0_to_rem_mem_no_block;
   reg 		 ep0_last_non_blocking;
   wire 	 ep0_non_block_load_complete;
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep0_last_non_blocking <= 1'b0;
	else
	  if(ep0_to_rem_mem_no_block)
	    ep0_last_non_blocking <= 1'b1;
	  else if(ep0_non_block_load_complete)
	    ep0_last_non_blocking <= 1'b0;
     end
   
   assign ep0_xmu_gnt_late = ep0_xmu_gnt_late_emem | mem_to_ep0_box[122];
   assign ep0_xmu_read_data = ep0_xmu_read_data_emem |
			      {mem_to_ep0_box[31:0],mem_to_ep0_box[31:0]};
   assign mem_to_ep0_box_read = mem_to_ep0_box[122] & 
	 (~ep0_last_non_blocking | ep0_non_block_load_complete);
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep0_block_req <= 1'b0;
	else
	  if(ep0_to_rem_mem & ep0_to_mem_box_read)
	   ep0_block_req <= 1'b1;
	  else if(mem_to_ep0_box[122])
	    ep0_block_req <= 1'b0;
     end
   
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep0_to_mem_box <= 125'd0;
	else begin
	   if(ep0_to_mem_box_read)
	     ep0_to_mem_box <= 125'd0;
	   else if(ep0_to_rem_mem & ~ep0_block_req) begin
	      ep0_to_mem_box[124:123] <= (ep0_mem_ldsd | ep0_mem_stsd | ep0_mem_lds | ep0_mem_sts) 
		? 2'b00 :  2'b01; //VC
	      ep0_to_mem_box[122] <= 1'b1; //Full
	      ep0_to_mem_box[121:118] <= ep0_mem_cswap ? `OCM_CMD_VC1_CPNSWP :
					 ep0_mem_lds ? `OCM_CMD_VC0_RDSTRM :
					 ep0_mem_sts ? `OCM_CMD_VC0_WRSTRM :
					 ep0_mem_ldsd ? `OCM_CMD_VC0_LDSD :
					 ep0_mem_stsd ? `OCM_CMD_VC0_STSD :
					 ep0_xmu_st ? `OCM_CMD_VC1_WRITE :
					 `OCM_CMD_VC1_READ;
	      ep0_to_mem_box[117:110] <= 8'h3a; //ID
	      ep0_to_mem_box[109:102] <= (ep0_mem_lds | ep0_mem_sts) ?
					 ep0_mem_swap_value[7:0] : 8'd1;//Size
	      ep0_to_mem_box[101:96] <= am_i_ens1 ? `OCM_NODE_E1_EP0 :`OCM_NODE_E0_EP0;
	      ep0_to_mem_box[95:64] <= (ep0_mem_ldsd | ep0_mem_stsd | ep0_mem_lds | ep0_mem_sts) ? 
				       ep0_xmu_write_data_temp  : ep0_mem_swap_value;
	      ep0_to_mem_box[63:32] <= (ep0_mem_lds | ep0_mem_sts) ? 
				       ep0_stream_offset : ep0_xmu_write_data_temp; //0 if ld...
	      ep0_to_mem_box[31:0] <= {ep0_toss_xmu_addr, ep0_xmu_addr};
	   end // if (ep0_xmu_rem_mem)
	end // else: !if(mem_rst)
     end // always@ (posedge CLK)
   
   assign ep0_xmu_req_local = ep0_xmu_req & ~ep0_to_rem_mem & ~ep0_mem_cswap & 
			      ~ep0_mem_ldsd & ~ep0_mem_stsd & ~ep0_mem_lds  & 
			      ~ep0_mem_sts;
   
   wire 	 ep0_mailbox_full = 1'b0;
   wire 	 ep1_mailbox_full = 1'b0;  
   wire 	 ep2_mailbox_full = 1'b0;  
   wire 	 ep3_mailbox_full = 1'b0;
   
   wire [63:0] 	 simd_to_ep_inst;
   wire 	 simd_to_ep_inst_valid;
   wire 	 simd_to_ep_force_stall;
   
   wire [63:0] 	 ep0_to_simd_inst;
   wire 	 ep0_to_simd_inst_valid;
   wire 	 ep0_to_simd_req;
   wire 	 ep0_to_simd_mine;
   wire 	 ep0_to_simd_simd_stall;

   wire 	 ep0_inst_mask;
   wire 	 ep1_inst_mask;
   wire 	 ep2_inst_mask;
   wire 	 ep3_inst_mask;
      
   ce_pipeline
   ep0(/**/
       // Outputs
       //.fetch_instr_request	(ep0_irf_req),
       //.fetch_instr_request_addr({ep0_toss_irf_addr, ep0_irf_addr}),
       .xmu_exec_req_mem	(ep0_xmu_req),
       .xmu_exec_ld_ensemble(ep0_xmu_ld),
       .xmu_exec_st_ensemble(ep0_xmu_st),
       .xmu_exec_mem_addr	({ep0_toss_xmu_addr, ep0_xmu_addr}),
       .xmu_exec_mem_write	(ep0_xmu_write_data_temp[31:0]),
       
       .ce_barrier_req (ep0_barrier_req),
       .xmu_remote_mem_req(ep0_to_rem_mem),
       .xmu_remote_mem_non_block(ep0_to_rem_mem_no_block),
       .non_block_load_complete(ep0_non_block_load_complete),

       .stream_offset (ep0_stream_offset),
       .mem_swap_value(ep0_mem_swap_value),
       .mem_cswap(ep0_mem_cswap),
       .mem_ldsd(ep0_mem_ldsd),
       .mem_stsd(ep0_mem_stsd),
       .mem_lds(ep0_mem_lds),
       .mem_sts(ep0_mem_sts),

       .decode_stall (ep0_decode_stall ),
       .mr_rs1_ptr(ep0_rs1_ptr ),
       .mr_rs1_ptr_valid(ep0_rs1_ptr_valid ),
       .mr_rs2_ptr(ep0_rs2_ptr ),
       .mr_rs2_ptr_valid(ep0_rs2_ptr_valid ),

       .mr_alu_rd_ptr(ep0_alu_rd_ptr ),
       .mr_alu_rd_ptr_valid(ep0_alu_rd_ptr_valid ),
       .mr_alu_rd_data(ep0_alu_rd_data ),

       .mr_xmu_rd_ptr(ep0_xmu_rd_ptr),
       .mr_xmu_rd_ptr_valid(ep0_xmu_rd_ptr_valid ),
       .mr_xmu_rd_data(ep0_xmu_rd_data),

       .hcf(ep0_hcf),
       
       .simd_out_inst(ep0_to_simd_inst),
       .simd_out_inst_valid(ep0_to_simd_inst_valid),
       .simd_out_req(ep0_to_simd_req),
       .simd_out_mine(ep0_to_simd_mine),
       .simd_out_simd_stall(ep0_to_simd_simd_stall),
       // Inputs
       .simd_in_inst(simd_to_ep_inst),
       .simd_in_inst_valid(simd_to_ep_inst_valid),
       .simd_in_stall(simd_to_ep_force_stall),
       .simd_in_mask(ep0_inst_mask),
       
       .mr0_empty(ep0_mr0_empty ),
       .mr0_full( ep0_mr0_full),
       .mr1_empty(ep0_mr1_empty ),
       .mr1_full(ep0_mr1_full ),
       .mr2_empty(ep0_mr2_empty ),
       .mr2_full(ep0_mr2_full ),
       .mr3_empty(ep0_mr3_empty ),
       .mr3_full(ep0_mr3_full ),
       .mr4_empty(ep0_mr4_empty ),
       .mr4_full(ep0_mr4_full ),
       .mr5_empty(ep0_mr5_empty ),
       .mr5_full(ep0_mr5_full ),
       .mr6_empty(ep0_mr6_empty ),
       .mr6_full(ep0_mr6_full ),
       .mr7_empty(ep0_mr7_empty ),
       .mr7_full(ep0_mr7_full ),

       .mr_rs1_data(ep0_rs1_data ),
       .mr_rs2_data(ep0_rs2_data ),
       
       .xmu_boot_inst(ep0_rst_insn),
       .who_am_i(2'd0),
       
       .ensemble_barrier_release(ensemble_barrier_release),
       .mailbox_full(ep0_mailbox_full),  
       .global_stall (ep0_stall),
       .clk			(CLK),
       .rst			(ep0_rst),
       //.fetch_data_ready	(ep0_irf_gnt_late),
       //.fetch_data_in	(ep0_irf_read_data),
       .ensemble_mem_gnt	(ep0_xmu_gnt_late),
       .ensemble_mem_ld	(ep0_xmu_read_data));


   //wire [15:0] 	 ep1_irf_addr;
   //wire 		 ep1_irf_req;
   wire 	 ep1_xmu_req;
   wire 	 ep1_xmu_req_local;
   
   wire [15:0] 	 ep1_xmu_addr;
   wire 	 ep1_xmu_ld;
   wire 	 ep1_xmu_st;
   //todo make all of these interfaces 64b
   wire [31:0] 	 ep1_xmu_write_data_temp;
   wire [63:0] 	 ep1_xmu_write_data;
   assign 	 ep1_xmu_write_data = ep1_xmu_addr[0] ? {ep1_xmu_write_data_temp, 32'd0} :
				      {32'd0, ep1_xmu_write_data_temp};
   
   //wire [15:0] 	 ep1_toss_irf_addr;
   wire [15:0] 	 ep1_toss_xmu_addr;
   //wire 	 ep1_irf_gnt_late;
   //wire [63:0] 	 ep1_irf_read_data;
  
   reg 		 ep1_block_req;
   
   wire 	 ep1_xmu_gnt_late;
   wire 	 ep1_xmu_gnt_late_emem;
   wire [63:0] 	 ep1_xmu_read_data;
   wire [63:0] 	 ep1_xmu_read_data_emem;
   wire [31:0] 	 ep1_stream_offset;
   
   wire [31:0] 	 ep1_mem_swap_value;
   //wire [7:0] 	 ep1_stream_num_elements;
   //wire [5:0] 	 ep1_steam_descriptor_id;
   wire 	 ep1_mem_cswap;
   wire 	 ep1_mem_ldsd;
   wire 	 ep1_mem_stsd;
   wire 	 ep1_mem_lds;
   wire 	 ep1_mem_sts;
      
   wire 	 ep1_to_rem_mem;
   wire 	 ep1_to_rem_mem_no_block;
   reg 		 ep1_last_non_blocking;
   wire 	 ep1_non_block_load_complete;
   
   always@(posedge CLK  or posedge mem_rst)
     begin
	if(mem_rst)
	  ep1_last_non_blocking <= 1'b0;
	else
	  if(ep1_to_rem_mem_no_block)
	    ep1_last_non_blocking <= 1'b1;
	  else if(ep1_non_block_load_complete)
	    ep1_last_non_blocking <= 1'b0;
     end
   

   assign ep1_xmu_gnt_late = ep1_xmu_gnt_late_emem | mem_to_ep1_box[122];
   assign ep1_xmu_read_data = ep1_xmu_read_data_emem | 
			      {mem_to_ep1_box[31:0], mem_to_ep1_box[31:0]};
   assign mem_to_ep1_box_read = mem_to_ep1_box[122] & 
				(~ep0_last_non_blocking | ep0_non_block_load_complete);
   
   always@(posedge CLK  or posedge mem_rst)
     begin
	if(mem_rst)
	  ep1_block_req <= 1'b0;
	else
	  if(ep1_to_rem_mem & ep1_to_mem_box_read)
	   ep1_block_req <= 1'b1;
	  else if(mem_to_ep1_box[122])
	    ep1_block_req <= 1'b0;
     end
   
   
   always@(posedge CLK  or posedge mem_rst)
     begin
	if(mem_rst)
	  ep1_to_mem_box <= 125'd0;
	else begin
	   if(ep1_to_mem_box_read)
	     ep1_to_mem_box <= 125'd0;
	   else if(ep1_to_rem_mem & ~ep1_block_req) begin
	      ep1_to_mem_box[124:123] <= (ep1_mem_ldsd | ep1_mem_stsd | ep1_mem_lds | ep1_mem_sts) 
		? 2'b00 :  2'b01; //VC
	      ep1_to_mem_box[122] <= 1'b1; //Full
	      ep1_to_mem_box[121:118] <= ep1_mem_cswap ? `OCM_CMD_VC1_CPNSWP :
					 ep1_mem_lds ? `OCM_CMD_VC0_RDSTRM :
					 ep1_mem_sts ? `OCM_CMD_VC0_WRSTRM :
					 ep1_mem_ldsd ? `OCM_CMD_VC0_LDSD :
					 ep1_mem_stsd ? `OCM_CMD_VC0_STSD :
					 ep1_xmu_st ? `OCM_CMD_VC1_WRITE :
					 `OCM_CMD_VC1_READ;
	      ep1_to_mem_box[117:110] <= 8'h3a; //ID
	      ep1_to_mem_box[109:102] <= (ep1_mem_lds | ep1_mem_sts) ? ep1_mem_swap_value[7:0] : 8'd1;//Size
	      ep1_to_mem_box[101:96] <= am_i_ens1 ? `OCM_NODE_E1_EP1 : `OCM_NODE_E0_EP1;
	      ep1_to_mem_box[95:64] <= (ep1_mem_ldsd | ep1_mem_stsd | ep1_mem_lds | ep1_mem_sts) ? ep1_xmu_write_data_temp 
				       : ep1_mem_swap_value;
	      ep1_to_mem_box[63:32] <= (ep1_mem_lds | ep1_mem_sts) ? ep1_stream_offset : ep1_xmu_write_data_temp; //0 if ld...
	      ep1_to_mem_box[31:0] <= {ep1_toss_xmu_addr, ep1_xmu_addr};
	   end // if (ep1_xmu_rem_mem)
	end // else: !if(mem_rst)
     end // always@ (posedge CLK)
   
   assign ep1_xmu_req_local = ep1_xmu_req & ~ep1_to_rem_mem & ~ep1_mem_cswap & 
			      ~ep1_mem_ldsd & ~ep1_mem_stsd & ~ep1_mem_lds  & 
			      ~ep1_mem_sts;

   
   wire [63:0] 	 ep1_to_simd_inst;
   wire 	 ep1_to_simd_inst_valid;
   wire 	 ep1_to_simd_req;
   wire 	 ep1_to_simd_mine;
   wire 	 ep1_to_simd_simd_stall;
   
   ce_pipeline 
   ep1(/**/
       // Outputs
       //.fetch_instr_request	(ep1_irf_req),
       //.fetch_instr_request_addr({ep1_toss_irf_addr, ep1_irf_addr}),
       .xmu_exec_req_mem	(ep1_xmu_req),
       .xmu_exec_ld_ensemble(ep1_xmu_ld),
       .xmu_exec_st_ensemble(ep1_xmu_st),
       .xmu_exec_mem_addr	({ep1_toss_xmu_addr, ep1_xmu_addr}),
       .xmu_exec_mem_write	(ep1_xmu_write_data_temp[31:0]),
       
       .ce_barrier_req (ep1_barrier_req),
       .xmu_remote_mem_req(ep1_to_rem_mem),
       .xmu_remote_mem_non_block(ep1_to_rem_mem_no_block),
       .non_block_load_complete(ep1_non_block_load_complete),
       
       .stream_offset (ep1_stream_offset),
       .mem_swap_value(ep1_mem_swap_value),
       .mem_cswap(ep1_mem_cswap),
       .mem_ldsd(ep1_mem_ldsd),
       .mem_stsd(ep1_mem_stsd),
       .mem_lds(ep1_mem_lds),
       .mem_sts(ep1_mem_sts),       

       .decode_stall (ep1_decode_stall ),
       .mr_rs1_ptr(ep1_rs1_ptr ),
       .mr_rs1_ptr_valid(ep1_rs1_ptr_valid ),
       .mr_rs2_ptr(ep1_rs2_ptr ),
       .mr_rs2_ptr_valid(ep1_rs2_ptr_valid ),

       .mr_alu_rd_ptr(ep1_alu_rd_ptr ),
       .mr_alu_rd_ptr_valid(ep1_alu_rd_ptr_valid ),
       .mr_alu_rd_data(ep1_alu_rd_data ),

       .mr_xmu_rd_ptr(ep1_xmu_rd_ptr),
       .mr_xmu_rd_ptr_valid(ep1_xmu_rd_ptr_valid ),
       .mr_xmu_rd_data(ep1_xmu_rd_data),
       
       .simd_out_inst(ep1_to_simd_inst),
       .simd_out_inst_valid(ep1_to_simd_inst_valid),
       .simd_out_req(ep1_to_simd_req),
       .simd_out_mine(ep1_to_simd_mine),
       .simd_out_simd_stall(ep1_to_simd_simd_stall),
       // Inputs
       .simd_in_inst(simd_to_ep_inst),
       .simd_in_inst_valid(simd_to_ep_inst_valid),
       .simd_in_stall(simd_to_ep_force_stall),
       .simd_in_mask(ep1_inst_mask),
       
       // Inputs
       .mr0_empty(ep1_mr0_empty ),
       .mr0_full( ep1_mr0_full),
       .mr1_empty(ep1_mr1_empty ),
       .mr1_full(ep1_mr1_full ),
       .mr2_empty(ep1_mr2_empty ),
       .mr2_full(ep1_mr2_full ),
       .mr3_empty(ep1_mr3_empty ),
       .mr3_full(ep1_mr3_full ),
       .mr4_empty(ep1_mr4_empty ),
       .mr4_full(ep1_mr4_full ),
       .mr5_empty(ep1_mr5_empty ),
       .mr5_full(ep1_mr5_full ),
       .mr6_empty(ep1_mr6_empty ),
       .mr6_full(ep1_mr6_full ),
       .mr7_empty(ep1_mr7_empty ),
       .mr7_full(ep1_mr7_full ),

       .mr_rs1_data(ep1_rs1_data ),
       .mr_rs2_data(ep1_rs2_data ),

      .hcf(ep1_hcf),

      .xmu_boot_inst(ep1_rst_insn),
      .who_am_i(2'd1),
       
       // Inputs
       .ensemble_barrier_release(ensemble_barrier_release),
       .mailbox_full(ep1_mailbox_full),  

       .global_stall (ep1_stall),
       .clk			(CLK),
       .rst			(ep1_rst),
       //.fetch_data_ready	(ep1_irf_gnt_late),
       //.fetch_data_in	(ep1_irf_read_data),
       .ensemble_mem_gnt	(ep1_xmu_gnt_late),
       .ensemble_mem_ld	(ep1_xmu_read_data));

   

   //wire [15:0] 	 ep2_irf_addr;
   //wire 		 ep2_irf_req;
   wire 	 ep2_xmu_req;
   wire 	 ep2_xmu_req_local;
   
   wire [15:0] 	 ep2_xmu_addr;
   wire 	 ep2_xmu_ld;
   wire 	 ep2_xmu_st;
   //todo make all of these interfaces 64b
   wire [31:0] 	 ep2_xmu_write_data_temp;
   wire [63:0] 	 ep2_xmu_write_data;
   assign 	 ep2_xmu_write_data = ep2_xmu_addr[0] ? {ep2_xmu_write_data_temp, 32'd0} :
				      {32'd0, ep2_xmu_write_data_temp};
   
   //wire [15:0] 	 ep2_toss_irf_addr;
   wire [15:0] 	 ep2_toss_xmu_addr;
   //wire 	 ep2_irf_gnt_late;
   //wire [63:0] 	 ep2_irf_read_data;
  
   reg 		 ep2_block_req;
   
   wire 	 ep2_xmu_gnt_late;
   wire 	 ep2_xmu_gnt_late_emem;
   wire [63:0] 	 ep2_xmu_read_data;
   wire [63:0] 	 ep2_xmu_read_data_emem;
   wire [31:0] 	 ep2_stream_offset;
   
   wire [31:0] 	 ep2_mem_swap_value;
   //wire [7:0] 	 ep2_stream_num_elements;
   //wire [5:0] 	 ep2_steam_descriptor_id;
   wire 	 ep2_mem_cswap;
   wire 	 ep2_mem_ldsd;
   wire 	 ep2_mem_stsd;
   wire 	 ep2_mem_lds;
   wire 	 ep2_mem_sts;
   
   wire 	 ep2_to_rem_mem;
   wire 	 ep2_to_rem_mem_no_block;
   reg 		 ep2_last_non_blocking;
   wire 	 ep2_non_block_load_complete;
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep2_last_non_blocking <= 1'b0;
	else
	  if(ep2_to_rem_mem_no_block)
	    ep2_last_non_blocking <= 1'b1;
	  else if(ep2_non_block_load_complete)
	    ep2_last_non_blocking <= 1'b0;
     end
   
   assign ep2_xmu_gnt_late = ep2_xmu_gnt_late_emem | mem_to_ep2_box[122];
   assign ep2_xmu_read_data = ep2_xmu_read_data_emem | 
			      {mem_to_ep2_box[31:0], mem_to_ep2_box[31:0]};
   assign mem_to_ep2_box_read = mem_to_ep2_box[122] &
				(~ep2_last_non_blocking | ep2_non_block_load_complete);
	    

   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep2_block_req <= 1'b0;
	else
	  if(ep2_to_rem_mem & ep2_to_mem_box_read)
	   ep2_block_req <= 1'b1;
	  else if(mem_to_ep2_box[122])
	    ep2_block_req <= 1'b0;
     end
   
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep2_to_mem_box <= 125'd0;
	else begin
	   if(ep2_to_mem_box_read)
	     ep2_to_mem_box <= 125'd0;
	   else if(ep2_to_rem_mem & ~ep2_block_req) begin
	      ep2_to_mem_box[124:123] <= (ep2_mem_ldsd | ep2_mem_stsd | ep2_mem_lds | ep2_mem_sts) 
		? 2'b00 :  2'b01; //VC
	      ep2_to_mem_box[122] <= 1'b1; //Full
	      ep2_to_mem_box[121:118] <= ep2_mem_cswap ? `OCM_CMD_VC1_CPNSWP :
					 ep2_mem_lds ? `OCM_CMD_VC0_RDSTRM :
					 ep2_mem_sts ? `OCM_CMD_VC0_WRSTRM :
					 ep2_mem_ldsd ? `OCM_CMD_VC0_LDSD :
					 ep2_mem_stsd ? `OCM_CMD_VC0_STSD :
					 ep2_xmu_st ? `OCM_CMD_VC1_WRITE :
					 `OCM_CMD_VC1_READ;
	      ep2_to_mem_box[117:110] <= 8'h3a; //ID
	      ep2_to_mem_box[109:102] <= (ep2_mem_lds | ep2_mem_sts) ? ep2_mem_swap_value[7:0] : 8'd1;//Size
	      ep2_to_mem_box[101:96] <= am_i_ens1 ? `OCM_NODE_E1_EP2 : `OCM_NODE_E0_EP2;
	      ep2_to_mem_box[95:64] <= (ep2_mem_ldsd | ep2_mem_stsd | ep2_mem_lds | ep2_mem_sts) ? ep2_xmu_write_data_temp 
				       : ep2_mem_swap_value;
	      ep2_to_mem_box[63:32] <= (ep2_mem_lds | ep2_mem_sts) ? ep2_stream_offset : ep2_xmu_write_data_temp; //0 if ld...
	      ep2_to_mem_box[31:0] <= {ep2_toss_xmu_addr, ep2_xmu_addr};
	   end // if (ep2_xmu_rem_mem)
	end // else: !if(mem_rst)
     end // always@ (posedge CLK)
   
   assign ep2_xmu_req_local = ep2_xmu_req & ~ep2_to_rem_mem & ~ep2_mem_cswap & 
			      ~ep2_mem_ldsd & ~ep2_mem_stsd & ~ep2_mem_lds  & 
			      ~ep2_mem_sts;

   wire [63:0] 	 ep2_to_simd_inst;
   wire 	 ep2_to_simd_inst_valid;
   wire 	 ep2_to_simd_req;
   wire 	 ep2_to_simd_mine;
   wire 	 ep2_to_simd_simd_stall;
 
   
   ce_pipeline
   ep2(/**/
       // Outputs
       //.fetch_instr_request	(ep2_irf_req),
       //.fetch_instr_request_addr({ep2_toss_irf_addr, ep2_irf_addr}),
       .xmu_exec_req_mem	(ep2_xmu_req),
       .xmu_exec_ld_ensemble(ep2_xmu_ld),
       .xmu_exec_st_ensemble(ep2_xmu_st),
       .xmu_exec_mem_addr	({ep2_toss_xmu_addr, ep2_xmu_addr}),
       .xmu_exec_mem_write	(ep2_xmu_write_data_temp[31:0]),
       
       .ce_barrier_req (ep2_barrier_req),
       .xmu_remote_mem_req(ep2_to_rem_mem),
       .xmu_remote_mem_non_block(ep2_to_rem_mem_no_block),
       .non_block_load_complete(ep2_non_block_load_complete),
       
       .stream_offset (ep2_stream_offset),
       .mem_swap_value(ep2_mem_swap_value),
       .mem_cswap(ep2_mem_cswap),
       .mem_ldsd(ep2_mem_ldsd),
       .mem_stsd(ep2_mem_stsd),
       .mem_lds(ep2_mem_lds),
       .mem_sts(ep2_mem_sts),       
    .decode_stall (ep2_decode_stall ),
       .mr_rs1_ptr(ep2_rs1_ptr ),
       .mr_rs1_ptr_valid(ep2_rs1_ptr_valid ),
       .mr_rs2_ptr(ep2_rs2_ptr ),
       .mr_rs2_ptr_valid(ep2_rs2_ptr_valid ),

       .mr_alu_rd_ptr(ep2_alu_rd_ptr ),
       .mr_alu_rd_ptr_valid(ep2_alu_rd_ptr_valid ),
       .mr_alu_rd_data(ep2_alu_rd_data ),

       .mr_xmu_rd_ptr(ep2_xmu_rd_ptr),
       .mr_xmu_rd_ptr_valid(ep2_xmu_rd_ptr_valid ),
       .mr_xmu_rd_data(ep2_xmu_rd_data),

        .xmu_boot_inst(ep2_rst_insn),
       .who_am_i(2'd2),
       
       .hcf(ep2_hcf),
       .simd_out_inst(ep2_to_simd_inst),
       .simd_out_inst_valid(ep2_to_simd_inst_valid),
       .simd_out_req(ep2_to_simd_req),
       .simd_out_mine(ep2_to_simd_mine),
       .simd_out_simd_stall(ep2_to_simd_simd_stall),
       // Inputs
       .simd_in_inst(simd_to_ep_inst),
       .simd_in_inst_valid(simd_to_ep_inst_valid),
       .simd_in_stall(simd_to_ep_force_stall),
       .simd_in_mask(ep2_inst_mask),
       
       // Inputs
       .mr0_empty(ep2_mr0_empty ),
       .mr0_full( ep2_mr0_full),
       .mr1_empty(ep2_mr1_empty ),
       .mr1_full(ep2_mr1_full ),
       .mr2_empty(ep2_mr2_empty ),
       .mr2_full(ep2_mr2_full ),
       .mr3_empty(ep2_mr3_empty ),
       .mr3_full(ep2_mr3_full ),
       .mr4_empty(ep2_mr4_empty ),
       .mr4_full(ep2_mr4_full ),
       .mr5_empty(ep2_mr5_empty ),
       .mr5_full(ep2_mr5_full ),
       .mr6_empty(ep2_mr6_empty ),
       .mr6_full(ep2_mr6_full ),
       .mr7_empty(ep2_mr7_empty ),
       .mr7_full(ep2_mr7_full ),

       .mr_rs1_data(ep2_rs1_data ),
       .mr_rs2_data(ep2_rs2_data ),
       
       // Inputs
       .ensemble_barrier_release(ensemble_barrier_release),
       .mailbox_full(ep2_mailbox_full),  

       .global_stall (ep2_stall),
       .clk			(CLK),
       .rst			(ep2_rst),
       //.fetch_data_ready	(ep2_irf_gnt_late),
       //.fetch_data_in	(ep2_irf_read_data),
       .ensemble_mem_gnt	(ep2_xmu_gnt_late),
       .ensemble_mem_ld	(ep2_xmu_read_data));

   


   //  wire [15:0] 	 ep3_irf_addr;
   //wire 		 ep3_irf_req;
   wire 	 ep3_xmu_req;
   wire 	 ep3_xmu_req_local;
   
   wire [15:0] 	 ep3_xmu_addr;
   wire 	 ep3_xmu_ld;
   wire 	 ep3_xmu_st;
   //todo make all of these interfaces 64b
   wire [31:0] 	 ep3_xmu_write_data_temp;
   wire [63:0] 	 ep3_xmu_write_data;
   assign 	 ep3_xmu_write_data = ep3_xmu_addr[0] ? {ep3_xmu_write_data_temp, 32'd0} :
				      {32'd0, ep3_xmu_write_data_temp};
   
   //wire [15:0] 	 ep3_toss_irf_addr;
   wire [15:0] 	 ep3_toss_xmu_addr;
   //wire 	 ep3_irf_gnt_late;
   //wire [63:0] 	 ep3_irf_read_data;
   
   reg 		 ep3_block_req;
   
   wire 	 ep3_xmu_gnt_late;
   wire 	 ep3_xmu_gnt_late_emem;
   wire [63:0] 	 ep3_xmu_read_data;
   wire [63:0] 	 ep3_xmu_read_data_emem;
   wire [31:0] 	 ep3_stream_offset;
   
   wire [31:0] 	 ep3_mem_swap_value;
   //wire [7:0] 	 ep3_stream_num_elements;
   //wire [5:0] 	 ep3_steam_descriptor_id;
   wire 	 ep3_mem_cswap;
   wire 	 ep3_mem_ldsd;
   wire 	 ep3_mem_stsd;
   wire 	 ep3_mem_lds;
   wire 	 ep3_mem_sts;
      
   wire 	 ep3_to_rem_mem;
   wire 	 ep3_to_rem_mem_no_block;
   reg 		 ep3_last_non_blocking;
   wire 	 ep3_non_block_load_complete;
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep3_last_non_blocking <= 1'b0;
	else
	  if(ep3_to_rem_mem_no_block)
	    ep3_last_non_blocking <= 1'b1;
	  else if(ep3_non_block_load_complete)
	    ep3_last_non_blocking <= 1'b0;
     end
      
   assign ep3_xmu_gnt_late = ep3_xmu_gnt_late_emem | mem_to_ep3_box[122];
   assign ep3_xmu_read_data = ep3_xmu_read_data_emem | 
			      {mem_to_ep3_box[31:0],mem_to_ep3_box[31:0]};
   assign mem_to_ep3_box_read = mem_to_ep3_box[122] &
				(~ep3_last_non_blocking | ep3_non_block_load_complete);
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep3_block_req <= 1'b0;
	else
	  if(ep3_to_rem_mem & ep3_to_mem_box_read)
	   ep3_block_req <= 1'b1;
	  else if(mem_to_ep3_box[122])
	    ep3_block_req <= 1'b0;
     end
   
   
   always@(posedge CLK or posedge mem_rst)
     begin
	if(mem_rst)
	  ep3_to_mem_box <= 125'd0;
	else begin
	   if(ep3_to_mem_box_read)
	     ep3_to_mem_box <= 125'd0;
	   else if(ep3_to_rem_mem & ~ep3_block_req) begin
	      ep3_to_mem_box[124:123] <= (ep3_mem_ldsd | ep3_mem_stsd | ep3_mem_lds | ep3_mem_sts) 
		? 2'b00 :  2'b01; //VC
	      ep3_to_mem_box[122] <= 1'b1; //Full
	      ep3_to_mem_box[121:118] <= ep3_mem_cswap ? `OCM_CMD_VC1_CPNSWP :
					 ep3_mem_lds ? `OCM_CMD_VC0_RDSTRM :
					 ep3_mem_sts ? `OCM_CMD_VC0_WRSTRM :
					 ep3_mem_ldsd ? `OCM_CMD_VC0_LDSD :
					 ep3_mem_stsd ? `OCM_CMD_VC0_STSD :
					 ep3_xmu_st ? `OCM_CMD_VC1_WRITE :
					 `OCM_CMD_VC1_READ;
	      ep3_to_mem_box[117:110] <= 8'h3a; //ID
	      ep3_to_mem_box[109:102] <= (ep3_mem_lds | ep3_mem_sts) ? ep3_mem_swap_value[7:0] : 8'd1;//Size
	      ep3_to_mem_box[101:96] <= am_i_ens1 ? `OCM_NODE_E1_EP3 : `OCM_NODE_E0_EP3;
	      ep3_to_mem_box[95:64] <= (ep3_mem_ldsd | ep3_mem_stsd | ep3_mem_lds | ep3_mem_sts) ? ep3_xmu_write_data_temp 
				       : ep3_mem_swap_value;
	      ep3_to_mem_box[63:32] <= (ep3_mem_lds | ep3_mem_sts) ? ep3_stream_offset : ep3_xmu_write_data_temp; //0 if ld...
	      ep3_to_mem_box[31:0] <= {ep3_toss_xmu_addr, ep3_xmu_addr};
	   end // if (ep3_xmu_rem_mem)
	end // else: !if(mem_rst)
     end // always@ (posedge CLK)
   
   assign ep3_xmu_req_local = ep3_xmu_req & ~ep3_to_rem_mem & ~ep3_mem_cswap & 
			      ~ep3_mem_ldsd & ~ep3_mem_stsd & ~ep3_mem_lds  & 
			      ~ep3_mem_sts;

   wire [63:0] 	 ep3_to_simd_inst;
   wire 	 ep3_to_simd_inst_valid;
   wire 	 ep3_to_simd_req;
   wire 	 ep3_to_simd_mine;
   wire 	 ep3_to_simd_simd_stall;
   
 
   ce_pipeline
   ep3(/**/
       // Outputs
       //.fetch_instr_request	(ep3_irf_req),
       //.fetch_instr_request_addr({ep3_toss_irf_addr, ep3_irf_addr}),
       .xmu_exec_req_mem	(ep3_xmu_req),
       .xmu_exec_ld_ensemble(ep3_xmu_ld),
       .xmu_exec_st_ensemble(ep3_xmu_st),
       .xmu_exec_mem_addr	({ep3_toss_xmu_addr, ep3_xmu_addr}),
       .xmu_exec_mem_write	(ep3_xmu_write_data_temp[31:0]),
       
       .ce_barrier_req (ep3_barrier_req),
       .xmu_remote_mem_req(ep3_to_rem_mem),
       .xmu_remote_mem_non_block(ep3_to_rem_mem_no_block),
       .non_block_load_complete(ep3_non_block_load_complete),
       
       .stream_offset (ep3_stream_offset),
       .mem_swap_value(ep3_mem_swap_value),
       .mem_cswap(ep3_mem_cswap),
       .mem_ldsd(ep3_mem_ldsd),
       .mem_stsd(ep3_mem_stsd),
       .mem_lds(ep3_mem_lds),
       .mem_sts(ep3_mem_sts),       
       .decode_stall (ep3_decode_stall ),
       .mr_rs1_ptr(ep3_rs1_ptr ),
       .mr_rs1_ptr_valid(ep3_rs1_ptr_valid ),
       .mr_rs2_ptr(ep3_rs2_ptr ),
       .mr_rs2_ptr_valid(ep3_rs2_ptr_valid ),

       .mr_alu_rd_ptr(ep3_alu_rd_ptr ),
       .mr_alu_rd_ptr_valid(ep3_alu_rd_ptr_valid ),
       .mr_alu_rd_data(ep3_alu_rd_data ),

       .mr_xmu_rd_ptr(ep3_xmu_rd_ptr),
       .mr_xmu_rd_ptr_valid(ep3_xmu_rd_ptr_valid ),
       .mr_xmu_rd_data(ep3_xmu_rd_data),

       .hcf (ep3_hcf),

       .xmu_boot_inst(ep3_rst_insn),
       .who_am_i(2'd3),
       
       .simd_out_inst(ep3_to_simd_inst),
       .simd_out_inst_valid(ep3_to_simd_inst_valid),
       .simd_out_req(ep3_to_simd_req),
       .simd_out_mine(ep3_to_simd_mine),
       .simd_out_simd_stall(ep3_to_simd_simd_stall),
       // Inputs
       .simd_in_inst(simd_to_ep_inst),
       .simd_in_inst_valid(simd_to_ep_inst_valid),
       .simd_in_stall(simd_to_ep_force_stall),
       .simd_in_mask(ep3_inst_mask),
          
       // Inputs
       .mr0_empty(ep3_mr0_empty ),
       .mr0_full( ep3_mr0_full),
       .mr1_empty(ep3_mr1_empty ),
       .mr1_full(ep3_mr1_full ),
       .mr2_empty(ep3_mr2_empty ),
       .mr2_full(ep3_mr2_full ),
       .mr3_empty(ep3_mr3_empty ),
       .mr3_full(ep3_mr3_full ),
       .mr4_empty(ep3_mr4_empty ),
       .mr4_full(ep3_mr4_full ),
       .mr5_empty(ep3_mr5_empty ),
       .mr5_full(ep3_mr5_full ),
       .mr6_empty(ep3_mr6_empty ),
       .mr6_full(ep3_mr6_full ),
       .mr7_empty(ep3_mr7_empty ),
       .mr7_full(ep3_mr7_full ),

       .mr_rs1_data(ep3_rs1_data ),
       .mr_rs2_data(ep3_rs2_data ),
       
       // Inputs
       .ensemble_barrier_release(ensemble_barrier_release),
       .mailbox_full(ep3_mailbox_full),  

       .global_stall (ep3_stall),
       .clk			(CLK),
       .rst			(ep3_rst),
       //.fetch_data_ready	(ep3_irf_gnt_late),
       //.fetch_data_in	(ep3_irf_read_data),
       .ensemble_mem_gnt	(ep3_xmu_gnt_late),
       .ensemble_mem_ld	(ep3_xmu_read_data));

   
   
   message_block the_mrs(
			 // Outputs
			 .ep0_rs1_data		(ep0_rs1_data[31:0]),
			 .ep0_rs2_data		(ep0_rs2_data[31:0]),
			 .ep1_rs1_data		(ep1_rs1_data[31:0]),
			 .ep1_rs2_data		(ep1_rs2_data[31:0]),
			 .ep2_rs1_data		(ep2_rs1_data[31:0]),
			 .ep2_rs2_data		(ep2_rs2_data[31:0]),
			 .ep3_rs1_data		(ep3_rs1_data[31:0]),
			 .ep3_rs2_data		(ep3_rs2_data[31:0]),
			 .ep0_mr0_empty		(ep0_mr0_empty),
			 .ep0_mr1_empty		(ep0_mr1_empty),
			 .ep0_mr2_empty		(ep0_mr2_empty),
			 .ep0_mr3_empty		(ep0_mr3_empty),
			 .ep0_mr4_empty		(ep0_mr4_empty),
			 .ep0_mr5_empty		(ep0_mr5_empty),
			 .ep0_mr6_empty		(ep0_mr6_empty),
			 .ep0_mr7_empty		(ep0_mr7_empty),
			 .ep1_mr0_empty		(ep1_mr0_empty),
			 .ep1_mr1_empty		(ep1_mr1_empty),
			 .ep1_mr2_empty		(ep1_mr2_empty),
			 .ep1_mr3_empty		(ep1_mr3_empty),
			 .ep1_mr4_empty		(ep1_mr4_empty),
			 .ep1_mr5_empty		(ep1_mr5_empty),
			 .ep1_mr6_empty		(ep1_mr6_empty),
			 .ep1_mr7_empty		(ep1_mr7_empty),
			 .ep2_mr0_empty		(ep2_mr0_empty),
			 .ep2_mr1_empty		(ep2_mr1_empty),
			 .ep2_mr2_empty		(ep2_mr2_empty),
			 .ep2_mr3_empty		(ep2_mr3_empty),
			 .ep2_mr4_empty		(ep2_mr4_empty),
			 .ep2_mr5_empty		(ep2_mr5_empty),
			 .ep2_mr6_empty		(ep2_mr6_empty),
			 .ep2_mr7_empty		(ep2_mr7_empty),
			 .ep3_mr0_empty		(ep3_mr0_empty),
			 .ep3_mr1_empty		(ep3_mr1_empty),
			 .ep3_mr2_empty		(ep3_mr2_empty),
			 .ep3_mr3_empty		(ep3_mr3_empty),
			 .ep3_mr4_empty		(ep3_mr4_empty),
			 .ep3_mr5_empty		(ep3_mr5_empty),
			 .ep3_mr6_empty		(ep3_mr6_empty),
			 .ep3_mr7_empty		(ep3_mr7_empty),
			 .ep0_mr0_full		(ep0_mr0_full),
			 .ep0_mr1_full		(ep0_mr1_full),
			 .ep0_mr2_full		(ep0_mr2_full),
			 .ep0_mr3_full		(ep0_mr3_full),
			 .ep0_mr4_full		(ep0_mr4_full),
			 .ep0_mr5_full		(ep0_mr5_full),
			 .ep0_mr6_full		(ep0_mr6_full),
			 .ep0_mr7_full		(ep0_mr7_full),
			 .ep1_mr0_full		(ep1_mr0_full),
			 .ep1_mr1_full		(ep1_mr1_full),
			 .ep1_mr2_full		(ep1_mr2_full),
			 .ep1_mr3_full		(ep1_mr3_full),
			 .ep1_mr4_full		(ep1_mr4_full),
			 .ep1_mr5_full		(ep1_mr5_full),
			 .ep1_mr6_full		(ep1_mr6_full),
			 .ep1_mr7_full		(ep1_mr7_full),
			 .ep2_mr0_full		(ep2_mr0_full),
			 .ep2_mr1_full		(ep2_mr1_full),
			 .ep2_mr2_full		(ep2_mr2_full),
			 .ep2_mr3_full		(ep2_mr3_full),
			 .ep2_mr4_full		(ep2_mr4_full),
			 .ep2_mr5_full		(ep2_mr5_full),
			 .ep2_mr6_full		(ep2_mr6_full),
			 .ep2_mr7_full		(ep2_mr7_full),
			 .ep3_mr0_full		(ep3_mr0_full),
			 .ep3_mr1_full		(ep3_mr1_full),
			 .ep3_mr2_full		(ep3_mr2_full),
			 .ep3_mr3_full		(ep3_mr3_full),
			 .ep3_mr4_full		(ep3_mr4_full),
			 .ep3_mr5_full		(ep3_mr5_full),
			 .ep3_mr6_full		(ep3_mr6_full),
			 .ep3_mr7_full		(ep3_mr7_full),
			 // Inputs
			 .clk			(CLK),
			 .rst			(ep_rst),
			 .ep0_decode_stall	(ep0_decode_stall),
			 .ep1_decode_stall	(ep1_decode_stall),
			 .ep2_decode_stall	(ep2_decode_stall),
			 .ep3_decode_stall	(ep3_decode_stall),
			 .ep0_rs1_ptr		(ep0_rs1_ptr[2:0]),
			 .ep0_rs1_ptr_valid	(ep0_rs1_ptr_valid),
			 .ep0_rs2_ptr		(ep0_rs2_ptr[2:0]),
			 .ep0_rs2_ptr_valid	(ep0_rs2_ptr_valid),
			 .ep1_rs1_ptr		(ep1_rs1_ptr[2:0]),
			 .ep1_rs1_ptr_valid	(ep1_rs1_ptr_valid),
			 .ep1_rs2_ptr		(ep1_rs2_ptr[2:0]),
			 .ep1_rs2_ptr_valid	(ep1_rs2_ptr_valid),
			 .ep2_rs1_ptr		(ep2_rs1_ptr[2:0]),
			 .ep2_rs1_ptr_valid	(ep2_rs1_ptr_valid),
			 .ep2_rs2_ptr		(ep2_rs2_ptr[2:0]),
			 .ep2_rs2_ptr_valid	(ep2_rs2_ptr_valid),
			 .ep3_rs1_ptr		(ep3_rs1_ptr[2:0]),
			 .ep3_rs1_ptr_valid	(ep3_rs1_ptr_valid),
			 .ep3_rs2_ptr		(ep3_rs2_ptr[2:0]),
			 .ep3_rs2_ptr_valid	(ep3_rs2_ptr_valid),
			 .ep0_alu_rd_ptr	(ep0_alu_rd_ptr[2:0]),
			 .ep0_alu_rd_ptr_valid	(ep0_alu_rd_ptr_valid),
			 .ep0_xmu_rd_ptr	(ep0_xmu_rd_ptr[2:0]),
			 .ep0_xmu_rd_ptr_valid	(ep0_xmu_rd_ptr_valid),
			 .ep1_alu_rd_ptr	(ep1_alu_rd_ptr[2:0]),
			 .ep1_alu_rd_ptr_valid	(ep1_alu_rd_ptr_valid),
			 .ep1_xmu_rd_ptr	(ep1_xmu_rd_ptr[2:0]),
			 .ep1_xmu_rd_ptr_valid	(ep1_xmu_rd_ptr_valid),
			 .ep2_alu_rd_ptr	(ep2_alu_rd_ptr[2:0]),
			 .ep2_alu_rd_ptr_valid	(ep2_alu_rd_ptr_valid),
			 .ep2_xmu_rd_ptr	(ep2_xmu_rd_ptr[2:0]),
			 .ep2_xmu_rd_ptr_valid	(ep2_xmu_rd_ptr_valid),
			 .ep3_alu_rd_ptr	(ep3_alu_rd_ptr[2:0]),
			 .ep3_alu_rd_ptr_valid	(ep3_alu_rd_ptr_valid),
			 .ep3_xmu_rd_ptr	(ep3_xmu_rd_ptr[2:0]),
			 .ep3_xmu_rd_ptr_valid	(ep3_xmu_rd_ptr_valid),
			 .ep0_alu_rd_data	(ep0_alu_rd_data[31:0]),
			 .ep0_xmu_rd_data	(ep0_xmu_rd_data[31:0]),
			 .ep1_alu_rd_data	(ep1_alu_rd_data[31:0]),
			 .ep1_xmu_rd_data	(ep1_xmu_rd_data[31:0]),
			 .ep2_alu_rd_data	(ep2_alu_rd_data[31:0]),
			 .ep2_xmu_rd_data	(ep2_xmu_rd_data[31:0]),
			 .ep3_alu_rd_data	(ep3_alu_rd_data[31:0]),
			 .ep3_xmu_rd_data	(ep3_xmu_rd_data[31:0]));
   

   simd_unit the_simd_box(
			  // Outputs
			  .simd_inst_out	(simd_to_ep_inst[63:0]),
			  .simd_inst_valid	(simd_to_ep_inst_valid),
			  .simd_force_stall (simd_to_ep_force_stall),
			  .ep0_inst_mask        (ep0_inst_mask),
			  .ep1_inst_mask        (ep1_inst_mask),
			  .ep2_inst_mask        (ep2_inst_mask),
			  .ep3_inst_mask        (ep3_inst_mask),
			  // Inputs
			  .CLK			(CLK),
			  .ep0_rst		(ep0_rst),
			  .ep1_rst		(ep1_rst),
			  .ep2_rst		(ep2_rst),
			  .ep3_rst		(ep3_rst),
			  .ep0_inst_in		(ep0_to_simd_inst[63:0]),
			  .ep0_inst_valid	(ep0_to_simd_inst_valid),
			  .ep0_simd_req		(ep0_to_simd_req),
			  .ep0_simd_mine	(ep0_to_simd_mine),
			  .ep0_simd_stall	(ep0_to_simd_simd_stall),
			  .ep1_inst_in		(ep1_to_simd_inst[63:0]),
			  .ep1_inst_valid	(ep1_to_simd_inst_valid),
			  .ep1_simd_req		(ep1_to_simd_req),
			  .ep1_simd_mine	(ep1_to_simd_mine),
			  .ep1_simd_stall	(ep1_to_simd_simd_stall),
			  .ep2_inst_in		(ep2_to_simd_inst[63:0]),
			  .ep2_inst_valid	(ep2_to_simd_inst_valid),
			  .ep2_simd_req		(ep2_to_simd_req),
			  .ep2_simd_mine	(ep2_to_simd_mine),
			  .ep2_simd_stall	(ep2_to_simd_simd_stall),
			  .ep3_inst_in		(ep3_to_simd_inst[63:0]),
			  .ep3_inst_valid	(ep3_to_simd_inst_valid),
			  .ep3_simd_req		(ep3_to_simd_req),
			  .ep3_simd_mine	(ep3_to_simd_mine),
			  .ep3_simd_stall	(ep3_to_simd_simd_stall)
			  );
   
   
   e0_top_level #(.am_i_ens1(am_i_ens1))
   emem0(/**/
		      // Outputs
		      .test_b0_read_data(test_b0_read_data[63:0]),
		      .test_b1_read_data(test_b1_read_data[63:0]),
		      .test_b2_read_data(test_b2_read_data[63:0]),
		      .test_b3_read_data(test_b3_read_data[63:0]),
		      .gated_outgoing_A	(gated_outgoing_A[34:0]),
		      .ungated_outgoing_A(ungated_outgoing_A[4:0]),
		      .gated_outgoing_B	(gated_outgoing_B[34:0]),
		      .ungated_outgoing_B(ungated_outgoing_B[4:0]),
		      .ep0_inbox_read	(ep0_to_mem_box_read),
		      .ep1_inbox_read	(ep1_to_mem_box_read),
		      .ep2_inbox_read	(ep2_to_mem_box_read),
		      .ep3_inbox_read	(ep3_to_mem_box_read),
		      .ep0_outbox	(mem_to_ep0_box[124:0]),
		      .ep1_outbox	(mem_to_ep1_box[124:0]),
		      .ep2_outbox	(mem_to_ep2_box[124:0]),
		      .ep3_outbox	(mem_to_ep3_box[124:0]),
	 //.ep0_irf_read_data(ep0_irf_read_data[63:0]),
	 //.ep1_irf_read_data(ep1_irf_read_data[63:0]),
	 //.ep2_irf_read_data(ep2_irf_read_data[63:0]),
	 //.ep3_irf_read_data(ep3_irf_read_data[63:0]),
	 //.ep0_irf_gnt_late	(ep0_irf_gnt_late),
	 //.ep1_irf_gnt_late	(ep1_irf_gnt_late),
	 //.ep2_irf_gnt_late	(ep2_irf_gnt_late),
	 //.ep3_irf_gnt_late	(ep3_irf_gnt_late),
		      .ep0_xmu_read_data(ep0_xmu_read_data_emem[63:0]),
		      .ep1_xmu_read_data(ep1_xmu_read_data_emem[63:0]),
		      .ep2_xmu_read_data(ep2_xmu_read_data_emem[63:0]),
		      .ep3_xmu_read_data(ep3_xmu_read_data_emem[63:0]),
		      .ep0_xmu_gnt_late	(ep0_xmu_gnt_late_emem),
		      .ep1_xmu_gnt_late	(ep1_xmu_gnt_late_emem),
		      .ep2_xmu_gnt_late	(ep2_xmu_gnt_late_emem),
		      .ep3_xmu_gnt_late	(ep3_xmu_gnt_late_emem),
		      // Inputs
		      .CLK		(CLK),
		      .rst		(mem_rst),
		      .TEST_MODE	(TEST_MODE),
		      .test_b0_csn	(test_b0_csn),
		      .test_b0_addr	(test_b0_addr[7:0]),
		      .test_b0_write_data(test_b0_write_data[63:0]),
		      .test_b0_write_mask(test_b0_write_mask[63:0]),
		      .test_b0_wen_b	(test_b0_wen_b),
		      .test_b1_csn	(test_b1_csn),
		      .test_b1_addr	(test_b1_addr[7:0]),
		      .test_b1_write_data(test_b1_write_data[63:0]),
		      .test_b1_write_mask(test_b1_write_mask[63:0]),
		      .test_b1_wen_b	(test_b1_wen_b),
		      .test_b2_csn	(test_b2_csn),
		      .test_b2_addr	(test_b2_addr[7:0]),
		      .test_b2_write_data(test_b2_write_data[63:0]),
		      .test_b2_write_mask(test_b2_write_mask[63:0]),
		      .test_b2_wen_b	(test_b2_wen_b),
		      .test_b3_csn	(test_b3_csn),
		      .test_b3_addr	(test_b3_addr[7:0]),
		      .test_b3_write_data(test_b3_write_data[63:0]),
		      .test_b3_write_mask(test_b3_write_mask[63:0]),
		      .test_b3_wen_b	(test_b3_wen_b),
		      .gated_incoming_A	(gated_incoming_A[34:0]),
		      .ungated_incoming_A(ungated_incoming_A[4:0]),
		      .gated_incoming_B	(gated_incoming_B[34:0]),
		      .ungated_incoming_B(ungated_incoming_B[4:0]),
		      .ep0_inbox	(ep0_to_mem_box[124:0]),
		      .ep1_inbox	(ep1_to_mem_box[124:0]),
		      .ep2_inbox	(ep2_to_mem_box[124:0]),
		      .ep3_inbox	(ep3_to_mem_box[124:0]),
		      .ep0_outbox_read	(mem_to_ep0_box_read),
		      .ep1_outbox_read	(mem_to_ep1_box_read),
		      .ep2_outbox_read	(mem_to_ep2_box_read),
		      .ep3_outbox_read	(mem_to_ep3_box_read),
	 //.ep0_irf_req	(ep0_irf_req),
	 //.ep0_irf_addr	(ep0_irf_addr[15:0]),
		      .ep0_xmu_req	(ep0_xmu_req_local),
		      .ep0_xmu_addr	(ep0_xmu_addr[15:0]),
		      .ep0_xmu_ld	(ep0_xmu_ld),
		      .ep0_xmu_st	(ep0_xmu_st),
		      .ep0_xmu_write_data(ep0_xmu_write_data[63:0]),
	 //.ep1_irf_req	(ep1_irf_req),
	 //.ep1_irf_addr	(ep1_irf_addr[15:0]),
		      .ep1_xmu_req	(ep1_xmu_req_local),
		      .ep1_xmu_addr	(ep1_xmu_addr[15:0]),
		      .ep1_xmu_ld	(ep1_xmu_ld),
		      .ep1_xmu_st	(ep1_xmu_st),
		      .ep1_xmu_write_data(ep1_xmu_write_data[63:0]),
	 //.ep2_irf_req	(ep2_irf_req),
	 //.ep2_irf_addr	(ep2_irf_addr[15:0]),
		      .ep2_xmu_req	(ep2_xmu_req_local),
		      .ep2_xmu_addr	(ep2_xmu_addr[15:0]),
		      .ep2_xmu_ld	(ep2_xmu_ld),
		      .ep2_xmu_st	(ep2_xmu_st),
		      .ep2_xmu_write_data(ep2_xmu_write_data[63:0]),
	 //.ep3_irf_req	(ep3_irf_req),
	 //.ep3_irf_addr	(ep3_irf_addr[15:0]),
		      .ep3_xmu_req	(ep3_xmu_req_local),
		      .ep3_xmu_addr	(ep3_xmu_addr[15:0]),
		      .ep3_xmu_ld	(ep3_xmu_ld),
		      .ep3_xmu_st	(ep3_xmu_st),
		      .ep3_xmu_write_data(ep3_xmu_write_data[63:0]));
   
   

endmodule // ep_emem


   

//Local Variables:
//verilog-library-directories:("." "/home/charting/tapeouts/rtl/ens_dbs" "/home/charting/tapeouts/rtl/elm_ocm")
//END:
