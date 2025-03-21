`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven
// Engineer: Jonas Bertels
// 
// Create Date: 06/27/2022 07:45:14 PM
// Design Name: BASIC NTT
// Module Name: butterfly
// Project Name: ZPRIZE
// Target Devices: Varium C1100
// Tool Versions: Vivado 2020.2
// Description: Basic butterfly unit
// 
// Dependencies: None
// Revision 0.04-- works in simulation
// Revision 0.03 - Fixed shift_rotate problems
// Revision 0.02 - first version, trying to make all shifts work to `MODULUS_WIDTH (so simple CT works)
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "parameters.v"

module GS_butterfly
#(parameter TWIDDLE = 0)
(
    input clk,
    input [`MODULUS_WIDTH-1:0] input_a,
    input [`MODULUS_WIDTH-1:0] input_b,
    output [`MODULUS_WIDTH-1:0] output_a,
    output [`MODULUS_WIDTH-1:0] output_b
    );

reg [`MODULUS_WIDTH+2-1:0] pipeline_a_0;
reg [`MODULUS_WIDTH-1:0] pipeline_a_1, pipeline_a_2;
reg [`MODULUS_WIDTH-1:0] pipeline_a_3, pipeline_a_4,pipeline_a_5; 
reg [`MODULUS_WIDTH-1:0] pipeline_a_6, pipeline_a_7, pipeline_a_8;
reg [`MODULUS_WIDTH+2-1:0] pipeline_b_0;
//,pipeline_a_8;
//reg [`MODULUS_WIDTH+2-1:0] pipeline_b_0, pipeline_b_1, pipeline_b_2, pipeline_b_3, pipeline_b_4, pipeline_b_5; 
wire [`MODULUS_WIDTH+2-1:0] add_mod_option0;
wire [`MODULUS_WIDTH+2-1:0] add_mod_option1;
wire [`MODULUS_WIDTH+2-1:0] sub_mod_option0 = pipeline_b_0;
wire [`MODULUS_WIDTH+2-1:0] sub_mod_option1 = pipeline_b_0+`MODULUS;
wire [`MODULUS_WIDTH-1:0] mult_output;

reg [`MODULUS_WIDTH-1:0] out_a, out_b;

modular_multiplier modular_multiplier(.clk(clk),.input_a(out_b), .input_b(TWIDDLE[`MODULUS_WIDTH-1:0]), .output_product(mult_output));
assign add_mod_option0 = pipeline_a_0;
assign add_mod_option1 = pipeline_a_0-`MODULUS;
always @(posedge clk) begin
    pipeline_a_0 <= {2'b0, input_a} + {2'b0,input_b};
    pipeline_b_0 <= {2'b0, input_a} - {2'b0,input_b};
    
    out_a <= add_mod_option1[`MODULUS_WIDTH+2-1] ? add_mod_option0[`MODULUS_WIDTH-1:0] : add_mod_option1[`MODULUS_WIDTH-1:0];
    out_b <= sub_mod_option0[`MODULUS_WIDTH+2-1] ? sub_mod_option1[`MODULUS_WIDTH-1:0] : sub_mod_option0[`MODULUS_WIDTH-1:0];
    
    
    
    
    pipeline_a_1 <= out_a;
    pipeline_a_2 <= pipeline_a_1;
    pipeline_a_3 <= pipeline_a_2;
    pipeline_a_4 <= pipeline_a_3;
    pipeline_a_5 <= pipeline_a_4;
    pipeline_a_6 <= pipeline_a_5;
    pipeline_a_7 <= pipeline_a_6;
    pipeline_a_8 <= pipeline_a_7;
    
end
assign output_a = pipeline_a_8;
assign output_b = mult_output;
endmodule
