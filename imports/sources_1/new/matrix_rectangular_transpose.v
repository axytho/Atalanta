`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jonas Bertels
// 
// Create Date: 12/05/2024 12:08:37 PM
// Design Name: 
// Module Name: matrix_rectangular_transpose
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

module matrix_rectangular_transpose #(parameter direction = "FORWARD") (
input clk,
input reset,
input [`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH-1:0] data_in,
input data_valid,
output data_valid_out,
output [`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH-1:0] data_out
    );
wire [`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH-1:0] data_in_matrix_transpose, data_out_matrix_transpose;
//localparam number_of_times_smaller_part_fits_into_larger = (1<<(2*`LOG_COEF_PER_CC-`LOG_N));
matrix_transpose #(.STREAM_WIDTH(`NTT_DIV_BY_RING), .DATA_ELEMENT_WIDTH(`MODULUS_WIDTH*(1<<(2*`LOG_COEF_PER_CC-`LOG_N)))) matrix(clk, reset, data_in_matrix_transpose, data_valid,data_valid_out, data_out_matrix_transpose);

generate
if (direction == "FORWARD") begin
wire [`COEF_PER_CLOCK_CYCLE*`MODULUS_WIDTH-1:0] data_in_grouped;
genvar i, j;
for (i=0; i<`COEF_PER_CLOCK_CYCLE; i=i+1) begin
    assign data_in_matrix_transpose[(((i[(`LOG_N-`LOG_COEF_PER_CC)-1:0])<<(2*`LOG_COEF_PER_CC-`LOG_N))+i[`LOG_COEF_PER_CC-1:(`LOG_N-`LOG_COEF_PER_CC)])*`MODULUS_WIDTH+:`MODULUS_WIDTH] = data_in[i*`MODULUS_WIDTH+:`MODULUS_WIDTH];
end
assign data_out = data_out_matrix_transpose; 
end else begin
genvar i, j;
for (i=0; i<`COEF_PER_CLOCK_CYCLE; i=i+1) begin
    assign data_out[i*`MODULUS_WIDTH+:`MODULUS_WIDTH] = data_out_matrix_transpose[(((i[(`LOG_N-`LOG_COEF_PER_CC)-1:0])<<(2*`LOG_COEF_PER_CC-`LOG_N))+i[`LOG_COEF_PER_CC-1:(`LOG_N-`LOG_COEF_PER_CC)])*`MODULUS_WIDTH+:`MODULUS_WIDTH];
end 
assign data_in_matrix_transpose = data_in;
end
endgenerate

    
endmodule
