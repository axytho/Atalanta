`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU LEUVEN COSIC
// Engineer: Jonas Bertels
// 
// SHA_3_256
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v" 
`include "ntt_params.v"
module SHAKE_256(
//module keccak_f #(parameter RATE=1088)(
    input clk,
    input rst,
    input [`SHAKE_256_INPUT-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`OUTPUT_WIDTH_CLUSTER_SHAKE_256-1:0] data_out
    );
 
 wire [`SHA_256_DATA_RATE-1:0] padded_input;
assign padded_input = {1'b1,{(`SHA_256_DATA_RATE-6 -`SHAKE_256_INPUT ){1'b0}},5'b11111,data_in};
wire [`KECCAK_WIDTH-1:0] keccak_input;
assign keccak_input = {{(`KECCAK_WIDTH-`SHA_256_DATA_RATE){1'b0}},padded_input};
wire [`KECCAK_WIDTH-1:0] keccak_output;
keccak_f keccak_f_SHA_256_block(clk, rst, keccak_input, data_valid, data_valid_out, keccak_output);
assign data_out = keccak_output[`OUTPUT_WIDTH_CLUSTER_SHAKE_256-1:0];
endmodule