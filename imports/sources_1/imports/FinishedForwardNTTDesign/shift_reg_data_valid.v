`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2022 01:06:42 PM
// Design Name: 
// Module Name: shift_reg_data_valid
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
module shift_reg_data_valid #(parameter shift = 1) (
    input clk,
    input data_valid,
    output data_valid_out
    );

// DATA_VALID delay


//parameter shift = `BUTTER_FLY_REGISTERS*`STAGE_SIZE;

reg [shift-1:0] data_valid_SLR = {shift{1'b0}};

always @(posedge clk) begin
  data_valid_SLR  <= {data_valid, data_valid_SLR[shift-1:1]};
end
assign data_valid_out = data_valid_SLR[0];



endmodule
