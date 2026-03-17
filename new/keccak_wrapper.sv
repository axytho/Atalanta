`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 03:55:56 PM
// Design Name: 
// Module Name: keccak_wrapper
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


module keccak_wrapper(
input [`KECCAK_WIDTH-1:0] keccak_input,
input   [64-1:0] Round_constant_signal,
output [`KECCAK_WIDTH-1:0] keccak_output
    );
    

parameter int NUM_PLANE             = 5;
parameter int NUM_SHEET             = 5;
parameter int unsigned N            = 64;
parameter int unsigned IN_BUF_SIZE  = 64;
parameter int unsigned OUT_BUF_SIZE = 64;
wire k_state Round_in,Round_out;
generate
genvar i, j, k, l;
for (j=0; j<5; j=j+1) begin
for (k=0; k<5; k=k+1) begin
for (l=0; l<64; l=l+1) begin
assign Round_in[j][k][l] = keccak_input[5*64*j+64*k+l];
assign keccak_output[5*64*j+64*k+l] = Round_out[j][k][l];
end
end
end
endgenerate
keccak_round keccak_inst (Round_in,Round_constant_signal ,Round_out);
endmodule
