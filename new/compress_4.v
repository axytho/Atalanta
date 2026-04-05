`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2026 03:27:23 PM
// Design Name: 
// Module Name: compress_10
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
module compress_4
#(parameter EXTRA_INPUT_BIT = 0)
(
    input clk,
    input [(`MODULUS_WIDTH)-1:0] data_in,
    output [4-1:0] data_out
    );
 
 function [4-1:0] compress_4;
 input  [(`MODULUS_WIDTH)-1:0] data_in;
 begin
 compress_4 = (data_in<<4)/`MODULUS;
 end
 endfunction
    
reg [(4)-1:0] result_reg;    
always @(posedge clk) begin
    result_reg <= compress_4(data_in); 
end
assign data_out = result_reg;
endmodule
