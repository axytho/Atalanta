`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 05:20:00 AM
// Design Name: 
// Module Name: hw_eval_kyber
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven
// 
// Create Date: 03/07/2026 04:32:37 PM
// Design Name: 
// Module Name: hw_eval_keccak
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

`include "ntt_params.v"
`include "parameters.v"


module hw_eval_kyber(
    input                    clk,
    input                    reset,
    input  [15          : 0] in_init,
    output [15-1 : 0] out
    );
wire [10-1:0] xor_out;
compress_10 compress_instance (clk, in_init[12-1:0],xor_out);
wire [1600-1:0] keccak_input;
wire [1600-1:0] keccak_output;


reg reset_reg;
always @(posedge clk) begin
reset_reg <= reset;
end







key_encapsulation keyencap(clk,reset, 256'd1234817209348712409387, {keccak_input, {9472-8000{1'b0}},keccak_input,keccak_input,keccak_input,keccak_input},keccak_input[0], keccak_output[`K_WIDTH-1:0], keccak_output[`K_WIDTH+`CIPHERTEXT_WIDTH-1:`K_WIDTH], data_valid_out);



LFSR #(1600) LSFR_inst (.clk(clk), .resetn(~reset_reg), .in_init(in_init), .out(keccak_input));

generate
genvar iterator;
for (iterator=0;iterator<(16);iterator=iterator+1) begin
assign out[iterator] = ^keccak_output[100*iterator+:100] ^ xor_out;
end
endgenerate
endmodule


