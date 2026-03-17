`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2026 10:54:21 AM
// Design Name: 
// Module Name: coefficient_multiplication
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
`include "ntt_params.v"
module coefficient_multiplication (
    input clk,
    input [(`MODULUS_WIDTH<<`REDUCED_POLYNOMIAL_DEPTH)-`MODULUS_WIDTH-1:0] twiddle_in,
    input [(`MODULUS_WIDTH<<`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_in_0,
    input [(`MODULUS_WIDTH<<`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_in_1,
    input data_valid,
    output data_valid_out,
    output [(`MODULUS_WIDTH<<`REDUCED_POLYNOMIAL_DEPTH)-1:0] data_out
    );
    
    
    
    
    
generate
//TODO: create a non-case statement convolution, so that you could do it for any REDUCED_POLYNOMIAL_DEPTH
//In reality, for Kyber =1, for almost all others = 0, and if this is not the case you probably want
// to handcraft this module anyway, so for now we do a case statement.
if (`REDUCED_POLYNOMIAL_DEPTH == 1) begin//////////////////////////////////////////////////////////////////////////////////


wire [`MODULUS_WIDTH-1:0] a0, a1, b0, b1, twiddle_a1;
assign a0 = data_in_0[`MODULUS_WIDTH-1:0];
assign a1 = data_in_0[2*`MODULUS_WIDTH-1:`MODULUS_WIDTH];
assign b0 = data_in_1[`MODULUS_WIDTH-1:0];
assign b1 = data_in_1[2*`MODULUS_WIDTH-1:`MODULUS_WIDTH];
wire [`MODULUS_WIDTH-1:0] a0_shift,a1_shift, b0_shift, b1_shift;
modular_multiplier mod_mult(clk, a1, twiddle_in, twiddle_a1);
shift_reg_width #(.shift(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY), .width(`MODULUS_WIDTH)) a0_shift_inst (clk, a0, a0_shift);
shift_reg_width #(.shift(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY), .width(`MODULUS_WIDTH)) a1_shift_inst (clk, a1, a1_shift);
shift_reg_width #(.shift(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY), .width(`MODULUS_WIDTH)) b0_shift_inst (clk, b0, b0_shift);
shift_reg_width #(.shift(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY), .width(`MODULUS_WIDTH)) b1_shift_inst (clk, b1, b1_shift);
wire [2*`MODULUS_WIDTH-1:0] c0_product,c1_product, d0_product, d1_product;
DSP_optimized_FINAL c0_product_inst(.CLK(clk), .A(a0_shift), .B(b0_shift), .P(c0_product));
DSP_optimized_FINAL c1_product_inst(.CLK(clk), .A(twiddle_a1), .B(b1_shift), .P(c1_product));
DSP_optimized_FINAL d0_product_inst(.CLK(clk), .A(a0_shift), .B(b1_shift), .P(d0_product));
DSP_optimized_FINAL d1_product_inst(.CLK(clk), .A(a1_shift), .B(b0_shift), .P(d1_product));
reg [2*`MODULUS_WIDTH+1-1:0] c_sum,d_sum;
always @(posedge clk) begin
    c_sum <= c0_product+ c1_product;
    d_sum <= d0_product+ d1_product;
end
reduction #(.EXTRA_INPUT_BIT(1)) reduction_0(.clk(clk), .data_in(c_sum), .data_out(data_out[`MODULUS_WIDTH-1:0]));
reduction #(.EXTRA_INPUT_BIT(1)) reduction_1(.clk(clk), .data_in(d_sum), .data_out(data_out[2*`MODULUS_WIDTH-1:`MODULUS_WIDTH]));

shift_reg_data_valid #(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY+`MULTIPLIER_LATENCY+1+`REDUCTION_LATENCY) shift_instance_2 (clk, data_valid, data_valid_out);  

    






end else begin/////////////////////////////////////////////////////////////////////////////////////////
modular_multiplier(clk, data_in_0,data_in_1, ,data_out);
shift_reg_data_valid #(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY) shift_instance_2 (clk, data_valid, data_valid_out);  

end


//genvar i;    
//for (i=0; i<(1<<`REDUCED_POLYNOMIAL_WIDTH); i=i+1) begin
   //data_in 
//end
endgenerate


endmodule
