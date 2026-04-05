`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2026 03:31:47 PM
// Design Name: 
// Module Name: compress
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


`include "parameters.v" `include "ntt_params.v"
module compress
#(parameter EXTRA_INPUT_BIT = 0)
(
    input clk,
    input [(`MODULUS_WIDTH)-1:0] data_in,
    output [10-1:0] data_out
    );

reg [`MODULUS_WIDTH+1-1:0] i_modified;    
always @(posedge clk) begin
    i_modified <= {data_in,10'b0} + 12'b11010000000; //
end





endmodule
