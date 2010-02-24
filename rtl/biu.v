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


/* BIU interfaces the PacoBlaze microcontroller to the test bus interface */

module biu(/*AUTOARG*/
	   // Outputs
	   uc_byte_out, uc_done, tb_addr, tb_word_out, tb_write, tb_read,
	   bus_error,
	   // Inputs
	   clk, reset, uc_addr, uc_byte_in, uc_write_strobe, tb_word_in,
	   tb_ack
	   );
   input clk;
   input reset;
   input [7:0] uc_addr;
   input [7:0] uc_byte_in;
   output reg [7:0] uc_byte_out;
   input 	    uc_write_strobe;
   output reg 	    uc_done;
   
   
   output [15:0]    tb_addr;
   output reg [31:0] tb_word_out;
   input [31:0]      tb_word_in;
   output reg 	     tb_write;
   output reg 	     tb_read;
   input 	     tb_ack;

   output reg 	     bus_error;
   
   
   reg [7:0] 	     addr_low_byte;
   reg [7:0] 	     addr_high_byte;

   reg [7:0] 	     data_byte_0;
   reg [7:0] 	     data_byte_1;
   reg [7:0] 	     data_byte_2;
   reg [7:0] 	     data_byte_3;
   
   //convert data bytes into ascii
   reg [7:0] 	     ascii_0;
   reg [7:0] 	     ascii_1;
   reg [7:0] 	     ascii_2;
   reg [7:0] 	     ascii_3;
   reg [7:0] 	     ascii_4;
   reg [7:0] 	     ascii_5;
   reg [7:0] 	     ascii_6;
   reg [7:0] 	     ascii_7;

   wire 	     uc_wr_addr_low = (uc_write_strobe) & (uc_addr == 8'd16);
   wire 	     uc_wr_addr_high = (uc_write_strobe) & (uc_addr == 8'd17);  
   wire 	     uc_wr_data_0 = (uc_write_strobe) & (uc_addr == 8'd18);
   wire 	     uc_wr_data_1 = (uc_write_strobe) & (uc_addr == 8'd19);
   wire 	     uc_wr_data_2 = (uc_write_strobe) & (uc_addr == 8'd20);
   wire 	     uc_wr_data_3 = (uc_write_strobe) & (uc_addr == 8'd21);


   wire 	     uc_l_write_0 = (uc_write_strobe) & (uc_addr == 8'd32);
   wire 	     uc_h_write_0 = (uc_write_strobe) & (uc_addr == 8'd33);
   wire 	     uc_l_write_1 = (uc_write_strobe) & (uc_addr == 8'd34);
   wire 	     uc_h_write_1 = (uc_write_strobe) & (uc_addr == 8'd35);
   wire 	     uc_l_write_2 = (uc_write_strobe) & (uc_addr == 8'd36);
   wire 	     uc_h_write_2 = (uc_write_strobe) & (uc_addr == 8'd37);
   wire 	     uc_l_write_3 = (uc_write_strobe) & (uc_addr == 8'd38);
   wire 	     uc_h_write_3 = (uc_write_strobe) & (uc_addr == 8'd39);

   reg [20:0] 	     time_out_cnt;	
   wire 	     bus_time_out = time_out_cnt[20];

   wire 	     uc_cmd = (uc_write_strobe) & (uc_addr == 8'd22);

   wire 	     start_read = uc_cmd & (uc_byte_in == 8'd1);
   wire 	     start_write = uc_cmd & (uc_byte_in == 8'd2);
   wire 	     uc_ack = uc_cmd & (uc_byte_in == 8'd4);
   

   reg 		     com_tb_read;
   reg 		     com_tb_write;
   
   reg 		     com_latch_out;
   
   
   reg [2:0] 	     state, nstate;
   
   assign tb_addr = {addr_high_byte, addr_low_byte};

   wire 	     tb_latch_in = (state == 3'd3) & tb_ack;
   wire 	     tb_latch_err = (state == 3'd3) & bus_time_out;
   
   wire [7:0] 	     ascii_out_0;
   wire [7:0] 	     ascii_out_1;
   wire [7:0] 	     ascii_out_2;
   wire [7:0] 	     ascii_out_3;
   wire [7:0] 	     ascii_out_4;
   wire [7:0] 	     ascii_out_5;
   wire [7:0] 	     ascii_out_6;
   wire [7:0] 	     ascii_out_7;
   
   wire [3:0] 	     hex_out;
   
   
   /*	wire [7:0] flip_byte;
    
    assign flip_byte[0] = uc_byte_in[7];
    assign flip_byte[1] = uc_byte_in[6];
    assign flip_byte[2] = uc_byte_in[5];
    assign flip_byte[3] = uc_byte_in[4];
    assign flip_byte[4] = uc_byte_in[3];
    assign flip_byte[5] = uc_byte_in[2];
    assign flip_byte[6] = uc_byte_in[1];
    assign flip_byte[7] = uc_byte_in[0];
    */
   
   
   
   from_ascii f0 (
		  .out_bin(hex_out), 
		  .in_ascii(uc_byte_in)
		  );

   ascii_lut a0 (
		 .in(tb_word_in[3:0]), 
		 .out(ascii_out_0)
		 );
   
   ascii_lut a1 (
		 .in(tb_word_in[7:4]), 
		 .out(ascii_out_1)
		 );
   
   ascii_lut a2 (
		 .in(tb_word_in[11:8]), 
		 .out(ascii_out_2)
		 );
   
   ascii_lut a3 (
		 .in(tb_word_in[15:12]), 
		 .out(ascii_out_3)
		 );
   
   ascii_lut a4 (
		 .in(tb_word_in[19:16]), 
		 .out(ascii_out_4)
		 );
   
   ascii_lut a5 (
		 .in(tb_word_in[23:20]), 
		 .out(ascii_out_5)
		 );
   
   ascii_lut a6 (
		 .in(tb_word_in[27:24]), 
		 .out(ascii_out_6)
		 );
   
   ascii_lut a7 (
		 .in(tb_word_in[31:28]), 
		 .out(ascii_out_7)
		 );	
   
   always@(posedge clk)
     begin
	if(reset)
	  begin
	     addr_low_byte <= 8'd0;
	     addr_high_byte <= 8'd0;
	     data_byte_0 <= 8'd0;
	     data_byte_1 <= 8'd0;
	     data_byte_2 <= 8'd0;
	     data_byte_3 <= 8'd0;
	     ascii_0 <= 8'd48;
	     ascii_1 <= 8'd48;
	     ascii_2 <= 8'd48;
	     ascii_3 <= 8'd48;
	     ascii_4 <= 8'd48;
	     ascii_5 <= 8'd48;
	     ascii_6 <= 8'd48;
	     ascii_7 <= 8'd48;
	  end
	else
	  begin
	     addr_low_byte <= uc_wr_addr_low ? uc_byte_in :addr_low_byte;
	     addr_high_byte <= uc_wr_addr_high ? uc_byte_in : addr_high_byte;
	     
	     data_byte_0 <= uc_wr_data_0 ? uc_byte_in : 
			    tb_latch_in ? tb_word_in[7:0] : 
			    uc_l_write_0 ? {data_byte_0[7:3], hex_out} : 
			    uc_h_write_0 ? {hex_out, data_byte_0[3:0]} :  
			    data_byte_0;
	     
	     data_byte_1 <= uc_wr_data_1 ? uc_byte_in : 
			    tb_latch_in ? tb_word_in[15:8] : 
			    uc_l_write_1 ? {data_byte_1[7:3], hex_out} : 
			    uc_h_write_1 ? {hex_out, data_byte_1[3:0]} : 
			    data_byte_1;
	     
	     data_byte_2 <= uc_wr_data_2 ? uc_byte_in : 
			    tb_latch_in ? tb_word_in[23:16] : 
			    uc_l_write_2 ? {data_byte_2[7:3], hex_out} : 
			    uc_h_write_2 ? {hex_out, data_byte_2[3:0]} : 
			    data_byte_2;
	     
	     data_byte_3 <= uc_wr_data_3 ? uc_byte_in : 
			    tb_latch_in ? tb_word_in[31:24] : 
			    uc_l_write_3 ? {data_byte_3[7:3], hex_out} : 
			    uc_h_write_3 ? {hex_out, data_byte_3[3:0]} : 
			    data_byte_3;

	     ascii_0 <= tb_latch_in ? ascii_out_0 : ascii_0;
	     ascii_1 <= tb_latch_in ? ascii_out_1 : ascii_1;
	     ascii_2 <= tb_latch_in ? ascii_out_2 : ascii_2;
	     ascii_3 <= tb_latch_in ? ascii_out_3 : ascii_3;

	     ascii_4 <= tb_latch_in ? ascii_out_4 : ascii_4;
	     ascii_5 <= tb_latch_in ? ascii_out_5 : ascii_5;
	     ascii_6 <= tb_latch_in ? ascii_out_6 : ascii_6;
	     ascii_7 <= tb_latch_in ? ascii_out_7 : ascii_7;		  
	  end
     end


   always@(posedge clk)
     begin
	uc_byte_out <= reset ? 8'd0 : 
		       (uc_addr == 8'd18) ? data_byte_0 :
		       (uc_addr == 8'd19) ? data_byte_1 :
		       (uc_addr == 8'd20) ? data_byte_2 :
		       (uc_addr == 8'd21) ? data_byte_3 :
		       (uc_addr == 8'd32) ? ascii_0 :
		       (uc_addr == 8'd33) ? ascii_1 :
		       (uc_addr == 8'd34) ? ascii_2 :
		       (uc_addr == 8'd35) ? ascii_3 :
		       (uc_addr == 8'd36) ? ascii_4 :
		       (uc_addr == 8'd37) ? ascii_5 :
		       (uc_addr == 8'd38) ? ascii_6 :
		       (uc_addr == 8'd39) ? ascii_7 :
	   
		       8'd0;
     end // always@ (posedge clk)


   reg [7:0] bus_cnt;

   wire      bus_cnt_en = (state == 3'd5) | (state == 3'd6);
   
   always@(posedge clk)
     begin
	if(reset)
	  begin
	     bus_cnt <= 8'd0;
	  end
	else
	  begin
	     bus_cnt <= bus_cnt_en ? (bus_cnt + 8'd1) : 8'd0;
	  end
     end
   
   wire cnt_done = (bus_cnt == 8'd255);
      
   always@(*)
     begin
	com_tb_write = 1'b0;
	com_tb_read = 1'b0;
	com_latch_out = 1'b0;
	
	case(state)
	  3'd0:
	    begin
	       /* Starting a write to a module */
	       if(start_write)
		 begin
		    com_latch_out = 1'b1;
		    nstate = 3'd5;
		 end

	       /* Starting a read of a module */
	       else if(start_read)
		 begin
		    nstate = 3'd6;
		 end
	       
	       else
		 begin
		    nstate = 3'd0;
		 end
	    end
	  3'd1:
	    begin
	       com_tb_write = 1'b1;
	       if(tb_ack | bus_time_out)
		 begin
		    nstate = 3'd2;
		 end
	       else
		 begin
		    nstate = 3'd1;
		 end
	    end
	  3'd2:
	    begin
	       nstate = 3'd0;
	    end
	  3'd3:
	    begin
	       com_tb_read = 1'b1;
	       if(tb_ack | bus_time_out)
		 begin
		    nstate = 3'd4;
		 end
	       else
		 begin
		    nstate = 3'd3;
		 end
	    end
	  3'd4:
	    begin
	       nstate = 3'd0;
	    end
	  
	  3'd5:
	    begin
	       if(cnt_done)
		 begin
		    nstate = 3'd1;
		 end
	       else
		 begin
		    nstate = 3'd5;
		 end
	    end

	  3'd6:
	    begin
	       if(cnt_done)
		 begin
		    nstate = 3'd3;
		 end
	       else
		 begin
		    nstate =3'd6;
		 end
	    end
	  
	  
	  default:
	    begin
	       nstate = 3'd0;
	    end
	endcase // case (state)
     end
   
   
   wire [7:0] b0 = {data_byte_0[3:0], data_byte_0[7:4]};
   wire [7:0] b1 = {data_byte_1[3:0], data_byte_1[7:4]};
   wire [7:0] b2 = {data_byte_2[3:0], data_byte_2[7:4]};
   wire [7:0] b3 = {data_byte_3[3:0], data_byte_3[7:4]};

   
   wire [31:0] data_out = {b0,b1,b2,b3};


   wire        count = (state == 3'd1) | (state == 3'd3);
   
   
   always@(posedge clk)
     begin
	time_out_cnt <= reset ? 'd0 : count  ? time_out_cnt + 'd1 :'d0;
	
	tb_word_out <= reset ? 32'd0 : com_latch_out ? data_out : tb_word_out;
	tb_write <= reset ? 1'b0 : com_tb_write;
	tb_read <= reset ? 1'b0 : com_tb_read;
	state <= reset ? 3'd0 : nstate;
     end

   wire write_done = (state == 3'd2);
   wire read_done = (state == 3'd4);
   
   
   always@(posedge clk)
     begin
	if(reset)
	  begin
	     uc_done <= 1'b0;
	     bus_error <= 1'b0;
	  end
	else
	  begin
	     uc_done <= (write_done | read_done) ? 1'b1 : 
			uc_ack ? 1'b0 : uc_done;
	     
	     bus_error <= bus_time_out ? 1'b1 :uc_ack ? 1'b0 : bus_error;
	  end
     end
   

   
endmodule // biu
