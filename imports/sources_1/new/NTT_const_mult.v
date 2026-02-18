`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 12/02/2024 06:21:15 PM
// Design Name: My Famous method for making the absolute bestest of best multipliers
// Module Name: NTT_const_mult
// Project Name: Quatorze 14bis
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



`include "parameters.v" 
`include "ntt_params.v"
module NTT_const_mult #(parameter STREAM_SIZE = 32, parameter PSI = 1, parameter OMEGA = 1, parameter PRECOMP_FACTOR = 1, parameter DIRECTION="FORWARD", parameter REDUCED_POLYNOMIAL_DEPTH=0) (
    input clk,
    input [STREAM_SIZE*(`MODULUS_WIDTH)-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [STREAM_SIZE*(`MODULUS_WIDTH)-1:0] data_out
    );
localparam STREAM_DEPTH = ($clog2(STREAM_SIZE));
localparam STREAM_DEPTH_MODDED = STREAM_DEPTH-REDUCED_POLYNOMIAL_DEPTH;

//localparam REDUCTION_ADDED_WIDTH = ($clog2(STREAM_DEPTH_MODDED));
//localparam REDUCTION_ADDED_WIDTH_GS = STREAM_DEPTH_MODDED+($clog2(`MODULUS*`SECTIONS))- `MODULUS_WIDTH;
localparam REDUCTION_ADDED_WIDTH = 3; //Used to be a complicated system, now just one extra because butterfly was changed.
localparam REDUCTION_ADDED_WIDTH_GS = 3;
localparam STAGE_REDUCTION = `STAGE_REDUCTION;


wire [`MODULUS_WIDTH-1:0] data_out_bit_reversed [0:STREAM_SIZE-1];
wire [`MODULUS_WIDTH-1:0] data_out_bit_normal [0:STREAM_SIZE-1];

// DATA_VALID delay
shift_reg_data_valid #(`JEWEL_REGISTERS*STREAM_DEPTH_MODDED+`TAIL_REDUCTION) shift_instance (clk, data_valid, data_valid_out);

generate
if (DIRECTION=="FORWARD") begin
    wire [`MODULUS_WIDTH+REDUCTION_ADDED_WIDTH-1:0] internal_wiring [0:STREAM_SIZE*(STREAM_DEPTH_MODDED+1)-1];

    genvar k;
    for(k = 0; k < STREAM_SIZE; k=k+1) begin: BIT_REVERSE_INDEX
        assign data_out_bit_reversed[bit_inverse(k[STREAM_DEPTH-1:0])] = data_out_bit_normal[(k[STREAM_DEPTH-1:0])];
        //TODO: probably the last two elements won't have to be bitreversed, so the bit_reverse function will have to be slightly modified.
        reduction_tail_ntt #(.ADDED_WIDTH(REDUCTION_ADDED_WIDTH)) reduction(.clk(clk), .data_in(internal_wiring[STREAM_DEPTH_MODDED*STREAM_SIZE + k]), .data_out(data_out_bit_normal[(k[STREAM_DEPTH-1:0])]));
    end
    genvar i;
    for(i = 0; i < STREAM_SIZE; i=i+1) begin: INITIAL
        assign internal_wiring[i] = { {REDUCTION_ADDED_WIDTH{1'b0}}, data_in[(i+1)*(`MODULUS_WIDTH)-1:i*(`MODULUS_WIDTH)]};
    end
    genvar stage;
    genvar block_number;
    genvar twiddle_exponent;
    genvar reduction_index;
        for(stage = 0; stage < STREAM_DEPTH_MODDED; stage=stage+1) begin: STAGE_LOOP
            for (block_number = 0; block_number < (1<<stage); block_number=block_number+1) begin: BLOCK_LOOP
                    for (twiddle_exponent = 0; twiddle_exponent  < (STREAM_SIZE>>(stage+1)); twiddle_exponent = twiddle_exponent + 1) begin :  INSIDE_BLOCK
                    // 244715 = psi^32 mod Q
                    // we need to calculate 
                            butterfly_jewel #(
                            .TWIDDLE(
                            modular_mult(
                            modular_mult(PRECOMP_FACTOR, modular_pow(PSI,(1<<STREAM_DEPTH_MODDED)>>(stage+1), `MODULUS ) ,`MODULUS),
                            modular_pow(OMEGA, bit_inverse(block_number)>>(1+REDUCED_POLYNOMIAL_DEPTH), `MODULUS),
                            `MODULUS)
                            ),
                            .STAGE(stage)
                            )
                            butterfly0(.clk(clk),
                            .input_a(internal_wiring[stage*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent]), 
                            .input_b(internal_wiring[stage*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent + (STREAM_SIZE>>(stage+1))]), 
                            .output_a(internal_wiring[(stage+1)*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent]),
                            .output_b(internal_wiring[(stage+1)*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent + (STREAM_SIZE>>(stage+1))]));
                 end
            end
        end
end else begin
   wire [`MODULUS_WIDTH+REDUCTION_ADDED_WIDTH_GS-1:0] internal_wiring [0:STREAM_SIZE*(STREAM_DEPTH+1)-1];

    genvar i;
    for(i = 0; i < STREAM_SIZE; i=i+1) begin: INITIAL
        assign internal_wiring[i] = { {REDUCTION_ADDED_WIDTH_GS{1'b0}}, data_in[(i+1)*(`MODULUS_WIDTH)-1:i*(`MODULUS_WIDTH)]};
    end
    genvar k;
    for(k = 0; k < STREAM_SIZE; k=k+1) begin: BIT_REVERSE_INDEX
        assign data_out_bit_reversed[bit_inverse(k[STREAM_DEPTH-1:0])] = data_out_bit_normal[(k[STREAM_DEPTH-1:0])];
        reduction_tail_ntt #(.ADDED_WIDTH(REDUCTION_ADDED_WIDTH_GS)) reduction(.clk(clk), .data_in(internal_wiring[STREAM_DEPTH*STREAM_SIZE + k]), .data_out(data_out_bit_normal[(k[STREAM_DEPTH-1:0])]));
    end
    genvar stage;
    genvar block_number;
    genvar twiddle_exponent;
    genvar reduction_index;
    for(stage = 0; stage < STREAM_DEPTH; stage=stage+1) begin: STAGE_LOOP
        for (block_number = 0; block_number < (1<<stage); block_number=block_number+1) begin: BLOCK_LOOP
                for (twiddle_exponent = 0; twiddle_exponent  < (STREAM_SIZE>>(stage+1)); twiddle_exponent = twiddle_exponent + 1) begin :  INSIDE_BLOCK
                // 244715 = psi^32 mod Q
                    // we need to calculate 
                            butterfly_jewel_GS #(
                        .TWIDDLE(
                        modular_mult(
                        modular_mult(PRECOMP_FACTOR, modular_pow(PSI,1<<(stage), `MODULUS ) ,`MODULUS),
                        modular_pow(OMEGA, twiddle_exponent<<stage, `MODULUS),
                        `MODULUS)
                        ),
                        .DIRECTION("INVERSE"),
                        .STAGE(stage),
                        .STAGE_REDUCTION(STAGE_REDUCTION)
                        )
                        butterfly0(.clk(clk),
                        .input_a(internal_wiring[stage*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent]), 
                        .input_b(internal_wiring[stage*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent + (STREAM_SIZE>>(stage+1))]), 
                        .output_a(internal_wiring[(stage+1)*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent]),
                        .output_b(internal_wiring[(stage+1)*STREAM_SIZE+2*block_number*(STREAM_SIZE>>(stage+1)) + twiddle_exponent + (STREAM_SIZE>>(stage+1))]));
                end
            end
        end
end
endgenerate

    

generate
    
endgenerate    
generate
    genvar j;
    for(j = 0; j < STREAM_SIZE; j=j+1) begin: OUTPUT
        assign data_out[(j+1)*(`MODULUS_WIDTH)-1:j*(`MODULUS_WIDTH)] = data_out_bit_reversed[j];
    end
endgenerate    
   
function [`MODULUS_WIDTH-1:0] modular_pow;
 input [2*`MODULUS_WIDTH-1:0] base;
 input [`MODULUS_WIDTH-1:0] exponent, modulus;
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

function [STREAM_DEPTH-1:0] bit_inverse;//TODO: FIX TO DEAL WITH KYBER PARAMETERS
 input [STREAM_DEPTH-1:0] normal_order;
 integer index_bitreverse;
 begin
     for(index_bitreverse=0; index_bitreverse<(STREAM_DEPTH); index_bitreverse=index_bitreverse+1) begin
        bit_inverse[index_bitreverse] = normal_order[STREAM_DEPTH - 1-index_bitreverse];
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

    
    
endmodule
