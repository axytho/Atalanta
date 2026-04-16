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


module shift_reg_width_CE #(parameter shift = 1, parameter width =1) (
    input clk,
    input CE,
    input [width-1:0] data_in,
    output [width-1:0] data_out
    );

// DATA_VALID delay


//parameter shift = `BUTTER_FLY_REGISTERS*`STAGE_SIZE;
wire [width*shift-1:0] data_valid_SLR_in;
reg [width*shift-1:0] data_valid_SLR;
always @(posedge clk) begin
if (CE)
data_valid_SLR <= data_valid_SLR_in;
else
data_valid_SLR <= data_valid_SLR;
end
generate
if (shift>1) begin: SHIFT_MORE_THAN_ONE
assign data_valid_SLR_in  = {data_in, data_valid_SLR[width*shift-1:width]};
end else begin: SHIFT_EQUAL_TO_ONE
assign data_valid_SLR_in  = data_in;

end
endgenerate
assign data_out = data_valid_SLR[width-1:0];



endmodule
