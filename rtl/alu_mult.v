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


module alu_mult(
   // Outputs
   result, carry, overflow, sign,
   // Inputs
   operand0, operand1, operand2, do_mult, do_mac,
   is_signed_saturating, is_unsigned_saturating, is_signed,
   is_unsigned, is_fixed_point
   );
   input [31:0] operand0;
   input [31:0] operand1;
   input [31:0] operand2;   //for mac
   input 	do_mult;
   input 	do_mac;
   input 	is_signed_saturating;
   input 	is_unsigned_saturating;
   input 	is_signed;
   input 	is_unsigned;
   input 	is_fixed_point;

   output [31:0] result;
   output 	 carry;
   output 	 overflow;
   output 	 sign;
   
   wire op0neg, op1neg;
   reg signed [16:0] mulop0, mulop1;
   wire signed [31:0] mulres;          //raw mul output
   reg [31:0] mulres_fixed;     //negated and corrected for fp
   reg [31:0] macres;           //raw result of mac
   reg [31:0] macres_sat;       //post saturation result of mac
   reg overflow_r, carry_r;

   reg gate;

   //mul16x16e32 mul(.op0(mulop0), .op1(mulop1), .result(mulres));
   assign mulres = mulop0*mulop1;

   assign result = macres_sat;
   assign overflow = overflow_r;
   assign carry = carry_r;
   assign op0neg = operand0[15] & is_signed;
   assign op1neg = operand1[15] & is_signed;
   assign op0negfp = operand0[31] & is_signed;
   assign op1negfp = operand1[31] & is_signed;

   //mul operands
   always @(*) begin 
       gate = do_mult|do_mac;

       if(is_fixed_point) begin
           mulop0 = {op0negfp,operand0[31:16]}&{17{gate}};
           mulop1 = {op1negfp,operand1[31:16]}&{17{gate}};
       end else begin
           mulop0 = {op0neg,operand0[15:0]}&{17{gate}};
           mulop1 = {op1neg,operand1[15:0]}&{17{gate}};
       end

       /*
       if(is_signed) begin
           if(op0neg) begin
               mulop0 = ~(operand0[15:0]) + 16'd1;
           end
           if(op1neg) begin
               mulop1 = ~(operand1[15:0]) + 16'd1;
           end
       end
       */
   end

   //mul result
   always @(*) begin
       //some ugly behavioral stuff in here, i think dc can handle it...
       mulres_fixed = mulres;
       if(is_fixed_point) begin
           mulres_fixed = mulres_fixed<<1;
       end

       //negate if its a negative result
           /*
       if(op0neg ^ op1neg) begin
           mulres_fixed = ~(mulres_fixed) + 1;
       end
       */
   end

   //mac
   always @(*) begin
       macres = mulres_fixed;
       macres_sat = mulres_fixed;
       overflow_r=0;
       carry_r = 0;
       if(do_mac) begin
           //Accumulate (with gating)
           {carry_r,macres} = mulres_fixed+(operand2&{32{do_mac}});
           macres_sat = macres; //behavioral

           //check for overflow and saturate
           if(is_signed) begin
               if(~macres[31]&mulres_fixed[31]&operand2[31]) begin
                   overflow_r = 1;
                   if(is_signed_saturating) begin
                       macres_sat = 32'h7FFFFFFF;
                   end
               end
               if(macres[31]&~mulres_fixed[31]&~operand2[31])begin
                   overflow_r = 1;
                   if(is_signed_saturating) begin
                       macres_sat = 32'h80000000;
                   end
               end
           end else begin
               overflow_r = carry_r;    //behavioral
               if(is_unsigned_saturating) begin
                   macres_sat = 32'hFFFFFFFF;
               end
           end
       end
   end

endmodule 


