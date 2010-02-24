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


module grf(/*AUTOARG*/
   // Outputs
   alu_read_value1, alu_read_value2, xmu_read_value1, xmu_read_value2,
   alu_read_valid1, alu_read_valid2, xmu_read_valid1, xmu_read_valid2,
   grf_complete_non_block_load,
   // Inputs
   clk, rst, alu_read_ptr1, alu_read_ptr2, xmu_read_ptr1,
   xmu_read_ptr2, alu_read_r1_valid, alu_read_r2_valid,
   xmu_read_r1_valid, xmu_read_r2_valid, alu_write_ptr,
   alu_write_valid, xmu_write_ptr, xmu_write_valid, alu_write_value,
   xmu_write_value, xmu_invalidate_ptr, xmu_invalidate_valid,
   non_block_load_data, non_block_load_data_valid
   );
   input clk;
   input rst;




   input [4:0] alu_read_ptr1;
   input [4:0] alu_read_ptr2;
   input [4:0] xmu_read_ptr1;
   input [4:0] xmu_read_ptr2;

   input       alu_read_r1_valid;
   input       alu_read_r2_valid;
   input       xmu_read_r1_valid;
   input       xmu_read_r2_valid;

   output [31:0] alu_read_value1;
   output [31:0] alu_read_value2;
   output [31:0] xmu_read_value1;
   output [31:0] xmu_read_value2;

   output 	 alu_read_valid1;
   output 	 alu_read_valid2;
   output 	 xmu_read_valid1;
   output 	 xmu_read_valid2;

   output 	 grf_complete_non_block_load;
   
   
   input [4:0] alu_write_ptr;
   input       alu_write_valid;

   input [4:0] xmu_write_ptr;
   input       xmu_write_valid;

   input [31:0] alu_write_value;
   input [31:0] xmu_write_value;


   input [4:0] 	xmu_invalidate_ptr;
   input 	xmu_invalidate_valid;
     
   input [31:0] non_block_load_data;
   input 	non_block_load_data_valid;
   
   
   reg valid_vector [31:0];


   reg [4:0] invalid_register_ptr;
   reg 	     invalid_register;
   

   assign alu_read_valid1 = valid_vector[alu_read_ptr1];
   assign alu_read_valid2 = valid_vector[alu_read_ptr2];
   assign xmu_read_valid1 = valid_vector[xmu_read_ptr1];
   assign xmu_read_valid2 = valid_vector[xmu_read_ptr2];



   reg [4:0] t_rp1;
   reg [4:0] t_rp2;

   
   reg [31:0] t_a_r1;
   reg [31:0] t_a_r2;
   reg [31:0] t_x_r1;
   reg [31:0] t_x_r2;  
 
    
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
   

   assign alu_read_value1 = t_a_r1;
   assign alu_read_value2 = t_a_r2;
   assign xmu_read_value1 = t_x_r1;
   assign xmu_read_value2 = t_x_r2;


   wire [31:0] rf_read_port1_out;
   wire [31:0] rf_read_port2_out;  


   wire        non_block_ld_complete =
	       non_block_load_data_valid &
	       invalid_register &
	       !xmu_write_valid;

   assign grf_complete_non_block_load = non_block_ld_complete;
   
   
   wire [31:0] xmu_write_mux = 
	       non_block_ld_complete ?
	       non_block_load_data :
	       xmu_write_value;

   wire        xmu_write_mux_valid = 
	       xmu_write_valid | 
	       non_block_ld_complete;

   wire [4:0] xmu_write_mux_ptr =
	      non_block_ld_complete ?
	      invalid_register_ptr :
	      xmu_write_ptr;
   
   
   
   rf_ff rf(
   
   /*rf_latch rf(*/
	    // Outputs
	    .read_port_1		(rf_read_port1_out),
	    .read_port_2		(rf_read_port2_out),
	    // Inputs
	    .clk			(clk),
	    .rst                        (rst),
	    .write_ptr_1		(alu_write_ptr),
	    .write_ptr_2		(xmu_write_mux_ptr),
	    .read_ptr_1			(t_rp1),
	    .read_ptr_2			(t_rp2),
	    .write_ptr_1_valid		(alu_write_valid),
	    .write_ptr_2_valid		(xmu_write_mux_valid),
	    .write_port_1		(alu_write_value),
	    .write_port_2		(xmu_write_mux)
	    );

   

   
   always@(*)
     begin: grf_arbitration
	t_rp1 = 5'd0;
	t_rp2 = 5'd0;

	t_a_r1 = 32'd0;
	t_a_r2 = 32'd0;
	
	t_x_r1 = 32'd0;
	t_x_r2 = 32'd0;
	
	case(req)
	  
	  4'b0001:
	    begin
	       t_rp1 = xmu_read_ptr2;
	       t_x_r2 = rf_read_port1_out;
	    end

	  4'b0010:
	    begin
	       t_rp1 = xmu_read_ptr1;
	       t_x_r1 = rf_read_port1_out;
	    end
	  
	  4'b0011:
	    begin
	       t_rp1 = xmu_read_ptr1;
	       t_rp2 = xmu_read_ptr2;
	       t_x_r1 = rf_read_port1_out;
	       t_x_r2 = rf_read_port2_out;
	    end	   

	  4'b0100:
	    begin
	       t_rp1 = alu_read_ptr2;
	       t_a_r2 = rf_read_port1_out;
	    end
	  
	  4'b0101:
	    begin
	       t_rp1 = xmu_read_ptr2;
	       t_rp2 = alu_read_ptr2;
	       t_x_r2 = rf_read_port1_out;
	       t_a_r2 = rf_read_port2_out;
	    end	  	  

	  4'b0110:
	    begin
	       t_rp1 = xmu_read_ptr1;
	       t_rp2 = alu_read_ptr2;
	       t_x_r1 = rf_read_port1_out;
	       t_a_r2 = rf_read_port2_out;
	    end

	  4'b0111:
	    begin

	       //alu register2 and xmu register 1 are the same
	       if(ar2_xr1)
		 begin
		    t_rp1 = alu_read_ptr2;
		    t_rp2 = xmu_read_ptr2;
		    
		    t_a_r2 = rf_read_port1_out;
		    t_x_r1 = rf_read_port1_out;
		    t_x_r2 = rf_read_port2_out;
			    
		 end

	       else if(ar2_xr2)
		 begin
		    t_rp1 = alu_read_ptr2;
		    t_rp2 = xmu_read_ptr1;

		    t_a_r2 = rf_read_port1_out;
		    t_x_r1 = rf_read_port2_out;
		    t_x_r2 = rf_read_port1_out;
		 end

	       else //if(xr1_xr2)
		 begin
		    t_rp1 = alu_read_ptr2;
		    t_rp2 = xmu_read_ptr1;

		    t_a_r2 = rf_read_port1_out;
		    t_x_r1 = rf_read_port2_out;
		    t_x_r2 = rf_read_port2_out;
		 end
	    end

	  4'b1000:
	    begin
	       t_rp1 = alu_read_ptr1;
	       t_a_r1 = rf_read_port1_out;
	    end

	  
	  4'b1001:
	    begin
	       t_rp1 = alu_read_ptr1;
	       t_a_r1 = rf_read_port1_out;
	       t_rp2 = xmu_read_ptr2;
	       t_x_r2 = rf_read_port2_out;
	    end
	  
	  4'b1010:
	    begin
	       t_rp1 = alu_read_ptr1;
	       t_a_r1 = rf_read_port1_out;

	       t_rp2 = xmu_read_ptr1;
	       t_x_r1 = rf_read_port2_out;
	    end

	  4'b1011:
	    begin
	       
	       if(ar1_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr2;
		    
		    t_a_r1 = rf_read_port1_out;
		    t_x_r1 = rf_read_port1_out;
		    t_x_r2 = rf_read_port2_out;
			    
		 end

	       else if(ar1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr1;

		    t_a_r1 = rf_read_port1_out;
		    t_x_r1 = rf_read_port2_out;
		    t_x_r2 = rf_read_port1_out;
		 end

	       else //if(xr1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr1;

		    t_a_r1 = rf_read_port1_out;
		    t_x_r1 = rf_read_port2_out;
		    t_x_r2 = rf_read_port2_out;
		 end
	    end // case: 4'b1011

	    

	  4'b1100:
	    begin

	       t_rp1 = alu_read_ptr1;
	       t_rp2 = alu_read_ptr2;
	       	       
	       t_a_r1 = rf_read_port1_out;
	       t_a_r2 = rf_read_port2_out;
	    end // case: 4'b1100


	  4'b1101:
	    begin

	       if(ar1_ar2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr2;

		    t_a_r1 = rf_read_port1_out;
		    t_a_r2 = rf_read_port1_out;
		    
		    t_x_r2 = rf_read_port2_out;
		 end

	       else if(ar1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;

		    t_a_r1 = rf_read_port1_out;
		    t_a_r2 = rf_read_port2_out;

		    t_x_r2 = rf_read_port1_out;
		 end

	       else //if(ar2_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;

		    t_a_r1 = rf_read_port1_out;
		    t_a_r2 = rf_read_port2_out;

		    t_x_r2 = rf_read_port2_out;
		 end
	    end // case: 4'b1101


	  4'b1110:
	    begin

	       if(ar1_ar2)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = xmu_read_ptr1;

		    t_a_r1 = rf_read_port1_out;
		    t_a_r2 = rf_read_port1_out;
		    
		    t_x_r1 = rf_read_port2_out;
		 end

	       else if(ar1_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;

		    t_a_r1 = rf_read_port1_out;
		    t_a_r2 = rf_read_port2_out;

		    t_x_r1 = rf_read_port1_out;
		 end

	       else //if(ar2_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;
		    t_rp2 = alu_read_ptr2;

		    t_a_r1 = rf_read_port1_out;
		    t_a_r2 = rf_read_port2_out;

		    t_x_r1 = rf_read_port2_out;

		 end // else: !if(ar1_xr1)
	    end // case: 4'b1110


	  4'b1111:
	    begin
	       
	       if(ar1_ar2)
		 begin
		    t_rp1 = alu_read_ptr1;

		    t_a_r1 = rf_read_port1_out;
		    t_a_r2 = rf_read_port1_out;

		    if(xr1_xr2)
		      begin
			 t_rp2 = xmu_read_ptr2;

			 t_x_r1 = rf_read_port2_out;
			 t_x_r2 = rf_read_port2_out;
		      end

		    else if(ar2_xr1)
		      begin
			 t_rp2 = xmu_read_ptr2;

			 t_x_r1 = rf_read_port1_out;
			 t_x_r2 = rf_read_port2_out;
		      end
		    
		    else //if(ar2_xr2)
		      begin
			 t_rp2 = xmu_read_ptr1;
			 t_x_r1 = rf_read_port2_out;
			 t_x_r2 = rf_read_port1_out;
		      end // else: !if(ar2_xr1)
		 end // if (ar1_ar2)

	       else if(ar1_xr1)
		 begin
		    t_rp1 = alu_read_ptr1;

		    t_a_r1 = rf_read_port1_out;
		    t_x_r1 = rf_read_port1_out;

		    if(xr1_xr2)
		      begin
			 t_rp2 = alu_read_ptr2;

			 t_a_r2 = rf_read_port2_out;
			 t_x_r2 = rf_read_port1_out;
		      end

		    else if(ar2_xr1)
		      begin
			 t_rp2 = xmu_read_ptr2;

			 t_a_r2 = rf_read_port1_out;
			 t_x_r2 = rf_read_port2_out;
			 
		      end

		    else //if(ar2_xr2)
		      begin
			 t_rp2 = alu_read_ptr2;
			 t_a_r2 = rf_read_port2_out;
			 t_x_r2 = rf_read_port2_out;
		      end // else: !if(ar2_xr1)
		 end // if (ar1_xr1)

	       else //if(ar1_xr2)
		 begin
		    t_rp1 = alu_read_ptr1;

		    t_a_r1 = rf_read_port1_out;
		    t_x_r2 = rf_read_port1_out;
		    
		    if(xr1_xr2)
		      begin
			 t_rp2 = alu_read_ptr2;

			 t_a_r2 = rf_read_port2_out;
			 t_x_r1 = rf_read_port1_out;
		      end

		    else if(ar2_xr1)
		      begin
			 t_rp2 = alu_read_ptr2;

			 t_a_r2 = rf_read_port2_out;
			 t_x_r1 = rf_read_port2_out;
		      end

		    else //if(ar2_xr2)
		      begin
			 t_rp2 = xmu_read_ptr1;
			 
			 t_x_r1 = rf_read_port2_out;
			 t_a_r2 = rf_read_port1_out;
								 
		      end // else: !if(ar2_xr1)
		    		    
		 end // else: !if(ar1_xr1)
	    end // case: 4'b1111
	  default: begin
	     t_rp1 = 5'd0;
	     t_rp2 = 5'd0;
	     
	     t_a_r1 = 32'd0;
	     t_a_r2 = 32'd0;
	     
	     t_x_r1 = 32'd0;
	     t_x_r2 = 32'd0;
	  end
	endcase // case (req)
     end
   
 
   always@(posedge clk or posedge rst)
     begin: valid_vector_register
	if(rst)
	  begin
	     valid_vector[5'd0] <= 1'b1;
	     valid_vector[5'd1] <= 1'b1;
	     valid_vector[5'd2] <= 1'b1;
	     valid_vector[5'd3] <= 1'b1;
	     valid_vector[5'd4] <= 1'b1;
	     valid_vector[5'd5] <= 1'b1;
	     valid_vector[5'd6] <= 1'b1;
	     valid_vector[5'd7] <= 1'b1;
	     valid_vector[5'd8] <= 1'b1;
	     valid_vector[5'd9] <= 1'b1;
	     valid_vector[5'd10] <= 1'b1;
	     valid_vector[5'd11] <= 1'b1;
	     valid_vector[5'd12] <= 1'b1;
	     valid_vector[5'd13] <= 1'b1;
	     valid_vector[5'd14] <= 1'b1;
	     valid_vector[5'd15] <= 1'b1;
	     valid_vector[5'd16] <= 1'b1;
	     valid_vector[5'd17] <= 1'b1;
	     valid_vector[5'd18] <= 1'b1;
	     valid_vector[5'd19] <= 1'b1;
	     valid_vector[5'd20] <= 1'b1;
	     valid_vector[5'd21] <= 1'b1;
	     valid_vector[5'd22] <= 1'b1;
	     valid_vector[5'd23] <= 1'b1;
	     valid_vector[5'd24] <= 1'b1;
	     valid_vector[5'd25] <= 1'b1;
	     valid_vector[5'd26] <= 1'b1;
	     valid_vector[5'd27] <= 1'b1;
	     valid_vector[5'd28] <= 1'b1;
	     valid_vector[5'd29] <= 1'b1;
	     valid_vector[5'd30] <= 1'b1;
	     valid_vector[5'd31] <= 1'b1;	     
	  end
	else
	  begin
	     if(xmu_invalidate_valid)
	       valid_vector[xmu_invalidate_ptr]<= 1'b0;
	     else if(non_block_ld_complete)
	       valid_vector[invalid_register_ptr] <= 1'b1;
	     
	  end
     end // block: valid_vector_register
   
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     invalid_register_ptr <= 5'd0;
	     invalid_register <= 1'b0;
	  end
	else
	  begin
	     invalid_register_ptr <= xmu_invalidate_valid ? 
				     xmu_invalidate_ptr :
				     invalid_register_ptr;

	     invalid_register <= (invalid_register == 1'b0) ?
				 xmu_invalidate_valid :
				 (non_block_ld_complete == 1'b1) ?
				 1'b0 :
				 invalid_register;
	     
				
	  end
     end // always@ (posedge clk)
          
   

endmodule // grf
