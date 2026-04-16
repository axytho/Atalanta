`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2026 07:30:28 PM
// Design Name: 
// Module Name: keccak_triple
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


module keccak_triple(
input clk,
input [`KECCAK_WIDTH-1:0] keccak_input,
input   [64-1:0] round_constant_signal_0,
input   [64-1:0] round_constant_signal_1,
input   [64-1:0] round_constant_signal_2,
output [`KECCAK_WIDTH-1:0] keccak_output
    );
    
wire [`KECCAK_WIDTH-1:0] keccak_output_0;
reg [`KECCAK_WIDTH-1:0] keccak_output_0_reg;
wire [`KECCAK_WIDTH-1:0] keccak_output_1;
reg [`KECCAK_WIDTH-1:0] keccak_output_1_reg;
wire [`KECCAK_WIDTH-1:0] keccak_output_2;
reg [`KECCAK_WIDTH-1:0] keccak_output_2_reg;
always @(posedge clk) begin
    keccak_output_0_reg <= keccak_output_0;
    keccak_output_1_reg <= keccak_output_1;
    keccak_output_2_reg <= keccak_output_2;

end
assign keccak_output = keccak_output_2_reg;

keccak_wrapper keccak_inst_0 (keccak_input,round_constant_signal_0 ,keccak_output_0);
keccak_wrapper keccak_inst_1 (keccak_output_0_reg,round_constant_signal_1,keccak_output_1);
keccak_wrapper keccak_inst_2 (keccak_output_1_reg,round_constant_signal_2 ,keccak_output_2);

endmodule
