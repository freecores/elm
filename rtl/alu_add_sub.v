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


module alu_add_sub(/*AUTOARG*/
   // Outputs
   result, gen_zero, gen_carry, gen_overflow, out_sign,
   // Inputs
   is_packed, is_saturating_signed, is_saturating_unsigned, is_add,
   is_sub, operand0, operand1
   );
   input is_packed;
   input is_saturating_signed;
   input is_saturating_unsigned;
  
   input is_add;
   input is_sub;
   
   
   input [31:0] operand0;
   input [31:0] operand1;

   output [31:0] result;
  
   output 	gen_zero;
   output 	gen_carry;
   output 	gen_overflow;
   output 	out_sign;
      
   wire [15:0] 	 op0_pk0 = operand0[15:0];
   wire [15:0] 	 op0_pk1 = operand0[31:16];
   wire [15:0] 	 op1_pk0 = operand1[15:0];
   wire [15:0] 	 op1_pk1 = operand1[31:16];
   
   
   reg [31:0]  t_result;
   reg [16:0]  t_pk0, t_pk1;

   reg [32:0]  t_norm;

   reg 	       t_pk0_signed_overflow;
   reg 	       t_pk1_signed_overflow;
   reg 	       t_pk0_signed_underflow;
   reg 	       t_pk1_signed_underflow;
   reg 	       t_pk0_unsigned_overflow;
   reg 	       t_pk1_unsigned_overflow;
   reg 	       t_pk0_unsigned_underflow;
   reg 	       t_pk1_unsigned_underflow;

   reg 	       t_out_sign;
   reg 	       t_carry;
   reg 	       t_overflow;
   
   
   assign result = t_result;
   assign gen_zero = (t_result == 32'd0);

   assign gen_carry = t_carry;
   assign gen_overflow = t_overflow;
   assign out_sign = t_out_sign;



   always@(*)
     begin: add_sub
	t_result = 32'd0;
	t_norm = 33'd0;
	
	t_pk0 = 17'd0;
	t_pk1 = 17'd0;
	
	t_pk0_signed_overflow = 1'b0;
	t_pk1_signed_overflow = 1'b0;
 	t_pk0_signed_underflow = 1'b0;
	t_pk1_signed_underflow = 1'b0;

	t_pk0_unsigned_overflow = 1'b0;
	t_pk1_unsigned_overflow = 1'b0;
 	t_pk0_unsigned_underflow = 1'b0;
	t_pk1_unsigned_underflow = 1'b0;

	t_out_sign = 1'b0;
	t_carry = 1'b0;
	t_overflow = 1'b0;

	if(is_packed)
	  begin
	     if(is_add)
	       begin
		  t_pk0 = {~is_saturating_unsigned & op0_pk0[15], op0_pk0} 
		  + {~is_saturating_unsigned & op1_pk0[15], op1_pk0};
		  t_pk1 =  {~is_saturating_unsigned & op0_pk1[15], op0_pk1}
		  + {~is_saturating_unsigned & op1_pk1[15], op1_pk1};

		  t_pk0_signed_overflow = 
		    !op0_pk0[15] & !op1_pk0[15] & t_pk0[15];
		  t_pk1_signed_overflow = 
		    !op0_pk1[15] & !op1_pk1[15] & t_pk1[15];
		  
		  t_pk0_unsigned_overflow = t_pk0[16];
		  t_pk1_unsigned_overflow = t_pk1[16];
		  		    
		  t_pk0_signed_underflow =
		    op0_pk0[15] & op1_pk0[15] & ~t_pk0[15];
		  t_pk1_signed_underflow =
		    op0_pk1[15] & op1_pk1[15] & ~t_pk1[15];

		  //todo: see how we handle packed carries
		  t_carry = t_pk1[16] /*| t_pk0[16]*/; 
		  t_overflow = is_saturating_unsigned ? t_pk1_unsigned_overflow :
			       (t_pk1_signed_overflow | t_pk1_signed_underflow);
		  t_out_sign = is_saturating_unsigned ? 1'b0 :
			       is_saturating_signed & t_pk1_signed_overflow ? 1'b0 :
			       is_saturating_signed & t_pk1_signed_underflow ? 1'b1 :
			       t_pk1[15];
		  
		  if(is_saturating_signed)
		    begin
		       t_result[15:0] = t_pk0_signed_overflow ? 16'h7fff : 
					 t_pk0_signed_underflow ? 16'h8000 : 
					 t_pk0[15:0];
		       t_result[31:16] = t_pk1_signed_overflow ? 16'h7fff : 
					  t_pk1_signed_underflow ? 16'h8000 : 
					  t_pk1[15:0];
		    end
		  else if(is_saturating_unsigned)
		    begin
		       t_result[15:0] = t_pk0_unsigned_overflow ? 16'hffff : t_pk0[15:0];
		       t_result[31:16] = t_pk1_unsigned_overflow ? 16'hffff : t_pk1[15:0];
		    end
		  else
		    begin
		       t_result = {t_pk1[15:0], t_pk0[15:0]};
		    end // else: !if(is_saturating_unsigned)		  
	       end // if (is_add)
	     
	     else if(is_sub)
	       begin
		  
		  //Overflow (signed) if 0 is + and 1 is - and result is neg
		  //Underflow (signed) if 0 is - and 1 is + and the result is pos
		  //Overflow (unsigned) is impossible
		  //Underflow (unsigned) is if 1 > 0
		  t_pk0 =  {~is_saturating_unsigned & op0_pk0[15], op0_pk0}
		  - {~is_saturating_unsigned & op1_pk0[15], op1_pk0};
		  t_pk1 =  {~is_saturating_unsigned & op0_pk1[15], op0_pk1}
		  - {~is_saturating_unsigned & op1_pk1[15], op1_pk1};
		  
		  t_pk0_signed_overflow = op0_pk0[15] & ~op1_pk0[15] & ~t_pk0[15];
		  t_pk0_signed_underflow =~op0_pk0[15] & op1_pk0[15] & t_pk0[15];

		  t_pk1_signed_overflow = op0_pk1[15] & ~op1_pk1[15] & ~t_pk1[15];
		  t_pk1_signed_underflow =~op0_pk1[15] & op1_pk1[15] & t_pk1[15];

		  t_pk0_unsigned_underflow = {1'b0, op0_pk0} < {1'b0, op1_pk0}; //todo
		  t_pk1_unsigned_underflow = {1'b0, op0_pk1} < {1'b0, op1_pk1}; //todo

		  t_carry = t_pk1[16]; //todo: verify
		  
		  t_overflow = is_saturating_signed ?  t_pk1_unsigned_overflow : 
			       is_saturating_unsigned ? 
			       (t_pk1_signed_overflow | t_pk1_signed_underflow)  :
			       (t_pk1_signed_overflow | t_pk1_signed_underflow);
		  
		  t_out_sign = is_saturating_unsigned ? 1'b0 :
			       is_saturating_signed & t_pk1_signed_overflow ? 1'b0 :
			       is_saturating_signed & t_pk1_signed_underflow ? 1'b1 :
			       t_pk1[15];
		  
		  if(is_saturating_signed)
		    begin
		       t_result[15:0] = t_pk0_signed_overflow ? 16'h7fff :
					 t_pk0_signed_underflow ? 16'h8000 :
					 t_pk0[15:0];
		       t_result[31:16] = t_pk1_signed_overflow ? 16'h7fff :
					  t_pk1_signed_underflow ? 16'h8000 :
					  t_pk1[15:0];
		    end
		  else if(is_saturating_unsigned)
		    begin
		       t_result[15:0] = t_pk0_unsigned_underflow ? 16'd0 :
					 t_pk0[15:0];
		       t_result[31:16] = t_pk1_unsigned_underflow ? 16'd0 :
					  t_pk1[15:0];
		    end // if (is_saturating_unsigned)
		  else
		    begin
		       t_result = {t_pk1[15:0], t_pk0[15:0]};
		    end
		  
	       end
	  end // if (is_packed)
	
	else if(!is_packed)
	  begin
	     if(is_add)
	       begin
		  t_norm = {~is_saturating_unsigned & operand0[31], operand0} 
		  + {~is_saturating_unsigned & operand1[31], operand1};
		  t_pk1_signed_overflow = ~operand0[31] & ~operand1[31] & t_norm[31];
		  t_pk1_signed_underflow = operand0[31] & operand1[31] & ~t_norm[31];
		  t_pk1_unsigned_overflow = t_norm[32];

		  t_out_sign = is_saturating_unsigned ? 1'b0 : 
			       is_saturating_signed & t_pk1_signed_overflow ? 1'b0 :
			       is_saturating_signed & t_pk1_signed_underflow ? 1'b1 :
			       t_norm[31];
		  t_carry = t_norm[32]; //todo

		  t_overflow = is_saturating_unsigned ? t_pk1_unsigned_overflow :
			       (t_pk1_signed_overflow | t_pk1_signed_underflow);
		  
		  if(is_saturating_signed)
		    begin
		       t_result = t_pk1_signed_overflow ? 32'h7fffffff :
				   t_pk1_signed_underflow ? 32'h80000000 :
				   t_norm[31:0];
		    end // if (is_saturating_signed)
		  else if(is_saturating_unsigned)
		    begin
		       t_result = t_pk1_unsigned_overflow ? 32'hffffffff : t_norm[31:0];
		    end // if (is_saturating_unsigned)
		  else
		    begin
		       t_result = t_norm[31:0];
		    end
	       end // if (is_add)
	     else if(is_sub)
	       begin
		  t_norm = {~is_saturating_unsigned & operand0[31], operand0} 
		  - {~is_saturating_unsigned & operand1[31], operand1};

		  t_pk1_signed_overflow = operand0[31] & ~operand1[31] & ~t_norm[31];
		  t_pk1_signed_underflow =~operand0[31] & operand1[31] & t_norm[31];
		  t_pk1_unsigned_underflow = {1'b0, operand0} < {1'b0, operand1}; //todo
		  
		  t_carry = t_norm[32]; //todo: verify
		  t_overflow = is_saturating_signed ?  t_pk1_unsigned_overflow : 
			       is_saturating_unsigned ? 
			       (t_pk1_signed_overflow | t_pk1_signed_underflow)  :
			       (t_pk1_signed_overflow | t_pk1_signed_underflow);
		  t_out_sign = is_saturating_unsigned ? 1'b0 :
			       is_saturating_signed & t_pk1_signed_overflow ? 1'b0 :
			       is_saturating_signed & t_pk1_signed_underflow ? 1'b1 :
			       t_norm[31];
		  if(is_saturating_signed)
		    begin
		       t_result = t_pk1_signed_overflow ? 32'h7fffffff :
				   t_pk1_signed_underflow ? 32'h80000000 :
				   t_norm[31:0];
		    end // if (is_saturating_signed)
		  else if(is_saturating_unsigned)
		    begin
		       t_result = t_pk1_unsigned_underflow ? 32'd0 : t_norm[31:0];
		    end // if (is_saturating_unsigned)
		  else
		    begin
		       t_result = t_norm[31:0];
		    end
	       end
	  end

	

     end // block: add_sub
   
   
   
endmodule // alu_add_sub
