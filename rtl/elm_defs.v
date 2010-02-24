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

`define ZR    7'b0000000
`define LR    7'b0000001
`define TR0   7'b0000010
`define TR1   7'b0000011
`define AS0   7'b0000100
`define AS1   7'b0000101
`define AS2   7'b0000110
`define AS3   7'b0000111
`define AR0   7'b0001000
`define AR1   7'b0001001
`define AR2   7'b0001010
`define AR3   7'b0001011
`define DR0   7'b0001100
`define DR1   7'b0001101
`define DR2   7'b0001110
`define DR3   7'b0001111
`define XP0   7'b0010000
`define XP1   7'b0010001
`define XP2   7'b0010010
`define XP3   7'b0010011
`define PR0   7'b0010100
`define PR1   7'b0010101
`define PR2   7'b0010110
`define PR3   7'b0010111
`define MR0   7'b0011000
`define MR1   7'b0011001
`define MR2   7'b0011010
`define MR3   7'b0011011
`define MR4   7'b0011100
`define MR5   7'b0011101
`define MR6   7'b0011110
`define MR7   7'b0011111
`define GR0   7'b0100000
`define GR1   7'b0100001
`define GRF2  7'b0100010
`define GRF3  7'b0100011
`define GRF4  7'b0100100
`define GRF5  7'b0100101
`define GRF6  7'b0100110
`define GRF7  7'b0100111
`define GRF8  7'b0101000
`define GRF9  7'b0101001
`define GRF10 7'b0101010
`define GRF11 7'b0101011
`define GRF12 7'b0101100
`define GRF13 7'b0101101
`define GRF14 7'b0101110
`define GRF15 7'b0101111
`define GRF16 7'b0110000
`define GRF17 7'b0110001
`define GRF18 7'b0110010
`define GRF19 7'b0110011
`define GRF20 7'b0110100
`define GRF21 7'b0110101
`define GRF22 7'b0110110
`define GRF23 7'b0110111
`define GRF24 7'b0111000
`define GRF25 7'b0111001
`define GRF26 7'b0111010
`define GRF27 7'b0111011
`define GRF28 7'b0111100
`define GRF29 7'b0111101
`define GRF30 7'b0111110
`define GRF31 7'b0111111
`define ASL0  7'b1000000
`define ASU0  7'b1000001
`define ASL1  7'b1000010
`define ASU1  7'b1000011
`define ASL2  7'b1000100
`define ASU2  7'b1000101
`define ASL3  7'b1000110
`define ASU3  7'b1000111
`define XPL0  7'b1001000
`define XPU0  7'b1001001
`define XPL1  7'b1001010
`define XPU1  7'b1001011
`define XPL2  7'b1001100
`define XPU2  7'b1001101
`define XPL3  7'b1001110
`define XPU3  7'b1001111
`define PR4   7'b1010000
`define PR5   7'b1010001
`define PR6   7'b1010010
`define PR7   7'b1010011
`define FAS0  7'b1010100
`define FAS1  7'b1010101
`define FAS2  7'b1010110
`define FAS3  7'b1010111
`define FXP0  7'b1011000
`define FXP1  7'b1011001
`define FXP2  7'b1011010
`define FXP3  7'b1011011
`define DA0   7'b1011100
`define DA1   7'b1011101
//34x UNUSED

/* Elm Opcodes */

/* ALU Instructions */

/* ALU Format 1: 
 * Opcode = 8 bits
 * Extend = 6 bits
 * Rd = 6 bits
 * Rs1 = 6 bits
 * Rs2 = 6 bits
 * 
 */

`define OP_H 31
`define OP_L 24

`define EX_H 23
`define EX_L 18

`define RD_H 17
`define RD_L 12

`define RS1_H 11
`define RS1_L 6

`define RS2_H 5
`define RS2_L 0

`define A_NOP 8'd0
`define A_MOV 8'd1
`define A_MOVI 8'd2 
//The immdiate is [rs1:extend:rs2]
`define A_ADD 8'd3
`define A_ADDI 8'd4
//The immdiate is [extend:rs2]
`define A_SUB 8'd5
`define A_SUBI 8'd6
//The immdiate is [extend:rs2]
`define A_TEST 8'd7
//The destination must be predicate

//The destination must be predicate
`define A_NEG 8'd9
`define A_ABS 8'd10
`define A_MAX 8'd11
`define A_MIN 8'd12
`define A_MUL 8'd13
//we need to include the .i/.f (opcode or extend)
`define A_MUL_F 8'd14
`define A_MAC_F 8'd15
`define A_MAC  8'd16
//we need to include the .i/.f (opcode or extend)
`define A_NOT  8'd17
`define A_CLZ  8'd18
`define A_AND  8'd19
`define A_ANDC 8'd20
`define A_OR   8'd21
`define A_XOR  8'd22
`define A_SRA  8'd23
`define A_SRAI 8'd24
//Immediate is just rs2
`define A_SRL  8'd25
`define A_SRLI 8'd26
`define A_SLA  8'd27
`define A_SLAI 8'd28
`define A_SLL  8'd29
`define A_SLLI 8'd30
`define A_SAE  8'd31
`define A_SAC  8'd32
`define A_PACKI 8'd33
`define A_UNPACKI 8'd34
`define A_PACKF 8'd35
`define A_UNPACKF 8'd36
`define A_GB 8'd37
`define A_SB 8'd38

//compare instructions
`define A_CMP_EQ 8'd39
`define A_CMP_NE 8'd40
`define A_CMP_LT 8'd41
`define A_CMP_LTE 8'd42
`define A_CMP_ULT 8'd43
`define A_CMP_ULTE 8'd44

//signed extended gb
`define A_GB_S 8'd45

`define A_SEL 8'd46
//XMU instructions
`define X_NOP 8'd0
`define X_MOV 8'd1
`define X_MOVI 8'd2 
//The immdiate is [rs1:extend:rs2]
`define X_ADD 8'd3
`define X_ADDI 8'd4
//The immdiate is [extend:rs2]
`define X_SUB 8'd5
`define X_SUBI 8'd6
//The immdiate is [extend:rs2]
`define X_TEST 8'd7


//Immediate load
`define X_LD_I 8'd9
//Immediate and register
`define X_LD_IR 8'd10
//Register + register
`define X_LD_RR 8'd11

//Which version of load (immm, r+imm, r+r) encoded in the extend?
`define X_ST_I 8'd12
`define X_ST_IR 8'd13
`define X_ST_RR 8'd14

/* Remote blocking loads */
`define X_RB_LD_I  8'd15
`define X_RB_LD_IR 8'd16
`define X_RB_LD_RR 8'd17

/* Remote blocking stores */
`define X_RB_ST_I  8'd18
`define X_RB_ST_IR 8'd19
`define X_RB_ST_RR 8'd20

/* Remote non-blocking loads */
`define X_RNB_LD_I  8'd21
`define X_RNB_LD_IR 8'd22
`define X_RNB_LD_RR 8'd23

/* Remote non-blocking stores */
`define X_RNB_ST_I  8'd24
`define X_RNB_ST_IR 8'd25
`define X_RNB_ST_RR 8'd26

//See X_LD
`define X_LDB 8'd80
`define X_STB 8'd81
`define X_LDV_OO 8'd82
`define X_LDV_RO 8'd83
`define X_LDV_RR 8'd84
`define X_STV_OO 8'd85
`define X_STV_RO 8'd86
`define X_STV_RR 8'd87
//`define X_LDR 8'd19
//`define X_STR 8'd20
//`define X_LDC 8'd21
//`define X_STC 8'd22
//`define X_LDAR 8'd23
//`define X_STAR 8'd24
//`define X_LDAC 8'd25
//`define X_STAC 8'd26
`define X_CMPSWP 8'd27
`define X_LDSD_RI 8'd28
`define X_LDSD_RR 8'd29
`define X_STSD_RI 8'd88
`define X_STSD_RR 8'd89
`define X_LDSTREAM 8'd30
`define X_STSTREAM 8'd31
`define X_SYNCSTREAM 8'd32

`define X_SEND 8'd35
`define X_RECV 8'd36
`define X_BARRIER 8'd37
`define X_FETCH_A_I 8'd38
`define X_FETCH_A_R 8'd39
`define X_FETCH_R_I 8'd40
`define X_FETCH_R_R 8'd41
`define X_JFETCH_A_I 8'd90 
`define X_JFETCH_A_R 8'd91
`define X_JFETCH_R_I 8'd92
`define X_JFETCH_R_R 8'd93


//Always jump, relative
`define X_JUMP_R 8'd42
//Always jump, absolute
`define X_JUMP_A 8'd43

//Jump set, relative
`define X_JUMPS_R 8'd44
//Jump set, absolute
`define X_JUMPS_A 8'd45

//Jump clear, relative
`define X_JUMPC_R 8'd46
//Jump clear, absolute
`define X_JUMPC_A 8'd47


//Always loop, relative
`define X_LOOP_R 8'd48
//Always loop, absolute
`define X_LOOP_A 8'd49

//loop set, relative
`define X_LOOPS_R 8'd50
//loop set, absolute
`define X_LOOPS_A 8'd51

//loop clear, relative
`define X_LOOPC_R 8'd52
//loop clear, absolute
`define X_LOOPC_A 8'd53

/* Versions of the loop instruction with immediate displacement*/

//Always loop, relative
`define X_LOOP_RI 8'd54
//Always loop, absolute
`define X_LOOP_AI 8'd55

//loop set, relative
`define X_LOOPS_RI 8'd56
//loop set, absolute
`define X_LOOPS_AI 8'd57

//loop clear, relative
`define X_LOOPC_RI 8'd58
//loop clear, absolute
`define X_LOOPC_AI 8'd59


`define X_JAL 8'd60
`define X_JLR 8'd61
`define X_JUMPSIMD 8'd62
`define X_JUMPSCALAR 8'd63
//move the jump to another register
`define X_MOV_JR 8'd64

`define X_PRED_S 8'd65
`define X_PRED_C 8'd66

`define X_CMP_EQ 8'd67
`define X_CMP_NE 8'd68
`define X_CMP_LT 8'd69
`define X_CMP_LTE 8'd70
`define X_CMP_ULT 8'd94
`define X_CMP_ULTE 8'd95

`define X_STSAVE_LO_I 8'd71
`define X_STSAVE_LO_IR 8'd72
`define X_STSAVE_HI_I 8'd73
`define X_STSAVE_HI_IR 8'd74

`define X_LDREST_LO_I 8'd75
`define X_LDREST_LO_IR 8'd76
`define X_LDREST_HI_I 8'd77
`define X_LDREST_HI_IR 8'd78

//`define X_BARRIER 8'd79

`define X_HCF 8'd250

  
