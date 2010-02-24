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


module ucontroller_uart(/*AUTOARG*/
   // Outputs
   serial_out, tb_addr, tb_word_out, tb_write, tb_read,
   // Inputs
   clk, serial_in, reset, tb_word_in, tb_ack
   );

   output 	serial_out;
   output [15:0] tb_addr;
   output [31:0] tb_word_out;
   output 	 tb_write;
   output 	 tb_read;
   input 	 clk;
   input 	 serial_in;
   input 	 reset;
   input [31:0]  tb_word_in;
   input 	 tb_ack;
   
   ucblock u0 (
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


endmodule // ucontroller_uart
