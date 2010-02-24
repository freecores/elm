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


module from_ascii(
   // Outputs
   out_bin,
   // Inputs
   in_ascii
   );
   input [7:0] in_ascii;
   output reg [3:0] out_bin;

   always@(in_ascii)
     begin
	case(in_ascii)
	  8'h30: out_bin = 4'h0;
	  8'h31: out_bin = 4'h1;
	  8'h32: out_bin = 4'h2;
	  8'h33: out_bin = 4'h3;
	  8'h34: out_bin = 4'h4;
	  8'h35: out_bin = 4'h5;
	  8'h36: out_bin = 4'h6;
	  8'h37: out_bin = 4'h7;
	  8'h38: out_bin = 4'h8;
	  8'h39: out_bin = 4'h9;
	  8'h41: out_bin = 4'ha;
	  8'h42: out_bin = 4'hb;
	  8'h43: out_bin = 4'hc;
	  8'h44: out_bin = 4'hd;
	  8'h45: out_bin = 4'he;
	  8'h46: out_bin = 4'hf;
	  8'h61: out_bin = 4'ha;
	  8'h62: out_bin = 4'hb;
	  8'h63: out_bin = 4'hc;
	  8'h64: out_bin = 4'hd;
	  8'h65: out_bin = 4'he;
	  8'h66: out_bin = 4'hf;	  
	  default: out_bin = 4'h0;
	endcase // case (in_ascii)
     end
   
		     
endmodule // from_ascii
