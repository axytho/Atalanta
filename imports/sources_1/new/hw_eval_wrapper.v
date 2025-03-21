`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 05:18:43 PM
// Design Name: 
// Module Name: hw_eval_wrapper
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


module hw_eval_wrapper(
    input clk,
    input [`MODULUS_WIDTH-1:0] random_input,
    output [`MODULUS_WIDTH-1:0] random_output,
    output data_valid_out_quick
    );
    
//reg [`MODULUS_WIDTH-1:0] counter = 0;
//always @(posedge clk)
//counter <= counter+1;
//end
wire [`MODULUS_WIDTH-1:0] output_raw;
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] random_output_raw;

reg [`RING_SIZE*`MODULUS_WIDTH-1:0] randomness;
always @(posedge clk) begin
    randomness <= {random_input, randomness[`RING_SIZE*`MODULUS_WIDTH-1:`MODULUS_WIDTH]};
end
assign random_output = output_raw;
INTT_1024 NTT_hw_eval(
    .clk(clk),
    .data_in(randomness),
    .data_valid(randomness[0]),
    .data_valid_out(data_valid_out_quick),
    .data_out(random_output_raw)
    );
generate
genvar i;
for (i=0;i<16;i=i+1) begin
assign random_output[i] = ^random_output_raw[4*`MODULUS_WIDTH*i+:4*`MODULUS_WIDTH];
end
endgenerate
//pearl_of_the_butterfly #(.TWIDDLE(258853)) inst (.clk(clk), .input_a(random_input), .output_product(output_raw));
//assign random_output = output_raw[4:0] + output_raw[9:5] + output_raw[14:10] + output_raw[19:5];

endmodule