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


/* UART Receiver:
 * David Sheffield (dsheffie@stanford.edu)
 * Set for 100 Mhz system clock (clk)
 * Output baud 115200 
 * Recompute baud with baud.c if system clock changes
 * 8x sampling state-machine based on FPGA4Fun implementation
 */
module uart_rx(
    input clk,
    input reset,
    input serial_in,
    input read_strobe,
    output reg byte_done,
    output reg [7:0] byte_out
    );

   reg [7:0] 	     byte_storage;
/* This code assumes a 100 Mhz system clock and 115200 baud signal
 * It will oversample the input signal 8x 
 * The accumulator incremement value can be calculated by baud.c
 */
   reg [16:0] 	     RxBaudGeneratorAcc;
   
   always@(posedge clk)
     begin
	if(reset)
	  begin
	     RxBaudGeneratorAcc <= 'd0;
	  end
	else
	  begin
	     RxBaudGeneratorAcc <= {1'b0,RxBaudGeneratorAcc[15:0]} + 17'd604;
	  end
     end

   //16x sampling clock
   wire sclk = RxBaudGeneratorAcc[16];
   
   reg [1:0] rx_synch;
   
   always@(posedge clk)
     begin
	if(reset)
	  begin
	     rx_synch <= 2'b11;
	  end
	else
	  begin
	     rx_synch[0] <= sclk ? serial_in : rx_synch[0];
	     rx_synch[1] <= sclk ? rx_synch[0] : rx_synch[1];
	  end
     end


   reg [2:0] bit_spacing;
   reg [3:0] state, nstate;
   reg [1:0] RxD_cnt;
   reg 	     RxD_bit;
   
   
   always @(posedge clk)
     begin
	if(reset)
	  begin
	     bit_spacing <= 3'd0;
	  end
	else
	  begin
	     bit_spacing <= (state == 0) ? 3'd0 : sclk ? bit_spacing + 3'd1 : bit_spacing;	
	  end
     end
   
   wire next_bit = (bit_spacing==3'd7); 
   
   always @(sclk or state or RxD_bit or next_bit)
     begin
	case(state)
	  4'b0000: nstate = (sclk & !RxD_bit) ? 4'b1000 : 4'b0000;
	  4'b1000: nstate = (sclk & next_bit) ? 4'b1001 : 4'b1000; // bit 0
	  4'b1001: nstate = (sclk & next_bit) ? 4'b1010 : 4'b1001; // bit 1
	  4'b1010: nstate = (sclk & next_bit) ? 4'b1011 : 4'b1010; // bit 2
	  4'b1011: nstate = (sclk & next_bit) ? 4'b1100 : 4'b1011; // bit 3
	  4'b1100: nstate = (sclk & next_bit) ? 4'b1101 : 4'b1100; // bit 4
	  4'b1101: nstate = (sclk & next_bit) ? 4'b1110 : 4'b1101; // bit 5
	  4'b1110: nstate = (sclk & next_bit) ? 4'b1111 : 4'b1110; // bit 6
	  4'b1111: nstate = (sclk & next_bit) ? 4'b0001 : 4'b1111; // bit 7
	  4'b0001: nstate = (sclk & next_bit) ? 4'b0000 : 4'b0001; // stop bit
	  default: nstate = 4'b0000;
	endcase 
     end
   
   always@(posedge clk)
     begin
	if(reset)
	  begin
	     state <= 4'd0;
	  end
	else
	  begin
	     state <= nstate;
	  end
     end
   
   always @(posedge clk)
     begin
	if(reset)
	  begin
	     RxD_cnt <= 2'b11;
	     RxD_bit <= 1'b1;
	  end
	else
	  begin
	     if(sclk)
	       begin
		  if(rx_synch[1] && RxD_cnt!=2'b11) 
		    RxD_cnt <= RxD_cnt + 1;
		  else 
		    if(~rx_synch[1] && RxD_cnt!=2'b00) 
		      RxD_cnt <= RxD_cnt - 1;
		  
		  if(RxD_cnt==2'b00) 
		    RxD_bit <= 0;
		  else
		    if(RxD_cnt==2'b11) 
		      RxD_bit <= 1;
	       end 
	  end
     end
 
   wire shift_bit = sclk & next_bit & state[3];
   
   
   always @(posedge clk) 
     begin
	if(reset) 
	  begin
	     byte_storage <= 8'd0;
	  end
	else
	  begin
	     if(shift_bit)
	       begin
		  byte_storage <= {RxD_bit, byte_storage[7:1]};
	       end
	     
	     else if(state == 4'b0000)
	       begin
		  byte_storage <= 8'd0;
	       end
	     else
	       begin
		  byte_storage <= byte_storage;
	       end
	  end // else: !if(reset)
     end // always @ (posedge clk)
   

   wire done_rx = (nstate == 4'b0000) & (state == 4'b0001);
   
   always@(posedge clk)
     begin
	if(reset)
	  begin
	     byte_done <= 1'b0;
	  end
	else
	  begin
	     if(done_rx)
	       begin
		  byte_done <= 1'b1;
	       end
	     else if(read_strobe)
	       begin
		  byte_done <= 1'b0;
	       end
	     else
	       begin
		  byte_done <= byte_done;
	       end
	  end // else: !if(reset)
     end // always@ (posedge clk)
   

   always@(posedge clk)
     begin
	if(reset)
	  begin
	     byte_out <= 8'd0;
	  end
	else
	  begin
	     if(done_rx)
	       begin
		  byte_out <= byte_storage;
	       end
	     else
	       begin
		  byte_out <= byte_out;
	       end
	  end // else: !if(reset)
     end // always@ (posedge clk)
   
   
endmodule // uart_rx

