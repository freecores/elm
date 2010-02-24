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


module arb3to1_hold(/*AUTOARG*/
   // Outputs
   gnt_0, gnt_1, gnt_2, 
   // Inputs
   CLK, rst, req_0, req_1, req_2, hold_0, hold_1, hold_2
   );


   input CLK;
   input rst;

   input req_0;
   input req_1;
   input req_2;
   input hold_0;
   input hold_1;
   input hold_2;

   output gnt_0;
   output gnt_1;
   output gnt_2;

   reg 	  gnt_0;
   reg 	  gnt_1;
   reg 	  gnt_2;

   reg 	  last_gnt0;
   reg 	  last_gnt1;
   reg 	  last_gnt2;

   always@(posedge CLK or posedge rst)
     begin
	if(rst)
	  begin
	     last_gnt0 <= 1'b0;
	     last_gnt1 <= 1'b0;
	     last_gnt2 <= 1'b0;
	  end
	else
	  begin
	     last_gnt0 <= gnt_0;
	     last_gnt1 <= gnt_1;
	     last_gnt2 <= gnt_2;
	  end // else: !if(rst)
     end // always@ (posedge CLK)

   always@(*)
     begin
	if(last_gnt0 & hold_0) begin
	   gnt_0 = 1'b1;
	   gnt_1 = 1'b0;
	   gnt_2 = 1'b0;
	end
	else if(last_gnt1& hold_1) begin
	   gnt_0 = 1'b0;
	   gnt_1 = 1'b1;
	   gnt_2 = 1'b0;
	end
	else if(last_gnt2 & hold_2) begin
	   gnt_0 = 1'b0;
	   gnt_1 = 1'b0;
	   gnt_2 = 1'b1;
	end  
	else if(last_gnt0 & ~hold_0) begin
	   gnt_1 = req_1 ? 1'b1 : 1'b0;
	   gnt_2 = req_1 ? 1'b0 : 
		    req_2 ? 1'b1 : 1'b0;
	   gnt_0 = (req_1 | req_2)? 1'b0 : 
		    req_0 ? 1'b1 : 1'b0;
	end
	else if(last_gnt1 & ~hold_1) begin
	   gnt_2 = req_2 ? 1'b1 : 1'b0;
	   gnt_0 = (req_2) ? 1'b0 : 
		    req_0 ? 1'b1 : 1'b0;
	   gnt_1 = (req_2 | req_0 )? 1'b0 : 
		    req_1 ? 1'b1 : 1'b0;
	end
	else if(last_gnt2 & ~hold_2) begin
	   gnt_0 = req_0 ? 1'b1 : 1'b0;
	   gnt_1 = req_0 ? 1'b0 : 
		    req_1 ? 1'b1 : 1'b0;
	   gnt_2 = (req_0 | req_1) ? 1'b0 : 
		    req_2 ? 1'b1 : 1'b0;
	end
	else
	  begin
	     gnt_0 = req_0 ? 1'b1 : 1'b0;
	     gnt_1 = req_0 ? 1'b0 : 
		     req_1 ? 1'b1 : 1'b0;
	     gnt_2 = (req_0 | req_1) ? 1'b0 : 
		     req_2 ? 1'b1 : 1'b0;
	  end // else: !if(last_gnt2 & ~hold_2)
     end // always@ (*)
endmodule // arb3to1_hold
