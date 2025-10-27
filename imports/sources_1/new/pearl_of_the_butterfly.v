`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: COSIC KU Leuven
// Engineer: Jonas Bertels
// 
// Create Date: 09/29/2024 02:33:38 PM
// Design Name: Pearl Of The Butterfly 
// Module Name: pearl_of_the_butterfly
// Project Name: Quatorze 14 bis
// Target Devices: U55, U250
// Tool Versions: Vivado 2020.2
// Description: Basically, a compute in memory butterfly, 
// but the original idea is actually based on LUT reduction
// 
// Dependencies: None
// 
// Revision: 1.0.0 LUT + 2 bit reduction + 1 bit reduction
// Revision 0.01 - File Created
// Additional Comments: ALL RIGHTS RESERVED KU LEUVEN (seriously, our legal department will hunt you down for sport)
// 
//////////////////////////////////////////////////////////////////////////////////



`include "parameters.v" `include "ntt_params.v"
module pearl_of_the_butterfly
#(parameter TWIDDLE = 0)
(
    input clk,
    input [`MODULUS_WIDTH-1:0] input_a,
    output [`MODULUS_WIDTH-1:0] output_product
    );
    
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [2*`MODULUS_WIDTH-1:0] input1;
 input [2*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction    
 
function [63:0] LUT_parameter;
 input [4:0] LUT_index_output_0;
 input [4:0] LUT_index_output_1;
 input [1:0] part;
 integer i_iterator;
 integer full_output;
 begin
    for (i_iterator=0; i_iterator<32; i_iterator=i_iterator+1) begin
        full_output = modular_mult((i_iterator << (part*5)), TWIDDLE, `MODULUS);
        //full_output = 0;
        LUT_parameter[i_iterator] = full_output[LUT_index_output_0];
        LUT_parameter[32+i_iterator] = full_output[LUT_index_output_1];
    end
 end
endfunction
wire [`MODULUS_WIDTH-1:0] LUT_out [`SECTIONS-1:0];
reg [`MODULUS_WIDTH*`SECTIONS-1:0] LUT_out_reg;
generate
    genvar i;
    genvar j;
    for (j=0; j<`SECTIONS; j=j+1) begin: MULTIPLE_SECTIONS_DIVINDING_INPUT
    for (i=0; i<`MODULUS_WIDTH>>1; i=i+1) begin: LUTS_0
      LUT6_2 #(
     .INIT(LUT_parameter((i<<1),(i<<1)+1,j))  // Specify LUT Contents
      ) LUT6_inst (   // LUT general output
      .O6(LUT_out[j][(i<<1)+1]), // 1-bit LUT6 output
      .O5(LUT_out[j][(i<<1)]), // 1-bit lower LUT5 output
         .I0(input_a[5*j+0]), // LUT input
         .I1(input_a[5*j+1]), // LUT input
         .I2(input_a[5*j+2]), // LUT input
         .I3(input_a[5*j+3]), // LUT input
         .I4(input_a[5*j+4]), // LUT input
         .I5(1'b1)  // LUT input
      );


      end
      always @(posedge clk) begin
        LUT_out_reg[`MODULUS_WIDTH*j+:`MODULUS_WIDTH]<=LUT_out[j];
    end

      end
    

endgenerate

generate
if (~(TWIDDLE==1)) begin
    //TODO: MAKE PARAMETRIC IF YOU WANT THIS TO WORK FOR MULTIPLE MODULUS WIDTHs
    reg [`MODULUS_WIDTH+2-1:0] sum_lo;
    reg [`MODULUS_WIDTH-1:0]  sum_hi;
    reg [`MODULUS_WIDTH+2-1:0] sum;
    wire  [`GOLD_MODULUS_WIDTH+1-1:0] reduction_one_addition_above_modulus;
    reg  [`GOLD_MODULUS_WIDTH+1-1:0] reduction_one_addition_above_modulus_reg;
    wire [`GOLD_MODULUS_WIDTH-1:0] result_high;
    reg [`GOLD_MODULUS_WIDTH-1:0]  result_high_reg;
    wire [`MODULUS_WIDTH+2-1:0] add_mod_option0;
    wire [`MODULUS_WIDTH+2-1:0] add_mod_option1;
    wire [`MODULUS_WIDTH+2-1:0] first_three_terms_sum;
    efficient_adder inst_adder_3_to_1 (
    .clk(clk),
    .input_a(LUT_out_reg[`MODULUS_WIDTH*0+:`MODULUS_WIDTH]),
    .input_b(LUT_out_reg[`MODULUS_WIDTH*1+:`MODULUS_WIDTH]),
    .input_c(LUT_out_reg[`MODULUS_WIDTH*2+:`MODULUS_WIDTH]),
    .sum(first_three_terms_sum)
    );
    always @(posedge clk) begin
        sum_lo <= first_three_terms_sum;
        sum_hi <= LUT_out_reg[`MODULUS_WIDTH*3+:`MODULUS_WIDTH];
        sum <= sum_lo + sum_hi;
    end
    assign reduction_one_addition_above_modulus = (sum[21:20]<<18)+ sum[19:0] -sum[21:20] ;
        
    assign add_mod_option0 = reduction_one_addition_above_modulus_reg;
    assign add_mod_option1 = reduction_one_addition_above_modulus_reg-`MODULUS;
    
    assign result_high =add_mod_option1[`MODULUS_WIDTH+2-1] ? add_mod_option0 : add_mod_option1;
    
    assign output_product = result_high_reg;
    
    always @(posedge clk) begin
        reduction_one_addition_above_modulus_reg <= reduction_one_addition_above_modulus;
        result_high_reg <= result_high;
    end
end else begin
    shift_reg_width #(.width(`MODULUS_WIDTH), .shift(`PEARL_LATENCY)) shift_inst (clk, input_a, output_product);
end
endgenerate
endmodule
