`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU LEUVEN COSIC
// Engineer: Jonas Bertels
// 
// SHAKE_128
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v" 
`include "ntt_params.v"
module SHAKE_128(
//module keccak_f #(parameter RATE=1088)(
    input clk,
    input rst,
    input [`SHAKE_128_INPUT-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:0] data_out
    );
 
 wire [`SHA_128_DATA_RATE-1:0] padded_input;
assign padded_input = {1'b1,{(`SHA_128_DATA_RATE-6 -`SHAKE_128_INPUT ){1'b0}},5'b11111,data_in};
wire [`KECCAK_WIDTH-1:0] keccak_input;
assign keccak_input = {{(`KECCAK_WIDTH-`SHA_128_DATA_RATE){1'b0}},padded_input};
wire [`KECCAK_WIDTH-1:0] keccak_output [0:5-1];
wire [`OUTPUT_WIDTH_ONE_BURST_SHAKE_128-1:0] keccak_verilog_bugfix [0:6-1];//because our shift register breaks from something for long shifts with wide stuff.


wire keccak_valid_output [0:4-1];
keccak_f keccak_f_SHA_128_block(clk, rst, keccak_input, data_valid, keccak_valid_output[0], keccak_output[0]);
keccak_f keccak_f_SHA_128_block_1(clk, rst, keccak_output[0], keccak_valid_output[0], keccak_valid_output[1], keccak_output[1]);
keccak_f keccak_f_SHA_128_block_2(clk, rst, keccak_output[1], keccak_valid_output[1], keccak_valid_output[2], keccak_output[2]);
keccak_f keccak_f_SHA_128_block_3(clk, rst, keccak_output[2], keccak_valid_output[2], keccak_valid_output[3], keccak_output[3]);
keccak_f keccak_f_SHA_128_block_4(clk, rst, keccak_output[3], keccak_valid_output[3], data_valid_out, keccak_output[4]);
assign data_out[4*`OUTPUT_WIDTH_ONE_BURST_SHAKE_128+:`OUTPUT_WIDTH_ONE_BURST_SHAKE_128] = keccak_output[4][`OUTPUT_WIDTH_ONE_BURST_SHAKE_128-1:0];

shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_00(clk, keccak_output[0][`OUTPUT_WIDTH_ONE_BURST_SHAKE_128-1:0], keccak_verilog_bugfix[0]);
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_01(clk, keccak_verilog_bugfix[0], keccak_verilog_bugfix[1]);
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_02(clk, keccak_verilog_bugfix[1], keccak_verilog_bugfix[2]);
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_03(clk, keccak_verilog_bugfix[2], data_out[0*`OUTPUT_WIDTH_ONE_BURST_SHAKE_128+:`OUTPUT_WIDTH_ONE_BURST_SHAKE_128]);


shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_10(clk, keccak_output[1][`OUTPUT_WIDTH_ONE_BURST_SHAKE_128-1:0], keccak_verilog_bugfix[3]);
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_11(clk, keccak_verilog_bugfix[3], keccak_verilog_bugfix[4]);
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_12(clk, keccak_verilog_bugfix[4], data_out[1*`OUTPUT_WIDTH_ONE_BURST_SHAKE_128+:`OUTPUT_WIDTH_ONE_BURST_SHAKE_128]);


shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_20(clk, keccak_output[2][`OUTPUT_WIDTH_ONE_BURST_SHAKE_128-1:0], keccak_verilog_bugfix[5]);
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_21(clk, keccak_verilog_bugfix[5], data_out[2*`OUTPUT_WIDTH_ONE_BURST_SHAKE_128+:`OUTPUT_WIDTH_ONE_BURST_SHAKE_128]);

shift_reg_width #(.shift(1*`ROUNDS_OF_KECCAK), .width(`OUTPUT_WIDTH_ONE_BURST_SHAKE_128)) shift_3(clk, keccak_output[3][`OUTPUT_WIDTH_ONE_BURST_SHAKE_128-1:0], data_out[3*`OUTPUT_WIDTH_ONE_BURST_SHAKE_128+:`OUTPUT_WIDTH_ONE_BURST_SHAKE_128]);

endmodule