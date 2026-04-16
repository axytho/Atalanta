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
module compress_10
#(parameter EXTRA_INPUT_BIT = 0)
(
    input clk,
    input [(`MODULUS_WIDTH)-1:0] data_in,
    output [10-1:0] data_out
    );
 
 function [10-1:0] compress_10;
 input  [(`MODULUS_WIDTH+10)-1:0] data_in;
 begin
 compress_10 = (data_in<<10)/`MODULUS;
 end
 endfunction
    
reg [(10)-1:0] result_reg;    
always @(posedge clk) begin
    result_reg <= compress_10({10'b0,data_in}); 
end
assign data_out = result_reg;
endmodule
