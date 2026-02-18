`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 01:45:37 PM
// Design Name: 
// Module Name: NTT_incomplete
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
module NTT_incomplete(
    input clk,
    input reset,
    input [`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH-1:0] data_out
    );
    

wire [((`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH)>>`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_in_grouped [0:(1<<`REDUCED_POLYNOMIAL_DEPTH)-1];

wire [(`MODULUS_WIDTH<<`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_in_grouped_out_bitreversed [0:`COEF_PER_CLOCK_CYCLE_BAILEY_NTT-1];
wire [(`MODULUS_WIDTH<<`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_in_grouped_out_normal [0:`COEF_PER_CLOCK_CYCLE_BAILEY_NTT-1];
wire [((`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH)>>`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_in_grouped_out_normal_per_ntt [0:(1<<`REDUCED_POLYNOMIAL_DEPTH)-1];
wire [((`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH)>>`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_in_grouped_out_bitreversed_per_ntt [0:(1<<`REDUCED_POLYNOMIAL_DEPTH)-1];

genvar i, j, k, m;
for (i=0; i<`COEF_PER_CLOCK_CYCLE; i=i+1) begin
    assign data_in_grouped[(i[`REDUCED_POLYNOMIAL_DEPTH-1:0])][(i[`LOG_N-1:`REDUCED_POLYNOMIAL_DEPTH])*`MODULUS_WIDTH+:`MODULUS_WIDTH] = data_in[i*`MODULUS_WIDTH+:`MODULUS_WIDTH];
    assign data_out[i*`MODULUS_WIDTH+:`MODULUS_WIDTH] = data_in_grouped_out_normal_per_ntt[(i[`REDUCED_POLYNOMIAL_DEPTH-1:0])][(i[`LOG_N-1:`REDUCED_POLYNOMIAL_DEPTH])*`MODULUS_WIDTH+:`MODULUS_WIDTH];
end
for (j=0; j<(1<<`REDUCED_POLYNOMIAL_DEPTH); j=j+1) begin
    Bailey_NTT NTT_128_instance(clk,reset, data_in_grouped[j],data_valid, data_valid_out, data_in_grouped_out_normal_per_ntt[j]);
end


for (k=0; k<`COEF_PER_CLOCK_CYCLE_BAILEY_NTT; k=k+1) begin
    assign data_in_grouped_out_bitreversed[bit_inverse(k[`LOG_COEF_PER_CC_BAILEY_NTT-1:0])] = data_in_grouped_out_normal[(k[`LOG_COEF_PER_CC_BAILEY_NTT-1:0])];

    for (m=0; m<(1<<`REDUCED_POLYNOMIAL_DEPTH); m=m+1) begin 
         assign data_in_grouped_out_normal[k][m*`MODULUS_WIDTH+:`MODULUS_WIDTH] = data_in_grouped_out_normal_per_ntt[m][k*`MODULUS_WIDTH+:`MODULUS_WIDTH];
         assign data_in_grouped_out_bitreversed_per_ntt[m][k*`MODULUS_WIDTH+:`MODULUS_WIDTH]  = data_in_grouped_out_bitreversed[k][m*`MODULUS_WIDTH+:`MODULUS_WIDTH];
    end
    
end

function [`LOG_COEF_PER_CC_BAILEY_NTT-1:0] bit_inverse;//TODO: FIX TO DEAL WITH KYBER PARAMETERS
 input [`LOG_COEF_PER_CC_BAILEY_NTT-1:0] normal_order;
 integer index_bitreverse;
 begin
     for(index_bitreverse=0; index_bitreverse<(`LOG_COEF_PER_CC_BAILEY_NTT); index_bitreverse=index_bitreverse+1) begin
        bit_inverse[index_bitreverse] = normal_order[`LOG_COEF_PER_CC_BAILEY_NTT - 1-index_bitreverse];
     end
 end
endfunction


endmodule
