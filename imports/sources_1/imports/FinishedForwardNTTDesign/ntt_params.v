`timescale 1ns / 1ps

//All rights reserved
// Author: Jonas Bertels on behalf of COSIC, KU Leuven
// MAY NOT BE REPRODUCED

//TODO


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////


// NTT application-specific user-defined parameters
// i.e. the cryptographical algorithm usually decides what goes here
// although the user may have some lattitude in picking the modulus
// (contact your local cryptographer for more details)
`define LOG_N 8
`define MODULUS 12'b110100000001
`define TWIDDLE_2N 17



// python program defined parameters (for stuff too complicated to generate through verilog functions)
`define INVERSE_TWIDDLE_2N 1175 //INVERSE_TWIDDLE_2N = pow(TWIDDLE_2N, -1, MODULUS)
`define PRECOMP_FACTOR   1 //butterfly multiplier precomp factor,
                           //will always be one unless you change modular reduction
                           //inside the butterflies to use something that isn't LUT
`define NUMBER_OF_PRECOMPS_NECESSARY   1 //1 if you only do K-reduction in the multiplier halfway,
                                         //3 if you use it for tail reduction as well 
                                         //can be anything depending on number of multipliers 
`define PRECOMP_FACTOR_NORMAL_MULT   256 // for multiplication outside butterflies
                                            // if K-reduction, should be equal to
                                            // pow(K, -1, MODULUS)
                                            // with K so that MODULUS = K << SHIFT + 1
                                            // for some SHIFT
`define REDUCED_POLYNOMIAL_DEPTH 1 // = max(0, LOG_N - log2(gcd(2^LOG_N,MODULUS-1))+1)
// i.e. the highest power of two that divided modulus -1, figure out what this power is and
// if this power is LOG_N + 1 or higher, the exponent of the polynomials is 0 and we have
// fully reduced the polynomials, if power is  LOG_N or smaller, the depth
// is equal to LOG_N + 1 - power
`define INVERSE_N 3303 //pow(N, -1, modulus) = pow(1<<LOG_N,-1,modulus)


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////


//NTT hardware-specific user-defined parameters
`define COEF_PER_CLOCK_CYCLE       (1 << 7)

//DESIGN DETERMINED parameters (TO BE PARAMETRIZED)
`define JEWEL_REGISTERS 2 //PERHAPS PARAMETRIZE AS 
`define TAIL_REDUCTION 2

`define REDUCTION_LATENCY 2

//Multiplier (For the device in use, generate an ip module or write your own verilog
// with the name of custom_multiplier. Fill in the latency in this parameter)
`define MULTIPLIER_LATENCY 3 // for 12x12 multipliers
//`define MULTIPLIER_LATENCY 4 // for 20x20 bit multipliers




//verilog defined parameters



`define NTT_POLYNOMIAL_SIZE (1<<`LOG_N)
`define LOG_COEF_PER_CC       ($clog2(`COEF_PER_CLOCK_CYCLE))
`define STAGE_SIZE      `LOG_COEF_PER_CC
`define NTT_DIV_BY_RING (`NTT_POLYNOMIAL_SIZE>>`LOG_COEF_PER_CC)
`define COEF_PER_CLOCK_CYCLE_BAILEY_NTT  (`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)
`define LOG_COEF_PER_CC_BAILEY_NTT  ($clog2(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT))
`define LOG_N_BAILEY_NTT (`LOG_N-`REDUCED_POLYNOMIAL_DEPTH)
`define FIRST_NTT_LATENCY (`JEWEL_REGISTERS*`LOG_COEF_PER_CC_BAILEY_NTT+`TAIL_REDUCTION)



`define BUTTERFLY_SIZE  (`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)
`define MODULUS_WIDTH   ($clog2(`MODULUS))
`define SECTIONS (`MODULUS_WIDTH/5)+1 //3 //`MODULUS/5


`define MODULUSHALFPLUSONE     {1'b0,(`MODULUS>>1)+1}
`define MODULUSEIGHTH    {3'b0,`MODULUS>>3}


