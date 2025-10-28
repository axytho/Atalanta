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
`define TWIDDLE_2N 17

//NTT hardware-specific user-defined parameters
`define COEF_PER_CLOCK_CYCLE       (1 << 8)

// python program defined parameters (for stuff too complicated to generate through verilog functions)
`define INVERSE_TWIDDLE_2N 1175 //INVERSE_TWIDDLE_2N = pow(TWIDDLE_2N, -1, MODULUS)
`define PRECOMP_FACTOR   1 //butterfly multiplier precomp factor, 
                            //will always be one unless you change modular reduction 
                            //inside the butterflies
`define PRECOMP_FACTOR_NORMAL_MULT   524289 // for multiplication outside butterflies
                                            // if K-reduction, should be equal to
                                            // pow(K, -1, MODULUS)
                                            // with K so that MODULUS = K << SHIFT + 1
                                            // for some SHIFT
`define INVERSE_N 3316 //pow(N, -1, 3329) = pow(256,-1,3329)

//DESIGN DETERMINED parameters (TO BE PARAMETRIZED)
`define JEWEL_REGISTERS 2 //PERHAPS PARAMETRIZE AS 
`define TAIL_REDUCTION 2
`define MULTIPLIER_LATENCY 4
`define REDUCTION_LATENCY 2





//verilog defined parameters



`define NTT_POLYNOMIAL_SIZE (1<<`LOG_N)
`define RING_DEPTH       ($clog2(`COEF_PER_CLOCK_CYCLE))
`define STAGE_SIZE      `RING_DEPTH
`define NTT_DIV_BY_RING (`NTT_POLYNOMIAL_SIZE>>`RING_DEPTH)




`define BUTTERFLY_SIZE  (`COEF_PER_CLOCK_CYCLE>>1)
`define MODULUS_WIDTH   ($clog2(`MODULUS))
`define SECTIONS (`MODULUS_WIDTH/5)+1 //3 //`MODULUS/5


`define MODULUSHALFPLUSONE     {1'b0,(`MODULUS>>1)+1}
`define MODULUSEIGHTH    {3'b0,`MODULUS>>3}


