`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 06/29/2022 04:24:36 PM
// Design Name: NTT generator
// Module Name: Bailey NTT (known as four step NTT for some stupid reason)
// Project Name: NTT generator
// Target Devices: U55c
// Tool Versions: Vivado 2020.2
// 
// Dependencies: 
// Revision 0.01 - File Created
// Additional Comments:
//D:\Jonas\PROGRAMS\Sigasi\sigasi.lic Pasting it here so I don't forget 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v" 
`include "ntt_params.v"
module Bailey_NTT #(parameter DIRECTION = "FORWARD") (
    input clk,
    input reset,
    input [`COEF_PER_CLOCK_CYCLE_BAILEY_NTT*`MODULUS_WIDTH-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`COEF_PER_CLOCK_CYCLE_BAILEY_NTT*`MODULUS_WIDTH-1:0] data_out
    );
    
    
localparam PSI_FIRST_PASS = (DIRECTION == "FORWARD") ? modular_pow(`TWIDDLE_2N, `NTT_DIV_BY_RING, `MODULUS) : 1;
localparam OMEGA_FIRST_PASS = (DIRECTION == "FORWARD") ? modular_pow(`TWIDDLE_2N, `NTT_DIV_BY_RING<<1, `MODULUS) : modular_pow(`INVERSE_TWIDDLE_2N, `NTT_DIV_BY_RING<<1, `MODULUS);
localparam PSI_SECOND_PASS = (DIRECTION == "FORWARD") ? 1 : modular_pow(`INVERSE_TWIDDLE_2N, `COEF_PER_CLOCK_CYCLE_BAILEY_NTT, `MODULUS);
localparam OMEGA_SECOND_PASS = (DIRECTION == "FORWARD") ? modular_pow(`TWIDDLE_2N, `COEF_PER_CLOCK_CYCLE_BAILEY_NTT<<1, `MODULUS) : modular_pow(`INVERSE_TWIDDLE_2N, `COEF_PER_CLOCK_CYCLE_BAILEY_NTT<<1, `MODULUS);



  
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

wire [`COEF_PER_CLOCK_CYCLE_BAILEY_NTT*(`MODULUS_WIDTH)-1:0]  matrix_1_data_out;
wire matrix_1_data_valid_out;
wire [`COEF_PER_CLOCK_CYCLE_BAILEY_NTT*(`MODULUS_WIDTH)-1:0]  barrel_in_wire_2, barrel_in_wire_3;
wire [`COEF_PER_CLOCK_CYCLE_BAILEY_NTT*(`MODULUS_WIDTH)-1:0] NTT_IN_wire_GOLD_MODULUS, NTT_IN_wire_GOLD_MODULUS_2;
wire [`COEF_PER_CLOCK_CYCLE_BAILEY_NTT*(`MODULUS_WIDTH)-1:0]  NTT_IN_wire_2;
wire [`COEF_PER_CLOCK_CYCLE_BAILEY_NTT*(`MODULUS_WIDTH)-1:0] NTT_OUT_wire, NTT_OUT_wire_2;
wire [(`MODULUS_WIDTH)-1:0] internal_wiring [0:(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT)-1];
wire [(`MODULUS_WIDTH)-1:0] internal_wiring_2 [0:(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT)-1];
wire [(`MODULUS_WIDTH)-1:0] twiddle_out [0:(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT)-1];
wire [(`MODULUS_WIDTH)-1:0] mult_out [0:(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT)-1];
wire  data_multiplier_valid, data_barrel_2_valid, data_ntt_valid_2;
wire [(1<<(2*`LOG_COEF_PER_CC_BAILEY_NTT-`LOG_N_BAILEY_NTT))-1:0] data_ntt_2_valid_out;
wire twiddle_valid;



  

// NTT_64
NTT_const_mult #(.STREAM_SIZE(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT), 
.PSI(PSI_FIRST_PASS), 
.OMEGA(OMEGA_FIRST_PASS), 
.PRECOMP_FACTOR(`PRECOMP_FACTOR),
.DIRECTION(DIRECTION),
.REDUCED_POLYNOMIAL_DEPTH(0)) 
FIRST_NTT_OF_BAILEY_NTT_instance(clk,matrix_1_data_out,matrix_1_data_valid_out, data_multiplier_valid, NTT_OUT_wire);
   

      
generate

endgenerate 
generate
if (`LOG_COEF_PER_CC_BAILEY_NTT==`LOG_N_BAILEY_NTT) begin //alternatively: `LOG_N == `LOG_COEF_PER_CC
    assign data_out = NTT_OUT_wire;
    assign data_valid_out = data_multiplier_valid;
    assign matrix_1_data_valid_out = data_valid;
    assign matrix_1_data_out = data_in;
end else begin
//reduction + multiplier
// MATRIX TRANSPOSE CAN BE DONE BEFORE, but if possible should be done in precomputation
matrix_rectangular_transpose #(.STREAM_SIZE_SQUARE_MATRIX(`NTT_DIV_BY_RING), .DIRECTION("FORWARD")) matrix_1(clk, reset, data_in,data_valid, matrix_1_data_valid_out, matrix_1_data_out);  



shift_reg_data_valid #(`FIRST_NTT_LATENCY-1) twiddle_instance (clk, matrix_1_data_valid_out, twiddle_valid);   
shift_reg_data_valid #(`MULTIPLIER_LATENCY+`REDUCTION_LATENCY) shift_instance_2 (clk, data_multiplier_valid, data_barrel_2_valid);  
    genvar k;
    for(k = 0; k < `COEF_PER_CLOCK_CYCLE_BAILEY_NTT; k=k+1) begin: INITIAL
        // MODULUS_WIDTH - `MODULUS_WIDTH
        modular_multiplier modular_multiplier(
        .clk(clk),.input_a(NTT_OUT_wire[(k+1)*(`MODULUS_WIDTH)-1:k*(`MODULUS_WIDTH)]), .input_b(twiddle_out[k]), 
        .output_product(mult_out[k]));
        twiddle_generation #(.TWIDDLE_INDEX(k), .DIRECTION(DIRECTION)) twiddle_gen(clk, reset, twiddle_valid, twiddle_out[k]);
    end
 
//multiplier ROM (requires 
// BRAM
     genvar m;
    for(m = 0; m < `COEF_PER_CLOCK_CYCLE_BAILEY_NTT; m=m+1) begin: BARREL_2
        // MODULUS_WIDTH - `MODULUS_WIDTH
        assign barrel_in_wire_2[m*`MODULUS_WIDTH+:`MODULUS_WIDTH] = mult_out[m] ;
    end
 matrix_rectangular_transpose #(.STREAM_SIZE_SQUARE_MATRIX(`NTT_DIV_BY_RING), .DIRECTION("BACKWARD")) matrix_2(clk, reset, barrel_in_wire_2, data_barrel_2_valid,data_ntt_valid_2, NTT_IN_wire_2);



    genvar ntt_iter;
    for(ntt_iter = 0; ntt_iter < (1<<(2*`LOG_COEF_PER_CC_BAILEY_NTT-`LOG_N_BAILEY_NTT)); ntt_iter=ntt_iter+1) begin: NTT_ITER_LOOP
        NTT_const_mult #(.STREAM_SIZE(`NTT_DIV_BY_RING), 
        .PSI(PSI_SECOND_PASS),//`TWIDDLE_2N is integrated into pointwise multiplication 
        .OMEGA(OMEGA_SECOND_PASS), 
        .PRECOMP_FACTOR(`PRECOMP_FACTOR),
        .DIRECTION(DIRECTION),
        .REDUCED_POLYNOMIAL_DEPTH(0)) SECOND_NTT_OF_BAILEY_NTT_instance(
        clk,
        NTT_IN_wire_2[ntt_iter*`NTT_DIV_BY_RING*`MODULUS_WIDTH+:`NTT_DIV_BY_RING*`MODULUS_WIDTH],
        data_ntt_valid_2,
        data_ntt_2_valid_out[ntt_iter], 
        NTT_OUT_wire_2[ntt_iter*`NTT_DIV_BY_RING*`MODULUS_WIDTH+:`NTT_DIV_BY_RING*`MODULUS_WIDTH]); 
    end
    //assign data_out = NTT_OUT_wire_2;
    //assign data_valid_out = data_ntt_2_valid_out[0];
    matrix_rectangular_transpose #(.STREAM_SIZE_SQUARE_MATRIX(`NTT_DIV_BY_RING), .DIRECTION("FORWARD")) matrix_3(clk, reset, NTT_OUT_wire_2, data_ntt_2_valid_out[0],data_valid_out, data_out);  
    //assign data_out = barrel_in_wire_3;
    // assign data_valid_out = data_barrel_3_valid;
end
endgenerate







endmodule