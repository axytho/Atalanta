`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2026 02:40:54 PM
// Design Name: 
// Module Name: key_encapsulation
// Project Name: 
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

module key_encapsulation(
input clk,
input rst,
input [`INPUT_WIDTH_CLUSTER_MESSAGE-1:0] message,
input [`INPUT_WIDTH_CLUSTER_PK-1:0] public_key,
input data_valid,
output [`K_WIDTH-1:0] K_output,
output [`CIPHERTEXT_WIDTH-1:0] ciphertext,
output data_valid_out
    );
    
wire internal_reset;
assign internal_reset = rst;    
wire data_valid_out_SHA_256, data_valid_out_SHA_512;    
wire [`SHA_256_OUTPUT-1:0] pk_hash;    
SHA_3_256 SHA_3_256_instance (clk, internal_reset, public_key, data_valid,data_valid_out_SHA_256, pk_hash);

wire [`INPUT_WIDTH_CLUSTER_MESSAGE-1:0] message_in_512;
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`INPUT_WIDTH_CLUSTER_MESSAGE)) shift_0 (clk, message, message_in_512);
wire [`SHA_512_OUTPUT/2-1:0] K, r;  

SHA_3_512 SHA_3_512_instance (clk, internal_reset, {message_in_512,pk_hash}, data_valid_out_SHA_256,data_valid_out_SHA_512, {K, r});
wire stream_valid_K, stream_valid_r;
wire [`K_WIDTH-1:0] K_stream;  
Burst_into_stream #(
.INPUT_WIDTH((`SHA_512_OUTPUT/2)), 
.OUTPUT_WIDTH(`K_WIDTH), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC))), 
.CYCLES_PER_OUTPUT_LOG((`LOG_N-`LOG_COEF_PER_CC))
) Burst
(clk, internal_reset, K, data_valid_out_SHA_512, stream_valid_K, K_stream);

shift_reg_width #(.shift(`TOTAL_LATENCY_ENCRYPTION), .width(`K_WIDTH)) shift_1(clk, K_stream, K_output);
shift_reg_data_valid #(`TOTAL_LATENCY_ENCRYPTION) shift_instance_2 (clk, stream_valid_K, data_valid_out);  

endmodule
