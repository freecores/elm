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

//branches and loops are handled in
//this functional unit

/*
 *  pc (handled in this module)
 *
 *  if/decode latch
 *  -> stall_decode hold value in latch
 *  -> stall_fetch will mux a nop into it
 * 
 * 
 * 
 *  decode/exec latch
 *  -> stall_decode will mux a nop
 *  -> stall_exec will hold value in latch
 * 
 * 
 *   exec/wb latch
 *  -> stall exec will mux in nop
 *  -> stall wb will hold value in latch
 * 
 */


//this module has state
module pc_branch_unit(/*AUTOARG*/
   // Outputs
   alu_pr_out1, alu_pr_out1_valid, alu_pr_out2, alu_pr_out2_valid,
   xmu_pr_out1, xmu_pr_out1_valid, xmu_pr_out2, xmu_pr_out2_valid, ip,
   stall_fetch, stall_decode, stall_exec, stall_wb, jump_pr, saved_ip,
   link_reg, hcf, fetch_req, fetch_base_global_addr,
   fetch_base_ir_addr, fetch_len, ce_barrier_req, simd_out_req,
   simd_out_mine, simd_out_simd_stall, simd_mode,
   // Inputs
   clk, rst, xmu_exec_hcf, xmu_exec_non_block, xmu_exec_ld,
   xmu_exec_st, grf_retire_non_block_load, xmu_exec_opcode,
   global_stall, xmu_rs1_in, xmu_dec_instruction, ir_valid,
   fetch_active, xmu_ensemble_req, ensemble_gnt, xmu_barrier,
   ensemble_barrier_release, alu_dec_stall, alu_exec_stall,
   xmu_dec_stall, xmu_exec_stall, alu_accum_stall, alu_pr_ptr1,
   alu_pr_ptr1_valid, alu_pr_ptr2, alu_pr_ptr2_valid, xmu_pr_ptr1,
   xmu_pr_ptr1_valid, xmu_pr_ptr2, xmu_pr_ptr2_valid, who_am_i,
   xmu_pr_wb_ptr, xmu_pr_wb_ptr_valid, alu_pr_exec_ptr,
   alu_pr_exec_ptr_valid, alu_pr_wb_ptr, alu_pr_wb_ptr_valid,
   alu_pr_wb_in, alu_write_link_reg, alu_link_reg, xmu_write_link_reg,
   xmu_link_pr_reg, stop_jfetch, simd_in_stall
   );
   //instruction in xmu decode
   input clk;
   input rst;
   input xmu_exec_hcf;
      
   input xmu_exec_non_block;
   input xmu_exec_ld;
   input xmu_exec_st;
   input grf_retire_non_block_load;
   
   input [7:0] xmu_exec_opcode;
      
   input global_stall;

   input [31:0] xmu_rs1_in;
      /*input 	xmu_rs1_in_valid;*/
      
     
   input [31:0] xmu_dec_instruction;

   //invalid ir causes stall
   input 	ir_valid;

   input 	fetch_active;

   //load / store has occured
   input 	xmu_ensemble_req;
   /*input 	xmu_ensemble_rem_req;*/
   input        ensemble_gnt;
   

   //processor has executed a barrier
   input 	xmu_barrier;
   input 	ensemble_barrier_release;
   
   
    //alu decode wants an invalid register
   input 	alu_dec_stall;

   input 	alu_exec_stall;
      
   
   //xmu decode wants an invalid register
   input 	xmu_dec_stall;

   //xmu exec has stalled
   input 	xmu_exec_stall;

   input 	alu_accum_stall;
   
   
   //either the alu or the xmu is
   //try to write to a full mr
   /*input 	mr_wb_stall;  */
      
   input [2:0] 	alu_pr_ptr1;
   input 	alu_pr_ptr1_valid;
 
   input [2:0] 	alu_pr_ptr2;
   input 	alu_pr_ptr2_valid;

   //predicate register read ports for
   //the xmu are just for killing
   //instructions the alu exec stage
   input [2:0]	xmu_pr_ptr1;
   input 	xmu_pr_ptr1_valid;

   input [2:0] 	xmu_pr_ptr2;
   input 	xmu_pr_ptr2_valid;
  
   input [1:0] 	who_am_i;
 	
   output [8:0] alu_pr_out1;
   output 	alu_pr_out1_valid;
   
   output [8:0] alu_pr_out2;
   output 	alu_pr_out2_valid;
   
   
   output [8:0] xmu_pr_out1;
   output 	xmu_pr_out1_valid;
   
   wire [8:0] 	w_xmu_pr_out1;
   assign xmu_pr_out1 = w_xmu_pr_out1;
   
   
   output [8:0] xmu_pr_out2;
   output 	xmu_pr_out2_valid;


   //does the writeback network serve
   //as a forwarding network....?
   input [2:0] 	 xmu_pr_wb_ptr;
   input 	 xmu_pr_wb_ptr_valid;
   /*input [31:0]  xmu_pr_wb_in;*/
      

   input [6:2] 	 alu_pr_exec_ptr;
   input 	 alu_pr_exec_ptr_valid;
  

   
   input [2:0] 	 alu_pr_wb_ptr;
   input 	 alu_pr_wb_ptr_valid;
   input [31:0]  alu_pr_wb_in;

   //instruction pointer
   output [5:0]  ip;
   
   //stall signals
   output 	 stall_fetch;
   output 	 stall_decode;
   output 	 stall_exec;
   output 	 stall_wb;

   //fed in xmu_exec stage
   output [31:0] jump_pr;

   output [5:0]  saved_ip;
   //zero padded version of saved_ip
   output [5:0] link_reg;

   output 	 hcf;
   
   
   input 	 alu_write_link_reg;
   input [31:0]  alu_link_reg;
   
   input 	 xmu_write_link_reg;
   input [31:0]  xmu_link_pr_reg;

   
   output 	 fetch_req;
   output [31:0] fetch_base_global_addr;
   output [5:0]  fetch_base_ir_addr;
   output [5:0]  fetch_len;

   input 	 stop_jfetch;
   input 	 simd_in_stall;
      
   output 	 ce_barrier_req;

   output 	 simd_out_req;
   output 	 simd_out_mine;
   output 	 simd_out_simd_stall;
   
   output 	 simd_mode;
   reg 		 simd_mode;
      
   /*
    * stall theory of operation:
    * stall_decode stalls the if/dec pipeline register
    * and the program counter
    * 
    * stall_exec stalls pc, if/dec, dec/exec
    *
    * stall_wb stalls EVERYTHING
    */
   
   //program counter
   reg [5:0] 	 pc;

   reg [5:0] 	 saved_pc;

   assign link_reg = saved_pc;

   /* Halt and catch fire state */
   reg 		 r_hcf;
   


   
   //pc of instruction in decode
   reg [5:0] 	 last_pc;
   

   //combinational version
   reg [5:0] 	 t_pc;
   
   assign ip = pc;
   assign saved_ip = saved_pc;
   

   reg 		 t_stall_fetch;
   reg 		 t_stall_decode;
   reg 		 t_stall_exec;
   reg 		 t_stall_wb;
   reg 		 t_stall_simd;
   
   assign stall_fetch = t_stall_fetch;
   assign stall_decode = t_stall_decode;
   assign stall_exec = t_stall_exec;
   assign stall_wb = t_stall_wb;
   assign simd_out_simd_stall = t_stall_simd;
    

   wire [7:0] 	 xmu_dec_opcode = xmu_dec_instruction[31:24];
 

   wire [7:0] 	 dec_branch_target = xmu_dec_instruction[23:16];

   //create curt register encoding
   wire [2:0] 	 dec_pr_ptr;

   /* This is encoding specific
    * NO JOKE, REGISTER ENCODING IS SERIOUS BUSINESS */
   assign dec_pr_ptr[2] = ~xmu_dec_instruction[12];
   assign dec_pr_ptr[1:0] = xmu_dec_instruction[11:10];
   
   
   reg 		 r_non_block_ld;
   reg 		 r_non_block_st;
   
  
   wire fetch_exec = (xmu_exec_opcode == `X_FETCH_A_R) |(xmu_exec_opcode == `X_FETCH_R_R) |
	          (xmu_exec_opcode == `X_JFETCH_A_R) | (xmu_exec_opcode == `X_JFETCH_R_R) ;


   //set in other always block
   wire 	t_is_control_op;
   
   //steal the xmu_pr port 1 for loops/jumps
   reg [2:0] t_xmu_pr_ptr1;
   reg 	     t_xmu_pr_ptr1_valid;
      
   wire [31:0] t_pr;
   reg [31:0]  t_forward_pr;
   
   reg [31:0]  t_loop_pr;
   assign jump_pr = t_loop_pr;

   /*
   input [6:0] alu_pr_exec_ptr;
   input       alu_pr_exec_ptr_valid;
   */

   wire alu_exec_use_pr = (alu_pr_exec_ptr[6:2] == 5'b00101) |
	(alu_pr_exec_ptr[6:2] == 5'b10100);

   //can't forward
   wire match_alu_pr_exec = alu_exec_use_pr & alu_pr_exec_ptr_valid;
      

   wire       match_xmu_pr_wb = (xmu_pr_wb_ptr == dec_pr_ptr) & 
	      xmu_pr_wb_ptr_valid;

   wire       match_alu_pr_wb = (alu_pr_wb_ptr == dec_pr_ptr) & 
	      alu_pr_wb_ptr_valid;
   
   
   reg 	      t_branch_access_pr;


   

  wire dec_rmem_op = 
       (xmu_dec_opcode == `X_RB_LD_I) |
       (xmu_dec_opcode == `X_RB_LD_IR) |
       (xmu_dec_opcode == `X_RB_LD_RR) |
       (xmu_dec_opcode == `X_RNB_LD_I) |
       (xmu_dec_opcode == `X_RNB_LD_IR) |
       (xmu_dec_opcode == `X_RNB_LD_RR) |
       (xmu_dec_opcode == `X_RB_ST_I) |
       (xmu_dec_opcode == `X_RB_ST_IR) |
       (xmu_dec_opcode == `X_RB_ST_RR) |
       (xmu_dec_opcode == `X_RNB_ST_I) |
       (xmu_dec_opcode == `X_RNB_ST_IR) |
       (xmu_dec_opcode == `X_RNB_ST_RR) | 
       (xmu_dec_opcode == `X_LD_I) |
       (xmu_dec_opcode == `X_LD_IR) |
       (xmu_dec_opcode == `X_LD_RR) |
       (xmu_dec_opcode == `X_ST_I) |
       (xmu_dec_opcode == `X_ST_IR) |
       (xmu_dec_opcode == `X_ST_RR) |
       (xmu_dec_opcode == `X_LDREST_LO_I) |
       (xmu_dec_opcode == `X_LDREST_LO_IR) |
       (xmu_dec_opcode == `X_LDREST_HI_I) |
       (xmu_dec_opcode == `X_LDREST_HI_IR) |
       (xmu_dec_opcode == `X_STSAVE_LO_I) |
       (xmu_dec_opcode == `X_STSAVE_LO_IR) |
       (xmu_dec_opcode == `X_STSAVE_HI_I) |
       (xmu_dec_opcode == `X_STSAVE_HI_IR) |
       (xmu_dec_opcode == `X_CMPSWP) |
       (xmu_dec_opcode == `X_LDSD_RI) |
       (xmu_dec_opcode == `X_LDSD_RR) |
       (xmu_dec_opcode == `X_STSD_RI) |
       (xmu_dec_opcode == `X_STSD_RR) | 
       (xmu_dec_opcode == `X_LDSTREAM) | 
       (xmu_dec_opcode == `X_STSTREAM);
   
   wire exec_rmem_op = 
	(xmu_exec_opcode == `X_RB_LD_I) |
	(xmu_exec_opcode == `X_RB_LD_IR) |
	(xmu_exec_opcode == `X_RB_LD_RR) |
	(xmu_exec_opcode == `X_RNB_LD_I) |
	(xmu_exec_opcode == `X_RNB_LD_IR) |
	(xmu_exec_opcode == `X_RNB_LD_RR) |
	(xmu_exec_opcode == `X_RB_ST_I) |
	(xmu_exec_opcode == `X_RB_ST_IR) |
	(xmu_exec_opcode == `X_RB_ST_RR) |
	(xmu_exec_opcode == `X_RNB_ST_I) |
	(xmu_exec_opcode == `X_RNB_ST_IR) |
	(xmu_exec_opcode == `X_RNB_ST_RR) |
	(xmu_exec_opcode == `X_LD_I) |
	(xmu_exec_opcode == `X_LD_IR) |
	(xmu_exec_opcode == `X_LD_RR) |
	(xmu_exec_opcode == `X_ST_I) |
	(xmu_exec_opcode == `X_ST_IR) |
	(xmu_exec_opcode == `X_ST_RR) |
	(xmu_exec_opcode == `X_LDREST_LO_I) |
	(xmu_exec_opcode == `X_LDREST_LO_IR) |
	(xmu_exec_opcode == `X_LDREST_HI_I) |
	(xmu_exec_opcode == `X_LDREST_HI_IR) |
	(xmu_exec_opcode == `X_STSAVE_LO_I) |
	(xmu_exec_opcode == `X_STSAVE_LO_IR) |
	(xmu_exec_opcode == `X_STSAVE_HI_I) |
	(xmu_exec_opcode == `X_STSAVE_HI_IR) |
	(xmu_exec_opcode == `X_CMPSWP) |
	(xmu_exec_opcode == `X_LDSD_RI) |
	(xmu_exec_opcode == `X_LDSD_RR) |
	(xmu_exec_opcode == `X_STSD_RI) |
	(xmu_exec_opcode == `X_STSD_RR) | 
	(xmu_exec_opcode == `X_LDSTREAM) | 
	(xmu_exec_opcode == `X_STSTREAM);

   wire mem_after_mem_hack_stall = dec_rmem_op & exec_rmem_op;
      
 
   //hack because modelsim is stupid
   wire t_is_zero = ~(t_forward_pr[30:0] == 31'b0);
   
   assign t_pr = t_branch_access_pr ? {23'd0, w_xmu_pr_out1} : {t_forward_pr[30:0], t_is_zero};
   


   wire op_need_pr = 
	(xmu_dec_opcode == `X_JUMPS_R) |
	(xmu_dec_opcode == `X_JUMPS_A) |
	(xmu_dec_opcode == `X_JUMPC_R) |
	(xmu_dec_opcode == `X_JUMPC_A) |
	(xmu_dec_opcode == `X_LOOPS_R) |
	(xmu_dec_opcode == `X_LOOPS_A) |
	(xmu_dec_opcode == `X_LOOPC_R) |
	(xmu_dec_opcode == `X_LOOPC_A) |
 	(xmu_dec_opcode == `X_LOOPS_RI) |
	(xmu_dec_opcode == `X_LOOPS_AI) |
	(xmu_dec_opcode == `X_LOOPC_RI) |
	(xmu_dec_opcode == `X_LOOPC_AI);
  

   //delay request signal by one cycle
   reg 	r_mem_op;

   //barrier status
   reg 	r_barrier_req;

   assign ce_barrier_req = r_barrier_req;
   

   wire barrier_stall = xmu_barrier | r_barrier_req;
   
   reg 	t_next_mem_op;
   wire ensemble_mem_stall = r_mem_op /*t_next_mem_op*/ & !ensemble_gnt;
         
   wire branch_unit_stall = match_alu_pr_exec & op_need_pr;


   wire is_fetch = ((xmu_dec_opcode == `X_FETCH_A_I) | (xmu_dec_opcode == `X_JFETCH_A_I) |
		    (xmu_dec_opcode == `X_FETCH_A_R) | (xmu_dec_opcode == `X_JFETCH_A_R) |
		    (xmu_dec_opcode == `X_FETCH_R_I) | (xmu_dec_opcode == `X_JFETCH_R_I) |
		    (xmu_dec_opcode == `X_FETCH_R_R) | (xmu_dec_opcode == `X_JFETCH_R_R));

   
   
   //do we want to stall the jump sim
   wire fetch_req_while_fetch = fetch_active & 
	((xmu_dec_opcode == `X_FETCH_A_I) | (xmu_dec_opcode == `X_JFETCH_A_I) |
	 (xmu_dec_opcode == `X_FETCH_A_R) | (xmu_dec_opcode == `X_JFETCH_A_R) |
	 (xmu_dec_opcode == `X_FETCH_R_I) | (xmu_dec_opcode == `X_JFETCH_R_I) |
	 (xmu_dec_opcode == `X_FETCH_R_R) | (xmu_dec_opcode == `X_JFETCH_R_R));

   /* COMBINATIONAL LOOP: 
    says ISE:
    1) branch_comp/t_is_control_op,
    2) xmu_pr_r1_in_valid,
    3) xpipe/xdec/t_rs1_valid29,
    4) branch_comp/N53,
    5) branch_comp/relative_fetch_to_inv_reg
    6) N1640,
    7) decode_stall
    */

   /*
   wire relative_fetch_to_inv_reg =( ~xmu_rs1_in_valid ) &
	((xmu_dec_opcode == `X_FETCH_A_R) | (xmu_dec_opcode == `X_JFETCH_A_R)  |
	 (xmu_dec_opcode == `X_FETCH_R_R) | (xmu_dec_opcode == `X_JFETCH_R_R));
   */
   wire relative_fetch_to_inv_reg = 1'b0;

   wire is_mem_op =
	(xmu_dec_opcode == `X_LD_I) |
	(xmu_dec_opcode == `X_LD_IR) |
	(xmu_dec_opcode == `X_LD_RR) |
	(xmu_dec_opcode == `X_ST_I) |
	(xmu_dec_opcode == `X_ST_IR) |
	(xmu_dec_opcode == `X_ST_RR) |
	(xmu_dec_opcode == `X_RB_LD_I) |
	(xmu_dec_opcode == `X_RB_LD_IR) |
	(xmu_dec_opcode == `X_RB_LD_RR) |
	(xmu_dec_opcode == `X_RB_ST_I) |
	(xmu_dec_opcode == `X_RB_ST_IR) |
	(xmu_dec_opcode == `X_RB_ST_RR) |	
	(xmu_dec_opcode == `X_RNB_LD_I) |
	(xmu_dec_opcode == `X_RNB_LD_IR) |
	(xmu_dec_opcode == `X_RNB_LD_RR) |
	(xmu_dec_opcode == `X_RNB_ST_I) |
	(xmu_dec_opcode == `X_RNB_ST_IR) |
	(xmu_dec_opcode == `X_RNB_ST_RR);

   wire non_block_req = (xmu_ensemble_req & xmu_exec_non_block);
      
   wire outstanding_memory_stall = (r_non_block_st | r_non_block_ld | non_block_req) 
	& is_mem_op;


   wire is_jfetch_grf =
	(xmu_dec_opcode == `X_FETCH_A_R | xmu_dec_opcode == `X_FETCH_R_R |
	 xmu_dec_opcode == `X_JFETCH_A_R | xmu_dec_opcode == `X_JFETCH_R_R) 
	;
   
   
   wire fetch_grf_not_valid_stall = /*is_jfetch_grf & ~xmu_rs1_in_valid*/ stop_jfetch;

   wire [31:0] xmu_rs1_in_fetch = is_jfetch_grf ? xmu_rs1_in : 32'd0;
         
   wire stall = /*mr_wb_stall |*/ xmu_exec_stall | 
	alu_dec_stall | alu_exec_stall | xmu_dec_stall | !ir_valid |
	branch_unit_stall | ensemble_mem_stall |
	barrier_stall | fetch_req_while_fetch | global_stall | r_hcf |
	relative_fetch_to_inv_reg | alu_accum_stall | outstanding_memory_stall |
	fetch_grf_not_valid_stall | mem_after_mem_hack_stall;
   
   
   assign simd_out_req = ~stall & (xmu_dec_opcode == `X_JUMPSIMD);

   always@(posedge clk or posedge rst)
     if(rst) simd_mode = 1'b0;
     else simd_mode = simd_mode | (~simd_mode & simd_out_req);

   reg 	simd_out_mine_r;
   assign simd_out_mine = simd_out_mine_r | ( simd_out_req & (dec_branch_target[7:6] == who_am_i));
   always@(posedge clk or posedge rst)
     if(rst) simd_out_mine_r = 1'b0;
     else simd_out_mine_r = simd_out_mine_r | ( simd_out_req & (dec_branch_target[7:6] == who_am_i));
      
   reg t_save_pc;

   reg t_fetch_req;
   reg [5:0] t_fetch_len;
   reg [5:0] t_fetch_base_ir_addr;
   reg [31:0] t_fetch_base_global_addr;


   assign t_is_control_op = ( xmu_dec_opcode == `X_JUMPS_R ||
			      xmu_dec_opcode == `X_JUMPS_A ||
			      xmu_dec_opcode == `X_JUMPC_R ||
			      xmu_dec_opcode == `X_JUMPC_A ||
			      xmu_dec_opcode == `X_LOOPS_R ||
			      xmu_dec_opcode == `X_LOOPS_A ||
			      xmu_dec_opcode == `X_LOOPC_R ||
			      xmu_dec_opcode == `X_LOOPC_A);


   
     always@(*)
     begin: get_pr
	t_forward_pr = 32'd0;
	t_xmu_pr_ptr1 = xmu_pr_ptr1;
	t_xmu_pr_ptr1_valid = xmu_pr_ptr1_valid;

	t_branch_access_pr = 1'b0;
		
	if(t_is_control_op)
	  begin
	     //check writeback networks
	     //write back networks have different
	     //pr encoding
	     if (match_xmu_pr_wb)
	       begin
		  t_forward_pr = xmu_link_pr_reg;

	       end
	     
	     else if (match_alu_pr_wb)
	       begin
		  t_forward_pr = alu_pr_wb_in;
	       end

	     else
	       begin
		  t_xmu_pr_ptr1 = xmu_dec_instruction[12:10];
		  t_xmu_pr_ptr1_valid = ~(stall | (simd_in_stall & simd_mode));

		  t_branch_access_pr = ~(stall | (simd_in_stall & simd_mode));
	       end
	     	     
	  end // if (t_is_control_op)
	
     end

   always@(*)
     begin
	//normal situation
	t_pc = pc + 6'd1;
	t_stall_fetch = 1'b0;
	t_stall_decode = 1'b0;
	t_stall_exec = 1'b0;
	t_stall_wb = 1'b0;
	t_stall_simd = 1'b0;
	//t_is_control_op = 1'b0;

	t_save_pc = 1'b0;
	t_loop_pr = 32'd0;

	t_fetch_req = 1'b0;
	t_fetch_len = 6'd0;
	t_fetch_base_ir_addr = 6'd0;
	t_fetch_base_global_addr = 32'd0;
	
	//stalling: forget about branches (for now)
	if(stall | (simd_in_stall & simd_mode))
	  begin
	     /* Hit HCF, stall everything! */
	     if(r_hcf)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b0;
		  t_stall_wb = 1'b0;
		  
		  t_pc = pc;
	       end

	     else if(relative_fetch_to_inv_reg)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b0;
		  t_stall_wb = 1'b0;
		  t_pc = pc;
	       end
	     	     
	     else if(global_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b1;
		  t_stall_wb = 1'b1;
		  t_pc = pc;
	       end

	     else if(fetch_grf_not_valid_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b0;
		  t_pc = pc;
	       end
	     

	     else if(alu_accum_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b0;
		  t_pc = pc;
	       end
	     
	     
	     else if(ensemble_mem_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b1;
		  t_stall_wb = 1'b1;
		  t_pc = pc;
	       end

	     else if(mem_after_mem_hack_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b0;
		  t_stall_wb = 1'b0;
		  t_pc = pc;
	       end

	     else if(fetch_req_while_fetch)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b0;
		  t_stall_wb = 1'b0;
		  t_pc = pc;
	       end
	   /*
	     else if(mr_wb_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  t_stall_exec = 1'b1;
		  t_stall_wb = 1'b1;
		  t_pc = pc;
	       end*/
	     else if(outstanding_memory_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b1;
		  t_pc = pc;
	       end
	     	     
	     else if(xmu_exec_stall)
	       begin
		  t_stall_fetch = 1'b1;	  
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b1;
		  t_stall_wb = 1'b1;
		  
		  t_pc = pc;
	       end

	     else if(alu_exec_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b1;
		  t_pc = pc;
	       end
	     
	     else if(barrier_stall)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_stall_exec = 1'b0;
		  t_pc = pc;
	       end
	     	     
	     
	     else if(alu_dec_stall | xmu_dec_stall | branch_unit_stall)
	       begin
		  t_stall_fetch = 1'b1;	 
		  t_stall_decode = 1'b1;
		  	  t_stall_simd = 1'b1;
		  t_pc = pc;
	       end

	     else if(!ir_valid)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  t_stall_simd = 1'b1;
		  t_pc = pc;
	       end
	     else if(simd_in_stall & simd_mode)
	       begin
		  t_stall_fetch = 1'b1;
		  t_stall_decode = 1'b1;
		  t_stall_simd = 1'b0;
		  t_pc = pc;
	       end
	  end // if (stall)
	//fetch (relative to address register)
	//in xmu exec unit
	else if(fetch_exec)
	  begin


	  end
   	//no stall: handle branches
	else
	  
	  begin
	     case(xmu_dec_opcode)
	       //absolute jumps
	       `X_JUMPSIMD:
		 t_pc = dec_branch_target[5:0];
	       `X_JUMP_R:
		 begin
		    t_pc = dec_branch_target[5:0] + last_pc;
		 end

	       `X_JUMP_A:
		 begin
		    t_pc = dec_branch_target[5:0];
		 end
	       
	       //jump if pr set
	       `X_JUMPS_R:
		 begin
		    //t_is_control_op = 1'b1;
		    
		    if(t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0] + last_pc;
		      end
		 end

	       `X_JUMPS_A:
		 begin
		    //t_is_control_op = 1'b1;
		    
		    if(t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0];
		      end
		    
		 end

	       //jump if pr clear
	       `X_JUMPC_R:
		 begin
		    //t_is_control_op = 1'b1;
		   
		    if(!t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0] + last_pc;
		      end
		    
		 end

	       `X_JUMPC_A:
		 begin
		    //t_is_control_op = 1'b1;

		    if(!t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0];
		      end
		 end

	       //loop if predicate is set
	       `X_LOOPS_R:
		 begin
		    //t_is_control_op = 1'b1;

		    //branch taken if predicate set
		    if(t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0] + last_pc;
			 t_loop_pr =  {24'd0, (t_pr[8:1] - 8'd1)};
		      end
		    else
		      begin
			 t_loop_pr = {24'd0, xmu_dec_instruction[7:0]};
		      end		 
		 end
	       //loop if predicate is set
	       `X_LOOPS_A:
		 begin
		    //t_is_control_op = 1'b1;
		    //branch taken if predicate set
		    if(t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0];
			 t_loop_pr =  {24'd0, (t_pr[8:1] - 8'd1)};
		      end
		    else
		      begin
			 t_loop_pr = {24'd0, xmu_dec_instruction[7:0]};
		      end
		 end // case: `X_LOOPS_A

	       //loop if predicate is cleared
	       `X_LOOPC_R:
		 begin
		    //t_is_control_op = 1'b1;

		    //branch taken if predicate cleared
		    if(!t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0] + last_pc;
			 t_loop_pr = {24'd0, xmu_dec_instruction[7:0]}; 
		      end
		    else
		      begin
			 t_loop_pr =  {24'd0, (t_pr[8:1] - 8'd1)};
		      end
		 end // case: `X_LOOPC_R
	       
	       //loop if predicate is cleared
	       `X_LOOPC_A:
		 begin
		    //t_is_control_op = 1'b1;

		    //branch taken if predicate cleared
		    if(!t_pr[0])
		      begin
			 t_pc = dec_branch_target[5:0];
			 t_loop_pr = {24'd0, xmu_dec_instruction[7:0]}; 
		      end
		    else
		      begin
			 t_loop_pr =  {24'd0, (t_pr[8:1] - 8'd1)};
		      end
		 end // case: `X_LOOPC_A

	       //JFETCH to an absolute, getting from immed
	       `X_JFETCH_A_I:
		 begin
		    //there can be only one....fetch active
		    if(!fetch_active)
		      begin
			 t_fetch_req = 1'b1;
			 t_fetch_len = xmu_dec_instruction[5:0];
			 t_fetch_base_ir_addr = xmu_dec_instruction[23:18];
			 t_fetch_base_global_addr = 
			    {20'd0, xmu_dec_instruction[17:6]};
			 t_pc = xmu_dec_instruction[23:18];
		      end
		    
		 end // case: `X_JFETCH_A_I
	       //FETCHING to an absolute, getting from immed
	       `X_FETCH_A_I:
		 begin
		    //there can be only one....fetch active
		    if(!fetch_active)
		      begin
			 t_fetch_req = 1'b1;
			 t_fetch_len = xmu_dec_instruction[5:0];
			 t_fetch_base_ir_addr = xmu_dec_instruction[23:18];
			 t_fetch_base_global_addr = 
			    {20'd0, xmu_dec_instruction[17:6]};
		      end
		 end // case: `X_FETCH_OO

	       //JFETCH to an absolute, getting from an i+r
	       `X_JFETCH_A_R:
		 begin
		    if(!fetch_active)
		      begin
			 t_fetch_req = 1'b1;
			 t_fetch_len = xmu_dec_instruction[5:0];
			 t_fetch_base_ir_addr = xmu_dec_instruction[23:18];
			 t_fetch_base_global_addr = 
			   {{25{xmu_dec_instruction[23]}}, xmu_dec_instruction[23:18], 1'b0} +
			     xmu_rs1_in_fetch;
			 t_pc = xmu_dec_instruction[23:18];
		      end
		 end // case: `X_JFETCH_A_R
	       //FETCH to an absolute, getting from an i+r
	       `X_FETCH_A_R:
		 begin
		    if(!fetch_active)
		      begin
			 t_fetch_req = 1'b1;
			 t_fetch_len = xmu_dec_instruction[5:0];
			 t_fetch_base_ir_addr = xmu_dec_instruction[23:18];
			 t_fetch_base_global_addr = 
			    {{25{xmu_dec_instruction[23]}}, xmu_dec_instruction[11:6]} + xmu_rs1_in_fetch;
		      end
		 end // case: `X_FETCH_A_R
	       

	       `X_FETCH_R_I:
		 begin
		    t_fetch_req = 1'b1;
		    t_fetch_len = xmu_dec_instruction[5:0];
		    t_fetch_base_ir_addr = xmu_dec_instruction[23:18] + pc - 1;
		    t_fetch_base_global_addr = 
			 {20'd0, xmu_dec_instruction[17:6]};
		 end
  
	       
	       //JFETCH to a relative from an immed
	       `X_JFETCH_R_I:
		 begin
		    if(!fetch_active)
		      begin
			 t_fetch_req = 1'b1;
			 t_fetch_len = xmu_dec_instruction[5:0];
			 t_fetch_base_ir_addr = xmu_dec_instruction[23:18] + pc - 1;
			 t_fetch_base_global_addr = 
				  {20'd0, xmu_dec_instruction[17:6]};
			 t_pc = xmu_dec_instruction[23:18] + pc - 1;
		      end
		 end // case: `X_JFETCH_R_I
	       	       	       
	       
	       `X_JFETCH_R_R:
		 begin
		    if(!fetch_active)
		      begin
			 t_fetch_req = 1'b1;
			 t_fetch_len = xmu_dec_instruction[5:0] ;
			 t_fetch_base_ir_addr = xmu_dec_instruction[23:18]+ pc - 1;
			 t_fetch_base_global_addr = 
		      {{26{xmu_dec_instruction[11]}}, xmu_dec_instruction[11:6]} + xmu_rs1_in_fetch;
			 t_pc = xmu_dec_instruction[23:18] + pc - 1;
		      end
		 end // case: `X_JFETCH_R_R
	       `X_FETCH_R_R:
		 begin
		    if(!fetch_active)
		      begin
			 t_fetch_req = 1'b1;
			 t_fetch_len = xmu_dec_instruction[5:0] ;
			 t_fetch_base_ir_addr = xmu_dec_instruction[23:18]+ pc - 1;
			 t_fetch_base_global_addr = 
		      {{26{xmu_dec_instruction[11]}}, xmu_dec_instruction[11:6]} + xmu_rs1_in_fetch;
		      end
		 end
	  
	       
	       `X_JAL:
		 begin
		    t_pc = dec_branch_target[5:0];
		    t_save_pc = 1'b1;
		 end

	       `X_JLR:
		 begin
		    t_pc = saved_pc;
		 end


	       `X_JUMPSCALAR:
		 begin

		 end

	       `X_MOV_JR:
		 begin

		 end

	       	       
	       default:
		 begin

		 end
	       
	       
	     endcase // case (opcode)
	     
	  end // else: !if(stall)
	
	
	
     end // always@ (*)
   
   //TODO: hook these signals up
   assign fetch_req = t_fetch_req;
   assign fetch_base_global_addr = t_fetch_base_global_addr;
   assign fetch_base_ir_addr = t_fetch_base_ir_addr;
   assign fetch_len = t_fetch_len;




   always@(*)
     begin
	t_next_mem_op = r_mem_op;

	if(r_mem_op == 1'b1)
	  begin
	     if(ensemble_gnt)
	       t_next_mem_op = 1'b0;
	  end
	else
	  begin
	     if(xmu_ensemble_req & ~xmu_exec_non_block)
	       t_next_mem_op = 1'b1;
	  end
	
	
	

     end
   

   
   always@(posedge clk or posedge rst)
     begin: pc_register
	if(rst)
	  begin
	     pc <= 6'd0;
	     saved_pc <= 6'd0;
	     last_pc <= 6'd0;
	     r_mem_op <= 1'b0;
	  end
	else
	  begin
	     pc <= t_pc;
	     last_pc <= pc;
	     saved_pc <= t_save_pc ? pc + 6'd1 :  
			  xmu_write_link_reg ? xmu_link_pr_reg[5:0] : 
			  alu_write_link_reg ? alu_link_reg[5:0] :
			  saved_pc;
	     r_mem_op <= t_next_mem_op;
	  end
     end // block: pc_register

   reg n_barrier_req;

   always@(*)
     begin
	n_barrier_req = 1'b0;
	if(r_barrier_req == 1'b1)
	  begin
	     if(ensemble_barrier_release == 1'b1)
	       begin
		  n_barrier_req = 1'b0;
	       end
	     else
	       begin
		  n_barrier_req = 1'b1;
	       end
	  end // if (r_barrier_req == 1'b1)
	else
	  begin
	     n_barrier_req = xmu_barrier;
	  end
     end // always@ (*)
   
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_barrier_req <= 1'b0;
	  end
	else
	  begin
	     r_barrier_req <= n_barrier_req;
	  end
     end // always@ (posedge clk)


  
   assign hcf = r_hcf;
      
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_hcf <= 1'b0;
	  end
	else
	  begin
	     r_hcf <= r_hcf ? 1'b1 : xmu_exec_hcf;
	  end
     end // always@ (posedge clk)
   

   wire w_exec_nb_ld = 
	xmu_exec_non_block & 
	xmu_ensemble_req &
	xmu_exec_ld;
   
   wire w_exec_nb_st =
	xmu_exec_non_block &
	xmu_ensemble_req &
	xmu_exec_st;

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_non_block_st <= 1'b0;
	  end
	else
	  begin
	     r_non_block_st <= (r_non_block_st == 1'b0) ?
			       w_exec_nb_st :
			       (ensemble_gnt == 1'b1) ?
				1'b0 :
			       r_non_block_st;
	  end
     end // always@ (posedge clk)
   
   
     
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_non_block_ld <= 1'b0;
	  end
	else
	  begin
	     r_non_block_ld <= (r_non_block_ld == 1'b0) ? 
			       w_exec_nb_ld :
			       (grf_retire_non_block_load == 1'b1) ?
				 1'b0 :
			       r_non_block_ld;
	  end
     end // always@ (posedge clk)
   
	  
   

   
   
   pr_rf u0 (
	     // Outputs
	     .alu_pr1_out		(alu_pr_out1),
	     .alu_pr1_out_valid		(alu_pr_out1_valid),
	     
	     .alu_pr2_out		(alu_pr_out2),
	     .alu_pr2_out_valid		(alu_pr_out2_valid),
	     
	     .xmu_pr1_out		(w_xmu_pr_out1),
	     .xmu_pr1_out_valid		(xmu_pr_out1_valid),
	     
	     .xmu_pr2_out		(xmu_pr_out2),
	     .xmu_pr2_out_valid		(xmu_pr_out2_valid),
	     
	     // Inputs
	     .clk			(clk),
	     .rst			(rst),
	     
	     .alu_pr1_ptr		(alu_pr_ptr1),
	     .alu_pr1_ptr_valid		(alu_pr_ptr1_valid),
	     .alu_pr2_ptr		(alu_pr_ptr2),
	     .alu_pr2_ptr_valid		(alu_pr_ptr2_valid),
	     
	     .xmu_pr1_ptr		(t_xmu_pr_ptr1),
	     .xmu_pr1_ptr_valid		(t_xmu_pr_ptr1_valid),
	     
	     .xmu_pr2_ptr		(xmu_pr_ptr2),
	     .xmu_pr2_ptr_valid		(xmu_pr_ptr2_valid),
   
	     .xmu_wb_ptr		(xmu_pr_wb_ptr),
	     .xmu_wb_valid		(xmu_pr_wb_ptr_valid),
	     .xmu_wb_value		(xmu_link_pr_reg),
	     
	     .alu_wb_ptr		(alu_pr_wb_ptr),
	     .alu_wb_valid		(alu_pr_wb_ptr_valid),
	     .alu_wb_value		(alu_pr_wb_in)
	     );
   
   
endmodule // pc_branch_unit
