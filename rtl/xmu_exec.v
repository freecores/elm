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

module xmu_exec(/*AUTOARG*/
   // Outputs
   xmu_exec_instr_out, orf_ptr1, orf_ptr1_valid, orf_ptr2,
   orf_ptr2_valid, xmu_kill_alu_exec, xmu_exec_rd_out,
   xmu_exec_req_mem, xmu_zero, xmu_carry, xmu_sign, xmu_overflow,
   xmu_exec_lo, xmu_exec_hi, xmu_exec_ld_ensemble,
   xmu_exec_st_ensemble, xmu_exec_barrier, xmu_exec_mem_addr,
   remote_mem_op, remote_mem_not_block, xmu_exec_cswap,
   xmu_exec_swap_value, xmu_exec_ldsd, xmu_exec_stsd,
   xmu_exec_offset_value, xmu_exec_ldstream, xmu_exec_ststream,
   xmu_asr_ptr1, xmu_asr_ptr2, xmu_asr_ptr1_req, xmu_asr_ptr2_req,
   xmu_exec_stall, xmu_exec_hcf, xmu_exec_nonblock_load,
   // Inputs
   xmu_exec_instr_in, rs1_in, rs2_in, rs1_in_valid, rs2_in_valid,
   alu_ex_mem_ptr, alu_ex_mem_valid, alu_ex_mem_in, xmu_ex_mem_ptr,
   xmu_ex_mem_valid, xmu_ex_mem_in, prev_xmu_sign, prev_xmu_carry,
   prev_xmu_overflow, prev_xmu_zero, orf_ptr1_in, orf_ptr2_in,
   xmu_asr_ptr1_out, xmu_asr_ptr2_out, mr0_full, mr1_full, mr2_full,
   mr3_full, mr4_full, mr5_full, mr6_full, mr7_full
   );
   input [34:0] xmu_exec_instr_in;
   output [34:0] xmu_exec_instr_out;

   input [31:0]  rs1_in;
   input [31:0]  rs2_in;

   input 	 rs1_in_valid;
   input 	 rs2_in_valid;
   
   //forwarding network
   input [6:0] 	 alu_ex_mem_ptr;
   input 	 alu_ex_mem_valid;
   input [31:0]  alu_ex_mem_in;

   //tr1
   input [6:0] 	 xmu_ex_mem_ptr;
   input 	 xmu_ex_mem_valid;
   input [31:0]  xmu_ex_mem_in;

   input 	 prev_xmu_sign;
   input 	 prev_xmu_carry;
   input 	 prev_xmu_overflow;
   input 	 prev_xmu_zero;
   
   //address register files are
   //physically the same thing as orfs
   //design reuse!

   //operand register files
   input [31:0]  orf_ptr1_in;
   output [1:0]  orf_ptr1;
   output 	 orf_ptr1_valid;
      
   input [31:0]  orf_ptr2_in;
   output [1:0]  orf_ptr2;
   output 	 orf_ptr2_valid;
   
   output 	 xmu_kill_alu_exec;
     
   //result
   output [31:0] xmu_exec_rd_out;

   //load store signals
   output 	 xmu_exec_req_mem;

   output 	 xmu_zero;
   output 	 xmu_carry;
   output 	 xmu_sign;
   output 	 xmu_overflow;
   
   //high / lo signals for 64-bit stuff
   output 	 xmu_exec_lo;
   output 	 xmu_exec_hi;
   
   
   //load from ensemble memory
   output 	 xmu_exec_ld_ensemble;
   //store to ensemble memory
   output 	 xmu_exec_st_ensemble;

   output 	 xmu_exec_barrier;
      
   output [31:0] xmu_exec_mem_addr;


   output 	 remote_mem_op;
   
   /* Is this signal needed ? */
   output 	 remote_mem_not_block;
   
   /* xmu performing remote compare and swap */
   output 	 xmu_exec_cswap;

   output [31:0] xmu_exec_swap_value;

   output 	 xmu_exec_ldsd;
   output 	 xmu_exec_stsd;

   output [31:0] xmu_exec_offset_value;

   output 	 xmu_exec_ldstream;
   output 	 xmu_exec_ststream;
      
   output [1:0]  xmu_asr_ptr1;
   output [1:0]  xmu_asr_ptr2;

   output 	 xmu_asr_ptr1_req;
   output 	 xmu_asr_ptr2_req;

   output 	 xmu_exec_stall;
   
   output 	 xmu_exec_hcf;
   
   output 	 xmu_exec_nonblock_load;
   
   
   input [31:0]  xmu_asr_ptr1_out;
   input [31:0]  xmu_asr_ptr2_out;
   
   input 	 mr0_full;
   input 	 mr1_full;
   input 	 mr2_full;
   input 	 mr3_full;
   input 	 mr4_full;
   input 	 mr5_full;
   input 	 mr6_full;
   input 	 mr7_full;
      
   
   wire [7:0] 	 opcode = xmu_exec_instr_in[34:27];
   
   wire [5:0] 	 extend = xmu_exec_instr_in[26:21];
   wire [6:0] 	 rd_ptr = xmu_exec_instr_in[20:14];
   wire [6:0] 	 rs1_ptr = xmu_exec_instr_in[13:7];
   wire [6:0] 	 rs2_ptr = xmu_exec_instr_in[6:0];


   wire mrf_full_stall = 
	( 
	  (rd_ptr == `MR0) ? mr0_full :
	  (rd_ptr == `MR1) ? mr1_full :
	  (rd_ptr == `MR2) ? mr2_full :
	  (rd_ptr == `MR3) ? mr3_full :
	  (rd_ptr == `MR4) ? mr4_full :
	  (rd_ptr == `MR5) ? mr5_full :
	  (rd_ptr == `MR6) ? mr6_full :
	  (rd_ptr == `MR7) ? mr7_full :
	  1'b0
	  );

   assign xmu_exec_stall = mrf_full_stall;
   
   wire is_loop =
	(opcode == `X_LOOP_R ) |
	(opcode == `X_LOOP_A ) |
	(opcode == `X_LOOPS_R ) |
	(opcode == `X_LOOPS_A ) |
	(opcode == `X_LOOPC_R ) |
	(opcode == `X_LOOPC_A ) |
	(opcode == `X_LOOP_RI ) |
	(opcode == `X_LOOP_AI ) |
	(opcode == `X_LOOPS_RI ) |
	(opcode == `X_LOOPS_AI ) |
	(opcode == `X_LOOPC_RI ) |
	(opcode == `X_LOOPC_AI );
   
   
   wire is_cswap =
	(opcode == `X_CMPSWP);

   wire is_ldst_stream =
	(opcode == `X_LDSTREAM) |
	(opcode == `X_STSTREAM);
      
  
   wire is_st = 
	(opcode == `X_ST_I) |
	(opcode == `X_ST_IR) |
	(opcode == `X_ST_RR) |
	(opcode == `X_RB_ST_I) |
	(opcode == `X_RB_ST_IR) |
	(opcode == `X_RB_ST_RR) |
	(opcode == `X_RNB_ST_I) |
	(opcode == `X_RNB_ST_IR) |
	(opcode == `X_RNB_ST_RR) |
	/* Loading and storing stream descriptors
	 * are the same thing as stores to the
	 * ensemble processor*/
	(opcode == `X_LDSD_RI) |
	(opcode == `X_LDSD_RR) |
	(opcode == `X_STSD_RI) |
	(opcode == `X_STSD_RR) |
	(opcode == `X_LDSTREAM) |
	(opcode == `X_STSTREAM) |
	(opcode == `X_STSAVE_HI_I) |
	(opcode == `X_STSAVE_LO_I) | 
	(opcode == `X_STSAVE_HI_IR) |
	(opcode == `X_STSAVE_LO_IR);
   
   

   /* 
    * For stores, RS1 is the RD holds value 
    *
    */
   
   wire st_need_rs1 =
	(opcode == `X_ST_IR) |
	(opcode == `X_ST_RR) |
  	(opcode == `X_RB_ST_IR) |
	(opcode == `X_RB_ST_RR) |
    	(opcode == `X_RNB_ST_IR) |
	(opcode == `X_RNB_ST_RR) |
	(opcode == `X_LDSD_RI) |
	(opcode == `X_LDSD_RR) |
	(opcode == `X_STSD_RI) |
	(opcode == `X_STSD_RR) |
	(opcode == `X_LDSTREAM) |
	(opcode == `X_STSTREAM) | 
	(opcode == `X_STSAVE_HI_IR) |
	(opcode == `X_STSAVE_LO_IR);
      

   wire st_need_rs2 =
	(opcode == `X_ST_RR) |
	(opcode == `X_RB_ST_RR) | 
	(opcode == `X_RNB_ST_RR) |
	(opcode == `X_LDSD_RR) |
	(opcode == `X_STSD_RR) |
	(opcode == `X_LDSTREAM) |
	(opcode == `X_STSTREAM);

   wire is_stsave =
	(opcode == `X_STSAVE_LO_I) |
	(opcode == `X_STSAVE_HI_I) | 
	(opcode == `X_STSAVE_HI_IR) |
	(opcode == `X_STSAVE_LO_IR);
   
   wire st_rd_orf = (is_st | is_stsave) & (rd_ptr[6:2] ==5'b00010 );
   

   
   //stores don't use rd for write back!
   
   wire [6:0] st_rd_ptr = (is_st | is_stsave) ? 7'd0 : rd_ptr;
      
   wire [34:0] reassembled_instr = 
	       {opcode, extend, st_rd_ptr, rs1_ptr, rs2_ptr};
   
   
   assign xmu_exec_instr_out = xmu_exec_instr_in;

   //immediate generation
   wire [5:0] 	 rs1_imm = rs1_ptr[5:0];
   wire [5:0] 	 rs2_imm = rs2_ptr[5:0];

   //immediate for loads and stores
   wire [11:0] 	 imm12 = {rs1_imm, rs2_imm};

   
   //immediate for addi/subi
   //18 + 12 DOES NOT EQUAL 32!!!!!!!
   wire [11:0] 	 w_imm12 = {extend, rs2_imm};
   wire [19:0] 	 imm_ext20 = {20{extend[5]}};
   wire [31:0] 	 imm32 = {imm_ext20, w_imm12};

   //immediate for movi
   wire [14:0] 	 movi_sign = {15{extend[2]}};
   wire [31:0] 	 movi_imm = 
		 { movi_sign, extend[2:0], rs1_ptr, rs2_ptr};
   
   //where we can get operands from:
   //1) decode (rs1 / rs2 valid bit will be set)
   //2) forward from output latch of xmu / alu exec
   //3) operand register file
   //4) tr0 / tr1 (same thing as 2)
   //5) zero register

   
   /* forwarding for stores
    * it's possible that we need forward the store value
    * from the instruction in front
    * 
    * rs2 in `X_ST_RR has to be a non forwared operand register
    */

   //for rd
   //wire 	 st_need_fwd_rd = (is_st) & (!rs1_in_valid);
   //wire 	 st_need_fwd_rs1 = (st_need_rs1) & (!rs2_in_valid);

   //todo, this line completely borks the stores...
   //If the write value is valid (fwd_rd = 0) 
   // while the rs2 is not (fwd_rs1 = 1), 
   // both rs1/rs2 point to the same thing
   //                    
   // wire [6:0] 	 st_rs1_ptr = st_need_fwd_rd ? rd_ptr: rs1_ptr;

   wire [6:0] 	 st_rs1_ptr = (is_stsave | is_st) ? rd_ptr: rs1_ptr;
   
   wire [6:0] 	 st_rs2_ptr = st_need_rs1 ? rs1_ptr : rs2_ptr;
      

   wire st_two_orf = (rs1_ptr[6:2] ==  5'b00010) & 
	(rs2_ptr[6:2] == 5'b00010) & st_need_rs2;

   wire st_two_asr = (rs1_ptr[6:2] ==  5'b00001) & 
	(rs2_ptr[6:2] == 5'b00001) & st_need_rs2;
   
   
   wire 	 rs1_use_tr0 = (st_rs1_ptr == `TR0);
   wire 	 rs1_use_tr1 = (st_rs1_ptr == `TR1);
   
   wire 	 rs2_use_tr0 = (st_rs2_ptr == `TR0);
   wire 	 rs2_use_tr1 = (st_rs2_ptr == `TR1); 
   
   wire 	 rs1_use_zr = (st_rs1_ptr == `ZR) & ~is_loop;
   wire 	 rs2_use_zr = (st_rs2_ptr == `ZR);

   wire 	 rs1_use_orf = (st_rs1_ptr[6:2] == 5'b00010);
   wire 	 rs2_use_orf = (st_rs2_ptr[6:2] == 5'b00010);

   reg [1:0] 	 t_asr_ptr2_st_rr;
   reg 		 t_asr_ptr2_st_rr_valid;
   
   
   wire 	 rs1_use_asr = (st_rs1_ptr[6:2] == 5'b00001) 
		 & !rs1_in_valid;
   
   wire 	 rs2_use_asr = (st_rs2_ptr[6:2] == 5'b00001)
		 & !rs2_in_valid;

   assign xmu_asr_ptr1 = st_two_asr ? rs1_ptr[1:0] : st_rs1_ptr[1:0];
   
   assign xmu_asr_ptr2 = t_asr_ptr2_st_rr_valid ? t_asr_ptr2_st_rr : st_rs2_ptr[1:0];

 

   wire forwardable_rs1 = !(
			    (st_rs1_ptr ==`MR0) |
			    (st_rs1_ptr ==`MR1) |
			    (st_rs1_ptr ==`MR2) |
			    (st_rs1_ptr ==`MR3) |			    
   			    (st_rs1_ptr ==`MR4) |
			    (st_rs1_ptr ==`MR5) |
			    (st_rs1_ptr ==`MR6) |
			    (st_rs1_ptr ==`MR7));
   
   wire forwardable_rs2 = !(
			    (st_rs2_ptr ==`MR0) |
			    (st_rs2_ptr ==`MR1) |
			    (st_rs2_ptr ==`MR2) |
			    (st_rs2_ptr ==`MR3) |			    
   			    (st_rs2_ptr ==`MR4) |
			    (st_rs2_ptr ==`MR5) |
			    (st_rs2_ptr ==`MR6) |
			    (st_rs2_ptr ==`MR7));
   
   
   
   wire 	 fwd_rs1_from_alu = 
		 (alu_ex_mem_ptr == st_rs1_ptr)
		 & (alu_ex_mem_valid) & (st_rs1_ptr != 7'd0)
		 & forwardable_rs1;
      
   wire 	 fwd_rs2_from_alu = 
		 (alu_ex_mem_ptr == st_rs2_ptr)
		 & (alu_ex_mem_valid) & (st_rs2_ptr != 7'd0)
		 & forwardable_rs2;
      
   wire 	 fwd_rs1_from_xmu = 
		 (xmu_ex_mem_ptr == st_rs1_ptr)
		 & (xmu_ex_mem_valid) & (st_rs1_ptr != 7'd0)
		 & forwardable_rs1;
   
   wire 	 fwd_rs2_from_xmu = 
		 (xmu_ex_mem_ptr == st_rs2_ptr)
		 & (xmu_ex_mem_valid) & (st_rs2_ptr != 7'd0)
		 & forwardable_rs2;
    //rch check this...9
   assign xmu_asr_ptr1_req = (rs1_use_asr & 
			      (!fwd_rs1_from_xmu | !fwd_rs1_from_alu)) |
			     st_two_asr;
   			
  
   assign xmu_asr_ptr2_req = (rs2_use_asr &
			      (!fwd_rs2_from_xmu | !fwd_rs2_from_alu)) |
			     t_asr_ptr2_st_rr_valid;
      
 
			    

   
   wire [6:0] 	 rs3_ptr = {1'b0, extend};
   
   wire fwd_rs3_from_alu = (alu_ex_mem_ptr == rs3_ptr) &
	& (alu_ex_mem_valid) & (is_cswap | is_ldst_stream );

   wire fwd_rs3_from_xmu = (xmu_ex_mem_ptr == rs3_ptr) &
	& (xmu_ex_mem_valid) & (is_cswap | is_ldst_stream );

   
   reg [1:0] 	 t_orf_ptr1, t_orf_ptr2;
   reg  	 t_orf_ptr1_valid, t_orf_ptr2_valid;

   reg [1:0] 	 t_orf_ptr2_st_rr;
   reg 		 t_orf_ptr2_st_rr_valid;
      

   /* 
    * Compare and swap always uses orf2 port for the
    * set value
    * */
   wire 	 rs3_use_tr0 = (rs3_ptr == `TR0);
   wire 	 rs3_use_tr1 = (rs3_ptr == `TR1);
   
   wire 	 rs3_need_orf = !(fwd_rs3_from_alu | fwd_rs3_from_xmu | 
				  rs3_use_tr0 | rs3_use_tr1 );
   
   assign orf_ptr1 = 
		     (is_cswap | is_ldst_stream ) & rs3_need_orf ?  extend[1:0] : 
		     st_two_orf ? t_orf_ptr2_st_rr : 
		     t_orf_ptr1;
   
   assign orf_ptr1_valid = (is_cswap | is_ldst_stream) & rs3_need_orf ? 1'b1 : 
			   st_two_orf ? t_orf_ptr2_st_rr_valid :
			   t_orf_ptr1_valid;  

   wire [31:0] w_rs3_value = 
	       (fwd_rs3_from_alu | rs3_use_tr0 ) ? alu_ex_mem_in :
	       (fwd_rs3_from_xmu | rs3_use_tr1 ) ? xmu_ex_mem_in :
	       orf_ptr1_in;
      
   assign xmu_exec_swap_value = w_rs3_value;

     
   assign orf_ptr2 =
		    (st_need_rs2 & ~st_two_orf & t_orf_ptr2_st_rr_valid ) 
     ? t_orf_ptr2_st_rr :  t_orf_ptr2;
   
   assign orf_ptr2_valid = 
			   (st_need_rs2 & ~st_two_orf & t_orf_ptr2_st_rr_valid) ? 1'b1 :
			   t_orf_ptr2_valid;
      
    
   reg [31:0] 	 t_rs1_value, t_rs2_value;
   wire 	 w_rs1_really_valid = 
		 rs1_in_valid  
		// & ~fwd_rs1_from_alu
		// & ~fwd_rs1_from_xmu 
		// & ~rs1_use_tr0 
		// & ~rs1_use_tr1
		 ;
   
   //final rs1 decoder
   always@(*)
     begin: rs1_exec_dec
	t_rs1_value = 32'd0;
	t_orf_ptr1 = 2'd0;
	t_orf_ptr1_valid = 1'b0;
		
	/*if(st_rd_orf)
	  begin
	     t_orf_ptr1 =rd_ptr[1:0];
	     t_orf_ptr1_valid  =1'b1;
	     t_rs1_value = orf_ptr1_in;
	  end

	
	else */if(rs1_use_zr)
	  begin
	     //just being explicit
	     t_rs1_value = 32'd0;
	  end


	
	else if(rs1_use_tr0)
	  begin
	     t_rs1_value = alu_ex_mem_in;
	  end
	else if(rs1_use_tr1)
	  begin
	     t_rs1_value = xmu_ex_mem_in;
	  end
	

	else if(fwd_rs1_from_alu)
	  begin
	     t_rs1_value = alu_ex_mem_in;
	  end
	else if(fwd_rs1_from_xmu)
	  begin
	     t_rs1_value = xmu_ex_mem_in;
	  end

	//HMM: This may break EVERYTHING
	else if(w_rs1_really_valid)
	  begin
	     t_rs1_value = rs1_in;
	  end

	else if(st_rd_orf)
	  begin
	     t_orf_ptr1 =rd_ptr[1:0];
	     t_orf_ptr1_valid  =1'b1;
	     t_rs1_value = orf_ptr1_in;
	  end
	else if(rs1_use_asr)
	  begin
	     t_rs1_value = xmu_asr_ptr1_out;
	  end
	

	//whatever came into exec from dec was good




	//tr* == ex_mem latch

	else if(rs1_use_orf)
	  begin
	     t_orf_ptr1 =st_rs1_ptr[1:0];
	     t_orf_ptr1_valid  =1'b1;
	     t_rs1_value = orf_ptr1_in;
	  end
     end // block: rs1_exec_dec


   //read orf for rs2 of store rs1 + rs2
   reg [31:0] t_st_orf_rr;


   always@(*)
     begin
	t_st_orf_rr = 32'd0;
	t_orf_ptr2_st_rr = 2'd0;
	t_orf_ptr2_st_rr_valid = 1'b0;
	t_asr_ptr2_st_rr = 2'd0;
	t_asr_ptr2_st_rr_valid = 1'b0;   

	if(st_two_orf)
	  begin
	     t_orf_ptr2_st_rr = rs2_ptr[1:0];
	     t_orf_ptr2_st_rr_valid = 1'b1;   

	     t_st_orf_rr = orf_ptr1_in;   

	  end
		
	else if((rs2_ptr[6:2] == 5'b00010) & st_need_rs2 )
	  begin
	     t_orf_ptr2_st_rr = rs2_ptr[1:0];
	     t_orf_ptr2_st_rr_valid = 1'b1;   

	     t_st_orf_rr = orf_ptr2_in;
	  end

	else if((rs2_ptr[6:2] == 5'b00001) & st_need_rs2 )
	  begin
	     t_asr_ptr2_st_rr = rs2_ptr[1:0];
	     t_asr_ptr2_st_rr_valid = 1'b1;   

	     t_st_orf_rr = xmu_asr_ptr2_out;
	  end
	
     end
   

   
   
   //final rs2 decoder
   always@(*)
     begin: rs2_exec_dec
	t_rs2_value = 32'd0;
	t_orf_ptr2 = 2'd0;
	t_orf_ptr2_valid = 1'b0;

	if(rs2_use_zr)
	  begin
	     //just being explicit
	     t_rs2_value = 32'd0;
	  end
	else if(fwd_rs2_from_alu)
	  begin
	     t_rs2_value = alu_ex_mem_in;

	  end
	else if(fwd_rs2_from_xmu)
	  begin
	     t_rs2_value = xmu_ex_mem_in;
	  end
	


	else if(rs2_use_tr0)
	  begin
	     t_rs2_value = alu_ex_mem_in;
	  end
	else if(rs2_use_tr1)
	  begin
	     t_rs2_value = xmu_ex_mem_in;
	  end

	else if(rs2_use_asr)
	  begin
	     t_rs2_value = st_two_asr ? xmu_asr_ptr1_out : xmu_asr_ptr2_out;
	  end

	else if(rs2_use_orf)
	  begin
	     t_orf_ptr2 = st_rs2_ptr[1:0];
	     t_orf_ptr2_valid  =1'b1;
	     t_rs2_value = (rs2_in_valid & is_ldst_stream) ? rs2_in : orf_ptr2_in;
	  end
	
	//todo: see if we need to move this up...
	//whatever came into exec from dec was good
	else if(rs2_in_valid /*& !is_ldst_stream*/)
	  begin
	     t_rs2_value = rs2_in;
	  end


	//tr* == ex_mem latch

	




	
     end // block: rs2_exec_dec


   reg [31:0] t_result;
   reg [31:0] t_mem_addr;
   
   reg 	      t_pred_kill;
   reg 	      t_req_mem;
   reg 	      t_ld_ensemble;
   reg 	      t_st_ensemble;
   
   
   reg 	      t_hi;
   reg 	      t_lo;

   reg 	      t_barrier;
   
   reg 	      t_remote_mem_op;
   reg 	      t_non_block;


   reg 	      t_ldsd;
   reg 	      t_stsd;


   assign xmu_exec_ldsd = t_ldsd;
   assign xmu_exec_stsd = t_stsd;
   

   reg 	      t_exec_cswap;
   
   assign xmu_exec_cswap = t_exec_cswap;
   
   
   assign remote_mem_op = t_remote_mem_op;
   assign remote_mem_not_block = t_non_block;
  
   assign xmu_exec_hi = t_hi;
   assign xmu_exec_lo = t_lo;

   assign xmu_exec_barrier = t_barrier;
      
   
   assign xmu_kill_alu_exec = t_pred_kill;
   assign xmu_exec_req_mem = t_req_mem;
   assign xmu_exec_ld_ensemble = t_ld_ensemble;
   assign xmu_exec_st_ensemble = t_st_ensemble;
   assign xmu_exec_mem_addr = t_mem_addr;

   //todo: hook these up...
   reg 	      t_xmu_carry;
   reg 	      t_xmu_overflow;
   reg 	      t_xmu_sign;
   
   wire       xmu_zero = (t_result == 32'd0);
   wire       xmu_carry = t_xmu_carry;
   wire       xmu_overflow = t_xmu_overflow;
   wire       xmu_sign = t_xmu_sign;

   
   wire [3:0] prev_status = {prev_xmu_carry, prev_xmu_sign,
			     prev_xmu_overflow, prev_xmu_zero};
   

   reg [31:0] t_offset;
   reg 	      t_ldstream;
   reg 	      t_ststream;
      
   assign xmu_exec_offset_value = t_offset;
   assign xmu_exec_ldstream = t_ldstream;
   assign xmu_exec_ststream = t_ststream;

   reg 	      t_hcf;
   reg 	      t_nb_load;
   
   assign xmu_exec_hcf = t_hcf;
   assign xmu_exec_nonblock_load = t_nb_load;
  
   always@(*)
     begin
	t_result = 32'd0;
	t_pred_kill = 1'b0;
	t_req_mem = 1'b0;
	t_ld_ensemble = 1'b0;
	t_st_ensemble = 1'b0;
	t_mem_addr = 32'd0;

	t_exec_cswap = 1'b0;
		
	t_hi = 1'b0;
	t_lo = 1'b0;

	t_barrier = 1'b0;

	t_xmu_carry = 0;
	t_xmu_sign = 0;
	t_xmu_overflow = 0;

	t_remote_mem_op = 1'b0;
	t_non_block = 1'b0;

	t_ldsd = 1'b0;
	t_stsd = 1'b0;

	t_offset = 32'd0;
	t_ldstream = 1'b0;
	t_ststream = 1'b0;

	t_hcf = 1'b0;
	t_nb_load = 1'b0;
		
	case(opcode)
	  `X_NOP:
	       begin
		  t_result = xmu_ex_mem_in;
	       end


	  `X_MOV:
	    begin
	       t_result = t_rs1_value;
	    end
	  
	  `X_MOVI:
	    begin
	       t_result = movi_imm;
	       
	       
	    end
	  	  
	  `X_ADD:
	    begin
	       t_result = t_rs1_value + t_rs2_value;
	    end
	  `X_TEST:
	    begin
	       /*
		prev_status = {prev_alu_carry, prev_alu_sign,
		prev_alu_overflow, prev_alu_zero};
		*/
	       t_result[31:1] = 31'd0;
	       if(!extend[0])  /*Anding of results*/
		 begin
		    t_result[0] = ((rs1_ptr[3] == 1'b0) | (prev_status[3] == rs2_ptr[3])) &
			       ((rs1_ptr[2] == 1'b0) | (prev_status[2] == rs2_ptr[2])) &
			       ((rs1_ptr[1] == 1'b0) | (prev_status[1] == rs2_ptr[1])) &
			       ((rs1_ptr[0] == 1'b0) | (prev_status[0] == rs2_ptr[0]));
		 end
	       else  /*OR'ing of results*/
		 begin
		    t_result[0] = ((rs1_ptr[3] == 1'b1) & (prev_status[3] == rs2_ptr[3])) |
			       ((rs1_ptr[2] == 1'b1) & (prev_status[2] == rs2_ptr[2])) |
			       ((rs1_ptr[1] == 1'b1) & (prev_status[1] == rs2_ptr[1])) |
			       ((rs1_ptr[0] == 1'b1) & (prev_status[0] == rs2_ptr[0]));
		    
		 end
	    end
	  

	  `X_ADDI:
	    begin
	       t_result = t_rs1_value + imm32;
	    end


	  `X_SUB:
	    begin
	       t_result = t_rs1_value - t_rs2_value;
	    end

	  `X_SUBI:
	    begin
	       t_result = t_rs1_value - imm32;
	    end
	  
	  
	  
	  
	  `X_LD_I:
	    begin
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1;
	       t_mem_addr = {14'd0, extend, imm12};
	       
	    end

	  `X_LD_IR:
	    begin
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1;
	       t_mem_addr = t_rs1_value + {{20{extend[5]}}, extend, rs2_imm} ;
	    end

	  `X_LD_RR:
	    begin
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1; 
    	       t_mem_addr = t_rs1_value + t_rs2_value;
	    end


	  `X_CMPSWP:
	    begin
	       t_exec_cswap = 1'b1;
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1;
	       t_remote_mem_op = 1'b1;
	        
	       //compare address is rs1
	       t_mem_addr = t_rs1_value;

	       //comparison value is rs2
	       t_result = t_rs2_value;
	       
	       //swap value is set by assign statement
	       
	    end
	  
	  
	  /* blocking remote loads */
	  `X_RB_LD_I:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1;
	       t_mem_addr = {14'd0, extend, imm12};
	       
	    end

	  `X_RB_LD_IR:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1;
	       t_mem_addr = t_rs1_value + {{20{extend[5]}}, extend, rs2_imm} ;
	    end

	  `X_RB_LD_RR:
	    begin
	       t_remote_mem_op = 1'b1;  
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1; 
    	       t_mem_addr = t_rs1_value + t_rs2_value;
	    end


	  /* Non blocking remote loads */
	  `X_RNB_LD_I:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_non_block = 1'b1;    	       
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1;
	       t_mem_addr = {14'd0, extend, imm12};
	       t_nb_load = 1'b1;
	    end

	  `X_RNB_LD_IR:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_non_block = 1'b1;       
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1;
	       t_mem_addr = t_rs1_value + {{20{extend[5]}}, extend, rs2_imm} ;
	       t_nb_load = 1'b1;
	    end

	  `X_RNB_LD_RR:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_non_block = 1'b1;
	       t_req_mem = 1'b1;
	       t_ld_ensemble = 1'b1; 
    	       t_mem_addr = t_rs1_value + t_rs2_value;
	       t_nb_load = 1'b1;
	    end  

	  `X_LDREST_LO_I:
	    begin
	       t_lo = 1'b1;
	       t_req_mem = 1'b1;
	       t_mem_addr = movi_imm;
	       //{20'd0, imm12};
	       t_ld_ensemble = 1'b1;
	    end

	  `X_LDREST_HI_I:
	    begin
	       t_hi = 1'b1;
	       t_req_mem = 1'b1;
	       t_mem_addr = movi_imm;
	       //{20'd0, imm12};
	       t_ld_ensemble = 1'b1;
	    end

	  `X_LDREST_LO_IR:
	    begin
	       t_lo = 1'b1;
	       t_req_mem = 1'b1;
	       t_mem_addr = t_rs1_value + {26'd0, rs2_imm};
	       t_ld_ensemble = 1'b1;
	    end

	  `X_LDREST_HI_IR:
	    begin
	       t_hi = 1'b1;
	       t_req_mem = 1'b1;
	       t_mem_addr = t_rs1_value + {26'd0, rs2_imm};
	       t_ld_ensemble = 1'b1;
	    end

	  
	  
	  
	  /* Local store instructions */
	  `X_ST_I:
	    begin
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = {14'd0, extend, imm12};
	       t_result = t_rs1_value;
	    end
	  	 
	  `X_ST_IR:
	    begin
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + {{20{extend[5]}}, extend, rs2_imm} ;
	       t_result = t_rs1_value; 	       
	    end
	  `X_ST_RR:
	    begin
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + t_st_orf_rr;
	       t_result = t_rs1_value;
	    end
	  `X_STSAVE_LO_I:
	    begin
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = movi_imm;
	       t_result = t_rs1_value;
	    end
	  `X_STSAVE_HI_I:
	    begin
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr =  t_rs2_value + {26'd0, rs2_imm};
	       t_result = t_rs1_value;
	    end
	  `X_STSAVE_LO_IR:
	    begin
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr =  t_rs2_value + {26'd0, rs2_imm};
	       t_result = t_rs1_value;
	    end
	  `X_STSAVE_HI_IR:
	    begin
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = movi_imm;
	       t_result = t_rs1_value;
	    end
	  
	  /* Remote blocking stores */
	  `X_RB_ST_I:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = {14'd0, extend, imm12};
	       t_result = t_rs1_value;
	    end
	  	 
	  `X_RB_ST_IR:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + {{20{extend[5]}}, extend, rs2_imm} ;
	       t_result = t_rs1_value; 	       
	    end


	  `X_RB_ST_RR:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + t_st_orf_rr;
	       t_result = t_rs1_value;
	    end


	  /* Remote non-blocking stores */
	  `X_RNB_ST_I:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_non_block = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = {14'd0, extend, imm12};
	       t_result = t_rs1_value;
	    end
	  	 
	  `X_RNB_ST_IR:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_non_block = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + {20'd0, extend, rs2_imm} ;
	       t_result = t_rs1_value; 	       
	    end


	  `X_RNB_ST_RR:
	    begin
	       t_remote_mem_op = 1'b1;
	       t_non_block = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + t_st_orf_rr;
	       t_result = t_rs1_value;
	    end
	  
	  
	  `X_LOOPS_R:
	    begin
	       t_result = t_rs1_value;
	    end

	  `X_LOOPS_A:
	    begin
	       t_result = t_rs1_value;
	    end

	  `X_LOOPC_R:
	    begin
	       t_result = t_rs1_value;
	    end	  

	  `X_LOOPC_A:
	    begin
	       t_result = t_rs1_value;
	    end

	  `X_PRED_S:
	    begin  
	       if(t_rs1_value[0] == 1'b1)
		 begin
		    t_pred_kill = 1'b1;
		 end
	       
	       t_result = 32'd0;
	    end

	  `X_PRED_C:
	    begin
	       if(t_rs1_value[0] == 1'b0)
		 begin
		    t_pred_kill = 1'b1;
		 end

	       
	       t_result = 32'd0;
	    end	

	  `X_HCF:
	    begin
	       t_hcf = 1'b1;
	    end
	  

	  `X_CMP_EQ:
	    begin	       
	       t_result = (t_rs1_value == t_rs2_value) ? 32'd1 : 32'd0;
	    end

	  `X_CMP_NE:
	    begin
	       t_result = (t_rs1_value != t_rs2_value) ? 32'd1 : 32'd0;
	    end

	  `X_CMP_LT:
	    begin
	       //rs1 < 0, rs2 > 0 
	       if(~t_rs1_value[31] & t_rs2_value[31])  t_result = 32'd1;
	       else if(t_rs1_value[31] & ~t_rs2_value[31])  t_result = 32'd0;
	       else 
	       	 t_result = (t_rs1_value < t_rs2_value) ? 32'd1 : 32'd0;
	    end
	  
	  `X_CMP_LTE:
	    begin
	       if(~t_rs1_value[31] & t_rs2_value[31])  t_result = 32'd1;
	       else if(t_rs1_value[31] & ~t_rs2_value[31])  t_result = 32'd0;
	       else 
	       	 t_result = (t_rs1_value < t_rs2_value | t_rs1_value == t_rs2_value) ? 32'd1 : 32'd0;
	    end
	  `X_CMP_ULT:
	    begin
	       t_result = (t_rs1_value < t_rs2_value) ? 32'd1 : 32'd0;
	    end

	  `X_CMP_ULTE:
	    begin
	       t_result = ((t_rs1_value < t_rs2_value) 
			   | (t_rs1_value == t_rs2_value)) ?
			  32'd1 : 32'd0;
	    end
	  
	  

	  `X_LDSD_RI:
	    begin
	       t_ldsd = 1'b1;
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + {20'd0, extend, rs2_imm} ;
	       t_result = t_rs1_value;  
	    end

	  `X_LDSD_RR:
	    begin
	       t_ldsd = 1'b1;
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + t_st_orf_rr;
	       t_result = t_rs1_value;      
	    end

	  `X_STSD_RI:
	    begin
	       t_stsd = 1'b1;
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + {20'd0, extend, rs2_imm} ;
	       t_result = t_rs1_value;   
	    end
	  	  
	  `X_STSD_RR:
	    begin
	       t_stsd = 1'b1;
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       t_mem_addr = t_rs2_value + t_st_orf_rr;
	       t_result = t_rs1_value;
	    end
	  
	  `X_LDSTREAM:
	    begin
	       t_ldstream = 1'b1;
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;
	       
	       //rd: t_rs1_value
	       //rs1: t_rs2_value
	       //rs2: t_st_orf_rr
	       //rs3: w_rs3_value

	       //dest
	       t_mem_addr = t_rs1_value;
	       //data
	       t_result = t_rs2_value;
	       //offset
	       t_offset = t_st_orf_rr;
	       	       
	    end

	  `X_STSTREAM:
	    begin
	       t_ststream = 1'b1;
	       t_remote_mem_op = 1'b1;
	       t_req_mem = 1'b1;
	       t_st_ensemble = 1'b1;


	       //dest
	       t_mem_addr = t_rs1_value;
	       //data
	       t_result = t_rs2_value;
	       //offset
	       t_offset = t_st_orf_rr;
	       
	    end
	   

	  `X_BARRIER:
	    begin
	       t_barrier = 1'b1;
	    end
	  


	  

	  default:
	    begin
	       t_result = 32'd0;
	    end
	  	  
	  endcase
     end // always (*)
   

     
   
   
   assign xmu_exec_rd_out = t_result;
   
endmodule // xmu_exec
