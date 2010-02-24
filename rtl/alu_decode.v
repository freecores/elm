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

/*
 read grf, indx, predicate, and message registers
*/
module alu_decode(/*AUTOARG*/
   // Outputs
   alu_decode_instr_out, rs1_out, rs2_out, rs3_out, rs1_out_valid,
   rs2_out_valid, rs3_out_valid, alu_decode_gen_stall, grf_ptr1,
   grf_ptr2, grf_ptr1_valid, grf_ptr2_valid, xp_ptr1, xp_ptr2,
   xp_ptr1_valid, xp_ptr2_valid, xp_rd_valid, xp_rd_ptr, pr_ptr1,
   pr_ptr2, pr_r1_valid, pr_r2_valid, mr_ptr1, mr_ptr2, mr_r1_valid,
   mr_r2_valid,
   // Inputs
   instr_in, alu_ex_mem_ptr, alu_ex_mem_valid, alu_ex_mem_in,
   xmu_ex_mem_ptr, xmu_ex_mem_valid, xmu_ex_mem_in, alu_id_ex_ptr,
   alu_id_ex_valid, xmu_id_ex_ptr, xmu_id_ex_valid, xmu_exec_opcode,
   grf_r1_in, grf_r2_in, grf_r1_in_valid, grf_r2_in_valid, link_reg,
   xp_grf_ptr1, xp_grf_ptr2, xp_grf_ptr1_valid, xp_grf_ptr2_valid,
   xp_grf_rd_ptr, xp_grf_rd_ptr_valid, pr_r1_in, pr_r2_in,
   pr_r1_in_valid, pr_r2_in_valid, mr_r1_in, mr_r2_in, mr_r1_in_valid,
   mr_r2_in_valid
   );
   input [31:0] instr_in;
   output [34:0] alu_decode_instr_out;

   output [31:0] rs1_out;
   output [31:0] rs2_out;
   output [31:0] rs3_out;
      
   output 	 rs1_out_valid;
   output 	 rs2_out_valid;
   output 	 rs3_out_valid;
   
   
   output 	 alu_decode_gen_stall;
   

   //forwarding network (from alu ex_mem latch)
   input [6:0] 	 alu_ex_mem_ptr;
   input 	 alu_ex_mem_valid;
   input [31:0]  alu_ex_mem_in;

   //forwarding network (from xmu ex_mem latch)
   input [6:0] 	 xmu_ex_mem_ptr;
   input 	 xmu_ex_mem_valid;
   input [31:0]  xmu_ex_mem_in;


   //*ideally* we would forward through tr0
   input [6:0] 	 alu_id_ex_ptr;
   input 	 alu_id_ex_valid;
   
   input [6:0] 	 xmu_id_ex_ptr;
   input 	 xmu_id_ex_valid;
   

   input [7:0] 	 xmu_exec_opcode;
   
  
   

   //gpr
   output [4:0]  grf_ptr1;
   output [4:0]  grf_ptr2;

   output 	 grf_ptr1_valid;
   output 	 grf_ptr2_valid;
      
   input [31:0]  grf_r1_in;
   input [31:0]  grf_r2_in;

   input 	 grf_r1_in_valid;
   input 	 grf_r2_in_valid;

   //always valid
   input [5:0]  link_reg;
   
   
   //idx
   output [1:0]  xp_ptr1;
   output [1:0]  xp_ptr2;
   
   output 	 xp_ptr1_valid;
   output 	 xp_ptr2_valid;

   output 	 xp_rd_valid;
   output [1:0]  xp_rd_ptr;
   
  

   /* pointers back from the 
    * index register file
    * 
    * */
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

   input [8:0]  pr_r1_in;
   input [8:0]  pr_r2_in;

   input 	 pr_r1_in_valid;
   input 	 pr_r2_in_valid;
   
   //message registers
   output [2:0]  mr_ptr1;
   output [2:0]  mr_ptr2;

   output 	 mr_r1_valid;
   output 	 mr_r2_valid;

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

   wire 		 is_mul = (opcode == `A_MUL | 
				   opcode == `A_MUL_F |
				   opcode == `A_MAC_F |
				   opcode == `A_MAC);

   

   //expand rs1 / rs2 from 6 bits to 7 bits 
   
    function [6:0] alu_rs1_7b(input [7:0] opcode, input [6:0] rs1_encode,
    input [5:0] 	 rs_ptr);
       begin
	  case(opcode)
	    `A_MOV: 
	      begin
		 alu_rs1_7b = rs1_encode;
	      end
	    default:
	      begin
		 alu_rs1_7b = {1'b0, rs_ptr};
	      end
	  endcase // case (opcode)
       end
    endfunction // alu_rs_7b

   function [6:0] alu_rs2_7b(input [7:0] opcode, input [5:0] rs_ptr);
      begin
	 alu_rs2_7b = {1'b0, rs_ptr};
      end
   endfunction // alu_rs2_7b
   
   
   function [6:0] alu_rd_7b(input [7:0] opcode, input [6:0] rd_encode,
    input [5:0] rd_ptr);
      begin
	 case(opcode)
	   `A_TEST:
	     begin
		alu_rd_7b = {!rd_ptr[2], rd_ptr};
	     end
	   `A_CMP_EQ:
	    begin
	       alu_rd_7b = {!rd_ptr[2], rd_ptr};
	    end
	  `A_CMP_NE:
	    begin
	       alu_rd_7b = {!rd_ptr[2], rd_ptr};
	    end
	  `A_CMP_LT:
	    begin
	       alu_rd_7b = {!rd_ptr[2], rd_ptr};
	    end
	  `A_CMP_LTE:
	    begin
	       alu_rd_7b = {!rd_ptr[2], rd_ptr};
	    end
	  `A_CMP_ULT:
	    begin
	       alu_rd_7b = {!rd_ptr[2], rd_ptr};
	    end
	   `A_CMP_ULTE:
	    begin
	       alu_rd_7b = {!rd_ptr[2], rd_ptr};
	    end	  
	   `A_MOV:
	     begin
		alu_rd_7b = rd_encode;
	     end
	   `A_MOVI:
	     begin
		alu_rd_7b = rd_encode;
	     end
	   default:
	     begin
		alu_rd_7b = {1'b0, rd_ptr};
	     end
	 endcase // case (opcode)
      end
   endfunction // alu_rd_7b
   
   //don't need to access register files for a handful of
   //immediate instructions

   //don't need rs1 or rs2
   wire       is_movi = (opcode == `A_MOVI);
   wire       is_mov = (opcode == `A_MOV);
   
   wire       is_sel = (opcode == `A_SEL);
      
   
   //don't need rs1 or rs2
   wire       is_nop = (opcode == `A_NOP);
   
   //don't need rs2
   wire       is_addi_subi = (opcode == `A_SUBI) || (opcode == `A_ADDI);

   wire is_neg_abs_not_clz = (opcode == `A_NEG) | (opcode == `A_ABS)
	| (opcode == `A_NOT) | (opcode == `A_CLZ);

   wire is_unpacki_unpackf = (opcode == `A_UNPACKI) || (opcode == `A_UNPACKF);

   wire is_shift_imm = (opcode == `A_SRAI) | (opcode == `A_SRLI) |
	(opcode == `A_SLAI) | (opcode == `A_SLLI);

   wire is_test = (opcode == `A_TEST);
      
   wire need_rs2 = !(is_movi | is_nop | is_addi_subi |
		     is_shift_imm | is_neg_abs_not_clz |
		     is_unpacki_unpackf | is_test);

   //rch
   wire need_rs1 = !(is_test | is_movi | is_nop);
   
   
   //expand into 7 bit pointers
   wire [6:0] w_rs1_7b_ptr = alu_rs1_7b(opcode, rs1_encode, rs1);
   wire [6:0] w_rs2_7b_ptr = alu_rs2_7b(opcode, rs2);

   //For ASEL
   wire [6:0] rs3_7b_ptr = {!extend[2], extend};
   

   
   wire rs1_from_xprf = (w_rs1_7b_ptr[6:2] == 5'b00100) & need_rs1;
   wire rs2_from_xprf = (w_rs2_7b_ptr[6:2] == 5'b00100) & need_rs2; 
   
   assign xp_ptr1 = w_rs1_7b_ptr[1:0];
   assign xp_ptr2 = w_rs2_7b_ptr[1:0];
      
   assign xp_ptr1_valid = rs1_from_xprf & !(is_movi | is_nop) & need_rs1;
   assign xp_ptr2_valid = rs2_from_xprf & need_rs2;


   
   reg [6:0]  rs1_7b_ptr, rs2_7b_ptr;
   
   always@(*)
     begin
	if(is_movi | is_nop)
	  begin
	     rs1_7b_ptr = 7'd0;
	  end
	else if(rs1_from_xprf)
	  begin
	     rs1_7b_ptr = {2'b01,xp_grf_ptr1};
	  end
	else
	  begin
	     rs1_7b_ptr = w_rs1_7b_ptr;
	  end
     end // always@ (*)

   always@(*)
     begin
	if(is_nop | is_addi_subi | is_neg_abs_not_clz | 
	  is_unpacki_unpackf | is_shift_imm | is_test)
	  begin
	     rs2_7b_ptr = {1'b0, rs2};
	  end
	else if(is_movi)
	  begin
	     rs2_7b_ptr = 7'd0;
	  end
	else
	  begin
	     rs2_7b_ptr = rs2_from_xprf ? {2'b01, xp_grf_ptr2} : w_rs2_7b_ptr;
	  end
     end // always@ (*)
   
   
   wire [6:0] w_rd_7b_ptr = alu_rd_7b(opcode, rd_encode, rd);

   wire       rd_from_xprf = (w_rd_7b_ptr[6:2] == 5'b00100);
   
   reg [6:0]  rd_7b_ptr;

   assign xp_rd_valid = rd_from_xprf & !(is_movi);
   assign xp_rd_ptr = (w_rd_7b_ptr[1:0]);
      
   /* resolve index register rd in decode to allow forwarding */
   always@(*)
     begin
	if(rd_from_xprf)
	  begin
	     rd_7b_ptr = {2'b01, xp_grf_rd_ptr};
	  end
	else
	  begin
	     rd_7b_ptr = w_rd_7b_ptr;
	  end
     end


   wire forwardable_rs1 = !(
			    (rs1_7b_ptr ==`MR0) |
			    (rs1_7b_ptr ==`MR1) |
			    (rs1_7b_ptr ==`MR2) |
			    (rs1_7b_ptr ==`MR3) |			    
   			    (rs1_7b_ptr ==`MR4) |
			    (rs1_7b_ptr ==`MR5) |
			    (rs1_7b_ptr ==`MR6) |
			    (rs1_7b_ptr ==`MR7) |
			    (rs1_7b_ptr ==`TR0) |
			    (rs1_7b_ptr ==`TR1) );
   
   wire forwardable_rs2 = !(
			    (rs2_7b_ptr ==`MR0) |
			    (rs2_7b_ptr ==`MR1) |
			    (rs2_7b_ptr ==`MR2) |
			    (rs2_7b_ptr ==`MR3) |			    
   			    (rs2_7b_ptr ==`MR4) |
			    (rs2_7b_ptr ==`MR5) |
			    (rs2_7b_ptr ==`MR6) |
			    (rs2_7b_ptr ==`MR7) |
			    (rs2_7b_ptr ==`TR0) |
			    (rs2_7b_ptr ==`TR1) );
   			    
   //forwarding network checks
   wire       fwd_rs1_from_alu = 
			    (alu_ex_mem_ptr == rs1_7b_ptr)
			    & (alu_ex_mem_valid) & (rs1_7b_ptr != 7'd0) 
			    & forwardable_rs1;
   
   wire       fwd_rs2_from_alu = 
			    (alu_ex_mem_ptr == rs2_7b_ptr)
			    & (alu_ex_mem_valid) & (rs2_7b_ptr != 7'd0)
			    & forwardable_rs2;
   
   wire       fwd_rs1_from_xmu = 
			    (xmu_ex_mem_ptr == rs1_7b_ptr)
			    & (xmu_ex_mem_valid) & (rs1_7b_ptr != 7'd0)
			    & forwardable_rs1;
   
   wire       fwd_rs2_from_xmu = 
			    (xmu_ex_mem_ptr == rs2_7b_ptr)
			    & (xmu_ex_mem_valid) & (rs2_7b_ptr != 7'd0)
			    & forwardable_rs2;


   wire       fwd_rs3_from_alu =
	      (alu_ex_mem_ptr == rs3_7b_ptr)
	      & (alu_ex_mem_valid) & (rs3_7b_ptr != 7'd0) 
	      & is_sel;

   wire       fwd_rs3_from_xmu =
	      (xmu_ex_mem_ptr == rs3_7b_ptr)
	      & (xmu_ex_mem_valid) & (rs3_7b_ptr != 7'd0)
	      & is_sel;
   

   //loads have a single cycle load use penality
   //therefore, we need to stall the pipeline for
   //a single cycle if we detect a load in exec
   //and fwd_rs1_from_xmu or fwd_rs2_from_xmu is valid

   wire ld_in_xmu_exec = 
	(xmu_exec_opcode == `X_LD_I) |
	(xmu_exec_opcode == `X_LD_IR) |
	(xmu_exec_opcode == `X_LD_RR) |
	(xmu_exec_opcode == `X_LDREST_LO_I) |
	(xmu_exec_opcode == `X_LDREST_LO_IR) |
	(xmu_exec_opcode == `X_LDREST_HI_I) |
	(xmu_exec_opcode == `X_LDREST_HI_IR);

   wire ld_use_rs1_rd = (xmu_id_ex_ptr == rs1_7b_ptr)
	& (xmu_id_ex_valid) & (rs1_7b_ptr != 7'd0);

   wire ld_use_rs2_rd = (xmu_id_ex_ptr == rs2_7b_ptr)
	& (xmu_id_ex_valid) & (rs2_7b_ptr != 7'd0);
   
   //rch HACK for reducing load cycle time...
   wire ld_use_stall_rs1 = 1'b0;
   //(is_mul | ld_in_xmu_exec) & ld_use_rs1_rd;
   wire ld_use_stall_rs2 = 1'b0;
   //(is_mul | ld_in_xmu_exec) & ld_use_rs2_rd;
   
  

   //good old p & h style forwarding   
   wire forward_rs1_from_tr0 = (alu_id_ex_ptr == rs1_7b_ptr)
	& alu_id_ex_valid;
   
   wire forward_rs2_from_tr0 = (alu_id_ex_ptr == rs2_7b_ptr)
	& alu_id_ex_valid;
   
   wire forward_rs1_from_tr1 = (xmu_id_ex_ptr == rs1_7b_ptr)
	& xmu_id_ex_valid;
   
   wire forward_rs2_from_tr1 = (xmu_id_ex_ptr == rs2_7b_ptr)
	& xmu_id_ex_valid;
   

   //RCH RIGHT HERE PUT A STALL IF THE DESTINIATION IS THE SAME AS RS3!
   wire kill_rs3_from_tr0 = (alu_id_ex_ptr == rs3_7b_ptr)
	& alu_id_ex_valid & is_sel;

   wire kill_rs3_from_tr1 = (xmu_id_ex_ptr == rs3_7b_ptr)
	& xmu_id_ex_valid & is_sel;
   
   //determine register file type
   wire rs1_from_grf = (rs1_7b_ptr[6:5] == 2'b01) & need_rs1;
   wire rs2_from_grf = (rs2_7b_ptr[6:5] == 2'b01) & need_rs2;

   wire rs1_from_prf = (
			(rs1_7b_ptr[6:2] == 5'b00101) |
			(rs1_7b_ptr[6:2] == 5'b10100) 
			) & need_rs1;
   
   wire rs2_from_prf = (
			(rs2_7b_ptr[6:2] == 5'b00101) |
			(rs2_7b_ptr[6:2] == 5'b10100)
			) & need_rs2;

   wire rs1_from_mrf = (rs1_7b_ptr[6:3] == 4'b0011) & need_rs1;
   wire rs2_from_mrf = (rs2_7b_ptr[6:3] == 4'b0011) & need_rs2; 


   
   wire rs1_is_link_reg = (rs1_7b_ptr == 7'b0000001);
   wire rs2_is_link_reg = (rs2_7b_ptr == 7'b0000001);
   
   
   //registers
   reg [31:0] t_rs1_value, t_rs2_value;
   reg 	      t_rs1_valid, t_rs2_valid;

   assign rs1_out = t_rs1_value;
   assign rs2_out = t_rs2_value;

   assign rs1_out_valid = t_rs1_valid;
   assign rs2_out_valid = t_rs2_valid;
      

   //register file pointers
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

      
   assign pr_ptr1 = is_sel ? rs3_7b_ptr[2:0] : t_prf_ptr1;
   assign pr_ptr2 = t_prf_ptr2;
   
   assign pr_r1_valid = is_sel ? 1'b1 : t_prf_ptr1_valid;
   assign pr_r2_valid = t_prf_ptr2_valid;

   reg [2:0] t_mrf_ptr1, t_mrf_ptr2;
   reg 	     t_mrf_ptr1_valid, t_mrf_ptr2_valid;
   
   assign mr_ptr1 = t_mrf_ptr1;
   assign mr_ptr2 = t_mrf_ptr2;

   assign mr_r1_valid = t_mrf_ptr1_valid;
   assign mr_r2_valid = t_mrf_ptr2_valid;

   //   reg [1:0] t_xp_ptr1, t_xp_ptr2;
   //   reg 	     t_xp_ptr1_valid, t_xp_ptr2_valid;
   
   


   reg 		 t_rs1_gen_stall, t_rs2_gen_stall;
   
   assign alu_decode_gen_stall = t_rs1_gen_stall | t_rs2_gen_stall | 
				  kill_rs3_from_tr0 | kill_rs3_from_tr1;

     //reassemble instruction word
   assign alu_decode_instr_out = 
          (t_rs1_gen_stall | t_rs2_gen_stall) ?
	  35'd0 :
	  (opcode == `A_MOVI) ?
	  {opcode, 3'd0, instr_in[16:14], rd_7b_ptr, instr_in[13:0]} : 
	  {opcode, extend, rd_7b_ptr, rs1_7b_ptr, rs2_7b_ptr};
   
   //get rs1
   always@(*)
     begin: rs1_decoder
	t_rs1_valid = 1'b0;
	t_rs1_value = 32'd0;

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
	     t_rs1_gen_stall = 1'b1;
	  end
		
	//avoid reading a register
	else if(is_movi)
	  begin
	     t_rs1_valid = 1'b0;
	  end
	
	//avoid reading a register
	else if(is_nop)
	  begin
	     t_rs1_valid = 1'b0;
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
	     /*if(is_mul) begin
		t_rs1_valid = 1'b0;
		t_rs1_gen_stall = 1'b1;
	     end
	     else begin*/
		t_rs1_valid = 1'b1;
		t_rs1_value = xmu_ex_mem_in;
	    /*end*/
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
	     t_grf1_ptr = rs1_7b_ptr[4:0];
 
	     //data back from the grf
	     t_rs1_value = grf_r1_in;
	     t_rs1_valid =  grf_r1_in_valid;
	     t_rs1_gen_stall = !grf_r1_in_valid;
	  end
	
	else if(rs1_from_prf)
	  begin
	     t_prf_ptr1 = rs1_7b_ptr[2:0];
	     t_prf_ptr1_valid = 1'b1;
	     
	     t_rs1_value = 32'b0 | (rs1_7b_ptr[2] ? pr_r1_in>>1 : pr_r1_in);
	     t_rs1_valid =  pr_r1_in_valid;
	     t_rs1_gen_stall = !pr_r1_in_valid;
	  end

	else if(rs1_from_mrf)
	  begin
	     t_mrf_ptr1 = rs1_7b_ptr[2:0];
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
	     t_rs2_gen_stall = 1'b1;
	  end
	
	//avoid reading a register
	else if(is_movi)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	else if(is_nop)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	else if(is_addi_subi)
	  begin
	     t_rs2_valid = 1'b0;
	  end

	else if(is_shift_imm)
	  begin
	     t_rs2_valid = 1'b0;
	  end
	
	else if(is_neg_abs_not_clz)
	  begin
	     t_rs2_valid = 1'b0;
	  end

	else if(is_unpacki_unpackf)
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
	     //if(is_mul) begin
	     //t_rs2_valid = 1'b0;
	     //t_rs2_gen_stall = 1'b1;
	     //end
	     //else begin
		t_rs2_valid = 1'b1;
		t_rs2_value = xmu_ex_mem_in;
	     //end
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
	     t_grf2_ptr = rs2_7b_ptr[4:0];
 
	     //data back from the grf
	     t_rs2_value = grf_r2_in;
	     t_rs2_valid =  grf_r2_in_valid;
	     t_rs2_gen_stall = !grf_r2_in_valid;
	  end
	
	else if(rs2_from_prf)
	  begin
	     t_prf_ptr2 = rs2_7b_ptr[2:0];
	     t_prf_ptr2_valid = 1'b1;
	     
	     t_rs2_value = 32'd0 | (rs2_7b_ptr[2] ? pr_r2_in >> 1 : pr_r2_in);
	     t_rs2_valid =  pr_r2_in_valid;
	     t_rs2_gen_stall = !pr_r2_in_valid;
	  end

	else if(rs2_from_mrf)
	  begin
	     t_mrf_ptr2 = rs2_7b_ptr[2:0];
	     t_mrf_ptr2_valid = 1'b1;

	     t_rs2_value = mr_r2_in;
	     t_rs2_valid =  mr_r2_in_valid;
	     t_rs2_gen_stall = !mr_r2_in_valid;
	     
	  end
	/*
	else if(rs2_from_xprf)
	  begin
	     t_xp_ptr2 = 
	     t_xp_ptr2_valid = 1'b1;

	     t_rs2_value = xp_r2_in;
	     t_rs2_valid = xp_r2_in_valid;

	     t_rs2_gen_stall = !xp_r2_in_valid;
	     
	  end // if (rs2_from_xprf)
	 */

	//snag link register
	else if(rs2_is_link_reg)
	  begin
	     t_rs2_value = {26'd0, link_reg};
	     t_rs2_valid = 1'b1;

	     t_rs2_gen_stall = 1'b0;
	  end
	

	
     end // block: rs2_decoder


   assign rs3_out = fwd_rs3_from_xmu ? xmu_ex_mem_in :
		    fwd_rs3_from_alu ? alu_ex_mem_in :
		    {23'd0, pr_r1_in};

   assign rs3_out_valid = (fwd_rs3_from_xmu |
			 fwd_rs3_from_alu |
			  pr_r1_in_valid) & ~(kill_rs3_from_tr0 | kill_rs3_from_tr1);
      

endmodule // alu_decode
