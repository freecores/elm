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

module xp_ptr(/*AUTOARG*/
   // Outputs
   store_data, alu_read_xp_grf_ptr1, alu_read_xp_grf_ptr2,
   xmu_read_xp_grf_ptr1, xmu_read_xp_grf_ptr2, alu_write_xp_grf_ptr,
   xmu_write_xp_grf_ptr,
   // Inputs
   clk, rst, st_rd_from_xprf, store_ptr, store_ptr_valid,
   xmu_load_ptr, xmu_load_ptr_valid, xmu_load_value, alu_load_ptr,
   alu_load_ptr_valid, alu_load_value, alu_read_req_ptr1,
   alu_read_req_ptr2, xmu_read_req_ptr1, xmu_read_req_ptr2,
   alu_read_r1_req, alu_read_r2_req, xmu_read_r1_req, xmu_read_r2_req,
   alu_write_ptr, xmu_write_ptr, alu_write_req, xmu_write_req,
   stall_decode
   );
   input clk;
   input rst;

   input st_rd_from_xprf;
      
   input [2:0] store_ptr;
   input       store_ptr_valid;
   output [31:0] store_data;

   input [6:0] 	 xmu_load_ptr;
   input 	 xmu_load_ptr_valid;
   input [31:0]  xmu_load_value;

   input [6:0] 	 alu_load_ptr;
   input 	 alu_load_ptr_valid;
   input [31:0]  alu_load_value;
      
   input [1:0] 	 alu_read_req_ptr1;
   input [1:0] 	 alu_read_req_ptr2;
   input [1:0] 	 xmu_read_req_ptr1;
   input [1:0] 	 xmu_read_req_ptr2;
 	 	      

   input 	 alu_read_r1_req;
   input 	 alu_read_r2_req;
   input 	 xmu_read_r1_req;
   input 	 xmu_read_r2_req;

   input [1:0] 	 alu_write_ptr;
   input [1:0]	 xmu_write_ptr;

   input 	 alu_write_req;
   input 	 xmu_write_req;

   input 	 stall_decode;
   
   
     
   output [11:0] alu_read_xp_grf_ptr1;
   output [11:0] alu_read_xp_grf_ptr2;
   output [11:0] xmu_read_xp_grf_ptr1;
   output [11:0] xmu_read_xp_grf_ptr2;

   output [11:0] alu_write_xp_grf_ptr;
   output [11:0] xmu_write_xp_grf_ptr;
         


   /* I HATE RTL */
   wire 	 alu_write = alu_write_req;
   wire 	 xmu_write = xmu_write_req & !st_rd_from_xprf;


   wire 	 alu_read_r1_valid = alu_read_r1_req;
   wire 	 alu_read_r2_valid = alu_read_r2_req;
   wire 	 xmu_read_r1_valid = xmu_read_r1_req;
   wire 	 xmu_read_r2_valid = st_rd_from_xprf | xmu_read_r2_req;
   
   wire [1:0] 	 alu_read_ptr1 = alu_read_req_ptr1;
   wire [1:0] 	 alu_read_ptr2 = alu_read_req_ptr2;
   wire [1:0] 	 xmu_read_ptr1 = xmu_read_req_ptr1;
   
   wire [1:0]	 xmu_read_ptr2 = st_rd_from_xprf ? xmu_write_ptr : xmu_read_req_ptr2;
   
   
   
   
   wire      ar1_ar2 = (alu_read_ptr1 == alu_read_ptr2) &
	     alu_read_r1_valid & alu_read_r2_valid;
   
   wire      ar1_xr1 = (alu_read_ptr1 == xmu_read_ptr1) &
	     alu_read_r1_valid & xmu_read_r1_valid;
   
   wire      ar1_xr2 = (alu_read_ptr1 == xmu_read_ptr2) &
	     alu_read_r1_valid & xmu_read_r2_valid;
   
   wire      ar2_xr1 = (alu_read_ptr2 == xmu_read_ptr1) &
	     alu_read_r2_valid & xmu_read_r1_valid;
   
   wire      ar2_xr2 = (alu_read_ptr2 == xmu_read_ptr2) &
	     alu_read_r2_valid & xmu_read_r2_valid;

   wire      xr1_xr2 = (xmu_read_ptr1 == xmu_read_ptr2) &
	     xmu_read_r1_valid & xmu_read_r2_valid;
   

   wire [3:0] req = {alu_read_r1_valid, alu_read_r2_valid, 
		     xmu_read_r1_valid, xmu_read_r2_valid};
   
   

   reg [1:0] t_rp1;
   reg [1:0] t_rp2;

   reg 	     t_rp1_valid;
   reg 	     t_rp2_valid;

      

   reg [63:0] xp0;
   reg [63:0] xp1;
   reg [63:0] xp2;
   reg [63:0] xp3;


   assign store_data = store_ptr_valid ? ((store_ptr == 3'd0) ? xp0[31:0] :
					  (store_ptr == 3'd1) ? xp0[63:32] :
					  (store_ptr == 3'd2) ? xp1[31:0] :
					  (store_ptr == 3'd3) ? xp1[63:32] :
					  (store_ptr == 3'd4) ? xp2[31:0] :
					  (store_ptr == 3'd5) ? xp2[63:32] :
					  (store_ptr == 3'd6) ? xp3[31:0] :
					  (store_ptr == 3'd7) ? xp3[63:32] :
					  32'd0 ) : 32'd0;
   
  always@(*)
     begin: irf_arbitration
	t_rp1 = 2'd0;
	t_rp2 = 2'd0;

	t_rp1_valid = 1'b0;
	t_rp2_valid = 1'b0;
		
	case(req)
	  
	  4'b0001:
	    begin
	       t_rp1 = xmu_read_ptr2;
	       t_rp1_valid = 1'b1;
	       
	    end

	  4'b0010:
	    begin
	       t_rp1 = xmu_read_ptr1;
	       t_rp1_valid = 1'b1;
	    end
	  
	  4'b0011:
	    begin
	       t_rp1 = xmu_read_ptr1;
	       t_rp2 = xmu_read_ptr2;

	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;	       
	    end	   

	  4'b0100:
	    begin
	       t_rp1 = alu_read_ptr2;
	       t_rp1_valid = 1'b1;
	       
	    end
	  
	  4'b0101:
	    begin
	       t_rp1 = xmu_read_ptr2;
	       t_rp2 = alu_read_ptr2;

	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	    end	  	  

	  4'b0110:
	    begin
	       t_rp1 = xmu_read_ptr1;
	       t_rp2 = alu_read_ptr2;

	       
	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	    end

	  4'b0111:
	    begin
		    
	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	       
	       //alu register2 and xmu register 1 are the same
	       if(ar2_xr1)
		 begin
		    t_rp1 = alu_read_ptr2;
		    t_rp2 = xmu_read_ptr2;
		 end

	       else if(ar2_xr2)
		 begin
		    t_rp1 = alu_read_ptr2;
		    t_rp2 = xmu_read_ptr1;
		 end

	       else //if(xr1_xr2)
		 begin
		    t_rp1 = alu_read_ptr2;
		    t_rp2 = xmu_read_ptr1;
		 end
	    end

	  4'b1000:
	    begin
	       t_rp1 = alu_read_ptr1;
	       t_rp1_valid = 1'b1;
	       
	    end

	  
	  4'b1001:
	    begin
	       t_rp1 = alu_read_ptr1;
	       t_rp2 = xmu_read_ptr2;

	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	    end
	  
	  4'b1010:
	    begin
	       t_rp1 = alu_read_ptr1;
	       t_rp2 = xmu_read_ptr1;

	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	    end

	  4'b1011:
	    begin	 
	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
      
	       if(ar1_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr2;
		 end

	       else if(ar1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr1;
		 end

	       else //if(xr1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr1;
		 end
	    end // case: 4'b1011

	    

	  4'b1100:
	    begin
	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	       
	       t_rp1 = alu_read_ptr1;
	       t_rp2 = alu_read_ptr2;
	    end // case: 4'b1100


	  4'b1101:
	    begin
	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	       
	       if(ar1_ar2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr2;
		 end

	       else if(ar1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;
		 end

	       else //if(ar2_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;
		 end
	    end // case: 4'b1101


	  4'b1110:
	    begin
	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;

	       if(ar1_ar2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr1;
		 end

	       else if(ar1_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;
		 end

	       else //if(ar2_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;
		 end // else: !if(ar1_xr1)
	    end // case: 4'b1110


	  4'b1111:
	    begin
	       t_rp1_valid = 1'b1;
	       t_rp2_valid = 1'b1;
	       
	       if(ar1_ar2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    if(xr1_xr2)
		      begin
			 t_rp2 = xmu_read_ptr2;
		      end

		    else if(ar2_xr1)
		      begin
			 t_rp2 = xmu_read_ptr2;
		      end
		    
		    else //if(ar2_xr2)
		      begin
			 t_rp2 = xmu_read_ptr1;
		      end // else: !if(ar2_xr1)
		 end // if (ar1_ar2)

	       else if(ar1_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;
		    
		    if(xr1_xr2)
		      begin
			 t_rp2 = alu_read_ptr2;
		      end

		    else if(ar2_xr1)
		      begin
			 t_rp2 = xmu_read_ptr2;
		      end

		    else //if(ar2_xr2)
		      begin
			 t_rp2 = alu_read_ptr2;
		      end // else: !if(ar2_xr1)
		 end // if (ar1_xr1)

	       else //if(ar1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    
		    if(xr1_xr2)
		      begin
			 t_rp2 = alu_read_ptr2;
		      end

		    else if(ar2_xr1)
		      begin
			 t_rp2 = alu_read_ptr2;
		      end

		    else //if(ar2_xr2)
		      begin
			 t_rp2 = xmu_read_ptr1;		 
		      end // else: !if(ar2_xr1)
		    		    
		 end // else: !if(ar1_xr1)
	    end // case: 4'b1111
	  default: begin
	     t_rp1 = 2'd0;
	     t_rp2 = 2'd0;
	     t_rp1_valid = 1'b0;
	     t_rp2_valid = 1'b0;
	  end
	endcase // case (req)
     end // block: grf_arbitration
      

   wire [11:0] xp0_write_ptr = xp0[11:0];
   wire [11:0] xp1_write_ptr = xp1[11:0];
   wire [11:0] xp2_write_ptr = xp2[11:0];
   wire [11:0] xp3_write_ptr = xp3[11:0];

   wire [11:0] xp0_read_ptr = xp0[27:16];
   wire [11:0] xp1_read_ptr = xp1[27:16];
   wire [11:0] xp2_read_ptr = xp2[27:16];
   wire [11:0] xp3_read_ptr = xp3[27:16];

   wire [3:0] xp0_write_incr = xp0[15:12];
   wire [3:0] xp1_write_incr = xp1[15:12]; 
   wire [3:0] xp2_write_incr = xp2[15:12];
   wire [3:0] xp3_write_incr = xp3[15:12];

   wire [3:0] xp0_read_incr = xp0[31:28];
   wire [3:0] xp1_read_incr = xp1[31:28]; 
   wire [3:0] xp2_read_incr = xp2[31:28];
   wire [3:0] xp3_read_incr = xp3[31:28];

   wire [11:0] xp0_base = xp0[59:48];
   wire [11:0] xp1_base = xp1[59:48];
   wire [11:0] xp2_base = xp2[59:48];
   wire [11:0] xp3_base = xp3[59:48];

   wire [11:0] xp0_limit = xp0[43:32];
   wire [11:0] xp1_limit = xp1[43:32];
   wire [11:0] xp2_limit = xp2[43:32];
   wire [11:0] xp3_limit = xp3[43:32];

   /*
   output [11:0] alu_read_xp_grf_ptr1;
   output [11:0] alu_read_xp_grf_ptr2;
   output [11:0] xmu_read_xp_grf_ptr1;
   output [11:0] xmu_read_xp_grf_ptr2;
    */


   wire [11:0] w_rp0_read =
	       (t_rp1 == 2'd0) ? xp0_read_ptr :
	       (t_rp1 == 2'd1) ? xp1_read_ptr :
	       (t_rp1 == 2'd2) ? xp2_read_ptr :
	       xp3_read_ptr;

   wire [11:0] w_rp1_read =
	       (t_rp2 == 2'd0) ? xp0_read_ptr :
	       (t_rp2 == 2'd1) ? xp1_read_ptr :
	       (t_rp2 == 2'd2) ? xp2_read_ptr :
	       xp3_read_ptr;
   
   

   assign alu_read_xp_grf_ptr1 = alu_read_r1_valid ? ((alu_read_ptr1 == t_rp1) ?
				 w_rp0_read :
				 (alu_read_ptr1 == t_rp2) ?
				 w_rp1_read :
				 12'd0) : 12'd0;

   
   assign alu_read_xp_grf_ptr2 = alu_read_r2_valid ? ((alu_read_ptr2 == t_rp1) ?
				 w_rp0_read :
				 (alu_read_ptr2 == t_rp2) ?
				 w_rp1_read :
				 12'd0) : 12'd0;


   assign xmu_read_xp_grf_ptr1 = xmu_read_r1_valid ? ((xmu_read_ptr1 == t_rp1) ?
						      w_rp0_read :
						      (xmu_read_ptr1 == t_rp2) ?
						      w_rp1_read :
						      12'd0) : 12'd0;

   
   assign xmu_read_xp_grf_ptr2 = xmu_read_r2_valid ? ((xmu_read_ptr2 == t_rp1) ?
						      w_rp0_read :
						      (xmu_read_ptr2 == t_rp2) ?
						      w_rp1_read :
						      12'd0) : 12'd0;


   assign alu_write_xp_grf_ptr = (alu_write_ptr == 2'd0) ?
				 xp0_write_ptr :
				 (alu_write_ptr == 2'd1) ?
				 xp1_write_ptr :
				 (alu_write_ptr == 2'd2) ?
				 xp2_write_ptr :
				 xp3_write_ptr;





   wire [11:0] xmu_write_xp_write_ptr = 
	       (xmu_write_ptr == 2'd0) ?
	       xp0_write_ptr :
	       (xmu_write_ptr == 2'd1) ?
	       xp1_write_ptr :
	       (xmu_write_ptr == 2'd2) ?
	       xp2_write_ptr :
	       xp3_write_ptr;

   wire [11:0] xmu_st_rd_xprf_oh11 =
	       (xmu_write_ptr == 2'd0) ?
	       xp0_read_ptr :
	       (xmu_write_ptr == 2'd1) ?
	       xp1_read_ptr :
	       (xmu_write_ptr == 2'd2) ?
	       xp2_read_ptr :
	       xp3_read_ptr;


   
   assign xmu_write_xp_grf_ptr = st_rd_from_xprf ?
				 xmu_st_rd_xprf_oh11 :
				 xmu_write_xp_write_ptr;
      

  
   wire bump_xp0_read = t_rp1_valid & (t_rp1 == 2'd0) |
	t_rp2_valid & (t_rp2 == 2'd0);

   wire bump_xp1_read = t_rp1_valid & (t_rp1 == 2'd1) |
	t_rp2_valid & (t_rp2 == 2'd1);

   wire bump_xp2_read = t_rp1_valid & (t_rp1 == 2'd2) |
	t_rp2_valid & (t_rp2 == 2'd2);

   wire bump_xp3_read = t_rp1_valid & (t_rp1 == 2'd3) |
	t_rp2_valid & (t_rp2 == 2'd3);

   wire bump_xp0_write = alu_write & (alu_write_ptr == 2'd0) |
	xmu_write & (xmu_write_ptr == 2'd0);
   
   wire bump_xp1_write = alu_write & (alu_write_ptr == 2'd1) |
	xmu_write & (xmu_write_ptr == 2'd1);
  
   wire bump_xp2_write = alu_write & (alu_write_ptr == 2'd2) |
	xmu_write & (xmu_write_ptr == 2'd2);

   wire bump_xp3_write = alu_write & (alu_write_ptr == 2'd3) |
	xmu_write & (xmu_write_ptr == 2'd3);  

   wire [11:0] next_xp0_read = bump_xp0_read ? xp0_read_ptr + xp0_read_incr :
	       xp0_read_ptr;
   
   wire [11:0] next_xp1_read = bump_xp1_read ? xp1_read_ptr + xp1_read_incr :
	       xp1_read_ptr;
   
   wire [11:0] next_xp2_read = bump_xp2_read ? xp2_read_ptr + xp2_read_incr :
	       xp2_read_ptr;
   
   wire [11:0] next_xp3_read = bump_xp3_read ? xp3_read_ptr + xp3_read_incr :
	       xp3_read_ptr;

   wire [11:0] next_xp0_write = bump_xp0_write ? xp0_write_ptr + xp0_write_incr 
	       : xp0_write_ptr;
   
   wire [11:0] next_xp1_write = bump_xp1_write ? xp1_write_ptr + xp1_write_incr
	       : xp1_write_ptr;
   
   wire [11:0] next_xp2_write = bump_xp2_write ? xp2_write_ptr + xp2_write_incr
	       : xp2_write_ptr;
   
   wire [11:0] next_xp3_write = bump_xp3_write ? xp3_write_ptr + xp3_write_incr 
	       : xp3_write_ptr;


   wire        xp0_read_wrap = (next_xp0_read > xp0_limit) & bump_xp0_read;
   wire        xp1_read_wrap = (next_xp1_read > xp1_limit) & bump_xp1_read;
   wire        xp2_read_wrap = (next_xp2_read > xp2_limit) & bump_xp2_read;
   wire        xp3_read_wrap = (next_xp3_read > xp3_limit) & bump_xp3_read;    
   
   wire [11:0] xp0_read = xp0_read_wrap ? xp0_base :
	       next_xp0_read;
   
   wire [11:0] xp1_read = xp1_read_wrap ? xp1_base :
	       next_xp1_read;
   
   wire [11:0] xp2_read = xp2_read_wrap ? xp2_base :
	       next_xp2_read;
   
   wire [11:0] xp3_read = xp3_read_wrap ? xp3_base :
	       next_xp3_read;


   wire [11:0] xp0_write = (bump_xp0_write & (next_xp0_write > xp0_limit)) ? xp0_base :
	       next_xp0_write;
   
   wire [11:0] xp1_write = (bump_xp1_write & (next_xp1_write > xp1_limit)) ? xp1_base :
	       next_xp1_write;
   
   wire [11:0] xp2_write = (bump_xp2_write & (next_xp2_write > xp2_limit)) ? xp2_base :
	       next_xp2_write;
   
   wire [11:0] xp3_write = (bump_xp3_write & (next_xp3_write > xp3_limit)) ? xp3_base :
	       next_xp3_write;


   wire        xmu_load_xp0_lo = (xmu_load_ptr == `XPL0) & xmu_load_ptr_valid;
   wire        xmu_load_xp0_hi = (xmu_load_ptr == `XPU0) & xmu_load_ptr_valid;
   
   wire        xmu_load_xp1_lo = (xmu_load_ptr == `XPL1) & xmu_load_ptr_valid;
   wire        xmu_load_xp1_hi = (xmu_load_ptr == `XPU1) & xmu_load_ptr_valid;
   
   wire        xmu_load_xp2_lo = (xmu_load_ptr == `XPL2) & xmu_load_ptr_valid;
   wire        xmu_load_xp2_hi = (xmu_load_ptr == `XPU2) & xmu_load_ptr_valid;

   wire        xmu_load_xp3_lo = (xmu_load_ptr == `XPL3) & xmu_load_ptr_valid;
   wire        xmu_load_xp3_hi = (xmu_load_ptr == `XPU3) & xmu_load_ptr_valid;


   wire        alu_load_xp0_lo = (alu_load_ptr == `XPL0) & alu_load_ptr_valid;
   wire        alu_load_xp0_hi = (alu_load_ptr == `XPU0) & alu_load_ptr_valid;
   
   wire        alu_load_xp1_lo = (alu_load_ptr == `XPL1) & alu_load_ptr_valid;
   wire        alu_load_xp1_hi = (alu_load_ptr == `XPU1) & alu_load_ptr_valid;
   
   wire        alu_load_xp2_lo = (alu_load_ptr == `XPL2) & alu_load_ptr_valid;
   wire        alu_load_xp2_hi = (alu_load_ptr == `XPU2) & alu_load_ptr_valid;

   wire        alu_load_xp3_lo = (alu_load_ptr == `XPL3) & alu_load_ptr_valid;
   wire        alu_load_xp3_hi = (alu_load_ptr == `XPU3) & alu_load_ptr_valid;


 

   wire xp0_load_active = 
   	xmu_load_xp0_lo | xmu_load_xp0_hi |
	alu_load_xp0_lo | alu_load_xp0_hi;

   wire xp1_load_active = 
   	xmu_load_xp1_lo | xmu_load_xp1_hi |
	alu_load_xp1_lo | alu_load_xp1_hi;
   
   wire xp2_load_active = 
   	xmu_load_xp2_lo | xmu_load_xp2_hi |
	alu_load_xp2_lo | alu_load_xp2_hi;

   wire xp3_load_active = 
   	xmu_load_xp3_lo | xmu_load_xp3_hi |
	alu_load_xp3_lo | alu_load_xp3_hi;


   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     xp0 <= 64'h0;
	     
		   //64'h0006001230062006;
	  end
	else if(xp0_load_active)
	  begin
		  xp0[31:0]  <= xmu_load_xp0_lo ? xmu_load_value :
				alu_load_xp0_lo ? alu_load_value :
				xp0[31:0];
		  
		  xp0[63:32] <= xmu_load_xp0_hi ? xmu_load_value :
				alu_load_xp0_hi ? alu_load_value :
				xp0[63:32]; 
	  end	
	else if(!stall_decode)
	  begin
	     xp0 <= {4'd0, xp0_base, 4'd0, xp0_limit, xp0_read_incr,
		     xp0_read, xp0_write_incr, xp0_write};
	  end // else: !if(xp0_load_active)
	else
	  begin
	     xp0 <= xp0;
	  end // else: !if(!stall_decode)
     end // always@ (posedge clk)


    always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     xp1 <= 64'h0;
	  end
	else if(xp1_load_active)
	  begin
	     xp1[31:0]  <= xmu_load_xp1_lo ? xmu_load_value :
			   alu_load_xp1_lo ? alu_load_value :
			   xp1[31:0];
	     
	     xp1[63:32] <= xmu_load_xp1_hi ? xmu_load_value :
			   alu_load_xp1_hi ? alu_load_value :
			   xp1[63:32];
	  end
    	else if(!stall_decode)
	  begin
	     xp1 <= {4'd0, xp1_base, 4'd0, xp1_limit, xp1_read_incr,
		     xp1_read, xp1_write_incr, xp1_write};
	  end // else: !if(xp1_load_active)
    	else
	  begin
	     xp1 <= xp1;
	  end // else: !if(!stall_decode)
     end // always@ (posedge clk)


   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     xp2 <= 64'h0;
	  end
	else if(xp2_load_active)
	  begin
	     xp2[31:0]  <= xmu_load_xp2_lo ? xmu_load_value :
			   alu_load_xp2_lo ? alu_load_value :
			   xp2[31:0];
	     
	     xp2[63:32] <= xmu_load_xp2_hi ? xmu_load_value :
			   alu_load_xp2_hi ? alu_load_value :
			   xp2[63:32];  
	  end
	else if(!stall_decode)
	  begin
	     xp2 <= {4'd0, xp2_base, 4'd0, xp2_limit, xp2_read_incr,
		     xp2_read, xp2_write_incr, xp2_write};
	  end // else: !if(xp2_load_active)
	else
	  begin
	     xp2 <= xp2;
	  end // else: !if(!stall_decode)
     end // always@ (posedge clk)		  

   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     xp3 <= 64'h0;
	  end
	else if(xp3_load_active)
	  begin
	     xp3[31:0]  <= xmu_load_xp3_lo ? xmu_load_value :
				alu_load_xp3_lo ? alu_load_value :
			   xp3[31:0];
	     
	     xp3[63:32] <= xmu_load_xp3_hi ? xmu_load_value :
			   alu_load_xp3_hi ? alu_load_value :
			   xp3[63:32];  
	  end
	
	else if(!stall_decode)
	  
	  begin
	     xp3 <= {4'd0, xp3_base, 4'd0, xp3_limit, xp3_read_incr,
		     xp3_read, xp3_write_incr, xp3_write};
	  end // else: !if(xp3_load_active)
	else
	  begin
	     xp3 <= xp3;
	  end // else: !if(!stall_decode)
     end // always@ (posedge clk)
   
    
endmodule // irf_ptr
