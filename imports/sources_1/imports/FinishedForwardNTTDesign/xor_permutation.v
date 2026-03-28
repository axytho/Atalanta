`timescale 1ns / 1ps
`include "parameters.v" 
`include "ntt_params.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 11/07/2022 04:24:36 PM
// Design Name: NTT_4096
// Module Name: NTT_4096
// Project Name: ZPRIZE
// Target Devices: Varium C1100
// Tool Versions: Vivado 2020.2
// Description: Number Theoretic Transform for modulus = 2^64-2^32+1 expanded to 96 bits
// 
// Dependencies: 
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module xor_permutation(
input clk,
input [`HBM_ELEMENT_SIZE*`MODULUS_WIDTH-1:0] data_in,
input [`HBM_ELEMENT_DEPTH-1:0] clock_counter,
input data_valid,
output data_valid_out,
output [`HBM_ELEMENT_SIZE*`MODULUS_WIDTH-1:0] data_out
);
reg [`MODULUS_WIDTH-1:0] internal_wiring_reg [0:`HBM_ELEMENT_SIZE*(`HBM_ELEMENT_DEPTH+1)-1];
reg [`HBM_ELEMENT_DEPTH-1:0] shift_shift_reg [0:(`HBM_ELEMENT_DEPTH+1)-1];
  

shift_reg_data_valid #(`HBM_ELEMENT_DEPTH+1) shift_instance (clk, data_valid, data_valid_out);  
  
generate
    genvar j;
    for(j = 0; j < `HBM_ELEMENT_SIZE; j=j+1) begin: OUTPUT
        assign data_out[(j+1)*`MODULUS_WIDTH-1:j*`MODULUS_WIDTH] = internal_wiring_reg[`HBM_ELEMENT_DEPTH*`HBM_ELEMENT_SIZE + j];
    end
endgenerate  



always @(posedge clk) begin: BARREL_SHIFTER
    integer stage;
    integer block_number, twiddle_exponent;
    integer i;

    for(i = 0; i < `HBM_ELEMENT_SIZE; i=i+1) begin: INITIAL
        internal_wiring_reg[i] <= data_in[i*`MODULUS_WIDTH+:`MODULUS_WIDTH];
    end
    
    shift_shift_reg[0] <= clock_counter;
    //if having an extra reg is a problem, change the stage intial to 1,
    // and make it so that the first registers is written with the dat_input
    // which is muxed
    for(stage = 0; stage < `HBM_ELEMENT_DEPTH; stage=stage+1) begin: STAGE_LOOP
        shift_shift_reg[stage+1] <= shift_shift_reg[stage];
        for (block_number = 0; block_number < (1<<stage); block_number=block_number+1) begin: BLOCK_LOOP
            for (twiddle_exponent = 0; twiddle_exponent  < (`HBM_ELEMENT_SIZE>>(stage+1)); twiddle_exponent = twiddle_exponent + 1) begin : INSIDE_BLOCK
                        //assign internal_wiring[(stage+1)*`HBM_ELEMENT_SIZE + ((block_number + (`HBM_ELEMENT_SIZE>>(stage+1)))%`HBM_ELEMENT_SIZE) ] = internal_wiring[stage*`HBM_ELEMENT_SIZE + block_number];
                
                internal_wiring_reg[(stage+1)*`HBM_ELEMENT_SIZE+2*block_number*(`HBM_ELEMENT_SIZE>>(stage+1)) + twiddle_exponent] <= 
                (shift_shift_reg[stage][`HBM_ELEMENT_DEPTH - 1 - stage] == 1'b1) ? 
                internal_wiring_reg[stage*`HBM_ELEMENT_SIZE+2*block_number*(`HBM_ELEMENT_SIZE>>(stage+1)) + twiddle_exponent + (`HBM_ELEMENT_SIZE>>(stage+1))] : 
                internal_wiring_reg[stage*`HBM_ELEMENT_SIZE+2*block_number*(`HBM_ELEMENT_SIZE>>(stage+1)) + twiddle_exponent];
                
                internal_wiring_reg[(stage+1)*`HBM_ELEMENT_SIZE+2*block_number*(`HBM_ELEMENT_SIZE>>(stage+1)) + twiddle_exponent + (`HBM_ELEMENT_SIZE>>(stage+1))] <=
                 (shift_shift_reg[stage][`HBM_ELEMENT_DEPTH - 1 - stage] == 1'b1) ? 
                 internal_wiring_reg[stage*`HBM_ELEMENT_SIZE+2*block_number*(`HBM_ELEMENT_SIZE>>(stage+1)) + twiddle_exponent] :
                internal_wiring_reg[stage*`HBM_ELEMENT_SIZE+2*block_number*(`HBM_ELEMENT_SIZE>>(stage+1)) + twiddle_exponent + (`HBM_ELEMENT_SIZE>>(stage+1))];
            end
        end
    end
end

endmodule
