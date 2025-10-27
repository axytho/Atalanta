`timescale 1ns / 1ps

//All rights reserved
// Author: Jonas Bertels on behalf of COSIC, KU Leuven
// MAY NOT BE REPRODUCED

`define LOG_N 8
`define RING_SIZE       (1 << 8)
`define NTT_POLYNOMIAL_SIZE (1<<`LOG_N)
`define RING_DEPTH       ($clog2(`RING_SIZE))
`define STAGE_SIZE      `RING_DEPTH
`define NTT_DIV_BY_RING (`NTT_POLYNOMIAL_SIZE>>`RING_DEPTH)



`define PRECOMP_FACTOR   1 //changes depending on whether we do K-red or mod-red or something else
`define PRECOMP_FACTOR_NORMAL_MULT   524289
`define INVERSE_N 3329
`define BUTTERFLY_SIZE  (`RING_SIZE>>1)
`define MODULUS_WIDTH   12
`define GOLD_MODULUS_WIDTH 12
`define HBM_ELEMENT_SIZE 16
`define HBM_ELEMENT_DEPTH 4
`define MODULUS       12'b110100000001
//`define MODULUSHALF     {1'b0,(`MODULUS>>1)}
`define MODULUSHALFPLUSONE     {1'b0,(`MODULUS>>1)+1}
`define MODULUSEIGHTH    {3'b0,`MODULUS>>3}
`define SECTIONS 3 //`MODULUS/5
`define TWIDDLE_2048 17
`define INVERSE_TWIDDLE_2048 1175

`define BUTTER_FLY_REGISTERS (`PEARL_LATENCY+2)  
`define JEWEL_REGISTERS 2
`define TAIL_REDUCTION 2

`define MULTIPLIER_LATENCY 4
`define REDUCTION_LATENCY 2
`define PEARL_LATENCY 5