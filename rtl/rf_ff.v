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


module rf_ff(read_port_1, read_port_2,
	 clk, rst, write_ptr_1, write_ptr_2, read_ptr_1, read_ptr_2,
	 write_ptr_1_valid, write_ptr_2_valid, write_port_1, write_port_2
	 ); 
	 
   input clk;
   input rst;
   
   input [4:0] write_ptr_1; 
   input [4:0] write_ptr_2; 
   input [4:0] read_ptr_1; 
   input [4:0] read_ptr_2; 
   input       write_ptr_1_valid; 
   input       write_ptr_2_valid; 
   input [31:0] write_port_1; 
   input [31:0] write_port_2; 
   output [31:0] read_port_1; 
   output [31:0] read_port_2; 
   reg [31:0] 	 t_read_port_1; 
   reg [31:0] 	 t_read_port_2; 
   
   assign read_port_1 = t_read_port_1; 
   assign read_port_2 = t_read_port_2; 


   reg [31:0] 	 r0;
   reg [31:0] 	 r1;
   reg [31:0] 	 r2;
   reg [31:0] 	 r3;
   reg [31:0] 	 r4;
   reg [31:0] 	 r5;
   reg [31:0] 	 r6;
   reg [31:0] 	 r7;
   reg [31:0] 	 r8;
   reg [31:0] 	 r9;
   reg [31:0] 	 r10;
   reg [31:0] 	 r11;
   reg [31:0] 	 r12;
   reg [31:0] 	 r13;
   reg [31:0] 	 r14;
   reg [31:0] 	 r15;
   reg [31:0] 	 r16;
   reg [31:0] 	 r17;
   reg [31:0] 	 r18;
   reg [31:0] 	 r19;
   reg [31:0] 	 r20;
   reg [31:0] 	 r21;
   reg [31:0] 	 r22;
   reg [31:0] 	 r23;
   reg [31:0] 	 r24;
   reg [31:0] 	 r25;
   reg [31:0] 	 r26;
   reg [31:0] 	 r27;
   reg [31:0] 	 r28;
   reg [31:0] 	 r29;
   reg [31:0] 	 r30;
   reg [31:0] 	 r31;
   
   wire 	 wptr1_0 = ((write_ptr_1 == 5'd0) && write_ptr_1_valid); 
   wire 	 wptr1_1 = ((write_ptr_1 == 5'd1) && write_ptr_1_valid); 
   wire 	 wptr1_2 = ((write_ptr_1 == 5'd2) && write_ptr_1_valid); 
   wire 	 wptr1_3 = ((write_ptr_1 == 5'd3) && write_ptr_1_valid); 
   wire 	 wptr1_4 = ((write_ptr_1 == 5'd4) && write_ptr_1_valid); 
   wire 	 wptr1_5 = ((write_ptr_1 == 5'd5) && write_ptr_1_valid); 
   wire 	 wptr1_6 = ((write_ptr_1 == 5'd6) && write_ptr_1_valid); 
   wire 	 wptr1_7 = ((write_ptr_1 == 5'd7) && write_ptr_1_valid); 
   wire 	 wptr1_8 = ((write_ptr_1 == 5'd8) && write_ptr_1_valid); 
   wire 	 wptr1_9 = ((write_ptr_1 == 5'd9) && write_ptr_1_valid); 
   wire 	 wptr1_10 = ((write_ptr_1 == 5'd10) && write_ptr_1_valid); 
   wire 	 wptr1_11 = ((write_ptr_1 == 5'd11) && write_ptr_1_valid); 
   wire 	 wptr1_12 = ((write_ptr_1 == 5'd12) && write_ptr_1_valid); 
   wire 	 wptr1_13 = ((write_ptr_1 == 5'd13) && write_ptr_1_valid); 
   wire 	 wptr1_14 = ((write_ptr_1 == 5'd14) && write_ptr_1_valid); 
   wire 	 wptr1_15 = ((write_ptr_1 == 5'd15) && write_ptr_1_valid); 
   wire 	 wptr1_16 = ((write_ptr_1 == 5'd16) && write_ptr_1_valid); 
   wire 	 wptr1_17 = ((write_ptr_1 == 5'd17) && write_ptr_1_valid); 
   wire 	 wptr1_18 = ((write_ptr_1 == 5'd18) && write_ptr_1_valid); 
   wire 	 wptr1_19 = ((write_ptr_1 == 5'd19) && write_ptr_1_valid); 
   wire 	 wptr1_20 = ((write_ptr_1 == 5'd20) && write_ptr_1_valid); 
   wire 	 wptr1_21 = ((write_ptr_1 == 5'd21) && write_ptr_1_valid); 
   wire 	 wptr1_22 = ((write_ptr_1 == 5'd22) && write_ptr_1_valid); 
   wire 	 wptr1_23 = ((write_ptr_1 == 5'd23) && write_ptr_1_valid); 
   wire 	 wptr1_24 = ((write_ptr_1 == 5'd24) && write_ptr_1_valid); 
   wire 	 wptr1_25 = ((write_ptr_1 == 5'd25) && write_ptr_1_valid); 
   wire 	 wptr1_26 = ((write_ptr_1 == 5'd26) && write_ptr_1_valid); 
   wire 	 wptr1_27 = ((write_ptr_1 == 5'd27) && write_ptr_1_valid); 
   wire 	 wptr1_28 = ((write_ptr_1 == 5'd28) && write_ptr_1_valid); 
   wire 	 wptr1_29 = ((write_ptr_1 == 5'd29) && write_ptr_1_valid); 
   wire 	 wptr1_30 = ((write_ptr_1 == 5'd30) && write_ptr_1_valid); 
   wire 	 wptr1_31 = ((write_ptr_1 == 5'd31) && write_ptr_1_valid); 
   
   
   wire 	 wptr2_0 = ((write_ptr_2 == 5'd0) && write_ptr_2_valid); 
   wire 	 wptr2_1 = ((write_ptr_2 == 5'd1) && write_ptr_2_valid); 
   wire 	 wptr2_2 = ((write_ptr_2 == 5'd2) && write_ptr_2_valid); 
   wire 	 wptr2_3 = ((write_ptr_2 == 5'd3) && write_ptr_2_valid); 
   wire 	 wptr2_4 = ((write_ptr_2 == 5'd4) && write_ptr_2_valid); 
   wire 	 wptr2_5 = ((write_ptr_2 == 5'd5) && write_ptr_2_valid); 
   wire 	 wptr2_6 = ((write_ptr_2 == 5'd6) && write_ptr_2_valid); 
   wire 	 wptr2_7 = ((write_ptr_2 == 5'd7) && write_ptr_2_valid); 
   wire 	 wptr2_8 = ((write_ptr_2 == 5'd8) && write_ptr_2_valid); 
   wire 	 wptr2_9 = ((write_ptr_2 == 5'd9) && write_ptr_2_valid); 
   wire 	 wptr2_10 = ((write_ptr_2 == 5'd10) && write_ptr_2_valid); 
   wire 	 wptr2_11 = ((write_ptr_2 == 5'd11) && write_ptr_2_valid); 
   wire 	 wptr2_12 = ((write_ptr_2 == 5'd12) && write_ptr_2_valid); 
   wire 	 wptr2_13 = ((write_ptr_2 == 5'd13) && write_ptr_2_valid); 
   wire 	 wptr2_14 = ((write_ptr_2 == 5'd14) && write_ptr_2_valid); 
   wire 	 wptr2_15 = ((write_ptr_2 == 5'd15) && write_ptr_2_valid); 
   wire 	 wptr2_16 = ((write_ptr_2 == 5'd16) && write_ptr_2_valid); 
   wire 	 wptr2_17 = ((write_ptr_2 == 5'd17) && write_ptr_2_valid); 
   wire 	 wptr2_18 = ((write_ptr_2 == 5'd18) && write_ptr_2_valid); 
   wire 	 wptr2_19 = ((write_ptr_2 == 5'd19) && write_ptr_2_valid); 
   wire 	 wptr2_20 = ((write_ptr_2 == 5'd20) && write_ptr_2_valid); 
   wire 	 wptr2_21 = ((write_ptr_2 == 5'd21) && write_ptr_2_valid); 
   wire 	 wptr2_22 = ((write_ptr_2 == 5'd22) && write_ptr_2_valid); 
   wire 	 wptr2_23 = ((write_ptr_2 == 5'd23) && write_ptr_2_valid); 
   wire 	 wptr2_24 = ((write_ptr_2 == 5'd24) && write_ptr_2_valid); 
   wire 	 wptr2_25 = ((write_ptr_2 == 5'd25) && write_ptr_2_valid); 
   wire 	 wptr2_26 = ((write_ptr_2 == 5'd26) && write_ptr_2_valid); 
   wire 	 wptr2_27 = ((write_ptr_2 == 5'd27) && write_ptr_2_valid); 
   wire 	 wptr2_28 = ((write_ptr_2 == 5'd28) && write_ptr_2_valid); 
   wire 	 wptr2_29 = ((write_ptr_2 == 5'd29) && write_ptr_2_valid); 
   wire 	 wptr2_30 = ((write_ptr_2 == 5'd30) && write_ptr_2_valid); 
   wire 	 wptr2_31 = ((write_ptr_2 == 5'd31) && write_ptr_2_valid); 
   
   
   always@(posedge clk or posedge rst) 
     begin
	if(rst)
	  begin
	     r0 <= 32'd0;
	     r1 <= 32'd0;
	     r2 <= 32'd0;
	     r3 <= 32'd0;
	     r4 <= 32'd0;
	     r5 <= 32'd0;
	     r6 <= 32'd0;
	     r7 <= 32'd0;
	     r8 <= 32'd0;
	     r9 <= 32'd0;
	     r10 <= 32'd0;
	     r11 <= 32'd0;
	     r12 <= 32'd0;
	     r13 <= 32'd0;
	     r14 <= 32'd0;
	     r15 <= 32'd0;
	     r16 <= 32'd0;
	     r17 <= 32'd0;
	     r18 <= 32'd0;
	     r19 <= 32'd0;
	     r20 <= 32'd0;
	     r21 <= 32'd0;
	     r22 <= 32'd0;
	     r23 <= 32'd0;
	     r24 <= 32'd0;
	     r25 <= 32'd0;
	     r26 <= 32'd0;
	     r27 <= 32'd0;
	     r28 <= 32'd0;
	     r29 <= 32'd0;
	     r30 <= 32'd0;
	     r31 <= 32'd0; 
	  end
	else
	  begin
	     r0 <= wptr1_0 ? write_port_1 : wptr2_0 ? write_port_2 : r0;
	     r1 <= wptr1_1 ? write_port_1 : wptr2_1 ? write_port_2 : r1;
	     r2 <= wptr1_2 ? write_port_1 : wptr2_2 ? write_port_2 : r2;
	     r3 <= wptr1_3 ? write_port_1 : wptr2_3 ? write_port_2 : r3;
	     r4 <= wptr1_4 ? write_port_1 : wptr2_4 ? write_port_2 : r4;
	     r5 <= wptr1_5 ? write_port_1 : wptr2_5 ? write_port_2 : r5;
	     r6 <= wptr1_6 ? write_port_1 : wptr2_6 ? write_port_2 : r6;
	     r7 <= wptr1_7 ? write_port_1 : wptr2_7 ? write_port_2 : r7;
	     r8 <= wptr1_8 ? write_port_1 : wptr2_8 ? write_port_2 : r8;
	     r9 <= wptr1_9 ? write_port_1 : wptr2_9 ? write_port_2 : r9;
	     r10 <= wptr1_10 ? write_port_1 : wptr2_10 ? write_port_2 : r10;
	     r11 <= wptr1_11 ? write_port_1 : wptr2_11 ? write_port_2 : r11;
	     r12 <= wptr1_12 ? write_port_1 : wptr2_12 ? write_port_2 : r12;
	     r13 <= wptr1_13 ? write_port_1 : wptr2_13 ? write_port_2 : r13;
	     r14 <= wptr1_14 ? write_port_1 : wptr2_14 ? write_port_2 : r14;
	     r15 <= wptr1_15 ? write_port_1 : wptr2_15 ? write_port_2 : r15;
	     r16 <= wptr1_16 ? write_port_1 : wptr2_16 ? write_port_2 : r16;
	     r17 <= wptr1_17 ? write_port_1 : wptr2_17 ? write_port_2 : r17;
	     r18 <= wptr1_18 ? write_port_1 : wptr2_18 ? write_port_2 : r18;
	     r19 <= wptr1_19 ? write_port_1 : wptr2_19 ? write_port_2 : r19;
	     r20 <= wptr1_20 ? write_port_1 : wptr2_20 ? write_port_2 : r20;
	     r21 <= wptr1_21 ? write_port_1 : wptr2_21 ? write_port_2 : r21;
	     r22 <= wptr1_22 ? write_port_1 : wptr2_22 ? write_port_2 : r22;
	     r23 <= wptr1_23 ? write_port_1 : wptr2_23 ? write_port_2 : r23;
	     r24 <= wptr1_24 ? write_port_1 : wptr2_24 ? write_port_2 : r24;
	     r25 <= wptr1_25 ? write_port_1 : wptr2_25 ? write_port_2 : r25;
	     r26 <= wptr1_26 ? write_port_1 : wptr2_26 ? write_port_2 : r26;
	     r27 <= wptr1_27 ? write_port_1 : wptr2_27 ? write_port_2 : r27;
	     r28 <= wptr1_28 ? write_port_1 : wptr2_28 ? write_port_2 : r28;
	     r29 <= wptr1_29 ? write_port_1 : wptr2_29 ? write_port_2 : r29;
	     r30 <= wptr1_30 ? write_port_1 : wptr2_30 ? write_port_2 : r30;
	     r31 <= wptr1_31 ? write_port_1 : wptr2_31 ? write_port_2 : r31;
	  end // else: !if(rst)
     end // always@ (posedge clk)
   
	

   always@(*) 
     begin 
	t_read_port_1 = 32'd0; 
	case(read_ptr_1) 
	  5'd0:
	    begin 
	       t_read_port_1 = r0;
	    end 
	  
	  5'd1:
	    begin 
	       t_read_port_1 = r1;
	    end 
	  
	  5'd2:
	    begin 
	       t_read_port_1 = r2;
	    end 
	  
	  5'd3:
	    begin 
	       t_read_port_1 = r3;
	    end 
	  
	  5'd4:
	    begin 
	       t_read_port_1 = r4;
	    end 
	  
	  5'd5:
	    begin 
	       t_read_port_1 = r5;
	    end 
	  
	  5'd6:
	    begin 
	       t_read_port_1 = r6;
	    end 
	  
	  5'd7:
	    begin 
	       t_read_port_1 = r7;
	    end 
	  
	  5'd8:
	    begin 
	       t_read_port_1 = r8;
	    end 
	  
	  5'd9:
	    begin 
	       t_read_port_1 = r9;
	    end 
	  
	  5'd10:
	    begin 
	       t_read_port_1 = r10;
	    end 
	  
	  5'd11:
	    begin 
	       t_read_port_1 = r11;
	    end 
	  
	  5'd12:
	    begin 
	       t_read_port_1 = r12;
	    end 
	  
	  5'd13:
	    begin 
	       t_read_port_1 = r13;
	    end 
	  
	  5'd14:
	    begin 
	       t_read_port_1 = r14;
	    end 
	  
	  5'd15:
	    begin 
	       t_read_port_1 = r15;
	    end 
	  
	  5'd16:
	    begin 
	       t_read_port_1 = r16;
	    end 
	  
	  5'd17:
	    begin 
	       t_read_port_1 = r17;
	    end 
	  
	  5'd18:
	    begin 
	       t_read_port_1 = r18;
	    end 
	  
	  5'd19:
	    begin 
	       t_read_port_1 = r19;
	    end 
	  
	  5'd20:
	    begin 
	       t_read_port_1 = r20;
	    end 
	  
	  5'd21:
	    begin 
	       t_read_port_1 = r21;
	    end 
	  
	  5'd22:
	    begin 
	       t_read_port_1 = r22;
	    end 
	  
	  5'd23:
	    begin 
	       t_read_port_1 = r23;
	    end 
	  
	  5'd24:
	    begin 
	       t_read_port_1 = r24;
	    end 
	  
	  5'd25:
	    begin 
	       t_read_port_1 = r25;
	    end 
	  
	  5'd26:
	    begin 
	       t_read_port_1 = r26;
	    end 
	  
	  5'd27:
	    begin 
	       t_read_port_1 = r27;
	    end 
	  
	  5'd28:
	    begin 
	       t_read_port_1 = r28;
	    end 
	  
	  5'd29:
	    begin 
	       t_read_port_1 = r29;
	    end 
	  
	  5'd30:
	    begin 
	       t_read_port_1 = r30;
	    end 
	  
	  5'd31:
	    begin 
	       t_read_port_1 = r31;
	    end 
	  
	endcase 
     end 


   always@(*) 
     begin 
	t_read_port_2 = 32'd0; 
	case(read_ptr_2) 
	  5'd0:
	    begin 
	       t_read_port_2 = r0;
	    end 
	  
	  5'd1:
	    begin 
	       t_read_port_2 = r1;
	    end 
	  
	  5'd2:
	    begin 
	       t_read_port_2 = r2;
	    end 
	  
	  5'd3:
	    begin 
	       t_read_port_2 = r3;
	    end 
	  
	  5'd4:
	    begin 
	       t_read_port_2 = r4;
	    end 
	  
	  5'd5:
	    begin 
	       t_read_port_2 = r5;
	    end 
	  
	  5'd6:
	    begin 
	       t_read_port_2 = r6;
	    end 
	  
	  5'd7:
	    begin 
	       t_read_port_2 = r7;
	    end 
	  
	  5'd8:
	    begin 
	       t_read_port_2 = r8;
	    end 
	  
	  5'd9:
	    begin 
	       t_read_port_2 = r9;
	    end 
	  
	  5'd10:
	    begin 
	       t_read_port_2 = r10;
	    end 
	  
	  5'd11:
	    begin 
	       t_read_port_2 = r11;
	    end 
	  
	  5'd12:
	    begin 
	       t_read_port_2 = r12;
	    end 
	  
	  5'd13:
	    begin 
	       t_read_port_2 = r13;
	    end 
	  
	  5'd14:
	    begin 
	       t_read_port_2 = r14;
	    end 
	  
	  5'd15:
	    begin 
	       t_read_port_2 = r15;
	    end 
	  
	  5'd16:
	    begin 
	       t_read_port_2 = r16;
	    end 
	  
	  5'd17:
	    begin 
	       t_read_port_2 = r17;
	    end 
	  
	  5'd18:
	    begin 
	       t_read_port_2 = r18;
	    end 
	  
	  5'd19:
	    begin 
	       t_read_port_2 = r19;
	    end 
	  
	  5'd20:
	    begin 
	       t_read_port_2 = r20;
	    end 
	  
	  5'd21:
	    begin 
	       t_read_port_2 = r21;
	    end 

	  5'd22:
	    begin 
	       t_read_port_2 = r22;
	    end 
	  
	  5'd23:
	    begin 
	       t_read_port_2 = r23;
	    end 
	  
	  5'd24:
	    begin 
	       t_read_port_2 = r24;
	    end 
	  
	  5'd25:
	    begin 
	       t_read_port_2 = r25;
	    end 
	  
	  5'd26:
	    begin 
	       t_read_port_2 = r26;
	    end 
	  
	  5'd27:
	    begin 
	       t_read_port_2 = r27;
	    end 
	  
	  5'd28:
	    begin 
	       t_read_port_2 = r28;
	    end 
	  
	  5'd29:
	    begin 
	       t_read_port_2 = r29;
	    end 
	  
	  5'd30:
	    begin 
	       t_read_port_2 = r30;
	    end 
	  
	  5'd31:
	    begin 
	       t_read_port_2 = r31;
	    end 
	  
	endcase // case (read_ptr_2)
     end // always@ (*)
   
endmodule
 
