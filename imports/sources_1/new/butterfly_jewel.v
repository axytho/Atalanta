`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven (All rights go to them)
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
// Revision 2: Created from butterfly_14bis: we go fully for lazy reduction
// Revision 0.04-- works in simulation
// Revision 0.03 - Fixed shift_rotate problems
// Revision 0.02 - first version, trying to make all shifts work to `MODULUS_WIDTH (so simple CT works)
// Revision 0.01 - File Created
// Additional Comments:


//TODO:
//1) replace by shift_reg if twiddle = 1 DONE
//2) Improve modular add and modular sub to only take 20 LUTS and increase possibillities to range between 0 to 2^20
//3) Replace small shift regs of 4 by 4 FDREs chained (use primitives) (10% improvement)
// ACTUALLY, WE DON'T DO 2 and 3, instead we do lazy reduction and reduce number of regs

// 
//////////////////////////////////////////////////////////////////////////////////
`include "parameters.v"

module butterfly_jewel //Currently 49341 LUTS ad 63805 FFs with this version
#(parameter TWIDDLE = 0, parameter DIRECTION = "FORWARD", parameter STAGE = 1)
(
    input clk,
    input [`MODULUS_WIDTH+(STAGE>0)*3-1:0] input_a, // the two here is from the fact that our mult increases everything by a factor 5.
    input [`MODULUS_WIDTH+(STAGE>0)*3-1:0] input_b,
    output [`MODULUS_WIDTH+3-1:0] output_a,
    output [`MODULUS_WIDTH+3-1:0] output_b
    );
localparam input_width = (STAGE==0) ? `MODULUS_WIDTH : `MODULUS_WIDTH+3;
localparam output_width = `MODULUS_WIDTH+3;

localparam stage_greater_than_zero = (STAGE>0);
wire [`MODULUS_WIDTH+3-1:0] mult_input;
wire [`MODULUS_WIDTH-1:0] mult_output_0;
wire [`MODULUS_WIDTH-1:0] mult_output_1;
wire [`MODULUS_WIDTH-1:0] mult_output_2;
wire [`MODULUS_WIDTH+2-1:0] mult_final_sum;
reg [`MODULUS_WIDTH+2-1:0] mult_final_sum_reg;
reg [output_width-1:0] input_a_reg;

reg [output_width-1:0] output_a_reg;
reg [output_width-1:0] output_b_reg;
reg [`MODULUS_WIDTH+2-1:0] full_sum_reg;
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [2*`MODULUS_WIDTH-1:0] input1;
 input [2*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction  
function [63:0] LUT_parameter_add_one_bit_no_twiddle;
 input [4:0] LUT_index_output_0;
 input [3:0] index;
 integer i_iterator_add_one;
 integer full_output_add_one;
 begin
    for (i_iterator_add_one=0; i_iterator_add_one<64; i_iterator_add_one=i_iterator_add_one+1) begin
        full_output_add_one = modular_mult((i_iterator_add_one[4:0] << (index))%`MODULUS, 1, `MODULUS);
        //full_output = 0;
        LUT_parameter_add_one_bit_no_twiddle[i_iterator_add_one] = i_iterator_add_one[5] ^ full_output_add_one[LUT_index_output_0];
    end
 end
endfunction  


    //TODO: MAKE PARAMETRIC IF YOU WANT THIS TO WORK FOR MULTIPLE MODULUS WIDTHs
    
    grayhairstreak #(.TWIDDLE(TWIDDLE)) gray_hairstreak_inst 
    (.clk(clk),
    .mult_input(mult_input),
    .mult_output_0(mult_output_0),
    .mult_output_1(mult_output_1),
    .mult_output_2(mult_output_2)
    );
    efficient_adder_no_3 #(.INPUT_WIDTH(`MODULUS_WIDTH), .OUTPUT_WIDTH(`MODULUS_WIDTH+2))
    compressor_from_3_to_final_form
    (
    .clk(clk),
    .input_a(mult_output_0),
    .input_b(mult_output_1),
    .input_c(mult_output_2),
    .sum(mult_final_sum)
    );
    always @(posedge clk) begin
    mult_final_sum_reg <= mult_final_sum;
    output_a_reg <= mult_final_sum_reg + input_a_reg;
    output_b_reg <= `MODULUS*3+input_a_reg-mult_final_sum_reg;
    end
     




generate
genvar mult_iterator;
for (mult_iterator=0; mult_iterator< `MODULUS_WIDTH+3; mult_iterator=mult_iterator+1) begin
    if (mult_iterator < input_width) begin
        assign mult_input[mult_iterator] = input_b[mult_iterator];
    end else begin
        assign mult_input[mult_iterator] = 1'b0;
    end
end

wire [`MODULUS_WIDTH+3-1:0] input_a_reductor;
genvar output_a_iterator;
for (output_a_iterator=0; output_a_iterator< `MODULUS_WIDTH+3; output_a_iterator=output_a_iterator+1) begin
    if (output_a_iterator < input_width) begin
        assign input_a_reductor[output_a_iterator] = input_a[output_a_iterator];
    end else begin
        assign input_a_reductor[output_a_iterator] = 1'b0;
    end
end
wire [`MODULUS_WIDTH+1-1:0] mult_final_sum_small_a_red;
wire [`MODULUS_WIDTH-1:0] mult_final_sum_raw_a_red;
genvar i;
 for (i=0; i<`MODULUS_WIDTH; i=i+1) begin: LUTS_END
          LUT6 #(
         .INIT(LUT_parameter_add_one_bit_no_twiddle(i, `MODULUS_WIDTH))  // Specify LUT Contents
          ) LUT6_inst (   // LUT general output
              .O(mult_final_sum_raw_a_red[i]), // 1-bit LUT6 output
             .I0(input_a_reductor[`MODULUS_WIDTH]), // LUT input
             .I1(input_a_reductor[`MODULUS_WIDTH+1]), // LUT input
             .I2(input_a_reductor[`MODULUS_WIDTH+2]), // LUT input
             .I3(1'b0), // LUT input
             .I4(1'b0), // LUT input
             .I5(input_a_reductor[i])  // LUT input
          );
      end
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
      .DI({4'bx, input_a_reductor[11:8]}),         // 8-bit input: Carry-MUX data in
      .S({4'bx,mult_final_sum_raw_a_red[11:8]})            // 8-bit input: Carry-mux select
  );
    assign mult_final_sum_small_a_red[`MODULUS_WIDTH] = CO_a_red[`MODULUS_WIDTH-1];
    assign CO_a_red[11:8] = last_output_rounded_CO_a_red[3:0];
    assign mult_final_sum_small_a_red[11:8] = last_output_rounded_O_a_red[3:0];
endgenerate
always @(posedge clk) begin
    input_a_reg <= {2'b0, mult_final_sum_small_a_red};
end
assign output_a = output_a_reg;
assign output_b = output_b_reg;





endmodule
