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



module hw_eval_keccak(
    input                    clk,
    input                    reset,
    input  [15          : 0] in_init,
    output [15-1 : 0] out
    );

wire [1600-1:0] keccak_input;
wire [1600-1:0] keccak_output;
parameter int NUM_PLANE             = 5;
parameter int NUM_SHEET             = 5;
parameter int unsigned N            = 64;
parameter int unsigned IN_BUF_SIZE  = 64;
parameter int unsigned OUT_BUF_SIZE = 64;


typedef logic   [N-1:0]             k_lane;
typedef k_lane  [NUM_SHEET-1:0]     k_plane;
typedef k_plane [NUM_PLANE-1:0]     k_state;
typedef k_state [25-1:0]     k_all;


reg reset_reg;
always @(posedge clk) begin
reset_reg <= reset;
end
k_all internal_wiring;
k_all internal_wiring_reg;

wire k_state Round_in,Round_out;
assign internal_wiring[0] = keccak_input;
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
assign internal_wiring[0] = Round_in;
assign Round_out = internal_wiring[24];
wire   [4:0]          round_number;

always @(posedge clk) begin
internal_wiring_reg <= internal_wiring;

end



for (i=0; i<25; i=i+1) begin
keccak_round keccak_inst (internal_wiring_reg[i],round_constant_signal_out(i) ,internal_wiring[i+1]);
end

endgenerate




function [63:0] round_constant_signal_out;
input [4:0] round_number;
        case(round_number)
            5'b00000 : round_constant_signal_out = 64'h0000_0000_0000_0001;
            5'b00001 : round_constant_signal_out = 64'h0000_0000_0000_8082;
            5'b00010 : round_constant_signal_out = 64'h8000_0000_0000_808A;
            5'b00011 : round_constant_signal_out = 64'h8000_0000_8000_8000;
            5'b00100 : round_constant_signal_out = 64'h0000_0000_0000_808B;
            5'b00101 : round_constant_signal_out = 64'h0000_0000_8000_0001;
            5'b00110 : round_constant_signal_out = 64'h8000_0000_8000_8081;
            5'b00111 : round_constant_signal_out = 64'h8000_0000_0000_8009;
            5'b01000 : round_constant_signal_out = 64'h0000_0000_0000_008A;
            5'b01001 : round_constant_signal_out = 64'h0000_0000_0000_0088;
            5'b01010 : round_constant_signal_out = 64'h0000_0000_8000_8009;
            5'b01011 : round_constant_signal_out = 64'h0000_0000_8000_000A;
            5'b01100 : round_constant_signal_out = 64'h0000_0000_8000_808B;
            5'b01101 : round_constant_signal_out = 64'h8000_0000_0000_008B;
            5'b01110 : round_constant_signal_out = 64'h8000_0000_0000_8089;
            5'b01111 : round_constant_signal_out = 64'h8000_0000_0000_8003;
            5'b10000 : round_constant_signal_out = 64'h8000_0000_0000_8002;
            5'b10001 : round_constant_signal_out = 64'h8000_0000_0000_0080;
            5'b10010 : round_constant_signal_out = 64'h0000_0000_0000_800A;
            5'b10011 : round_constant_signal_out = 64'h8000_0000_8000_000A;
            5'b10100 : round_constant_signal_out = 64'h8000_0000_8000_8081;
            5'b10101 : round_constant_signal_out = 64'h8000_0000_0000_8080;
            5'b10110 : round_constant_signal_out = 64'h0000_0000_8000_0001;
            5'b10111 : round_constant_signal_out = 64'h8000_0000_8000_8008;
            default : round_constant_signal_out = '0;

        endcase
endfunction

LFSR #(1600) LSFR_inst (.clk(clk), .resetn(~reset_reg), .in_init(in_init), .out(keccak_input));

generate
genvar iterator;
for (iterator=0;iterator<(16);iterator=iterator+1) begin
assign out[iterator] = ^keccak_output[100*iterator+:100];
end
endgenerate
endmodule
