`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2025 09:37:44 AM
// Design Name: 
// Module Name: grayhairstreak
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


module grayhairstreak
#(parameter TWIDDLE = 0)
(
input clk,
input [`MODULUS_WIDTH+3-1:0] mult_input,
output [`MODULUS_WIDTH-1:0] mult_output_0,
output [`MODULUS_WIDTH-1:0] mult_output_1,
output [`MODULUS_WIDTH-1:0] mult_output_2
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
 input [2:0] part;
 integer i_iterator;
 integer full_output;
 begin
    for (i_iterator=0; i_iterator<32; i_iterator=i_iterator+1) begin
        full_output = modular_mult((i_iterator << (part*5))%`MODULUS, TWIDDLE, `MODULUS);
        //full_output = 0;
        LUT_parameter[i_iterator] = full_output[LUT_index_output_0];
        LUT_parameter[32+i_iterator] = full_output[LUT_index_output_1];
    end
 end
endfunction    
    
wire [`MODULUS_WIDTH-1:0] LUT_out [`SECTIONS-1:0];


       

    
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
         .I0(mult_input[5*j+0]), // LUT input
         .I1(mult_input[5*j+1]), // LUT input
         .I2(mult_input[5*j+2]), // LUT input
         .I3(mult_input[5*j+3]), // LUT input
         .I4(mult_input[5*j+4]), // LUT input
         .I5(1'b1)  // LUT input
      );
      end
     
  end
endgenerate




assign mult_output_0 =LUT_out[0];
assign mult_output_1 =LUT_out[1];
assign mult_output_2 =LUT_out[2];

endmodule
