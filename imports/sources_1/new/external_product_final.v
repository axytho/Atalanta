`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 02/19/2024 10:21:23 PM
// Design Name: 
// Module Name: external_product_final
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
module external_product_final(
    input clk,
    input rst,
    input [`RING_SIZE*`MODULUS_WIDTH-1:0] data_in,
    input data_valid,
    input [`MODULUS_WIDTH*`RING_SIZE-1:0] BSK,
    input BSK_valid,
    output data_valid_out,
    output [`RING_SIZE*`MODULUS_WIDTH-1:0] data_out
    );
    
wire data_decompose_valid;
wire data_matrix_transpose_valid;

shift_reg_data_valid #(`L+1) decompose_shift_instance (clk, data_matrix_transpose_valid, data_decompose_valid);    

wire [`RING_SIZE*`MODULUS_WIDTH-1:0] data_to_ntt [0:`L-1];
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] data_from_matrix_transpose;
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] BSK_rotated;
wire BSK_rotated_valid;
matrix_rectangular_transpose #(.direction("FORWARD")) matrix(clk, rst, data_in, data_valid,data_matrix_transpose_valid, data_from_matrix_transpose);
 
 matrix_rectangular_transpose #(.direction("INVERSE")) matrix_BSK(clk, rst, BSK, BSK_valid,BSK_rotated_valid, BSK_rotated);

wire [`L*`MODULUS_WIDTH-1:0] data_from_decomp [0:`RING_SIZE-1];
//decomposition
generate
    genvar k, j;
    for(k = 0; k < `RING_SIZE; k=k+1) begin: DECOMP
        // MODULUS_WIDTH - `GOLD_MODULUS_WIDTH
        decompose decomposition_block(
        .clk(clk),.data_in(data_from_matrix_transpose[k*(`MODULUS_WIDTH)+:`MODULUS_WIDTH]), 
        .data_out(data_from_decomp[k]));
        for (j = 0; j< `L; j=j+1) begin: TO_NTT_PER_L
            assign data_to_ntt[j][k*(`MODULUS_WIDTH)+:`MODULUS_WIDTH] = data_from_decomp[k][j*(`MODULUS_WIDTH)+:`MODULUS_WIDTH];
        end
    end
endgenerate     
    
wire [`L-1:0] data_ntt_valid;
wire [`RING_SIZE*`MODULUS_WIDTH*`L-1:0] data_from_ntt;
generate
    genvar i;
    for (i = 0; i< `L; i=i+1) begin: NTT_PER_L
        // MODULUS_WIDTH - `GOLD_MODULUS_WIDTH
        NTT_1024 NTT_1024_instance(clk,rst,data_to_ntt[i],data_decompose_valid, data_ntt_valid[i], data_from_ntt[i*(`RING_SIZE*`MODULUS_WIDTH)+:(`RING_SIZE*`MODULUS_WIDTH)]); 
    end
endgenerate   
    
wire data_MAC_valid;
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] data_to_intt;
multiply_and_accumulate MAC(.clk(clk), .rst(rst), .data_in(data_from_ntt), .data_valid(data_ntt_valid[0]), .BSK(BSK_rotated), .BSK_valid(BSK_rotated_valid), .data_valid_out(data_MAC_valid), .data_out(data_to_intt));

INTT_1024 INTT_1024_instance(clk,rst,data_to_intt,data_MAC_valid, data_valid_out, data_out); 
        
endmodule
