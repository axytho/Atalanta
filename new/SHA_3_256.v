`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU LEUVEN COSIC
// Engineer: Jonas Bertels
// 
// SHA_3_256
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v" 
`include "ntt_params.v"
module SHA_3_256(
    input clk,
    input rst,
    input [`INPUT_WIDTH_CLUSTER_PK-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`SHA_256_OUTPUT-1:0] data_out
    );
    
  
    
 wire [((`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1)*`SHA_256_DATA_RATE-1:0] padded_input;
assign padded_input = {1'b1,{(`SHA_256_DATA_RATE-4 -(`INPUT_WIDTH_CLUSTER_PK%`SHA_256_DATA_RATE) ){1'b0}},3'b110,data_in};


wire [`KECCAK_WIDTH-1:0] keccak_input [0:(`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1+1-1];//+1 because 9, +1 because interwire
wire [0:(`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1+1-1]  keccak_valid ;
assign keccak_valid[0] = data_valid;
//assign keccak_input[0] = {{(`KECCAK_WIDTH-`SHA_256_DATA_RATE){1'b0}},padded_input[`SHA_256_DATA_RATE-1:0]};
assign keccak_input[0] = 0;


wire [`SHA_256_DATA_RATE-1:0] modified_input [0:((`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1)*((`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1+1)-1];
//assign modified_input[0] = padded_input&{`SHA_256_DATA_RATE{1'b0}};
assign data_valid_out = keccak_valid[(`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1];
assign data_out= keccak_input[(`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1][`SHA_256_OUTPUT-1:0];

generate
    genvar i;
    genvar k;
    genvar j;
    for (k=0; k<(`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1; k=k+1) begin
        for (j=0; j<(`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1; j=j+1) begin
            shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`SHA_256_DATA_RATE)) shift_02(clk, modified_input[k*((`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1)+j],modified_input[(k+1)*((`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1)+j]);
        end
    end





    for (i=0; i<(`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1; i=i+1) begin
        assign modified_input[i] = padded_input[`SHA_256_DATA_RATE*i+:`SHA_256_DATA_RATE];
        
        keccak_f #(.BURST_SIZE(`BURST_SIZE_DIV_BY_3)) keccak_f_SHA_256_block(
        clk, 
        rst,
        {keccak_input[i][`KECCAK_WIDTH-1:`SHA_256_DATA_RATE] ,modified_input[i*((`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1)+i]^keccak_input[i][`SHA_256_DATA_RATE-1:0] },
         keccak_valid[i], 
         keccak_valid[i+1], 
         keccak_input[i+1]);
        //shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`SHA_256_DATA_RATE*((`INPUT_WIDTH_CLUSTER_PK/`SHA_256_DATA_RATE)+1+1))) shift_02(clk, modified_input[i], modified_input[i+1]);
        
    end



endgenerate
 

endmodule