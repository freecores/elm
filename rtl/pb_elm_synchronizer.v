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


module pb_elm_synchronizer(/*AUTOARG*/
   // Outputs
   pb_data_out, pb_ack,
   // Inputs
   core_clk, pb_clk, pb_reset, external_reset, pb_read, pb_write,
   pb_addr, pb_data_in
   );
   /* module clock */
   input core_clk;
   
   /* pacoblaze signals */
   input pb_clk;
   input pb_reset;

   input external_reset;
   
   
   input pb_read;
   input pb_write;
   
   input [15:0] pb_addr;
   input [31:0] pb_data_in;
   output [31:0] pb_data_out;

   output 	 pb_ack;
   

   wire 	 pb_req = pb_read | pb_write;

   //prevent glitching
   reg 		 r_pb_req;


   reg 		 rff1;
   reg 		 core_reset;
   
   wire 	 reset_core_logic = pb_reset | external_reset;
   
   always@(posedge core_clk or posedge reset_core_logic)
     begin
	if(reset_core_logic)
	  begin
	     core_reset <= 1'b1;
	     rff1 <= 1'b1;
	  end
	else
	  begin
	     core_reset <= rff1;
	     rff1 <= 1'b0;
	  end
     end // always@ (posedge core_clk or posedge pb_reset)
   
   always@(posedge pb_clk or posedge pb_reset) 
     begin
	if(pb_reset)
	  begin
	     r_pb_req <= 1'b0;
	  end
	else
	  begin
	     r_pb_req <=  pb_req;
	  end
     end // always@ (posedge pb_clk)
      

   wire [49:0] 	 pb_pkd_data_addr = {pb_data_in, pb_addr, pb_read, pb_write};

   /* Address and data synchronized to core clock domain */
   wire [49:0] 	 core_pkd_data_addr;
   /* Request synchronized to core clock domain */
   wire 	 core_req;
      

   twophase_sync #(50) pb_to_core (
			     // Outputs
			     .ackA		(),
			     .dataB		(core_pkd_data_addr),
			     .validB		(core_req),
			     
			     // Inputs
			     .clkA		(pb_clk),
			     .rstA		(pb_reset),
			     .dataA		(pb_pkd_data_addr),
			     .reqA		(r_pb_req),
			     .clkB		(core_clk),
			     .rstB		(core_reset)
			     );
      
   wire [31:0] 	 core_synch_data = core_pkd_data_addr[49:18];
   wire [15:0] 	 core_synch_addr = core_pkd_data_addr[17:2];
   wire 	 core_synch_read = core_pkd_data_addr[1];
   wire 	 core_synch_write = core_pkd_data_addr[0];


   wire 	 addr_range_hit = ((core_synch_addr < 16'h9000));
         
   wire 	 read_hit = (addr_range_hit) & core_synch_read;
   wire 	 write_hit = (addr_range_hit) & core_synch_write; 


   wire [31:0] 	 stupid;

   pb_elm_wrapper elm_wrapper(
			      // Outputs
			      .pb_data_out	(stupid),
			      // Inputs
			      .clk		(core_clk),
			      .rst		(core_reset),
			      .pb_addr		(core_synch_addr),
			      .pb_wr		(write_hit),
			      .pb_rd		(read_hit),
			      .pb_data_in	(core_synch_data)
			      );
   
   
   /*
   pb_burr_bram burr_ram(
			 // Outputs
			 .dout			(stupid),
			 // Inputs
			 .clk			(core_clk),
			 .addr			(core_synch_addr[9:0]),
			 .wr			(write_hit),
			 .din			(core_synch_data)
			 );
    */
   
   reg 		 core_data_valid;
   always@(posedge core_clk or posedge core_reset)
     begin
	if(core_reset)
	  begin
	     core_data_valid <= 1'b0;
	  end
	else
	  begin
	     core_data_valid <= core_req;
	  end
     end // always@ (posedge clk)
      
   
   wire 	 core_data_valid_on_pb_clk;
   wire [31:0] 	 core_data;
   
   
   twophase_sync #(32) core_to_pb (
			      // Outputs
			     .ackA		(),
			     .dataB		(core_data),
			     .validB		(core_data_valid_on_pb_clk),
			     
			     // Inputs
			     .clkA		(core_clk),
			     .rstA		(core_reset),
			     .dataA		(stupid),
			     .reqA		(core_data_valid),
			     .clkB		(pb_clk),
			     .rstB		(pb_reset)
			     );
   

   reg 		 ack;
   reg [31:0] 	 data_out;


    
   always@(posedge pb_clk or posedge pb_reset)
     begin
	if(pb_reset)
	  begin
	     ack <= 1'b0;
	     data_out <= 32'd0;
	  end
	else
	  begin
	     ack <= core_data_valid_on_pb_clk;
	     data_out <= read_hit ? core_data : data_out;
	  end
     end // always@ (posedge pb_clk)
   	    

   assign pb_ack = ack;
   assign pb_data_out = data_out;
   
   
endmodule // pb_elm_synchronizer



   