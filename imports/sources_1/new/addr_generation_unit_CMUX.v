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
`include "ntt_params.v"
module addr_generation_unit_CMUX(
    input clk,
    input reset,
    input [`LOG_N-1+1:0] invert_coef,
    input data_valid_in,
    output data_valid_out,
    output [`COEF_PER_CLOCK_CYCLE-1:0] sign_data, //32 sign bits at a time
    output [`LOG_N-`RING_DEPTH+1-1:0] write_addr,
    output [(`LOG_N-`RING_DEPTH+1)*`COEF_PER_CLOCK_CYCLE-1:0] read_addr
    );

wire [`LOG_N-1+1:0] invert_coef_delayed;   

shift_reg_width  #(.shift(`NTT_DIV_BY_RING+1), .width(`LOG_N+1)) invert_coef_storage_space (
  .clk(clk),  // input wire CLK
  .data_in(invert_coef),      // input wire [9 : 0] D
  .data_out(invert_coef_delayed)      // output wire [9 : 0] Q
);


reg  [`LOG_N-`RING_DEPTH+1-1:0] write_counter; 




assign write_addr = write_counter[`LOG_N-`RING_DEPTH:0];
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


reg   [`LOG_N-`RING_DEPTH+1-1:0] read_counter; // @127, it flips round back to 0
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
    end else if (~|write_counter[`LOG_N-`RING_DEPTH-1:0]) begin // IF NOT DATA_VALID_IN, and we've started reading, set to 0, once we start writing, it becomes active again
        active <= 1'b0;
    end else begin
       active <= active; 
    end
end

always @(posedge clk) begin
    if (reset) begin 
        read_burst_trigger <= 1'b0;
    end else if (active && ~|write_counter[`LOG_N-`RING_DEPTH-1:0])
        read_burst_trigger <= 1'b1;
    else if(read_counter[`LOG_N-`RING_DEPTH-1:0] == `NTT_DIV_BY_RING-1)
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

wire [`LOG_N-1:0] offset [0:`COEF_PER_CLOCK_CYCLE-1];
wire [`LOG_N-`RING_DEPTH-1:0] lower_five_bits [0:`COEF_PER_CLOCK_CYCLE-1];
wire [`LOG_N+1-1:0] sign_sum [0:`COEF_PER_CLOCK_CYCLE-1];
wire [`COEF_PER_CLOCK_CYCLE-1:0] signs;
generate
    genvar i;
    for(i = 0; i < `COEF_PER_CLOCK_CYCLE; i=i+1) begin: INITIAL
        assign offset[i] = i[`RING_DEPTH-1:0] + invert_coef_delayed;
        assign lower_five_bits[i] = offset[i][`LOG_N-1:`RING_DEPTH] + read_counter[`LOG_N-`RING_DEPTH-1:0];
        assign read_addr[(i)*(`LOG_N-`RING_DEPTH+1)+:(`LOG_N-`RING_DEPTH+1)] = {read_counter[`LOG_N-`RING_DEPTH], lower_five_bits[i]};
        assign sign_sum[i] = i + (read_counter[`LOG_N-`RING_DEPTH-1:0] << `RING_DEPTH) + invert_coef_delayed;
        assign signs[i] = ~sign_sum[i][`LOG_N]; //important: not gate here because we select if we are under and don't select if we're not
    end
endgenerate  

reg [`COEF_PER_CLOCK_CYCLE-1:0] signs_reg, signs_reg_reg;
always @(posedge clk) begin
    signs_reg <= signs;
    signs_reg_reg <= signs_reg;
end
assign sign_data = signs_reg_reg;
endmodule

