`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 06/29/2022 04:24:36 PM
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
//D:\Jonas\PROGRAMS\Sigasi\sigasi.lic Pasting it here so I don't forget 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v"
module INTT_1024(
    input clk,
    input reset,
    input [`RING_SIZE*`GOLD_MODULUS_WIDTH-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`RING_SIZE*`GOLD_MODULUS_WIDTH-1:0] data_out
    );
    
function [`MODULUS_WIDTH-1:0] modular_pow;
 input [2*`MODULUS_WIDTH-1:0] base;
 input [`MODULUS_WIDTH-1:0] exponent;
 input [`MODULUS_WIDTH-1:0] modulus;

 begin
     if (modulus == 1) begin
        modular_pow = 0;
     end else begin
        modular_pow = 1;
        while ( exponent > 0) begin
            if (exponent[0] == 1)
                modular_pow = ({20'b0,modular_pow} * base) % modulus;
            exponent = exponent >> 1;
            base = (base * base) % modulus;
        
        end
     end
 end
endfunction


wire [`RING_SIZE*(`GOLD_MODULUS_WIDTH)-1:0]  barrel_in_wire_2, barrel_in_wire_3;
wire [`RING_SIZE*(`GOLD_MODULUS_WIDTH)-1:0] NTT_IN_wire_GOLD_MODULUS, NTT_IN_wire_GOLD_MODULUS_2;
wire [`RING_SIZE*(`MODULUS_WIDTH)-1:0] NTT_IN_wire, NTT_IN_wire_2;
wire [`RING_SIZE*(`MODULUS_WIDTH)-1:0] NTT_OUT_wire, NTT_OUT_wire_2;
wire [(`GOLD_MODULUS_WIDTH)-1:0] internal_wiring [0:(`RING_SIZE)-1];
wire [(`GOLD_MODULUS_WIDTH)-1:0] internal_wiring_2 [0:(`RING_SIZE)-1];
wire [(`GOLD_MODULUS_WIDTH)-1:0] twiddle_out [0:(`RING_SIZE)-1];
wire [(`GOLD_MODULUS_WIDTH)-1:0] mult_out [0:(`RING_SIZE)-1];
wire  data_ntt_valid, data_multiplier_valid, data_barrel_2_valid, data_ntt_valid_2;
wire [(1<<(2*`RING_DEPTH-`LOG_N))-1:0] data_ntt_2_valid_out;
wire twiddle_valid;

//PSI^32 and OMEGA^32
 //matrix_rectangular_transpose #(.direction("INVERSE")) matrix(clk, reset, data_in, data_valid,data_ntt_valid, NTT_IN_wire);
 assign NTT_IN_wire = data_in;
 assign data_ntt_valid = data_valid;
//assign NTT_IN_wire_GOLD_MODULUS = data_in;
//assign data_ntt_valid = data_valid;
   
  
// NTT_16
generate
    genvar ntt_iter;
    for(ntt_iter = 0; ntt_iter < (1<<(2*`RING_DEPTH-`LOG_N)); ntt_iter=ntt_iter+1) begin: NTT_ITER_LOOP
        NTT_const_mult #(.STREAM_SIZE(`NTT_DIV_BY_RING), 
        .PSI(`INVERSE_TWIDDLE_2048), 
        .OMEGA(modular_pow(`INVERSE_TWIDDLE_2048, `RING_SIZE<<1, `MODULUS)), 
        .PRECOMP_FACTOR(`PRECOMP_FACTOR),
        .DIRECTION("INVERSE")) NTT_16_inst(
        clk,
        NTT_IN_wire[ntt_iter*`NTT_DIV_BY_RING*`MODULUS_WIDTH+:`NTT_DIV_BY_RING*`MODULUS_WIDTH],
        data_ntt_valid,
        data_ntt_2_valid_out[ntt_iter], 
        NTT_OUT_wire[ntt_iter*`NTT_DIV_BY_RING*`MODULUS_WIDTH+:`NTT_DIV_BY_RING*`MODULUS_WIDTH]); 
    end
endgenerate

   


//multiplier ROM (requires 
// BRAM

//Barrel-shift
      


 matrix_rectangular_transpose #(.direction("FORWARD")) matrix_2(clk, reset, NTT_OUT_wire, data_ntt_2_valid_out[0],data_ntt_valid_2, NTT_IN_wire_2);

shift_reg_data_valid #(`MATRIX_TRANSPOSE_LATENCY-1) twiddle_instance (clk, data_ntt_2_valid_out[0], twiddle_valid);   

shift_reg_data_valid #(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY) shift_instance_2 (clk,data_ntt_valid_2 , data_barrel_2_valid);  


//reduction + multiplier
generate
    genvar k;
    for(k = 0; k < `RING_SIZE; k=k+1) begin: INITIAL
        // MODULUS_WIDTH - `GOLD_MODULUS_WIDTH
        modular_multiplier modular_multiplier(
        .clk(clk),.input_a(NTT_IN_wire_2[(k+1)*(`MODULUS_WIDTH)-1:k*(`MODULUS_WIDTH)]), .input_b(twiddle_out[k]), 
        .output_product(mult_out[k]));
        twiddle_generation #(.TWIDDLE_INDEX(k),.DIRECTION("INVERSE")) twiddle_gen(clk, reset, twiddle_valid, twiddle_out[k]);
    end
endgenerate 

generate
    genvar m;
    for(m = 0; m < `RING_SIZE; m=m+1) begin: BARREL_2
        // MODULUS_WIDTH - `GOLD_MODULUS_WIDTH
        assign barrel_in_wire_2[m*`GOLD_MODULUS_WIDTH+:`GOLD_MODULUS_WIDTH] = mult_out[m] ;
    end
endgenerate 

// NTT_64
NTT_const_mult #(.STREAM_SIZE(`RING_SIZE), 
.PSI(modular_pow(`INVERSE_TWIDDLE_2048, `NTT_DIV_BY_RING, `MODULUS)), 
.OMEGA(modular_pow(`INVERSE_TWIDDLE_2048, `NTT_DIV_BY_RING<<1, `MODULUS)), 
.PRECOMP_FACTOR(`PRECOMP_FACTOR),
.DIRECTION("INVERSE")) 
NTT_64_instance(clk,barrel_in_wire_2,data_barrel_2_valid, data_final_ntt_valid, NTT_OUT_wire_2);

  
 matrix_rectangular_transpose #(.direction("INVERSE")) matrix_3(clk, reset, NTT_OUT_wire_2, data_final_ntt_valid,data_valid_out, data_out);  

//assign data_out = barrel_in_wire_3;
// assign data_valid_out = data_barrel_3_valid;

endmodule