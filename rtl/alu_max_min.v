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


module alu_max_min(/*AUTOARG*/
   // Outputs
   result,
   // Inputs
   operand0, operand1, do_min, do_max, is_packed, is_signed
   );
   input [31:0] operand0;
   input [31:0] operand1;

   input 	do_min;
   input 	do_max;
   
   input 	is_packed;
   input 	is_signed;
   
   output [31:0] result;
   reg [31:0] 	 t_result;

   wire [15:0] 	 op0_pk0 = operand0[15:0];
   wire [15:0] 	 op0_pk1 = operand0[31:16];

   wire [15:0] 	 op1_pk0 = operand1[15:0];
   wire [15:0] 	 op1_pk1 = operand1[31:16];  

   reg [15:0] 	 t_pk0, t_pk1;
   

   assign result = t_result;
   
   
   always@(*)
     begin
	t_result = 32'd0;
	t_pk0 = 16'd0;
	t_pk1 = 16'd0;
		
	if(is_packed)
	  begin
	     t_result = {t_pk1,t_pk0};
	     
	     if(is_signed)
	       begin
		  if(do_min)
		    begin
		       //op1_pk0 is negative
		       if(!op0_pk0[15] & op1_pk0[15])
			 begin
			    t_pk0 = op1_pk0;
			 end
		       //op0_pk0 is negative
		       else if(op0_pk0[15] & !op1_pk0[15])
			 begin
			    t_pk0 = op0_pk0;
			 end
		       //op0_pk0 and op1 have the same sign
		       else
			 begin
			    t_pk0 = (op0_pk0 < op1_pk0) ? op0_pk0 : op1_pk0;
			 end

		       //op1_pk1 is negative
		       if(!op0_pk1[15] & op1_pk1[15])
			 begin
			    t_pk1 = op1_pk1;
			 end
		       //op0_pk1 is negative
		       else if(op0_pk1[15] & !op1_pk1[15])
			 begin
			    t_pk1 = op0_pk1;
			 end
		       //op0_pk1 and op1 have the same sign
		       else
			 begin
			    t_pk1 = (op0_pk1 < op1_pk1) ? op0_pk1 : op1_pk1;
			 end
		    end // if (do_min)
		  

		  else if(do_max)
		    begin
		       //op1_pk0 is negative
		       if(!op0_pk0[15] & op1_pk0[15])
			 begin
			    t_pk0 = op0_pk0;
			 end
		       //op0_pk0 is negative
		       else if(op0_pk0[15] & !op1_pk0[15])
			 begin
			    t_pk0 = op1_pk0;
			 end
		       //op0_pk0 and op1 have the same sign
		       else
			 begin
			    t_pk0 = (op0_pk0 < op1_pk0) ? op1_pk0 : op0_pk0;
			 end

		       //op1_pk1 is negative
		       if(!op0_pk1[15] & op1_pk1[15])
			 begin
			    t_pk1 = op0_pk1;
			 end
		       //op0_pk1 is negative
		       else if(op0_pk1[15] & !op1_pk1[15])
			 begin
			    t_pk1 = op1_pk1;
			 end
		       //op0_pk1 and op1 have the same sign
		       else
			 begin
			    t_pk1 = (op0_pk1 < op1_pk1) ? op1_pk1 : op0_pk1;
			 end
		    end
		  
	       end	     
	     else
	       begin
		  if(do_min)
		    begin
		       t_pk0 = (op0_pk0 < op1_pk0) ? op0_pk0 : op1_pk0;
		       t_pk1 = (op0_pk1 < op1_pk1) ? op0_pk1 : op1_pk1;
		    end
		  else if(do_max)
		    begin
		       t_pk0 = (op0_pk0 < op1_pk0) ? op1_pk0 : op0_pk0;
		       t_pk1 = (op0_pk1 < op1_pk1) ? op1_pk1 : op0_pk1;	       
		    end
	       end
	  end // if (is_packed)
	
	else
	  begin
	     if(is_signed)
	       begin
		  //need to check signs of operands
		  
		  if(do_min)
		    begin
		       //operand0 is negative
		       if(operand0[31] & !operand1[31])
			 begin
			    t_result = operand0;
			 end
		       //operand1 is negative
		       else if(!operand0[31] & operand1[31])
			 begin
			    t_result = operand1;
			 end
		       //both operands have the same sign
		       else 
			 begin
			    t_result = (operand0 < operand1) ?
				       operand0 : operand1;
			 end
		    end // if (do_min)
		  else if(do_max)
		    begin
		       //operand0 is negative
		       if(operand0[31] & !operand1[31])
			 begin
			    t_result = operand1;
			 end
		       //operand1 is negative
		       else if(!operand0[31] & operand1[31])
			 begin
			    t_result = operand0;
			 end
		       //both operands have the same sign
		       else 
			 begin
			    t_result = (operand0 < operand1) ?
				       operand1 : operand0;
			 end
		    end // if (do_max)
	       end
	     //unsigned compares
	     else
	       begin
		  if(do_min)
		    begin
		       t_result = (operand0 < operand1) ?
				  operand0 : operand1;
		    end
		  else if(do_max)
		    begin
		       t_result = (operand0 > operand1) ?
				  operand0 : operand1;
		       end
	       end // else: !if(is_signed)
	  end // else: !if(is_packed)
     end // always@ (*)
   
      
endmodule // alu_max_min
