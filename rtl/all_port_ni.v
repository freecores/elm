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
module all_port_ni(/*AUTOARG*/
   // Outputs
   gated_outgoing_A, ungated_outgoing_A, gated_outgoing_B, 
   ungated_outgoing_B, epe_sm0g_for_nA_vc0_gnt, 
   epe_sm0g_for_nB_vc0_gnt, epe_1g_for_nA_vc1_gnt, 
   see_for_nA_vc1_gnt, epe_1g_for_nB_vc1_gnt, see_for_nB_vc1_gnt, 
   nie_sm1_for_nA_vc2_gnt, nie_sm1_for_nB_vc2_gnt, 
   see_for_nA_vc3_gnt, nie_sm1_for_nA_vc3_gnt, 
   nie_sm2_for_nA_vc3_gnt, see_for_nB_vc3_gnt, 
   nie_sm1_for_nB_vc3_gnt, nie_sm2_for_nB_vc3_gnt, nA_vc0_incoming_d, 
   nA_vc1_incoming_d, nA_vc2_incoming_d, nA_vc3_incoming_d, 
   nB_vc0_incoming_d, nB_vc1_incoming_d, nB_vc2_incoming_d, 
   nB_vc3_incoming_d, nA_vc0_incoming_e, nA_vc1_incoming_e, 
   nA_vc2_incoming_e, nA_vc3_incoming_e, nB_vc0_incoming_e, 
   nB_vc1_incoming_e, nB_vc2_incoming_e, nB_vc3_incoming_e, 
   // Inputs
   CLK, rst, gated_incoming_A, ungated_incoming_A, gated_incoming_B, 
   ungated_incoming_B, epe_sm0g_for_nA_vc0_r, epe_sm0g_for_nA_vc0_h, 
   epe_sm0g_for_nA_vc0_d, epe_sm0g_for_nB_vc0_r, 
   epe_sm0g_for_nB_vc0_h, epe_sm0g_for_nB_vc0_d, epe_1g_for_nA_vc1_r, 
   epe_1g_for_nA_vc1_h, epe_1g_for_nA_vc1_d, see_for_nA_vc1_r, 
   see_for_nA_vc1_h, see_for_nA_vc1_d, epe_1g_for_nB_vc1_r, 
   epe_1g_for_nB_vc1_h, epe_1g_for_nB_vc1_d, see_for_nB_vc1_r, 
   see_for_nB_vc1_h, see_for_nB_vc1_d, nie_sm1_for_nA_vc2_r, 
   nie_sm1_for_nA_vc2_h, nie_sm1_for_nA_vc2_d, nie_sm1_for_nB_vc2_r, 
   nie_sm1_for_nB_vc2_h, nie_sm1_for_nB_vc2_d, see_for_nA_vc3_r, 
   see_for_nA_vc3_h, see_for_nA_vc3_d, nie_sm1_for_nA_vc3_r, 
   nie_sm1_for_nA_vc3_h, nie_sm1_for_nA_vc3_d, nie_sm2_for_nA_vc3_r, 
   nie_sm2_for_nA_vc3_h, nie_sm2_for_nA_vc3_d, see_for_nB_vc3_r, 
   see_for_nB_vc3_h, see_for_nB_vc3_d, nie_sm1_for_nB_vc3_r, 
   nie_sm1_for_nB_vc3_h, nie_sm1_for_nB_vc3_d, nie_sm2_for_nB_vc3_r, 
   nie_sm2_for_nB_vc3_h, nie_sm2_for_nB_vc3_d, nA_vc0_incoming_read, 
   nA_vc1_incoming_read, nA_vc2_incoming_read, nA_vc3_incoming_read, 
   nB_vc0_incoming_read, nB_vc1_incoming_read, nB_vc2_incoming_read, 
   nB_vc3_incoming_read
   );

   parameter gated_bits = 35;
   parameter ungated_bits = 5;
   parameter tackon_bits = 2;
   parameter par_vc0_credits = 3; //covers a non-immediate sd
   parameter par_vc1_credits = 3; //covers rt latency
   parameter par_vc2_credits = 3; //covers rt latency
   parameter par_vc3_credits = 3; //covers rt latency

   
   input     CLK;
   input     rst;

   
   
   //output wires to A and B
   output [gated_bits-1:0]   gated_outgoing_A;
   output [ungated_bits-1:0] ungated_outgoing_A;
   output [gated_bits-1:0]   gated_outgoing_B;
   output [ungated_bits-1:0] ungated_outgoing_B;

   reg [gated_bits-1:0]   gated_outgoing_A;
   reg [ungated_bits-1:0] ungated_outgoing_A;
   reg [gated_bits-1:0]   gated_outgoing_B;
   reg [ungated_bits-1:0] ungated_outgoing_B;

   //input wires from A and B
   input [gated_bits-1:0]    gated_incoming_A;
   input [ungated_bits-1:0]  ungated_incoming_A;
   input [gated_bits-1:0]    gated_incoming_B;
   input [ungated_bits-1:0]  ungated_incoming_B;

   
   
   
   //From the controllers...
   //arbitration occurs within units...
   //but this will go between units

   //////////VC0 outgoing\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
   input 		     epe_sm0g_for_nA_vc0_r;
   input 		     epe_sm0g_for_nA_vc0_h; //no need to have hold, since only one source
   input [gated_bits-tackon_bits-1:0] epe_sm0g_for_nA_vc0_d;
   output 			    epe_sm0g_for_nA_vc0_gnt;
   
   input 			    epe_sm0g_for_nB_vc0_r;
   input 			    epe_sm0g_for_nB_vc0_h;
   input [gated_bits-tackon_bits-1:0] epe_sm0g_for_nB_vc0_d;
   output 			    epe_sm0g_for_nB_vc0_gnt;
   
   //////////VC1 outgoing\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
   input 			    epe_1g_for_nA_vc1_r;
   input 			    epe_1g_for_nA_vc1_h;
   input [gated_bits-tackon_bits-1:0] epe_1g_for_nA_vc1_d;
   output 			    epe_1g_for_nA_vc1_gnt;
   input 			    see_for_nA_vc1_r;
   input 			    see_for_nA_vc1_h;
   input [gated_bits-tackon_bits-1:0] see_for_nA_vc1_d;
   output 			    see_for_nA_vc1_gnt;
   
   input 			    epe_1g_for_nB_vc1_r;
   input 			    epe_1g_for_nB_vc1_h;
   input [gated_bits-tackon_bits-1:0] epe_1g_for_nB_vc1_d;
   output 			    epe_1g_for_nB_vc1_gnt;
   input 			    see_for_nB_vc1_r;
   input 			    see_for_nB_vc1_h;
   input [gated_bits-tackon_bits-1:0] see_for_nB_vc1_d;
   output 			    see_for_nB_vc1_gnt;

   ////////VC2 outgoing\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
   input 			    nie_sm1_for_nA_vc2_r;
   input 			    nie_sm1_for_nA_vc2_h; //no need for hold, since only one source
   input [gated_bits-tackon_bits-1:0] nie_sm1_for_nA_vc2_d;
   output 			    nie_sm1_for_nA_vc2_gnt;
   
   input 			    nie_sm1_for_nB_vc2_r;
   input 			    nie_sm1_for_nB_vc2_h;
   input [gated_bits-tackon_bits-1:0] nie_sm1_for_nB_vc2_d;
   output 			    nie_sm1_for_nB_vc2_gnt;
   
   ///////VC3 outgoing\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
   input 			    see_for_nA_vc3_r;
   input 			    see_for_nA_vc3_h;
   input [gated_bits-tackon_bits-1:0] see_for_nA_vc3_d;
   output 			    see_for_nA_vc3_gnt;
   input 			    nie_sm1_for_nA_vc3_r;
   input 			    nie_sm1_for_nA_vc3_h;
   input [gated_bits-tackon_bits-1:0] nie_sm1_for_nA_vc3_d;
   output 			    nie_sm1_for_nA_vc3_gnt;
   input 			    nie_sm2_for_nA_vc3_r;
   input 			    nie_sm2_for_nA_vc3_h;
   input [gated_bits-tackon_bits-1:0] nie_sm2_for_nA_vc3_d;
   output 			      nie_sm2_for_nA_vc3_gnt;
   
   input 			      see_for_nB_vc3_r;
   input 			      see_for_nB_vc3_h;
   input [gated_bits-tackon_bits-1:0] see_for_nB_vc3_d;
   output 			      see_for_nB_vc3_gnt;
   input 			      nie_sm1_for_nB_vc3_r;
   input 			      nie_sm1_for_nB_vc3_h;
   input [gated_bits-tackon_bits-1:0] nie_sm1_for_nB_vc3_d;
   output 			      nie_sm1_for_nB_vc3_gnt;
   input 			      nie_sm2_for_nB_vc3_r;
   input 			      nie_sm2_for_nB_vc3_h;
   input [gated_bits-tackon_bits-1:0] nie_sm2_for_nB_vc3_d;
   output 			      nie_sm2_for_nB_vc3_gnt;
   

   ///////data incoming
   output [gated_bits-tackon_bits-1:0] nA_vc0_incoming_d;
   output [gated_bits-tackon_bits-1:0] nA_vc1_incoming_d;
   output [gated_bits-tackon_bits-1:0] nA_vc2_incoming_d;
   output [gated_bits-tackon_bits-1:0] nA_vc3_incoming_d;
   output [gated_bits-tackon_bits-1:0] nB_vc0_incoming_d;
   output [gated_bits-tackon_bits-1:0] nB_vc1_incoming_d;
   output [gated_bits-tackon_bits-1:0] nB_vc2_incoming_d;
   output [gated_bits-tackon_bits-1:0] nB_vc3_incoming_d;
   
   output 			     nA_vc0_incoming_e;
   output 			     nA_vc1_incoming_e;
   output 			     nA_vc2_incoming_e;
   output 			     nA_vc3_incoming_e;
   output 			     nB_vc0_incoming_e;
   output 			     nB_vc1_incoming_e;
   output 			     nB_vc2_incoming_e;
   output 			     nB_vc3_incoming_e;
			     
   input 			     nA_vc0_incoming_read;
   input 			     nA_vc1_incoming_read;
   input 			     nA_vc2_incoming_read;
   input 			     nA_vc3_incoming_read;
   input 			     nB_vc0_incoming_read;
   input 			     nB_vc1_incoming_read;
   input 			     nB_vc2_incoming_read;
   input 			     nB_vc3_incoming_read;
   
   reg [2:0] 			     vc0_credits_nA;
   reg [2:0] 			     vc1_credits_nA;
   reg [2:0] 			     vc2_credits_nA;
   reg [2:0] 			     vc3_credits_nA;
   
   reg [2:0] 			     vc0_credits_nB;
   reg [2:0] 			     vc1_credits_nB;
   reg [2:0] 			     vc2_credits_nB;
   reg [2:0] 			     vc3_credits_nB;
   
   wire can_I_send_vc0_nA = ~(vc0_credits_nA == 3'd0);
   wire can_I_send_vc1_nA = ~(vc1_credits_nA == 3'd0);
   wire can_I_send_vc2_nA = ~(vc2_credits_nA == 3'd0);
   wire can_I_send_vc3_nA = ~(vc3_credits_nA == 3'd0);
   wire can_I_send_vc0_nB = ~(vc0_credits_nB == 3'd0);
   wire can_I_send_vc1_nB = ~(vc1_credits_nB == 3'd0);
   wire can_I_send_vc2_nB = ~(vc2_credits_nB == 3'd0);
   wire can_I_send_vc3_nB = ~(vc3_credits_nB == 3'd0);

   wire epe_gets_vc1_nA;
   wire see_gets_vc1_nA;
   wire see_gets_vc3_nA;
   wire ni1_gets_vc3_nA;
   wire ni2_gets_vc3_nA;

   wire epe_gets_vc1_nB;
   wire see_gets_vc1_nB;
   wire see_gets_vc3_nB;
   wire ni1_gets_vc3_nB;
   wire ni2_gets_vc3_nB;

   wire outgoing_vc0_nA_r = epe_sm0g_for_nA_vc0_r;
   wire outgoing_vc1_nA_r = (epe_gets_vc1_nA & epe_1g_for_nA_vc1_r) |
			      (see_gets_vc1_nA & see_for_nA_vc1_r);
   wire outgoing_vc2_nA_r = nie_sm1_for_nA_vc2_r;
   wire outgoing_vc3_nA_r = (see_gets_vc3_nA & see_for_nA_vc3_r ) |
			      (ni1_gets_vc3_nA & nie_sm1_for_nA_vc3_r) |
				(ni2_gets_vc3_nA & nie_sm2_for_nA_vc3_r);

   wire [gated_bits-1:0] outgoing_vc0_nA_d;
   wire [gated_bits-1:0] outgoing_vc1_nA_d;
   wire [gated_bits-1:0] outgoing_vc2_nA_d;
   wire [gated_bits-1:0] outgoing_vc3_nA_d;
   
   assign outgoing_vc0_nA_d[gated_bits-1:gated_bits-tackon_bits] = 2'd0;
   assign outgoing_vc1_nA_d[gated_bits-1:gated_bits-tackon_bits] = 2'd1;
   assign outgoing_vc2_nA_d[gated_bits-1:gated_bits-tackon_bits] = 2'd2;
   assign outgoing_vc3_nA_d[gated_bits-1:gated_bits-tackon_bits] = 2'd3;
   assign outgoing_vc0_nA_d[gated_bits-tackon_bits-1:0] =
       	  epe_sm0g_for_nA_vc0_d;
   assign outgoing_vc1_nA_d[gated_bits-tackon_bits-1:0]  = epe_gets_vc1_nA ? 
	  epe_1g_for_nA_vc1_d : see_for_nA_vc1_d;
   assign outgoing_vc2_nA_d[gated_bits-tackon_bits-1:0]  =
       	  nie_sm1_for_nA_vc2_d;
   assign outgoing_vc3_nA_d[gated_bits-tackon_bits-1:0]  = see_gets_vc3_nA ? 
	  see_for_nA_vc3_d : (ni1_gets_vc3_nA ?
			      nie_sm1_for_nA_vc3_d : nie_sm2_for_nA_vc3_d);
   
   wire sending_vc3_nA = outgoing_vc3_nA_r & can_I_send_vc3_nA;
   wire sending_vc2_nA = outgoing_vc2_nA_r & can_I_send_vc2_nA
	& ~sending_vc3_nA;
   wire sending_vc1_nA = outgoing_vc1_nA_r & can_I_send_vc1_nA
	& ~sending_vc3_nA & ~sending_vc2_nA;
   wire sending_vc0_nA = outgoing_vc0_nA_r & can_I_send_vc0_nA
	& ~sending_vc3_nA & ~sending_vc2_nA & ~sending_vc1_nA;

   assign epe_sm0g_for_nA_vc0_gnt = sending_vc0_nA;
   assign epe_1g_for_nA_vc1_gnt = sending_vc1_nA & epe_gets_vc1_nA;
   assign see_for_nA_vc1_gnt = sending_vc1_nA & see_gets_vc1_nA;
   assign nie_sm1_for_nA_vc2_gnt = sending_vc2_nA;
   assign see_for_nA_vc3_gnt = sending_vc3_nA & see_gets_vc3_nA ;
   assign nie_sm1_for_nA_vc3_gnt = sending_vc3_nA & ni1_gets_vc3_nA ;
   assign nie_sm2_for_nA_vc3_gnt = sending_vc3_nA & ni2_gets_vc3_nA;

 

   wire outgoing_vc0_nB_r = epe_sm0g_for_nB_vc0_r;
   wire outgoing_vc1_nB_r = (epe_gets_vc1_nB & epe_1g_for_nB_vc1_r) |
			      (see_gets_vc1_nB & see_for_nB_vc1_r);
   wire outgoing_vc2_nB_r = nie_sm1_for_nB_vc2_r;
   wire outgoing_vc3_nB_r = (see_gets_vc3_nB & see_for_nB_vc3_r ) |
			      (ni1_gets_vc3_nB & nie_sm1_for_nB_vc3_r) |
				(ni2_gets_vc3_nB & nie_sm2_for_nB_vc3_r);
   
   wire [gated_bits-1:0] outgoing_vc0_nB_d;
   wire [gated_bits-1:0] outgoing_vc1_nB_d;
   wire [gated_bits-1:0] outgoing_vc2_nB_d;
   wire [gated_bits-1:0] outgoing_vc3_nB_d;
   assign outgoing_vc0_nB_d[gated_bits-1:gated_bits-tackon_bits] = 2'd0;
   assign outgoing_vc1_nB_d[gated_bits-1:gated_bits-tackon_bits] = 2'd1;
   assign outgoing_vc2_nB_d[gated_bits-1:gated_bits-tackon_bits] = 2'd2;
   assign outgoing_vc3_nB_d[gated_bits-1:gated_bits-tackon_bits] = 2'd3;
   assign outgoing_vc0_nB_d[gated_bits-tackon_bits-1:0] =
       	  epe_sm0g_for_nB_vc0_d;
   assign outgoing_vc1_nB_d[gated_bits-tackon_bits-1:0]  = epe_gets_vc1_nB ? 
	  epe_1g_for_nB_vc1_d : see_for_nB_vc1_d;
   assign outgoing_vc2_nB_d[gated_bits-tackon_bits-1:0]  =
       	  nie_sm1_for_nB_vc2_d;
   assign outgoing_vc3_nB_d[gated_bits-tackon_bits-1:0]  = see_gets_vc3_nB ? 
	  see_for_nB_vc1_d : (ni1_gets_vc3_nB ?
			      nie_sm1_for_nB_vc3_d : nie_sm2_for_nB_vc3_d);
   wire   sending_vc3_nB = outgoing_vc3_nB_r & can_I_send_vc3_nB;
   wire   sending_vc2_nB = outgoing_vc2_nB_r & can_I_send_vc2_nB
	  & ~sending_vc3_nB;
   wire   sending_vc1_nB = outgoing_vc1_nB_r & can_I_send_vc1_nB
	  & ~sending_vc3_nB & ~sending_vc2_nB;
   wire   sending_vc0_nB = outgoing_vc0_nB_r & can_I_send_vc0_nB
	  & ~sending_vc3_nB & ~sending_vc2_nB & ~sending_vc1_nB;
   
   assign epe_sm0g_for_nB_vc0_gnt = sending_vc0_nB;
   assign epe_1g_for_nB_vc1_gnt = sending_vc1_nB & epe_gets_vc1_nB;
   assign see_for_nB_vc1_gnt = sending_vc1_nB & see_gets_vc1_nB;
   assign nie_sm1_for_nB_vc2_gnt = sending_vc2_nB;
   assign see_for_nB_vc3_gnt = sending_vc3_nB & see_gets_vc3_nB ;
   assign nie_sm1_for_nB_vc3_gnt = sending_vc3_nB & ni1_gets_vc3_nB ;
   assign nie_sm2_for_nB_vc3_gnt = sending_vc3_nB & ni2_gets_vc3_nB;
   
   always@(posedge CLK or posedge rst)
     begin
	if(rst)
	  begin
	     gated_outgoing_A <= 35'd0;
	     gated_outgoing_B <= 35'd0;
	     ungated_outgoing_A <= 5'd0;
	     ungated_outgoing_B <= 5'd0;
	  end
	else
	  begin
	     ungated_outgoing_A[0] <= sending_vc0_nA | sending_vc1_nA |
				      sending_vc2_nA | sending_vc3_nA;
	     ungated_outgoing_A[1] <= nA_vc0_incoming_read & ~nA_vc0_incoming_e;
	     ungated_outgoing_A[2] <= nA_vc1_incoming_read & ~nA_vc1_incoming_e;
	     ungated_outgoing_A[3] <= nA_vc2_incoming_read & ~nA_vc2_incoming_e;
	     ungated_outgoing_A[4] <= nA_vc3_incoming_read & ~nA_vc3_incoming_e;
	     
	     ungated_outgoing_B[0] <= sending_vc0_nB | sending_vc1_nB |
				      sending_vc2_nB | sending_vc3_nB;
	     ungated_outgoing_B[1] <= nB_vc0_incoming_read & ~nB_vc0_incoming_e;
	     ungated_outgoing_B[2] <= nB_vc1_incoming_read & ~nB_vc1_incoming_e;
	     ungated_outgoing_B[3] <= nB_vc2_incoming_read & ~nB_vc2_incoming_e;
	     ungated_outgoing_B[4] <= nB_vc3_incoming_read & ~nB_vc3_incoming_e;

	     if(sending_vc0_nA | sending_vc1_nA | sending_vc2_nA | sending_vc3_nA)
	       begin
		  gated_outgoing_A <= sending_vc0_nA ? outgoing_vc0_nA_d :
				      sending_vc1_nA ? outgoing_vc1_nA_d :
				      sending_vc2_nA ? outgoing_vc2_nA_d :
				      outgoing_vc3_nA_d;
	       end
	     
	     if(sending_vc0_nB | sending_vc1_nB | sending_vc2_nB | sending_vc3_nB)
	       begin
		  gated_outgoing_B <= sending_vc0_nB ? outgoing_vc0_nB_d :
				      sending_vc1_nB ? outgoing_vc1_nB_d :
				      sending_vc2_nB ? outgoing_vc2_nB_d :
				      outgoing_vc3_nB_d;
	       end
	     
	  end
     end // always@ (posedge CLK)
   
   
   always@(posedge CLK or posedge rst)
     begin
	if(rst)
	  begin
	     vc0_credits_nA <= par_vc0_credits;
	     vc1_credits_nA <= par_vc1_credits;
	     vc2_credits_nA <= par_vc2_credits;
	     vc3_credits_nA <= par_vc3_credits;
	     vc0_credits_nB <= par_vc0_credits;
	     vc1_credits_nB <= par_vc1_credits;
	     vc2_credits_nB <= par_vc2_credits;
	     vc3_credits_nB <= par_vc3_credits;
	  end
	else
	  begin
	     vc0_credits_nA <= vc0_credits_nA -
			       (sending_vc0_nA ? 1'b1 : 1'b0) +
			       (ungated_incoming_A[1] ? 1'b1 : 1'b0);
	     vc1_credits_nA <= vc1_credits_nA -
			       (sending_vc1_nA ? 1'b1 : 1'b0) +
			       (ungated_incoming_A[2] ? 1'b1 : 1'b0);
	     vc2_credits_nA <= vc2_credits_nA -
			       (sending_vc2_nA ? 1'b1 : 1'b0) +
			       (ungated_incoming_A[3] ? 1'b1 : 1'b0);
	     vc3_credits_nA <= vc3_credits_nA -
			       (sending_vc3_nA ? 1'b1 : 1'b0) +
			       (ungated_incoming_A[4] ? 1'b1 : 1'b0);
	     vc0_credits_nB <= vc0_credits_nB -
			       (sending_vc0_nB ? 1'b1 : 1'b0) +
			       (ungated_incoming_B[1] ? 1'b1 : 1'b0);
	     vc1_credits_nB <= vc1_credits_nB -
			       (sending_vc1_nB ? 1'b1 : 1'b0) +
			       (ungated_incoming_B[2] ? 1'b1 : 1'b0);
	     vc2_credits_nB <= vc2_credits_nB -
			       (sending_vc2_nB ? 1'b1 : 1'b0) +
			       (ungated_incoming_B[3] ? 1'b1 : 1'b0);
	     vc3_credits_nB <= vc3_credits_nB -
			       (sending_vc3_nB ? 1'b1 : 1'b0) +
			       (ungated_incoming_B[4] ? 1'b1 : 1'b0);
	  end // else: !if(rst)
     end // always@ (posedge CLK)

   arb2to1_hold arb_vc1_nA(
			   // Outputs
			   .gnt_0	(epe_gets_vc1_nA),
			   .gnt_1	(see_gets_vc1_nA),
			   // Inputs
			   .CLK		(CLK),
			   .rst		(rst),
			   .req_0	(epe_1g_for_nA_vc1_r),
			   .req_1	(see_for_nA_vc1_r),
			   .hold_0	(epe_1g_for_nA_vc1_h),
			   .hold_1	(see_for_nA_vc1_h));
   arb2to1_hold arb_vc1_nB(
			   // Outputs
			   .gnt_0	(epe_gets_vc1_nB),
			   .gnt_1	(see_gets_vc1_nB),
			   // Inputs
			   .CLK		(CLK),
			   .rst		(rst),
			   .req_0	(epe_1g_for_nB_vc1_r),
			   .req_1	(see_for_nB_vc1_r),
			   .hold_0	(epe_1g_for_nB_vc1_h),
			   .hold_1	(see_for_nB_vc1_h));

   arb3to1_hold arb_vc3_nA(
			   // Outputs
			   .gnt_0	(see_gets_vc3_nA),
			   .gnt_1	(ni1_gets_vc3_nA),
			   .gnt_2	(ni2_gets_vc3_nA),
			   // Inputs
			   .CLK		(CLK),
			   .rst		(rst),
			   .req_0	(see_for_nA_vc3_r),
			   .req_1	(nie_sm1_for_nA_vc3_r),
			   .req_2	(nie_sm2_for_nA_vc3_r),
			   .hold_0	(see_for_nA_vc3_h),
			   .hold_1	(nie_sm1_for_nA_vc3_h),
			   .hold_2	(nie_sm2_for_nA_vc3_h));
   arb3to1_hold arb_vc3_nB(
			   // Outputs
			   .gnt_0	(see_gets_vc3_nB),
			   .gnt_1	(ni1_gets_vc3_nB),
			   .gnt_2	(ni2_gets_vc3_nB),
			   // Inputs
			   .CLK		(CLK),
			   .rst		(rst),
			   .req_0	(see_for_nB_vc3_r),
			   .req_1	(nie_sm1_for_nB_vc3_r),
			   .req_2	(nie_sm2_for_nB_vc3_r),
			   .hold_0	(see_for_nB_vc3_h),
			   .hold_1	(nie_sm1_for_nB_vc3_h),
			   .hold_2	(nie_sm2_for_nB_vc3_h));

   wire [7:0] wasted_full;
   
   fifo #(gated_bits-tackon_bits, 2) vc0_incom_nA_fifo(
	// Outputs
	.dout(nA_vc0_incoming_d),
	.full(wasted_full[0]),
	.empty(nA_vc0_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst),
	.r(nA_vc0_incoming_read),
	.w(ungated_incoming_A[0] & 
	   (gated_incoming_A[34:33] == 2'd0)),
	.din(gated_incoming_A[gated_bits-tackon_bits-1:0]));
   
   fifo #(gated_bits-tackon_bits, 2) vc1_incom_nA_fifo(
	// Outputs
	.dout(nA_vc1_incoming_d),
	.full(wasted_full[1]),
	.empty(nA_vc1_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst),
	.r(nA_vc1_incoming_read),
	.w(ungated_incoming_A[0] & 
	   (gated_incoming_A[34:33] == 2'd1)),
	.din(gated_incoming_A[gated_bits-tackon_bits-1:0]));
   
   fifo #(gated_bits-tackon_bits, 2) vc2_incom_nA_fifo(
	// Outputs
	.dout(nA_vc2_incoming_d),
	.full(wasted_full[2]),
	.empty(nA_vc2_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst),
	.r(nA_vc2_incoming_read),
	.w(ungated_incoming_A[0] & 
	   (gated_incoming_A[34:33] == 2'd2)),
	.din(gated_incoming_A[gated_bits-tackon_bits-1:0]));
   
   fifo #(gated_bits-tackon_bits, 2) vc3_incom_nA_fifo(
	// Outputs
	.dout(nA_vc3_incoming_d),
	.full(wasted_full[3]),
	.empty(nA_vc3_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst),
	.r(nA_vc3_incoming_read),
	.w(ungated_incoming_A[0] & 
	   (gated_incoming_A[34:33] == 2'd3)),
	.din(gated_incoming_A[gated_bits-tackon_bits-1:0]));

   
   fifo #(gated_bits-tackon_bits, 2) vc0_incom_nB_fifo(
	// Outputs
	.dout(nB_vc0_incoming_d),
	.full(wasted_full[4]),
	.empty(nB_vc0_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst), .r(nB_vc0_incoming_read),
	.w(ungated_incoming_B[0] & 
	   (gated_incoming_B[gated_bits-1:gated_bits-tackon_bits] == 2'd0)),
	.din(gated_incoming_B[gated_bits-tackon_bits-1:0]));
   
   fifo #(gated_bits-tackon_bits, 2) vc1_incom_nB_fifo(
	// Outputs
	.dout(nB_vc1_incoming_d),
	.full(wasted_full[5]),
	.empty(nB_vc1_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst),
	.r(nB_vc1_incoming_read),
	.w(ungated_incoming_B[0] & 
	   (gated_incoming_B[gated_bits-1:gated_bits-tackon_bits] == 2'd1)),
	.din(gated_incoming_B[gated_bits-tackon_bits-1:0]));
   
   fifo #(gated_bits-tackon_bits, 2) vc2_incom_nB_fifo(
	// Outputs
	.dout(nB_vc2_incoming_d),
	.full(wasted_full[6]),
	.empty(nB_vc2_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst),
	.r(nB_vc2_incoming_read),
	.w(ungated_incoming_B[0] & 
	   (gated_incoming_B[gated_bits-1:gated_bits-tackon_bits] == 2'd2)),
	.din(gated_incoming_B[gated_bits-tackon_bits-1:0]));
   
   fifo #(gated_bits-tackon_bits, 2) vc3_incom_nB_fifo(
	// Outputs
	.dout(nB_vc3_incoming_d),
	.full(wasted_full[7]),
	.empty(nB_vc3_incoming_e),
	// Inputs
	.clk(CLK),
	.rst(rst),
	.r(nB_vc3_incoming_read),
	.w(ungated_incoming_B[0] & 
	   (gated_incoming_B[gated_bits-1:gated_bits-tackon_bits] == 2'd3)),
	.din(gated_incoming_B[gated_bits-tackon_bits-1:0]));
   

endmodule // outgoing_port
