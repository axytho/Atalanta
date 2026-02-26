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
module reduction_tail_ntt
#(parameter ADDED_WIDTH = 5)
(
    input clk,
    input [(`MODULUS_WIDTH+ADDED_WIDTH)-1:0] data_in,
    output [`MODULUS_WIDTH-1:0] data_out
    );
    
    

function [63:0] LUT_reduce_below;
 input [4:0] LUT_index_output_0;
 input [4:0] index;
 integer i_iterator_add_one;
 integer full_output_add_one;
 begin
    for (i_iterator_add_one=0; i_iterator_add_one<64; i_iterator_add_one=i_iterator_add_one+1) begin
        full_output_add_one = (i_iterator_add_one[4:0] << (index))%`MODULUS;
        //full_output = 0;
        LUT_reduce_below[i_iterator_add_one] = i_iterator_add_one[5] ^ full_output_add_one[LUT_index_output_0];
    end
 end
endfunction      
    



wire [`MODULUS_WIDTH+4-1:0] input_a_reductor;
wire [`MODULUS_WIDTH+1-1:0] mult_final_sum_small_a_red;
wire [`MODULUS_WIDTH-1:0] mult_final_sum_raw_a_red;
generate
genvar output_a_iterator;
genvar i;
for (output_a_iterator=0; output_a_iterator< `MODULUS_WIDTH+4; output_a_iterator=output_a_iterator+1) begin
    if (output_a_iterator < (`MODULUS_WIDTH+ADDED_WIDTH)) begin
        assign input_a_reductor[output_a_iterator] = data_in[output_a_iterator];
    end else begin
        assign input_a_reductor[output_a_iterator] = 1'b0;
    end
end




for (i=0; i<`MODULUS_WIDTH-1; i=i+1) begin: LUTS_END
      LUT6 #(
     .INIT(LUT_reduce_below(i,`MODULUS_WIDTH-1))  // Specify LUT Contents
     //.INIT(64'b0)  // Specify LUT Contents
      ) LUT6_inst (   // LUT general output
          .O(mult_final_sum_raw_a_red[i]), // 1-bit LUT6 output
         .I0(input_a_reductor[`MODULUS_WIDTH-1]), // LUT input
         .I1(input_a_reductor[`MODULUS_WIDTH]), // LUT input
         .I2(input_a_reductor[`MODULUS_WIDTH+1]), // LUT input
         .I3(input_a_reductor[`MODULUS_WIDTH+2]), // LUT input
         .I4(input_a_reductor[`MODULUS_WIDTH+3]), // LUT input
         .I5(input_a_reductor[i])  // LUT input
      );
  end
  
  //FOR THE 11TH BIT, WE DO A SPECIAL THING AS HERE YOU'RE ADDING WITH 0
        LUT6 #(
     .INIT(LUT_reduce_below(`MODULUS_WIDTH-1,`MODULUS_WIDTH-1))  // Specify LUT Contents
     //.INIT(64'b0)  // Specify LUT Contents
      ) LUT6_inst (   // LUT general output
          .O(mult_final_sum_raw_a_red[`MODULUS_WIDTH-1]), // 1-bit LUT6 output
         .I0(input_a_reductor[`MODULUS_WIDTH-1]), // LUT input
         .I1(input_a_reductor[`MODULUS_WIDTH]), // LUT input
         .I2(input_a_reductor[`MODULUS_WIDTH+1]), // LUT input
         .I3(input_a_reductor[`MODULUS_WIDTH+2]), // LUT input
         .I4(input_a_reductor[`MODULUS_WIDTH+3]), // LUT input
         .I5(1'b0)  // LUT input
      );
  
endgenerate
    wire [`MODULUS_WIDTH-1:0] CO_a_red;
    wire [8-1:0] last_output_rounded_CO_a_red;
    wire [8-1:0] last_output_rounded_O_a_red;
     CARRY8 #(
      .CARRY_TYPE("SINGLE_CY8")  // 8-bit or dual 4-bit carry (DUAL_CY4, SINGLE_CY8)
  )
  CARRY8_inst_0_to_7 (
      .CO(CO_a_red[7:0]),         // 8-bit output: Carry-out
      .O(mult_final_sum_small_a_red[7:0]),           // 8-bit output: Carry chain XOR data out
      .CI(1'b0),         // 1-bit input: Lower Carry-In
      .CI_TOP(1'b0), // 1-bit input: Upper Carry-In
      .DI(input_a_reductor[7:0]),         // 8-bit input: Carry-MUX data in
      .S(mult_final_sum_raw_a_red[7:0])            // 8-bit input: Carry-mux select
  ); 

   CARRY8 #(
      .CARRY_TYPE("SINGLE_CY8")  // 8-bit or dual 4-bit carry (DUAL_CY4, SINGLE_CY8)
  )
    CARRY8_inst_16_to_19 (
      .CO(last_output_rounded_CO_a_red),         // 8-bit output: Carry-out
      .O(last_output_rounded_O_a_red),           // 8-bit output: Carry chain XOR data out
      .CI(CO_a_red[7]),         // 1-bit input: Lower Carry-In
      .CI_TOP(1'bx), // 1-bit input: Upper Carry-In
      .DI({4'bx, 1'b0,input_a_reductor[10:8]}),         // 8-bit input: Carry-MUX data in
      .S({4'bx,mult_final_sum_raw_a_red[11:8]})            // 8-bit input: Carry-mux select
  );
    assign mult_final_sum_small_a_red[`MODULUS_WIDTH] = CO_a_red[`MODULUS_WIDTH-1];
    assign CO_a_red[11:8] = last_output_rounded_CO_a_red[3:0];
    assign mult_final_sum_small_a_red[11:8] = last_output_rounded_O_a_red[3:0];



wire [`MODULUS_WIDTH-1:0] three_times_b,  b_plus_c_without_negative_carry;
reg  [`MODULUS_WIDTH-1:0] three_times_b_reg,  b_plus_c_without_negative_carry_reg;
wire [`MODULUS_WIDTH+1-1:0] reduction_to_21_bit;
wire  [`MODULUS_WIDTH+1-1:0] reduction_one_addition_above_modulus;
reg  [`MODULUS_WIDTH+1-1:0] reduction_to_21_bit_reg; 
reg  [`MODULUS_WIDTH+1-1:0] reduction_one_addition_above_modulus_reg;
wire [`MODULUS_WIDTH-1:0] result_high;
reg [`MODULUS_WIDTH-1:0]  result_high_reg;
wire [`MODULUS_WIDTH+2-1:0] a;
wire [`MODULUS_WIDTH-2-1:0] b;
wire [`MODULUS_WIDTH+1-1:0] add_mod_option0;
wire [`MODULUS_WIDTH+1-1:0] add_mod_option1;
reg [`MODULUS_WIDTH+2-1:0] a_reg;




assign add_mod_option0 = reduction_to_21_bit_reg;
assign add_mod_option1 = reduction_to_21_bit_reg-`MODULUS;

assign result_high = add_mod_option1[`MODULUS_WIDTH] ? add_mod_option0 : add_mod_option1;

assign data_out = result_high_reg;

always @(posedge clk) begin
    result_high_reg <= result_high;
    reduction_to_21_bit_reg <= mult_final_sum_small_a_red;

end

endmodule
