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

module ce_pipeline(/*AUTOARG*/
   // Outputs
   decode_stall, mr_rs1_ptr, mr_rs1_ptr_valid, mr_rs2_ptr,
   mr_rs2_ptr_valid, mr_alu_rd_ptr, mr_alu_rd_ptr_valid,
   mr_alu_rd_data, mr_xmu_rd_ptr, mr_xmu_rd_ptr_valid, mr_xmu_rd_data,
   ce_barrier_req, mem_swap_value, mem_cswap, mem_ldsd, mem_stsd,
   mem_lds, mem_sts, stream_offset, non_block_load_complete, hcf,
   simd_out_inst, simd_out_inst_valid, simd_out_req, simd_out_mine,
   simd_out_simd_stall, /*fetch_instr_request, fetch_instr_request_addr,*/
   xmu_exec_req_mem, xmu_exec_ld_ensemble, xmu_exec_st_ensemble,
   xmu_exec_mem_addr, xmu_exec_mem_write, xmu_remote_mem_req,
   xmu_remote_mem_non_block,
   // Inputs
   clk, rst, xmu_boot_inst, who_am_i, mr0_empty, mr0_full, mr1_empty, mr1_full, mr2_empty,
   mr2_full, mr3_empty, mr3_full, mr4_empty, mr4_full, mr5_empty,
   mr5_full, mr6_empty, mr6_full, mr7_empty, mr7_full, mr_rs1_data,
   mr_rs2_data, ensemble_barrier_release, mailbox_full, global_stall,
   simd_in_inst, simd_in_inst_valid, simd_in_stall, simd_in_mask,
   /*fetch_data_ready, fetch_data_in,*/ ensemble_mem_ld, ensemble_mem_gnt
   );


 
   input clk;
   input rst;

   input [31:0] xmu_boot_inst;
   input [1:0] 	who_am_i;
      
   /* Begin: signals for message registers */
   input mr0_empty;
   input mr0_full;

   input mr1_empty;
   input mr1_full;

   input mr2_empty;
   input mr2_full;

   input mr3_empty;
   input mr3_full;

   input mr4_empty;
   input mr4_full;

   input mr5_empty;
   input mr5_full;
      
   input mr6_empty;
   input mr6_full;

   input mr7_empty;
   input mr7_full;

   output decode_stall;

   /* Message register read pointers */
   output [2:0] mr_rs1_ptr;
   output 	mr_rs1_ptr_valid;

   output [2:0] mr_rs2_ptr;
   output 	mr_rs2_ptr_valid;
      
   input [31:0] mr_rs1_data;
   input [31:0] mr_rs2_data;

   /* Message register writeback pointers */
   output [2:0]  mr_alu_rd_ptr;
   output 	 mr_alu_rd_ptr_valid;
   output [31:0] mr_alu_rd_data;
   
   output [2:0]  mr_xmu_rd_ptr;
   output 	 mr_xmu_rd_ptr_valid;
   output [31:0] mr_xmu_rd_data;
    
   
   /* End: signals for the message registers */
   
   
   input ensemble_barrier_release;
   output ce_barrier_req;
   
   //output [124:0] ep_to_mem_box;
   //assign 	  ep_to_mem_box = 125'd0;
   //input  ep_to_mem_box_read;
   //input [124:0]  mem_to_ep_box;
   //output 	  mem_to_ep_box_read;
   //assign 	  mem_to_ep_box_read = 1'b0;
   
   input  mailbox_full;
   input  global_stall;

    
   output 	 hcf;


   input [63:0]  simd_in_inst;
   input 	 simd_in_inst_valid;
   input 	 simd_in_stall;

   //basically, execute a nop
   input 	 simd_in_mask;
   
   
   output [63:0] simd_out_inst;
   output 	 simd_out_inst_valid;
   output 	 simd_out_req;
   output 	 simd_out_mine;
   output 	 simd_out_simd_stall;
   
   
   wire 	 simd_mode;
      /* cswap:
    * xmu_addr = address
    * xmu_data = compare to value
    * mem_swap_value = swap value 
    */


   /* ldsd / stsd 
    * xmu_addr = address
    * stream_descriptor = stream_descriptor_id 
    */

   /* store stream / load stream 
    * dest address = xmu_address
    * offset = xmu_data  
    * stream descriptor id = stream_descriptor_id
    * number of elements = stream_num_elements
    */
   
   
   wire [6:0] xmu_ex_mem_ptr;
   wire       xmu_ex_mem_valid;
   wire [31:0] xmu_ex_mem_in;

   wire        xmu_id_ex_valid;
   wire [6:0]  xmu_id_ex_ptr;

  
   //output from predicate register file
   wire [8:0] alu_pr_r1_in;
   wire        alu_pr_r1_in_valid;
   wire [8:0] alu_pr_r2_in;
   wire        alu_pr_r2_in_valid;
   
   wire [8:0] xmu_pr_r1_in;
   wire        xmu_pr_r1_in_valid;
   wire [8:0] xmu_pr_r2_in;
   wire        xmu_pr_r2_in_valid;

   
   wire        xmu_gets_the_port;
   wire        fetch_active;
   /* Inputs and outputs that are going to memory */
   //data in from ensemble memory
   output [31:0] xmu_exec_mem_addr;
   reg [31:0] 	 r_mem_addr;
   
   input [63:0] ensemble_mem_ld;
   wire [31:0] 	w_ensemble_mem_ld = xmu_gets_the_port ? (r_mem_addr[0] ?
		ensemble_mem_ld[63:32] : ensemble_mem_ld[31:0]) : 32'd0;
   
   input 	ensemble_mem_gnt;
   wire 	xmu_ensemble_mem_gnt = xmu_gets_the_port & ensemble_mem_gnt;
   
   //output 	fetch_instr_request;
   //output [31:0] fetch_instr_request_addr;
   wire 	 w_fetch_instr_request;
   wire [31:0] 	 w_fetch_instr_request_addr;
   //assign fetch_instr_request = 1'b0/* w_fetch_instr_request*/;
   //assign fetch_instr_request_addr = 32'd0/* w_fetch_instr_request_addr*/;
   //input 	 fetch_data_ready;
   // input [63:0]  fetch_data_in;
   wire 	 w_fetch_data_ready = (~xmu_gets_the_port) ?  
		 ensemble_mem_gnt : 1'b0;
   wire [63:0] 	 w_fetch_data_in = (~xmu_gets_the_port) ? ensemble_mem_ld : 64'd0;
   //wire 	 w_fetch_data_ready = fetch_data_ready;
   //wire [63:0] 	 w_fetch_data_in = fetch_data_in;
      
   output 	 xmu_exec_req_mem;
   wire 	 w_xmu_exec_req_mem;  //hooked to module
   reg 		 r_mem_req;
   wire 	 mem_reg_valid = r_mem_req & ~xmu_ensemble_mem_gnt;
   assign xmu_exec_req_mem = xmu_gets_the_port ? (mem_reg_valid ? /*!xmu_ensemble_mem_gnt*/ 1'b1  :
			     w_xmu_exec_req_mem) : w_fetch_instr_request;
   
   output 	 xmu_exec_ld_ensemble;
   output 	 xmu_exec_st_ensemble;
   wire 	 w_xmu_exec_ld_ensemble; //directly from module
   wire 	 w_xmu_exec_st_ensemble; //directly from module
   reg 		 r_ld_ensemble;
   reg 		 r_st_ensemble;
   
   assign xmu_exec_ld_ensemble = xmu_gets_the_port ? (mem_reg_valid ? r_ld_ensemble :
				 w_xmu_exec_ld_ensemble) : w_fetch_instr_request;
   
   assign xmu_exec_st_ensemble = xmu_gets_the_port ? (mem_reg_valid ? r_st_ensemble :
				 w_xmu_exec_st_ensemble) : 1'b0;
    
   
   output [31:0] xmu_exec_mem_write;
   wire [31:0] 	 w_xmu_exec_mem_addr;
   wire [31:0] 	 w_xmu_exec_mem_write;

   reg [31:0] 	 r_mem_data;
   assign xmu_exec_mem_addr = xmu_gets_the_port ? (mem_reg_valid ? r_mem_addr :
						   w_xmu_exec_mem_addr) :
			      fetch_active ? w_fetch_instr_request_addr: 32'd0;
   
   assign xmu_exec_mem_write = xmu_gets_the_port ? (mem_reg_valid ? r_mem_data :
						    w_xmu_exec_mem_write) : 1'b0;

   output 	 xmu_remote_mem_req;
   output 	 xmu_remote_mem_non_block;
   wire 	 w_xmu_remote_mem_req;
   wire 	 w_xmu_remote_mem_non_block;
   reg 		 r_mem_remote;
   reg 		 r_mem_nonblock;
   assign xmu_remote_mem_req = xmu_gets_the_port ? (mem_reg_valid ? r_mem_remote :
			       w_xmu_remote_mem_req) : 1'b0;
   assign xmu_remote_mem_non_block = xmu_gets_the_port ? (mem_reg_valid ? r_mem_nonblock :
				     w_xmu_remote_mem_non_block) :1'b0 ;
      
   /* swap value for compare and swap */
   output [31:0] mem_swap_value;
   wire [31:0] 	 w_xmu_exec_swap_value;
   reg [31:0] 	 r_mem_swap;
   assign mem_swap_value = mem_reg_valid ? r_mem_swap :
			   w_xmu_exec_swap_value;
   
    /* compare and swap */
   output 	 mem_cswap;
   wire 	 w_xmu_exec_cswap;
   reg 		 r_mem_cswap;
   assign mem_cswap = xmu_gets_the_port ? ( mem_reg_valid ? r_mem_cswap :
		      w_xmu_exec_cswap) : 1'b0;

   /* load stream descriptor */
   output 	 mem_ldsd ;
   output 	 mem_stsd;
   wire 	 w_xmu_exec_ldsd;
   wire 	 w_xmu_exec_stsd;
   reg 		 r_ldsd;
   reg 		 r_stsd;
   assign mem_ldsd = xmu_gets_the_port ? (mem_reg_valid ? r_ldsd :
		     w_xmu_exec_ldsd) : 1'b0;
   assign mem_stsd = xmu_gets_the_port ? (mem_reg_valid ? r_stsd :
		     w_xmu_exec_stsd) : 1'b0;

   /* load stream and store stream */
   output 	 mem_lds ;
   output 	 mem_sts;
   wire 	 w_xmu_exec_ldstream;
   wire 	 w_xmu_exec_ststream;
   reg 		 r_ldstream;
   reg 		 r_ststream;
   assign mem_lds = xmu_gets_the_port ? (mem_reg_valid ? r_ldstream :
		    w_xmu_exec_ldstream) : 1'b0;

   assign mem_sts = xmu_gets_the_port ? (mem_reg_valid ? r_ststream :
		    w_xmu_exec_ststream) : 1'b0;


   output [31:0] stream_offset;
   wire [31:0] 	 w_xmu_exec_offset_value;
   reg [31:0] 	r_mem_offset_value;
   assign stream_offset = xmu_gets_the_port ? (mem_reg_valid ? r_mem_offset_value :
			  w_xmu_exec_offset_value) : 1'b0;
   
   
   output 	 non_block_load_complete;
   wire 	 w_grf_complete_non_block;
   assign non_block_load_complete = w_grf_complete_non_block;
  


   reg 		 xmu_gets_the_port_last;
   assign xmu_gets_the_port = xmu_gets_the_port_last ? (w_xmu_exec_req_mem | r_mem_req) :
			      (~fetch_active & (w_xmu_exec_req_mem | r_mem_req));
   

   //register file to decode stage
   wire [31:0] alu_grf_r1_in;
   wire        alu_grf_r1_in_valid;
   
   wire [31:0] alu_grf_r2_in;
   wire        alu_grf_r2_in_valid;

   wire [31:0] xmu_grf_r1_in;
   wire        xmu_grf_r1_in_valid;
   

   wire [31:0] xmu_grf_r2_in;
   wire        xmu_grf_r2_in_valid;  
	

   //combinational grf requests
   wire [4:0]  alu_if_ex_grf_ptr1;
   wire [4:0]  alu_if_ex_grf_ptr2;
   wire        alu_if_ex_grf_ptr1_valid;
   wire        alu_if_ex_grf_ptr2_valid;
  
   wire [4:0]  xmu_if_ex_grf_ptr1;
   wire [4:0]  xmu_if_ex_grf_ptr2;
   wire        xmu_if_ex_grf_ptr1_valid;
   wire        xmu_if_ex_grf_ptr2_valid;
  
   wire [4:0]  alu_grf_wb_ptr;
   wire        alu_grf_wb_valid;
   wire [4:0]  xmu_grf_wb_ptr;   
   wire        xmu_grf_wb_valid;
 
   
   //combinational index register requests
   wire [1:0]  alu_if_ex_xp_ptr1;
   wire [1:0]  alu_if_ex_xp_ptr2;
   wire        alu_if_ex_xp_ptr1_valid;
   wire        alu_if_ex_xp_ptr2_valid;

   wire [1:0]  xmu_if_ex_xp_ptr1;
   wire [1:0]  xmu_if_ex_xp_ptr2;
   wire        xmu_if_ex_xp_ptr1_valid;
   wire        xmu_if_ex_xp_ptr2_valid;


   wire [1:0]  alu_xp_wb_ptr;
   wire        alu_xp_wb_valid;
   wire [1:0]  xmu_xp_wb_ptr;
   wire        xmu_xp_wb_valid; 

   //combinational predicate register requests
   wire [2:0]  alu_if_ex_pr_ptr1;
   wire [2:0]  alu_if_ex_pr_ptr2;
   wire        alu_if_ex_pr_ptr1_valid;
   wire        alu_if_ex_pr_ptr2_valid;

   wire [2:0]  xmu_if_ex_pr_ptr1;
   wire [2:0]  xmu_if_ex_pr_ptr2;
   wire        xmu_if_ex_pr_ptr1_valid;
   wire        xmu_if_ex_pr_ptr2_valid;
         
   wire [2:0]  alu_pr_wb_ptr;
   wire        alu_pr_wb_valid;
   wire [2:0]  xmu_pr_wb_ptr;
   wire        xmu_pr_wb_valid;
   
   //combinational message register requests
   wire [2:0]  alu_if_ex_mr_ptr1;
   wire [2:0]  alu_if_ex_mr_ptr2;
   wire        alu_if_ex_mr_ptr1_valid;
   wire        alu_if_ex_mr_ptr2_valid;

   wire [2:0]  xmu_if_ex_mr_ptr1;
   wire [2:0]  xmu_if_ex_mr_ptr2;
   wire        xmu_if_ex_mr_ptr1_valid;
   wire        xmu_if_ex_mr_ptr2_valid;

   
   wire [2:0]  alu_mr_wb_ptr;
   wire        alu_mr_wb_valid;
   wire [2:0]  xmu_mr_wb_ptr;
   wire        xmu_mr_wb_valid;

  
   
   wire        alu_decode_gen_stall;
   wire        alu_exec_gen_stall;
   
   wire [6:0]  alu_ex_mem_ptr;
   wire        alu_ex_mem_valid;

   //the result!
   wire [31:0] alu_ex_mem_in;
   wire [31:0] alu_wb_value;
   wire [6:0]  alu_id_ex_ptr;
   wire        alu_id_ex_valid;


   wire [34:0] alu_wb_instruction;
   wire        alu_wb_valid;


   
   wire [11:0] xp_write_grf_alu;
   wire [11:0] xp_write_grf_xmu;

   
   //xmu result
   wire [31:0] xmu_wb_value;
   
   wire [31:0] w_alu_mr_rs1_data;
   wire [31:0] w_alu_mr_rs2_data;  
   wire [31:0] w_xmu_mr_rs1_data;
   wire [31:0] w_xmu_mr_rs2_data;  

   
   //signal asserted by the xmu exec stage to kill alu exec wb
   wire        xmu_pred_kill_exec;


   wire        xmu_decode_gen_stall;
   wire        xmu_exec_gen_stall;
  
   //to be generated by message register file

   //todo, this needs to be implemented so we can block on mr writes
   //I thought we already do though...odd
   //apparently we do
   /*wire        message_register_stall = 1'b0;*/
   
   

   //instruction registers
   wire        fetch_req;
   wire [31:0] fetch_base_global_addr;
   wire [5:0]  fetch_base_ir_addr;
   wire [5:0]  fetch_len;
   
    //bits 63 to 32 are the xmu instruction
   //bits 31 to 0 are the alu instruction
   wire [63:0] instruction_dword;

   wire        instruction_valid;

   wire [5:0]  pc;

   wire 	 w_stop_jfetch;


   wire [31:0] w_xmu_dec_rs1_out;
   /*wire        w_xmu_dec_rs1_out_valid;*/
      


  
   
   
   wire 	 w_xmu_exec_lo;
   wire 	 w_xmu_exec_hi;
   
   wire [11:0] 	 xp_read_alu_r1;
   wire [11:0] 	 xp_read_alu_r2;  
   wire [11:0] 	 xp_read_xmu_r1;
   wire [11:0] 	 xp_read_xmu_r2;
   
   wire 	 xmu_barrier;
   wire [5:0] 	 w_link_reg;
   wire 	 w_alu_accum_stall;
 


   wire 	 w_sample_mem = (!r_mem_req | xmu_ensemble_mem_gnt) & 
		 w_xmu_exec_req_mem;
   
   wire 	 w_mem_gnt = xmu_ensemble_mem_gnt /*|
		 r_mem_nonblock & !mailbox_full*/;

      
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     xmu_gets_the_port_last <= 1'b0;
	     r_mem_req <= 1'b0;
	     r_ld_ensemble <= 1'b0;
	     r_st_ensemble <= 1'b0;

	     /* If mailbox is full, even nonblock will block */
	     r_mem_remote <= 1'b0;
	     r_mem_nonblock <= 1'b0;
	   
	     r_mem_addr <= 32'd0;
	     r_mem_data <= 32'd0;

	     r_mem_cswap <= 1'b0;
	     	     
	     r_mem_swap <= 32'd0;
	
	     r_stsd <= 1'b0;
	     r_ldsd <= 1'b0;

	     r_ldstream <= 1'b0;
	     r_ststream <= 1'b0;
	     
	     r_mem_offset_value <= 32'd0;
	          
	  end
	else
	  begin
	     xmu_gets_the_port_last <= xmu_gets_the_port;
	     r_mem_req <= (r_mem_req == 1'b0) ?  w_xmu_exec_req_mem :
			  (xmu_gets_the_port_last & xmu_ensemble_mem_gnt) ? w_xmu_exec_req_mem 
			  /*1'b0*/ : 1'b1;


	     r_stsd <= w_sample_mem ? w_xmu_exec_stsd :
		       r_stsd;

	     r_ldsd <= w_sample_mem ? w_xmu_exec_ldsd :
		       r_ldsd;
	     

	     r_ldstream <= w_sample_mem ? w_xmu_exec_ldstream :
			   r_ldstream;

	     r_ststream <= w_sample_mem ? w_xmu_exec_ststream :
			   r_ststream;
	     
	     r_mem_offset_value <= w_sample_mem ? w_xmu_exec_offset_value :
				   r_mem_offset_value;
	    	     
	     r_mem_cswap <= w_sample_mem ? w_xmu_exec_cswap :
			    r_mem_cswap;

	     r_mem_swap <= w_sample_mem ? w_xmu_exec_swap_value :
			   r_mem_swap;
	     	     
	     
	     r_ld_ensemble <= w_sample_mem ? w_xmu_exec_ld_ensemble :
			      r_ld_ensemble;

	     r_st_ensemble <= w_sample_mem ? w_xmu_exec_st_ensemble :
			      r_st_ensemble;

	     r_mem_addr <= w_sample_mem ? w_xmu_exec_mem_addr :
			   r_mem_addr;

	     r_mem_data <= w_sample_mem ? w_xmu_exec_mem_write :
			   r_mem_data;

	     r_mem_remote <= w_sample_mem ? w_xmu_remote_mem_req :
			     r_mem_remote;

	     r_mem_nonblock <= w_sample_mem ? w_xmu_remote_mem_non_block:
			       r_mem_nonblock;
	     
	  end // else: !if(rst)
     end // always@ (posedge clk)
   
   
   
   //registered output of the fetch instruction
   reg [63:0] 	 r_if_dec_instruction;


   wire [31:0] simd_xdec_inst = 
	       (simd_in_mask | ~simd_in_inst_valid) ? 32'd0 :
	       simd_in_inst[63:32];

   //rch, delta 2/11 since we still want to execute the alu op w/ a loop
    wire [31:0] simd_adec_inst = 
	       (~simd_in_inst_valid) ? 32'd0 :
	       simd_in_inst[31:0];
   
   //instruction currently in xmu decode
   wire [31:0] 	 xmu_dec_instruction = simd_mode ? 
		 simd_xdec_inst : 
		 r_if_dec_instruction[63:32];
   
   wire [31:0] 	 alu_dec_instruction = simd_mode ? 
		 simd_adec_inst : 
		 r_if_dec_instruction[31:0];
   
   
   //output from xmu_pipeline module
   wire [34:0] 	 xmu_exec_instruction;
   
   wire 	 stall_fetch;

   reg [63:0] 	 r_simd_out_inst;
   reg 		 r_simd_out_inst_valid;
  
    
   assign simd_out_inst = simd_mode ? instruction_dword : 64'd0;
   assign simd_out_inst_valid = simd_mode ? instruction_valid : 1'b0;
 

   /*
   assign simd_out_inst = r_simd_out_inst;
   assign simd_out_inst_valid = r_simd_out_inst_valid;
      */
   /* TEST */
   /*
   always@(posedge clk or posedge rst)
     begin
	if(rst)
	  begin
	     r_simd_out_inst <= 64'd0;
	     r_simd_out_inst_valid <= 1'b0;
	  end
	else
	  begin
	     r_simd_out_inst <= simd_mode ? instruction_dword : 64'd0;
	     r_simd_out_inst_valid <= simd_mode ? instruction_valid : 1'b0;
	  end
     end
   */


   
   //wire 	 ir_valid_simd = simd_mode ? simd_out_mine ? instruction_dword : 1'b1 : instruction_dword;
   
   instr_supply irf (
		    // Outputs
		    .instr_word		(instruction_dword),
		    .instr_valid	(instruction_valid),
		    .fetch_active	(fetch_active),
		    .memory_request	(w_fetch_instr_request),
		    .memory_request_addr(w_fetch_instr_request_addr),
		    // Inputs
		    .clk		(clk),
		    .rst		(rst),
		    .ce_pc		(pc),
		     .xmu_boot_inst     (xmu_boot_inst),
		     
		    //TODO:
		    .fetch_req		(fetch_req),
		    .fetch_base_global_addr(fetch_base_global_addr),
		    .fetch_base_ir_addr	(fetch_base_ir_addr),
		    .fetch_len		(fetch_len),
		    .data_ready		(w_fetch_data_ready),
		    .data_in		(w_fetch_data_in)
		    );
   



   wire 	 stall_decode;
   wire 	 stall_exec;
   wire 	 stall_wb;

   wire 	 w_xmu_exec_hcf;
   

   //predicate (if jump / loop instruction)
   wire [31:0] 	 jump_pr;

   //saved program counter
   wire [5:0] 	 saved_ip;

   
   wire [7:0] 	 xmu_exec_opcode;

   wire 	 w_xmu_write_link_reg;
   wire [31:0] 	 w_xmu_link_pr_reg;
   
   wire 	 w_alu_write_link_reg;
   wire [31:0] 	 w_alu_link_reg;
   


   
   assign decode_stall = stall_decode;
   

   
   wire 	 w_ensemble_req_blocking = w_xmu_exec_req_mem;
   /*	 & ~w_xmu_remote_mem_non_block; */

   pc_branch_unit 
     branch_comp (
		  // Outputs
		  .alu_pr_out1	(alu_pr_r1_in),
		  .alu_pr_out1_valid(alu_pr_r1_in_valid),
		  
		  .alu_pr_out2	(alu_pr_r2_in),
		  .alu_pr_out2_valid(alu_pr_r2_in_valid),
		  
		  .xmu_pr_out1	(xmu_pr_r1_in),
		  .xmu_pr_out1_valid(xmu_pr_r1_in_valid),
		      
		  .xmu_pr_out2	(xmu_pr_r2_in),
		  .xmu_pr_out2_valid(xmu_pr_r2_in_valid),
		      
		  .ip		(pc),
		  .stall_fetch	(stall_fetch),
		  .stall_decode	(stall_decode),
		  .stall_exec	(stall_exec),
		  .stall_wb		(stall_wb),
		  .jump_pr		(jump_pr),
		  .saved_ip		(saved_ip),
		  .link_reg         (w_link_reg),
		  .fetch_req(fetch_req),
		  .fetch_base_global_addr(fetch_base_global_addr),
		  .fetch_base_ir_addr(fetch_base_ir_addr),
		  .fetch_len(fetch_len),
		  .ce_barrier_req(ce_barrier_req),
		  
		  .hcf (hcf),
		  .simd_out_req(simd_out_req),
		  .simd_out_mine(simd_out_mine),
		  .simd_mode(simd_mode),
		  .simd_out_simd_stall(simd_out_simd_stall),
		  // Inputs
		  .clk		(clk),
		  .rst		(rst),
		  
		  .simd_in_stall(simd_in_stall),
		  .who_am_i (who_am_i),
		  .xmu_exec_opcode  (xmu_exec_opcode),       
		  .xmu_exec_hcf     (w_xmu_exec_hcf),
		  .xmu_exec_non_block (w_xmu_remote_mem_non_block),
		  .xmu_exec_ld        (w_xmu_exec_ld_ensemble),
		  .xmu_exec_st        (w_xmu_exec_st_ensemble),
		  .grf_retire_non_block_load (w_grf_complete_non_block),
		  
                      .global_stall     (global_stall),
			       .xmu_ensemble_req (w_ensemble_req_blocking),
			       /*.xmu_ensemble_rem_req ( w_xmu_remote_mem_req),*/
		      .ensemble_gnt    (w_mem_gnt),
		      .xmu_barrier(xmu_barrier),
		      .ensemble_barrier_release(ensemble_barrier_release),

		      .alu_write_link_reg(w_alu_write_link_reg),
		      .alu_link_reg(w_alu_link_reg),

		      .xmu_write_link_reg(w_xmu_write_link_reg),       
		      .xmu_link_pr_reg(w_xmu_link_pr_reg),
		
		      .xmu_rs1_in(w_xmu_dec_rs1_out),
		      /*.xmu_rs1_in_valid(w_xmu_dec_rs1_out_valid),*/
			       
		      //generated in this module
		      .xmu_dec_instruction(xmu_dec_instruction),

		      //not registered!
		      .ir_valid	(instruction_valid),
		      .fetch_active(fetch_active),
			       
		  
		      .alu_dec_stall	(alu_decode_gen_stall),
		      .alu_exec_stall   (alu_exec_gen_stall),
			       
		      .xmu_dec_stall	(xmu_decode_gen_stall),
		      .xmu_exec_stall	(xmu_exec_gen_stall),

		      .alu_accum_stall   (w_alu_accum_stall),	       
			       
		      //from message register file
		      /*.mr_wb_stall	(message_register_stall),*/
		

     		      .alu_pr_ptr1	(alu_if_ex_pr_ptr1),
		      .alu_pr_ptr1_valid(alu_if_ex_pr_ptr1_valid),
		      
		      .alu_pr_ptr2	(alu_if_ex_pr_ptr2),
		      .alu_pr_ptr2_valid(alu_if_ex_pr_ptr2_valid),
		      
		      .xmu_pr_ptr1	(xmu_if_ex_pr_ptr1),
		      .xmu_pr_ptr1_valid(xmu_if_ex_pr_ptr1_valid),
		      
		      .xmu_pr_ptr2	(xmu_if_ex_pr_ptr2),
		      .xmu_pr_ptr2_valid(xmu_if_ex_pr_ptr2_valid),


		      .alu_pr_exec_ptr	(alu_id_ex_ptr[6:2]),
		      .alu_pr_exec_ptr_valid(alu_id_ex_valid),
	
		      .stop_jfetch (w_stop_jfetch),
		      //write backs		      
		      .xmu_pr_wb_ptr	(xmu_pr_wb_ptr),
		      .xmu_pr_wb_ptr_valid(xmu_pr_wb_valid),
			       /*.xmu_pr_wb_in	(xmu_wb_value),*/
		      
		      .alu_pr_wb_ptr	(alu_pr_wb_ptr),
		      .alu_pr_wb_ptr_valid(alu_pr_wb_valid),
		      .alu_pr_wb_in	(alu_wb_value)
		      );
   

   wire 	 w_alu_mr_rs1_in_valid = alu_if_ex_mr_ptr1_valid &
		 ((alu_if_ex_mr_ptr1 == 3'd0) ? ~mr0_empty :
		  (alu_if_ex_mr_ptr1 == 3'd1) ? ~mr1_empty :
		  (alu_if_ex_mr_ptr1 == 3'd2) ? ~mr2_empty :
		  (alu_if_ex_mr_ptr1 == 3'd3) ? ~mr3_empty :
   		  (alu_if_ex_mr_ptr1 == 3'd4) ? ~mr4_empty :
		  (alu_if_ex_mr_ptr1 == 3'd5) ? ~mr5_empty :
		  (alu_if_ex_mr_ptr1 == 3'd6) ? ~mr6_empty :
		  ~mr7_empty);
   
		 
   wire 	 w_alu_mr_rs2_in_valid =  alu_if_ex_mr_ptr2_valid &
		 ((alu_if_ex_mr_ptr2 == 3'd0) ? ~mr0_empty :
		  (alu_if_ex_mr_ptr2 == 3'd1) ? ~mr1_empty :
		  (alu_if_ex_mr_ptr2 == 3'd2) ? ~mr2_empty :
		  (alu_if_ex_mr_ptr2 == 3'd3) ? ~mr3_empty :
   		  (alu_if_ex_mr_ptr2 == 3'd4) ? ~mr4_empty :
		  (alu_if_ex_mr_ptr2 == 3'd5) ? ~mr5_empty :
		  (alu_if_ex_mr_ptr2 == 3'd6) ? ~mr6_empty :
		  ~mr7_empty);
   
   assign mr_alu_rd_data = alu_wb_value;
   
   alu_pipeline apipe(
		    // Outputs
		    .alu_if_ex_grf_ptr1	(alu_if_ex_grf_ptr1),
		    .alu_if_ex_grf_ptr2	(alu_if_ex_grf_ptr2),
		    .alu_if_ex_grf_ptr1_valid(alu_if_ex_grf_ptr1_valid),
		    .alu_if_ex_grf_ptr2_valid(alu_if_ex_grf_ptr2_valid),
		    
		    .alu_if_ex_xp_ptr1	(alu_if_ex_xp_ptr1[1:0]),
		    .alu_if_ex_xp_ptr2	(alu_if_ex_xp_ptr2[1:0]),
		    .alu_if_ex_xp_ptr1_valid(alu_if_ex_xp_ptr1_valid),
		    .alu_if_ex_xp_ptr2_valid(alu_if_ex_xp_ptr2_valid),
		    
		    .alu_if_ex_pr_ptr1	(alu_if_ex_pr_ptr1[2:0]),
		    .alu_if_ex_pr_ptr2	(alu_if_ex_pr_ptr2[2:0]),
		    .alu_if_ex_pr_r1_valid(alu_if_ex_pr_ptr1_valid),
		    .alu_if_ex_pr_r2_valid(alu_if_ex_pr_ptr2_valid),
		    
		    .alu_if_ex_mr_ptr1	(alu_if_ex_mr_ptr1[2:0]),
		    .alu_if_ex_mr_ptr2	(alu_if_ex_mr_ptr2[2:0]),
		    .alu_if_ex_mr_r1_valid(alu_if_ex_mr_ptr1_valid),
		    .alu_if_ex_mr_r2_valid(alu_if_ex_mr_ptr2_valid),
		    
		    .alu_decode_gen_stall(alu_decode_gen_stall),
		    .alu_exec_gen_stall(alu_exec_gen_stall),
		      
		    .alu_ex_mem_ptr	(alu_ex_mem_ptr),
		    .alu_ex_mem_valid	(alu_ex_mem_valid),
		    .alu_ex_mem_in	(alu_ex_mem_in),
		    .alu_id_ex_ptr	(alu_id_ex_ptr),
		    .alu_id_ex_valid	(alu_id_ex_valid),

		    //writeback pointers
		    .alu_grf_wb_valid	(alu_grf_wb_valid),
		    .alu_grf_wb_ptr	(alu_grf_wb_ptr),

		    .alu_mr_wb_valid	(mr_alu_rd_ptr_valid),
		    .alu_mr_wb_ptr	(mr_alu_rd_ptr),
		    
		    .alu_pr_wb_valid	(alu_pr_wb_valid),
		    .alu_pr_wb_ptr	(alu_pr_wb_ptr),
		
		      //not actually used in writeback, 
		      //read in decode for grf ptr
		    .alu_xp_wb_valid	(alu_xp_wb_valid),
		    .alu_xp_wb_ptr	(alu_xp_wb_ptr),

		    //writeback value
		    .alu_wb_value	(alu_wb_value),
		    .alu_wb_valid       (alu_wb_valid),
		    .alu_wb_instruction (alu_wb_instruction),


		      
		   .alu_accum_stall   (w_alu_accum_stall),
		      
		    // Inputs
		    .clk		(clk),
		    .rst		(rst),
		    .alu_if_id_instruction(alu_dec_instruction),
		    .xmu_pred_kill_exec	(xmu_pred_kill_exec),
		    .xmu_ex_mem_ptr	(xmu_ex_mem_ptr),
		    .xmu_ex_mem_valid	(xmu_ex_mem_valid),
		    .xmu_ex_mem_in	(xmu_ex_mem_in),
		    .xmu_id_ex_valid	(xmu_id_ex_valid),
		    .xmu_id_ex_ptr	(xmu_id_ex_ptr),
		      
		    .xmu_exec_opcode    (xmu_exec_opcode),

		    .link_reg          (w_link_reg),
		      
		    .grf_r1_in		(alu_grf_r1_in),
		    .grf_r1_in_valid	(alu_grf_r1_in_valid),
		    .grf_r2_in		(alu_grf_r2_in),
		    .grf_r2_in_valid	(alu_grf_r2_in_valid),
		
		     //new way of using index registers
		    .xp_grf_ptr1       (xp_read_alu_r1[4:0]),
		    .xp_grf_ptr2       (xp_read_alu_r2[4:0]),
		    .xp_grf_ptr1_valid (1'b1),
		    .xp_grf_ptr2_valid (1'b1),

		    .xp_grf_rd_ptr       (xp_write_grf_alu[4:0]),
		    .xp_grf_rd_ptr_valid (1'b1),
		      
		      
		    .pr_r1_in		(alu_pr_r1_in),
		    .pr_r1_in_valid	(alu_pr_r1_in_valid),
		    .pr_r2_in		(alu_pr_r2_in),
		    .pr_r2_in_valid	(alu_pr_r2_in_valid),

    
		    .mr_r1_in		(w_alu_mr_rs1_data),
		    .mr_r1_in_valid	(w_alu_mr_rs1_in_valid),
		    .mr_r2_in		(w_alu_mr_rs2_data),
		    .mr_r2_in_valid	(w_alu_mr_rs2_in_valid),

		    .mr0_full          (mr0_full),
		    .mr1_full          (mr1_full),
		    .mr2_full          (mr2_full),
		    .mr3_full          (mr3_full),
		    .mr4_full          (mr4_full),
		    .mr5_full          (mr5_full),
		    .mr6_full          (mr6_full),
		    .mr7_full          (mr7_full),
		      

		      
		    .stall_decode(stall_decode),
		    .stall_exec(stall_exec),
		    .stall_wb(stall_wb)
		    );

   assign w_alu_write_link_reg = (alu_ex_mem_ptr == 7'b0000001) &
				 alu_ex_mem_valid;

   assign w_alu_link_reg = alu_wb_value;
   
   wire 	 w_st_rd_from_xprf;
   
   wire 	 w_xmu_mr_rs1_in_valid = xmu_if_ex_mr_ptr1_valid &
		 ((xmu_if_ex_mr_ptr1 == 3'd0) ? ~mr0_empty :
		  (xmu_if_ex_mr_ptr1 == 3'd1) ? ~mr1_empty :
		  (xmu_if_ex_mr_ptr1 == 3'd2) ? ~mr2_empty :
		  (xmu_if_ex_mr_ptr1 == 3'd3) ? ~mr3_empty :
   		  (xmu_if_ex_mr_ptr1 == 3'd4) ? ~mr4_empty :
		  (xmu_if_ex_mr_ptr1 == 3'd5) ? ~mr5_empty :
		  (xmu_if_ex_mr_ptr1 == 3'd6) ? ~mr6_empty :
		  ~mr7_empty);
   
		 
   wire 	 w_xmu_mr_rs2_in_valid =  xmu_if_ex_mr_ptr2_valid &
		 ((xmu_if_ex_mr_ptr2 == 3'd0) ? ~mr0_empty :
		  (xmu_if_ex_mr_ptr2 == 3'd1) ? ~mr1_empty :
		  (xmu_if_ex_mr_ptr2 == 3'd2) ? ~mr2_empty :
		  (xmu_if_ex_mr_ptr2 == 3'd3) ? ~mr3_empty :
   		  (xmu_if_ex_mr_ptr2 == 3'd4) ? ~mr4_empty :
		  (xmu_if_ex_mr_ptr2 == 3'd5) ? ~mr5_empty :
		  (xmu_if_ex_mr_ptr2 == 3'd6) ? ~mr6_empty :
		  ~mr7_empty);
  
   assign mr_xmu_rd_data = xmu_wb_value;


   wire 	 w_xmu_wb_nonblock_load;
   wire [2:0] 	 w_xp_store_ptr;
   wire 	 w_xp_store_ptr_valid;
   wire [31:0]	 w_xp_store_data;
         
   xmu_pipeline xpipe(
		      // Outputs
		      .xmu_if_ex_grf_ptr1(xmu_if_ex_grf_ptr1),
		      .xmu_if_ex_grf_ptr2(xmu_if_ex_grf_ptr2),
		      .xmu_if_ex_grf_ptr1_valid(xmu_if_ex_grf_ptr1_valid),
		      .xmu_if_ex_grf_ptr2_valid(xmu_if_ex_grf_ptr2_valid),

		      //TODO: implement
		      .xmu_if_ex_xp_ptr1(xmu_if_ex_xp_ptr1),
		      .xmu_if_ex_xp_ptr2(xmu_if_ex_xp_ptr2),
		      .xmu_if_ex_xp_ptr1_valid(xmu_if_ex_xp_ptr1_valid),
		      .xmu_if_ex_xp_ptr2_valid(xmu_if_ex_xp_ptr2_valid),
		      
		      .xmu_if_ex_pr_ptr1(xmu_if_ex_pr_ptr1),
		      .xmu_if_ex_pr_ptr2(xmu_if_ex_pr_ptr2),
		      .xmu_if_ex_pr_r1_valid(xmu_if_ex_pr_ptr1_valid),
		      .xmu_if_ex_pr_r2_valid(xmu_if_ex_pr_ptr2_valid),
		      
		      .xp_store_ptr (w_xp_store_ptr),
		      .xp_store_ptr_valid (w_xp_store_ptr_valid),
		      .xp_store_data (w_xp_store_data),

		      //TODO: implement
		      .xmu_if_ex_mr_ptr1(xmu_if_ex_mr_ptr1),
		      .xmu_if_ex_mr_ptr2(xmu_if_ex_mr_ptr2),
		      .xmu_if_ex_mr_r1_valid(xmu_if_ex_mr_ptr1_valid),
		      .xmu_if_ex_mr_r2_valid(xmu_if_ex_mr_ptr2_valid),

		      .xmu_exec_instruction(xmu_exec_instruction),
		      .xmu_exec_opcode(xmu_exec_opcode),
		      
		      .xmu_ex_mem_ptr	(xmu_ex_mem_ptr[6:0]),
		      .xmu_ex_mem_valid	(xmu_ex_mem_valid),
		      .xmu_ex_mem_in	(xmu_ex_mem_in[31:0]),
		      .xmu_id_ex_ptr	(xmu_id_ex_ptr[6:0]),
		      .xmu_id_ex_valid	(xmu_id_ex_valid),
		      .xmu_grf_wb_valid	(xmu_grf_wb_valid),
		      .xmu_grf_wb_ptr	(xmu_grf_wb_ptr[4:0]),
	      
		      .xmu_mr_wb_valid	(mr_xmu_rd_ptr_valid),
		      .xmu_mr_wb_ptr	(mr_xmu_rd_ptr),
		      
		      .xmu_pr_wb_valid	(xmu_pr_wb_valid),
		      .xmu_pr_wb_ptr	(xmu_pr_wb_ptr[2:0]),

		      //used for resolving index rd in decode
		      .xmu_xp_wb_valid	(xmu_xp_wb_valid),
		      .xmu_xp_wb_ptr	(xmu_xp_wb_ptr[1:0]),
		      
		      .xmu_wb_value	(xmu_wb_value[31:0]),
		      .xmu_exec_hcf     (w_xmu_exec_hcf),
		      
		      .xmu_pred_kill_exec(xmu_pred_kill_exec),
		      .xmu_decode_gen_stall(xmu_decode_gen_stall),
		      .xmu_exec_gen_stall(xmu_exec_gen_stall),

		      .xmu_exec_req_mem(w_xmu_exec_req_mem),
		      .xmu_exec_ld_ensemble(w_xmu_exec_ld_ensemble),
		      .xmu_exec_st_ensemble(w_xmu_exec_st_ensemble),
		      .xmu_exec_mem_addr(w_xmu_exec_mem_addr),
                      .xmu_exec_mem_write(w_xmu_exec_mem_write),

		      .xmu_exec_hi(w_xmu_exec_hi),
		      .xmu_exec_lo(w_xmu_exec_lo),

		      .remote_mem_op(w_xmu_remote_mem_req),
		      .remote_mem_not_block(w_xmu_remote_mem_non_block),

		      .xmu_exec_cswap (w_xmu_exec_cswap),
		      .xmu_exec_swap_value (w_xmu_exec_swap_value),
		    
		      .xmu_exec_ldsd (w_xmu_exec_ldsd),
		      .xmu_exec_stsd (w_xmu_exec_stsd),
		     
		      .xmu_exec_ldstream (w_xmu_exec_ldstream),
		      .xmu_exec_ststream (w_xmu_exec_ststream),

		      .xmu_exec_offset_value (w_xmu_exec_offset_value),
		      
		      .xmu_dec_rs1_out(w_xmu_dec_rs1_out),
		      /*.xmu_dec_rs1_out_valid(w_xmu_dec_rs1_out_valid),*/
		      
		      .xmu_barrier(xmu_barrier),
		      .xmu_wb_nonblock_load(w_xmu_wb_nonblock_load),
		      .st_rd_from_xprf   (w_st_rd_from_xprf),
		      .stop_jfetch (w_stop_jfetch),
		      
		      // Inputs
		      .clk		(clk),
		      .rst		(rst),
		      .stall_decode	(stall_decode),
		      .stall_exec	(stall_exec),
		      .stall_wb		(stall_wb),


		      .link_reg         (w_link_reg),
		      
		      .ensemble_gnt      (xmu_ensemble_mem_gnt),
		      .xmu_ensemble_ld_in(w_ensemble_mem_ld),
		      
		      .xmu_if_id_instruction(xmu_dec_instruction),
		      
		      .branch_pr	(jump_pr),
		      
		      .alu_ex_mem_ptr	(alu_ex_mem_ptr),
		      .alu_ex_mem_valid	(alu_ex_mem_valid),
		      .alu_wb_valid (alu_wb_valid),
		      .alu_ex_mem_in	(alu_ex_mem_in),
		      
		      .alu_id_ex_valid	(alu_id_ex_valid),
		      .alu_id_ex_ptr	(alu_id_ex_ptr[6:0]),
		      
		      .grf_r1_in	(xmu_grf_r1_in),
		      .grf_r1_in_valid	(xmu_grf_r1_in_valid),
		      .grf_r2_in	(xmu_grf_r2_in),
		      .grf_r2_in_valid	(xmu_grf_r2_in_valid),

		      .xp_grf_ptr1      (xp_read_xmu_r1[4:0]),
		      .xp_grf_ptr2      (xp_read_xmu_r2[4:0]),
		      .xp_grf_ptr1_valid (1'b1),
		      .xp_grf_ptr2_valid (1'b1),
		      .xp_grf_rd_ptr     (xp_write_grf_xmu[4:0]),
		      .xp_grf_rd_ptr_valid (1'b1),
				      
		      .pr_r1_in		(xmu_pr_r1_in),
		      .pr_r1_in_valid	(xmu_pr_r1_in_valid),
		      .pr_r2_in		(xmu_pr_r2_in),
		      .pr_r2_in_valid	(xmu_pr_r2_in_valid),


		      .mr0_full          (mr0_full),
		      .mr1_full          (mr1_full),
		      .mr2_full          (mr2_full),
		      .mr3_full          (mr3_full),
		      .mr4_full          (mr4_full),
		      .mr5_full          (mr5_full),
		      .mr6_full          (mr6_full),
		      .mr7_full          (mr7_full),
		      
		     
		      .mr_r1_in		(w_xmu_mr_rs1_data),
		      .mr_r1_in_valid	(w_xmu_mr_rs1_in_valid),
		      .mr_r2_in		(w_xmu_mr_rs2_data),
		      .mr_r2_in_valid	(w_xmu_mr_rs2_in_valid)
			      
		      );

   
   assign w_xmu_write_link_reg = (xmu_ex_mem_ptr == 7'b0000001) &
				 xmu_ex_mem_valid;

   assign w_xmu_link_pr_reg = xmu_wb_value;



   
   wire [4:0] 	 xmu_invalidate_ptr = xmu_grf_wb_ptr;
   wire 	 xmu_invalidate_valid = w_xmu_wb_nonblock_load;
   
 
  
   
   wire [4:0]  alu_read_grf_ptr1 = alu_if_ex_grf_ptr1;
   wire [4:0]  alu_read_grf_ptr2 = alu_if_ex_grf_ptr2;
      
   wire [4:0]  xmu_read_grf_ptr1 = xmu_if_ex_grf_ptr1;
   wire [4:0]  xmu_read_grf_ptr2 = xmu_if_ex_grf_ptr2;

   wire alu_read_grf_ptr1_valid = alu_if_ex_grf_ptr1_valid;
   wire alu_read_grf_ptr2_valid = alu_if_ex_grf_ptr2_valid;

   wire xmu_read_grf_ptr1_valid = xmu_if_ex_grf_ptr1_valid;
   wire xmu_read_grf_ptr2_valid = xmu_if_ex_grf_ptr2_valid;



   wire [31:0] load_port = w_ensemble_mem_ld;
   
  


   wire [4:0] alu_write_grf_ptr = alu_grf_wb_ptr;

   wire alu_write_grf_ptr_valid = alu_grf_wb_valid;
   
   wire [4:0] xmu_write_grf_ptr = xmu_grf_wb_ptr;

   wire xmu_write_grf_ptr_valid = xmu_grf_wb_valid;


   
   wire xp_addr_match = (xmu_write_grf_ptr == 5'b01000);
   
   
    
   //.xmu_write_ptr		(xmu_write_grf_ptr),
	

	
   xp_ptr xp_rf (
		 // Outputs
		 .alu_read_xp_grf_ptr1	(xp_read_alu_r1),
		 .alu_read_xp_grf_ptr2	(xp_read_alu_r2),
		 .xmu_read_xp_grf_ptr1	(xp_read_xmu_r1),
		 .xmu_read_xp_grf_ptr2	(xp_read_xmu_r2),

		 .alu_write_xp_grf_ptr  (xp_write_grf_alu),
		 .xmu_write_xp_grf_ptr  (xp_write_grf_xmu), 
		 
		 
		 // Inputs
		 .clk			(clk),
		 .rst			(rst),


		 .st_rd_from_xprf       (w_st_rd_from_xprf),
		 /* decode full pointers in xp register file
		  * for moves to pointer metadata */
		 
		 .xmu_load_ptr          (xmu_ex_mem_ptr),
		 .xmu_load_ptr_valid        (xmu_ex_mem_valid),
		 .xmu_load_value        (xmu_ex_mem_in),

		 .alu_load_ptr          (alu_ex_mem_ptr),
		 .alu_load_ptr_valid        (alu_ex_mem_valid),
		 .alu_load_value        (alu_ex_mem_in),


		 
		 .store_ptr		(w_xp_store_ptr),
		 .store_ptr_valid (w_xp_store_ptr_valid),
		 .store_data (w_xp_store_data),
		 
		 .alu_read_req_ptr1		(alu_if_ex_xp_ptr1),
		 .alu_read_req_ptr2		(alu_if_ex_xp_ptr2),
		 .xmu_read_req_ptr1		(xmu_if_ex_xp_ptr1),
		 .xmu_read_req_ptr2		(xmu_if_ex_xp_ptr2),
		 
		 .alu_read_r1_req	(alu_if_ex_xp_ptr1_valid),
		 .alu_read_r2_req	(alu_if_ex_xp_ptr2_valid),
		 .xmu_read_r1_req	(xmu_if_ex_xp_ptr1_valid),
		 .xmu_read_r2_req	(xmu_if_ex_xp_ptr2_valid),
		 
		 .alu_write_ptr		(alu_xp_wb_ptr),
		 .xmu_write_ptr		(xmu_xp_wb_ptr),
		 .alu_write_req		(alu_xp_wb_valid),
		 .xmu_write_req		(xmu_xp_wb_valid),
		 .stall_decode          (stall_decode)
		 );



   
   
   
   

   grf grf_rf(
	       // Outputs
	       .alu_read_value1		(alu_grf_r1_in),
	       .alu_read_value2		(alu_grf_r2_in),
	       .xmu_read_value1		(xmu_grf_r1_in),
	       .xmu_read_value2		(xmu_grf_r2_in),
	       .alu_read_valid1		(alu_grf_r1_in_valid),
	       .alu_read_valid2		(alu_grf_r2_in_valid),
	       .xmu_read_valid1		(xmu_grf_r1_in_valid),
	       .xmu_read_valid2		(xmu_grf_r2_in_valid),
	       .grf_complete_non_block_load (w_grf_complete_non_block),

	      
	       // Inputs
	      .clk			(clk),
	       .rst			(rst),
	       
	       .alu_read_ptr1		(alu_read_grf_ptr1),
	       .alu_read_ptr2		(alu_read_grf_ptr2),
	       .xmu_read_ptr1		(xmu_read_grf_ptr1),
	       .xmu_read_ptr2		(xmu_read_grf_ptr2),
	       .alu_read_r1_valid	(alu_read_grf_ptr1_valid),
	       .alu_read_r2_valid	(alu_read_grf_ptr2_valid),
	       .xmu_read_r1_valid	(xmu_read_grf_ptr1_valid),
	       .xmu_read_r2_valid	(xmu_read_grf_ptr2_valid),

	       .alu_write_ptr		(alu_write_grf_ptr),
	       .alu_write_valid		(alu_write_grf_ptr_valid),
	       .alu_write_value		(alu_wb_value),
	       
	       .xmu_write_ptr		(xmu_write_grf_ptr),
	       .xmu_write_valid		(xmu_write_grf_ptr_valid),
	       .xmu_write_value		(xmu_wb_value),

	       .non_block_load_data         ( w_ensemble_mem_ld ),
	       .non_block_load_data_valid   (  w_mem_gnt      ),
	       
	       .xmu_invalidate_ptr	(xmu_invalidate_ptr),
	       .xmu_invalidate_valid	(xmu_invalidate_valid)
	      );
   


     
   mr_rs_sel mr_arb_mux (
			 // Outputs
			 .mr_rs1_ptr		(mr_rs1_ptr),
			 .mr_rs2_ptr		(mr_rs2_ptr),
			 .mr_rs1_ptr_valid	(mr_rs1_ptr_valid),
			 .mr_rs2_ptr_valid	(mr_rs2_ptr_valid),
			 
			 .alu_mr_rs1_data	(w_alu_mr_rs1_data),
			 .alu_mr_rs2_data	(w_alu_mr_rs2_data),
			 .xmu_mr_rs1_data	(w_xmu_mr_rs1_data),
			 .xmu_mr_rs2_data	(w_xmu_mr_rs2_data),
			 
			 // Inputs
			 .alu_mr_rs1_ptr	(alu_if_ex_mr_ptr1),
			 .alu_mr_rs2_ptr	(alu_if_ex_mr_ptr2),
			 .xmu_mr_rs1_ptr	(xmu_if_ex_mr_ptr1),
			 .xmu_mr_rs2_ptr	(xmu_if_ex_mr_ptr2),
			 .alu_mr_rs1_ptr_valid	(alu_if_ex_mr_ptr1_valid),
			 .alu_mr_rs2_ptr_valid	(alu_if_ex_mr_ptr2_valid),
			 .xmu_mr_rs1_ptr_valid	(xmu_if_ex_mr_ptr1_valid),
			 .xmu_mr_rs2_ptr_valid	(xmu_if_ex_mr_ptr2_valid),

			 //From MRF
			 .mr_rs1_data		(mr_rs1_data),
			 .mr_rs2_data		(mr_rs2_data)
			 );
   
   

   
   always@(posedge clk or posedge rst)
     begin: if_dec_register
	if(rst)
	  begin
	     //default: nops
	     r_if_dec_instruction <= 64'd0;
	  end
	else
	  begin
	     r_if_dec_instruction <= stall_decode ? 
				     r_if_dec_instruction :
				     stall_fetch ?
				     64'd0 :
				     instruction_dword;
	  end
     end
   
   
   
endmodule // ce_pipeline

