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


module twophase_sync #(parameter DATAWIDTH = 32)
   (/*AUTOARG*/
   // Outputs
   ackA, dataB, validB,
   // Inputs
   clkA, rstA, dataA, reqA, clkB, rstB
   );
    
   input clkA;
   input rstA;
   input [(DATAWIDTH-1):0] dataA;
   input 		   reqA;
   output 		   ackA;

   input 		   clkB;
   input 		   rstB;
   output [(DATAWIDTH-1):0] dataB;
   output       validB;


   reg [(DATAWIDTH-1):0] r_data;

   reg 			 r_Req;
   reg [1:0] 		 r_ReqSync;
   reg 			 r_ReqB;
   reg 			 r_Ack;
   reg [1:0] 		 r_AckSync;
   reg 			 r_AckA;
   reg r_valid;
   
   wire reqB;
   
   assign reqB = r_ReqB ^ r_ReqSync[1];
   assign dataB = r_data;
   assign ackA = r_AckA ^ r_AckSync[1];
   assign validB = r_valid;
         
   always@(posedge clkA or posedge rstA)
     begin
	if(rstA)
	  begin
	     r_Req <= 1'b0;
	  end
	else
	  begin
	     r_Req <= r_Req ^ reqA;
	  end
     end // always@ (posedge clkA)
   
   
   always@(posedge clkB or posedge rstB)
     begin
	if(rstB)
	  begin
	     r_ReqSync <= 2'b00;
	  end
	else
	  begin
	     r_ReqSync[0] <= r_Req;
	     r_ReqSync[1] <= r_ReqSync[0];
	  end
     end // always@ (posedge clkB)
   

   always@(posedge clkB or posedge rstB)
     begin
	if(rstB)
	  begin
	     r_ReqB <= 1'b0;
	  end
	else
	  begin
	     r_ReqB <= r_ReqSync[1];
	  end
     end // always@ (posedge clkB)
   

   always@(posedge clkB or posedge rstB)
     begin
	if(rstB)
	  begin
	     r_data <= 'd0;
	  end
	else
	  begin
	     r_data <= (reqB) ? dataA : r_data;
	  end
     end // always@ (posedge clkB)

   always@(posedge clkB or posedge rstB)
     begin
	if(rstB)
	  begin
	     r_Ack <= 1'b0;
	  end
	else
	  begin
	     r_Ack <= r_Ack ^ reqB;
	  end
     end // always@ (posedge clkB)

   always@(posedge clkA or posedge rstA)
     begin
	if(rstA)
	  begin
	     r_AckSync <= 2'b00;
	  end
	else
	  begin
	     r_AckSync[0] <= r_Ack;
	     r_AckSync[1] <= r_AckSync[0];
	  end
     end

   always@(posedge clkA or posedge rstA)
     begin
	if(rstA)
	  begin
	     r_AckA <= 1'b0;
	  end
	else
	  begin
	     r_AckA <= r_AckSync[1];
	  end
     end // always@ (posedge clkA)
   
   always@(posedge clkB or posedge rstB)
   begin
     if(rstB)
       begin
         r_valid <= 1'b0;
       end
     else
       begin
         r_valid <= reqB;
       end    
   end
   
endmodule // twophase_sync
