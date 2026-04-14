`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2026 12:27:52 AM
// Design Name: 
// Module Name: convert_to_sample_ntt_input
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


module convert_to_sample_ntt_input #(parameter INDEX_WIDTH=9, parameter INDEX = 0) (
    input clk,
    input [`MODULUS_WIDTH-1:0] data_in,
    output [`MODULUS_WIDTH + INDEX_WIDTH+1-1:0 ] data_out
    );
    
reg [`MODULUS_WIDTH + INDEX_WIDTH+1-1:0 ]  result_reg;
always @(posedge clk) begin
    result_reg[`MODULUS_WIDTH-1:0] <= data_in;
    result_reg[`MODULUS_WIDTH + INDEX_WIDTH-1:`MODULUS_WIDTH] <= INDEX;
    result_reg[`MODULUS_WIDTH + INDEX_WIDTH+1-1] <= (data_in<`MODULUS);
end

assign data_out = result_reg;
endmodule
