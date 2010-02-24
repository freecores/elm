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


`timescale 1ns / 1ps

module ucblock(/*AUTOARG*/
   // Outputs
   serial_out, tb_addr, tb_word_out, tb_write, tb_read,
   // Inputs
   clk, serial_in, reset, tb_word_in, tb_ack
   );
   
  input clk;
  output serial_out;
  input serial_in;
  input reset;

  output [15:0] tb_addr;
  output [31:0] tb_word_out;
  input [31:0] tb_word_in;
  output tb_write;
  output tb_read;
  input tb_ack;


wire ureset;

wire tb_bus_error;

wire [9:0] address;
wire [17:0] instruction;

wire interrupt_ack;

wire done;


wire [7:0] data_out;
wire write_strobe;



wire [7:0] port_id;
wire read_strobe;

wire biu_done;

reg [1:0] tx_state, tx_nstate;
wire rdone;
wire gdone = (tx_nstate == 2'd0);
wire [7:0] tx_status = {7'd0, gdone};
wire [7:0] rx_status = {7'd0, rdone};
wire [7:0] biu_error_status = {6'd0, tb_bus_error, biu_done};
wire [7:0] rx_byte_out;

reg [7:0] proc_data_in;

wire [7:0] biu_byte_out;

always@(*)
begin
case(port_id)
8'd0:
 proc_data_in = tx_status;
8'd1:
 proc_data_in = rx_status;
8'd2:
 proc_data_in = rx_byte_out;
 8'd18:
 proc_data_in = biu_byte_out;
 8'd19:
 proc_data_in = biu_byte_out;
 8'd20:
 proc_data_in = biu_byte_out;
 8'd21:
 proc_data_in = biu_byte_out;
 8'd24:
  proc_data_in = biu_error_status;
 
 8'd32:
 proc_data_in = biu_byte_out;
 8'd33:
 proc_data_in = biu_byte_out;
 8'd34:
 proc_data_in = biu_byte_out;
 8'd35:
 proc_data_in = biu_byte_out;
 8'd36:
 proc_data_in = biu_byte_out;
 8'd37:
 proc_data_in = biu_byte_out;
 8'd38:
 proc_data_in = biu_byte_out;
 8'd39:
 proc_data_in = biu_byte_out;
 
default:
 proc_data_in = 8'd0;
endcase 
end


//req done fsm
always@(posedge clk)
begin
	tx_state <= reset ? 2'd0 : tx_nstate;
end

wire tx_req = (write_strobe) & (port_id == 8'd0);	 
always@(tx_state, done, tx_req)
begin
tx_nstate = 2'd0;
case(tx_state)
4'd0:
  begin
    tx_nstate =  tx_req ? 2'd1 : 2'd0;
  end
4'd1:
  begin
    tx_nstate = done ? 4'd1 : 4'd2;
  end
4'd2:
  begin
    tx_nstate = done ? 4'd0 : 4'd2;
  end
default:
  tx_nstate = 2'd0;
endcase
end


wire irq = rdone | biu_done;


wire irq_ack_rx = (write_strobe) & (port_id == 8'd3);

pacoblaze3 uc (
    .address(address), 
    .instruction(instruction), 
    .port_id(port_id), 
    .write_strobe(write_strobe), 
    .out_port(data_out), 
    .read_strobe(read_strobe), 
    .in_port(proc_data_in), 
    .interrupt(irq), 
    .interrupt_ack(interrupt_ack), 
    .reset(ureset), 
    .clk(clk)
    );

irom rom (
    .address(address), 
    .instruction(instruction), 
    .clk(clk),
    .reset(ureset)
    );
	 
	 

uart_tx tx (
    .serial_out(serial_out), 
    .done(done), 
    .pclk(clk), 
    .preset(reset),
    .ureset(ureset),	 
    .data_in(data_out), 
    .req(tx_req)
    ); 
	



wire rs_tx = (port_id == 8'd1);
	
uart_rx rx (
    .clk(clk), 
    .reset(ureset), 
    .serial_in(serial_in),	 
    //.read_strobe(rx_rs), 
	 .read_strobe(irq_ack_rx),
    .byte_done(rdone), 
    .byte_out(rx_byte_out)
    );
	


biu test_biu (
    .uc_byte_out(biu_byte_out), 
    .uc_done(biu_done), 
    .tb_addr(tb_addr), 
    .tb_word_out(tb_word_out), 
    .tb_write(tb_write), 
    .tb_read(tb_read), 
	 .bus_error(tb_bus_error),
    .clk(clk), 
    .reset(reset), 
    .uc_addr(port_id), 
    .uc_byte_in(data_out), 
    .uc_write_strobe(write_strobe), 
    .tb_word_in(tb_word_in), 
    .tb_ack(tb_ack)
    );	
	 
	 
	 
	 
endmodule
