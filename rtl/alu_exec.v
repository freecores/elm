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

module alu_exec(/*AUTOARG*/
   // Outputs
   alu_exec_instr_out, orf_ptr1, orf_ptr1_valid, orf_ptr2,
   orf_ptr2_valid, alu_exec_rd_out, alu_zero, alu_carry, alu_sign,
   alu_overflow, orf_use_byte_mask, orf_byte_mask, mac_wr_valid,
   mac_wr_ptr, alu_exec_stall, alu_accum_stall, acc_ptr,
   // Inputs
   alu_exec_instr_in, rs1_in, rs2_in, rs3_in, rs1_in_valid,
   rs2_in_valid, rs3_in_valid, rs_accum, rs_accum_norm_read,
   prev_alu_sign, prev_alu_carry, prev_alu_overflow, prev_alu_zero,
   alu_ex_mem_ptr, alu_ex_mem_valid, alu_ex_mem_in, mr0_full,
   mr1_full, mr2_full, mr3_full, mr4_full, mr5_full, mr6_full,
   mr7_full, xmu_ex_mem_ptr, xmu_ex_mem_valid, xmu_ex_mem_in,
   orf_ptr1_in, orf_ptr2_in
   );
   input [34:0] alu_exec_instr_in;
   output [34:0] alu_exec_instr_out;

   //from alu decode stage
   input [31:0]  rs1_in;
   input [31:0]  rs2_in;
   input [31:0]  rs3_in;
   
   input 	 rs1_in_valid;
   input 	 rs2_in_valid;
   input 	 rs3_in_valid;
      
   input [31:0]  rs_accum;
   input [31:0]  rs_accum_norm_read;
   

   
   //previous instructions zero/carry/overflow/sign bits
   input 	 prev_alu_sign;
   input 	 prev_alu_carry;
   input 	 prev_alu_overflow;
   input 	 prev_alu_zero;
   

   //these are tr0 / tr1:
   //feedback from alu ex_mem latch
   input [6:0] 	 alu_ex_mem_ptr;
   input 	 alu_ex_mem_valid;
   input [31:0]  alu_ex_mem_in;

   input 	 mr0_full;
   input 	 mr1_full;
   input 	 mr2_full;
   input 	 mr3_full;
   input 	 mr4_full;
   input 	 mr5_full;
   input 	 mr6_full;
   input 	 mr7_full;
      
   
   //feedback from xmu ex_mem latch
   input [6:0] 	 xmu_ex_mem_ptr;
   input 	 xmu_ex_mem_valid;
   input [31:0]  xmu_ex_mem_in;

   //operand register files
   input [31:0]  orf_ptr1_in;
   output [1:0]  orf_ptr1;
   output 	 orf_ptr1_valid;
      
   input [31:0]  orf_ptr2_in;
   output [1:0]  orf_ptr2;
   output 	 orf_ptr2_valid;

   //result
   output [31:0] alu_exec_rd_out;
   
   output 	 alu_zero;
   output 	 alu_carry;
   output 	 alu_sign;
   output 	 alu_overflow;
   

   output 	 orf_use_byte_mask;
   output [1:0]  orf_byte_mask;


   output 	 mac_wr_valid;
   output 	 mac_wr_ptr;
   
   output 	 alu_exec_stall;
   output 	 alu_accum_stall;

   output 	 acc_ptr;
      
   wire [7:0] 	 opcode = alu_exec_instr_in[34:27];
   
   wire [5:0] 	 extend = alu_exec_instr_in[26:21];
   wire [6:0] 	 rd_ptr = alu_exec_instr_in[20:14];
   wire [6:0] 	 rs1_ptr = alu_exec_instr_in[13:7];
   wire [6:0] 	 rs2_ptr = alu_exec_instr_in[6:0];
   //screwed up encoding specific
   wire [6:0] 	 rs3_ptr = {~extend[2], extend};
   


   wire acc_stall = 
	((rd_ptr == `DA0 ) | (rd_ptr == `DA1)) &
	((opcode == `A_MOV) | (opcode == `A_MOVI));
   
   assign alu_accum_stall = acc_stall;
   
   
   
   //build immediates 
   wire [5:0] 	 rs1_imm = rs1_ptr[5:0];
   wire [5:0] 	 rs2_imm = rs2_ptr[5:0];

   wire [17:0] 	 w_imm18 = {rs1_imm, extend, rs2_imm};
   wire [11:0] 	 w_imm12 = {extend, rs2_imm};

   //for addi / subi
   wire [19:0] 	 imm_ext20 = {20{extend[5]}};
   //for movi
   wire [11:0] 	 imm_ext12 = {12{rs1_imm[5]}};

   //immediate for addi / subi
   wire [31:0] 	 imm32 = {imm_ext20, w_imm12};

   //immediate for movi

   wire [14:0] 	 movi_sign = {15{extend[2]}};
   
   wire [31:0] 	 imm18 = { movi_sign, extend[2:0], rs1_ptr, rs2_ptr};
   

   
   wire 	 is_sel = (opcode == `A_SEL);
      
   
   assign alu_exec_instr_out = alu_exec_instr_in;


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
	  1'b0);

   
   wire is_mul = (opcode == `A_MUL | 
		  opcode == `A_MUL_F |
		  opcode == `A_MAC_F |
		  opcode == `A_MAC);
   
  
   

   //where we can get operands from:
   //1) decode (rs1 / rs2 valid bit will be set)
   //2) forward from output latch of xmu / alu exec
   //3) operand register file
   //4) tr0 / tr1 (same thing as 2)
   //5) zero register

   wire forwardable_rs1 = !(
			    (rs1_ptr ==`MR0) |
			    (rs1_ptr ==`MR1) |
			    (rs1_ptr ==`MR2) |
			    (rs1_ptr ==`MR3) |			    
   			    (rs1_ptr ==`MR4) |
			    (rs1_ptr ==`MR5) |
			    (rs1_ptr ==`MR6) |
			    (rs1_ptr ==`MR7));
   
   wire forwardable_rs2 = !(
			    (rs2_ptr ==`MR0) |
			    (rs2_ptr ==`MR1) |
			    (rs2_ptr ==`MR2) |
			    (rs2_ptr ==`MR3) |			    
   			    (rs2_ptr ==`MR4) |
			    (rs2_ptr ==`MR5) |
			    (rs2_ptr ==`MR6) |
			    (rs2_ptr ==`MR7));
      
   
   wire 	 fwd_rs1_from_alu = (alu_ex_mem_ptr == rs1_ptr)
		 & (alu_ex_mem_valid) & (rs1_ptr != 7'd0) 
		 & (forwardable_rs1);

   wire 	 fwd_rs2_from_alu = (alu_ex_mem_ptr == rs2_ptr)
		 & (alu_ex_mem_valid) & (rs2_ptr != 7'd0)
		 & (forwardable_rs2);
      
   wire 	 fwd_rs1_from_xmu = (xmu_ex_mem_ptr == rs1_ptr)
		 & (xmu_ex_mem_valid) & (rs1_ptr != 7'd0)
		 & (forwardable_rs1) /*& ~is_mul*/;
      
   wire 	 fwd_rs2_from_xmu = (xmu_ex_mem_ptr == rs2_ptr)
		 & (xmu_ex_mem_valid) & (rs2_ptr != 7'd0)
		 & (forwardable_rs2) /*& ~is_mul*/;
   
   wire 	 fwd_rs3_from_alu = (alu_ex_mem_ptr == rs3_ptr)
		 & (alu_ex_mem_valid) & (rs3_ptr != 7'd0)
		 & (is_sel);
      
   wire 	 fwd_rs3_from_xmu = (xmu_ex_mem_ptr == rs3_ptr)
		 & (xmu_ex_mem_valid) & (rs3_ptr != 7'd0)
		 & (is_sel);

   
   assign alu_exec_stall = mrf_full_stall /*| (is_mul & (fwd_rs1_from_xmu | fwd_rs2_from_xmu))*/;

   
   wire 	 rs1_use_tr0 = (rs1_ptr == `TR0);
   wire 	 rs1_use_tr1 = (rs1_ptr == `TR1)/* & ~is_mul*/;  //rch, probably not good...
      
   wire 	 rs2_use_tr0 = (rs2_ptr == `TR0);
   wire 	 rs2_use_tr1 = (rs2_ptr == `TR1); 
   
   wire 	 rs1_use_zr = (rs1_ptr == `ZR);
   wire 	 rs2_use_zr = (rs2_ptr == `ZR); 

   wire 	 rs1_use_orf = (rs1_ptr[6:2] == 5'b00011);
   wire 	 rs2_use_orf = (rs2_ptr[6:2] == 5'b00011);

   wire 	 rs1_use_acc = (rs1_ptr == `DA0) | (rs1_ptr == `DA1);
   wire 	 rs2_use_acc = (rs2_ptr == `DA0) | (rs2_ptr == `DA1);
   

   reg [1:0] 	 t_orf_ptr1, t_orf_ptr2;
   reg  	 t_orf_ptr1_valid, t_orf_ptr2_valid;
   reg 		 t_acc_ptr1, t_acc_ptr2;
      
   assign orf_ptr1 = t_orf_ptr1;
   assign orf_ptr1_valid = t_orf_ptr1_valid;

   assign orf_ptr2 = t_orf_ptr2;
   assign orf_ptr2_valid = t_orf_ptr2_valid;
   
   assign acc_ptr = rs1_use_acc ? t_acc_ptr1 :
		    rs2_use_acc ? t_acc_ptr2 : 1'b0;
   
   reg [31:0] 	 t_rs1_value;
   reg [31:0] 	 t_rs2_value;
   reg [31:0] 	 t_rs3_value;
   
   //final rs1 decoder
   always@(*)
     begin: rs1_exec_dec
	t_rs1_value = 32'd0;
	t_orf_ptr1 = 2'd0;
	t_orf_ptr1_valid = 1'b0;
	t_acc_ptr1 = 1'b0;
	
	//whatever came into exec from dec was good

	if(fwd_rs1_from_alu)
	  begin
	     t_rs1_value = alu_ex_mem_in;
	  end
	else if(fwd_rs1_from_xmu)
	  begin
	     t_rs1_value = xmu_ex_mem_in;
	  end

	//tr* == ex_mem latch
	else if(rs1_use_tr0)
	  begin
	     t_rs1_value = alu_ex_mem_in;
	  end
	else if(rs1_use_tr1)
	  begin
	     t_rs1_value = xmu_ex_mem_in;
	  end
	
	else if(rs1_use_zr)
	  begin
	     //just being explicit
	     t_rs1_value = 32'd0;
	  end

	else if(rs1_use_orf)
	  begin
	     t_orf_ptr1 =rs1_ptr[1:0];
	     t_orf_ptr1_valid  =1'b1;
	     t_rs1_value = orf_ptr1_in;
	  end

	else if(rs1_use_acc)
	  begin
	     t_acc_ptr1 = rs1_ptr[0];
	     t_rs1_value = rs_accum_norm_read;
	  end

	else if(rs1_in_valid)
	  begin
	     t_rs1_value = rs1_in;
	  end
	
     end // block: rs1_exec_dec


   
   //final rs2 decoder
   always@(*)
     begin: rs2_exec_dec
	t_rs2_value = 32'd0;
	t_orf_ptr2 = 2'd0;
	t_orf_ptr2_valid = 1'b0;
	t_acc_ptr2 = 1'b0;
		//whatever came into exec from dec was good

	if(fwd_rs2_from_alu)
	  begin
	     t_rs2_value = alu_ex_mem_in;
	  end
	else if(fwd_rs2_from_xmu)
	  begin
	     t_rs2_value = xmu_ex_mem_in;
	  end

	//tr* == ex_mem latch
	else if(rs2_use_tr0)
	  begin
	     t_rs2_value = alu_ex_mem_in;
	  end
	else if(rs2_use_tr1)
	  begin
	     t_rs2_value = xmu_ex_mem_in;
	  end
	
	else if(rs2_use_zr)
	  begin
	     //just being explicit
	     t_rs2_value = 32'd0;
	  end

	else if(rs2_use_orf)
	  begin
	     t_orf_ptr2 =rs2_ptr[1:0];
	     t_orf_ptr2_valid  =1'b1;
	     t_rs2_value = orf_ptr2_in;
	  end
	else if(rs2_use_acc)
	  begin
	     t_acc_ptr2 = rs2_ptr[0];
	     t_rs2_value = rs_accum_norm_read;
	  end
	else if(rs2_in_valid)
	  begin
	     t_rs2_value = rs2_in;
	  end
     end // block: rs1_exec_dec

   always@(*)
     begin
	t_rs3_value = rs3_in;
	
	if(fwd_rs3_from_alu)
	  begin
	     t_rs3_value = alu_ex_mem_in;
	  end
	else if(fwd_rs3_from_xmu)
	  begin
	     t_rs3_value = xmu_ex_mem_in;
	  end

     end // always (*)
   
   

   //packed values
   wire [15:0] rs1_pak0 = t_rs1_value[15:0];
   wire [15:0] rs1_pak1 = t_rs1_value[31:16];

   wire [15:0] rs2_pak0 = t_rs2_value[15:0];
   wire [15:0] rs2_pak1 = t_rs2_value[31:16];

   //are the operands packed?
   //remember: no packed operands for immediate operations
   //because extend carries data.

   wire is_imm = (opcode == `A_ADDI) |
	(opcode == `A_SUBI) |
	(opcode == `A_MOVI) |
	(opcode == `A_CMP_EQ) |
	(opcode == `A_CMP_NE) |
	(opcode == `A_CMP_LT) |
	(opcode == `A_CMP_LTE) |
	(opcode == `A_CMP_ULT) |
	(opcode == `A_CMP_ULTE);
   
   wire        operands_packed = extend[3] & !(is_imm);
      
   //exchange packed operands for rs1
   wire        x1 = extend[2] /*& operands_packed*/ & ~is_imm;
   //exchange packed operands for rs2
   wire        x2 = extend[1]/* & operands_packed*/ & ~is_imm;

   wire        saturating_unsigned = !extend[5] & !is_imm;
   wire        saturating_signed = extend[4] & !is_imm;
   
   
   //packed registers
   reg [15:0]  t_rs1_p0, t_rs1_p1;
   reg [15:0]  t_rs2_p0, t_rs2_p1;
      
   always@(*)
     begin: x1_packed
	if(x1)
	  begin
	     //exchange high and low half-words
	     t_rs1_p0 = rs1_pak1;
	     t_rs1_p1 = rs1_pak0;
	  end
	else
	  begin
	     t_rs1_p0 = rs1_pak0;
	     t_rs1_p1 = rs1_pak1;
	  end
     end // block: x1_packed
   
     always@(*)
     begin: x2_packed
	if(x2)
	  begin
	     //exchange high and low half-words
	     t_rs2_p0 = rs2_pak1;
	     t_rs2_p1 = rs2_pak0;
	  end
	else
	  begin
	     t_rs2_p0 = rs2_pak0;
	     t_rs2_p1 = rs2_pak1;
	  end
     end // block: x2_packed
   
   //ready for computation 
   wire [31:0] rs1_packed = {t_rs1_p1, t_rs1_p0};
   wire [31:0] rs2_packed = {t_rs2_p1, t_rs2_p0};
   
   
   //combinational signals into various circuits
   reg 	       t_do_add;
   reg 	       t_do_sub;
   reg 	       t_do_clz;
   reg 	       t_do_abs;
   reg 	       t_do_max;
   reg 	       t_do_min;

   reg 	       t_do_mult;
   reg 	       t_do_mac;
   
   reg 	       t_do_logic_shift;
   reg 	       t_do_arith_shift;
   reg 	       t_do_left_shift;
   reg 	       t_do_right_shift;
   reg 	       t_do_combine;
   reg 	       t_do_extract;

   reg         t_fixed_point;
   
   
   reg [3:0]   t_status;
   
   
   reg [4:0]   t_shift_distance;
   

   
   reg [31:0]  t_operand0, t_operand1;
   
   reg [31:0] t_result;

   reg 	      t_use_byte_mask;
   assign orf_use_byte_mask = t_use_byte_mask;

   reg [1:0]  t_byte_mask;
   assign orf_byte_mask = t_byte_mask;
   
   assign mac_wr_valid = t_do_mac;
   assign mac_wr_ptr = extend[0];
   

   //output from the add/sub fu
   wire [31:0] add_sub_result;
   wire        add_sub_zero;
   wire        add_sub_carry;
   wire        add_sub_overflow;
   wire        add_sub_sign;

   //todo: hook me up
   wire        mult_carry;
   wire        mult_overflow;
   wire        mult_sign;
   
   wire        mult_out_carry = 1'b0;
   wire        shift_out_carry = 1'b0;
   
   //todo: See if we need to gate these (probably)
   assign alu_zero = (t_result == 32'd0);
   assign alu_carry = add_sub_carry | mult_out_carry | shift_out_carry;
   assign alu_overflow = add_sub_overflow;
   assign alu_sign = add_sub_sign | (t_result[31] & saturating_signed);

   wire [3:0] prev_status = {prev_alu_carry, prev_alu_sign,
			     prev_alu_overflow, prev_alu_zero};
   
   //output from the clz
   wire [31:0] clz_result;
   //increment value from abs unit
   wire [31:0] abs_incr;
   //complemented value from abs unit
   wire [31:0] abs_comp;

   //output of max / min unit
   wire [31:0] max_min_result;
   

   //output of the multiplier / mac unit
   wire [31:0] mult_result;

   //output from the shifter
   wire [31:0] shifter_result;

   

   assign alu_exec_rd_out = t_result;
   
   always@(*)
     begin: exec_decoder

	t_do_add = 1'b0;
	t_do_sub = 1'b0;

	t_do_clz = 1'b0;
	t_do_abs = 1'b0;

	t_do_max = 1'b0;
	t_do_min = 1'b0;
			
	t_do_mult = 1'b0;
	t_do_mac = 1'b0;
	
        t_do_logic_shift = 1'b0;
        t_do_arith_shift = 1'b0;
	t_do_left_shift = 1'b0;
	t_do_right_shift = 1'b0;
	t_do_combine = 1'b0;
	t_do_extract = 1'b0;
	t_shift_distance = 5'd0;
	
	t_result = 32'd0;

	t_operand0 = t_rs1_value;
	t_operand1 = t_rs2_value;

	t_status = 4'd0;

	//used for set byte (only works with orf)
	t_use_byte_mask = 1'b0;
	t_byte_mask = 2'd0;

	t_fixed_point = 1'b0;
		
	case(opcode)
	  `A_NOP:
	    begin
	       t_result = alu_ex_mem_in;
	    end
	  `A_MOV:
	    begin
	       t_result =/* x1 ? rs1_packed :*/ t_rs1_value;
	    end
	  `A_MOVI:
	    begin
	       t_result = imm18;
	    end

	  `A_ADD:
	    begin
	       t_do_add = 1'b1;
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ? */rs2_packed /*: t_rs2_value*/;
	       t_result = add_sub_result;
	    end

	  `A_ADDI:
	    begin
	       //packed operations not supported in imm 
	       t_do_add = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_operand1 = imm32;
	       t_result = add_sub_result;
	    end
	  	  
	  `A_SUB:
	    begin
	       t_do_sub = 1'b1;
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ? */rs2_packed /*: t_rs2_value*/;   
	       t_result = add_sub_result;
	    end
	  `A_SUBI:
	    begin
	       //packed operations not supported in imm
	       t_do_sub = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_operand1 = imm32;
	       t_result = add_sub_result;
	    end
	  `A_TEST:
	    begin
	       /*
	       prev_status = {prev_alu_carry, prev_alu_sign,
			     prev_alu_overflow, prev_alu_zero};
		t_status = ~(((prev_status & rs1_ptr[3:0]) ^ (rs2_ptr[3:0])));
		t_result = (|t_status) ? 32'd1 : 32'd0;
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
	  `A_CMP_EQ:
	    begin
	       //t_result = (t_rs1_value == t_rs2_value) ? 32'd1 : 32'd0;
	       t_result = (rs1_packed == rs2_packed) ? 32'd1 : 32'd0;
	    end

	  `A_CMP_NE:
	    begin
	       //t_result = (t_rs1_value != t_rs2_value) ? 32'd1 : 32'd0;
	       t_result = (rs1_packed != rs2_packed) ? 32'd1 : 32'd0;
	    end


	  `A_CMP_LT:
	    begin
	       t_do_sub = 1'b1;
	       t_operand0 = /*t_rs1_value*/ rs1_packed;
	       t_operand1 = /*t_rs2_value*/ rs2_packed;   
	       t_result = add_sub_sign ? 32'd1 : 32'd0; 
	    end

	  `A_CMP_LTE:
	    begin
	       t_do_sub = 1'b1;
	       t_operand0 = /*t_rs1_value*/ rs1_packed;
	       t_operand1 = /*t_rs2_value*/ rs2_packed;   
	       t_result = (add_sub_sign | add_sub_zero) ? 32'd1 : 32'd0; 
	    end

	  `A_CMP_ULT:
	    begin
	       //t_result = (t_rs1_value < t_rs2_value) ? 32'd1 : 32'd0;
	       t_result = (rs1_packed < rs2_packed) ? 32'd1 : 32'd0;
	    end

	  `A_CMP_ULTE:
	    begin
	       t_result = (t_rs1_value <= t_rs2_value) ? 32'd1 : 32'd0;
	       t_result = (rs1_packed <= rs2_packed) ? 32'd1 : 32'd0; 
	    end	  
	  
	  
	  `A_NEG:
	    begin
	       t_do_add = 1'b1;
	       t_operand0 = /*operands_packed ?*/ ~rs1_packed /* : ~t_rs1_value*/;
	       t_operand1 = operands_packed ? {32'h00010001} : 32'd1;
	       t_result = add_sub_result;
	    end
	  
	  `A_ABS:
	    begin
	       t_do_abs = 1'b1;
	       t_do_add = 1'b1;
	       //t_operand0 used to drive abs unit:
	       //  complemented value directly driven into adder
	       //rch, do we need the packed check????
	       t_operand0 = /*operands_packed ?*/ rs1_packed /*: t_rs1_value*/;
      	       t_operand1 = abs_incr ;
	       t_result = add_sub_result;
	    end

	  `A_MAX:
	    begin
	       t_do_max = 1'b1;
	       t_operand0 = /*operands_packed ?*/ rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ?*/ rs2_packed /*: t_rs2_value*/;
	       t_result = max_min_result;
	    end
	  
	  `A_MIN:
	    begin
	       t_do_min = 1'b1;
	       t_operand0 = /*operands_packed ?*/ rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ?*/ rs2_packed /*: t_rs2_value*/;
	       t_result = max_min_result;
	    end

	  `A_MUL:
	    begin
	       t_do_mult = 1'b1;
	       t_operand0 = /*operands_packed ?*/ rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ?*/ rs2_packed /*: t_rs2_value*/;
	       t_result = mult_result;
	    end

	  //Fixed point multiply
	  `A_MUL_F:
	    begin
	       t_do_mult = 1'b1;
	       t_operand0 = /*operands_packed ?*/ rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ?*/ rs2_packed /*: t_rs2_value*/;  
	       t_fixed_point = 1'b1;
	       t_result = mult_result;
	    end

	  //Fixed point multiply accumulate
	  `A_MAC_F:
	    begin
	       t_do_mac = 1'b1;
	       //TODO: select accumulator 
	       t_operand0 =  /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 =  /*operands_packed ? */rs2_packed /*: t_rs2_value*/;	       
	       t_fixed_point = 1'b1;
	       t_result = mult_result;
	    end
	  	  
	  `A_MAC:
	    begin
	       t_do_mac = 1'b1;
	       //TODO: select accumulator 
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ? */rs2_packed /*: t_rs2_value*/;
	       t_result = mult_result;
	    end
	  	  
	  `A_NOT:
	    begin
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_result = ~t_operand0;
	    end

	  `A_CLZ:
	    begin
	       //packed mode not supported
	       t_do_clz = 1'b1;
	       t_result = clz_result;
	    end

	  `A_AND:
	    begin
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ? */rs2_packed /*: t_rs2_value*/;
	       t_result = t_operand0 & t_operand1;
	    end

	  `A_ANDC:
	    begin
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ? */rs2_packed /*: t_rs2_value*/;
	       t_result = t_operand0 & ~t_operand1;
	    end
	  	  
	  `A_OR:
	    begin
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ? */rs2_packed /*: t_rs2_value*/;
	       t_result = t_operand0 | t_operand1;
	    end

	  `A_XOR:
	    begin
	       t_operand0 = /*operands_packed ? */rs1_packed /*: t_rs1_value*/;
	       t_operand1 = /*operands_packed ? */rs2_packed /*: t_rs2_value*/;
	       t_result = t_operand0 ^ t_operand1;
	    end

	  //shift right arith
	  `A_SRA:
	    begin
	       t_do_arith_shift = 1'b1;
	       t_do_right_shift = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_shift_distance = t_rs2_value[4:0];
	       t_result = shifter_result;
	    end

	  //shift right arith (immediate)
	  `A_SRAI:
	    begin
	       t_do_arith_shift = 1'b1;
	       t_do_right_shift = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_shift_distance = rs2_ptr[4:0];
	       t_result = shifter_result;
	    end

	  //shift right logical
	  `A_SRL:
	    begin
	       t_do_logic_shift = 1'b1;
	       t_do_right_shift = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_shift_distance = t_rs2_value[4:0];
	       t_result = shifter_result;
	    end

	  //shift right logical (immediate)
	  `A_SRLI:
	    begin
	       t_do_logic_shift = 1'b1;
	       t_do_right_shift = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_shift_distance = rs2_ptr[4:0];
	       t_result = shifter_result;
	    end


	  //shift left arith
	  `A_SLA:
	    begin
	       t_do_arith_shift = 1'b1;
	       t_do_left_shift = 1'b1;
       	       t_operand0 = t_rs1_value;
	       t_shift_distance = t_rs2_value[4:0];
	       t_result = shifter_result;
	    end

	  //shift left arith (immediate)
	  `A_SLAI:
	    begin
	       t_do_arith_shift = 1'b1;
	       t_do_left_shift = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_shift_distance = rs2_ptr[4:0];	       
	       t_result = shifter_result;
	    end

	  //shift left logical
	  `A_SLL:
	    begin
	       t_do_logic_shift = 1'b1;
	       t_do_left_shift = 1'b1;
	       t_operand0 =  t_rs1_value;
	       t_shift_distance = t_rs2_value[4:0];
	       t_result = shifter_result;
	    end

	  //shift left logical (immediate)
	  `A_SLLI:
	    begin
	       t_do_logic_shift = 1'b1;
	       t_do_left_shift = 1'b1;
	       t_operand0 = t_rs1_value;  
	       t_shift_distance = rs2_ptr[4:0];
	       t_result = shifter_result;
	    end
	  
	  `A_SAE:
	    begin
	       t_do_extract = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_operand1 = t_rs2_value;
	       t_shift_distance = extend[4:0];
	       t_do_right_shift = 1'b1;
	       t_result = shifter_result;
	    end

	  `A_SAC:
	    begin
	       t_do_combine = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_operand1 = t_rs2_value;
	       t_do_right_shift = 1'b1;
	       t_shift_distance = extend[4:0];
	       t_result = shifter_result;
	    end

	  `A_PACKI:
	    begin
	       //i guess you could pack packed registers...
	       t_operand0 = operands_packed ? rs1_packed : t_rs1_value;
	       t_operand1 = operands_packed ? rs2_packed : t_rs2_value;  

	       t_result = {t_operand0[15:0], t_operand1[15:0]};
	    end

	  `A_UNPACKI:
	    begin
	       t_operand0 = operands_packed ? rs1_packed : t_rs1_value;
	       t_result = { {16{t_operand0[15]}}, t_operand0[15:0]};
	    end

	  `A_PACKF:
	    begin
	       //i guess you could pack packed registers...
	       t_operand0 = operands_packed ? rs1_packed : t_rs1_value;
	       t_operand1 = operands_packed ? rs2_packed : t_rs2_value;  

	       //todo, rounding a ffff up will cause an overflow to the next packed integer
	       //todo, really? We're freaking rounding down xxxx8000 COME ON
	       t_result = ((t_operand0[15] & (|t_operand0[14:0] | t_operand0[16])) &
			   (t_operand1[15] & (|t_operand1[14:0] | t_operand1[16]))) ? 
			  (t_operand0[31:16] + 1'b1 << 16) | ((t_operand1[31:16] + 1'b1) & 32'h0000ffff) :
			  
			  (~(t_operand0[15] & (|t_operand0[14:0] | t_operand0[16])) & 
 			   (t_operand1[15] & (|t_operand1[14:0] | t_operand1[16]))) ? 
			  (t_operand0[31:16] << 16) | ((t_operand1[31:16] + 1'b1) & 32'h0000ffff) :
			  
			  ( (t_operand0[15] & (|t_operand0[14:0] | t_operand0[16])) & 
			    ~(t_operand1[15] & (|t_operand1[14:0] | t_operand1[16]))) ? 
			  {t_operand0[31:16], t_operand1[31:16]} + 32'h00010000 : 
			  
			  {t_operand0[31:16], t_operand1[31:16]};
	    end
	  
	  `A_UNPACKF:
	    begin
	       t_operand0 = operands_packed ? rs1_packed : t_rs1_value;
	       t_result = {t_operand0[31:16], 16'd0};
	    end

	  `A_GB:
	    begin
	       t_operand0 = t_rs1_value;
	       t_operand1 = t_rs2_value;

	     
	       if(t_operand1[1:0] == 2'b11)
		 begin
		    t_result = {{24{t_operand0[7]}}  , t_operand0[7:0]};
		 end
	       else if(t_operand1[1:0] == 2'b10)
		 begin
		    t_result = {{24{t_operand0[15]}} , t_operand0[15:8]};
		 end
	       else if(t_operand1[1:0] == 2'b01)
		 begin
		    t_result = {{24{t_operand0[23]}}, t_operand0[23:16]};
		 end
	       else
		 begin
		    t_result = {{24{t_operand0[31]}}, t_operand0[31:24]};
		 end
	    end

	  //sign extend GB
	  `A_GB_S:
	    begin
	       t_operand0 = t_rs1_value;
	       t_operand1 = t_rs2_value;
	     
	       if(t_operand1[1:0] == 2'b11)
		 begin
		    t_result = {{24{t_operand0[7]}}  , t_operand0[7:0]};
		 end
	       else if(t_operand1[1:0] == 2'b10)
		 begin
		    t_result = {{24{t_operand0[15]}} , t_operand0[15:8]};
		 end
	       else if(t_operand1[1:0] == 2'b01)
		 begin
		    t_result = {{24{t_operand0[23]}}, t_operand0[23:16]};
		 end
	       else
		 begin
		    t_result = {{24{t_operand0[31]}}, t_operand0[31:24]};
		 end
	    end
	  

	  
	  `A_SB:
	    begin
	       //only implemented for ORF!!!
	       t_use_byte_mask = 1'b1;
	       t_operand0 = t_rs1_value;
	       t_operand1 = t_rs2_value;

	       t_byte_mask = t_rs2_value[1:0];
	       t_result = t_operand0;
	    end

	  `A_SEL:
	    begin 
	       t_result = t_rs3_value[0] ? t_rs1_value : t_rs2_value;
	    end
	  

	  
	  default:
	    begin
	       t_result = 32'd0;
	    end
	  
	  endcase // case (opcode)
     end
   
   
   //functional units

   wire [31:0] add_op0 = (t_do_abs) ? abs_comp : t_operand0;



      
   alu_add_sub u0(
		  // Outputs
		  .result		(add_sub_result),
		  .gen_zero		(add_sub_zero),
		  .gen_carry		(add_sub_carry),
		  .gen_overflow	        (add_sub_overflow),
		  .out_sign		(add_sub_sign),  
		  // Inputs
		  .is_packed		(operands_packed),
		  .is_saturating_signed	(saturating_signed),
		  .is_saturating_unsigned(saturating_unsigned),
		  .is_add		(t_do_add),
		  .is_sub		(t_do_sub),
		  .operand0		((t_do_add|t_do_sub) ? add_op0 : 32'd0),
		  .operand1		((t_do_add|t_do_sub) ? t_operand1 : 32'd0));

   alu_clz u1(
	      // Outputs
	      .y			(clz_result),
	      // Inputs
	      .a			(t_do_clz ? t_operand0 : 32'd0),
	      .enable			(t_do_clz)
	      );
   
   alu_abs u2(
	      // Outputs
	      .y			(abs_comp),
	      .add			(abs_incr),
	      // Inputs
	      .a			(t_do_abs ? t_operand0 : 32'd0),
	      .is_packed		(operands_packed),
	      .enable			(t_do_abs)
	      );
   
   
   alu_max_min u3(
		  // Outputs
		  .result		(max_min_result),
		  // Inputs
		  .operand0		((t_do_min | t_do_max) ? t_operand0 : 32'd0),
		  .operand1		((t_do_min | t_do_max) ? t_operand1 : 32'd0),
		  .do_min		(t_do_min),
		  .do_max		(t_do_max),
		  .is_packed		(operands_packed),
		  .is_signed		(~saturating_unsigned)
		  );

   //TODO: FIX OPERAND2

   wire        w_is_unsigned = 1'b0;
   wire        w_is_signed = !saturating_unsigned;
   
   
   alu_mult u4(
	       // Outputs
	       .result			(mult_result),
	       .carry (mult_carry),
	       .overflow (mult_overflow),
	       .sign (mult_sign),
	       // Inputs
	       .operand0		(is_mul ? t_operand0 : 32'd0),
	       .operand1		(is_mul ? t_operand1 : 32'd0),
	       .operand2		(rs_accum), //accumulator
	       .do_mult			(t_do_mult),
	       .do_mac			(t_do_mac),
	       .is_signed_saturating	(saturating_signed),
	       .is_unsigned_saturating	(saturating_unsigned),
	       .is_unsigned             (w_is_unsigned),
	       .is_signed               (w_is_signed),
	       .is_fixed_point          (t_fixed_point)
	       
	       );
   

   wire        shift_it = t_do_logic_shift | t_do_arith_shift | t_do_combine | t_do_extract;
      
   
   alu_shifter u5(
		  // Outputs
		  .y			(shifter_result),
		  // Inputs
		  .operand0		(shift_it ? t_operand0 : 32'd0),
		  .operand1		(shift_it ? t_operand1 : 32'd0 ),
		  .shift_distance	(t_shift_distance),
		  .is_packed		(operands_packed),
		  .is_signed_saturating	(saturating_signed),
		  .is_unsigned_saturating(saturating_unsigned),
		  .logic_shift		(t_do_logic_shift),
		  .arith_shift		(t_do_arith_shift),
		  .right_shift		(t_do_right_shift),
		  .left_shift		(t_do_left_shift),
		  .combine		(t_do_combine),
		  .extract		(t_do_extract)
		  );

   
   
   
endmodule // alu_exec
