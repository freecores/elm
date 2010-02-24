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


/* Reset to all ELM memories (SRAM) */ 
`define ELM_MEM_RST 16'h8000

/* Reset to all ensemble processors */
`define ELM_EP_RST  16'h8001

/* Hold EP0 in stall */
`define ELM_EP0_STALL 16'h8002

/* Hold EP1 in stall */
`define ELM_EP1_STALL 16'h8003

/* Hold EP2 in stall */
`define ELM_EP2_STALL 16'h8004

/* Hold EP3 in stall */
`define ELM_EP3_STALL 16'h8005

/* Hold EP4 (Ensemble 1, EP0) in stall */
`define ELM_EP4_STALL 16'h800c

/* Hold EP5 (Ensemble 1, EP1) in stall */
`define ELM_EP5_STALL 16'h800d

/* Hold EP6 (Ensemble 1, EP2) in stall */
`define ELM_EP6_STALL 16'h800e

/* Hold EP7 (Ensemble 1, EP3) in stall */
`define ELM_EP7_STALL 16'h800f


/* Boot vector addrees registers */
`define ELM_EP0_BOOT_VECTOR 16'h8014
`define ELM_EP1_BOOT_VECTOR 16'h8015
`define ELM_EP2_BOOT_VECTOR 16'h8016
`define ELM_EP3_BOOT_VECTOR 16'h8017
`define ELM_EP4_BOOT_VECTOR 16'h8018
`define ELM_EP5_BOOT_VECTOR 16'h8019
`define ELM_EP6_BOOT_VECTOR 16'h801a
`define ELM_EP7_BOOT_VECTOR 16'h801b



/* Test mode for ensemble memories */
`define ELM_MEM_TEST_MODE 16'h8006


/* Vector of EP's HCF pins */
`define ELM_HCF_VECTOR  16'h8007

/* Cycle counters for each EP */
`define ELM_EP0_CYC_CNT 16'h8008
`define ELM_EP1_CYC_CNT 16'h8009
`define ELM_EP2_CYC_CNT 16'h800a
`define ELM_EP3_CYC_CNT 16'h800b
`define ELM_EP4_CYC_CNT 16'h8010
`define ELM_EP5_CYC_CNT 16'h8011
`define ELM_EP6_CYC_CNT 16'h8012
`define ELM_EP7_CYC_CNT 16'h8013





/* Ensemble 0, Bank 0 pacoblaze start address */
`define E0_B0_START 16'd0
/* Ensemble 0, Bank 0 pacoblaze end address */
`define E0_B0_END   16'd511

/* Ensemble 0, Bank 1 pacoblaze start address */
`define E0_B1_START 16'd512
/* Ensemble 0, Bank 1 pacoblaze end address */
`define E0_B1_END   16'd1023

/* Ensemble 0, Bank 2 pacoblaze start address */
`define E0_B2_START 16'd1024
/* Ensemble 0, Bank 2 pacoblaze end address */
`define E0_B2_END   16'd1535

/* Ensemble 0, Bank 3 pacoblaze start address */
`define E0_B3_START 16'd1536
/* Ensemble 0, Bank 3 pacoblaze end address */
`define E0_B3_END   16'd2047

/* On chip memory pacoblaze start adddres */
`define OCM_START   16'd2048

/* On chip memory pacoblaze end address */
`define OCM_END     16'd10239

/* Ensemble 1, Bank 0 pacoblaze start address */
`define E1_B0_START 16'd10240

/* Ensemble 1, Bank 0 pacoblaze end address */
`define E1_B0_END   16'd10751

/* Ensemble 1, Bank 1 pacoblaze start address */
`define E1_B1_START 16'd10752

/* Ensemble 1, Bank 1 pacoblaze end address */
`define E1_B1_END   16'd11263

/* Ensemble 1, Bank 2 pacoblaze start address */
`define E1_B2_START 16'd11264

/* Ensemble 1, Bank 2 pacoblaze end address */
`define E1_B2_END  16'd11775

/* Ensemble 1, Bank 3 pacoblaze start address */
`define E1_B3_START 16'd11776

/* Ensemble 1, Bank 3 pacoblaze end address */
`define E1_B3_END   16'd12287

