`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 01:21:14 PM
// Design Name: 
// Module Name: efficient_adder
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


module efficient_adder (
 input clk,
 input [`MODULUS_WIDTH-1:0] input_a,
 input [`MODULUS_WIDTH-1:0] input_b,
 input [`MODULUS_WIDTH-1:0] input_c,
 output [`MODULUS_WIDTH+2-1:0] sum
    );
    
 wire [(`MODULUS_WIDTH+2>>3)+2-1:0] BBUS;
 wire [(`MODULUS_WIDTH+2>>3)+2-1:0] c_in;
 assign BBUS[0] = 1'b0;
 assign c_in[0] = 1'b0;
 wire [((`MODULUS_WIDTH+2>>3)+1<<3)-1:0] a_padded, b_padded, c_padded, sum_padded;
 assign a_padded = { {(((`MODULUS_WIDTH+2>>3)+1<<3)-`MODULUS_WIDTH){1'b0}} , input_a};
 assign b_padded = { {(((`MODULUS_WIDTH+2>>3)+1<<3)-`MODULUS_WIDTH){1'b0}} , input_b};
 assign c_padded = { {(((`MODULUS_WIDTH+2>>3)+1<<3)-`MODULUS_WIDTH){1'b0}} , input_c};   
 
 
 
 generate
 genvar i;
 for (i=0; i<(`MODULUS_WIDTH>>3)+1; i=i+1) begin
    csa3 csa3_inst(
    .clk(clk),
    .BBUS_IN(BBUS[i]),
    .cin(c_in[i]),
    .in_a(a_padded[i*8+:8]),
    .in_b(b_padded[i*8+:8]),
    .in_c(c_padded[i*8+:8]),
    .sum(sum_padded[i*8+:8]),
    .BBUS7(BBUS[i+1]),
    .cout(c_in[i+1])
    );
 end
 endgenerate
 
 assign sum = sum_padded[`MODULUS_WIDTH+2-1:0];
endmodule
