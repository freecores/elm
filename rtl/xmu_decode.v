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

module xmu_decode(/*AUTOARG*/
   // Outputs
   xmu_dec_strest_ptr, xmu_decode_instr_out, rs1_out, rs2_out,
   rs1_out_valid, rs2_out_valid, xmu_decode_gen_stall, grf_ptr1,
   grf_ptr2, grf_ptr1_valid, grf_ptr2_valid, xp_ptr1, xp_ptr2,
   xp_ptr1_valid, xp_ptr2_valid, xp_rd_valid, xp_rd_ptr, xp_store_ptr,
   xp_store_ptr_valid, pr_ptr1, pr_ptr2, pr_r1_valid, pr_r2_valid,
   mr_ptr1, mr_ptr2, mr_r1_valid, mr_r2_valid, st_rd_from_xprf,
   stop_the_jfetch,
   // Inputs
   instr_in, xmu_exec_opcode, alu_ex_mem_ptr, alu_ex_mem_valid,
   alu_ex_mem_in, xmu_ex_mem_ptr, xmu_ex_mem_valid, xmu_ex_mem_in,
   link_reg, arf_strest_value, alu_id_ex_ptr, alu_id_ex_valid,
   xmu_id_ex_ptr, xmu_id_ex_valid, grf_r1_in, grf_r2_in,
   grf_r1_in_valid, grf_r2_in_valid, xp_store_data, xp_grf_ptr1,
   xp_grf_ptr2, xp_grf_ptr1_valid, xp_grf_ptr2_valid, xp_grf_rd_ptr,
   xp_grf_rd_ptr_valid, pr_r1_in, pr_r2_in, pr_r1_in_valid,
   pr_r2_in_valid, branch_pr, mr_r1_in, mr_r2_in, mr_r1_in_valid,
   mr_r2_in_valid
   );
   input [31:0] instr_in;
   input [7:0] 	xmu_exec_opcode;
   
   output [6:0] xmu_dec_strest_ptr;
   output [34:0] xmu_decode_instr_out;

   output [31:0] rs1_out;
   output [31:0] rs2_out;

   output 	 rs1_out_valid;
   output 	 rs2_out_valid;

   output 	 xmu_decode_gen_stall;


   //forwarding network (from alu ex_mem latch)
   input [6:0] 	 alu_ex_mem_ptr;
   input 	 alu_ex_mem_valid;
   input [31:0]  alu_ex_mem_in;

   //forwarding network (from xmu ex_mem latch)
   input [6:0] 	 xmu_ex_mem_ptr;
   input 	 xmu_ex_mem_valid;
   input [31:0]  xmu_ex_mem_in;

   input [5:0]  link_reg;
   input [31:0]  arf_strest_value;
   
   //*ideally* we would forward through tr0
   input [6:0] 	 alu_id_ex_ptr;
   input 	 alu_id_ex_valid;
   
   input [6:0] 	 xmu_id_ex_ptr;
   input 	 xmu_id_ex_valid;
  //gpr
   output [4:0]  grf_ptr1;
   output [4:0]  grf_ptr2;

   output 	 grf_ptr1_valid;
   output 	 grf_ptr2_valid;
      
   input [31:0]  grf_r1_in;
   input [31:0]  grf_r2_in;

   input 	 grf_r1_in_valid;
   input 	 grf_r2_in_valid;

   //idx
   output [1:0]  xp_ptr1;
   output [1:0]  xp_ptr2;
   
   output 	 xp_ptr1_valid;
   output 	 xp_ptr2_valid;

   output 	 xp_rd_valid;
   output [1:0]  xp_rd_ptr;
   
   output [2:0]  xp_store_ptr;
   output 	 xp_store_ptr_valid;
   input [31:0]  xp_store_data;
   
   
   //mark II index registers
   input [4:0] 	 xp_grf_ptr1;
   input [4:0] 	 xp_grf_ptr2;
   input 	 xp_grf_ptr1_valid;
   input 	 xp_grf_ptr2_valid;
   
   input [4:0] 	 xp_grf_rd_ptr;
   input 	 xp_grf_rd_ptr_valid;
   

   
   //predicate
   output [2:0]  pr_ptr1;
   output [2:0]  pr_ptr2;

   output 	 pr_r1_valid;
   output 	 pr_r2_valid;
   
   input [8:0] 	 pr_r1_in;
   input [8:0] 	 pr_r2_in;

   input 	 pr_r1_in_valid;
   input 	 pr_r2_in_valid;

   //post branch unit pr
   input [31:0]  branch_pr;
      
   //message registers
   output [2:0]  mr_ptr1;
   output [2:0]  mr_ptr2;

   output 	 mr_r1_valid;
   output 	 mr_r2_valid;

   /* ITS A TRAP: xprf should have read pointer, not 
    write pointer bumped */
   output 	 st_rd_from_xprf;
   
   
   input [31:0]  mr_r1_in;
   input [31:0]  mr_r2_in;

   input 	 mr_r1_in_valid;
   input 	 mr_r2_in_valid;

   wire [7:0] 		 opcode = instr_in[31:24];
   //as defined by curt's document
   wire [6:0] 		 rd_encode = instr_in[23:17];
   wire [6:0] 		 rs1_encode = instr_in[16:10];
      
   wire [5:0] 		 extend = instr_in[23:18];
   wire [5:0] 		 rd = instr_in[17:12];
   wire [5:0] 		 rs1 = instr_in[11:6];
   wire [5:0] 		 rs2 = instr_in[5:0];

   /*
   function [6:0] xmu_rs_7b(input [7:0] opcode, input [5:0] rs_ptr, 
    input [6:0] 	 rd_encode );
      begin
	 //ERROR HERE!
/* -----\/----- EXCLUDED -----\/-----
	 xmu_rs_7b = (opcode == `X_STSAVE_LO_I) |
		     (opcode == `X_STSAVE_LO_IR) |
		     (opcode == `X_STSAVE_HI_I) |
		     (opcode == `X_STSAVE_HI_IR) ?
		     rd_encode :
 -----/\----- EXCLUDED -----/\----- 
	 xmu_rs_7b =  {1'b0, rs_ptr};
      end
   endfunction // xmu_rs_7b
 */

   function [6:0] xmu_rs1_7b(input [7:0] opcode, input [6:0] rs1_encode,
    input [5:0] 	 rs_ptr);
       begin
	  case(opcode)
	    `X_MOV: 
	      begin
		 xmu_rs1_7b = rs1_encode;
	      end
	    `X_LDREST_LO_IR: 
	      begin
		 xmu_rs1_7b = rs1_encode;
	      end
	    `X_LDREST_HI_IR: 
	      begin
		 xmu_rs1_7b = rs1_encode;
	      end
	    `X_STSAVE_LO_IR: 
	      begin
		 xmu_rs1_7b = rs1_encode;
	      end
	    `X_STSAVE_HI_IR: 
	      begin
		 xmu_rs1_7b = rs1_encode;
	      end
	    `X_JUMPSIMD:
	      begin
		 xmu_rs1_7b = 7'd0;
	      end
	    `X_JUMPSCALAR:
	      begin
		 xmu_rs1_7b = 7'd0;
	      end	    
		
	    default:
	      begin
		 xmu_rs1_7b = {1'b0, rs_ptr};
	      end
	  endcase // case (opcode)
       end
    endfunction // xmu_rs_7b

   
   function [6:0] xmu_rs2_7b(input [7:0] opcode, input [5:0] rs_ptr);
      begin
	 case(opcode)
	   `X_JUMPSIMD:
	      begin
		 xmu_rs2_7b = 7'd0;
	      end
	    `X_JUMPSCALAR:
	      begin
		 xmu_rs2_7b = 7'd0;
	      end
	   default:
	     begin
		xmu_rs2_7b = {1'b0, rs_ptr};
	     end
	 endcase // case (opcode)
      end
   endfunction // xmu_rs2_7b

   //rch, edit
   function [6:0] xmu_rd_7b(input [7:0] opcode, input [6:0] rd_encode,
    input [5:0] rd_ptr);
      
      begin
	 case(opcode)
	   `X_TEST:
	     begin
		xmu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `X_CMP_EQ:
	     begin
		xmu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `X_CMP_NE:
	     begin
		xmu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `X_CMP_LT:
	     begin
		xmu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `X_CMP_LTE:
	     begin
		xmu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `X_CMP_ULT:
	     begin
		xmu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `X_CMP_ULTE:
	     begin
		xmu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `X_MOV:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   `X_MOVI:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   /* THIS CODE BREAKS THE PROCESSOR,
	    RD GETS SCREWED UP */
	   `X_LDREST_LO_I:
	      begin
		 xmu_rd_7b = rd_encode;
	      end
	   `X_LDREST_HI_I:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   `X_LDREST_LO_IR:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   `X_LDREST_HI_IR:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   `X_STSAVE_LO_I:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   `X_STSAVE_HI_I:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   `X_STSAVE_LO_IR:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   `X_STSAVE_HI_IR:
	     begin
		xmu_rd_7b = rd_encode;
	     end
	   default:
	     begin
		xmu_rd_7b = {1'b0, rd_ptr};
	     end
	 endcase // case (opcode)
      end
   endfunction // xmu_rd_7b

   //don't need to access register files for a handful of
   //immediate instructions

   //don't need rs1 or rs2
   wire       is_movi = (opcode == `X_MOVI);
   wire       is_mov = (opcode == `X_MOV);
      
   //don't need rs1 or rs2
   wire       is_nop = (opcode == `X_NOP);  

   //don't need rs1 or rs2
   wire       is_ld_imm = 
	      (opcode == `X_LD_I) | 
	      (opcode == `X_RB_LD_I) | 
	      (opcode == `X_RNB_LD_I) | 
	      (opcode == `X_LDREST_LO_I) | 
	      (opcode == `X_LDREST_HI_I);

   wire       is_ld_ri =
	      (opcode == `X_LD_IR  ) |
	      (opcode == `X_RB_LD_IR  ) |
	      (opcode == `X_RNB_LD_IR ) |
	      (opcode == `X_LDREST_LO_IR) | 
	      (opcode == `X_LDREST_HI_IR);
   

   //rd holds register we want to read
   wire       is_st = 
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
	      /* Load stream and store stream are a more
	       * basically stores too */
	      (opcode == `X_LDSTREAM) |
	      (opcode == `X_STSTREAM) |
	      (opcode == `X_STSAVE_LO_I) |
	      (opcode == `X_STSAVE_HI_I) |
	      (opcode == `X_STSAVE_LO_IR) |
	      (opcode == `X_STSAVE_HI_IR) ;
   
	      

   //st needs rs1 for addr calculation
   wire       is_st_rs1 =
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
	      (opcode == `X_STSAVE_LO_IR) | 
	      (opcode == `X_STSAVE_HI_IR);

	      

   wire       is_st_imm  = 
	      (opcode == `X_ST_I) | 
  	      (opcode == `X_RB_ST_I) |  
	      (opcode == `X_RNB_ST_I) | 
	      (opcode == `X_STSAVE_LO_I) | 
	      (opcode == `X_STSAVE_HI_I);
   

   wire is_simd_ctrl =
	(opcode == `X_JUMPSIMD) |
	(opcode == `X_JUMPSCALAR);
   
   
	      
   wire       is_test = (opcode == `X_TEST);
   
   //don't need rs2
   wire       is_addi_subi = (opcode == `X_SUBI) || (opcode == `X_ADDI);

   //don't need rs2
   wire       is_pred = (opcode == `X_PRED_S) || (opcode == `X_PRED_C);
   
  
   //jump and loop are handled in another unit
   //no need for operand fetch
   wire is_jump = 
	(opcode == `X_JUMP_R) | 
	(opcode == `X_JUMP_A) |
	(opcode == `X_JUMPS_R) |
	(opcode == `X_JUMPS_A) |
	(opcode == `X_JUMPC_R) |
	(opcode == `X_JUMPC_A);
    
   wire is_loopi = 
	(opcode == `X_LOOP_RI) | 
	(opcode == `X_LOOP_AI) |
	(opcode == `X_LOOPS_RI) |
	(opcode == `X_LOOPS_AI) |
	(opcode == `X_LOOPC_RI) |
	(opcode == `X_LOOPC_AI);

   wire is_fetch_oo =
	(opcode == `X_FETCH_A_I ) |
	(opcode == `X_JFETCH_A_I ) | 
	(opcode == `X_FETCH_R_I ) |
	(opcode == `X_JFETCH_R_I );
   
   wire is_fetch_r =
	(opcode == `X_FETCH_A_R ) |
	(opcode == `X_JFETCH_A_R ) | 
	(opcode == `X_FETCH_R_R ) |
	(opcode == `X_JFETCH_R_R );

      
   //branch and loop instructions issue out of the module
   //pc_branch_unit.  The modifed predicate registers
   //needs to be trucked along in this module

   wire is_loop = 
		    (opcode == `X_LOOPS_R) |
		    (opcode == `X_LOOPS_A) |
		    (opcode == `X_LOOPC_R) |
		    (opcode == `X_LOOPC_A) |
 		    (opcode == `X_LOOPS_RI) |
		    (opcode == `X_LOOPS_AI) |
		    (opcode == `X_LOOPC_RI) |
		    (opcode == `X_LOOPC_AI);
   
   //expand into 7 bit pointers
   wire [6:0] w_rs1_7b_ptr = xmu_rs1_7b(opcode, rs1_encode, rs1);
   wire [6:0] w_rs2_7b_ptr = xmu_rs2_7b(opcode, rs2);


   wire       need_rs1 = !(is_movi | is_nop | is_ld_imm | is_jump |
			   is_loopi | is_loop | is_test);
   
   wire       need_rs2 = !(is_movi | is_nop | is_ld_imm | is_jump | is_ld_ri |
			   is_loopi | is_loop | /*is_st | is_st_rs1 |*/
			   is_st_imm | is_addi_subi | is_pred | is_test);
   
   

   /* Index register decode */
   wire rs1_from_xprf = (w_rs1_7b_ptr[6:2] == 5'b00100);
   wire rs2_from_xprf = (w_rs2_7b_ptr[6:2] == 5'b00100); 
   wire [6:0]  extend_rd = xmu_rd_7b(opcode, rd_encode, rd);


     
   assign xp_ptr1 = w_rs1_7b_ptr[1:0];
   assign xp_ptr2 = w_rs2_7b_ptr[1:0];
   assign xp_store_ptr = extend_rd[2:0];
   assign xp_store_ptr_valid = ((opcode == `X_STSAVE_LO_I) | (opcode == `X_STSAVE_HI_I) |
				(opcode == `X_STSAVE_LO_IR) | (opcode == `X_STSAVE_HI_IR))
     & ({extend_rd[6:3],3'd0} == `XPL0);
   

   //rch 8/19
   //rch 9/23: no longer allowed to fetch from xrf
   assign xp_ptr1_valid = (rs1_from_xprf & need_rs1 & ~is_st) & ~(is_fetch_oo | is_fetch_r) ;
   assign xp_ptr2_valid = (rs2_from_xprf & need_rs2 & ~is_st) & ~(is_fetch_oo | is_fetch_r);
   
   
   wire [6:0]  rs1_7b_ptr;
   wire [6:0]  rs2_7b_ptr;

   /*
   always@(*)
     begin
	if(is_movi | is_nop)
	  begin
	     rs1_7b_ptr = {1'b0, rs1};
	  end
	else if(is_loop | is_loopi | is_jump)
	  begin
	     rs1_7b_ptr = 7'd0;
	  end	
	else
	  begin
	     rs1_7b_ptr = w_rs1_7b_ptr;
	  end
     end 
    */
   wire [6:0]  loop_rd = {1'b0, instr_in[15:10]};

   assign rs1_7b_ptr = (is_movi | is_nop | is_test | is_ld_imm | is_st_imm ) ?
		       {1'b0, rs1} :
		       (is_loop | is_loopi | is_jump | is_fetch_oo) ?
		       7'd0 :
		       (rs1_from_xprf & xp_ptr1_valid) ?
		       {2'b01,xp_grf_ptr1} :
		       w_rs1_7b_ptr;
   
   //rch 8/19
   assign rs2_7b_ptr = (is_movi | is_addi_subi | is_nop | is_test | is_st_imm | is_ld_imm | 
			is_ld_ri) ?
		       {1'b0, rs2} :
		       (is_loop | is_loopi | is_jump | is_pred | is_fetch_oo | is_fetch_r) ?
		       7'd0 :
		       (rs2_from_xprf & xp_ptr2_valid) ?
		       {2'b01,xp_grf_ptr2} :
		       w_rs2_7b_ptr;
   /*
   always@(*)
     begin
	if(is_movi | is_addi_subi | is_nop)
	  begin
	     rs2_7b_ptr = {1'b0, rs2};
	  end
	else if(is_loop | is_loopi | is_jump)
	  begin
	     rs2_7b_ptr = 7'd0;
	  end
	else
	  begin
	     rs2_7b_ptr = w_rs2_7b_ptr;
	  end
     end 
    */
   
 


   wire       use_loop_rd = (is_loop | is_loopi);
   
   wire       is_fetch = is_fetch_oo | is_fetch_r;
   wire       rd_from_xprf = (extend_rd[6:2] == 5'b00100) & !( is_movi) & ~(is_fetch);
  

   assign st_rd_from_xprf = rd_from_xprf & is_st;
     
   assign xp_rd_valid = rd_from_xprf;
   assign xp_rd_ptr = (extend_rd[1:0]);
      
   wire [6:0] rd_7b_ptr = use_loop_rd ? loop_rd : 
	      rd_from_xprf ? {2'b01, xp_grf_rd_ptr} : extend_rd;


   
     
   //reassemble instruction word
   assign xmu_decode_instr_out =
	  is_simd_ctrl ? 35'd0 : 			
	  (opcode == `X_MOVI | opcode == `X_LDREST_LO_I | opcode == `X_LDREST_HI_I | 
	   opcode == `X_STSAVE_LO_I | opcode == `X_STSAVE_HI_I) ?
	  {opcode, 3'd0, instr_in[16:14], rd_7b_ptr, instr_in[13:0]} :
				 (is_fetch | is_jump ) ? 35'd0 :
	  {opcode, extend, rd_7b_ptr, rs1_7b_ptr, rs2_7b_ptr};

   //use a register read port for stores
   wire [6:0] st_rs1_7b_ptr = is_st ? rd_7b_ptr : rs1_7b_ptr;

   assign xmu_dec_strest_ptr = st_rs1_7b_ptr;
   
   //use second read port for rs1 of stores
   wire [6:0] st_rs2_7b_ptr = is_st_rs1 ? rs1_7b_ptr :
	      rs2_7b_ptr;
     
   wire forwardable_rs1 = !(
			    (st_rs1_7b_ptr ==`MR0) |
			    (st_rs1_7b_ptr ==`MR1) |
			    (st_rs1_7b_ptr ==`MR2) |
			    (st_rs1_7b_ptr ==`MR3) |			    
   			    (st_rs1_7b_ptr ==`MR4) |
			    (st_rs1_7b_ptr ==`MR5) |
			    (st_rs1_7b_ptr ==`MR6) |
			    (st_rs1_7b_ptr ==`MR7) |
			    (st_rs1_7b_ptr ==`TR0) |
			    (st_rs1_7b_ptr ==`TR1) 
			    );
   
   wire forwardable_rs2 = !(
			    (st_rs2_7b_ptr ==`MR0) |
			    (st_rs2_7b_ptr ==`MR1) |
			    (st_rs2_7b_ptr ==`MR2) |
			    (st_rs2_7b_ptr ==`MR3) |			    
   			    (st_rs2_7b_ptr ==`MR4) |
			    (st_rs2_7b_ptr ==`MR5) |
			    (st_rs2_7b_ptr ==`MR6) |
			    (st_rs2_7b_ptr ==`MR7) |
			    (st_rs2_7b_ptr ==`TR0) |
			    (st_rs2_7b_ptr ==`TR1) 
			    );
	      
   //forwarding network checks
   wire fwd_rs1_from_alu = 
	(alu_ex_mem_ptr == st_rs1_7b_ptr)
	& (alu_ex_mem_valid)
	& forwardable_rs1;
   
   wire fwd_rs2_from_alu = 
	(alu_ex_mem_ptr == st_rs2_7b_ptr)
	& (alu_ex_mem_valid)
	& forwardable_rs2;
      
   wire fwd_rs1_from_xmu = 
	(xmu_ex_mem_ptr == st_rs1_7b_ptr)
	& (xmu_ex_mem_valid)
	& forwardable_rs1;
   
   wire fwd_rs2_from_xmu = 
	(xmu_ex_mem_ptr == st_rs2_7b_ptr)
	& (xmu_ex_mem_valid)
	& forwardable_rs2;
   
   /* This is for checking b2b dependences... not for actual
    * forwarding! */
   wire forward_rs1_from_tr0 = (alu_id_ex_ptr == st_rs1_7b_ptr)
	& alu_id_ex_valid;

   wire forward_rs2_from_tr0 = (alu_id_ex_ptr == st_rs2_7b_ptr)
	& alu_id_ex_valid;

   wire forward_rs1_from_tr1 = (xmu_id_ex_ptr == st_rs1_7b_ptr)
	& xmu_id_ex_valid;

   wire forward_rs2_from_tr1 = (xmu_id_ex_ptr == st_rs2_7b_ptr)
	& xmu_id_ex_valid;


   wire rs1_from_grf = ((st_rs1_7b_ptr[6:5] == 2'b01)) & need_rs1;
   
   wire rs2_from_grf = ((st_rs2_7b_ptr[6:5] == 2'b01)) & need_rs2;
   
   wire rs1_from_prf = ((st_rs1_7b_ptr[6:2] == 5'b00101) |
			(st_rs1_7b_ptr[6:2] == 5'b10100) 
			& (!is_loop | !is_loop)) & need_rs1;
   

   
   wire rs2_from_prf = ((st_rs2_7b_ptr[6:2] == 5'b00101) |
			(st_rs2_7b_ptr[6:2] == 5'b10100)) & need_rs2;
   
   wire rs1_from_mrf = (st_rs1_7b_ptr[6:3] == 4'b0011) & need_rs1;
   wire rs2_from_mrf = (st_rs2_7b_ptr[6:3] == 4'b0011) & need_rs2;  

   wire rs1_is_link_reg = (rs1_7b_ptr == 7'b0000001) & need_rs1;
   wire rs2_is_link_reg = (rs2_7b_ptr == 7'b0000001) & need_rs2;

   //loads have a single cycle load use penality
   //therefore, we need to stall the pipeline for
   //a single cycle if we detect a load in exec
   //and fwd_rs1_from_xmu or fwd_rs2_from_xmu is valid

   wire ld_in_xmu_exec = 
	(xmu_exec_opcode == `X_LD_I) |
	(xmu_exec_opcode == `X_LD_IR) |
	(xmu_exec_opcode == `X_LD_RR) |
	(xmu_exec_opcode == `X_RB_LD_I) |
	(xmu_exec_opcode == `X_RB_LD_IR) |
	(xmu_exec_opcode == `X_RB_LD_RR) |
	(xmu_exec_opcode == `X_CMPSWP) |
	(xmu_exec_opcode == `X_LDREST_LO_I) |
	(xmu_exec_opcode == `X_LDREST_LO_IR) |
	(xmu_exec_opcode == `X_LDREST_HI_I) |
	(xmu_exec_opcode == `X_LDREST_HI_IR);


   wire ld_use_rs1_rd = (xmu_id_ex_ptr == st_rs1_7b_ptr)
	& (xmu_id_ex_valid) & (st_rs1_7b_ptr != 7'd0);

   wire ld_use_rs2_rd = (xmu_id_ex_ptr == st_rs2_7b_ptr)
	& (xmu_id_ex_valid) & (st_rs2_7b_ptr != 7'd0);
   

   //rch
   wire ld_use_stall_rs1 = ld_in_xmu_exec & ld_use_rs1_rd;
   wire ld_use_stall_rs2 = ld_in_xmu_exec & ld_use_rs2_rd;


   reg [31:0] t_rs1_value, t_rs2_value;
   reg 	      t_rs1_valid, t_rs2_valid;

   assign rs1_out = t_rs1_value;
   assign rs2_out = t_rs2_value;

   //wire       need_rs1;
   //wire       need_rs2;
   reg t_hack_dec_jfetch_rs1_good;
   output stop_the_jfetch;
   assign stop_the_jfetch = (fwd_rs1_from_alu | fwd_rs1_from_xmu | forward_rs1_from_tr0 | forward_rs1_from_tr1)
     & is_fetch_r;
   			    //~t_hack_dec_jfetch_rs1_good;
   
   assign rs1_out_valid = (t_rs1_valid | ~need_rs1) /*& ~(is_fetch_r & ~t_hack_dec_jfetch_rs1_good)*/;
   assign rs2_out_valid = t_rs2_valid | ~need_rs2;

   reg [4:0]  t_grf1_ptr;
   reg 	      t_grf_ptr1_valid;

   reg [4:0]  t_grf2_ptr;
   reg 	      t_grf_ptr2_valid; 
   
   assign grf_ptr1 = t_grf1_ptr;
   assign grf_ptr1_valid = t_grf_ptr1_valid;

   assign grf_ptr2 = t_grf2_ptr;
   assign grf_ptr2_valid = t_grf_ptr2_valid;
   
   reg [2:0]  t_prf_ptr1, t_prf_ptr2;
   reg 	      t_prf_ptr1_valid, t_prf_ptr2_valid;

   assign pr_ptr1 = t_prf_ptr1;
   assign pr_ptr2 = t_prf_ptr2;
   
   assign pr_r1_valid = t_prf_ptr1_valid;
   assign pr_r2_valid = t_prf_ptr2_valid;

   reg [2:0] t_mrf_ptr1, t_mrf_ptr2;
   reg 	     t_mrf_ptr1_valid, t_mrf_ptr2_valid;
   
   assign mr_ptr1 = t_mrf_ptr1;
   assign mr_ptr2 = t_mrf_ptr2;

   assign mr_r1_valid = t_mrf_ptr1_valid;
   assign mr_r2_valid = t_mrf_ptr2_valid;

  
   reg 		 t_rs1_gen_stall, t_rs2_gen_stall;
   
   assign xmu_decode_gen_stall = (t_rs1_gen_stall | t_rs2_gen_stall)
     &(!is_loopi | !is_nop | !is_loop);




   wire is_arf_strest = 
	((extend_rd == `ASL0) |
	 (extend_rd == `ASU0) |
	 (extend_rd == `ASL1) |
	 (extend_rd == `ASU1) |
	 (extend_rd == `ASL2) |
	 (extend_rd == `ASU2) |
	 (extend_rd == `ASL3) |
	 (extend_rd == `ASU3)) & (is_st) ;
   
      
   
   //get rs1
   always@(*)
     begin: rs1_decoder
	t_rs1_valid = 1'b0;
	t_rs1_value = 32'd0;
	t_hack_dec_jfetch_rs1_good = 1'b0;
		
	//grf pointers
	t_grf1_ptr = 5'd0;
	t_grf_ptr1_valid = 1'b0;

	//prf pointers
	t_prf_ptr1 = 3'd0; 
	t_prf_ptr1_valid = 1'b0;

	//mrf pointers
	t_mrf_ptr1 = 3'd0;
	t_mrf_ptr1_valid = 1'b0;
	
	
	//stall generated by rs1
	t_rs1_gen_stall = 1'b0;

	
	
	if(ld_use_stall_rs1)
	  begin
	     t_rs1_valid = 1'b0;
	     t_rs1_gen_stall = 1'b0;
	  end

	else if(is_ld_imm)
	  begin
	     t_rs1_valid = 1'b0;
	  end
	else if(xp_store_ptr_valid)
	  begin
	     t_rs1_valid = 1'b1;
	     t_rs1_value = xp_store_data;
	  end
	else if(is_movi)
	  begin
	     t_rs1_valid = 1'b0;
	  end
	
	else if(is_nop)
	  begin
	     t_rs1_valid = 1'b0;
	  end
	
	else if(is_jump)
	  begin
	     t_rs1_valid = 1'b0;
	  end

	else if(is_loop | is_loopi)
	  begin
	     t_rs1_valid = 1'b1;
	     t_rs1_value = branch_pr;
	  end

	else if(is_arf_strest)
	  begin
	     t_rs1_value = arf_strest_value;
	     t_rs1_valid = 1'b1;
	  end
	
	//forward from alu ex latch
	else if(fwd_rs1_from_alu)
	  begin
	     t_rs1_valid = 1'b1;
	     t_rs1_value = alu_ex_mem_in;
	  end
	
	//forward from xmu ex latch
	else if(fwd_rs1_from_xmu)
	  begin
	     t_rs1_valid = 1'b1;
	     t_rs1_value = xmu_ex_mem_in;
	  end

	//rs1 is rd of previous instruction
	else if(forward_rs1_from_tr0)
	  begin
	     t_rs1_valid = 1'b0;
	  end

	else if(forward_rs1_from_tr1)
	  begin
	     t_rs1_valid = 1'b0;
	  end
	
	
	//decode and read proper register file
	else if(rs1_from_grf)
	  begin
	     //read register file
	     t_grf_ptr1_valid = 1'b1;
	     t_grf1_ptr = st_rs1_7b_ptr[4:0];
	     t_hack_dec_jfetch_rs1_good = 1'b1;
 
	     //data back from the grf
	     t_rs1_value = grf_r1_in;
	     t_rs1_valid =  grf_r1_in_valid;
	     t_rs1_gen_stall = !grf_r1_in_valid;
	  end
	
	else if(rs1_from_prf)
	  begin
	     t_prf_ptr1 = st_rs1_7b_ptr[2:0];
	     t_prf_ptr1_valid = 1'b1;
	     
	     t_rs1_value = 32'd0 | (st_rs1_7b_ptr[2] ? pr_r1_in>>1 : pr_r1_in);
	     t_rs1_valid =  pr_r1_in_valid;
	  end

	else if(rs1_from_mrf)
	  begin
	     t_mrf_ptr1 = st_rs1_7b_ptr[2:0];
	     t_mrf_ptr1_valid = 1'b1;

	     t_rs1_value = mr_r1_in;
	     t_rs1_valid =  mr_r1_in_valid;
	     t_rs1_gen_stall = !mr_r1_in_valid;
	     
	  end
	else if(rs1_is_link_reg)
	  begin
	     t_rs1_value = {26'd0, link_reg};
	     t_rs1_valid = 1'b1;
	     t_rs1_gen_stall = 1'b0;
	  end
	
     end // block: rs1_decoder
   

   
   //get rs2
   always@(*)
     begin: rs2_decoder
	t_rs2_valid = 1'b0;
	t_rs2_value = 32'd0;

	//grf pointers
	t_grf2_ptr = 5'd0;
	t_grf_ptr2_valid = 1'b0;

	//prf pointers
	t_prf_ptr2 = 3'd0; 
	t_prf_ptr2_valid = 1'b0;

	//mrf pointers
	t_mrf_ptr2 = 3'd0;
	t_mrf_ptr2_valid = 1'b0;

	
	//stall generated by rs2
	t_rs2_gen_stall = 1'b0;
	
	if(ld_use_stall_rs2)
	  begin
	     t_rs2_valid = 1'b0;
	     t_rs2_gen_stall = 1'b0;
	  end

	else if(is_ld_imm)
	  begin
	     t_rs2_valid = 1'b0;
	  end

	else if(is_st_imm)
	  begin
	     t_rs2_valid = 1'b0;
	  end
		
	else if(is_movi)
	  begin
	     t_rs2_valid = 1'b0;
	  end

	else if(is_nop)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	else if(is_loop)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	else if(is_loopi)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	else if(is_jump)
	  begin
	     t_rs2_valid = 1'b0;
	  end

	else if(is_addi_subi)
	  begin
	     t_rs2_valid = 1'b0;
	  end	

	else if(is_pred)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	
	//forward from alu ex latch
	else if(fwd_rs2_from_alu)
	  begin
	     t_rs2_valid = 1'b1;
	     t_rs2_value = alu_ex_mem_in;
	  end
	
	//forward from xmu ex latch
	else if(fwd_rs2_from_xmu)
	  begin
	     t_rs2_valid = 1'b1;
	     t_rs2_value = xmu_ex_mem_in;
	  end

	//rs2 is rd of previous instruction
	else if(forward_rs2_from_tr0)
	  begin
	     t_rs2_valid = 1'b0;
	  end

	else if(forward_rs2_from_tr1)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	//decode and read proper register file
	else if(rs2_from_grf)
	  begin
	     //read register file
	     t_grf_ptr2_valid = 1'b1;
	     t_grf2_ptr = st_rs2_7b_ptr[4:0];
 
	     //data back from the grf
	     t_rs2_value = grf_r2_in;
	     t_rs2_valid =  grf_r2_in_valid;
	     t_rs2_gen_stall = !grf_r2_in_valid;
	  end
	
	else if(rs2_from_prf)
	  begin
	     t_prf_ptr2 = st_rs2_7b_ptr[2:0];
	     t_prf_ptr2_valid = 1'b1;
	     
	     t_rs2_value = 32'd0 | (st_rs2_7b_ptr[2] ? pr_r2_in >> 1 : pr_r2_in);
	     t_rs2_valid =  pr_r2_in_valid;
	     t_rs2_gen_stall = !pr_r2_in_valid;
	  end

	else if(rs2_from_mrf)
	  begin
	     t_mrf_ptr2 = st_rs2_7b_ptr[2:0];
	     t_mrf_ptr2_valid = 1'b1;

	     t_rs2_value = mr_r2_in;
	     t_rs2_valid =  mr_r2_in_valid;
	     t_rs2_gen_stall = !mr_r2_in_valid;
	     
	  end
       	else if(rs2_is_link_reg)
	  begin
	     t_rs2_value = {26'd0, link_reg};
	     t_rs2_valid = 1'b1;
	     t_rs2_gen_stall = 1'b0;
	  end
     end // block: rs2_decoder


   
	  
	
   
endmodule // xmu_decode
