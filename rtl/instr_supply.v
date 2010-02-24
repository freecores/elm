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


`include "elm_defs.v"

module instr_supply(/*AUTOARG*/
   // Outputs
   instr_word, instr_valid, fetch_active, memory_request,
   memory_request_addr,
   // Inputs
   clk, rst, ce_pc, fetch_req, fetch_base_global_addr,
   fetch_base_ir_addr, fetch_len, data_ready, data_in, xmu_boot_inst
   );
   input clk;
   input rst;

   //normal instruction issue
   
   //program counter input
   input [5:0] ce_pc;
   //instruction
   output [63:0] instr_word;
   //instruction valid
   output 	 instr_valid;


   //fetch engine
   input 	 fetch_req;
   output 	 fetch_active;

   //address of instruction in global memory
   input [31:0]  fetch_base_global_addr;

   //starting ir reload address
   input [5:0] 	 fetch_base_ir_addr;
   //reload count
   input [5:0] 	 fetch_len;

   output 	 memory_request;
   output [31:0] memory_request_addr;
   
      
   input 	 data_ready;
   input [63:0]  data_in;


   input [31:0]  xmu_boot_inst;
   
   //ir valid bits
   reg 	 ir_valid_vector [63:0];

   //state machine registers
   reg [1:0] state, nstate;

   //local address register
   reg [5:0] local_reload_addr;
      
   //global address register
   reg [31:0] global_reload_addr;

   //reload counter
   reg [5:0]  reload_instr_counter;
   

   //current instuction being reloaded
   reg [63:0] load_instruction;

   reg [5:0] last_local_addr;
   reg 	      r_instr_ready;   

   wire       w_fetch_active = (state != 2'd0);
   
   assign fetch_active = w_fetch_active;
   
   
   
   reg 	      t_inv;
   reg 	      instr_ready;
   
   wire [5:0] inv_start = fetch_base_ir_addr;
   wire [5:0] inv_end = fetch_base_ir_addr + fetch_len;

   wire       wrap_top = (inv_end < inv_start);

   wire       inv_r0 = (((inv_start <= 6'd0) & wrap_top) | 
	      ((inv_end >= 6'd0) & wrap_top) | 
	      ((inv_start <= 6'd0) & (inv_end >= 6'd0))) & t_inv;
   
   wire       inv_r1 = (((inv_start <= 6'd1) & wrap_top) | 
	      ((inv_end >= 6'd1) & wrap_top) | 
	      ((inv_start <= 6'd1) & (inv_end >= 6'd1))) & t_inv;
   
   wire       inv_r2 = (((inv_start <= 6'd2) & wrap_top) | 
	      ((inv_end >= 6'd2) & wrap_top) | 
	      ((inv_start <= 6'd2) & (inv_end >= 6'd2))) & t_inv;
   
   wire       inv_r3 = (((inv_start <= 6'd3) & wrap_top) | 
	      ((inv_end >= 6'd3) & wrap_top) | 
	      ((inv_start <= 6'd3) & (inv_end >= 6'd3))) & t_inv;
   
   wire       inv_r4 = (((inv_start <= 6'd4) & wrap_top) | 
	      ((inv_end >= 6'd4) & wrap_top) | 
	      ((inv_start <= 6'd4) & (inv_end >= 6'd4))) & t_inv;
   
   wire       inv_r5 = (((inv_start <= 6'd5) & wrap_top) | 
	      ((inv_end >= 6'd5) & wrap_top) | 
	      ((inv_start <= 6'd5) & (inv_end >= 6'd5))) & t_inv;
   
   wire       inv_r6 = (((inv_start <= 6'd6) & wrap_top) | 
	      ((inv_end >= 6'd6) & wrap_top) | 
	      ((inv_start <= 6'd6) & (inv_end >= 6'd6))) & t_inv;
   
   wire       inv_r7 = (((inv_start <= 6'd7) & wrap_top) | 
			((inv_end >= 6'd7) & wrap_top) | 
			((inv_start <= 6'd7) & (inv_end >= 6'd7))) & t_inv;
   
   wire       inv_r8 = (((inv_start <= 6'd8) & wrap_top) | 
			((inv_end >= 6'd8) & wrap_top) | 
			((inv_start <= 6'd8) & (inv_end >= 6'd8))) & t_inv;
   
   wire       inv_r9 = (((inv_start <= 6'd9) & wrap_top) | 
			((inv_end >= 6'd9) & wrap_top) | 
			((inv_start <= 6'd9) & (inv_end >= 6'd9))) & t_inv;
   
   wire       inv_r10 = (((inv_start <= 6'd10) & wrap_top) | 
			 ((inv_end >= 6'd10) & wrap_top) | 
			 ((inv_start <= 6'd10) & (inv_end >= 6'd10))) & t_inv;
   
   wire       inv_r11 = (((inv_start <= 6'd11) & wrap_top) | 
			 ((inv_end >= 6'd11) & wrap_top) | 
			 ((inv_start <= 6'd11) & (inv_end >= 6'd11))) & t_inv;
   
   wire       inv_r12 = (((inv_start <= 6'd12) & wrap_top) | 
			 ((inv_end >= 6'd12) & wrap_top) | 
			 ((inv_start <= 6'd12) & (inv_end >= 6'd12))) & t_inv;
   
   wire       inv_r13 = (((inv_start <= 6'd13) & wrap_top) |
			 ((inv_end >= 6'd13) & wrap_top) | 
			 ((inv_start <= 6'd13) & (inv_end >= 6'd13))) & t_inv;
   
   wire       inv_r14 = (((inv_start <= 6'd14) & wrap_top) | 
			 ((inv_end >= 6'd14) & wrap_top) | 
			 ((inv_start <= 6'd14) & (inv_end >= 6'd14))) & t_inv;
   
   wire       inv_r15 = (((inv_start <= 6'd15) & wrap_top) | 
			 ((inv_end >= 6'd15) & wrap_top) | 
			 ((inv_start <= 6'd15) & (inv_end >= 6'd15))) & t_inv;
   
   wire       inv_r16 = (((inv_start <= 6'd16) & wrap_top) | 
			 ((inv_end >= 6'd16) & wrap_top) | 
			 ((inv_start <= 6'd16) & (inv_end >= 6'd16))) & t_inv;
   
   wire       inv_r17 = (((inv_start <= 6'd17) & wrap_top) |
			 ((inv_end >= 6'd17) & wrap_top) | 
			 ((inv_start <= 6'd17) & (inv_end >= 6'd17))) & t_inv;
   
   wire       inv_r18 = (((inv_start <= 6'd18) & wrap_top) |
			 ((inv_end >= 6'd18) & wrap_top) |
			 ((inv_start <= 6'd18) & (inv_end >= 6'd18))) & t_inv;
   
   wire       inv_r19 = (((inv_start <= 6'd19) & wrap_top) | 
			 ((inv_end >= 6'd19) & wrap_top) | 
			 ((inv_start <= 6'd19) & (inv_end >= 6'd19))) & t_inv;
   
   wire       inv_r20 = (((inv_start <= 6'd20) & wrap_top) |
			 ((inv_end >= 6'd20) & wrap_top) | 
			 ((inv_start <= 6'd20) & (inv_end >= 6'd20))) & t_inv;
   
   wire       inv_r21 = (((inv_start <= 6'd21) & wrap_top) | 
			 ((inv_end >= 6'd21) & wrap_top) | 
			 ((inv_start <= 6'd21) & (inv_end >= 6'd21))) & t_inv;
   
   wire       inv_r22 = (((inv_start <= 6'd22) & wrap_top) | 
			 ((inv_end >= 6'd22) & wrap_top) | 
			 ((inv_start <= 6'd22) & (inv_end >= 6'd22))) & t_inv;
   
   wire       inv_r23 = (((inv_start <= 6'd23) & wrap_top) | 
			 ((inv_end >= 6'd23) & wrap_top) |
			 ((inv_start <= 6'd23) & (inv_end >= 6'd23))) & t_inv;
   
   wire       inv_r24 = (((inv_start <= 6'd24) & wrap_top) | 
			 ((inv_end >= 6'd24) & wrap_top) | 
			 ((inv_start <= 6'd24) & (inv_end >= 6'd24))) & t_inv;
   
   wire       inv_r25 = (((inv_start <= 6'd25) & wrap_top) | 
			 ((inv_end >= 6'd25) & wrap_top) |
			 ((inv_start <= 6'd25) & (inv_end >= 6'd25))) & t_inv;
   
   wire       inv_r26 = (((inv_start <= 6'd26) & wrap_top) | 
			 ((inv_end >= 6'd26) & wrap_top) | 
			 ((inv_start <= 6'd26) & (inv_end >= 6'd26))) & t_inv;
   
   wire       inv_r27 = (((inv_start <= 6'd27) & wrap_top) |
			 ((inv_end >= 6'd27) & wrap_top) | 
			 ((inv_start <= 6'd27) & (inv_end >= 6'd27))) & t_inv;
   
   wire       inv_r28 = (((inv_start <= 6'd28) & wrap_top) | 
			 ((inv_end >= 6'd28) & wrap_top) | 
			 ((inv_start <= 6'd28) & (inv_end >= 6'd28))) & t_inv;
   
   wire       inv_r29 = (((inv_start <= 6'd29) & wrap_top) | 
			 ((inv_end >= 6'd29) & wrap_top) | 
			 ((inv_start <= 6'd29) & (inv_end >= 6'd29))) & t_inv;
   
   wire       inv_r30 = (((inv_start <= 6'd30) & wrap_top) | 
			 ((inv_end >= 6'd30) & wrap_top) | 
			 ((inv_start <= 6'd30) & (inv_end >= 6'd30))) & t_inv;
   
   wire       inv_r31 = (((inv_start <= 6'd31) & wrap_top) | 
			 ((inv_end >= 6'd31) & wrap_top) |
			 ((inv_start <= 6'd31) & (inv_end >= 6'd31))) & t_inv;
   
   wire       inv_r32 = (((inv_start <= 6'd32) & wrap_top) | 
	      ((inv_end >= 6'd32) & wrap_top) | 
	      ((inv_start <= 6'd32) & (inv_end >= 6'd32))) & t_inv;
   
   wire       inv_r33 = (((inv_start <= 6'd33) & wrap_top) |
	      ((inv_end >= 6'd33) & wrap_top) |
	      ((inv_start <= 6'd33) & (inv_end >= 6'd33))) & t_inv;
   
   wire       inv_r34 = (((inv_start <= 6'd34) & wrap_top) |
	      ((inv_end >= 6'd34) & wrap_top) | 
	      ((inv_start <= 6'd34) & (inv_end >= 6'd34))) & t_inv;
   
   wire       inv_r35 = (((inv_start <= 6'd35) & wrap_top) |
	      ((inv_end >= 6'd35) & wrap_top) | 
	      ((inv_start <= 6'd35) & (inv_end >= 6'd35))) & t_inv;
   
   wire       inv_r36 = (((inv_start <= 6'd36) & wrap_top) | 
	      ((inv_end >= 6'd36) & wrap_top) | 
	      ((inv_start <= 6'd36) & (inv_end >= 6'd36))) & t_inv;
   
   wire       inv_r37 = (((inv_start <= 6'd37) & wrap_top) | 
	      ((inv_end >= 6'd37) & wrap_top) | 
	      ((inv_start <= 6'd37) & (inv_end >= 6'd37))) & t_inv;
   
   wire       inv_r38 = (((inv_start <= 6'd38) & wrap_top) | 
	      ((inv_end >= 6'd38) & wrap_top) | 
	      ((inv_start <= 6'd38) & (inv_end >= 6'd38))) & t_inv;
   
   wire       inv_r39 = (((inv_start <= 6'd39) & wrap_top) | 
	      ((inv_end >= 6'd39) & wrap_top) | 
	      ((inv_start <= 6'd39) & (inv_end >= 6'd39))) & t_inv;
   
   wire       inv_r40 = (((inv_start <= 6'd40) & wrap_top) |
	      ((inv_end >= 6'd40) & wrap_top) | 
	      ((inv_start <= 6'd40) & (inv_end >= 6'd40))) & t_inv;
   
   wire       inv_r41 = (((inv_start <= 6'd41) & wrap_top) | 
	      ((inv_end >= 6'd41) & wrap_top) | 
	      ((inv_start <= 6'd41) & (inv_end >= 6'd41))) & t_inv;
   
   wire       inv_r42 = (((inv_start <= 6'd42) & wrap_top) | 
	      ((inv_end >= 6'd42) & wrap_top) | 
	      ((inv_start <= 6'd42) & (inv_end >= 6'd42))) & t_inv;
   
   wire       inv_r43 = (((inv_start <= 6'd43) & wrap_top) | 
	      ((inv_end >= 6'd43) & wrap_top) | 
	      ((inv_start <= 6'd43) & (inv_end >= 6'd43))) & t_inv;
   
   wire       inv_r44 = (((inv_start <= 6'd44) & wrap_top) |
	      ((inv_end >= 6'd44) & wrap_top) |
	      ((inv_start <= 6'd44) & (inv_end >= 6'd44))) & t_inv;
   
   wire       inv_r45 = (((inv_start <= 6'd45) & wrap_top) | 
	      ((inv_end >= 6'd45) & wrap_top) | 
	      ((inv_start <= 6'd45) & (inv_end >= 6'd45))) & t_inv;
   
   wire       inv_r46 = (((inv_start <= 6'd46) & wrap_top) | 
	      ((inv_end >= 6'd46) & wrap_top) | 
	      ((inv_start <= 6'd46) & (inv_end >= 6'd46))) & t_inv; 
 
   wire       inv_r47 = (((inv_start <= 6'd47) & wrap_top) | 
	      ((inv_end >= 6'd47) & wrap_top) | 
	      ((inv_start <= 6'd47) & (inv_end >= 6'd47))) & t_inv;
   
   wire       inv_r48 = (((inv_start <= 6'd48) & wrap_top) |
	      ((inv_end >= 6'd48) & wrap_top) |
	      ((inv_start <= 6'd48) & (inv_end >= 6'd48))) & t_inv;
   
   wire       inv_r49 = (((inv_start <= 6'd49) & wrap_top) | 
	      ((inv_end >= 6'd49) & wrap_top) | 
	      ((inv_start <= 6'd49) & (inv_end >= 6'd49))) & t_inv;
   
   wire       inv_r50 = (((inv_start <= 6'd50) & wrap_top) | 
	      ((inv_end >= 6'd50) & wrap_top) | 
	      ((inv_start <= 6'd50) & (inv_end >= 6'd50))) & t_inv;
   
   wire       inv_r51 = (((inv_start <= 6'd51) & wrap_top) | 
	      ((inv_end >= 6'd51) & wrap_top) | 
	      ((inv_start <= 6'd51) & (inv_end >= 6'd51))) & t_inv;
   
   wire       inv_r52 = (((inv_start <= 6'd52) & wrap_top) |
	      ((inv_end >= 6'd52) & wrap_top) | 
	      ((inv_start <= 6'd52) & (inv_end >= 6'd52))) & t_inv;
   
   wire       inv_r53 = (((inv_start <= 6'd53) & wrap_top) | 
	      ((inv_end >= 6'd53) & wrap_top) | 
	      ((inv_start <= 6'd53) & (inv_end >= 6'd53))) & t_inv;
   
   wire       inv_r54 = (((inv_start <= 6'd54) & wrap_top) |
	      ((inv_end >= 6'd54) & wrap_top) | 
	      ((inv_start <= 6'd54) & (inv_end >= 6'd54))) & t_inv;
   
   wire       inv_r55 = (((inv_start <= 6'd55) & wrap_top) | 
	      ((inv_end >= 6'd55) & wrap_top) | 
	      ((inv_start <= 6'd55) & (inv_end >= 6'd55))) & t_inv;
   
   wire       inv_r56 = (((inv_start <= 6'd56) & wrap_top) | 
	      ((inv_end >= 6'd56) & wrap_top) | 
	      ((inv_start <= 6'd56) & (inv_end >= 6'd56))) & t_inv;
   
   wire       inv_r57 = (((inv_start <= 6'd57) & wrap_top) |
	      ((inv_end >= 6'd57) & wrap_top) | 
	      ((inv_start <= 6'd57) & (inv_end >= 6'd57))) & t_inv;
   
   wire       inv_r58 = (((inv_start <= 6'd58) & wrap_top) | 
	      ((inv_end >= 6'd58) & wrap_top) | 
	      ((inv_start <= 6'd58) & (inv_end >= 6'd58))) & t_inv;
   
   wire       inv_r59 = (((inv_start <= 6'd59) & wrap_top) | 
	      ((inv_end >= 6'd59) & wrap_top) | 
	      ((inv_start <= 6'd59) & (inv_end >= 6'd59))) & t_inv;
 
   wire       inv_r60 = (((inv_start <= 6'd60) & wrap_top) | 
	      ((inv_end >= 6'd60) & wrap_top) | 
	      ((inv_start <= 6'd60) & (inv_end >= 6'd60))) & t_inv;
   
   wire       inv_r61 = (((inv_start <= 6'd61) & wrap_top) |
	      ((inv_end >= 6'd61) & wrap_top) | 
	      ((inv_start <= 6'd61) & (inv_end >= 6'd61))) & t_inv;
   
   wire       inv_r62 = (((inv_start <= 6'd62) & wrap_top) | 
	      ((inv_end >= 6'd62) & wrap_top) | 
	      ((inv_start <= 6'd62) & (inv_end >= 6'd62))) & t_inv;
   
   wire       inv_r63 = (((inv_start <= 6'd63) & wrap_top) | 
	      ((inv_end >= 6'd63) & wrap_top) | 
	      ((inv_start <= 6'd63) & (inv_end >= 6'd63))) & t_inv; 


   
   

   wire       set_r0 = /* (w_fetch_active) & */ (last_local_addr == 6'd0) & (r_instr_ready);
   wire       set_r1 = /* (w_fetch_active) & */ (last_local_addr == 6'd1) & (r_instr_ready);
   wire       set_r2 = /* (w_fetch_active) & */ (last_local_addr == 6'd2) & (r_instr_ready);
   wire       set_r3 = /* (w_fetch_active) & */ (last_local_addr == 6'd3) & (r_instr_ready);
   wire       set_r4 = /* (w_fetch_active) & */ (last_local_addr == 6'd4) & (r_instr_ready);
   wire       set_r5 = /* (w_fetch_active) & */ (last_local_addr == 6'd5) & (r_instr_ready);
   wire       set_r6 = /* (w_fetch_active) & */ (last_local_addr == 6'd6) & (r_instr_ready);
   wire       set_r7 = /* (w_fetch_active) & */ (last_local_addr == 6'd7) & (r_instr_ready);
   wire       set_r8 = /* (w_fetch_active) & */ (last_local_addr == 6'd8) & (r_instr_ready);
   wire       set_r9 = /* (w_fetch_active) & */ (last_local_addr == 6'd9) & (r_instr_ready);
   wire       set_r10 = /* (w_fetch_active) & */ (last_local_addr == 6'd10) & (r_instr_ready);
   wire       set_r11 = /* (w_fetch_active) & */ (last_local_addr == 6'd11) & (r_instr_ready);
   wire       set_r12 = /* (w_fetch_active) & */ (last_local_addr == 6'd12) & (r_instr_ready);
   wire       set_r13 = /* (w_fetch_active) & */ (last_local_addr == 6'd13) & (r_instr_ready);
   wire       set_r14 = /* (w_fetch_active) & */ (last_local_addr == 6'd14) & (r_instr_ready);
   wire       set_r15 = /* (w_fetch_active) & */ (last_local_addr == 6'd15) & (r_instr_ready);
   wire       set_r16 = /* (w_fetch_active) & */ (last_local_addr == 6'd16) & (r_instr_ready);
   wire       set_r17 = /* (w_fetch_active) & */ (last_local_addr == 6'd17) & (r_instr_ready);
   wire       set_r18 = /* (w_fetch_active) & */ (last_local_addr == 6'd18) & (r_instr_ready);
   wire       set_r19 = /* (w_fetch_active) & */ (last_local_addr == 6'd19) & (r_instr_ready);
   wire       set_r20 = /* (w_fetch_active) & */ (last_local_addr == 6'd20) & (r_instr_ready);
   wire       set_r21 = /* (w_fetch_active) & */ (last_local_addr == 6'd21) & (r_instr_ready);
   wire       set_r22 = /* (w_fetch_active) & */ (last_local_addr == 6'd22) & (r_instr_ready);
   wire       set_r23 = /* (w_fetch_active) & */ (last_local_addr == 6'd23) & (r_instr_ready);
   wire       set_r24 = /* (w_fetch_active) & */ (last_local_addr == 6'd24) & (r_instr_ready);
   wire       set_r25 = /* (w_fetch_active) & */ (last_local_addr == 6'd25) & (r_instr_ready);
   wire       set_r26 = /* (w_fetch_active) & */ (last_local_addr == 6'd26) & (r_instr_ready);
   wire       set_r27 = /* (w_fetch_active) & */ (last_local_addr == 6'd27) & (r_instr_ready);
   wire       set_r28 = /* (w_fetch_active) & */ (last_local_addr == 6'd28) & (r_instr_ready);
   wire       set_r29 = /* (w_fetch_active) & */ (last_local_addr == 6'd29) & (r_instr_ready);
   wire       set_r30 = /* (w_fetch_active) & */ (last_local_addr == 6'd30) & (r_instr_ready);
   wire       set_r31 = /* (w_fetch_active) & */ (last_local_addr == 6'd31) & (r_instr_ready);
   wire       set_r32 = /* (w_fetch_active) & */ (last_local_addr == 6'd32) & (r_instr_ready);
   wire       set_r33 = /* (w_fetch_active) & */ (last_local_addr == 6'd33) & (r_instr_ready);
   wire       set_r34 = /* (w_fetch_active) & */ (last_local_addr == 6'd34) & (r_instr_ready);
   wire       set_r35 = /* (w_fetch_active) & */ (last_local_addr == 6'd35) & (r_instr_ready);
   wire       set_r36 = /* (w_fetch_active) & */ (last_local_addr == 6'd36) & (r_instr_ready);
   wire       set_r37 = /* (w_fetch_active) & */ (last_local_addr == 6'd37) & (r_instr_ready);
   wire       set_r38 = /* (w_fetch_active) & */ (last_local_addr == 6'd38) & (r_instr_ready);
   wire       set_r39 = /* (w_fetch_active) & */ (last_local_addr == 6'd39) & (r_instr_ready);
   wire       set_r40 = /* (w_fetch_active) & */ (last_local_addr == 6'd40) & (r_instr_ready);
   wire       set_r41 = /* (w_fetch_active) & */ (last_local_addr == 6'd41) & (r_instr_ready);
   wire       set_r42 = /* (w_fetch_active) & */ (last_local_addr == 6'd42) & (r_instr_ready);
   wire       set_r43 = /* (w_fetch_active) & */ (last_local_addr == 6'd43) & (r_instr_ready);
   wire       set_r44 = /* (w_fetch_active) & */ (last_local_addr == 6'd44) & (r_instr_ready);
   wire       set_r45 = /* (w_fetch_active) & */ (last_local_addr == 6'd45) & (r_instr_ready);
   wire       set_r46 = /* (w_fetch_active) & */ (last_local_addr == 6'd46) & (r_instr_ready);
   wire       set_r47 = /* (w_fetch_active) & */ (last_local_addr == 6'd47) & (r_instr_ready);
   wire       set_r48 = /* (w_fetch_active) & */ (last_local_addr == 6'd48) & (r_instr_ready);
   wire       set_r49 = /* (w_fetch_active) & */ (last_local_addr == 6'd49) & (r_instr_ready);
   wire       set_r50 = /* (w_fetch_active) & */ (last_local_addr == 6'd50) & (r_instr_ready);
   wire       set_r51 = /* (w_fetch_active) & */ (last_local_addr == 6'd51) & (r_instr_ready);
   wire       set_r52 = /* (w_fetch_active) & */ (last_local_addr == 6'd52) & (r_instr_ready);
   wire       set_r53 = /* (w_fetch_active) & */ (last_local_addr == 6'd53) & (r_instr_ready);
   wire       set_r54 = /* (w_fetch_active) & */ (last_local_addr == 6'd54) & (r_instr_ready);
   wire       set_r55 = /* (w_fetch_active) & */ (last_local_addr == 6'd55) & (r_instr_ready);
   wire       set_r56 = /* (w_fetch_active) & */ (last_local_addr == 6'd56) & (r_instr_ready);
   wire       set_r57 = /* (w_fetch_active) & */ (last_local_addr == 6'd57) & (r_instr_ready);
   wire       set_r58 = /* (w_fetch_active) & */ (last_local_addr == 6'd58) & (r_instr_ready);
   wire       set_r59 = /* (w_fetch_active) & */ (last_local_addr == 6'd59) & (r_instr_ready);
   wire       set_r60 = /* (w_fetch_active) & */ (last_local_addr == 6'd60) & (r_instr_ready);
   wire       set_r61 = /* (w_fetch_active) & */ (last_local_addr == 6'd61) & (r_instr_ready);
   wire       set_r62 = /* (w_fetch_active) & */ (last_local_addr == 6'd62) & (r_instr_ready);
   wire       set_r63 = /*(w_fetch_active) &*/ (last_local_addr == 6'd63) & (r_instr_ready);
   
   //rch: I'm setting all the valid bits to be 0 initially...
   always@(posedge clk or posedge rst)
     begin: ir_valid_vector_register
	if(rst)
	  begin
	     ir_valid_vector[6'd0] <= 1'b1;
	     ir_valid_vector[6'd1] <= 1'b1;
	     ir_valid_vector[6'd2] <= 1'b1;
	     ir_valid_vector[6'd3] <= 1'b1;
	     ir_valid_vector[6'd4] <= 1'b0;
	     ir_valid_vector[6'd5] <= 1'b0;
	     ir_valid_vector[6'd6] <= 1'b0;
	     ir_valid_vector[6'd7] <= 1'b0;
	     ir_valid_vector[6'd8] <= 1'b0;
	     ir_valid_vector[6'd9] <= 1'b0;
	     ir_valid_vector[6'd10] <= 1'b0;
	     ir_valid_vector[6'd11] <= 1'b0;
	     ir_valid_vector[6'd12] <= 1'b0;
	     ir_valid_vector[6'd13] <= 1'b0;
	     ir_valid_vector[6'd14] <= 1'b0;
	     ir_valid_vector[6'd15] <= 1'b0;
	     ir_valid_vector[6'd16] <= 1'b0;
	     ir_valid_vector[6'd17] <= 1'b0;
	     ir_valid_vector[6'd18] <= 1'b0;
	     ir_valid_vector[6'd19] <= 1'b0;
	     ir_valid_vector[6'd20] <= 1'b0;
	     ir_valid_vector[6'd21] <= 1'b0;
	     ir_valid_vector[6'd22] <= 1'b0;
	     ir_valid_vector[6'd23] <= 1'b0;
	     ir_valid_vector[6'd24] <= 1'b0;
	     ir_valid_vector[6'd25] <= 1'b0;
	     ir_valid_vector[6'd26] <= 1'b0;
	     ir_valid_vector[6'd27] <= 1'b0;
	     ir_valid_vector[6'd28] <= 1'b0;
	     ir_valid_vector[6'd29] <= 1'b0;
	     ir_valid_vector[6'd30] <= 1'b0;
	     ir_valid_vector[6'd31] <= 1'b0;
	     ir_valid_vector[6'd32] <= 1'b0;
	     ir_valid_vector[6'd33] <= 1'b0;
	     ir_valid_vector[6'd34] <= 1'b0;
	     ir_valid_vector[6'd35] <= 1'b0;
	     ir_valid_vector[6'd36] <= 1'b0;
	     ir_valid_vector[6'd37] <= 1'b0;
	     ir_valid_vector[6'd38] <= 1'b0;
	     ir_valid_vector[6'd39] <= 1'b0;
	     ir_valid_vector[6'd40] <= 1'b0;
	     ir_valid_vector[6'd41] <= 1'b0;
	     ir_valid_vector[6'd42] <= 1'b0;
	     ir_valid_vector[6'd43] <= 1'b0;
	     ir_valid_vector[6'd44] <= 1'b0;
	     ir_valid_vector[6'd45] <= 1'b0;
	     ir_valid_vector[6'd46] <= 1'b0;
	     ir_valid_vector[6'd47] <= 1'b0;
	     ir_valid_vector[6'd48] <= 1'b0;
	     ir_valid_vector[6'd49] <= 1'b0;
	     ir_valid_vector[6'd50] <= 1'b0;
	     ir_valid_vector[6'd51] <= 1'b0;
	     ir_valid_vector[6'd52] <= 1'b0;
	     ir_valid_vector[6'd53] <= 1'b0;
	     ir_valid_vector[6'd54] <= 1'b0;
	     ir_valid_vector[6'd55] <= 1'b0;
	     ir_valid_vector[6'd56] <= 1'b0;
	     ir_valid_vector[6'd57] <= 1'b0;
	     ir_valid_vector[6'd58] <= 1'b0;
	     ir_valid_vector[6'd59] <= 1'b0;
	     ir_valid_vector[6'd60] <= 1'b0;
	     ir_valid_vector[6'd61] <= 1'b0;
	     ir_valid_vector[6'd62] <= 1'b0;
	     ir_valid_vector[6'd63] <= 1'b0;
	     
	     
	  end
	else
	  begin
	     ir_valid_vector[6'd0] <= inv_r0 ? 1'b0 : set_r0 ? 
				      1'b1 : ir_valid_vector[6'd0];
	     ir_valid_vector[6'd1] <= inv_r1 ? 1'b0 : set_r1 ? 
				      1'b1 : ir_valid_vector[6'd1];
	     ir_valid_vector[6'd2] <= inv_r2 ? 1'b0 : set_r2 ? 
				      1'b1 : ir_valid_vector[6'd2];
	     ir_valid_vector[6'd3] <= inv_r3 ? 1'b0 : set_r3 ? 
				      1'b1 : ir_valid_vector[6'd3];
	     ir_valid_vector[6'd4] <= inv_r4 ? 1'b0 : set_r4 ? 
				      1'b1 : ir_valid_vector[6'd4];
	     ir_valid_vector[6'd5] <= inv_r5 ? 1'b0 : set_r5 ? 
				      1'b1 : ir_valid_vector[6'd5];
	     ir_valid_vector[6'd6] <= inv_r6 ? 1'b0 : set_r6 ? 
				      1'b1 : ir_valid_vector[6'd6];
	     ir_valid_vector[6'd7] <= inv_r7 ? 1'b0 : set_r7 ? 
				      1'b1 : ir_valid_vector[6'd7];
	     ir_valid_vector[6'd8] <= inv_r8 ? 1'b0 : set_r8 ? 
				      1'b1 : ir_valid_vector[6'd8];
	     ir_valid_vector[6'd9] <= inv_r9 ? 1'b0 : set_r9 ? 
				      1'b1 : ir_valid_vector[6'd9];
	     ir_valid_vector[6'd10] <= inv_r10 ? 1'b0 : set_r10 ? 
				       1'b1 : ir_valid_vector[6'd10];
	     ir_valid_vector[6'd11] <= inv_r11 ? 1'b0 : set_r11 ? 
				       1'b1 : ir_valid_vector[6'd11];
	     ir_valid_vector[6'd12] <= inv_r12 ? 1'b0 : set_r12 ? 
				       1'b1 : ir_valid_vector[6'd12];
	     ir_valid_vector[6'd13] <= inv_r13 ? 1'b0 : set_r13 ? 
				       1'b1 : ir_valid_vector[6'd13];
	     ir_valid_vector[6'd14] <= inv_r14 ? 1'b0 : set_r14 ? 
				       1'b1 : ir_valid_vector[6'd14];
	     ir_valid_vector[6'd15] <= inv_r15 ? 1'b0 : set_r15 ? 
				       1'b1 : ir_valid_vector[6'd15];
	     ir_valid_vector[6'd16] <= inv_r16 ? 1'b0 : set_r16 ? 
				       1'b1 : ir_valid_vector[6'd16];
	     ir_valid_vector[6'd17] <= inv_r17 ? 1'b0 : set_r17 ?
				       1'b1 : ir_valid_vector[6'd17];
	     ir_valid_vector[6'd18] <= inv_r18 ? 1'b0 : set_r18 ?
				       1'b1 : ir_valid_vector[6'd18];
	     ir_valid_vector[6'd19] <= inv_r19 ? 1'b0 : set_r19 ? 
				       1'b1 : ir_valid_vector[6'd19];
	     ir_valid_vector[6'd20] <= inv_r20 ? 1'b0 : set_r20 ? 
				       1'b1 : ir_valid_vector[6'd20];
	     ir_valid_vector[6'd21] <= inv_r21 ? 1'b0 : set_r21 ?
				       1'b1 : ir_valid_vector[6'd21];
	     ir_valid_vector[6'd22] <= inv_r22 ? 1'b0 : set_r22 ?
				       1'b1 : ir_valid_vector[6'd22];
	     ir_valid_vector[6'd23] <= inv_r23 ? 1'b0 : set_r23 ?
				       1'b1 : ir_valid_vector[6'd23];
	     ir_valid_vector[6'd24] <= inv_r24 ? 1'b0 : set_r24 ?
				       1'b1 : ir_valid_vector[6'd24];
	     ir_valid_vector[6'd25] <= inv_r25 ? 1'b0 : set_r25 ?
				       1'b1 : ir_valid_vector[6'd25];
	     ir_valid_vector[6'd26] <= inv_r26 ? 1'b0 : set_r26 ? 
				       1'b1 : ir_valid_vector[6'd26];
	     ir_valid_vector[6'd27] <= inv_r27 ? 1'b0 : set_r27 ?
				       1'b1 : ir_valid_vector[6'd27];
	     ir_valid_vector[6'd28] <= inv_r28 ? 1'b0 : set_r28 ? 
				       1'b1 : ir_valid_vector[6'd28];
	     ir_valid_vector[6'd29] <= inv_r29 ? 1'b0 : set_r29 ? 
				       1'b1 : ir_valid_vector[6'd29];
	     ir_valid_vector[6'd30] <= inv_r30 ? 1'b0 : set_r30 ?
				       1'b1 : ir_valid_vector[6'd30];
	     ir_valid_vector[6'd31] <= inv_r31 ? 1'b0 : set_r31 ? 
				       1'b1 : ir_valid_vector[6'd31];
	     ir_valid_vector[6'd32] <= inv_r32 ? 1'b0 : set_r32 ?
				       1'b1 : ir_valid_vector[6'd32];
	     ir_valid_vector[6'd33] <= inv_r33 ? 1'b0 : set_r33 ?
				       1'b1 : ir_valid_vector[6'd33];
	     ir_valid_vector[6'd34] <= inv_r34 ? 1'b0 : set_r34 ?
				       1'b1 : ir_valid_vector[6'd34];
	     ir_valid_vector[6'd35] <= inv_r35 ? 1'b0 : set_r35 ?
				       1'b1 : ir_valid_vector[6'd35];
	     ir_valid_vector[6'd36] <= inv_r36 ? 1'b0 : set_r36 ?
				       1'b1 : ir_valid_vector[6'd36];
	     ir_valid_vector[6'd37] <= inv_r37 ? 1'b0 : set_r37 ?
				       1'b1 : ir_valid_vector[6'd37];
	     ir_valid_vector[6'd38] <= inv_r38 ? 1'b0 : set_r38 ?
				       1'b1 : ir_valid_vector[6'd38];
	     ir_valid_vector[6'd39] <= inv_r39 ? 1'b0 : set_r39 ? 
				       1'b1 : ir_valid_vector[6'd39];
	     ir_valid_vector[6'd40] <= inv_r40 ? 1'b0 : set_r40 ? 
				       1'b1 : ir_valid_vector[6'd40];
	     ir_valid_vector[6'd41] <= inv_r41 ? 1'b0 : set_r41 ? 
				       1'b1 : ir_valid_vector[6'd41];
	     ir_valid_vector[6'd42] <= inv_r42 ? 1'b0 : set_r42 ? 
				       1'b1 : ir_valid_vector[6'd42];
	     ir_valid_vector[6'd43] <= inv_r43 ? 1'b0 : set_r43 ?
				       1'b1 : ir_valid_vector[6'd43];
	     ir_valid_vector[6'd44] <= inv_r44 ? 1'b0 : set_r44 ? 
				       1'b1 : ir_valid_vector[6'd44];
	     ir_valid_vector[6'd45] <= inv_r45 ? 1'b0 : set_r45 ? 
				       1'b1 : ir_valid_vector[6'd45];
	     ir_valid_vector[6'd46] <= inv_r46 ? 1'b0 : set_r46 ? 
				       1'b1 : ir_valid_vector[6'd46];
	     ir_valid_vector[6'd47] <= inv_r47 ? 1'b0 : set_r47 ? 
				       1'b1 : ir_valid_vector[6'd47];
	     ir_valid_vector[6'd48] <= inv_r48 ? 1'b0 : set_r48 ? 
				       1'b1 : ir_valid_vector[6'd48];
	     ir_valid_vector[6'd49] <= inv_r49 ? 1'b0 : set_r49 ? 
				       1'b1 : ir_valid_vector[6'd49];
	     ir_valid_vector[6'd50] <= inv_r50 ? 1'b0 : set_r50 ? 
				       1'b1 : ir_valid_vector[6'd50];
	     ir_valid_vector[6'd51] <= inv_r51 ? 1'b0 : set_r51 ? 
				       1'b1 : ir_valid_vector[6'd51];
	     ir_valid_vector[6'd52] <= inv_r52 ? 1'b0 : set_r52 ? 
				       1'b1 : ir_valid_vector[6'd52];
	     ir_valid_vector[6'd53] <= inv_r53 ? 1'b0 : set_r53 ? 
				       1'b1 : ir_valid_vector[6'd53];
	     ir_valid_vector[6'd54] <= inv_r54 ? 1'b0 : set_r54 ? 
				       1'b1 : ir_valid_vector[6'd54];
	     ir_valid_vector[6'd55] <= inv_r55 ? 1'b0 : set_r55 ? 
				       1'b1 : ir_valid_vector[6'd55];
	     ir_valid_vector[6'd56] <= inv_r56 ? 1'b0 : set_r56 ? 
				       1'b1 : ir_valid_vector[6'd56];
	     ir_valid_vector[6'd57] <= inv_r57 ? 1'b0 : set_r57 ? 
				       1'b1 : ir_valid_vector[6'd57];
	     ir_valid_vector[6'd58] <= inv_r58 ? 1'b0 : set_r58 ? 
				       1'b1 : ir_valid_vector[6'd58];
	     ir_valid_vector[6'd59] <= inv_r59 ? 1'b0 : set_r59 ? 
				       1'b1 : ir_valid_vector[6'd59];
	     ir_valid_vector[6'd60] <= inv_r60 ? 1'b0 : set_r60 ? 
				       1'b1 : ir_valid_vector[6'd60];
	     ir_valid_vector[6'd61] <= inv_r61 ? 1'b0 : set_r61 ? 
				       1'b1 : ir_valid_vector[6'd61];
	     ir_valid_vector[6'd62] <= inv_r62 ? 1'b0 : set_r62 ? 
				       1'b1 : ir_valid_vector[6'd62];
	     ir_valid_vector[6'd63] <= inv_r63 ? 1'b0 : set_r63 ? 
				       1'b1 : ir_valid_vector[6'd63];

	  end
     end


   reg [5:0] next_local_reload_addr;
   reg [31:0] next_global_reload_addr;
   reg [31:0] next_next_global_reload_addr;
   reg [31:0] r_next_next_global_reload_addr;
      
   reg [5:0]  next_reload_instr_counter;
   reg 	      t_mem_read;
   reg [63:0] next_load_instruction;
   
   reg 	      mem_read;
   
   reg 	      t_instr_ready;

   parameter state_idle = 2'd0;
   parameter st_1 = 2'd1;
   parameter st_2 = 2'd2;
   parameter st_3 = 2'd3;
      
   always@(*)
     begin
	next_local_reload_addr = local_reload_addr;
	
	next_global_reload_addr = global_reload_addr;
	next_next_global_reload_addr =r_next_next_global_reload_addr;
	
	next_reload_instr_counter = reload_instr_counter;
	t_inv = 1'b0;
	instr_ready = 1'b0;
	t_mem_read = 1'b0;
	next_load_instruction = load_instruction;
	t_instr_ready = 1'b0;
	
	nstate  = state_idle;
				
	case(state)
	  state_idle:
	    //idle state
	    begin
	       if(fetch_req)
		 begin
		    //we've got a request!
		    nstate = 2'd1;
		    next_local_reload_addr = fetch_base_ir_addr;
		    next_next_global_reload_addr = fetch_base_global_addr;
		    //next_global_reload_addr = fetch_base_global_addr;
		    
		    next_reload_instr_counter = fetch_len;
		    
		    t_inv = 1'b1;
		 end
	       else
		 begin
		    nstate = state_idle;
		    //next_global_reload_addr = r_next_next_global_reload_addr;
		    
		 end
	    end // case: 3'd0

	  st_1:
	    //send request from lower half of the instruction word
	    //aka bits 31 to 0 of a 64-bit word
	    begin
	       t_mem_read = 1'b1;
	       next_global_reload_addr = r_next_next_global_reload_addr;
	       nstate = st_2;
	       next_reload_instr_counter = reload_instr_counter;
	    end

	  st_2:
	    //wait for lower half instruction word to be delievered from memory
	    begin
	       if(data_ready)
		 begin
		    t_mem_read = 1'b0;
		    next_global_reload_addr = global_reload_addr + 32'd2;
		    //nstate = 3'd5;
		    next_load_instruction = data_in;
		     //registered
		    t_instr_ready = 1'b1;
		    //stuff below is from 5
		    instr_ready = 1'b1;
		    next_reload_instr_counter = reload_instr_counter - 6'd1;
	       	    next_local_reload_addr = local_reload_addr + 6'd1;
	       	    if(/*next_*/reload_instr_counter == 6'd0)
		      begin
			 nstate = state_idle;
		      end
		    else
		      begin
			 nstate = st_2;
		      end
		 end
	       else
		 begin
		    t_mem_read = 1'b1;
		    nstate = 2'd2;
		    
		 end
	    end // case: 3'd2
	  default: begin
	  end
       	endcase // case (state)
	
     end
   

   assign memory_request = t_mem_read;
   assign memory_request_addr=  next_global_reload_addr;
      
   always@(posedge clk or posedge rst)
     begin/*: state_register*/
	if(rst)
	  begin
	     mem_read <= 1'b0;
	     state <= 2'd0;
	     local_reload_addr <= 6'd0;
	     global_reload_addr <= 32'd0;
	     r_next_next_global_reload_addr <= 32'd0;
	     reload_instr_counter <= 6'd0;
	     load_instruction <= 64'd0;
	     r_instr_ready <= 1'b0;
	     
	  end
	else
	  begin
	     mem_read <= t_mem_read;
	     state <= nstate;
	     r_next_next_global_reload_addr <= next_next_global_reload_addr;
	     local_reload_addr <= next_local_reload_addr;
	     global_reload_addr <= next_global_reload_addr;
	     reload_instr_counter <= next_reload_instr_counter;
	     load_instruction <= next_load_instruction;
	     r_instr_ready <= t_instr_ready;
	  end // else: !if(rst)
     end // block: state_register


   reg 	     last_ready;
   always@(posedge clk or posedge rst)
     begin
	if(rst) begin
	   last_local_addr <= 6'd0;
	   last_ready <= 1'b0;
	end
	else begin
	   last_local_addr <= local_reload_addr;
	   last_ready <= ir_valid_vector[ce_pc];
	end
     end
   
   

   assign instr_valid = ir_valid_vector[ce_pc];

   instr_rf irs(
		// Outputs
		.instr_out		(instr_word),
		// Inputs
		.clk			(clk),
		.rst                    (rst),
		.xmu_boot_inst          (xmu_boot_inst),			
		.ce_pc			(ce_pc),
		.load_instr_addr	(last_local_addr),
		.load_instr_valid	(r_instr_ready),
		.load_instr_in		(load_instruction)
		);
   
   
endmodule // instr_supply

   
