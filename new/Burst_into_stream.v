`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 12:56:26 PM
// Design Name: 
// Module Name: Burst_into_stream
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


module Burst_into_stream #(parameter INPUT_WIDTH = 1, parameter OUTPUT_WIDTH =1, parameter BURST_SIZE= 1, parameter OUTPUT_BURST = 1) (
    input clk,
    input [INPUT_WIDTH-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [OUTPUT_WIDTH-1:0] data_out
    );

// DATA_VALID delay

// assert output_burst = (BURST_SIZE*INPUT_WIDTH/OUTPUT_WIDTH);
reg [$clog(OUTPUT_BURST)-1:0] output_counter;
reg data_valid_reg;
reg data_valid_out_until_counter;
assign data_valid_out = data_valid_out_until_counter;



//parameter shift = `BUTTER_FLY_REGISTERS*`STAGE_SIZE;
wire [INPUT_WIDTH-1:0] data_valid_SLR_in;
reg [INPUT_WIDTH-1:0] data_valid_SLR [0:BURST_SIZE-1];
generate
genvar i;
for (i=0; i<BURST_SIZE; i=i+1) begin


end
always @(posedge clk) begin
data_valid_SLR <= data_valid_SLR_in;
end

if (shift>1) begin: SHIFT_MORE_THAN_ONE
assign data_valid_SLR_in  =  ? data_in : {, data_valid_SLR[width*shift-1:width]};
end else begin: SHIFT_EQUAL_TO_ONE
assign data_valid_SLR_in  = data_in;

end
endgenerate
assign data_out = data_valid_SLR[width-1:0];



endmodule

endmodule
