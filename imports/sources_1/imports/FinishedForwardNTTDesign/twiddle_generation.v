`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jonas Bertels
// 
// Create Date: 07/31/2022 03:55:27 PM
// Design Name: 
// Module Name: twiddle_generation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: See intt_N_HW_with_CoefPerClockCycle_optimized() in python,
// the twiddle generation part
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`include "parameters.v" `include "ntt_params.v"
module twiddle_generation #(parameter TWIDDLE_INDEX= 0, parameter DIRECTION = "FORWARD")

(
    input clk,
    input rst,
    input data_valid,
    output [`MODULUS_WIDTH-1:0] twiddle
    );
    
reg [`LOG_N_BAILEY_NTT-`LOG_COEF_PER_CC_BAILEY_NTT-1:0] counter;
reg [`MODULUS_WIDTH-1:0] twiddle_output;
wire [`MODULUS_WIDTH-1:0] OMEGA [`NTT_DIV_BY_RING-1:0];
function [`MODULUS_WIDTH-1:0] modular_pow;
 input [2*`MODULUS_WIDTH-1:0] base;
 input [`MODULUS_WIDTH-1:0] exponent, modulus;
 begin
     if (modulus == 1) begin
        modular_pow = 0;
     end else begin
        modular_pow = 1;
        while ( exponent > 0) begin
            if (exponent[0] == 1)
                modular_pow = ({ {`MODULUS_WIDTH{1'b0}} ,modular_pow} * base) % modulus;
            exponent = exponent >> 1;
            base = (base * base) % modulus;
        
        end
     end
 end
endfunction
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [2*`MODULUS_WIDTH-1:0] input1;
 input [2*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction
assign twiddle = twiddle_output;

always @(posedge clk) begin
    if (rst)
        counter <= 0;
    else if (data_valid)
        counter <= counter + 1;
    else
        counter <= counter;
end



always @(posedge clk) begin
    twiddle_output <= OMEGA[counter];
end


   //twiddle = OMEGA[TWIDDLE_INDEX * counter];


generate
genvar i;
for (i=0; i<`NTT_DIV_BY_RING; i=i+1) begin
    if (DIRECTION=="FORWARD") begin
    assign OMEGA[i] = modular_mult(
        modular_mult(
            modular_pow(`PRECOMP_FACTOR_NORMAL_MULT,`NUMBER_OF_PRECOMPS_NECESSARY,`MODULUS) , 
             modular_pow(`TWIDDLE_2N,  i, `MODULUS),
             `MODULUS),
        modular_pow(`TWIDDLE_2N, 2*TWIDDLE_INDEX *i, `MODULUS), 
        `MODULUS);
    end else begin
    assign OMEGA[i] = modular_mult(
        modular_mult(
                 modular_pow(`INVERSE_TWIDDLE_2N,  TWIDDLE_INDEX, `MODULUS),
                modular_mult(modular_pow(`PRECOMP_FACTOR_NORMAL_MULT,`NUMBER_OF_PRECOMPS_NECESSARY,`MODULUS), `INVERSE_N,`MODULUS), 
                `MODULUS), 
        modular_pow(`INVERSE_TWIDDLE_2N, 2*TWIDDLE_INDEX *i, `MODULUS), 
        `MODULUS);
    end
end



endgenerate

    
endmodule