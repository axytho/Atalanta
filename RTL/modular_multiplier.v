`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: COSIC KU Leuven
// Engineer: Jonas Bertels
// 
// Create Date: 07/19/2022 03:38:49 PM
// Design Name: NTT_4096
// Module Name: modular_multiplier
// Project Name: ZPRIZE NTT
// Target Devices: Varium
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
module modular_multiplier
(
    input clk,
    input [`MODULUS_WIDTH-1:0] input_a,
    input [`MODULUS_WIDTH-1:0] input_b,
    output [`MODULUS_WIDTH-1:0] output_product
    );
    
wire [(`MODULUS_WIDTH<<1)-1:0] output_mult;


DSP_optimized_FINAL twiddle_multiplier(.CLK(clk), .A(input_a), .B(input_b), .P(output_mult));
reduction reduction_0(.clk(clk), .data_in(output_mult), .data_out(output_product));
//don't connect data_valid or data_valid_out on reduction
endmodule
