`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU LEUVEN COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 09/18/2023 10:10:41 PM
// Design Name: FINAL hardware wrapper
// Module Name: FINAL
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Fundamentally, this module interfaces between the external AXI stream
// and the internal data/data valid datapath.
// It continously collects 32 ciphertexts, then waits until those 32 ciphertexts have left
// the internal FIFO (this will not have much overhead as the module is surrounded by 
// FIFO's)
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
module FINAL(
    input clk,
    input rst,
    input [4095:0] data_in, //3 types of input: first AXI stream, then b and then coefficients (x31 for first coefficients and then b)
    input data_valid_in,
    output data_ready_in,
    output [4095:0] data_out,
    output data_valid_out,
    input data_ready_out// WE IGNORE THE READY. TO MAKE THIS MODULE AXI COMPLIANT, ADD `BATCH_SIZE*`NTT_DIV_BY_RING FIFO at the end
    );
    
reg buffered_reset, rst_reg;
always @(posedge clk) begin
    rst_reg <= rst;
    buffered_reset <= rst_reg;
end
reg [`BSK_COUNTER_SIZE-1+1:0] counter_bsk;
reg [`BATCH_DEPTH+`LOG_N-`RING_DEPTH-1+1:0] counter_coef_and_b_in;
reg [`COUNTER_SIZE-1:0] counter_until_output;
wire state_reading_bsk = ~(counter_bsk == `NTT_DIV_BY_RING*`ITERATIONS*`L);
wire state_reading_coef = ~(counter_coef_and_b_in == `NTT_DIV_BY_RING*`BATCH_SIZE) && ~state_reading_bsk;
wire state_waiting_till_reading_out_acc = ~(counter_until_output == `NTT_DIV_BY_RING*`BATCH_SIZE*(`ITERATIONS-1));



reg data_ready_in_reg;
assign data_ready_in = data_ready_in_reg; 
always @(posedge clk) begin
    if (buffered_reset) begin
        data_ready_in_reg <= 1;
    end else if ((counter_coef_and_b_in == `NTT_DIV_BY_RING*`BATCH_SIZE-1) && data_valid_in) begin
        data_ready_in_reg <= 0;
    end else begin
        data_ready_in_reg <= data_ready_in_reg;
    end
    
end

reg [`MODULUS_WIDTH*`RING_SIZE-1:0] data_in_reg;
wire [`MODULUS_WIDTH*`RING_SIZE-1:0] data_in_aligned;
generate
    genvar a;
    for (a=0; a<`RING_SIZE; a=a+1) begin: DATA_REROUTE
        assign data_in_aligned[a*`MODULUS_WIDTH+:`MODULUS_WIDTH] = data_in[a*`HBM_WIDTH+:`MODULUS_WIDTH];
    end
endgenerate
always @(posedge clk) begin
    data_in_reg <= data_in_aligned;
end

always @(posedge clk) begin
    if (buffered_reset) begin
        counter_bsk <= 0;
    end else if (state_reading_bsk && data_valid_in && data_ready_in) begin
        counter_bsk <= counter_bsk+1;
    end else begin
        counter_bsk <= counter_bsk;
    end
end

always @(posedge clk) begin
    if (buffered_reset) begin
        counter_coef_and_b_in <= 0;
    end else if (state_reading_coef && data_valid_in && data_ready_in) begin
        counter_coef_and_b_in <= counter_coef_and_b_in+1;
    end else begin
        counter_coef_and_b_in <= counter_coef_and_b_in;
    end
end



wire [`RING_SIZE*`MODULUS_WIDTH-1:0] CMUX_in, gen_acc_out;
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] CMUX_out;
wire CMUX_valid, CMUX_valid_out;


//-----------------------AXI CONTROL SECTION

reg gen_acc_valid, coef_valid, BSK_valid;
always @(posedge clk) begin
    gen_acc_valid <= &counter_coef_and_b_in[`LOG_N-`RING_DEPTH-1:0] && data_valid_in && data_ready_in;
    coef_valid <= state_reading_coef && data_valid_in && data_ready_in;
    BSK_valid <= state_reading_bsk && data_valid_in && data_ready_in;
end

wire data_valid_out_gen_acc;
// ---------------------- ACC GEN section (the primer)
gen_acc gen_acc_instance(.clk(clk), .rst(buffered_reset),
.data_in(data_in_reg[(`MODULUS_WIDTH)*(`RING_SIZE-1)+:`LOG_N+1]),
.data_valid_in(gen_acc_valid),
.data_valid_out(data_valid_out_gen_acc),
.data_out(gen_acc_out)
);

//----------------------- DATA BLOCKS
wire CMUX_datapath_valid_out;
assign CMUX_valid = (data_valid_out_gen_acc || CMUX_datapath_valid_out) && state_waiting_till_reading_out_acc;
CMUX cmux_instance(.clk(clk), .reset(buffered_reset), 
.data_in(CMUX_in), 
.data_valid(CMUX_valid), 
.data_in_coefficients(data_in_reg[`RING_SIZE*`MODULUS_WIDTH-1:0]),// we load the coefficients in 32x blocks, but the zeroes are padding, and part of the padding also includes the b.
// this last part makes sense for FINAL, where we are not using 1024 coefficients, but less than this, and so we have the space (simplifying the control logic)
.data_coef_valid(coef_valid), 
.data_valid_out(CMUX_valid_out), 
.data_out(CMUX_out));

wire [`RING_SIZE*`MODULUS_WIDTH-1:0] external_product_out;

external_product_final extern_product_instance(.clk(clk), .rst(buffered_reset),
.data_in(CMUX_out),
.data_valid(CMUX_valid_out),
.BSK(data_in_reg[`MODULUS_WIDTH*`RING_SIZE-1:0]),
.BSK_valid(BSK_valid),
.data_out(external_product_out),
.data_valid_out(data_external_product_valid_out)
);


wire [`RING_SIZE*`MODULUS_WIDTH-1:0] accumulator_buffer_out, accumulator_from_datapath_cmux_in;

wire [`MODULUS_WIDTH+1-1:0] sum [0:`RING_SIZE-1];
wire [`MODULUS_WIDTH+1-1:0] sum_minus_modulus [0:`RING_SIZE-1];
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] accumulator_for_next_iteration;
reg [`RING_SIZE*`MODULUS_WIDTH-1:0] accumulator_for_next_iteration_reg;
generate
genvar n;
for (n= 0; n<`RING_SIZE; n=n+1) begin: ACCUMULATOR
shift_reg_width  #(.shift(`CMUX_LATENCY + `EXTERNAL_PRODUCT_LATENCY), .width(`MODULUS_WIDTH)) accumulator_buffer (
  .clk(clk),  // input wire CLK
  .data_in(CMUX_in[n*`MODULUS_WIDTH+:`MODULUS_WIDTH]),      // input wire [9 : 0] D
  .data_out(accumulator_buffer_out[n*`MODULUS_WIDTH+:`MODULUS_WIDTH])      // output wire [9 : 0] Q
);
assign sum_minus_modulus[n] = (sum[n] - `MODULUS);
assign sum[n] = external_product_out[n*`MODULUS_WIDTH+:`MODULUS_WIDTH] + accumulator_buffer_out[n*`MODULUS_WIDTH+:`MODULUS_WIDTH];
assign accumulator_for_next_iteration[n*`MODULUS_WIDTH+:`MODULUS_WIDTH] = sum_minus_modulus[n][`MODULUS_WIDTH] ? sum[n]  : sum_minus_modulus[n];
shift_reg_width  #(.shift(`BATCH_SIZE*`NTT_DIV_BY_RING - (`CMUX_LATENCY + `EXTERNAL_PRODUCT_LATENCY) - 1), .width(`MODULUS_WIDTH)) output_and_cmux_input_buffer (
  .clk(clk),  // input wire CLK
  .data_in(accumulator_for_next_iteration_reg[n*`MODULUS_WIDTH+:`MODULUS_WIDTH]),      // input wire [9 : 0] D
  .data_out(accumulator_from_datapath_cmux_in[n*`MODULUS_WIDTH+:`MODULUS_WIDTH])      // output wire [9 : 0] Q
);
end
endgenerate


shift_reg_width  #(.shift(`BATCH_SIZE*`NTT_DIV_BY_RING - (`CMUX_LATENCY + `EXTERNAL_PRODUCT_LATENCY)), .width(1)) output_and_cmux_input_buffer (
  .clk(clk),  // input wire CLK
  .data_in(data_external_product_valid_out),      // input wire [9 : 0] D
  .data_out(CMUX_datapath_valid_out)      // output wire [9 : 0] Q
);


always @(posedge clk) begin
    accumulator_for_next_iteration_reg <= accumulator_for_next_iteration;
end

assign CMUX_in = data_valid_out_gen_acc ? gen_acc_out : accumulator_from_datapath_cmux_in;


wire [`HBM_WIDTH*`RING_SIZE-1:0] data_out_small;

generate
    genvar b;
    for (b=0; b<`RING_SIZE; b=b+1) begin: DATA_REROUTE_OUT
        assign data_out_small[b*`HBM_WIDTH+:`MODULUS_WIDTH] = accumulator_from_datapath_cmux_in[b*`MODULUS_WIDTH+:`MODULUS_WIDTH];
        assign data_out_small[b*`HBM_WIDTH+`MODULUS_WIDTH+:(`HBM_WIDTH-`MODULUS_WIDTH)] = 0;
    end
endgenerate

always @(posedge clk) begin
    if (buffered_reset) begin
        counter_until_output <= 0;
    end else if (state_waiting_till_reading_out_acc && CMUX_datapath_valid_out) begin
        counter_until_output <= counter_until_output+1;
    end else begin
        counter_until_output <= counter_until_output;
    end
end
reg data_out_valid_reg, data_out_valid_reg_2;


reg [4095:0] data_out_reg, data_out_reg_2;
always @(posedge clk) begin
    data_out_reg <= { {4096-`RING_SIZE*`HBM_WIDTH{1'b0}} , data_out_small};
    data_out_reg_2 <= data_out_reg;
    data_out_valid_reg <=~state_waiting_till_reading_out_acc && CMUX_datapath_valid_out;
    data_out_valid_reg_2 <= data_out_valid_reg;
end
assign data_out = data_out_reg_2;
assign data_valid_out = data_out_valid_reg_2;
endmodule







