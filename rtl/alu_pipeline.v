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

module alu_pipeline(/*AUTOARG*/
   // Outputs
   alu_if_ex_grf_ptr1, alu_if_ex_grf_ptr2, alu_if_ex_grf_ptr1_valid,
   alu_if_ex_grf_ptr2_valid, alu_if_ex_xp_ptr1, alu_if_ex_xp_ptr2,
   alu_if_ex_xp_ptr1_valid, alu_if_ex_xp_ptr2_valid,
   alu_if_ex_pr_ptr1, alu_if_ex_pr_ptr2, alu_if_ex_pr_r1_valid,
   alu_if_ex_pr_r2_valid, alu_if_ex_mr_ptr1, alu_if_ex_mr_ptr2,
   alu_if_ex_mr_r1_valid, alu_if_ex_mr_r2_valid, alu_decode_gen_stall,
   alu_exec_gen_stall, alu_ex_mem_ptr, alu_ex_mem_valid,
   alu_ex_mem_in, alu_id_ex_ptr, alu_id_ex_valid, alu_grf_wb_valid,
   alu_grf_wb_ptr, alu_mr_wb_valid, alu_mr_wb_ptr, alu_pr_wb_valid,
   alu_pr_wb_ptr, alu_xp_wb_valid, alu_xp_wb_ptr, alu_wb_value,
   alu_wb_instruction, alu_wb_valid, alu_accum_stall,
   // Inputs
   clk, rst, link_reg, alu_if_id_instruction, xmu_pred_kill_exec,
   xmu_ex_mem_ptr, xmu_ex_mem_valid, xmu_ex_mem_in, xmu_id_ex_valid,
   xmu_id_ex_ptr, grf_r1_in, grf_r1_in_valid, grf_r2_in,
   grf_r2_in_valid, xp_grf_ptr1, xp_grf_ptr2, xp_grf_ptr1_valid,
   xp_grf_ptr2_valid, xp_grf_rd_ptr, xp_grf_rd_ptr_valid, pr_r1_in,
   pr_r1_in_valid, pr_r2_in, pr_r2_in_valid, mr_r1_in, mr_r1_in_valid,
   mr_r2_in, mr_r2_in_valid, mr0_full, mr1_full, mr2_full, mr3_full,
   mr4_full, mr5_full, mr6_full, mr7_full, stall_decode, stall_exec,
   stall_wb, xmu_exec_opcode
   );

   input clk;
   input rst;
   
   input [5:0] link_reg;
   
   
   //instruction fetch / decode instruction
   input [31:0] alu_if_id_instruction;

   output [4:0] alu_if_ex_grf_ptr1;
   output [4:0] alu_if_ex_grf_ptr2;

   output 	alu_if_ex_grf_ptr1_valid;
   output 	alu_if_ex_grf_ptr2_valid;

   output [1:0] alu_if_ex_xp_ptr1;
   output [1:0] alu_if_ex_xp_ptr2; 

   output 	alu_if_ex_xp_ptr1_valid;
   output 	alu_if_ex_xp_ptr2_valid; 

   output [2:0] alu_if_ex_pr_ptr1;
   output [2:0] alu_if_ex_pr_ptr2;  
 
   output 	alu_if_ex_pr_r1_valid;
   output 	alu_if_ex_pr_r2_valid;

   output [2:0] alu_if_ex_mr_ptr1;
   output [2:0] alu_if_ex_mr_ptr2;

   output 	alu_if_ex_mr_r1_valid;
   output 	alu_if_ex_mr_r2_valid;
      
   output 	alu_decode_gen_stall;
   wire 	w_alu_decode_gen_stall;

   output 	alu_exec_gen_stall;
   wire 	w_alu_exec_gen_stall;

   assign alu_exec_gen_stall = w_alu_exec_gen_stall;
      
   
   assign alu_decode_gen_stall = w_alu_decode_gen_stall;
   


   output [6:0] alu_ex_mem_ptr;
   wire [6:0] 	w_alu_ex_mem_ptr;
   assign alu_ex_mem_ptr =  w_alu_ex_mem_ptr;
   

   
   output 	alu_ex_mem_valid;
   wire 	w_alu_ex_mem_valid;
   assign alu_ex_mem_valid = w_alu_ex_mem_valid;
   
   
   output [31:0] alu_ex_mem_in;
   wire [31:0] 	 w_alu_ex_mem_in;
   assign alu_ex_mem_in = w_alu_ex_mem_in;
   
   
   
 
   output [6:0]  alu_id_ex_ptr;
   wire [6:0] 	 w_alu_id_ex_ptr;
   assign alu_id_ex_ptr = w_alu_id_ex_ptr;
   
   
   output 	 alu_id_ex_valid;
   wire 	 w_alu_id_ex_valid;
   assign alu_id_ex_valid = w_alu_id_ex_valid;
   
   


   output 	 alu_grf_wb_valid;
   output [4:0]  alu_grf_wb_ptr;
   
   output 	 alu_mr_wb_valid;
   output [2:0]  alu_mr_wb_ptr;
   
   output 	 alu_pr_wb_valid;
   output [2:0]  alu_pr_wb_ptr;
   
   output 	 alu_xp_wb_valid;
   output [1:0]  alu_xp_wb_ptr;

   output [31:0] alu_wb_value;
   output [34:0] alu_wb_instruction;
   output 	 alu_wb_valid;


   output 	 alu_accum_stall;
   
   
   //predicate kills writeback
   input 	 xmu_pred_kill_exec;
      
   input [6:0] 	 xmu_ex_mem_ptr;
   input 	 xmu_ex_mem_valid;
   input [31:0]  xmu_ex_mem_in;


   input 	 xmu_id_ex_valid;
   input [6:0] 	 xmu_id_ex_ptr;

   input [31:0]  grf_r1_in;
   input 	 grf_r1_in_valid;

   input [31:0]  grf_r2_in;
   input 	 grf_r2_in_valid;


   //new way of doing xps
   input [4:0] 	 xp_grf_ptr1;
   input [4:0] 	 xp_grf_ptr2;

   input 	 xp_grf_ptr1_valid;
   input 	 xp_grf_ptr2_valid;


   input [4:0] 	 xp_grf_rd_ptr;
   input 	 xp_grf_rd_ptr_valid;
      
      
   input [8:0] 	 pr_r1_in;
   input 	 pr_r1_in_valid;

   input [8:0] 	 pr_r2_in;
   input 	 pr_r2_in_valid;
   
   input [31:0]  mr_r1_in;
   input 	 mr_r1_in_valid;

   input [31:0]  mr_r2_in;
   input 	 mr_r2_in_valid;

   input 	 mr0_full;
   input 	 mr1_full;
   input 	 mr2_full;
   input 	 mr3_full;
   input 	 mr4_full;
   input 	 mr5_full;
   input 	 mr6_full;
   input 	 mr7_full;

   
   input 	 stall_decode;
   input 	 stall_exec;
   input 	 stall_wb;
   
   input [7:0] 	 xmu_exec_opcode;
   
   

   //signals to be registered 
   wire [34:0] 	id_ex_instruction;
   wire [31:0] 	id_ex_rs1_out;
   wire [31:0] 	id_ex_rs2_out;
   wire [31:0] 	id_ex_rs3_out;
      
   wire 	if_ex_rs1_out_valid;
   wire 	if_ex_rs2_out_valid;
   wire 	if_ex_rs3_out_valid;
      
   
   //state for pipeline latches
   reg [34:0] 	r_id_ex_instruction;
   reg 		r_id_ex_valid;
   
   reg [31:0] 	r_id_ex_rs1_out;
   reg [31:0] 	r_id_ex_rs2_out;
   reg [31:0] 	r_id_ex_rs3_out;
   
   reg 		r_id_ex_rs1_out_valid;
   reg 		r_id_ex_rs2_out_valid;
   reg 		r_id_ex_rs3_out_valid;
      
   //read from accumulator
   //wire [31:0] 	w_alu_accumrf_value;
   wire [31:0] w_xmu_accumrf_value;


   //todo: FIX THE ACCUMULATORS
   wire        w_xmu_acc_read_ptr = 1'b0;
   wire        w_alu_acc_read_ptr;
    
      
   alu_decode adec(
		   // Outputs
		   .alu_decode_instr_out(id_ex_instruction),
		   .rs1_out		(id_ex_rs1_out),
		   .rs2_out		(id_ex_rs2_out),
		   .rs3_out             (id_ex_rs3_out),
		   .rs1_out_valid	(if_ex_rs1_out_valid),
		   .rs2_out_valid	(if_ex_rs2_out_valid),
		   .rs3_out_valid       (if_ex_rs3_out_valid),
		   
		   
		   .alu_decode_gen_stall(w_alu_decode_gen_stall),
		   .grf_ptr1		(alu_if_ex_grf_ptr1),
		   .grf_ptr2		(alu_if_ex_grf_ptr2),
		   .grf_ptr1_valid	(alu_if_ex_grf_ptr1_valid),
		   .grf_ptr2_valid	(alu_if_ex_grf_ptr2_valid),
		   .xp_ptr1		(alu_if_ex_xp_ptr1),
		   .xp_ptr2		(alu_if_ex_xp_ptr2),
		   .xp_ptr1_valid	(alu_if_ex_xp_ptr1_valid),
		   .xp_ptr2_valid	(alu_if_ex_xp_ptr2_valid),
		   .pr_ptr1		(alu_if_ex_pr_ptr1),
		   .pr_ptr2		(alu_if_ex_pr_ptr2),
		   .pr_r1_valid		(alu_if_ex_pr_r1_valid),
		   .pr_r2_valid		(alu_if_ex_pr_r2_valid),
		   .mr_ptr1		(alu_if_ex_mr_ptr1),
		   .mr_ptr2		(alu_if_ex_mr_ptr2),
		   .mr_r1_valid		(alu_if_ex_mr_r1_valid),
		   .mr_r2_valid		(alu_if_ex_mr_r2_valid),


		   //resolve rd in decode for index register file
		   .xp_rd_valid         (alu_xp_wb_valid),
		   .xp_rd_ptr           (alu_xp_wb_ptr),
		   

		   // Inputs
		   .instr_in		(alu_if_id_instruction),
		   .xmu_exec_opcode     (xmu_exec_opcode),
		   .link_reg            (link_reg),
		   
		   
		   //forwarding network from output of alu exec latch
		   .alu_ex_mem_ptr	(w_alu_ex_mem_ptr),
		   .alu_ex_mem_valid	(w_alu_ex_mem_valid),
		   .alu_ex_mem_in	(w_alu_ex_mem_in),

		   //forwarding network from output of xmu exec latch
		   .xmu_ex_mem_ptr	(xmu_ex_mem_ptr),
		   .xmu_ex_mem_valid	(xmu_ex_mem_valid),
		   .xmu_ex_mem_in	(xmu_ex_mem_in),

		   //track instruction in head of current one
		   .alu_id_ex_ptr	(w_alu_id_ex_ptr),
		   .alu_id_ex_valid	(w_alu_id_ex_valid),

		   
		   .xmu_id_ex_ptr	(xmu_id_ex_ptr),
		   .xmu_id_ex_valid	(xmu_id_ex_valid),
		   
		   .grf_r1_in		(grf_r1_in),
		   .grf_r2_in		(grf_r2_in),
		   .grf_r1_in_valid	(grf_r1_in_valid),
		   .grf_r2_in_valid	(grf_r2_in_valid),


		   //new way
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
		   .mr_r1_in		(mr_r1_in),
		   .mr_r2_in		(mr_r2_in),
		   .mr_r1_in_valid	(mr_r1_in_valid),
		   .mr_r2_in_valid	(mr_r2_in_valid)
		   );


   always@(posedge clk or posedge rst)
     begin: alu_id_ex_latch
	if(rst)
	  begin
	     r_id_ex_instruction <= 35'd0;
	     r_id_ex_valid <= 1'b0;
	     r_id_ex_rs1_out <= 32'd0;
	     r_id_ex_rs2_out <= 32'd0;
	     r_id_ex_rs3_out <= 32'd0;
	     	     
	     r_id_ex_rs1_out_valid <= 1'b0;
	     r_id_ex_rs2_out_valid <= 1'b0;
	     r_id_ex_rs3_out_valid <= 1'b0;
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
			      !w_alu_decode_gen_stall;
	     
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
	  
	     r_id_ex_rs3_out <= stall_exec ?
				r_id_ex_rs3_out :
				stall_decode ?
				32'd0 :
				id_ex_rs3_out;

  
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
	     
	     r_id_ex_rs3_out_valid <= stall_exec ?
				      r_id_ex_rs3_out_valid :
				      stall_decode ?
				      1'b0 :
				      if_ex_rs3_out_valid;
	     
	  end
     end
    
   assign w_alu_id_ex_ptr =   r_id_ex_instruction[20:14];

   //avoid matches on immediate for movi
   assign w_alu_id_ex_valid = r_id_ex_valid &
			      (r_id_ex_instruction[34:27] != `A_MOVI);
   

   wire alu_zero;
   wire alu_carry;
   wire alu_sign;
   wire alu_overflow;

   reg 	r_alu_zero, r_alu_carry, r_alu_sign, r_alu_overflow;


   wire [1:0] orf_read_ptr1;
   wire [1:0] orf_read_ptr2;
   wire orf_read_ptr1_valid;
   wire orf_read_ptr2_valid;
   wire [31:0] orf_read_ptr1_out;
   wire [31:0] orf_read_ptr2_out;
   
   
   wire [34:0] ex_mem_instruction;
   wire [31:0] ex_mem_result;
   
   
   reg [34:0]  r_ex_mem_instruction;
   reg [31:0]  r_ex_mem_result;
   reg 	       r_ex_mem_valid;
   
   wire        orf_use_byte_mask;
   wire [1:0]  orf_byte_mask;

   reg 	       r_orf_use_byte_mask;
   reg [1:0]   r_orf_byte_mask;
   
   
   wire        w_alu_mac_wr_valid;
   wire        w_alu_mac_wr_ptr;
   
   wire [31:0] w_rs_accum;
   wire [31:0] w_rs_accum_norm_read;
   
    
   alu_exec aexec(
		  // Outputs
		  .alu_exec_instr_out	(ex_mem_instruction),
		  
		  .orf_ptr1		(orf_read_ptr1),
		  .orf_ptr1_valid	(orf_read_ptr1_valid),
		  .orf_ptr2		(orf_read_ptr2),
		  .orf_ptr2_valid	(orf_read_ptr2_valid),

		  .acc_ptr (w_alu_acc_read_ptr),
		  
		  .alu_exec_rd_out	(ex_mem_result),
		  .alu_zero		(alu_zero),
		  .alu_carry		(alu_carry),
		  .alu_sign		(alu_sign),
		  .alu_overflow		(alu_overflow),

		  .orf_use_byte_mask    (orf_use_byte_mask),
		  .orf_byte_mask        (orf_byte_mask),

		  .mac_wr_valid         (w_alu_mac_wr_valid),
		  .mac_wr_ptr           (w_alu_mac_wr_ptr),

		  .alu_exec_stall       (w_alu_exec_gen_stall),
		  .alu_accum_stall      (alu_accum_stall),
		  
		  // Inputs
		  .alu_exec_instr_in	(r_id_ex_instruction),
		  .rs1_in		(r_id_ex_rs1_out),
		  .rs2_in		(r_id_ex_rs2_out),
		  .rs3_in               (r_id_ex_rs3_out),
		  
		  .rs1_in_valid		(r_id_ex_rs1_out_valid),
		  .rs2_in_valid		(r_id_ex_rs2_out_valid),
		  .rs3_in_valid         (r_id_ex_rs3_out_valid),
		  

		  .rs_accum             (w_rs_accum),
		  .rs_accum_norm_read   (w_rs_accum_norm_read),

		  .prev_alu_sign	(r_alu_sign),
		  .prev_alu_carry	(r_alu_carry),
		  .prev_alu_overflow	(r_alu_overflow),
		  .prev_alu_zero	(r_alu_zero),

		  //registered version of this stages output
		  .alu_ex_mem_ptr	(w_alu_ex_mem_ptr),
		  .alu_ex_mem_valid	(w_alu_ex_mem_valid),
		  .alu_ex_mem_in	(w_alu_ex_mem_in),

		  //gotta get your stall on when the message registers aren't ready
		  .mr0_full          (mr0_full),
		  .mr1_full          (mr1_full),
		  .mr2_full          (mr2_full),
		  .mr3_full          (mr3_full),
		  .mr4_full          (mr4_full),
		  .mr5_full          (mr5_full),
		  .mr6_full          (mr6_full),
		  .mr7_full          (mr7_full),
		  

		  //cross pipeline
		  .xmu_ex_mem_ptr	(xmu_ex_mem_ptr),
		  .xmu_ex_mem_valid	(xmu_ex_mem_valid),
		  .xmu_ex_mem_in	(xmu_ex_mem_in),
		  
		  .orf_ptr1_in		(orf_read_ptr1_out),
		  .orf_ptr2_in		(orf_read_ptr2_out)
		  );

   always@(posedge clk or posedge rst)
     begin: alu_ex_mem_latch
	if(rst)
	  begin
	     r_ex_mem_instruction <= 35'd0;
	     r_ex_mem_result <= 32'd0;
	     r_ex_mem_valid <= 1'b1;
	     
	     r_alu_zero <= 1'b0;
	     r_alu_carry <= 1'b0;
	     r_alu_sign <= 1'b0;
	     r_alu_overflow <= 1'b0;
	     
	     r_orf_byte_mask <= 2'd0;
	     r_orf_use_byte_mask <= 1'b0;
	     
	  end
	else
	  begin
	     r_orf_byte_mask <= stall_wb ?
				r_orf_byte_mask :
				orf_byte_mask;

	     r_orf_use_byte_mask <= stall_wb ?
				    r_orf_use_byte_mask :
				    stall_exec ?
				    1'b0 :
				    orf_use_byte_mask;
	     
	     
	     
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
				xmu_pred_kill_exec ?
				r_ex_mem_result : 
				ex_mem_result;

	     //predicate invalidates result
	     r_ex_mem_valid <= stall_wb ? 
			       r_ex_mem_valid :
			       stall_exec ?
			       1'b0 :
			       !xmu_pred_kill_exec;
	     
	     r_alu_zero <= stall_wb ?
			   r_alu_zero :
			   stall_exec ?
			   1'b1 :
			   xmu_pred_kill_exec ? 
			   r_alu_zero : 
			   alu_zero;
	     
	     r_alu_carry <= stall_wb ?
			    r_alu_carry :
			    stall_exec ?
			    1'b0 :
			    xmu_pred_kill_exec ? 
			    r_alu_carry : 
			    alu_carry;
	     
	     r_alu_sign <= stall_wb ?
			   r_alu_sign :
			   stall_exec ?
			   1'b0 :
			   xmu_pred_kill_exec ? 
			   r_alu_sign : 
			   alu_sign;
	     
	     r_alu_overflow <= stall_wb ?
			       r_alu_overflow :
			       stall_exec ?
			       1'b0 :
			       xmu_pred_kill_exec ? 
			       r_alu_overflow :
			       alu_overflow;
	  end
     end
   
   assign w_alu_ex_mem_ptr =   r_ex_mem_instruction[20:14];
  
   //avoid bizarre rd matches with movi instructions
   assign w_alu_ex_mem_valid = r_ex_mem_valid /*& 
			       (r_ex_mem_instruction[34:27] != `A_MOVI)*/;
	    
   assign w_alu_ex_mem_in = r_ex_mem_result;

  
   assign alu_wb_value = r_ex_mem_result;
   assign alu_wb_valid = r_ex_mem_valid;
   assign alu_wb_instruction = r_ex_mem_instruction;
   
    
   alu_writeback awb(
		     // Outputs
		     .grf_wb_valid	(alu_grf_wb_valid),
		     .grf_wb_ptr	(alu_grf_wb_ptr),
		     .mr_wb_valid	(alu_mr_wb_valid),
		     .mr_wb_ptr		(alu_mr_wb_ptr),
		     .pr_wb_valid	(alu_pr_wb_valid),
		     .pr_wb_ptr		(alu_pr_wb_ptr),

		    
		     // Inputs
		     .rd_ptr		(r_ex_mem_instruction[20:14]),
		     .rd_valid		(r_ex_mem_valid)
		     );
   
   
   wire        orf_write_ptr_valid = ({w_alu_ex_mem_ptr[6:2],2'b00} ==  `DR0) &
	       r_ex_mem_valid;
   
   
   
   wire [1:0]  orf_write_ptr = w_alu_ex_mem_ptr[1:0];
   
   
   alu_orf aorf(
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

		.orf_use_write_mask     (r_orf_use_byte_mask),
		.orf_write_mask	        (r_orf_byte_mask),
		.orf_write_value	(r_ex_mem_result),


		.xmu_ex_mem_ptr         (xmu_ex_mem_ptr),
		.xmu_ex_mem_valid       (xmu_ex_mem_valid),
		.xmu_ex_mem_in          (xmu_ex_mem_in)
		

		);


 
   
   
   wire        mac_no_stall = w_alu_mac_wr_valid & !stall_exec;

   
   wire        w_alu_write_ptr = w_alu_ex_mem_ptr[0];
   
   wire        w_alu_write_valid = r_ex_mem_valid & 
	       (w_alu_ex_mem_ptr[6:1] == 6'b101110);
   
   wire        w_xmu_write_ptr = xmu_ex_mem_ptr[0];
   
   wire        w_xmu_write_valid = xmu_ex_mem_valid & 
	       (xmu_ex_mem_ptr[6:1] == 6'b101110);

   
   alu_accrf accumrf(
		     // Outputs
		     .alu_read_value	(w_rs_accum_norm_read),
		     .xmu_read_value	(w_xmu_accumrf_value),
		     
		     // Inputs
		     .clk		(clk),
		     .rst		(rst),
		     .alu_read_ptr	(w_alu_acc_read_ptr),
		     .xmu_read_ptr	(w_xmu_acc_read_ptr),

		     .alu_mac_wr_ptr    (w_alu_mac_wr_ptr),
		     .alu_mac_wr_valid  (mac_no_stall),
		     .alu_mac_wr_value  (ex_mem_result),

		     .alu_write_value	(r_ex_mem_result),
		     .xmu_write_value	(xmu_ex_mem_in),
		     
		     .alu_write_ptr	(w_alu_write_ptr),
		     .xmu_write_ptr	(w_xmu_write_ptr),
		     
		     .alu_write_valid	(w_alu_write_valid),
		     .xmu_write_valid	(w_xmu_write_valid),

		     .alu_mac_read      (w_rs_accum)
		     );
   
		     



   
   
endmodule // alu_pipeline
