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

`include "parameters.v" `include "ntt_params.v"
module reduction
(
    input clk,
    input [(`MODULUS_WIDTH<<1)-1:0] data_in,
    output [`MODULUS_WIDTH-1:0] data_out
    );
    

wire [22:0] sub_res;
reg [22:0] sub_res_reg;
reg [`MODULUS_WIDTH-1:0] result_reg;
wire [4:0] to_add;


efficient_subtractor #(.INPUT_WIDTH(`MODULUS_WIDTH), .OUTPUT_WIDTH(`MODULUS_WIDTH+3)) eff_sub (
.clk(clk),
.input_a({3'b0,data_in[17:0],1'b0}),
.input_b(data_in[39:18]),
.input_c({2'b0,data_in[17:0]}),
.sum(sub_res)
);//should be about 20 LUTs

function [4:0] determine_number_to_be_added;
input [4:0] most_significant_bits;
begin
if (most_significant_bits[4]==1'b0) begin
    determine_number_to_be_added = 6'b0;
end else begin
    determine_number_to_be_added[2:0] = (6'b100000 - most_significant_bits[4:0]+3-1)/3;//EQUIVALENT TO CEILDIV(6'b100000 - most_significant_bits[4:0], 3)
    determine_number_to_be_added[4:3] = determine_number_to_be_added[2:0] + (determine_number_to_be_added[2:0]<<1);
end
end
endfunction   
assign to_add = determine_number_to_be_added(sub_res_reg[22:18]);//should be only 5 LUTs

always @(posedge clk) begin
    sub_res_reg <= sub_res;
    result_reg <= {to_add[4:3],15'b0,to_add[2:0]} + sub_res_reg[19:0];//should be only 20 LUTs
end

assign data_out = result_reg;
endmodule
