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


module fpga_tmem(/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, wen, csn, addr, din, mask
   );
   input clk;
   input wen;
   input csn;
   input [11:0] addr;
   input [63:0] din;
   input [63:0] mask;
   
   output [63:0] dout;


   reg [31:0] 	 mem_l [0:4095];
   reg [31:0] 	 mem_h [0:4095];

   reg [31:0] 	 r_dout_l;
   reg [31:0] 	 r_dout_h;
      
   assign dout = {r_dout_h, r_dout_l};

   wire 	 write_all = (mask == 64'd0);

   wire 	 write_lo = (mask == 64'hffffffff00000000);
   wire 	 write_hi = (mask == 64'h00000000ffffffff);
      
   wire 	 we_l = ~csn & ~wen & (write_all | write_lo);
   wire 	 we_h = ~csn & ~wen & (write_all | write_hi);
      
   always@(posedge clk)
     begin
	r_dout_l <= mem_l[addr];
	
	if(we_l)
	  begin
	     mem_l[addr] <= din[31:0];
	  end
     end


   always@(posedge clk)
     begin
	r_dout_h <= mem_h[addr];
	
	if(we_h)
	  begin
	     mem_h[addr] <= din[63:32];
	  end

     end

endmodule // fpga_tmem
