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


module alu_clz(/*AUTOARG*/
   // Outputs
   y,
   // Inputs
   a, enable
   );
   input [31:0] a;
   input 	enable;
   
   output [31:0] y;

   reg [31:0] 	 clz;


   assign y = clz;
      
   always@(*)
     begin
	clz = 32'd0;
	if(enable)
	  begin
	     casex(a)
	       32'b00000000000000000000000000000000:
		 begin
		    clz = 32'd32;
		 end
	       32'b00000000000000000000000000000001:
		 begin
		    clz = 32'd31;
		 end
	       32'b0000000000000000000000000000001x:
		 begin
		    clz = 32'd30;
		 end
	       32'b000000000000000000000000000001xx:
		 begin
		    clz = 32'd29;
		 end
	       32'b00000000000000000000000000001xxx:
		 begin
		    clz = 32'd28;
		 end
	       32'b0000000000000000000000000001xxxx:
		 begin
		    clz = 32'd27;
		 end
	       32'b000000000000000000000000001xxxxx:
		 begin
		    clz = 32'd26;
		 end
	       32'b00000000000000000000000001xxxxxx:
		 begin
		    clz = 32'd25;
		 end
	       32'b0000000000000000000000001xxxxxxx:
		 begin
		    clz = 32'd24;
		 end	  
	       32'b000000000000000000000001xxxxxxxx:
		 begin
		    clz = 32'd23;
		 end
	       32'b00000000000000000000001xxxxxxxxx:
		 begin
		    clz = 32'd22;
		 end
	       32'b0000000000000000000001xxxxxxxxxx:
		 begin
		    clz = 32'd21;
		 end
	       32'b000000000000000000001xxxxxxxxxxx:
		 begin
		    clz = 32'd20;
		 end
	       32'b00000000000000000001xxxxxxxxxxxx:
		 begin
		    clz = 32'd19;
		 end
	       32'b0000000000000000001xxxxxxxxxxxxx:
		 begin
		    clz = 32'd18;
		 end
	       32'b000000000000000001xxxxxxxxxxxxxx:
		 begin
		    clz = 32'd17;
		 end	  
	       
	       32'b00000000000000001xxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd16;
		 end	  
	       32'b0000000000000001xxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd15;
		 end
	       32'b000000000000001xxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd14;
		 end
	       
	       32'b00000000000001xxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd13;
		 end
	       
	       32'b0000000000001xxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd12;
		 end
	       
	       32'b000000000001xxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd11;
		 end
	       
	       32'b00000000001xxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd10;
		 end
	       
	       32'b0000000001xxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd9;
		 end
	       
	       32'b000000001xxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd8;
		 end
	       
	       32'b00000001xxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd7;
		 end
	       
	       32'b0000001xxxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd6;
		 end
	       
	       32'b000001xxxxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd5;
		 end
	       
	       32'b00001xxxxxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd4;
		 end
	       
	       32'b0001xxxxxxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd3;
		 end
	       
	       32'b001xxxxxxxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd2;
		 end
	       
	       32'b01xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd1;
		 end
	       
	       32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:
		 begin
		    clz = 32'd0;
		 end
	       default:
		 begin
		    clz = 32'd0;
		 end
	     endcase // casex (operand)
	  end // if (en)
     end // always@ (*)
      
endmodule // alu_clz
