`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU LEUVEN COSIC
// Engineer: Jonas Bertels
// 
// SHA_3_512
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v" 
`include "ntt_params.v"
module SHA_3_512(
//module keccak_f #(parameter RATE=1088)(
    input clk,
    input rst,
    input [(`INPUT_WIDTH_CLUSTER_MESSAGE+`SHA_256_OUTPUT)-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`SHA_512_OUTPUT-1:0] data_out
    );
 
 wire [`SHA_512_DATA_RATE-1:0] padded_input;
assign padded_input = {1'b1,{(`SHA_512_DATA_RATE-4 -(`INPUT_WIDTH_CLUSTER_MESSAGE+`SHA_256_OUTPUT)){1'b0}},3'b110,data_in};
wire [`KECCAK_WIDTH-1:0] keccak_input;
assign keccak_input = {{(`KECCAK_WIDTH-`SHA_512_DATA_RATE){1'b0}},padded_input};
wire [`KECCAK_WIDTH-1:0] keccak_output;
keccak_f #(.BURST_SIZE(`BURST_SIZE_DIV_BY_3)) keccak_f_SHA_512_block(clk, rst, keccak_input, data_valid, data_valid_out, keccak_output);
assign data_out = keccak_output[`SHA_512_OUTPUT-1:0];
endmodule