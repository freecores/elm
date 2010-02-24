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



module elm_project_top(/*AUTOARG*/
   // Outputs
   serial_out,
   // Inputs
   clk, core_clk, reset, serial_in
   );
   
   input clk;
   input core_clk;
   input reset;
   input serial_in;
   output serial_out;
     
	
   wire 	 tb_ack;
     
   wire 	 tb_read;
   wire 	 tb_write;
   wire [31:0] 	 tb_word_out;
   wire [15:0] 	 tb_addr;
   
   wire 	 tb0_ack;
   wire [31:0] 	 tb0_data_out;
      
   assign tb_ack = tb0_ack;
      
   wire [31:0] 	 tb_word_in =  tb0_ack ? tb0_data_out : 32'd0;	
   
   ucontroller_uart 
     microcontroller (
		      .serial_out(serial_out), 
		      .tb_addr(tb_addr), 
		      .tb_word_out(tb_word_out), 
		      .tb_write(tb_write), 
		      .tb_read(tb_read), 
		      .clk(clk), 
		      .serial_in(serial_in), 
		      .reset(reset), 
		      .tb_word_in(tb_word_in), 
		      .tb_ack(tb_ack)
		      );	

  pb_elm_synchronizer
    elm_block (
	   // Outputs
	   .pb_data_out			(tb0_data_out),
	   .pb_ack			(tb0_ack),
	   // Inputs
	   .core_clk			(core_clk),
	   .pb_clk			(clk),
	   .pb_reset			(reset),
	   .external_reset              (rst_out),
	   .pb_read			(tb_read),
	   .pb_write			(tb_write),
	   .pb_addr			(tb_addr[15:0]),
	   .pb_data_in			(tb_word_out)
	   );
     	 
endmodule // elm_project_top

