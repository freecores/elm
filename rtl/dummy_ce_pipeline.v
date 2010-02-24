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

module dummy_ce_pipeline(/*AUTOARG*/
   // Outputs
   fetch_instr_request, fetch_instr_request_addr, xmu_exec_req_mem,
   xmu_exec_ld_ensemble, xmu_exec_st_ensemble, xmu_exec_mem_addr,
   xmu_exec_mem_write, xmu_remote_mem_req, xmu_remote_mem_non_block,
   mem_swap_value, mem_cswap, mem_ldsd, mem_stsd, mem_lds, mem_sts,
   stream_offset, ce_barrier_req, mr_alu_rd_ptr, mr_alu_rd_ptr_valid,
   mr_alu_rd_data, mr_xmu_rd_ptr, mr_xmu_rd_ptr_valid, mr_xmu_rd_data,
   non_block_load_complete, hcf, decode_stall, mr_rs1_ptr,
   mr_rs1_ptr_valid, mr_rs2_ptr, mr_rs2_ptr_valid,
   // Inputs
   clk, rst, mr0_empty, mr0_full, mr1_empty, mr1_full, mr2_empty,
   mr2_full, mr3_empty, mr3_full, mr4_empty, mr4_full, mr5_empty,
   mr5_full, mr6_empty, mr6_full, mr7_empty, mr7_full, mr_rs1_data,
   mr_rs2_data, ensemble_barrier_release, mailbox_full, global_stall,
   fetch_data_ready, fetch_data_in, ensemble_mem_ld, ensemble_mem_gnt
   );

   input clk;
   input rst;

   /* Begin: signals for message registers */
   input mr0_empty;
   input mr0_full;

   input mr1_empty;
   input mr1_full;

   input mr2_empty;
   input mr2_full;

   input mr3_empty;
   input mr3_full;

   input mr4_empty;
   input mr4_full;

   input mr5_empty;
   input mr5_full;
      
   input mr6_empty;
   input mr6_full;

   input mr7_empty;
   input mr7_full;


      
   input [31:0] mr_rs1_data;
   input [31:0] mr_rs2_data;

  
   /* End: signals for the message registers */
   
   
   input ensemble_barrier_release;

   parameter rst_insn = {`X_JFETCH_A_I, 6'd0, 12'd0, 6'd63, 32'd0};
   //output [124:0] ep_to_mem_box;
   //assign 	  ep_to_mem_box = 125'd0;
   //input  ep_to_mem_box_read;
   //input [124:0]  mem_to_ep_box;
   //output 	  mem_to_ep_box_read;
   //assign 	  mem_to_ep_box_read = 1'b0;
   
   input  mailbox_full;
   input  global_stall;


   
   input        fetch_data_ready;
   input [63:0] fetch_data_in;

   //data in from ensemble memory
   input [31:0] ensemble_mem_ld;
   
   input 	ensemble_mem_gnt;
   
   

   output 	fetch_instr_request;
   assign fetch_instr_request = 1'b0;
      
   output [31:0] fetch_instr_request_addr;
   assign fetch_instr_request_addr = 32'd0;
   
   
   output 	 xmu_exec_req_mem;
   assign xmu_exec_req_mem = 1'b0;
      
   output 	 xmu_exec_ld_ensemble;
   assign xmu_exec_ld_ensemble = 1'b0;
      
   output 	 xmu_exec_st_ensemble;
   assign xmu_exec_st_ensemble = 1'b0;
      
   output [31:0] xmu_exec_mem_addr;
   assign xmu_exec_mem_addr = 32'd0;
      
   output [31:0] xmu_exec_mem_write;
   assign xmu_exec_mem_write = 32'd0;
   
   
   output 	 xmu_remote_mem_req;
   assign xmu_remote_mem_req = 1'b0;
      
   output 	 xmu_remote_mem_non_block;
   assign xmu_remote_mem_non_block = 1'b0;
   
   /* swap value for compare and swap */
   output [31:0] mem_swap_value;
   assign mem_swap_value = 32'd0;
   
   
    /* compare and swap */
   output 	 mem_cswap;
   assign mem_cswap = 1'b0;
   
   
   /* load stream descriptor */
   output 	 mem_ldsd ;
   assign mem_ldsd = 1'b0;
   
   output 	 mem_stsd;
   assign mem_stsd = 1'b0;
   
   /* load stream and store stream */
   output 	 mem_lds ;
   assign mem_lds = 1'b0;
      
   output 	 mem_sts;
   assign mem_sts = 1'b0;
      
   output [31:0] stream_offset;
   assign stream_offset = 32'd0;
   
   output 	 ce_barrier_req;
   assign ce_barrier_req = 1'b0;
      
  /* Message register writeback pointers */
   output [2:0]  mr_alu_rd_ptr;
   assign mr_alu_rd_ptr = 2'd0;
      
   output 	 mr_alu_rd_ptr_valid;
   assign mr_alu_rd_ptr_valid = 1'b0;
      
   output [31:0] mr_alu_rd_data;
   assign mr_alu_rd_data = 32'd0;
   
   
   output [2:0]  mr_xmu_rd_ptr;
   assign mr_xmu_rd_ptr = 3'd0;
   
   output 	 mr_xmu_rd_ptr_valid;
   assign mr_xmu_rd_ptr_valid = 1'b0;
   
   output [31:0] mr_xmu_rd_data;
   assign mr_xmu_rd_data = 32'd0;
      
   output 	 non_block_load_complete;
   assign non_block_load_complete = 1'b0;
   
   output 	 hcf;
   assign hcf = 1'b1;
      
   output 	 decode_stall;
   assign decode_stall = 1'b0;
      
   /* Message register read pointers */
   output [2:0] mr_rs1_ptr;
   assign mr_rs1_ptr = 3'd0;
   
   output 	mr_rs1_ptr_valid;
   assign mr_rs1_ptr_valid = 1'b0;
      
   output [2:0] mr_rs2_ptr;
   assign mr_rs2_ptr = 3'd0;
   
   output 	mr_rs2_ptr_valid;
   assign mr_rs2_ptr_valid = 1'b0;
   

endmodule // dummy_ce_pipeline


