`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/28/2022 03:30:02 PM
// Design Name: 
// Module Name: addr_generation_unit
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
module addr_generation_unit #(parameter STREAM_SIZE = `RING_SIZE) (
    input clk,
    input reset,
    input data_valid_in,
    output data_valid_out,
    output [($clog2(STREAM_SIZE))+1-1:0] write_addr,
    output [(($clog2(STREAM_SIZE))+1)*STREAM_SIZE-1:0] read_addr
    );
 
localparam STREAM_DEPTH = ($clog2(STREAM_SIZE));




reg  [STREAM_DEPTH+1-1:0] write_counter; 




assign write_addr = write_counter[STREAM_DEPTH:0];
 //WRITE_STATE
always @(posedge clk) begin
    if (reset) begin
        write_counter <= 0;
    end else if (data_valid_in==1'b1) begin
        write_counter <= write_counter + 1;
    end else begin 
        write_counter <= write_counter;
    end
    
end


reg   [STREAM_DEPTH+1-1:0] read_counter; // @127, it flips round back to 0
reg read_burst_trigger = 0;
reg read_burst_trigger_reg = 0;
reg read_burst_trigger_reg_reg = 0;
assign data_valid_out = read_burst_trigger_reg_reg;

always @(posedge clk) begin
    read_burst_trigger_reg <= read_burst_trigger;
    read_burst_trigger_reg_reg <= read_burst_trigger_reg;
end


reg active; // a reg for ensuring that when the write_counter starts up for the first time we don't have a "ready" signal
// because the write_counter = 0
always @(posedge clk) begin
    if (reset) begin
        active <= 1'b0;
    end else if (data_valid_in) begin
        active <= 1'b1;
    end else if (~|write_counter[STREAM_DEPTH-1:0]) begin // IF NOT DATA_VALID_IN, and we've started reading, set to 0, once we start writing, it becomes active again
        active <= 1'b0;
    end else begin
       active <= active; 
    end
end

always @(posedge clk) begin
    if (reset) begin 
        read_burst_trigger <= 1'b0;
    end else if (active && ~|write_counter[STREAM_DEPTH-1:0])
        read_burst_trigger <= 1'b1;
    else if(read_counter[STREAM_DEPTH-1:0] == STREAM_SIZE-1)
        read_burst_trigger <= 1'b0;
    else
        read_burst_trigger <= read_burst_trigger;
end

always @(posedge clk) begin
    if (reset) begin
        read_counter <= 0;
    end else if (read_burst_trigger) begin
        read_counter <= read_counter + 1;
    end else begin 
        read_counter <= read_counter;
    end
    
end

generate
    genvar i;
    for(i = 0; i < STREAM_SIZE; i=i+1) begin: INITIAL
        assign read_addr[(i)*(STREAM_DEPTH+1)+:(STREAM_DEPTH+1)] = {read_counter[STREAM_DEPTH], i[STREAM_DEPTH-1:0] - read_counter[STREAM_DEPTH-1:0]};
    end
endgenerate  

 
endmodule
