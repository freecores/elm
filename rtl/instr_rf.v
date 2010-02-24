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

module instr_rf(/*AUTOARG*/
   // Outputs
   instr_out,
   // Inputs
   clk, rst, ce_pc, xmu_boot_inst, load_instr_addr, load_instr_valid,
   load_instr_in
   );
   input clk;
   input rst;
   
   input [5:0] ce_pc;
   output [63:0] instr_out;
   
   input [31:0]  xmu_boot_inst;

   input [5:0] 	 load_instr_addr;
   input       load_instr_valid;
   input [63:0] load_instr_in;
   
   reg [63:0] 	ir [63:0];

   
   wire [63:0]	rst_insn = {xmu_boot_inst, 32'd0};
      irf_decoder ird
     (
      .sel(ce_pc),
      .y(instr_out),
      .in0(ir[0]),
      .in1(ir[1]),
      .in2(ir[2]),
      .in3(ir[3]),
      .in4(ir[4]),
      .in5(ir[5]),
      .in6(ir[6]),
      .in7(ir[7]),
      .in8(ir[8]),
      .in9(ir[9]),
      .in10(ir[10]),
      .in11(ir[11]),
      .in12(ir[12]),
      .in13(ir[13]),
      .in14(ir[14]),
      .in15(ir[15]),
      .in16(ir[16]),
      .in17(ir[17]),
      .in18(ir[18]),
      .in19(ir[19]),
      .in20(ir[20]),
      .in21(ir[21]),
      .in22(ir[22]),
      .in23(ir[23]),
      .in24(ir[24]),
      .in25(ir[25]),
      .in26(ir[26]),
      .in27(ir[27]),
      .in28(ir[28]),
      .in29(ir[29]),
      .in30(ir[30]),
      .in31(ir[31]),
      .in32(ir[32]),
      .in33(ir[33]),
      .in34(ir[34]),
      .in35(ir[35]),
      .in36(ir[36]),
      .in37(ir[37]),
      .in38(ir[38]),
      .in39(ir[39]),
      .in40(ir[40]),
      .in41(ir[41]),
      .in42(ir[42]),
      .in43(ir[43]),
      .in44(ir[44]),
      .in45(ir[45]),
      .in46(ir[46]),
      .in47(ir[47]),
      .in48(ir[48]),
      .in49(ir[49]),
      .in50(ir[50]),
      .in51(ir[51]),
      .in52(ir[52]),
      .in53(ir[53]),
      .in54(ir[54]),
      .in55(ir[55]),
      .in56(ir[56]),
      .in57(ir[57]),
      .in58(ir[58]),
      .in59(ir[59]),
      .in60(ir[60]),
      .in61(ir[61]),
      .in62(ir[62]),
      .in63(ir[63])
      );

   //assign instr_out = {32'd0, `X_MOVI, 7'b0010101, 6'd0, 5'b000000, 6'd10};
   
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     ir[6'd0] <= rst_insn;
	     ir[6'd1] <= 64'd0;
	     ir[6'd2] <= 64'd0;
	     ir[6'd3] <= 64'd0;
	     ir[6'd4] <= 64'd0;
	     ir[6'd5] <= 64'd0;
	     ir[6'd6] <= 64'd0;
	     ir[6'd7] <= 64'd0;
	     ir[6'd8] <= 64'd0;
	     ir[6'd9] <= 64'd0;
	     ir[6'd10] <= 64'd0;
	     ir[6'd11] <= 64'd0;
	     ir[6'd12] <= 64'd0;
	     ir[6'd13] <= 64'd0;
	     ir[6'd14] <= 64'd0;
	     ir[6'd15] <= 64'd0;
	     ir[6'd16] <= 64'd0;
	     ir[6'd17] <= 64'd0;
	     ir[6'd18] <= 64'd0;
	     ir[6'd19] <= 64'd0;
	     ir[6'd20] <= 64'd0;
	     ir[6'd21] <= 64'd0;
	     ir[6'd22] <= 64'd0;
	     ir[6'd23] <= 64'd0;
	     ir[6'd24] <= 64'd0;
	     ir[6'd25] <= 64'd0;
	     ir[6'd26] <= 64'd0;
	     ir[6'd27] <= 64'd0;
	     ir[6'd28] <= 64'd0;
	     ir[6'd29] <= 64'd0;
	     ir[6'd30] <= 64'd0;
	     ir[6'd31] <= 64'd0;
	     ir[6'd32] <= 64'd0;
	     ir[6'd33] <= 64'd0;
	     ir[6'd34] <= 64'd0;
	     ir[6'd35] <= 64'd0;
	     ir[6'd36] <= 64'd0;
	     ir[6'd37] <= 64'd0;
	     ir[6'd38] <= 64'd0;
	     ir[6'd39] <= 64'd0;
	     ir[6'd40] <= 64'd0;
	     ir[6'd41] <= 64'd0;
	     ir[6'd42] <= 64'd0;
	     ir[6'd43] <= 64'd0;
	     ir[6'd44] <= 64'd0;
	     ir[6'd45] <= 64'd0;
	     ir[6'd46] <= 64'd0;
	     ir[6'd47] <= 64'd0;
	     ir[6'd48] <= 64'd0;
	     ir[6'd49] <= 64'd0;
	     ir[6'd50] <= 64'd0;
	     ir[6'd51] <= 64'd0;
	     ir[6'd52] <= 64'd0;
	     ir[6'd53] <= 64'd0;
	     ir[6'd54] <= 64'd0;
	     ir[6'd55] <= 64'd0;
	     ir[6'd56] <= 64'd0;
	     ir[6'd57] <= 64'd0;
	     ir[6'd58] <= 64'd0;
	     ir[6'd59] <= 64'd0;
	     ir[6'd60] <= 64'd0;
	     ir[6'd61] <= 64'd0;
	     ir[6'd62] <= 64'd0;
	     ir[6'd63] <= 64'd0;
	  end
	else
	  begin
	     if(load_instr_valid)
	       begin
		  ir[load_instr_addr] <= load_instr_in;
	       end
	  end // else: !if(rst)
	
     end
   
   
      
   
endmodule
