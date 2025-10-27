`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 06/29/2022 04:24:36 PM
// Design Name: NTT_64_SIZE
// Module Name: NTT_64
// Project Name: ZPRIZE
// Target Devices: Varium C1100
// Tool Versions: Vivado 2020.2
// Description: Number Theoretic Transform for modulus = 2^64-2^32+1 expanded to 96 bits
// 
// Revision 2.0: Modified to NTT_32_pass_1 for Quinten's design
// Revision 1.1: Added one extra bit to allow for 2**96 case
// Revision 1.0: NTT_64 works

// Revision 0.2: At first, thought of doing it in SystemVerilog, but decided against it, instead wrote "variables" in comments
// Revision 0.1: Using "An Extensive Study of Flexible Design Methods for the Number Theoretic Transform" GS NTT algorithm as baseline
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v" 
`include "ntt_params.v"
module INTT_32_pass_2(
    input clk,
    input [`RING_SIZE*(`MODULUS_WIDTH)-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`RING_SIZE*(`MODULUS_WIDTH)-1:0] data_out
    );
    
// DATA_VALID delay
shift_reg_data_valid #(`BUTTER_FLY_REGISTERS*`STAGE_SIZE) shift_instance (clk, data_valid, data_valid_out);


// NTT_64
    
wire [`MODULUS_WIDTH-1:0] internal_wiring [0:`RING_SIZE*(`STAGE_SIZE+1)-1];
wire [`MODULUS_WIDTH-1:0] data_out_bit_reversed [0:`RING_SIZE-1];
generate
    genvar i;
    for(i = 0; i < `RING_SIZE; i=i+1) begin: INITIAL
        assign internal_wiring[i] = data_in[(i+1)*(`MODULUS_WIDTH)-1:i*(`MODULUS_WIDTH)];
    end
endgenerate    
generate
    genvar j;
    for(j = 0; j < `RING_SIZE; j=j+1) begin: OUTPUT
        assign data_out[(j+1)*(`MODULUS_WIDTH)-1:j*(`MODULUS_WIDTH)] = data_out_bit_reversed[j];
    end
endgenerate    
generate
    genvar k;
    for(k = 0; k < `RING_SIZE; k=k+1) begin: BIT_REVERSE_INDEX
        assign data_out_bit_reversed[{k[0], k[1], k[2], k[3], k[4]}] = internal_wiring[`STAGE_SIZE*`RING_SIZE + k];
    end
endgenerate    
function [`MODULUS_WIDTH-1:0] modular_pow;
 input [2*`MODULUS_WIDTH-1:0] base;
 input [`MODULUS_WIDTH-1:0] modulus, exponent;
 begin
     if (modulus == 1) begin
        modular_pow = 0;
     end else begin
        modular_pow = 1;
        while ( exponent > 0) begin
            if (exponent[0] == 1)
                modular_pow = ({20'b0,modular_pow} * base) % modulus;
            exponent = exponent >> 1;
            base = (base * base) % modulus;
        
        end
     end
 end
endfunction
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [2*`MODULUS_WIDTH-1:0] input1;
 input [2*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction

function [`STAGE_SIZE-1:0] bit_inverse;
 input [`STAGE_SIZE-1:0] normal_order;
 integer index_bitreverse;
 begin
     for(index_bitreverse=0; index_bitreverse<(`STAGE_SIZE); index_bitreverse=index_bitreverse+1) begin
        bit_inverse[index_bitreverse] = normal_order[`STAGE_SIZE - 1-index_bitreverse];
     end
 end
endfunction

// A NOTE on the twiddle factors:
//
// Normal case: Cooley Tukey: 
// X[first half] = sum(x[even]*w^(2nk)) + sum(x(odd)*w^(2nk)*w^k)
// X(second half) = E - w^k O
// So for ring size of 4:
// x[0]----------------------
//     /\       \/
// x[2]--------/-\------------
//            /   \  \  /
// x[1]---------------\/------
//     /\             /\
// x[3]----------------------
//
//Case with psi twiddle factors:
//
// X[first half] = sum(x[even]*w^(2nk)*psi^(2n)) + sum(x(odd)*w^(2nk)*w^k*psi^(2n+1))
// X(second half) = E - psi*w^k O
//
//
//


generate
    genvar stage;
    genvar block_number;
    genvar twiddle_exponent;
    
    for(stage = 0; stage < `STAGE_SIZE; stage=stage+1) begin: STAGE_LOOP
        for (block_number = 0; block_number < (1<<stage); block_number=block_number+1) begin: BLOCK_LOOP
                for (twiddle_exponent = 0; twiddle_exponent  < (`RING_SIZE>>(stage+1)); twiddle_exponent = twiddle_exponent + 1) begin : INSIDE_BLOCK
                // 244715 = psi^32 mod Q
                // we need to calculate 
                    GS_butterfly #(.TWIDDLE(modular_mult(modular_mult(524289,modular_pow(70756,`MODULUS, (1<<(stage))) ,`MODULUS),modular_pow(203749,`MODULUS, twiddle_exponent<<stage),`MODULUS)))
                    butterfly0(.clk(clk),
                    .input_a(internal_wiring[stage*`RING_SIZE+2*block_number*(`RING_SIZE>>(stage+1)) + twiddle_exponent]), 
                    .input_b(internal_wiring[stage*`RING_SIZE+2*block_number*(`RING_SIZE>>(stage+1)) + twiddle_exponent + (`RING_SIZE>>(stage+1))]), 
                    .output_a(internal_wiring[(stage+1)*`RING_SIZE+2*block_number*(`RING_SIZE>>(stage+1)) + twiddle_exponent]),
                    .output_b(internal_wiring[(stage+1)*`RING_SIZE+2*block_number*(`RING_SIZE>>(stage+1)) + twiddle_exponent + (`RING_SIZE>>(stage+1))]));
            end
        end
    end
endgenerate    
    
endmodule
