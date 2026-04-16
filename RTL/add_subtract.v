`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2024 02:42:03 PM
// Design Name: 
// Module Name: add_subtract
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


module add_subtract(
    input clk,
    input [`MODULUS_WIDTH-1:0] input_a,
    input [`MODULUS_WIDTH-1:0] input_b,
    input sign,
    output [`MODULUS_WIDTH-1:0] data_out
    );
    
reg [`MODULUS_WIDTH-1:0]  data_out_reg;
reg [`MODULUS_WIDTH+1-1:0] data_out_reg_raw;
always @(posedge clk) begin
    if (sign)
        data_out_reg_raw <= `MODULUS - input_a - input_b;
    else
        data_out_reg_raw <= input_a - input_b;
end
always @(posedge clk) begin
    if (data_out_reg_raw[`MODULUS_WIDTH])
        data_out_reg <= data_out_reg_raw+`MODULUS;
    else
        data_out_reg <= data_out_reg_raw;
end
    
assign data_out = data_out_reg;
    
endmodule
