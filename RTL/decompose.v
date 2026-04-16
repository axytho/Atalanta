`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 02/19/2024 10:35:06 PM
// Design Name: 
// Module Name: decompose
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

module decompose(
    input clk,
    input [`MODULUS_WIDTH-1:0] data_in, //breaks for 0x60000
    output [`L*`MODULUS_WIDTH-1:0] data_out
    );
    
wire [`MODULUS_WIDTH-1+1:0] data_negative;
assign data_negative = data_in - `MODULUS;
wire select_positive_or_negative;
wire [`MODULUS_WIDTH:0] tSelectValue;
assign tSelectValue = {1'b0, data_in} - {1'b0, `MODULUSHALFPLUSONE};
assign select_positive_or_negative = tSelectValue[`MODULUS_WIDTH];

wire [`MODULUS_WIDTH+1-1:0] data_with_q_overflow_LSBs;// = {`B_BSK_WIDTH*(`L+1){1'b0}};
assign data_with_q_overflow_LSBs = (select_positive_or_negative) ? data_in: data_negative;

wire [(`MODULUS_WIDTH+1)*(`L)-1:0] data_with_q_overflow; //= {`B_BSK_WIDTH*(`L+1){1'b0}};
reg [`L*(`MODULUS_WIDTH+1)-1:0] data_with_q_overflow_reg;
always @(posedge clk) begin
    data_with_q_overflow_reg <= {data_with_q_overflow[(`L-1)*(`MODULUS_WIDTH+1)-1:0], data_with_q_overflow_LSBs};
end

reg [`L-1:0] select_positive_or_negative_reg;
always @(posedge clk) begin
  select_positive_or_negative_reg  <= {select_positive_or_negative_reg[`L-2:0], select_positive_or_negative};
end

wire [`L-1:0] select_wire;
//assign take_b_elements[0*`B_BSK_WIDTH+:`B_BSK_WIDTH] = data_with_q_overflow[0*`B_BSK_WIDTH+:`B_BSK_WIDTH];
wire [(`B_BSK_WIDTH+1)*`L-1:0] do_minus_B_div_two;
wire [`MODULUS_WIDTH*`L-1:0] decompose_result, take_the_overflown_value;


//reg [`B_BSK_WIDTH*(`L+1)-1:0] take_b_elements_reg;
//always @(posedge clk) begin
//    take_b_elements_reg <= take_b_elements;
//end
generate
    genvar i;
    for (i=0; i<`L; i=i+1) begin
    // NOTE: CHECK A DIAGRAM TO UNDERSTAND THESE WIRES
    // data_with_q_overflow_reg is actually a group of L different registers, each containing `MODULUS_WIDTH + 1 bits
    // each reg stores the result after an addition
        assign do_minus_B_div_two[i*(`B_BSK_WIDTH+1)+:(`B_BSK_WIDTH+1)] = (data_with_q_overflow_reg[(i)*(`MODULUS_WIDTH+1)+:`B_BSK_WIDTH] -  (select_positive_or_negative_reg[i]+(1<<(`B_BSK_WIDTH-1)))); 
        assign select_wire[i] = do_minus_B_div_two[(i+1)*(`B_BSK_WIDTH+1)-1];
        //assign select_wire[i] = data_with_q_overflow_reg[(i)*(`MODULUS_WIDTH+1)+`B_BSK_WIDTH-1];
        assign take_the_overflown_value[i*`MODULUS_WIDTH+:`MODULUS_WIDTH] = data_with_q_overflow_reg[(i)*(`MODULUS_WIDTH+1)+:`B_BSK_WIDTH] + (`MODULUS - (1<<`B_BSK_WIDTH));
        assign decompose_result[i*`MODULUS_WIDTH+:`MODULUS_WIDTH] = select_wire[i] ? data_with_q_overflow_reg[(i)*(`MODULUS_WIDTH+1)+:`B_BSK_WIDTH] : take_the_overflown_value[i*`MODULUS_WIDTH+:`MODULUS_WIDTH];
        //assign zeros to the upper bits of take_b_elements
        //of the data_with_q_overflow, we take index spatially the i-th modulus, and from this we take the upper bits (we take less upper bits as time progresses) to use in the following stage
        // note that data_with_overflow itself does not change
        assign data_with_q_overflow[(i+1)*(`MODULUS_WIDTH+1)-1:(i)*(`MODULUS_WIDTH+1)] = data_with_q_overflow_reg[(i+1)*(`MODULUS_WIDTH+1)-1:(i)*(`MODULUS_WIDTH+1)+`B_BSK_WIDTH] + {{`MODULUS_WIDTH{1'b0}},~select_wire[i]};
        shift_reg_width #(.shift(`L-i), .width(`MODULUS_WIDTH)) synchronizer (
        .clk(clk),
        .data_in(decompose_result[i*`MODULUS_WIDTH+:`MODULUS_WIDTH]),
        .data_out(data_out[i*`MODULUS_WIDTH+:`MODULUS_WIDTH]));
    end
endgenerate
//assign firstSeven = d[6:0];
//wire [6:0] firstSelectValue;
//wire firstSelect;
//assign firstSelectValue = firstSeven - 7'd64;
//assign firstSelect = firstSelectValue[6];
//wire [`DATA_SIZE_ARB-1:0] rFirstMinusBasePlusModulus;
//assign rFirstMinusBasePlusModulus = firstSeven + (`MODULUS - 8'd128);
//assign firstResult = firstSelect ? firstSeven : rFirstMinusBasePlusModulus; // ARB ? 1:0
//wire [`DATA_SIZE_ARB-7:0] rNext3 = d[`DATA_SIZE_ARB:7] + {1'b0, ~firstSelect};

endmodule
