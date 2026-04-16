`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jonas Bertels
// 
// Create Date: 02/25/2026 04:31:36 PM
// Design Name: 
// Module Name: tail_reduction_with_division_by_128
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

//CRITICAL COMMENT: THIS MODULE IS CALIBRATED AROUND q = 3329 and N_INV = 3303, and would not work for anything else
// moreover, it uses the fact that the sum of the 3 luts will always be less than 2*3329 (a fact which can be verified on the blackboard)
// (by enumerating all the possible inputs for the LUTS are realizing that 1<<(15-7) can always be added to the sum of the two luts)
`include "parameters.v" 
`include "ntt_params.v"
module tail_reduction_with_division_by_128
(
input clk,
input [`MODULUS_WIDTH+3-1:0] data_in,
output [`MODULUS_WIDTH-1:0] data_out
    );
    
    
    
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [2*`MODULUS_WIDTH-1:0] input1;
 input [2*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction    
    
    
function [63:0] LUT_parameter_lsb_5;
 input [4:0] LUT_index_output_0;
 input [4:0] LUT_index_output_1;
 integer i_iterator;
 integer full_output;
 begin
    for (i_iterator=0; i_iterator<32; i_iterator=i_iterator+1) begin
        full_output = modular_mult((i_iterator)%`MODULUS, `INVERSE_N, `MODULUS);
        //full_output = 0;
        LUT_parameter_lsb_5[i_iterator] = full_output[LUT_index_output_0];
        LUT_parameter_lsb_5[32+i_iterator] = full_output[LUT_index_output_1];
    end
 end
endfunction    
 function [63:0] LUT_parameter_lsb_7_and_6;
 input [4:0] LUT_index_output_0;
 input [4:0] LUT_index_output_1;
 integer i_iterator;
 integer full_output;
 begin
    for (i_iterator=0; i_iterator<32; i_iterator=i_iterator+1) begin
        full_output = modular_mult((i_iterator[1:0] << (5))%`MODULUS, `INVERSE_N, `MODULUS);
        //full_output = 0;
        LUT_parameter_lsb_7_and_6[i_iterator] = full_output[LUT_index_output_0];
        LUT_parameter_lsb_7_and_6[32+i_iterator] = full_output[LUT_index_output_1];
    end
 end
endfunction  
wire [`MODULUS_WIDTH-1:0] LUT_out [2-1:0];
wire [`MODULUS_WIDTH+2-1:0] sum_out;


       

    
generate
genvar i;
    for (i=0; i<`MODULUS_WIDTH>>1; i=i+1) begin: LUTS_0
      LUT6_2 #(
     .INIT(LUT_parameter_lsb_5((i<<1),(i<<1)+1))  // Specify LUT Contents
      ) LUT6_inst (   // LUT general output
      .O6(LUT_out[0][(i<<1)+1]), // 1-bit LUT6 output
      .O5(LUT_out[0][(i<<1)]), // 1-bit lower LUT5 output
         .I0(data_in[0]), // LUT input
         .I1(data_in[1]), // LUT input
         .I2(data_in[2]), // LUT input
         .I3(data_in[3]), // LUT input
         .I4(data_in[4]), // LUT input
         .I5(1'b1)  // LUT input
      );
      LUT6_2 #(
     .INIT(LUT_parameter_lsb_7_and_6((i<<1),(i<<1)+1))  // Specify LUT Contents
      ) LUT6_inst_2 (   // LUT general output
      .O6(LUT_out[1][(i<<1)+1]), // 1-bit LUT6 output
      .O5(LUT_out[1][(i<<1)]), // 1-bit lower LUT5 output
         .I0(data_in[5]), // LUT input
         .I1(data_in[6]), // LUT input
         .I2(1'bx), // LUT input
         .I3(1'bx), // LUT input
         .I4(1'bx), // LUT input
         .I5(1'b1)  // LUT input
      );
      end
     
endgenerate


efficient_adder_no_3 #(.INPUT_WIDTH(`MODULUS_WIDTH), .OUTPUT_WIDTH(`MODULUS_WIDTH+2))
    compressor_from_3_to_final_form
    (
    .clk(clk),
    .input_a(LUT_out[0]),
    .input_b(LUT_out[1]),
    .input_c({4'b0,data_in[`MODULUS_WIDTH+3-1:7]}),
    .sum(sum_out)
    );
reg  [`MODULUS_WIDTH+1-1:0] reduction_to_21_bit_reg; 
wire [`MODULUS_WIDTH-1:0] result_high;
reg [`MODULUS_WIDTH-1:0]  result_high_reg;
wire [`MODULUS_WIDTH+1-1:0] add_mod_option0;
wire [`MODULUS_WIDTH+1-1:0] add_mod_option1;
assign add_mod_option0 = reduction_to_21_bit_reg;
assign add_mod_option1 = reduction_to_21_bit_reg-`MODULUS;

assign result_high = add_mod_option1[`MODULUS_WIDTH] ? add_mod_option0 : add_mod_option1;

assign data_out = result_high_reg;

always @(posedge clk) begin
    result_high_reg <= result_high;
    reduction_to_21_bit_reg <= sum_out[`MODULUS_WIDTH+1-1:0];

end


endmodule
