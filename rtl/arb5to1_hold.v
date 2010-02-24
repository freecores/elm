module arb5to1_hold(/*AUTOARG*/
   // Outputs
   gnt_0, gnt_1, gnt_2, gnt_3, gnt_4, last_gnt0, last_gnt1, last_gnt2,
   last_gnt3, last_gnt4,
   // Inputs
   CLK, rst, req_0, req_1, req_2, req_3, req_4, hold_0, hold_1,
   hold_2, hold_3, hold_4
   );


   input CLK;
   input rst;

   input req_0;
   input req_1;
   input req_2;
   input req_3;
   input req_4;
   
   input hold_0;
   input hold_1;
   input hold_2;
   input hold_3;
   input hold_4;
   
   output gnt_0;
   output gnt_1;
   output gnt_2;
   output gnt_3;
   output gnt_4;
   
   output last_gnt0;
   output last_gnt1;
   output last_gnt2;
   output last_gnt3;
   output last_gnt4;
   
   reg 	  gnt_0;
   reg 	  gnt_1;
   reg 	  gnt_2;
   reg 	  gnt_3;
   reg 	  gnt_4;

   reg 	  last_gnt0;
   reg 	  last_gnt1;
   reg 	  last_gnt2;
   reg 	  last_gnt3;
   reg 	  last_gnt4;

   always@(posedge CLK or posedge rst)
     begin
	if(rst)
	  begin
	     last_gnt0 <= 1'b0;
	     last_gnt1 <= 1'b0;
	     last_gnt2 <= 1'b0;
	     last_gnt3 <= 1'b0;
	     last_gnt4 <= 1'b0;
	  end
	else
	  begin
	     last_gnt0 <= gnt_0;
	     last_gnt1 <= gnt_1;
	     last_gnt2 <= gnt_2;
	     last_gnt3 <= gnt_3;
	     last_gnt4 <= gnt_4;
	  end // else: !if(rst)
     end // always@ (posedge CLK)

   always@(*)
     begin
	if(last_gnt0 & hold_0) begin
	   gnt_0 = 1'b1;
	   gnt_1 = 1'b0;
	   gnt_2 = 1'b0;
	   gnt_3 = 1'b0;
	   gnt_4 = 1'b0;
	end
	else if(last_gnt1& hold_1) begin
	   gnt_0 = 1'b0;
	   gnt_1 = 1'b1;
	   gnt_2 = 1'b0;
	   gnt_3 = 1'b0;
	   gnt_4 = 1'b0;
	end
	else if(last_gnt2 & hold_2) begin
	   gnt_0 = 1'b0;
	   gnt_1 = 1'b0;
	   gnt_2 = 1'b1;
	   gnt_3 = 1'b0;
	   gnt_4 = 1'b0;
	end
	else if(last_gnt3 & hold_3) begin
	   gnt_0 = 1'b0;
	   gnt_1 = 1'b0;
	   gnt_2 = 1'b0;
	   gnt_3 = 1'b1;
	   gnt_4 = 1'b0;
	end
	else if(last_gnt4 & hold_4) begin
	   gnt_0 = 1'b0;
	   gnt_1 = 1'b0;
	   gnt_2 = 1'b0;
	   gnt_3 = 1'b0;
	   gnt_4 = 1'b1;
	end
	else if(last_gnt0 & ~hold_0) begin
	   gnt_1 = req_1;
	   gnt_2 = ~req_1 & req_2;
	   gnt_3 = ~req_1 & ~req_2 & req_3;
	   gnt_4 = ~req_1 & ~req_2 & ~req_3 & req_4;
	   gnt_0 = ~req_1 & ~req_2 & ~req_3 & ~req_4 & req_0;
	end
	else if(last_gnt1 & ~hold_1) begin
	   gnt_2 = req_2;
	   gnt_3 = ~req_2 & req_3;
	   gnt_4 = ~req_2 & ~req_3 & req_4;
	   gnt_0 = ~req_2 & ~req_3 & ~req_4 & req_0;
	   gnt_1 = ~req_2 & ~req_3 & ~req_4 & ~req_0 & req_1;
	end
	else if(last_gnt2 & ~hold_2) begin
	   gnt_3 = req_3;
	   gnt_4 = ~req_3 & req_4;
	   gnt_0 = ~req_3 & ~req_4 & req_0;
	   gnt_1 = ~req_3 & ~req_4 & ~req_0 & req_1;
	   gnt_2 = ~req_3 & ~req_4 & ~req_0 & ~req_1 & req_2;
	end
	else if(last_gnt3 & ~hold_3) begin
	   gnt_4 = req_4;
	   gnt_0 = ~req_4 & req_0;
	   gnt_1 = ~req_4 & ~req_0 & req_1;
	   gnt_2 = ~req_4 & ~req_0 & ~req_1 & req_2;
	   gnt_3 = ~req_4 & ~req_0 & ~req_1 & ~req_2 & req_3;
	end
	else if(last_gnt4 & ~hold_4) begin
	   gnt_0 = req_0;
	   gnt_1 = ~req_0 & req_1;
	   gnt_2 = ~req_0 & ~req_1 & req_2;
	   gnt_3 = ~req_0 & ~req_1 & ~req_2 & req_3;
	   gnt_4 = ~req_0 & ~req_1 & ~req_2 & ~req_3 & req_4;
	end
	else begin
	   gnt_0 = req_0;
	   gnt_1 = ~req_0 & req_1;
	   gnt_2 = ~req_0 & ~req_1 & req_2;
	   gnt_3 = ~req_0 & ~req_1 & ~req_2 & req_3;
	   gnt_4 = ~req_0 & ~req_1 & ~req_2 & ~req_3 & req_4;
	end // else: !if(last_gnt4 & ~hold_4)
     end // always@ (*)
endmodule // arb3to1_hold
