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

module xmu_pipeline(/*AUTOARG*/
   // Outputs
   xmu_dec_rs1_out, /*xmu_dec_rs1_out_valid,*/ xmu_if_ex_grf_ptr1,
   xmu_if_ex_grf_ptr2, xmu_if_ex_grf_ptr1_valid,
   xmu_if_ex_grf_ptr2_valid, xmu_if_ex_xp_ptr1, xmu_if_ex_xp_ptr2,
   xmu_if_ex_xp_ptr1_valid, xmu_if_ex_xp_ptr2_valid,
   xmu_if_ex_pr_ptr1, xmu_if_ex_pr_ptr2, xmu_if_ex_pr_r1_valid,
   xmu_if_ex_pr_r2_valid, xmu_if_ex_mr_ptr1, xmu_if_ex_mr_ptr2,
   xmu_if_ex_mr_r1_valid, xmu_if_ex_mr_r2_valid, xmu_exec_instruction,
   xmu_ex_mem_ptr, xmu_ex_mem_valid, xmu_ex_mem_in, xmu_exec_opcode,
   xmu_id_ex_ptr, xmu_id_ex_valid, xmu_grf_wb_valid, xmu_grf_wb_ptr,
   xmu_mr_wb_valid, xmu_mr_wb_ptr, xmu_pr_wb_valid, xmu_pr_wb_ptr,
   xmu_xp_wb_valid, xmu_xp_wb_ptr, xmu_wb_value, xp_store_ptr,
   xp_store_ptr_valid, stop_jfetch, xmu_pred_kill_exec,
   xmu_decode_gen_stall, xmu_exec_gen_stall, xmu_exec_req_mem,
   xmu_exec_ld_ensemble, xmu_exec_st_ensemble, xmu_exec_mem_addr,
   xmu_exec_mem_write, xmu_exec_lo, xmu_exec_hi, st_rd_from_xprf,
   remote_mem_op, remote_mem_not_block, xmu_exec_cswap,
   xmu_exec_swap_value, xmu_exec_ldsd, xmu_exec_stsd,
   xmu_exec_ldstream, xmu_exec_ststream, xmu_exec_offset_value,
   xmu_wb_nonblock_load, xmu_barrier, xmu_exec_hcf,
   // Inputs
   clk, rst, stall_decode, stall_exec, stall_wb, link_reg,
   xmu_ensemble_ld_in, ensemble_gnt, xmu_if_id_instruction,
   xp_store_data, branch_pr, alu_ex_mem_ptr, alu_ex_mem_valid,
   alu_wb_valid, alu_ex_mem_in, alu_id_ex_valid, alu_id_ex_ptr,
   grf_r1_in, grf_r1_in_valid, grf_r2_in, grf_r2_in_valid,
   xp_grf_ptr1, xp_grf_ptr2, xp_grf_ptr1_valid, xp_grf_ptr2_valid,
   xp_grf_rd_ptr, xp_grf_rd_ptr_valid, mr0_full, mr1_full, mr2_full,
   mr3_full, mr4_full, mr5_full, mr6_full, mr7_full, pr_r1_in,
   pr_r1_in_valid, pr_r2_in, pr_r2_in_valid, mr_r1_in, mr_r1_in_valid,
   mr_r2_in, mr_r2_in_valid
   );
  
   input clk;
   input rst;

   input stall_decode;
   input stall_exec;
   input stall_wb;

   input [5:0] link_reg;
   
   output [31:0] xmu_dec_rs1_out;
   /*output 	 xmu_dec_rs1_out_valid;*/
   

   
   input [31:0] xmu_ensemble_ld_in;
   input 	ensemble_gnt;
   

   input [31:0] xmu_if_id_instruction;

   output [4:0] xmu_if_ex_grf_ptr1;
   output [4:0] xmu_if_ex_grf_ptr2;

   output 	xmu_if_ex_grf_ptr1_valid;
   output 	xmu_if_ex_grf_ptr2_valid;

   output [1:0] xmu_if_ex_xp_ptr1;
   output [1:0] xmu_if_ex_xp_ptr2; 

   output 	xmu_if_ex_xp_ptr1_valid;
   output 	xmu_if_ex_xp_ptr2_valid; 

   output [2:0] xmu_if_ex_pr_ptr1;
   output [2:0] xmu_if_ex_pr_ptr2;  
 
   output 	xmu_if_ex_pr_r1_valid;
   output 	xmu_if_ex_pr_r2_valid;

   output [2:0] xmu_if_ex_mr_ptr1;
   output [2:0] xmu_if_ex_mr_ptr2;

   output 	xmu_if_ex_mr_r1_valid;
   output 	xmu_if_ex_mr_r2_valid;

   output [34:0] xmu_exec_instruction;
   
      
   output [6:0] xmu_ex_mem_ptr;
   wire [6:0] 	w_xmu_ex_mem_ptr;

   assign xmu_ex_mem_ptr = w_xmu_ex_mem_ptr;
      
   output 	xmu_ex_mem_valid;
   wire 	w_xmu_ex_mem_valid;

   assign xmu_ex_mem_valid = w_xmu_ex_mem_valid;
      
   output [31:0] xmu_ex_mem_in;
   output [7:0]  xmu_exec_opcode;
   wire [7:0] 	 w_xmu_exec_opcode;

   assign xmu_exec_opcode=  w_xmu_exec_opcode;
   
   
   
   wire [31:0] 	 w_xmu_ex_mem_in;

   assign xmu_ex_mem_in = w_xmu_ex_mem_in;
      
 
   output [6:0]  xmu_id_ex_ptr;
   output 	 xmu_id_ex_valid;



   output 	 xmu_grf_wb_valid;
   output [4:0]  xmu_grf_wb_ptr;
   
   output 	 xmu_mr_wb_valid;
   output [2:0]  xmu_mr_wb_ptr;
   
   output 	 xmu_pr_wb_valid;
   output [2:0]  xmu_pr_wb_ptr;
   
   output 	 xmu_xp_wb_valid;
   output [1:0]  xmu_xp_wb_ptr;

   output [31:0] xmu_wb_value;

   output [2:0]  xp_store_ptr;
   output 	 xp_store_ptr_valid;
   input [31:0]  xp_store_data;

   output 	 stop_jfetch;
      
   wire [2:0] 	 w_xp_store_ptr;
   wire 	 w_xp_store_ptr_valid;
   wire [31:0]	 w_xp_store_data = xp_store_data;
   assign xp_store_ptr = w_xp_store_ptr;
   assign xp_store_ptr_valid = w_xp_store_ptr_valid;
   
   
   //xmu exec predicate
   output 	 xmu_pred_kill_exec;
      
   output 	 xmu_decode_gen_stall;
   wire 	 w_xmu_decode_gen_stall; 
   output 	 xmu_exec_gen_stall;

   output 	 xmu_exec_req_mem;
   output 	 xmu_exec_ld_ensemble;
   output 	 xmu_exec_st_ensemble;
   output [31:0] xmu_exec_mem_addr;
   output [31:0] xmu_exec_mem_write;

   output 	 xmu_exec_lo;
   output 	 xmu_exec_hi;
   
   output 	 st_rd_from_xprf;

   output 	 remote_mem_op;
   output 	 remote_mem_not_block;


   output 	 xmu_exec_cswap;
   wire 	 w_xmu_exec_cswap;

   output [31:0] xmu_exec_swap_value;
   wire [31:0] 	 w_xmu_exec_swap_value;

   output 	 xmu_exec_ldsd;
   output 	 xmu_exec_stsd;

   wire 	 w_xmu_exec_ldsd;
   wire 	 w_xmu_exec_stsd;

   output 	 xmu_exec_ldstream;
   output 	 xmu_exec_ststream;

   output [31:0] xmu_exec_offset_value;

   output 	 xmu_wb_nonblock_load;

   
   assign xmu_exec_ldsd = w_xmu_exec_ldsd;
   assign xmu_exec_stsd = w_xmu_exec_stsd;
      

   assign xmu_exec_swap_value = w_xmu_exec_swap_value;
      
   assign xmu_exec_cswap = w_xmu_exec_cswap;

   wire 	 w_xmu_exec_gen_stall;
      
   assign xmu_exec_gen_stall = w_xmu_exec_gen_stall;
      
   assign xmu_decode_gen_stall = w_xmu_decode_gen_stall;
   
   
   //result of loop predicate operation
   input [31:0]  branch_pr;
   
   

   //forwarding network signalz
   input [6:0] 	 alu_ex_mem_ptr;
   input 	 alu_ex_mem_valid;
   input 	 alu_wb_valid;
   input [31:0]  alu_ex_mem_in;


   input 	 alu_id_ex_valid;
   input [6:0] 	 alu_id_ex_ptr;

   input [31:0]  grf_r1_in;
   input 	 grf_r1_in_valid;

   input [31:0]  grf_r2_in;
   input 	 grf_r2_in_valid;

   input [4:0] 	 xp_grf_ptr1;
   input [4:0] 	 xp_grf_ptr2;

   input 	 xp_grf_ptr1_valid;
   input 	 xp_grf_ptr2_valid;


   input [4:0] 	 xp_grf_rd_ptr;
   input 	 xp_grf_rd_ptr_valid;


   input 	 mr0_full;
   input 	 mr1_full;
   input 	 mr2_full;
   input 	 mr3_full;
   input 	 mr4_full;
   input 	 mr5_full;
   input 	 mr6_full;
   input 	 mr7_full;
      

   input [8:0] 	 pr_r1_in;
   input 	 pr_r1_in_valid;
   
   input [8:0] 	 pr_r2_in;
   input 	 pr_r2_in_valid;
   
   input [31:0]  mr_r1_in;
   input 	 mr_r1_in_valid;

   input [31:0]  mr_r2_in;
   input 	 mr_r2_in_valid;


   
   //signals to be registered 
   wire [34:0] 	 id_ex_instruction;
   wire [31:0] 	 id_ex_rs1_out;
   wire [31:0] 	 id_ex_rs2_out;
   wire 	 if_ex_rs1_out_valid;
   wire 	 if_ex_rs2_out_valid;
   
   //state for pipeline latches
   reg [34:0] 	r_id_ex_instruction;
   reg 		r_id_ex_valid;
   
   reg [31:0] 	r_id_ex_rs1_out;
   reg [31:0] 	r_id_ex_rs2_out;
   reg 		r_id_ex_rs1_out_valid;
   reg 		r_id_ex_rs2_out_valid;


   //address register file signals
   wire [1:0] 	orf_read_ptr1;
   wire [1:0] 	orf_read_ptr2;
   wire 	orf_read_ptr1_valid;
   wire 	orf_read_ptr2_valid;
   wire [31:0] 	orf_read_ptr1_out;
   wire [31:0] 	orf_read_ptr2_out;


   wire [31:0] ex_mem_result;
   wire [34:0] ex_mem_instruction;
   
   
   //exec / wb latches
   reg [34:0]  r_ex_mem_instruction;
   reg [31:0]  r_ex_mem_result;
   reg 	       r_ex_mem_valid;
   
   wire [6:0] w_xmu_id_ex_ptr = r_id_ex_instruction[20:14];

   wire xmu_zero;
   wire xmu_carry;
   wire xmu_sign;
   wire xmu_overflow;

   reg 	r_xmu_zero, r_xmu_carry, r_xmu_sign, r_xmu_overflow;


   wire [6:0] w_xmu_dec_strest_ptr;
   wire [31:0] arf_strest_value;
   
   output     xmu_barrier;
   output     xmu_exec_hcf;

   wire       w_xmu_exec_hcf;

   assign xmu_exec_hcf = w_xmu_exec_hcf;
   
   
   wire       w_xmu_exec_barrier;

   assign xmu_barrier = w_xmu_exec_barrier;
    
   assign xmu_dec_rs1_out = id_ex_rs1_out;
   /*assign xmu_dec_rs1_out_valid = if_ex_rs1_out_valid;*/
   wire       w_stop_jfetch;
   assign stop_jfetch = w_stop_jfetch;
   
   xmu_decode xdec(
		   // Outputs
		   .xmu_decode_instr_out(id_ex_instruction),
		   .rs1_out		(id_ex_rs1_out),
		   .rs2_out		(id_ex_rs2_out),
		   .rs1_out_valid	(if_ex_rs1_out_valid),
		   .rs2_out_valid	(if_ex_rs2_out_valid),
		   .xmu_decode_gen_stall(w_xmu_decode_gen_stall),

		   .xmu_dec_strest_ptr  (w_xmu_dec_strest_ptr),
		   
		   .grf_ptr1		(xmu_if_ex_grf_ptr1),
		   .grf_ptr2		(xmu_if_ex_grf_ptr2),
		   .grf_ptr1_valid	(xmu_if_ex_grf_ptr1_valid),
		   .grf_ptr2_valid	(xmu_if_ex_grf_ptr2_valid),
		   
		   .xp_ptr1		(xmu_if_ex_xp_ptr1),
		   .xp_ptr2		(xmu_if_ex_xp_ptr2),
		   .xp_ptr1_valid	(xmu_if_ex_xp_ptr1_valid),
		   .xp_ptr2_valid	(xmu_if_ex_xp_ptr2_valid),
		   
		   .pr_ptr1		(xmu_if_ex_pr_ptr1),
		   .pr_ptr2		(xmu_if_ex_pr_ptr2),
		   .pr_r1_valid		(xmu_if_ex_pr_r1_valid),
		   .pr_r2_valid		(xmu_if_ex_pr_r2_valid),
		   
		   .mr_ptr1		(xmu_if_ex_mr_ptr1),
		   .mr_ptr2		(xmu_if_ex_mr_ptr2),
		   .mr_r1_valid		(xmu_if_ex_mr_r1_valid),
		   .mr_r2_valid		(xmu_if_ex_mr_r2_valid),


		   .xp_rd_valid         (xmu_xp_wb_valid),
		   .xp_rd_ptr           (xmu_xp_wb_ptr),
		   .stop_the_jfetch (w_stop_jfetch),
		   
		   .st_rd_from_xprf     (st_rd_from_xprf),
		   .xp_store_ptr (w_xp_store_ptr),
		   .xp_store_ptr_valid (w_xp_store_ptr_valid),
		   
		   // Inputs
		   .instr_in		(xmu_if_id_instruction),
                   .xmu_exec_opcode     (w_xmu_exec_opcode),
		   //forwarding network
		   .alu_ex_mem_ptr	(alu_ex_mem_ptr),
		   .alu_ex_mem_valid	(alu_ex_mem_valid),
		   .alu_ex_mem_in	(alu_ex_mem_in),
		   
		   .xmu_ex_mem_ptr	(w_xmu_ex_mem_ptr),
		   .xmu_ex_mem_valid	(w_xmu_ex_mem_valid),
		   .xmu_ex_mem_in	(w_xmu_ex_mem_in),
		   
		   .alu_id_ex_ptr	(alu_id_ex_ptr),
		   .alu_id_ex_valid	(alu_id_ex_valid),


		   .link_reg            (link_reg),
		   .arf_strest_value    (arf_strest_value),
		   
		   //signals changed to avoid reading from outputs
		   .xmu_id_ex_ptr	(w_xmu_id_ex_ptr),
		   .xmu_id_ex_valid	(r_id_ex_valid),
		   .xp_store_data (w_xp_store_data),
		   
		   .grf_r1_in		(grf_r1_in),
		   .grf_r2_in		(grf_r2_in),
		   .grf_r1_in_valid	(grf_r1_in_valid),
		   .grf_r2_in_valid	(grf_r2_in_valid),

		   .xp_grf_ptr1         (xp_grf_ptr1),
		   .xp_grf_ptr2         (xp_grf_ptr2),
		   .xp_grf_ptr1_valid   (xp_grf_ptr1_valid),
		   .xp_grf_ptr2_valid   (xp_grf_ptr2_valid),

		   .xp_grf_rd_ptr       (xp_grf_rd_ptr),
		   .xp_grf_rd_ptr_valid (xp_grf_rd_ptr_valid),
		   		   
		   .pr_r1_in		(pr_r1_in),
		   .pr_r2_in		(pr_r2_in),
		   .pr_r1_in_valid	(pr_r1_in_valid),
		   .pr_r2_in_valid	(pr_r2_in_valid),
		   .branch_pr           (branch_pr),
		   
		   .mr_r1_in		(mr_r1_in),
		   .mr_r2_in		(mr_r2_in),
		   .mr_r1_in_valid	(mr_r1_in_valid),
		   .mr_r2_in_valid	(mr_r2_in_valid)


		   );
   
   assign w_xmu_exec_opcode = r_id_ex_instruction[34:27];
   
   wire [7:0] w_xmu_dec_opcode = id_ex_instruction[34:27];
   
   wire       dec_is_st = 
	      (w_xmu_dec_opcode == `X_ST_I) |
	      (w_xmu_dec_opcode == `X_ST_IR) |
	      (w_xmu_dec_opcode == `X_ST_RR) |
	      (w_xmu_dec_opcode == `X_RB_ST_I) |
	      (w_xmu_dec_opcode == `X_RB_ST_IR) |
	      (w_xmu_dec_opcode == `X_RB_ST_RR);
   

   
   always@(posedge clk or posedge rst)
     begin: xmu_id_ex_latch
	if(rst)
	  begin
	     r_id_ex_instruction <= 35'd0;
	     r_id_ex_valid <= 1'b0;
	     r_id_ex_rs1_out <= 32'd0;
	     r_id_ex_rs2_out <= 32'd0;
	     r_id_ex_rs1_out_valid <= 1'b0;
	     r_id_ex_rs2_out_valid <= 1'b0;
	  end
	else
	  begin
	     r_id_ex_instruction <= stall_exec ? 
				    r_id_ex_instruction : 
				    stall_decode ?
				    35'd0 :
				    id_ex_instruction;
	     
				   
	     r_id_ex_valid <= stall_exec ? 
			      r_id_ex_valid :
			      stall_decode ?
			       1'b0 :
			      dec_is_st ?
			      1'b0 :
			      !w_xmu_decode_gen_stall;
	     
	     r_id_ex_rs1_out <= stall_exec ?
				r_id_ex_rs1_out :
				stall_decode ?
				32'd0 :
				id_ex_rs1_out;
	     
	     r_id_ex_rs2_out <= stall_exec ?
				r_id_ex_rs2_out :
				stall_decode ?
				32'd0 :
				id_ex_rs2_out;
	    
	     r_id_ex_rs1_out_valid <= stall_exec ?
				      r_id_ex_rs1_out_valid :
				      stall_decode ?
				      1'b0 :
				      if_ex_rs1_out_valid;
	     
	     r_id_ex_rs2_out_valid <= stall_exec ?
				      r_id_ex_rs2_out_valid :
				      stall_decode ?
				      1'b0 :
				      if_ex_rs2_out_valid;
	  end
     end
    
   assign xmu_id_ex_ptr =   r_id_ex_instruction[20:14];
   assign xmu_id_ex_valid = r_id_ex_valid & 
			    (r_id_ex_instruction[34:27] != `X_MOVI);



 


   assign xmu_exec_instruction = r_id_ex_instruction;

   wire        w_xmu_exec_req_mem;
   wire        w_xmu_exec_ld_ensemble;
   wire        w_xmu_exec_st_ensemble;
   wire [31:0] w_xmu_exec_mem_addr;

   
   
   wire        w_xmu_exec_hi;
   wire        w_xmu_exec_lo;

   reg 	       r_xmu_exec_hi;
   reg 	       r_xmu_exec_lo;
   
   assign xmu_exec_hi = r_xmu_exec_hi;
   assign xmu_exec_lo = r_xmu_exec_lo;
      
   assign xmu_exec_req_mem = w_xmu_exec_req_mem;
   assign xmu_exec_ld_ensemble = w_xmu_exec_ld_ensemble;
   assign xmu_exec_st_ensemble = w_xmu_exec_st_ensemble;
   assign xmu_exec_mem_addr = w_xmu_exec_mem_addr;
   
   assign xmu_exec_mem_write = ex_mem_result; //rch todo: should 
   
   //value from asr
   wire [31:0] xmu_asr_ptr1_out;
   wire [31:0] xmu_asr_ptr2_out;

   //asr read pointers
   wire [1:0]  xmu_asr_ptr1;
   wire [1:0]  xmu_asr_ptr2;

   //asr req 
   wire        xmu_asr_ptr1_req;
   wire        xmu_asr_ptr2_req;

   wire        w_xmu_exec_ldstream;
   wire        w_xmu_exec_ststream;

   wire        w_xmu_exec_nb_load;
   
   
   wire [31:0] w_xmu_exec_offset_value;

   assign xmu_exec_ldstream = w_xmu_exec_ldstream;
   assign xmu_exec_ststream = w_xmu_exec_ststream;
   assign xmu_exec_offset_value = w_xmu_exec_req_mem ? w_xmu_exec_offset_value : 32'd0;
         
   xmu_exec xexec (
		   // Outputs
		   .xmu_exec_instr_out	(ex_mem_instruction),
		   .orf_ptr1		(orf_read_ptr1),
		   .orf_ptr1_valid	(orf_read_ptr1_valid),
		   .orf_ptr2		(orf_read_ptr2),
		   .orf_ptr2_valid	(orf_read_ptr2_valid),
		   .xmu_exec_hcf        (w_xmu_exec_hcf),
		   .xmu_exec_barrier    (w_xmu_exec_barrier),
		   .xmu_exec_cswap      (w_xmu_exec_cswap),
		   .xmu_exec_swap_value (w_xmu_exec_swap_value),
		   
		   .xmu_kill_alu_exec   (xmu_pred_kill_exec),
		   .xmu_exec_rd_out	(ex_mem_result),

		   //ensemble memory interface
		   .xmu_exec_req_mem	(w_xmu_exec_req_mem),
		   .xmu_exec_ld_ensemble(w_xmu_exec_ld_ensemble),
		   .xmu_exec_st_ensemble(w_xmu_exec_st_ensemble),
		   .xmu_exec_mem_addr	(w_xmu_exec_mem_addr),

		   .xmu_exec_hi(w_xmu_exec_hi),
		   .xmu_exec_lo(w_xmu_exec_lo),

		   .xmu_exec_ldsd  (w_xmu_exec_ldsd),
		   .xmu_exec_stsd  (w_xmu_exec_stsd),

		   .xmu_exec_ldstream (w_xmu_exec_ldstream),
		   .xmu_exec_ststream (w_xmu_exec_ststream),

		   .xmu_exec_offset_value (w_xmu_exec_offset_value),
		   
		   .xmu_zero (xmu_zero),
		   .xmu_carry (xmu_carry),
		   .xmu_sign (xmu_sign),
		   .xmu_overflow (xmu_overflow),
		   .remote_mem_op       (remote_mem_op),
		   .remote_mem_not_block (remote_mem_not_block),

		   .xmu_asr_ptr1        (xmu_asr_ptr1),
		   .xmu_asr_ptr2        (xmu_asr_ptr2),
		   .xmu_asr_ptr1_req    (xmu_asr_ptr1_req),
		   .xmu_asr_ptr2_req    (xmu_asr_ptr2_req),
		   //.xmu_exec_hcf   (w_xmu_exec_hcf),
		   .xmu_exec_stall (w_xmu_exec_gen_stall),
		   .xmu_exec_nonblock_load (w_xmu_exec_nb_load),
		   
		   // Inputs
		   .mr0_full  (mr0_full),
		   .mr1_full  (mr1_full),
		   .mr2_full  (mr2_full),
		   .mr3_full  (mr3_full),
		   .mr4_full  (mr4_full),
		   .mr5_full  (mr5_full),
		   .mr6_full  (mr6_full),
		   .mr7_full  (mr7_full),

		   
		   .xmu_exec_instr_in	(r_id_ex_instruction),
		   
		   .prev_xmu_sign	(r_xmu_sign),
		   .prev_xmu_carry	(r_xmu_carry),
		   .prev_xmu_overflow	(r_xmu_overflow),
		   .prev_xmu_zero	(r_xmu_zero),
		   
		   .rs1_in		(r_id_ex_rs1_out),
		   .rs2_in		(r_id_ex_rs2_out),
		   .rs1_in_valid	(r_id_ex_rs1_out_valid),
		   .rs2_in_valid	(r_id_ex_rs2_out_valid),

		   //this comes from alu pipeline
		   .alu_ex_mem_ptr	(alu_ex_mem_ptr),
		   .alu_ex_mem_valid	(alu_ex_mem_valid),
		   .alu_ex_mem_in	(alu_ex_mem_in),
		   
		   //registered output of this stage
		   .xmu_ex_mem_ptr	(w_xmu_ex_mem_ptr),
		   .xmu_ex_mem_valid	(w_xmu_ex_mem_valid),
		   .xmu_ex_mem_in	(w_xmu_ex_mem_in),
		   
		   .orf_ptr1_in		(orf_read_ptr1_out),
		   .orf_ptr2_in		(orf_read_ptr2_out),

		   .xmu_asr_ptr1_out    (xmu_asr_ptr1_out),
		   .xmu_asr_ptr2_out    (xmu_asr_ptr2_out)
		   );
   
   
   wire       exec_is_st = 
	      (w_xmu_exec_opcode == `X_ST_I) |
	      (w_xmu_exec_opcode == `X_ST_IR) |
	      (w_xmu_exec_opcode == `X_ST_RR) |
   	      (w_xmu_exec_opcode == `X_RB_ST_I) |
	      (w_xmu_exec_opcode == `X_RB_ST_IR) |
	      (w_xmu_exec_opcode == `X_RB_ST_RR) |
	      (w_xmu_exec_opcode == `X_RNB_ST_I) |
	      (w_xmu_exec_opcode == `X_RNB_ST_IR) |
	      (w_xmu_exec_opcode == `X_RNB_ST_RR) |
	      (w_xmu_exec_opcode == `X_LDSD_RI) |
	      (w_xmu_exec_opcode == `X_LDSD_RR) |
	      (w_xmu_exec_opcode == `X_STSD_RI) |
	      (w_xmu_exec_opcode == `X_STSD_RR) |
	      (w_xmu_exec_opcode == `X_LDSTREAM) |
	      (w_xmu_exec_opcode == `X_STSAVE_LO_I) |
	      (w_xmu_exec_opcode == `X_STSAVE_HI_I) |
	      (w_xmu_exec_opcode == `X_STSAVE_LO_IR) |
	      (w_xmu_exec_opcode == `X_STSAVE_HI_IR) |
	      (w_xmu_exec_opcode == `X_STSTREAM);
   

   reg 	      r_ex_mem_non_block_load;
   assign xmu_wb_nonblock_load = r_ex_mem_non_block_load;
   
   
   always@(posedge clk or posedge rst)
     begin: xmu_ex_mem_latch
	if(rst)
	  begin
	     r_xmu_zero <= 1'b0;
	     r_xmu_carry <= 1'b0;
	     r_xmu_sign <= 1'b0;
	     r_xmu_overflow <= 1'b0;
	     	     
	     r_xmu_exec_lo <= 1'b0;
	     r_xmu_exec_hi <= 1'b0;
	     
	     r_ex_mem_instruction <= 35'd0;
	     r_ex_mem_result <= 32'd0;
	     r_ex_mem_valid <= 1'b1;

	     r_ex_mem_non_block_load <= 1'b0;
	  end
	else
	  begin
	     r_ex_mem_non_block_load <= stall_wb ?
					r_ex_mem_non_block_load :
					stall_exec ?
					1'b0 :
					w_xmu_exec_nb_load;
	     
	     r_xmu_exec_lo <= stall_wb ?
			      r_xmu_exec_lo :
			      stall_exec ?
			      1'b0 :
			      w_xmu_exec_lo;


	     r_xmu_exec_hi <= stall_wb ?
			      r_xmu_exec_hi :
			      stall_exec ?
			      1'b0 :
			      w_xmu_exec_hi;
	     
	     
	     r_ex_mem_instruction <= stall_wb ? 
				     r_ex_mem_instruction :
				     stall_exec ?
				     35'd0: 
				     ex_mem_instruction;
	     
	     //predicate kill keeps old tr0 value
	     r_ex_mem_result <= stall_wb ?
				r_ex_mem_result :
				stall_exec ?
				32'd0 :
				ex_mem_result;

	     //predicate invalidates result
	     r_ex_mem_valid <= stall_wb ? 
			       r_ex_mem_valid :
			       stall_exec ?
			       1'b0 :
			       exec_is_st ?
			       1'b0 :
			       1'b1;

	     r_xmu_zero <= stall_wb ?
			   r_xmu_zero :
			   stall_exec ?
			   1'b1 :
			   xmu_zero;
	     
	     r_xmu_carry <= stall_wb ?
			    r_xmu_carry :
			    stall_exec ?
			    1'b0 :
			    xmu_carry;
	     
	     r_xmu_sign <= stall_wb ?
			   r_xmu_sign :
			   stall_exec ?
			   1'b0 :
			   xmu_sign;
	     
	     r_xmu_overflow <= stall_wb ?
			       r_xmu_overflow :
			       stall_exec ?
			       1'b0 :
			       xmu_overflow;
	     
	  end
     end
   //xmu_ensemble_ld_in
   wire [7:0] xmu_wb_opcode = r_ex_mem_instruction[34:27];	

    wire       is_load =
	       (xmu_wb_opcode == `X_LD_I) |
	       (xmu_wb_opcode == `X_LD_IR) |
	       (xmu_wb_opcode == `X_LD_RR) |
	       (xmu_wb_opcode == `X_LDREST_LO_I) |
   	       (xmu_wb_opcode == `X_LDREST_LO_IR) |
	       (xmu_wb_opcode == `X_LDREST_HI_I) |
   	       (xmu_wb_opcode == `X_LDREST_HI_IR) |
	       (xmu_wb_opcode == `X_RB_LD_I) |
	       (xmu_wb_opcode == `X_RB_LD_IR) |
	       (xmu_wb_opcode == `X_RB_LD_RR) |
	       (xmu_wb_opcode == `X_CMPSWP);
   
   
	       

   wire [31:0] w_xmu_wb_value = is_load ? xmu_ensemble_ld_in :
			 r_ex_mem_result;
   
   assign xmu_wb_value = w_xmu_wb_value;
   
   /*
   assign w_xmu_ex_mem_valid = is_load ? ensemble_gnt :  
			       r_ex_mem_valid & 
			       (r_ex_mem_instruction[34:27] != `X_MOVI);
   */

   wire is_nb_load = 	  
	(xmu_wb_opcode == `X_RNB_LD_I) |
	(xmu_wb_opcode == `X_RNB_LD_IR) |
	(xmu_wb_opcode == `X_RNB_LD_RR);
   

   assign w_xmu_ex_mem_valid = is_load ? ensemble_gnt : 
			       is_nb_load ? 1'b0 :
			       r_ex_mem_valid;
   
   
   assign w_xmu_ex_mem_in = w_xmu_wb_value;
   assign w_xmu_ex_mem_ptr =  r_ex_mem_instruction[20:14];
   
   xmu_writeback xwb(
		     // Outputs
		     .grf_wb_valid	(xmu_grf_wb_valid),
		     .grf_wb_ptr	(xmu_grf_wb_ptr),
		     .mr_wb_valid	(xmu_mr_wb_valid),
		     .mr_wb_ptr		(xmu_mr_wb_ptr),
		     .pr_wb_valid	(xmu_pr_wb_valid),
		     .pr_wb_ptr		(xmu_pr_wb_ptr),
		     // Inputs
		     .rd_ptr		(w_xmu_ex_mem_ptr),
		     .rd_valid		(w_xmu_ex_mem_valid),
		     .ld_invalidate     (xmu_wb_nonblock_load)
		     );

   wire        orf_write_ptr_valid = 
	       ({w_xmu_ex_mem_ptr[6:2],2'b00} ==  `AR0) & 
	       w_xmu_ex_mem_valid;

   wire [1:0]  orf_write_ptr = w_xmu_ex_mem_ptr[1:0];

   
   xmu_orf xorf(
		// Outputs
		.orf_read_ptr1_out	(orf_read_ptr1_out),
		.orf_read_ptr2_out	(orf_read_ptr2_out),
		// Inputs
		.clk			(clk),
		.rst			(rst),
		.orf_read_ptr1		(orf_read_ptr1),
		.orf_read_ptr1_valid	(orf_read_ptr1_valid),
		.orf_read_ptr2		(orf_read_ptr2),
		.orf_read_ptr2_valid	(orf_read_ptr2_valid),



		
		//write orf signals
		.orf_write_ptr		(orf_write_ptr),
		.orf_write_ptr_valid	(orf_write_ptr_valid),
		.orf_write_value	(w_xmu_wb_value),


		.alu_ex_mem_ptr         (alu_ex_mem_ptr),
		.alu_ex_mem_in          (alu_ex_mem_in),
		.alu_ex_mem_valid       (alu_wb_valid)


		
		);




   
   asr_rf xasr(
	       // Outputs
	       .xmu_read_ptr1_data	(xmu_asr_ptr1_out),
	       .xmu_read_ptr2_data	(xmu_asr_ptr2_out),

	       .xmu_strest_data         (arf_strest_value),
	       // Inputs
	       .clk			(clk),
	       .rst			(rst),

	       .xmu_strest_ptr          (w_xmu_dec_strest_ptr),
	       
	       .xmu_read_req_ptr1	(xmu_asr_ptr1),
	       .xmu_read_r1_req		(xmu_asr_ptr1_req),
	       .xmu_read_req_ptr2	(xmu_asr_ptr2),
	       .xmu_read_r2_req		(xmu_asr_ptr2_req),
	      
	       .stall_exec		(stall_exec),

	       .alu_md_write_port	(alu_ex_mem_in),
	       .alu_md_ptr		(alu_ex_mem_ptr),
	       .alu_md_valid		(alu_wb_valid),
	     
	       .xmu_md_write_port	(w_xmu_ex_mem_in),
	       .xmu_md_ptr		(w_xmu_ex_mem_ptr),
	       .xmu_md_valid		(w_xmu_ex_mem_valid)
	       );
   



   
endmodule 
