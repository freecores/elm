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


module fifo(
   // Outputs
   dout, full, empty, /*water_level,*/
   // Inputs
   clk, rst, r, w, din
   );

   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 3;
   
   input     clk;
   input     rst;
   
   input     r;
   input     w;

   wire [(DATA_WIDTH-1):0] dout2;
   output [(DATA_WIDTH-1):0] dout;
   input [(DATA_WIDTH-1):0]  din;

   output 		     full;
   output 		     empty;
   
  // output [ADDR_WIDTH:0]     water_level;
   
   reg [ADDR_WIDTH:0] 	     w_ptr, r_ptr;
   wire 		     r_mem, w_mem;

   assign dout = empty ? {(DATA_WIDTH){1'b0}} : dout2;
   assign full = (w_ptr[(ADDR_WIDTH-1):0] == r_ptr[(ADDR_WIDTH-1):0]) 
   && (w_ptr[ADDR_WIDTH] != r_ptr[ADDR_WIDTH]);
   
   assign 		     empty = (w_ptr == r_ptr);

   assign r_mem = (r && !empty) || (r && w);
   assign w_mem = (w && !full) || (r && w);
  
   //assign water_level = (w_ptr - r_ptr);
    
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     w_ptr <= {(ADDR_WIDTH+1){1'b0}};
	     r_ptr <= {(ADDR_WIDTH+1){1'b0}};
	  end
	else
	  begin
	     w_ptr <= (w && !full) ? w_ptr + 1 : w_ptr;
	     r_ptr <= (r && !empty) ? r_ptr + 1 : r_ptr;
	  end
     end
   
   
   
   mem #(DATA_WIDTH,ADDR_WIDTH ) m0
   (
	   // Outputs
	   .r_data			(dout2),
	   // Inputs
	   .clk				(clk),
	   .r_addr			(r_ptr[(ADDR_WIDTH-1):0]),
	   .w_addr			(w_ptr[(ADDR_WIDTH-1):0]),
	   .w_data			(din),
//	   .r				(r_mem),
	   .w				(w_mem),
    .rst (rst)
    );
   

endmodule // fifo 

module mem(
   // Outputs
   r_data,
   // Inputs
   clk, r_addr, w_addr, w_data,/* r,*/ w, rst
   );

   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 3;
   parameter RAM_DEPTH = 1 << ADDR_WIDTH;

   input rst;
   input clk;
   input [(ADDR_WIDTH-1):0] r_addr;
   input [(ADDR_WIDTH-1):0] w_addr;

   input [(DATA_WIDTH-1):0] w_data;
   output[(DATA_WIDTH-1):0] r_data;

   //reg [(DATA_WIDTH-1):0] r_data;
   
   
   //input 		    r;
   input w;

   reg [(DATA_WIDTH-1):0] mem [(RAM_DEPTH-1):0];
   integer 		  ii;
   
   assign 		  r_data = mem[r_addr];
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  for(ii = 0; ii<RAM_DEPTH; ii=ii+1)
	    mem[ii] <= {(DATA_WIDTH){1'b0}};
	else
	  mem[w_addr] <= w ? w_data : mem[w_addr];
	//r_data <= r ? mem[r_addr] : r_data;
     end

endmodule // mem
		  
