`timescale 1ns / 1ps

//All rights reserved
// Author: Jonas Bertels on behalf of COSIC, KU Leuven
// MAY NOT BE REPRODUCED

//NTT application-specific user-defined parameters
// i.e. the cryptographical algorithm usually decides what goes here
// although the user may have some lattitude in picking the modulus
// (contact your local cryptographer for more details)
`define LOG_N 8
`define MODULUS       12'b110100000001

//NTT hardware-specific user-defined parameters


`define PRECOMP_FACTOR   1 //changes depending on whether we do K-red or mod-red or something else
`define PRECOMP_FACTOR_NORMAL_MULT   524289
`define INVERSE_N 3329
`define SECTIONS 3 //`MODULUS/5
`define TWIDDLE_2048 17
`define INVERSE_TWIDDLE_2048 1175

`define COEF_PER_CLOCK_CYCLE       (1 << 8)
`define NTT_POLYNOMIAL_SIZE (1<<`LOG_N)
`define RING_DEPTH       ($clog2(`COEF_PER_CLOCK_CYCLE))
`define STAGE_SIZE      `RING_DEPTH
`define NTT_DIV_BY_RING (`NTT_POLYNOMIAL_SIZE>>`RING_DEPTH)




`define BUTTERFLY_SIZE  (`COEF_PER_CLOCK_CYCLE>>1)
`define MODULUS_WIDTH   12
`define GOLD_MODULUS_WIDTH 12
`define HBM_ELEMENT_SIZE 16
`define HBM_ELEMENT_DEPTH 4
//`define MODULUSHALF     {1'b0,(`MODULUS>>1)}
`define MODULUSHALFPLUSONE     {1'b0,(`MODULUS>>1)+1}
`define MODULUSEIGHTH    {3'b0,`MODULUS>>3}


`define BUTTER_FLY_REGISTERS (`PEARL_LATENCY+2)  
`define JEWEL_REGISTERS 2
`define TAIL_REDUCTION 2

`define MULTIPLIER_LATENCY 4
`define REDUCTION_LATENCY 2
`define PEARL_LATENCY 5