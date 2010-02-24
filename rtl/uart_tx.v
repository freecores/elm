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


/* UART Transmitter:
 * David Sheffield (dsheffie@stanford.edu)
 * Set for 100 Mhz system clock (pclk)
 * Output baud 115200 
 * Recompute baud with baud.c if system clock changes
 */

module uart_tx(
   // Outputs
   serial_out, done, ureset,
   // Inputs
   pclk, preset, data_in, req
   );
   input pclk;
   input preset;
     
   input [7:0] data_in;
   input       req;
   output ureset;   

   output  reg   serial_out;
   output reg	 done;

   reg [7:0]   tx_word;
   reg [7:0]   data_buf;
   
   
   reg [3:0]   state, nstate;

   reg 	       obit;

   reg [1:0]   in_synch;
   reg [2:0]   out_synch;

   reg pstate;
   
   reg odone;
   reg rodone;
   reg [2:0] odone_synch;
   
	reg [16:0] BaudGeneratorAcc;
   reg uclk;
   reg [4:0] uart_reset;
	
	/* See FPGA4Fun for accumulator calculations */
   always@(posedge pclk)
   begin
      if(preset)
	begin
	   uart_reset <= 5'd0;
	   uclk <= 1'b0;
	   BaudGeneratorAcc <= 17'd0;
	end
      else
	begin
	   uclk <= BaudGeneratorAcc[16] ? !uclk : uclk;
	   BaudGeneratorAcc <= {1'b0,BaudGeneratorAcc[15:0]} + 17'd151;
	   uart_reset <= (uart_reset == 5'd31) ? uart_reset : uclk ? (uart_reset + 5'd1) : uart_reset;
	end
   end
   assign ureset = (uart_reset != 5'd31);
   
   always@(posedge pclk)
     begin
	if(ureset)
	  begin
	     pstate <= 1'b0;
	     data_buf <= 8'd0;
	     out_synch <= 3'd0;
	     done <= 1'b0;
	     odone_synch <= 3'd0;
	  end
	else
	  begin
	     odone_synch[0] <= rodone;
	     odone_synch[1] <= odone_synch[0];
	     odone_synch[2] <= odone_synch[1];
	     
	     pstate <= req & (!pstate) ? 1'b1 : (odone_synch[2] ^ odone_synch[1]) ? 1'b0 : pstate;
	               
	     out_synch[0] <= (state == 4'd0);
	     out_synch[1] <= out_synch[0];
	     out_synch[2] <= out_synch[1];
	     done <= out_synch[2];
	     data_buf <= req ? data_in : data_buf;
	  end
     end // always@ (posedge pclk)
   
   
   wire ureq = in_synch[1];
      
   always@(posedge uclk)
     begin
	if(ureset)
	  begin
	     rodone <= 1'b0;
	     in_synch <= 2'd0;
	     tx_word <= 8'd0;
	  end
	else
	  begin
	     rodone <= odone;
	     in_synch[0] <= pstate;
	     in_synch[1] <= in_synch[0];
	     tx_word <= ureq & (state == 4'd0) ? data_buf : tx_word;
	  end
     end // always@ (posedge clk)


   always@(posedge uclk)
     begin
	if(ureset)
	  begin
	     serial_out <= 1'b1;
	     state <= 4'd0;
	  end
	else
	  begin
	     serial_out <= obit;
	     state <= nstate;
	  end
     end // always@ (posedge uclk)
      
   
   always@(/*AUTOSENSE*/state or tx_word or ureq)
     begin
	obit = 1'b1;
	odone = 1'b0;
	case(state)
	  4'd0:
	    begin
	       if(ureq)
		 begin
		    nstate = 4'd1;
		 end
	       else
		 begin
		    nstate = 4'd0;
		 end
	    end // case: 4'd0
	  //start bit
	  4'd1:
	    begin
	       obit = 1'b0;
	       nstate = 4'd2;
	    end
	  4'd2:
	    begin
	       obit = tx_word[0];
	       nstate = 4'd3;
	    end
	  4'd3:
	    begin
	       obit = tx_word[1];
	       nstate = 4'd4;
	    end
	  4'd4:
	    begin
	       obit = tx_word[2];
	       nstate = 4'd5;
	    end
	  4'd5:
	    begin
	       obit = tx_word[3];
	       nstate = 4'd6;
	    end
	  4'd6:
	    begin
	       obit = tx_word[4];
	       nstate = 4'd7;

	    end
	  4'd7:
	    begin
	       obit = tx_word[5];
	       nstate = 4'd8;
	    end
	  4'd8:
	    begin
	       obit = tx_word[6];
	       nstate = 4'd9;
	    end
	  4'd9:
	    begin
	       obit = tx_word[7];
	       nstate = 4'd10;
	    end
	  4'd10:
	    begin
	       obit = 1'b1;
	       odone = 1'b1;
	       nstate = 4'd11;
	    end
	  4'd11:
	    begin
	      if(ureq)
	      begin
	        nstate = 4'd11;
	      end
	      else
	        begin
	          nstate = 4'd0;
	         end
	    end
	      
	  default:
	    begin
	       nstate = 4'd0;
	    end
	endcase // case (state)
     end // always@ (...
   
   
   

endmodule // uart_tx
