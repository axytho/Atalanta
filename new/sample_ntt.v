`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jonas Bertels
// 
// Create Date: 04/13/2026 11:18:11 PM
// Design Name: 
// Module Name: sample_ntt
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


module sample_ntt(
    input clk,
    input [`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`MODULUS*`NTT_POLYNOMIAL_SIZE-1:0] data_out
    );
    

localparam INDEX_WIDTH = ($clog2(`SHAKE_128_NUMBER_OF_MODULI)-1);
localparam FIRST_BITONIC_SIZE = (1<<INDEX_WIDTH);
localparam UPPER_PART_WIDTH = `SHAKE_128_NUMBER_OF_MODULI*`MODULUS_WIDTH - FIRST_BITONIC_SIZE *`MODULUS_WIDTH;
wire [FIRST_BITONIC_SIZE*(`MODULUS_WIDTH + INDEX_WIDTH+1)-1:0 ] sample_input;
wire [FIRST_BITONIC_SIZE*(`MODULUS_WIDTH + INDEX_WIDTH+1)-1:0 ] sample_output;
wire [FIRST_BITONIC_SIZE*`MODULUS_WIDTH-1:0 ] sample_output_trimmed;
localparam INDEX_WIDTH_PART_2 = ($clog2(`SHAKE_128_NUMBER_OF_MODULI-FIRST_BITONIC_SIZE)+1-1);
localparam SECOND_BITONIC_SIZE = (1<<INDEX_WIDTH_PART_2);
wire [SECOND_BITONIC_SIZE*(`MODULUS_WIDTH + INDEX_WIDTH_PART_2+1)-1:0 ] sample_2_output;
wire [SECOND_BITONIC_SIZE*`MODULUS_WIDTH-1:0 ] sample_2_output_trimmed;

wire [UPPER_PART_WIDTH-1:0] sample_2_upper_part_input;
wire [SECOND_BITONIC_SIZE*`MODULUS_WIDTH - UPPER_PART_WIDTH-1:0] sample_2_lower_part_input;


constant_delay_buffer #(.shift(`FIRST_BITONIC_LATENCY+1), .width(UPPER_PART_WIDTH)) shift_1(clk, data_in[`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:FIRST_BITONIC_SIZE*`MODULUS_WIDTH], sample_2_part_input);


generate
genvar i;
for (i=0; i<FIRST_BITONIC_SIZE; i=i+1) begin
convert_to_sample_ntt_input #(.INDEX_WIDTH(INDEX_WIDTH), .INDEX(i)) (clk, data_in[i*`MODULUS_WIDTH+:`MODULUS_WIDTH]  ,sample_input[i*(`MODULUS_WIDTH + INDEX_WIDTH+1)+:(`MODULUS_WIDTH + INDEX_WIDTH+1)]);
assign sample_output_trimmed[i*`MODULUS_WIDTH+:`MODULUS_WIDTH]  = sample_output[i*(`MODULUS_WIDTH + INDEX_WIDTH+1)+:(`MODULUS_WIDTH)];
assign sample_2_output_trimmed[i*`MODULUS_WIDTH+:`MODULUS_WIDTH]  = sample_2_output[i*(`MODULUS_WIDTH + INDEX_WIDTH_PART_2+1)+:(`MODULUS_WIDTH)];

end
bitonic_sort #(.DATA_WIDTH(`MODULUS_WIDTH + INDEX_WIDTH+1), .CHAN_NUM(FIRST_BITONIC_SIZE), .DIR(0), .SIGNED(0), .PIPE_REG(1) ) (clk, sample_input, sample_output);

assign sample_2_lower_part_input = sample_output_trimmed[`NTT_POLYNOMIAL_SIZE*`MODULUS_WIDTH-UPPER_PART_WIDTH+SECOND_BITONIC_SIZE*`MODULUS_WIDTH - UPPER_PART_WIDTH-1:`NTT_POLYNOMIAL_SIZE*`MODULUS_WIDTH-UPPER_PART_WIDTH];

bitonic_sort #(.DATA_WIDTH(`MODULUS_WIDTH + INDEX_WIDTH_PART_2+1), .CHAN_NUM(SECOND_BITONIC_SIZE), .DIR(0), .SIGNED(0), .PIPE_REG(1) ) 
(clk, 
{sample_2_upper_part_input, sample_2_lower_part_input}, 
sample_2_output);

constant_delay_buffer #(.shift(`SECOND_BITONIC_LATENCY), .width((`SHAKE_128_NUMBER_OF_MODULI-SECOND_BITONIC_SIZE)*`MODULUS_WIDTH)) 
shift_2(clk, 
sample_output_trimmed[(`SHAKE_128_NUMBER_OF_MODULI-SECOND_BITONIC_SIZE)*`MODULUS_WIDTH-1:0], 
data_out[(`SHAKE_128_NUMBER_OF_MODULI-SECOND_BITONIC_SIZE)*`MODULUS_WIDTH-1:0]);

assign data_out[`MODULUS*`NTT_POLYNOMIAL_SIZE-1:`NTT_POLYNOMIAL_SIZE*`MODULUS_WIDTH-UPPER_PART_WIDTH] = sample_2_output_trimmed[UPPER_PART_WIDTH-1:0];

endgenerate

endmodule
