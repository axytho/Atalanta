`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2026 01:17:28 PM
// Design Name: 
// Module Name: constant_delay_buffer
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


module constant_delay_buffer #(parameter shift = 1, parameter width =1) (
    input clk,
    input [width-1:0] data_in,
    output [width-1:0] data_out
    );
    
    
reg [width-1:0] internal_reg [0:shift-1];    
assign data_out = internal_reg[shift-1];
always @(posedge clk) begin
    internal_reg[0] <= data_in;
end
generate
genvar i;

    for (i=0; i<(shift-1); i=i+1) begin
        always @(posedge clk) begin
            internal_reg[i+1] <= internal_reg[i];
        end
    end
endgenerate
endmodule
