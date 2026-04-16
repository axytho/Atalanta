`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2026 06:24:18 PM
// Design Name: 
// Module Name: SamplePolyCBD
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

module SamplePolyCBD(
    input clk,
    input [`SAMPLE_INPUT_WIDTH-1:0] data_in,
    output [`MODULUS_WIDTH-1:0] data_out
    );
    
 function [`MODULUS_WIDTH-1:0] SamplePolyCBD;
 input  [(`SAMPLE_INPUT_WIDTH)-1:0] data_in;
 begin
 SamplePolyCBD = (`MODULUS+data_in[0]+data_in[1]-data_in[2]-data_in[3])%`MODULUS;
 end
 endfunction

reg [`MODULUS_WIDTH-1:0] result_reg;
assign data_out = result_reg;
always @(posedge clk) begin
    result_reg <= SamplePolyCBD(data_in);
end
    
endmodule
