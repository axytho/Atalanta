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
#(parameter EXTRA_INPUT_BIT = 0)
(
    input clk,
    input [(`MODULUS_WIDTH<<1)+EXTRA_INPUT_BIT-1:0] data_in,
    output [`MODULUS_WIDTH-1:0] data_out
    );
    
if (`MODULUS == 20'hc0001) begin
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
end else if (`MODULUS == 12'hd01) begin

// stage 1
function [63:0] LUT_parameter;
 input [3:0] LUT_index;
 integer i;
 integer full_output;
 begin
    for (i=0; i<64; i=i+1) begin
        full_output = (i << (18+ EXTRA_INPUT_BIT)) % 3329;
        LUT_parameter[i] = full_output[LUT_index];
    end
 end
endfunction
wire [11:0] LUT_out;

    genvar i;
    for (i=0; i<12; i=i+1) begin: LUTS
      LUT6 #(
     .INIT(LUT_parameter(i))  // Specify LUT Contents
      ) LUT6_inst (
             .O(LUT_out[i]),   // LUT general output
         .I0(data_in[18+EXTRA_INPUT_BIT]), // LUT input
         .I1(data_in[19+EXTRA_INPUT_BIT]), // LUT input
         .I2(data_in[20+EXTRA_INPUT_BIT]), // LUT input
         .I3(data_in[21+EXTRA_INPUT_BIT]), // LUT input
         .I4(data_in[22+EXTRA_INPUT_BIT]), // LUT input
         .I5(data_in[23+EXTRA_INPUT_BIT])  // LUT input
      );
    end

wire [18+EXTRA_INPUT_BIT:0] LUT_reduced;
assign LUT_reduced = data_in[17+EXTRA_INPUT_BIT:0] + LUT_out;
reg [18+EXTRA_INPUT_BIT:0] LUT_reduced_reg;
always @(posedge clk) begin
    LUT_reduced_reg <= LUT_reduced;
end
//stage 2
wire [13:0] Kred_upper;
wire [10:0] Kred_lower;
assign Kred_upper =  LUT_reduced_reg[18+EXTRA_INPUT_BIT:8] - {2'b0, LUT_reduced_reg[7:0], 3'b0};
assign Kred_lower = {2'b0, LUT_reduced_reg[7:0]} + {LUT_reduced_reg[7:0], 2'b0};
wire [12:0] Kred_result;
assign Kred_result = Kred_upper - Kred_lower;
reg [12:0] Kred_result_reg;
always @(posedge clk) begin
    Kred_result_reg <= Kred_result;
end
//stage 3
wire [12:0] total_sum;
assign total_sum = Kred_result_reg;
wire [12:0] plus_or_zero_q;
assign plus_or_zero_q = (total_sum[12] ? 12'hd01 : 0);
assign data_out = total_sum + plus_or_zero_q;
end else begin

// @ USER: Write your custom modulus reduction function from 2*MODULUS_WIDTH to MODULUS_WIDTH here!


end
endmodule
