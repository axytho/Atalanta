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


module Burst_into_stream #(parameter INPUT_WIDTH = 1024, parameter OUTPUT_WIDTH =256, parameter BURST_SIZE= 6, parameter OUTPUT_BURST = 24, parameter CYCLES_PER_OUTPUT_LOG = 2) (
    input clk,
    input rst,
    input [INPUT_WIDTH-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [OUTPUT_WIDTH-1:0] data_out
    );

//assert OUTPUT_BURST == NO_OF_OUTPUT_BURSTS << 

// DATA_VALID delay


// assert output_burst = (BURST_SIZE*INPUT_WIDTH/OUTPUT_WIDTH);
reg [$clog2(OUTPUT_BURST)-1:0] output_counter = 0;
reg [$clog2(BURST_SIZE)-1:0] input_counter;
always @(posedge clk) begin
    if (rst) begin
        input_counter <= 0;
    end else if (data_valid) begin
        if (input_counter == BURST_SIZE-1)
            input_counter <= 0; 
        else
            input_counter <= input_counter + 1;    
    end else begin
        input_counter <= input_counter;
    end
end
reg data_valid_out_reg = 0; //to ensure doesn't mess with simulation
reg valid_rising_edge_reg = 0;
reg data_valid_reg = 0;
wire data_valid_out_until_counter;
reg [INPUT_WIDTH-1:0] data_valid_SLR [0:BURST_SIZE-1];
reg [OUTPUT_WIDTH-1:0] data_out_reg;
always @(posedge clk) begin
    data_valid_out_reg <= data_valid_out_until_counter;
    data_out_reg <= data_valid_SLR[(output_counter>>(CYCLES_PER_OUTPUT_LOG))][OUTPUT_WIDTH-1:0];
    valid_rising_edge_reg <= (~data_valid_reg & data_valid);
end
assign data_valid_out_until_counter = ~(output_counter == 0) || valid_rising_edge_reg;
assign data_valid_out = data_valid_out_reg;
assign data_out = data_out_reg;
always @(posedge clk) begin
    data_valid_reg <= data_valid;
    if (rst) begin
        output_counter <= 0;
    end else if (data_valid_out_until_counter) begin
        if (output_counter == OUTPUT_BURST-1)
            output_counter <= 0; 
        else
            output_counter <= output_counter + 1;    
    end else begin
        output_counter <= output_counter;
    end
end


//parameter shift = `BUTTER_FLY_REGISTERS*`STAGE_SIZE;

generate
genvar i;
for (i=0; i<BURST_SIZE; i=i+1) begin
    always @(posedge clk) begin
        if (input_counter==i && data_valid)
            data_valid_SLR[i] <= data_in;
        else if ((output_counter>>(CYCLES_PER_OUTPUT_LOG))==i && data_valid_out_until_counter)
            data_valid_SLR[i] <= data_valid_SLR[i]>>OUTPUT_WIDTH;
        else
            data_valid_SLR[i] <= data_valid_SLR[i];
        end
    end
endgenerate



endmodule
