/* Heavily modified pacoblaze3 microcontroller
 * Parameterizations which could cause problems with
 * Design Compiler were removed 
 *
 * Pacoblaze is an open-source version of Xilinx's PicoBlaze uC
 * see: http://bleyer.org/pacoblaze
 * 
 * Modifications by: dsheffie@stanford.edu
 *
 *
 * Pacoblaze is released under the following license:
 * 
 * --------------------
 *  Modified BSD License
 * --------------------
 *
 *  Redistribution and use in source and binary forms, with or without modification,
 *  are permitted provided that the following conditions are met:
 *
 *     1. Redistributions of source code must retain the above copyright notice,  this
 *        list of conditions and the following disclaimer.
 *
 *     2. Redistributions in  binary form must  reproduce the above  copyright notice,
 *        this  list of  conditions and  the following  disclaimer in  the documentation
 *        and/or other materials provided with the distribution.
 * 
 *     3. The  name of  the author  may not  be used  to endorse  or promote  products
 *	    derived from this software without specific prior written permission.
 *
 *	THIS SOFTWARE  IS PROVIDED  BY THE  AUTHOR "AS  IS" AND  ANY EXPRESS  OR IMPLIED
 *      WARRANTIES,  INCLUDING,  BUT   NOT  LIMITED  TO,   THE  IMPLIED  WARRANTIES   OF
 *      MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 *      SHALL  THE  AUTHOR BE  LIABLE  FOR ANY  DIRECT,  INDIRECT, INCIDENTAL,  SPECIAL,
 *	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,  PROCUREMENT
 *	OF SUBSTITUTE  GOODS OR  SERVICES; LOSS  OF USE,  DATA, OR  PROFITS; OR BUSINESS
 *      INTERRUPTION)  HOWEVER  CAUSED  AND  ON  ANY  THEORY  OF  LIABILITY,  WHETHER IN
 *      CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING
 *	IN ANY WAY OUT OF THE USE  OF THIS SOFTWARE, EVEN IF ADVISED OF  THE POSSIBILITY
 *	OF SUCH DAMAGE.
 *								 
 */ 
 

`define operand_width 8 ///< Operand width
`define code_width 18
`define code_depth 10 // 1024 instructions

`define code_size (1<<`code_depth) ///< Instruction memory size

`define port_width `operand_width ///< Port IO data width
`define port_depth `operand_width ///< Port id (address) width
`define port_size (1<<`port_depth) ///< Port size

`define stack_width `code_depth ///< Call/return stack width
/** Call/return stack depth */

`define stack_depth 5

`define stack_size (1<<`stack_depth) ///< Call/return stack size

`define register_width `operand_width ///< Register file width
/** Register file depth */

`define register_depth 4

`define register_size (1<<`register_depth) ///< Register file size


`define scratch_width `operand_width ///< Scratchpad ram width
`define scratch_depth 6 ///< Scratchpad ram depth
`define scratch_size (1<<`scratch_depth) ///< Scratchpad ram size



`define operation_width 5



`define reset_vector 0 ///< Reset vector
`define interrupt_vector (`code_size-1) ///< Interrupt vector


/** Operation string names */
`define os_load "load"
`define os_add "add"
`define os_addcy "addcy"
`define os_and "and"
`define os_or "or"
`define os_rs "rs"
`define os_sr0 "sr0"
`define os_sr1 "sr1"
`define os_srx "srx"
`define os_sra "sra"
`define os_rr "rr"
`define os_sl0 "sl0"
`define os_sl1 "sl1"
`define os_slx "slx"
`define os_sla "sla"
`define os_rl "rl"
`define os_sub "sub"
`define os_subcy "subcy"
`define os_xor "xor"
`define os_jump "jump"
`define os_call "call"
`define os_return "return"
`define os_returni "returni"
`define os_interrupt "interrupt"
`define os_input "input"
`define os_output "output"
`define os_invalid "(n/a)"
// PB3
`define os_compare "compare"
`define os_test "test"
`define os_fetch "fetch"
`define os_store "store"
// PB3M
`define os_mul "mul"
`define os_addw "addw"
`define os_addwcy "addwcy"
`define os_subw "subw"
`define os_subwcy "subwcy"

// flags
`define os_z "z "
`define os_nz "nz"
`define os_c "c "
`define os_nc "nc"
// interrupt
`define os_enable "enable "
`define os_disable "disable"


/** Conditional flags */
`define flag_z 2'b00 // zero set
`define flag_nz 2'b01 // zero not set
`define flag_c 2'b10 // carry set
`define flag_nc 2'b11 // carry not set

/** Rotate/shift operations */
`define opcode_rsc 2'b11 // shift constant
`define opcode_rsa 2'b00 // shift all (through carry)
`define opcode_rr 2'b10
`define opcode_slx 2'b10
`define opcode_rl 2'b01
`define opcode_srx 2'b01



`define opcode_add 5'h0c
`define opcode_addcy 5'h0d
`define opcode_and 5'h05
`define opcode_compare 5'h0a
`define opcode_or 5'h06
`define opcode_rs 5'h10
`define opcode_sub 5'h0e
`define opcode_subcy 5'h0f
`define opcode_test 5'h09
`define opcode_xor 5'h07

`define opcode_call 5'h18
`define opcode_interrupt 5'h1e
`define opcode_fetch 5'h03
`define opcode_input 5'h02
`define opcode_jump 5'h1a
`define opcode_load 5'h00
`define opcode_output 5'h16
`define opcode_return 5'h15
`define opcode_returni 5'h1c
`define opcode_store 5'h17

`define op_load `opcode_load
`define op_add `opcode_add
`define op_addcy `opcode_addcy
`define op_and `opcode_and
`define op_or `opcode_or
`define op_rs `opcode_rs
`define op_sub `opcode_sub
`define op_subcy `opcode_subcy
`define op_xor `opcode_xor
`define op_jump `opcode_jump
`define op_call `opcode_call
`define op_return `opcode_return
`define op_returni `opcode_returni
`define op_interrupt `opcode_interrupt
`define op_input `opcode_input
`define op_output `opcode_output
`define op_compare `opcode_compare
`define op_test `opcode_test
`define op_fetch `opcode_fetch
`define op_store `opcode_store


`define operation(x) (x)
`define operation_set(x) operation = (x)
`define operation_is(x) (operation == (x))

/** Top PacoBlaze module */
module pacoblaze3(
	address, instruction,
	port_id,
	write_strobe, out_port,
	read_strobe, in_port,
	interrupt,
	interrupt_ack,
	reset, clk
		  );
   output [`code_depth-1:0] address; ///< Address output
   input [`code_width-1:0]  instruction; ///< Instruction input
   output [`port_depth-1:0] port_id; ///< Port address
   output 		    write_strobe; ///< Port output strobe
   output [`port_width-1:0] out_port; ///< Port output
   output 		    read_strobe; ///< Port input strobe
   input [`port_width-1:0]  in_port; ///< Port input
   input 		    interrupt; ///< Interrupt request
   output 		    interrupt_ack; ///< Interrupt acknowledge (output)
   input 		    reset; ///< Reset input
   input 		    clk; ///< Clock input
   
   /* Output registers */
   reg 			    write_strobe, read_strobe;

   /* Processor registers and signals */
   reg [`code_depth-1:0]    program_counter; ///< Program counter
   reg 			    timing_control; ///< Timing control register
   
   reg 			    zero; ///< Zero flag
   reg 			    carry; ///< Carry flag
   reg 			    interrupt_enable; ///< Interrupt enable
   reg 			    interrupt_latch; ///< Interrupt latch hold
   reg 			    interrupt_ack; ///< Interrupt acknowledge
   reg 			    zero_saved; ///< Interrupt-saved zero flag
reg carry_saved; ///< Interrupt-saved carry flag
   
   reg [1:0] reset_latch; ///< Reset latch
   
   reg 	     zero_carry_write_enable; ///< Zero/Carry update
   
   wire      internal_reset; ///< Internal reset signal
   wire [`code_depth-1:0] program_counter_source, program_counter_next; ///< Next program counter logic
   wire 		  conditional_match; ///< True when unconditional or flags match
   wire 		  interrupt_assert; ///< True when interrupt condition is met
   
   
   /* IDU - Instruction Decode Unit */
   wire [`operation_width-1:0] idu_operation;
   wire [2:0] 		       idu_shift_operation;
   wire 		       idu_shift_direction, idu_shift_constant;
   wire 		       idu_operand_selection;
   wire [`register_depth-1:0]  idu_x_address, idu_y_address;
   wire [`operand_width-1:0]   idu_implied_value;
   wire [`port_depth-1:0]      idu_port_address;
   wire [`scratch_depth-1:0]   idu_scratch_address;
   wire [`code_depth-1:0]      idu_code_address;
   wire 		       idu_conditional;
   wire [1:0] 		       idu_condition_flags;
   wire 		       idu_interrupt_enable;
   
   
   pacoblaze3_idu idu(
		      instruction,
		      idu_operation,
		      idu_shift_operation, idu_shift_direction, idu_shift_constant,
		      idu_operand_selection,
		      idu_x_address, idu_y_address,
		      idu_implied_value, idu_port_address,
		      idu_scratch_address,
		      idu_code_address,
		      idu_conditional, idu_condition_flags,
		      idu_interrupt_enable
		      );
   
   
   /* ALU - Arithmetic-Logic Unit */
   wire [`operand_width-1:0]   alu_result, alu_operand_a, alu_operand_b;
   wire 		       alu_zero_out, alu_carry_out;
   
   
   pacoblaze3_alu alu(
		      idu_operation,
		      idu_shift_operation, idu_shift_direction, idu_shift_constant,
		      alu_result, alu_operand_a, alu_operand_b,
		      carry, alu_zero_out, alu_carry_out
		      
		      );
   
   /*
wire is_alu =
    // `operation_is(`op_load)
    idu_operation == (`op_and)
    || idu_operation == (`op_or)
    || idu_operation == (`op_xor)
    || idu_operation == (`op_add)
    || idu_operation == (`op_addcy)
    || idu_operation == (`op_sub)
    || idu_operation == (`op_subcy)
    || idu_operation == (`op_rs)
    || idu_operation == (`op_compare)
    || idu_operation == (`op_test)
    ;
*/

/* Register file */
reg register_x_write_enable;
wire [`register_width-1:0] register_x_data_in, register_x_data_out, register_y_data_out;


pacoblaze3_register register(
	idu_x_address, register_x_write_enable, register_x_data_in, register_x_data_out,
	idu_y_address, register_y_data_out,
	reset, clk
);

/* Call/return stack */
wire stack_write_enable, stack_update_enable, stack_push_pop;
wire [`stack_width-1:0] stack_data_in = program_counter;
wire [`stack_width-1:0] stack_data_out;

pacoblaze3_stack stack(
	stack_write_enable, stack_update_enable, stack_push_pop, stack_data_in, stack_data_out,
	reset, clk
);

/* Scratchpad RAM */

reg scratch_write_enable;
wire [`scratch_depth-1:0] scratch_address =
	(idu_operand_selection == 0) ? idu_scratch_address :
	register_y_data_out[`scratch_depth-1:0];
wire [`scratch_width-1:0] scratch_data_out;

pacoblaze3_scratch scratch(
	scratch_address, scratch_write_enable, register_x_data_out, scratch_data_out,
	reset, clk
);


/* Miscellaneous */
assign address = program_counter;

assign out_port = register_x_data_out;
assign port_id =
	(idu_operand_selection == 0) ? idu_port_address : register_y_data_out;


assign internal_reset = reset_latch[1];


assign conditional_match =
	(!idu_conditional
	|| idu_condition_flags == `flag_c && carry
	|| idu_condition_flags == `flag_nc && ~carry
	|| idu_condition_flags == `flag_z && zero
	|| idu_condition_flags == `flag_nz && ~zero
	) ? 1 : 0;

wire is_jump = idu_operation == (`op_jump);
wire is_call = idu_operation == (`op_call);
wire is_return = idu_operation == (`op_return);
wire is_returni = idu_operation == (`op_returni);
wire is_input = idu_operation == (`op_input);
wire is_fetch = idu_operation == (`op_fetch);


assign program_counter_source =
	(interrupt_latch) ? `interrupt_vector :
	(conditional_match && (is_jump || is_call)) ? idu_code_address : // PC from opcode
	(conditional_match && is_return || is_returni) ? stack_data_out : // PC from stack
	program_counter; // current PC

assign program_counter_next =
	(interrupt_latch ||
	conditional_match && (is_jump || is_call)
	|| is_returni) ? program_counter_source : // PC not incremented
	program_counter_source + 1; // PC must be incremented

assign interrupt_assert = interrupt && interrupt_enable;

assign stack_write_enable =
	internal_reset || timing_control; // update stack at reset and T==1
assign stack_update_enable = ~timing_control &&
	(conditional_match && (is_call || is_return)
	|| is_returni
	|| interrupt_latch);
assign stack_push_pop = interrupt_latch ||
	((conditional_match && is_return || is_returni) ? 0 : 1);

assign alu_operand_a = register_x_data_out;
assign alu_operand_b =
	(idu_operand_selection == 0) ? idu_implied_value : register_y_data_out;
assign register_x_data_in =
	(is_fetch) ? scratch_data_out :
	(is_input) ? in_port : alu_result;



/*
task decode;
input [`operation_width-1:0] operation;
begin
end
endtask
*/

/* Combinatorial main block */
/*
always @(program_counter) begin: com
end
*/

/* Sequential internal reset control */

always @(posedge clk or posedge reset) 
  begin: on_reset
     if (reset) 
       begin
	  reset_latch <= 'b11; // initialize latch
       end
     else 
       begin
	  reset_latch[1] <= reset_latch[0]; // shift latch
	  reset_latch[0] <= 0;
       end
  end // block: on_reset
   


   /* Begin DBS */
   reg t_write_strobe;
   reg t_read_strobe;
   
   reg t_timing_control;
   reg [`code_depth-1:0] t_program_counter;

   reg 			 t_zero;
   reg 			 t_carry;

   reg 			 t_zero_saved;
   reg 			 t_carry_saved;
      

   reg 			 t_interrupt_enable;
   reg 			 t_interrupt_latch;
   reg 			 t_register_x_write_enable;
   reg 			 t_scratch_write_enable;
   reg 			 t_interrupt_ack;
   reg 			 t_zero_carry_write_enable;

   

   always@(*)
     begin
	
	/* Idle values and default actions */
	t_read_strobe = 0; 
	t_write_strobe = 0;
	t_register_x_write_enable = 0;
	t_scratch_write_enable = 0;
	
	t_interrupt_ack = 0;
	t_zero_carry_write_enable = 0;

	t_timing_control = ~timing_control;
	t_interrupt_latch = interrupt_assert | interrupt_latch;

	//non-defaults
	t_program_counter = program_counter;
	t_interrupt_enable = interrupt_enable;
	t_zero = zero;
	t_carry = carry;

	t_zero_saved = zero_saved;
	t_carry_saved = carry_saved;
		

	if(timing_control == 0)
	  begin
	     t_program_counter = program_counter_next;
	     if(interrupt_latch)
	       begin
		  t_interrupt_enable = 0; 
		  t_interrupt_latch = 0; // clear interrupt
		  t_interrupt_ack = 1; // acknowledge interrupt
		  t_zero_saved = zero; 
		  t_carry_saved = carry; // save flags
	       end
	     else
	      begin
 		 case (idu_operation)
		   `operation(`op_load): 
		     begin
			t_register_x_write_enable = 1; // load register with value
		     end
		   
		    `operation(`op_and),
		      `operation(`op_or),
		      `operation(`op_xor),
		      `operation(`op_add),
		      `operation(`op_addcy),
		      `operation(`op_sub),
		      `operation(`op_subcy),
		      `operation(`op_rs): 
			begin
			   t_register_x_write_enable = 1; // writeback register
			   t_zero_carry_write_enable = 1; // writeback zero, carry
			end
		    
		   `operation(`op_returni): 
		     begin
			t_zero = zero_saved; 
			t_carry = carry_saved; // restore flags
			t_interrupt_enable = idu_interrupt_enable; // return with interrupt enabled/disabled
		      end
		   
		   `operation(`op_interrupt): 
		     begin
			t_interrupt_enable = idu_interrupt_enable; // enable/disable interrupt
		     end
		   
		   `operation(`op_input): 
		     begin
			t_read_strobe = 1; // flag read
			t_register_x_write_enable = 1; // write into register
		     end
		    
		   `operation(`op_output): 
		     begin
			t_write_strobe = 1; // flag write
		     end
		   
		   `operation(`op_compare): 
		     begin
			t_zero_carry_write_enable = 1; // writeback zero, carry
		      end
		   
		   `operation(`op_test):
		     begin
			t_zero_carry_write_enable = 1; // writeback zero, carry
		     end
		   
		   `operation(`op_fetch): 
		     begin
			t_register_x_write_enable = 1;
		     end 
		   
		   `operation(`op_store): 
		     begin
			t_scratch_write_enable = 1;
		     end
		   
		   default: ;
		 endcase
	      end
	  end // if (timing_control == 0)
	else
	  begin
	     if (zero_carry_write_enable) 
	       begin
		  t_zero = alu_zero_out; 
		  t_carry = alu_carry_out; // update alu flags
	       end
	  end // else: !if(timing_control == 0)
     end // always@ (*)
   	     
   

/* Sequential main block */
always @(posedge clk or posedge internal_reset) 
  begin: seq
      
     if (internal_reset) 
       begin: on_internal_reset
	  /* Reset values */
	  timing_control <= 0;
	  program_counter <= `reset_vector; // load reset vector
	  zero <= 0; 
	  carry <= 0; // flags begin cleared
	  interrupt_enable <= 0; 
	  interrupt_latch <= 0; // interrupts disabled at reset

	  zero_saved <= 0;
	  carry_saved <= 0;
	  

	  /* Idle values and default actions */
	  read_strobe <= 0; 
	  write_strobe <= 0;
	  register_x_write_enable <= 0;
	  scratch_write_enable <= 0;
	  
	  interrupt_ack <= 0;
	  zero_carry_write_enable <= 0;
	  
	  
       end
     else 
       begin: on_run
	  timing_control <= t_timing_control;
	  program_counter <= t_program_counter;
	  zero <= t_zero;
	  carry <= t_carry;
	  interrupt_enable <= t_interrupt_enable;
	  interrupt_latch <= t_interrupt_latch;

	  zero_saved <= t_zero_saved;
	  carry_saved <= t_carry_saved;
	  
	  /* Idle values and default actions */
	  read_strobe <= t_read_strobe;
	  write_strobe <= t_write_strobe;
	  
	  register_x_write_enable <= t_register_x_write_enable;
	  scratch_write_enable <= t_scratch_write_enable;
	  
	  interrupt_ack <= t_interrupt_ack;
	  zero_carry_write_enable <= t_zero_carry_write_enable;
       end
  end // block: seq
   
endmodule


module pacoblaze3_idu(
	instruction,
	operation,
	shift_operation, shift_direction, shift_constant,
	operand_selection,
	x_address, y_address,
	implied_value, port_address,
	scratch_address,
	code_address,
	conditional, condition_flags,
	interrupt_enable
);
input [`code_width-1:0] instruction; ///< Instruction
output reg [`operation_width-1:0] operation; ///< Main operation
output [2:0] shift_operation; ///< Rotate/shift operation
output shift_direction; ///< Rotate/shift left(0)/right(1)
output shift_constant; ///< Shift constant value
output operand_selection; ///< Operand selection (k/p/s:0, y:1)
output [`register_depth-1:0] x_address, y_address; ///< Operation x source/target, y source
output [`operand_width-1:0] implied_value; ///< Operand constant source
output [`port_depth-1:0] port_address; ///< Port address

output [`scratch_depth-1:0] scratch_address; ///< Scratchpad address

output [`code_depth-1:0] code_address; ///< Program address
output conditional; ///< Conditional operation (unconditional(0)/conditional(1))
output [1:0] condition_flags; ///< Condition flags on zero and carry
output interrupt_enable; ///< Interrupt disable(0)/enable(1)


assign shift_direction = instruction[3];
assign shift_operation = instruction[2:1];
assign shift_constant = instruction[0];

assign conditional = instruction[12];
assign condition_flags = instruction[11:10];

assign implied_value = instruction[7:0];
assign port_address = instruction[7:0];


wire [4:0] instruction_0 = instruction[17:13];

assign x_address = instruction[11:8];
assign y_address = instruction[7:4];
assign operand_selection = instruction[12];
assign code_address = instruction[9:0];
assign interrupt_enable = instruction[0];
assign scratch_address = instruction[5:0];



always @(instruction_0)
begin

	operation = 'h0; // default
	// synthesis parallel_case full_case

	case (instruction_0)


		`opcode_load: `operation_set(`op_load);
		`opcode_add: `operation_set(`op_add);
		`opcode_addcy: `operation_set(`op_addcy);
		`opcode_and: `operation_set(`op_and);
		`opcode_or: `operation_set(`op_or);
		`opcode_rs: `operation_set(`op_rs);
		`opcode_sub: `operation_set(`op_sub);
		`opcode_subcy: `operation_set(`op_subcy);
		`opcode_xor: `operation_set(`op_xor);


		`opcode_jump: `operation_set(`op_jump);
		`opcode_call: `operation_set(`op_call);
		`opcode_return: `operation_set(`op_return);
		`opcode_returni: `operation_set(`op_returni);
		`opcode_interrupt: `operation_set(`op_interrupt);
		`opcode_input: `operation_set(`op_input);
		`opcode_output: `operation_set(`op_output);

		`opcode_compare: `operation_set(`op_compare);

		`opcode_test: `operation_set(`op_test);


		`opcode_fetch: `operation_set(`op_fetch);
		`opcode_store: `operation_set(`op_store);



		// default: `operation_set(0);
	endcase
end


endmodule


module pacoblaze3_alu(
	operation,
	shift_operation, shift_direction, shift_constant,
	result, operand_a, operand_b,
	carry_in, zero_out, carry_out

);
input [`operation_width-1:0] operation; ///< Main operation
input [2:0] shift_operation; ///< Rotate/shift operation
input shift_direction; ///< Rotate/shift left(0)/right(1)
input shift_constant; ///< Shift constant (0 or 1)
output reg [`operand_width-1:0] result; ///< ALU result
input [`operand_width-1:0] operand_a, operand_b; ///< ALU operands
input carry_in; ///< Carry in
output zero_out; ///< Zero out
output reg carry_out; ///< Carry out


/** Adder/substracter second operand. */
wire [`operand_width-1:0] addsub_b =
	(`operation_is(`op_sub)
	|| `operation_is(`op_subcy)
	|| `operation_is(`op_compare)
	) ? ~operand_b :
	operand_b;


/** Adder/substracter carry. */
wire addsub_carry =
	(`operation_is(`op_addcy)
	) ? carry_in :
	(`operation_is(`op_sub)
	|| `operation_is(`op_compare)
	) ? 1 : // ~b => b'
	(`operation_is(`op_subcy)
	) ? ~carry_in : // ~b - c => b' - c
	0;

/** Adder/substracter with carry. */
wire [1+`operand_width-1:0] addsub_result = operand_a + addsub_b + addsub_carry;


/** Shift bit value. */
// synthesis parallel_case full_case
wire shift_bit =
	(shift_operation == `opcode_rr) ? operand_a[0] : // == `opcode_slx
	(shift_operation == `opcode_rl) ? operand_a[7] : // == `opcode_srx
	(shift_operation == `opcode_rsa) ? carry_in :
	shift_constant; // == `opcode_rsc



assign zero_out =
	~|result;


/*
always @(operation,
	shift_operation, shift_direction, shift_constant, shift_bit,
	result, operand_a, operand_b, carry_in, carry_out,
	addsub_result, addsub_b, addsub_carry
`ifdef HAS_WIDE_ALU
	, resultw, operand_v, addsubw_result
`endif
	) begin
	$display("op:%b %h (%h)=(%h),(%h)", operation, operation, result, operand_a, operand_b);
	$display("as:%h=%h+%h+%b", addsub_result, operand_a, addsub_b, addsub_carry);
end
*/

// always @*
always @(operation,
	shift_operation, shift_direction, shift_constant, shift_bit,
	result, operand_a, operand_b, carry_in, carry_out,
	addsub_result, addsub_carry

	) begin: on_alu
	/* Defaults */
	carry_out = 0;

	// synthesis parallel_case full_case

	case (operation)


		`operation(`op_add),
		`operation(`op_addcy):
			{carry_out, result} = addsub_result;
		`operation(`op_compare),

		`operation(`op_sub),
		`operation(`op_subcy): begin
			{carry_out, result} = {~addsub_result[8], addsub_result[7:0]};
		end

		`operation(`op_and):
			result = operand_a & operand_b;

		`operation(`op_or):
			result = operand_a | operand_b;


		`operation(`op_test):
			begin result = operand_a & operand_b; carry_out = ^result; end


		`operation(`op_xor):
			result = operand_a ^ operand_b;

		`operation(`op_rs):
			if (shift_direction) // shift right
				{result, carry_out} = {shift_bit, operand_a};
			else // shift left
				{carry_out, result} = {operand_a, shift_bit};
		default:
			result = operand_b;

	endcase

end
endmodule


module pacoblaze3_register(
	x_address, x_write_enable, x_data_in, x_data_out,
	y_address, y_data_out,
	reset, clk
);
input clk, reset, x_write_enable;
input [`register_depth-1:0] x_address, y_address;
input [`register_width-1:0] x_data_in;
output [`register_width-1:0] x_data_out, y_data_out;

reg [`register_width-1:0] dpr[0:`register_size-1];

assign x_data_out = dpr[x_address];
assign y_data_out = dpr[y_address];

always @(posedge clk or posedge reset)
  begin
     if(reset)
       begin
	  dpr[4'd0] <= 8'd0;
	  dpr[4'd1] <= 8'd0;
	  dpr[4'd2] <= 8'd0;
	  dpr[4'd3] <= 8'd0;
	  dpr[4'd4] <= 8'd0;
	  dpr[4'd5] <= 8'd0;
	  dpr[4'd6] <= 8'd0;
	  dpr[4'd7] <= 8'd0;
	  dpr[4'd8] <= 8'd0;
	  dpr[4'd9] <= 8'd0;
	  dpr[4'd10] <= 8'd0;
	  dpr[4'd11] <= 8'd0;
	  dpr[4'd12] <= 8'd0;
	  dpr[4'd13] <= 8'd0;
	  dpr[4'd14] <= 8'd0;
	  dpr[4'd15] <= 8'd0;
       end
     else
       begin
          if (x_write_enable) 
	    begin
	       dpr[x_address] <= x_data_in;
	    end
       end
     
  end // always @ (posedge clk or posedge reset)
   
   
endmodule


module pacoblaze3_stack(
	write_enable, update_enable, push_pop, data_in, data_out,
	reset, clk
);
   input clk, reset, write_enable, update_enable, push_pop; // push:1, pop:0
   input [`stack_width-1:0] data_in;
   output [`stack_width-1:0] data_out;
   
   reg [`stack_width-1:0]    spr[0:`stack_size-1]; // single port ram memory
   reg [`stack_depth-1:0]    ptr; // stack pointer
   
   wire [`stack_depth-1:0]   ptr_1 =
			     (push_pop) ? ptr + 1 : ptr - 1;
   
   assign data_out = spr[ptr_1];
   
   
   always @(posedge clk or posedge reset)
     begin
	if (reset) 
	  begin
	     ptr <= 0;

	     spr[5'd0] <= 10'd0;
	     spr[5'd1] <= 10'd0;
	     spr[5'd2] <= 10'd0;
	     spr[5'd3] <= 10'd0;
	     spr[5'd4] <= 10'd0;
	     spr[5'd5] <= 10'd0;
	     spr[5'd6] <= 10'd0;
	     spr[5'd7] <= 10'd0;
	     spr[5'd8] <= 10'd0;
	     spr[5'd9] <= 10'd0;
	     spr[5'd10] <= 10'd0;
	     spr[5'd11] <= 10'd0;
	     spr[5'd12] <= 10'd0;
	     spr[5'd13] <= 10'd0;
	     spr[5'd14] <= 10'd0;
	     spr[5'd15] <= 10'd0;

	     spr[5'd16] <= 10'd0;
	     spr[5'd17] <= 10'd0;
	     spr[5'd18] <= 10'd0;
	     spr[5'd19] <= 10'd0;
	     spr[5'd20] <= 10'd0;
	     spr[5'd21] <= 10'd0;
	     spr[5'd22] <= 10'd0;
	     spr[5'd23] <= 10'd0;
	     spr[5'd24] <= 10'd0;
	     spr[5'd25] <= 10'd0;
	     spr[5'd26] <= 10'd0;
	     spr[5'd27] <= 10'd0;
	     spr[5'd28] <= 10'd0;
	     spr[5'd29] <= 10'd0;
	     spr[5'd30] <= 10'd0;
	     spr[5'd31] <= 10'd0;
	  end
	
	else 
	  begin
	     if (write_enable) spr[ptr] <= data_in;
	     if (update_enable) ptr <= ptr_1;
	  end
     end // always @ (posedge clk or posedge reset)
      
endmodule


module pacoblaze3_scratch(
	address, write_enable, data_in, data_out,
	reset, clk
);
   input clk, reset, write_enable;
   input [`scratch_depth-1:0] address;
   input [`scratch_width-1:0] data_in;
   output [`scratch_width-1:0] data_out;

   reg [`scratch_width-1:0] spr[0:`scratch_size-1];

   assign data_out = spr[address];
   
   always @(posedge clk or posedge reset)
     begin
	if(reset)
	  begin
	     spr[6'd0] <= 8'd0;
	     spr[6'd1] <= 8'd0;
	     spr[6'd2] <= 8'd0;
	     spr[6'd3] <= 8'd0;
	     spr[6'd4] <= 8'd0;
	     spr[6'd5] <= 8'd0;
	     spr[6'd6] <= 8'd0;
	     spr[6'd7] <= 8'd0;
	     spr[6'd8] <= 8'd0;
	     spr[6'd9] <= 8'd0;
	     spr[6'd10] <= 8'd0;
	     spr[6'd11] <= 8'd0;
	     spr[6'd12] <= 8'd0;
	     spr[6'd13] <= 8'd0;
	     spr[6'd14] <= 8'd0;
	     spr[6'd15] <= 8'd0;

	     spr[6'd16] <= 8'd0;
	     spr[6'd17] <= 8'd0;
	     spr[6'd18] <= 8'd0;
	     spr[6'd19] <= 8'd0;
	     spr[6'd20] <= 8'd0;
	     spr[6'd21] <= 8'd0;
	     spr[6'd22] <= 8'd0;
	     spr[6'd23] <= 8'd0;
	     spr[6'd24] <= 8'd0;
	     spr[6'd25] <= 8'd0;
	     spr[6'd26] <= 8'd0;
	     spr[6'd27] <= 8'd0;
	     spr[6'd28] <= 8'd0;
	     spr[6'd29] <= 8'd0;
	     spr[6'd30] <= 8'd0;
	     spr[6'd31] <= 8'd0;
 
	     spr[6'd32] <= 8'd0;
	     spr[6'd33] <= 8'd0;
	     spr[6'd34] <= 8'd0;
	     spr[6'd35] <= 8'd0;
	     spr[6'd36] <= 8'd0;
	     spr[6'd37] <= 8'd0;
	     spr[6'd38] <= 8'd0;
	     spr[6'd39] <= 8'd0;
	     spr[6'd40] <= 8'd0;
	     spr[6'd41] <= 8'd0;
	     spr[6'd42] <= 8'd0;
	     spr[6'd43] <= 8'd0;
	     spr[6'd44] <= 8'd0;
	     spr[6'd45] <= 8'd0;
	     spr[6'd46] <= 8'd0;
	     spr[6'd47] <= 8'd0;

	     spr[6'd48] <= 8'd0;
	     spr[6'd49] <= 8'd0;
	     spr[6'd50] <= 8'd0;
	     spr[6'd51] <= 8'd0;
	     spr[6'd52] <= 8'd0;
	     spr[6'd53] <= 8'd0;
	     spr[6'd54] <= 8'd0;
	     spr[6'd55] <= 8'd0;
	     spr[6'd56] <= 8'd0;
	     spr[6'd57] <= 8'd0;
	     spr[6'd58] <= 8'd0;
	     spr[6'd59] <= 8'd0;
	     spr[6'd60] <= 8'd0;
	     spr[6'd61] <= 8'd0;
	     spr[6'd62] <= 8'd0;
	     spr[6'd63] <= 8'd0;
	     
	  end
	else
	  begin
	     if (write_enable)
	       begin
		  spr[address] <= data_in;
	       end
	  end // else: !if(reset)
     end // always @ (posedge clk or posedge reset)
   
   
endmodule


