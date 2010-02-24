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


module irf_dec4 (sel, en, y, in0, in1, in2, in3);
   input [1:0] sel;
   input       en;
   
   input [63:0] in0;
   input [63:0] in1;
   input [63:0] in2;
   input [63:0] in3;

   output [63:0] y;



   wire [63:0] 	 t0 = (sel[0] & en) ? in1 : in0;
   wire [63:0] 	 t1 = (sel[0] & en) ? in3 : in2;

   assign y = (sel[1] & en) ? t1 : t0;
endmodule // irf_dec4

module irf_dec8(sel, y, en, 
		in0, in1, in2, in3, in4, in5, in6, in7);

   input [2:0] sel;
   input       en;
   
   input [63:0] in0;
   input [63:0] in1;
   input [63:0] in2;
   input [63:0] in3;
   input [63:0] in4;
   input [63:0] in5;
   input [63:0] in6;
   input [63:0] in7;
   

   output [63:0] y;

   wire [63:0] 	 t0,t1;
      

   irf_dec4 d0
     (
      .sel(sel[1:0]),
      .en(~sel[2] & en),
      .y(t0),
      .in0(in0),
      .in1(in1),
      .in2(in2),
      .in3(in3)
      );
   
   irf_dec4 d1
     (
      .sel(sel[1:0]),
      .en(sel[2] & en),
      .y(t1),
      .in0(in4),
      .in1(in5),
      .in2(in6),
      .in3(in7)
      );

   assign y = (sel[2] & en) ? t1 : t0;
      

endmodule // irf_dec8


module irf_dec16(sel, y, en, 
		 in0, in1, in2, in3,
		 in4, in5, in6, in7,
		 in8, in9, in10, in11,
		 in12, in13, in14, in15);
   
   input [3:0] sel;
   output [63:0] y;
   input 	 en;
   
  
   input [63:0]  in0;
   input [63:0]  in1;
   input [63:0]  in2;
   input [63:0]  in3;
   input [63:0]  in4;
   input [63:0]  in5;
   input [63:0]  in6;
   input [63:0]  in7;
   input [63:0]  in8;
   input [63:0]  in9;
   input [63:0]  in10;
   input [63:0]  in11;
   input [63:0]  in12;
   input [63:0]  in13;
   input [63:0]  in14;
   input [63:0]  in15;


  wire [63:0] 	 t0,t1;
      

   irf_dec8 d0
     (
      .sel(sel[2:0]),
      .en(~sel[3] & en),
      .y(t0),
      .in0(in0),
      .in1(in1),
      .in2(in2),
      .in3(in3),
      .in4(in4),
      .in5(in5),
      .in6(in6),
      .in7(in7)
      );
 
   irf_dec8 d1
     (
      .sel(sel[2:0]),
      .en(sel[3] & en),
      .y(t1),
      .in0(in8),
      .in1(in9),
      .in2(in10),
      .in3(in11),
      .in4(in12),
      .in5(in13),
      .in6(in14),
      .in7(in15)
      );
 

   assign y = (en & sel[3]) ? t1 : t0;
   
endmodule // irf_dec16


module irf_dec32(sel, y, en, 
		 in0, in1, in2, in3,
		 in4, in5, in6, in7,
		 in8, in9, in10, in11,
		 in12, in13, in14, in15,
		 in16, in17, in18, in19,
		 in20, in21, in22, in23,
		 in24, in25, in26, in27,
		 in28, in29, in30, in31);
   
   input [4:0] sel;
   output [63:0] y;
   input 	 en;
     
   input [63:0]  in0;
   input [63:0]  in1;
   input [63:0]  in2;
   input [63:0]  in3;
   input [63:0]  in4;
   input [63:0]  in5;
   input [63:0]  in6;
   input [63:0]  in7;
   input [63:0]  in8;
   input [63:0]  in9;
   input [63:0]  in10;
   input [63:0]  in11;
   input [63:0]  in12;
   input [63:0]  in13;
   input [63:0]  in14;
   input [63:0]  in15;		   
   input [63:0]  in16;
   input [63:0]  in17;
   input [63:0]  in18;
   input [63:0]  in19;
   input [63:0]  in20;
   input [63:0]  in21;
   input [63:0]  in22;
   input [63:0]  in23;
   input [63:0]  in24;
   input [63:0]  in25;
   input [63:0]  in26;
   input [63:0]  in27;
   input [63:0]  in28;
   input [63:0]  in29;
   input [63:0]  in30;
   input [63:0]  in31;


   wire [63:0] 	 t0, t1;

   assign y = (sel[4] & en) ? t1 : t0;
         
   irf_dec16 d0
     (
      .sel(sel[3:0]),
      .y(t0),
      .en(~sel[4] & en),
      .in0(in0),
      .in1(in1),
      .in2(in2),
      .in3(in3),
      .in4(in4),
      .in5(in5),
      .in6(in6),
      .in7(in7),
      .in8(in8),
      .in9(in9),
      .in10(in10),
      .in11(in11),
      .in12(in12),
      .in13(in13),
      .in14(in14),
      .in15(in15)
      );

   irf_dec16 d1
     (
      .sel(sel[3:0]),
      .y(t1),
      .en(sel[4] & en),
      .in0(in16),
      .in1(in17),
      .in2(in18),
      .in3(in19),
      .in4(in20),
      .in5(in21),
      .in6(in22),
      .in7(in23),
      .in8(in24),
      .in9(in25),
      .in10(in26),
      .in11(in27),
      .in12(in28),
      .in13(in29),
      .in14(in30),
      .in15(in31)
      );
endmodule // irf_dec32


module irf_decoder(sel, y,
		 in0, in1, in2, in3,
		 in4, in5, in6, in7,
		 in8, in9, in10, in11,
		 in12, in13, in14, in15,
		 in16, in17, in18, in19,
		 in20, in21, in22, in23,
		 in24, in25, in26, in27,
		 in28, in29, in30, in31,
		 in32, in33, in34, in35,
		 in36, in37, in38, in39,
		 in40, in41, in42, in43,
		 in44, in45, in46, in47,
		 in48, in49, in50, in51,
		 in52, in53, in54, in55,
		 in56, in57, in58, in59,
		 in60, in61, in62, in63);

   input [5:0] sel;
   output [63:0] y;
   
   input [63:0]  in0;
   input [63:0]  in1;
   input [63:0]  in2;
   input [63:0]  in3;
   input [63:0]  in4;
   input [63:0]  in5;
   input [63:0]  in6;
   input [63:0]  in7;
   input [63:0]  in8;
   input [63:0]  in9;
   input [63:0]  in10;
   input [63:0]  in11;
   input [63:0]  in12;
   input [63:0]  in13;
   input [63:0]  in14;
   input [63:0]  in15;		   
   input [63:0]  in16;
   input [63:0]  in17;
   input [63:0]  in18;
   input [63:0]  in19;
   input [63:0]  in20;
   input [63:0]  in21;
   input [63:0]  in22;
   input [63:0]  in23;
   input [63:0]  in24;
   input [63:0]  in25;
   input [63:0]  in26;
   input [63:0]  in27;
   input [63:0]  in28;
   input [63:0]  in29;
   input [63:0]  in30;
   input [63:0]  in31;

   input [63:0]  in32;
   input [63:0]  in33;
   input [63:0]  in34;
   input [63:0]  in35;
   input [63:0]  in36;
   input [63:0]  in37;
   input [63:0]  in38;
   input [63:0]  in39;
   input [63:0]  in40;
   input [63:0]  in41;
   input [63:0]  in42;
   input [63:0]  in43;
   input [63:0]  in44;
   input [63:0]  in45;
   input [63:0]  in46;
   input [63:0]  in47;		   
   input [63:0]  in48;
   input [63:0]  in49;
   input [63:0]  in50;
   input [63:0]  in51;
   input [63:0]  in52;
   input [63:0]  in53;
   input [63:0]  in54;
   input [63:0]  in55;
   input [63:0]  in56;
   input [63:0]  in57;
   input [63:0]  in58;
   input [63:0]  in59;
   input [63:0]  in60;
   input [63:0]  in61;
   input [63:0]  in62;
   input [63:0]  in63;

   
   wire [63:0] 	 t0, t1;

   assign y = sel[5] ? t1 : t0;
      
   irf_dec32 d0
     (
      .sel(sel[4:0]),
      .y(t0),
      .en(~sel[5]),
      .in0(in0),
      .in1(in1),
      .in2(in2),
      .in3(in3),
      .in4(in4),
      .in5(in5),
      .in6(in6),
      .in7(in7),
      .in8(in8),
      .in9(in9),
      .in10(in10),
      .in11(in11),
      .in12(in12),
      .in13(in13),
      .in14(in14),
      .in15(in15),
      .in16(in16),
      .in17(in17),
      .in18(in18),
      .in19(in19),
      .in20(in20),
      .in21(in21),
      .in22(in22),
      .in23(in23),
      .in24(in24),
      .in25(in25),
      .in26(in26),
      .in27(in27),
      .in28(in28),
      .in29(in29),
      .in30(in30),
      .in31(in31)
      );

    irf_dec32 d1
     (
      .sel(sel[4:0]),
      .y(t1),
      .en(sel[5]),
      .in0(in32),
      .in1(in33),
      .in2(in34),
      .in3(in35),
      .in4(in36),
      .in5(in37),
      .in6(in38),
      .in7(in39),
      .in8(in40),
      .in9(in41),
      .in10(in42),
      .in11(in43),
      .in12(in44),
      .in13(in45),
      .in14(in46),
      .in15(in47),
      .in16(in48),
      .in17(in49),
      .in18(in50),
      .in19(in51),
      .in20(in52),
      .in21(in53),
      .in22(in54),
      .in23(in55),
      .in24(in56),
      .in25(in57),
      .in26(in58),
      .in27(in59),
      .in28(in60),
      .in29(in61),
      .in30(in62),
      .in31(in63)
      );


endmodule // irf_dec64
