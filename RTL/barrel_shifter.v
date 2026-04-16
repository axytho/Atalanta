`timescale 1ns / 1ps
`include "parameters.v" 
`include "ntt_params.v"

module barrel_shifter #(parameter STREAM_SIZE = `COEF_PER_CLOCK_CYCLE_BAILEY_NTT, parameter DATA_ELEMENT_WIDTH = `MODULUS_WIDTH) (
input clk,
input [STREAM_SIZE*DATA_ELEMENT_WIDTH-1:0] data_in,
input [($clog2(STREAM_SIZE))-1:0] shift,
input data_valid,
output data_valid_out,
output [STREAM_SIZE*DATA_ELEMENT_WIDTH-1:0] data_out
);

localparam STREAM_DEPTH = ($clog2(STREAM_SIZE));
reg [DATA_ELEMENT_WIDTH-1:0] internal_wiring_reg [0:STREAM_SIZE*(STREAM_DEPTH+1)-1];
reg [STREAM_DEPTH-1:0] shift_shift_reg [0:(STREAM_DEPTH+1)-1];
  

shift_reg_data_valid #(STREAM_DEPTH+1) shift_instance (clk, data_valid, data_valid_out);  
  
generate
    genvar j;
    for(j = 0; j < STREAM_SIZE; j=j+1) begin: OUTPUT
        assign data_out[(j+1)*DATA_ELEMENT_WIDTH-1:j*DATA_ELEMENT_WIDTH] = internal_wiring_reg[STREAM_DEPTH*STREAM_SIZE + j];
    end
endgenerate  



always @(posedge clk) begin: BARREL_SHIFTER
    integer stage;
    integer block_number;
    integer i;

    for(i = 0; i < STREAM_SIZE; i=i+1) begin: INITIAL
        internal_wiring_reg[i] <= data_in[i*DATA_ELEMENT_WIDTH+:DATA_ELEMENT_WIDTH];
    end
    
    shift_shift_reg[0] <= shift;
    //if having an extra reg is a problem, change the stage intial to 1,
    // and make it so that the first registers is written with the dat_input
    // which is muxed
    for(stage = 0; stage < STREAM_DEPTH; stage=stage+1) begin: STAGE_LOOP
        shift_shift_reg[stage+1] <= shift_shift_reg[stage];
        for (block_number = 0; block_number < (STREAM_SIZE); block_number=block_number+1) begin: BLOCK_LOOP
            
            internal_wiring_reg[(stage+1)*STREAM_SIZE + block_number] <= (shift_shift_reg[stage][STREAM_DEPTH - 1 - stage] == 1'b1) ? 
            internal_wiring_reg[stage*STREAM_SIZE + ((block_number + STREAM_SIZE - (STREAM_SIZE>>(stage+1)))%STREAM_SIZE)] : 
            internal_wiring_reg[stage*STREAM_SIZE + block_number];

        end
    end
end




endmodule
