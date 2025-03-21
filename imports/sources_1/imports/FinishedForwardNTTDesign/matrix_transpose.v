`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2022 01:06:46 PM
// Design Name: 
// Module Name: matrix_transpose
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
module matrix_transpose #(parameter STREAM_WIDTH = 32, parameter DATA_ELEMENT_WIDTH = `GOLD_MODULUS_WIDTH) (
input clk,
input reset,
input [STREAM_WIDTH*DATA_ELEMENT_WIDTH-1:0] data_in,
input data_valid,
output data_valid_out,
output [STREAM_WIDTH*DATA_ELEMENT_WIDTH-1:0] data_out
);

localparam STREAM_DEPTH = ($clog2(STREAM_WIDTH));
//barrel_shift
reg  [STREAM_DEPTH-1:0] shift; 
wire data_memory_valid;
wire [STREAM_WIDTH*DATA_ELEMENT_WIDTH-1:0] data_memory_in;
always @(posedge clk) begin
    if (reset) begin
        shift <= 0;
    end else if ((data_valid==1'b1)) begin
        shift <= shift + 1; //during input, shift in the direction that you're going to be addressing
    end else begin 
        shift <= shift;
    end
    
end

barrel_shifter #(.STREAM_SIZE(STREAM_WIDTH), .DATA_ELEMENT_WIDTH(DATA_ELEMENT_WIDTH)) barrel_instance(clk,data_in, shift, data_valid, data_memory_valid, data_memory_in);


//Control logic
wire data_barrel_valid;
wire [STREAM_DEPTH+1-1:0] write_addr;
wire [(STREAM_DEPTH+1)*STREAM_WIDTH-1:0] read_addr;
addr_generation_unit #(.STREAM_SIZE(STREAM_WIDTH)) control(.clk(clk), .reset(reset),
.data_valid_in(data_memory_valid),
.data_valid_out(data_barrel_valid), 
.write_addr(write_addr),
.read_addr(read_addr));



// BRAM
wire [DATA_ELEMENT_WIDTH-1:0] data_out_bram [0:(STREAM_WIDTH)-1];
generate
    genvar i;
    for(i = 0; i < STREAM_WIDTH; i=i+1) begin: BUTTERFLIES
BRAM_custom #(
            .RAM_WIDTH(DATA_ELEMENT_WIDTH),
            .RAM_DEPTH(STREAM_WIDTH<<1),
            .RAM_PERFORMANCE("RAM_PERFORMANCE")
        ) BRAM_instance (
            .clka(clk),
            .addra(write_addr),
            .addrb(read_addr[i*(STREAM_DEPTH+1)+:(STREAM_DEPTH+1)]),
            .dina(data_memory_in[(i+1)*DATA_ELEMENT_WIDTH-1:i*DATA_ELEMENT_WIDTH]),
            .wea(1'b1),// The idea being
             //that each bram is loaded one at a time
            .doutb(data_out_bram[i])
        ); 
    end
endgenerate


//barrel_shift
reg  [STREAM_DEPTH-1:0] shift_2; 
always @(posedge clk) begin
    if (reset) begin
        shift_2 <= 0;
    end else if ((data_barrel_valid==1'b1)) begin
        shift_2 <= shift_2 - 1; //during input, shift in the direction that you're going to be addressing
    end else begin 
        shift_2 <= shift_2;
    end
    
end

wire [STREAM_WIDTH*(DATA_ELEMENT_WIDTH)-1:0] barrel_in_wire; 
generate
    genvar l;
    for(l = 0; l < STREAM_WIDTH; l=l+1) begin: BARREL
        assign barrel_in_wire[l*DATA_ELEMENT_WIDTH+:DATA_ELEMENT_WIDTH] = data_out_bram[l] ;
    end
endgenerate 


barrel_shifter #(.STREAM_SIZE(STREAM_WIDTH), .DATA_ELEMENT_WIDTH(DATA_ELEMENT_WIDTH)) barrel_instance_2(clk,barrel_in_wire, shift_2, data_barrel_valid, data_valid_out, data_out);


endmodule
