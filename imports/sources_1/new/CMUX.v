`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: COSIC 
// Engineer: Jonas Bertels
// 
// Create Date: 03/11/2024 10:26:58 PM
// Design Name: FINAL HW Implementation
// Module Name: CMUX
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
module CMUX(
input clk,
input reset,
//data_valid does not actually do much, beyond tell when the first elements are coming in. 
// there is an necessity to feed in the data in blocks of at least of 32.
input [`RING_SIZE*`MODULUS_WIDTH-1:0] data_in,
input data_valid, 
input [`RING_SIZE*`MODULUS_WIDTH-1:0] data_in_coefficients,
input data_coef_valid,//signals that the incomming data is coef data to be stored in BRAM
output data_valid_out,
output [`RING_SIZE*`MODULUS_WIDTH-1:0] data_out
);

//---------------------------------------- COUNTER OF BLOCKS ---------------------------------------------
wire update_coef; //update once every `BATCH_SIZE*NTT_DIV_BY_RING
reg [`CMUX_COUNTER_SIZE-1:0] counter_of_cycles;
reg [`CMUX_COUNTER_SIZE-1:0] counter_of_cycles_reg;
reg [`CMUX_COUNTER_SIZE-1:0] counter_of_cycles_reg_2;
always @(posedge clk) begin
    counter_of_cycles_reg_2 <= counter_of_cycles_reg;
    counter_of_cycles_reg <= counter_of_cycles;
end

always @(posedge clk) begin
    if (reset || (counter_of_cycles == `ITERATIONS*`NTT_DIV_BY_RING*`BATCH_SIZE-1)) begin
        counter_of_cycles <= 0;
    end else if (data_valid) begin
        counter_of_cycles <= counter_of_cycles + 1;
    end else begin
        counter_of_cycles <= counter_of_cycles;
    end
end

reg [`LOG_N-`RING_DEPTH+`BATCH_DEPTH-1:0] counter_of_input_cycles;
always @(posedge clk) begin
    if (reset) begin
        counter_of_input_cycles <= 0;
    end else if (data_coef_valid) begin
        counter_of_input_cycles <= counter_of_input_cycles + 1;
    end else if ((counter_of_input_cycles == `NTT_DIV_BY_RING*`BATCH_SIZE-1) && (data_coef_valid)) begin
        counter_of_input_cycles <= 0;
    end else begin
        counter_of_input_cycles <= counter_of_input_cycles;
    end
end


//---------------------------------------- COEFFICIENT PART --------------------------------------------
// block for loading the coef data in 32x10 bits at a time and reading out 10 bits at a time





wire [(`LOG_N+1)-1:0] coef_addr_block [`RING_SIZE-1:0];
generate
genvar m;
    for (m= 0; m<`RING_SIZE; m=m+1) begin: CRAM_loop
    BRAM_custom  #(.RAM_DEPTH(`NTT_DIV_BY_RING*`BATCH_SIZE), .RAM_WIDTH((`LOG_N+1))) coef_storage_space (
      .clka(clk),  // input wire CLK
      .dina(data_in_coefficients[m*`MODULUS_WIDTH+:(`LOG_N+1)]),      // input wire [9 : 0] D
      .addra(counter_of_input_cycles),
      .addrb({counter_of_cycles[`LOG_N-`RING_DEPTH+`BATCH_DEPTH-1:`LOG_N-`RING_DEPTH], counter_of_cycles[`CMUX_COUNTER_SIZE-1:`LOG_N-`RING_DEPTH+`BATCH_DEPTH+`RING_DEPTH]}),
      //technically speaking the condition for the shift is that 
      // data_valid is true and counter_cycles is at the right cycle,
      // but we guarantee that data_valid is always true (once you get going)
      .wea(data_coef_valid),    // choose which shift register to write to
      .doutb(coef_addr_block[m])      // output wire [9 : 0] Q
    );
    end
endgenerate

 wire [(`LOG_N+1)-1:0] coefficient;

assign coefficient = coef_addr_block[counter_of_cycles_reg_2[`LOG_N-`RING_DEPTH+`BATCH_DEPTH+:`RING_DEPTH]];//32:1 MUX





//--------------------------------CMUX DATAPATH PART------------------------------------------
//data_valid goes in only if we're not loading coefficients

//barrel_shift
wire  [`RING_DEPTH-1:0] shift; 
wire coef_sign;
wire data_memory_valid;
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] data_memory_in;


wire [(`LOG_N+1)-1:0] coef_from_barrel;

reg [`RING_SIZE*`MODULUS_WIDTH-1:0] data_in_reg, data_in_reg_2;
reg data_valid_reg, data_valid_reg_2;
always @(posedge clk) begin
    data_in_reg <= data_in;
    data_in_reg_2 <= data_in_reg;
    data_valid_reg <= data_valid;
    data_valid_reg_2 <= data_valid_reg;
end

shift_reg_width  #(.shift(`STAGE_SIZE+1), .width((`LOG_N+1))) coef_for_barrel (
  .clk(clk),  // input wire CLK
  .data_in(coefficient),      // input wire [9 : 0] D
  .data_out(coef_from_barrel)      // output wire [9 : 0] Q
);


shift_reg_width  #(.shift(`NTT_DIV_BY_RING+3), .width(1)) coef_storage_space (
  .clk(clk),  // input wire CLK
  .data_in(coef_from_barrel[`LOG_N]),      // input wire [9 : 0] D
  .data_out(coef_sign)      // output wire [9 : 0] Q
);

wire [`LOG_N-1+1:0] invert_coef = `NTT_VECTOR_SIZE - coef_from_barrel[`LOG_N-1:0];
assign shift = coefficient[`RING_DEPTH-1:0];
barrel_shifter barrel_instance(clk,data_in_reg_2, shift, data_valid_reg_2, data_memory_valid, data_memory_in);
//barrel has a latency of 6 cycles

//Control logic
wire data_barrel_valid;
wire [`LOG_N-`RING_DEPTH+1-1:0] write_addr;
wire [(`LOG_N-`RING_DEPTH+1)*`RING_SIZE-1:0] read_addr;
wire [`RING_SIZE-1:0] sign_data;
addr_generation_unit_CMUX control(.clk(clk), .reset(reset),
.invert_coef(invert_coef),
.data_valid_in(data_memory_valid),// THIS HAS A LATENCY OF 35 cycles
.data_valid_out(data_barrel_valid),
.sign_data(sign_data), 
.write_addr(write_addr),
.read_addr(read_addr));



// BRAM
wire [`GOLD_MODULUS_WIDTH-1:0] data_out_bram [0:(`RING_SIZE)-1];
generate
    genvar i;
    for(i = 0; i < `RING_SIZE; i=i+1) begin: BUTTERFLIES
BRAM_custom #(
            .RAM_WIDTH(`GOLD_MODULUS_WIDTH),
            .RAM_DEPTH(2*(`NTT_DIV_BY_RING)),
            .RAM_PERFORMANCE("RAM_PERFORMANCE")
        ) BRAM_instance (
            .clka(clk),
            .addra(write_addr),
            .addrb(read_addr[i*(`LOG_N-`RING_DEPTH+1)+:(`LOG_N-`RING_DEPTH+1)]),
            .dina(data_memory_in[(i+1)*`GOLD_MODULUS_WIDTH-1:i*`GOLD_MODULUS_WIDTH]),
            .wea(data_memory_valid),// The idea being
             //that each bram is loaded one at a time
            .doutb(data_out_bram[i])
        ); 
    end
endgenerate

wire [`RING_SIZE*`MODULUS_WIDTH-1:0] data_buffer_out;
generate
genvar n;
for (n= 0; n<`RING_SIZE; n=n+1) begin: NON_MODIFIED_MEM
shift_reg_width  #(.shift((`RING_DEPTH+1)+`NTT_DIV_BY_RING+3), .width(`MODULUS_WIDTH)) coef_storage_space (
  .clk(clk),  // input wire CLK
  .data_in(data_in_reg_2[n*`MODULUS_WIDTH+:`MODULUS_WIDTH]),      // input wire [9 : 0] D
  .data_out(data_buffer_out[n*`MODULUS_WIDTH+:`MODULUS_WIDTH])      // output wire [9 : 0] Q
);
end
endgenerate


generate
    genvar l;
    for(l = 0; l < `RING_SIZE; l=l+1) begin: ADD_SUBTACT
        add_subtract  sum_difference (
      .clk(clk),  // input wire CLK
      .input_a(data_out_bram[l]),
      .input_b(data_buffer_out[l*`MODULUS_WIDTH+:`MODULUS_WIDTH]),
      .sign(sign_data[l] ^ coef_sign), //if coef_sign = 1, invert the normal proceedings
      .data_out(data_out[l*`MODULUS_WIDTH+:`MODULUS_WIDTH])      // output wire [9 : 0] Q
    );
    end
endgenerate 
shift_reg_data_valid #(2) add_subtract_instance_valid (clk, data_barrel_valid, data_valid_out);    

//// DOCUMENTATION OF CMUX

//This CMUX first selects the coefficient it's going to need from the batch. 
//It does this by initially loading all the coefficients, and then simply grabbing the right one


// Then it needs to do have, one the one hand, a buffered version of the input data (data_buffer_out)
// and on the other hand a rotated version of the vector.
// It does this by barrel rotating the data, and loading it naively into BRAM,
// then it picks the right addresses from read by sometimes reading one ahead and sometimes reading normal
// depending on whether the current read address if greater than the coef or not
// for the given input 

endmodule
