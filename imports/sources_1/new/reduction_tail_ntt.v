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
module reduction_tail_ntt
#(parameter ADDED_WIDTH = 5)
(
    input clk,
    input [(`MODULUS_WIDTH+ADDED_WIDTH)-1:0] data_in,
    output [`MODULUS_WIDTH-1:0] data_out
    );
    



wire [`GOLD_MODULUS_WIDTH-1:0] three_times_b,  b_plus_c_without_negative_carry;
reg  [`GOLD_MODULUS_WIDTH-1:0] three_times_b_reg,  b_plus_c_without_negative_carry_reg;
wire [`GOLD_MODULUS_WIDTH+1-1:0] reduction_to_21_bit;
wire  [`GOLD_MODULUS_WIDTH+1-1:0] reduction_one_addition_above_modulus;
reg  [`GOLD_MODULUS_WIDTH+1-1:0] reduction_to_21_bit_reg; 
reg  [`GOLD_MODULUS_WIDTH+1-1:0] reduction_one_addition_above_modulus_reg;
wire [`GOLD_MODULUS_WIDTH-1:0] result_high;
reg [`GOLD_MODULUS_WIDTH-1:0]  result_high_reg;
wire [`GOLD_MODULUS_WIDTH+2-1:0] a;
wire [`GOLD_MODULUS_WIDTH-2-1:0] b;
wire [`MODULUS_WIDTH+1-1:0] add_mod_option0;
wire [`MODULUS_WIDTH+1-1:0] add_mod_option1;
reg [`GOLD_MODULUS_WIDTH+2-1:0] a_reg;

assign a =  data_in[`MODULUS_WIDTH+ADDED_WIDTH-1:18];
assign b =  data_in[17:0];
 
assign three_times_b = (b<<1) + b;

assign reduction_to_21_bit = three_times_b-a;//a is less than 2^22-2^20+4


assign add_mod_option0 = reduction_to_21_bit_reg;
assign add_mod_option1 = reduction_to_21_bit_reg+`MODULUS;

assign result_high = reduction_to_21_bit_reg[`MODULUS_WIDTH+1-1] ? add_mod_option1 : add_mod_option0;

assign data_out = result_high_reg;

always @(posedge clk) begin
    result_high_reg <= result_high;
    reduction_to_21_bit_reg <= reduction_to_21_bit;

end

endmodule
