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


module ensemble_addr_decoder(/*AUTOARG*/
   // Outputs
   ocm_addr, ens_b0_csn, ens_b1_csn, ens_b2_csn, ens_b3_csn, ocm_csn,
   ens_b4_csn, ens_b5_csn, ens_b6_csn, ens_b7_csn, mask, ens_data_in,
   // Inputs
   pb_addr, pb_data_in, pb_rd, pb_wr
   );
   input [15:0] pb_addr;
   input [31:0] pb_data_in;

   input 	pb_rd;
   input 	pb_wr;
      
   output [11:0] ocm_addr;
  
   output 	ens_b0_csn;
   output 	ens_b1_csn;
   output 	ens_b2_csn;
   output 	ens_b3_csn;
   output       ocm_csn;

   output 	ens_b4_csn;
   output 	ens_b5_csn;
   output 	ens_b6_csn;
   output 	ens_b7_csn;
   
   
      
   output [63:0] mask;
   output [63:0] ens_data_in;

   wire 	 b0_cs = (pb_addr < 16'd512);
  
   wire 	 b1_cs = (pb_addr < 16'd1024) & 
		 (pb_addr > 16'd511);

   wire 	 b2_cs = (pb_addr < 16'd1536) & 
		 (pb_addr > 16'd1023);

   wire 	 b3_cs = (pb_addr < 16'd2048) & 
		 (pb_addr > 16'd1535);

   wire 	 ocm_cs = (pb_addr < 16'd10240) & 
		 (pb_addr > 16'd2047);

   wire 	 b4_cs = (pb_addr < 16'd10752) & 
		 (pb_addr > 16'd10239);

   wire 	 b5_cs = (pb_addr < 16'd11264) & 
		 (pb_addr > 16'd10751);

   wire 	 b6_cs = (pb_addr < 16'd11776) & 
		 (pb_addr > 16'd11263);

   wire 	 b7_cs = (pb_addr < 16'd12288) & 
		 (pb_addr > 16'd11775);

   wire 	 mem_active = (pb_wr | pb_rd);
      
   assign ens_b0_csn = ~(b0_cs & mem_active);
   assign ens_b1_csn = ~(b1_cs & mem_active);
   assign ens_b2_csn = ~(b2_cs & mem_active);
   assign ens_b3_csn = ~(b3_cs & mem_active);

   assign ens_b4_csn = ~(b4_cs & mem_active);
   assign ens_b5_csn = ~(b5_cs & mem_active);
   assign ens_b6_csn = ~(b6_cs & mem_active);
   assign ens_b7_csn = ~(b7_cs & mem_active);

   
   assign ocm_csn = ~(ocm_cs & mem_active);

   //rch THIS IS HARDWIRED
   assign ocm_addr = ocm_cs ? pb_addr[13:1]-12'h400 : pb_addr[12:1];

   assign mask = pb_addr[0] ? 
		 64'h00000000ffffffff :
		 64'hffffffff00000000;

   assign ens_data_in = pb_addr[0] ?
			{pb_data_in, 32'd0} :
			{32'd0, pb_data_in};

endmodule // ensemble_addr_decoder

   

   