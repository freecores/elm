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


module alu_shifter(/*AUTOARG*/
   // Outputs
   y,
   // Inputs
   operand0, operand1, shift_distance, is_packed,
   is_signed_saturating, is_unsigned_saturating, logic_shift,
   arith_shift, right_shift, left_shift, combine, extract
   );
   input [31:0] operand0;
   input [31:0] operand1;
   
   input [4:0] 	shift_distance;

   input 	is_packed;
   input 	is_signed_saturating;
   input 	is_unsigned_saturating;

   input 	logic_shift;
   input 	arith_shift;
   input 	right_shift;
   input 	left_shift;

   input 	combine;
   input 	extract;
   
     
   output [31:0] y;
   
   
   reg [31:0] 	 t_out;

   assign y = t_out;
   
   
   /* 
    sra = shift arithmetic right
    srl = shift arithmetic left
    
    sra = shift logical right
    sll = shift logical left
    
    sae = shift and extract
    (shift then and)
    
    sac = shift and combine
    (shift then or)
    */


   /* Building the funnel shifter
    * shown on page 691 of CMOS VLSI
    * Design */

   reg [62:0] 	 t_z;
   reg [4:0] 	 t_kl;
   reg [62:0] 	 t_y;

   wire 	 barrel_shift = combine | extract;
           
   always@(*)
     begin
	t_z = 63'd0;
	t_kl = 5'd0;
	t_y = 63'd0;
	t_out = 32'd0;
		
	if(arith_shift & right_shift)
	  begin
	     t_z = { {31{operand0[31]}}, operand0};
	     t_kl = shift_distance;
	  end

	else if(arith_shift & left_shift)
	  begin
	     t_z = {operand0, 31'd0};
	     t_kl = ~shift_distance;
	  end
		
	else if(logic_shift & right_shift)
	  begin
	     t_z = {31'd0, operand0};
	     t_kl = shift_distance;
	     
	  end
	else if(logic_shift & left_shift)
	  begin
	     t_z = {operand0, 31'd0};
	     t_kl = ~shift_distance;
	  end

	else if(barrel_shift & right_shift)
	  begin
	     t_z = {operand0[30:0], operand0};
	     t_kl = shift_distance;
	  end

	else if(barrel_shift & left_shift)
	  begin
	     t_z = {operand0, operand0[31:1]};
	     t_kl = ~shift_distance;
	  end
	
	t_y = (t_z >> t_kl);
	
	if(combine)
	  begin
	     t_out = t_y[31:0] | operand1;
	  end
	else if(extract)
	  begin
	     t_out = t_y[31:0] & operand1;
	  end
	else
	  begin
	     t_out = t_y[31:0];
	  end
     end
   
   
endmodule // alu_shifter

   