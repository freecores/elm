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


//to be used with adder to take two's complement
module alu_abs(/*AUTOARG*/
   // Outputs
   y, add,
   // Inputs
   a, is_packed, enable
   );
   input [31:0] a;
   input 	is_packed;
   input 	enable;

   output [31:0] y;
   output [31:0] add;
   

   wire [15:0] 	 pk0 = a[15:0];
   wire [15:0] 	 pk1 = a[31:16];

   reg [31:0] 	 t_out;
   reg [31:0] 	 t_add;

   assign y = t_out;
   assign add = t_add;
      
   always@(*)
     begin
	t_out = 32'd0;
	t_add = 32'd0;
	
	if(enable)
	  begin
	     if(is_packed)
	       begin
		  //both packed values are negative
		  if(pk0[15] & pk1[15])
		    begin
		       t_out = ~a;
		       t_add = {32'h00010001};
		    end

		  //lower packed value is negative
		  else if(pk0[15])
		    begin
		       t_out = {pk1, ~pk0};
		       t_add = 32'd1;
		    end
		  //upper packed value is negative
		  else if(pk1[15])
		    begin
		       t_out = {~pk1, pk0};
		       t_add = 32'h00010000;
		    end
		  //both are positive
		  else
		    begin
		       t_out = a;
		       t_add = 32'd0;
		    end
	       end
	     else
	       begin
		  if(a[31])
		     begin
			t_out = ~a;
			t_add = 32'd1;
		     end
		  else
		    begin
		       t_out = a;
		       t_add = 32'd0;
		    end
	       end // else: !if(is_packed)
	  end // if (enable)
     end // always@ (*)
   
   

endmodule // alu_abs
