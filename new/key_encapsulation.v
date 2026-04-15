`timescale 1ns / 1ps
//Copyright 2026 Jonas Bertels COSIC KU Leuven
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
//sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
//DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
//OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//////////////////////////////////////////////////////////////////////////////////
`include "parameters.v" 
`include "ntt_params.v"

module key_encapsulation(
input clk,
input rst,
input [`INPUT_WIDTH_CLUSTER_MESSAGE-1:0] message,
input [`INPUT_WIDTH_CLUSTER_PK-1:0] public_key,
input data_valid,
output [`K_WIDTH-1:0] K_output,
output [`CIPHERTEXT_WIDTH-1:0] ciphertext,
output data_valid_out
    );
    
wire internal_reset;
assign internal_reset = rst;    
wire data_valid_out_SHA_256, data_valid_out_SHA_512;    
wire data_valid_out_SHA_512_spaced;


wire [`SHA_256_OUTPUT-1:0] pk_hash;    
SHA_3_256 SHA_3_256_instance (clk, internal_reset, public_key, data_valid,data_valid_out_SHA_256, pk_hash);

wire [`INPUT_WIDTH_CLUSTER_MESSAGE-1:0] message_in_512;
wire [(`INPUT_WIDTH_CLUSTER_MESSAGE>>(`LOG_N-`LOG_COEF_PER_CC))-1:0] message_for_mu;
wire [(`INPUT_WIDTH_CLUSTER_MESSAGE>>(`LOG_N-`LOG_COEF_PER_CC))-1:0] message_stream;
wire data_empty;
constant_delay_buffer #(.shift(`ROUNDS_OF_KECCAK), .width(`INPUT_WIDTH_CLUSTER_MESSAGE)) shift_message_in_512 (clk, message, message_in_512);
Burst_into_stream #(
.INPUT_WIDTH((`INPUT_WIDTH_CLUSTER_MESSAGE)), 
.OUTPUT_WIDTH(`INPUT_WIDTH_CLUSTER_MESSAGE>>(`LOG_N-`LOG_COEF_PER_CC)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC)))
) Burst_message
(clk, internal_reset, message_in_512, data_valid_out_SHA_512, data_empty, message_stream);

constant_delay_buffer #(.shift(`MESSAGE_LATENCY), .width((`INPUT_WIDTH_CLUSTER_MESSAGE>>(`LOG_N-`LOG_COEF_PER_CC)))) shift_mu (clk, message_stream, message_for_mu);

wire [`SHA_512_OUTPUT/2-1:0] K, r, r_burst, rho;  

SHA_3_512 SHA_3_512_instance (clk, internal_reset, {pk_hash, message_in_512}, data_valid_out_SHA_256,data_valid_out_SHA_512, {r_burst, K});
wire stream_valid_K, stream_valid_t;
wire [`K_WIDTH-1:0] K_stream;  
Burst_into_stream #(
.INPUT_WIDTH((`SHA_512_OUTPUT/2)), 
.OUTPUT_WIDTH(`K_WIDTH), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC))) 
) Burst_K
(clk, internal_reset, K, data_valid_out_SHA_512, stream_valid_K, K_stream);

wire [`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*`SMALL_K-1:0] t_normal, t_reversed;
wire [`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*`SMALL_K-1:0] A_normal, A_reversed;
//A_2_burst_reversed
wire [(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)-1:0] A_0_burst, A_1_burst, A_2_burst;
wire [(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)-1:0] A_0_burst_reversed, A_1_burst_reversed, A_2_burst_reversed;
assign A_normal = {A_2_burst,A_1_burst,A_0_burst};
assign A_2_burst_reversed = A_reversed[`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*2+:`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE];
assign A_1_burst_reversed = A_reversed[`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*1+:`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE];
assign A_0_burst_reversed = A_reversed[`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*0+:`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE];


assign t_normal = public_key[`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*`SMALL_K-1:0];
//bit_reversal of t_stream VERY IMPORTANT NOTE: OUR NTT KEEPS THE POLYNOMIAL IN NORMAL ORDER, THEREFORE T MUST BE BITINVERSED
generate
genvar index_of_t, iterator_k;
for (iterator_k=0; iterator_k<(`SMALL_K); iterator_k=iterator_k+1) begin
    for (index_of_t=0; index_of_t<(`NTT_POLYNOMIAL_SIZE>>`REDUCED_POLYNOMIAL_DEPTH); index_of_t=index_of_t+1) begin
        assign t_reversed[iterator_k*`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE+2*`MODULUS_WIDTH*bit_inverse(index_of_t[`LOG_N_BAILEY_NTT-1:0])+:2*`MODULUS_WIDTH] = t_normal[iterator_k*`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE+2*`MODULUS_WIDTH*index_of_t[`LOG_N_BAILEY_NTT-1:0]+:2*`MODULUS_WIDTH];
        assign A_reversed[iterator_k*`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE+2*`MODULUS_WIDTH*bit_inverse(index_of_t[`LOG_N_BAILEY_NTT-1:0])+:2*`MODULUS_WIDTH] = A_normal[iterator_k*`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE+2*`MODULUS_WIDTH*index_of_t[`LOG_N_BAILEY_NTT-1:0]+:2*`MODULUS_WIDTH];
    end
end
endgenerate

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] t_stream;  
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*`SMALL_K)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST(((`BURST_SIZE_DIV_BY_3*`SMALL_K)<<(`LOG_N-`LOG_COEF_PER_CC))) //ends up being 24, which makes sense
) Burst_ciphertext
(clk, internal_reset, t_reversed, data_valid, stream_valid_t, t_stream);




burst_spacing #(
.INPUT_WIDTH(`SHA_512_OUTPUT/2),
.BURST_SIZE(`BURST_SIZE_DIV_BY_3),
.SPACING(`SMALL_K)
) space_burst
(clk, internal_reset, r_burst,data_valid_out_SHA_512, data_valid_out_SHA_512_spaced, r);

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] t_stream_delayed;  
reg [`SHAKE_COUNTER_SIZE-1:0] input_counter;
//TODO: CHANGE TO PULSED!!!!
always @(posedge clk) begin
    if (internal_reset) begin
        input_counter <= 0;
    end else if (data_valid_out_SHA_512_spaced || ~(input_counter==0)) begin
        if (input_counter == `SMALL_K-1) begin
            input_counter <= 0; 
        end else begin
            input_counter <= input_counter + 1;    
        end
    end else begin
        input_counter <= input_counter;
    end
end
reg [`SHA_512_OUTPUT/2-1:0] r_cap; 
reg data_valid_out_SHA_512_reg;
reg [`SHAKE_COUNTER_SIZE-1:0] input_counter_reg;
always @(posedge clk) begin
    data_valid_out_SHA_512_reg <= (data_valid_out_SHA_512_spaced || ~(input_counter==0));
    input_counter_reg <= input_counter;
    if (data_valid_out_SHA_512_spaced) begin
        r_cap <=r;
    end else begin
        r_cap <=r_cap;
    end
end

wire Y_gen_valid;
wire [`OUTPUT_WIDTH_CLUSTER_SHAKE_256-1:0] SHAKE_256_out;
SHAKE_256 #(.BURST_SIZE(`BURST_SIZE)) Y_generation (clk, internal_reset, {input_counter_reg, r_cap}, data_valid_out_SHA_512_reg, Y_gen_valid,SHAKE_256_out);

wire [`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE-1:0] sampled_Y_burst;
generate
genvar y;
    for (y=0; y<`NTT_POLYNOMIAL_SIZE; y=y+1) begin
        SamplePolyCBD Sample_Y (clk, SHAKE_256_out[y*(`SAMPLE_INPUT_WIDTH)+:`SAMPLE_INPUT_WIDTH], sampled_Y_burst[y*(`MODULUS_WIDTH)+:`MODULUS_WIDTH]);
    end
endgenerate

reg temp_y_data_valid_buffer;
always @(posedge clk) begin
    temp_y_data_valid_buffer <= Y_gen_valid;
end

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] Y_stream;  
wire stream_valid_y;
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE), 
.OUTPUT_BURST((`BURST_SIZE<<(`LOG_N-`LOG_COEF_PER_CC))) //ends up being 24, which makes sense, has to match t
) Burst_Y
(clk, internal_reset, sampled_Y_burst, temp_y_data_valid_buffer, stream_valid_y, Y_stream);


////////////////////////////////////////////////////A _generation
assign rho = public_key[`INPUT_WIDTH_CLUSTER_PK-1:`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*`SMALL_K];
wire [`SHA_512_OUTPUT/2-1:0] rho_delay, rho_spaced;
wire rho_delay_valid, data_valid_out_rho_spaced;


constant_delay_buffer #(
.shift(11*`ROUNDS_OF_KECCAK+2*`BURST_LATENCY+`CAPTURE_R_LATENCY+`SAMPLE_POLY_CBD_LATENCY+`FORWARD_NTT_1024_LATENCY
-`BURST_LATENCY-`CAPTURE_R_LATENCY-5*`ROUNDS_OF_KECCAK-(`FIRST_BITONIC_LATENCY+`SECOND_BITONIC_LATENCY+2)-`BURST_LATENCY), 
.width((`SHA_512_OUTPUT/2))) shift_rho_first(clk, rho, rho_delay);

shift_reg_data_valid #(10*`ROUNDS_OF_KECCAK) shift_instance_rho (clk, data_valid, rho_delay_valid);  

burst_spacing #(
.INPUT_WIDTH(`SHA_512_OUTPUT/2),
.BURST_SIZE(`BURST_SIZE_DIV_BY_3),
.SPACING(`SMALL_K)
) space_burst_rho
(clk, internal_reset, rho_delay,rho_delay_valid, data_valid_out_rho_spaced, rho_spaced);

reg [`SHA_512_OUTPUT/2-1:0] rho_delay_cap; 
reg data_valid_out_rho_reg;
reg [`SHAKE_COUNTER_SIZE-1:0] input_counter_rho_reg;
reg [`SHAKE_COUNTER_SIZE-1:0] input_counter_rho;
always @(posedge clk) begin
    data_valid_out_rho_reg <= (data_valid_out_rho_spaced || ~(input_counter_rho==0));
    input_counter_rho_reg <= input_counter_rho;
    if (data_valid_out_rho_spaced) begin
        rho_delay_cap <=rho_spaced;
    end else begin
        rho_delay_cap <=rho_delay_cap;
    end
end




//TODO: CHANGE TO PULSED!!!!
always @(posedge clk) begin
    if (internal_reset) begin
        input_counter_rho <= 0;
    end else if (data_valid_out_rho_spaced || ~(input_counter_rho==0)) begin
        if (input_counter_rho == `SMALL_K-1) begin
            input_counter_rho <= 0; 
        end else begin
            input_counter_rho <= input_counter_rho + 1;    
        end
    end else begin
        input_counter_rho <= input_counter_rho;
    end
end

wire A_gen_valid_0,A_gen_valid_1, A_gen_valid_2 ;



wire [`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:0] SHAKE_128_out, SHAKE_128_out_1, SHAKE_128_out_2;
SHAKE_128 #(.BURST_SIZE(`BURST_SIZE)) A_generation_0 (clk, internal_reset, {8'd0,input_counter_rho, rho_delay_cap}, data_valid_out_rho_reg, A_gen_valid_0,SHAKE_128_out);
SHAKE_128 #(.BURST_SIZE(`BURST_SIZE)) A_generation_1 (clk, internal_reset, {8'd1,input_counter_rho, rho_delay_cap}, data_valid_out_rho_reg,A_gen_valid_1 ,SHAKE_128_out_1);
SHAKE_128 #(.BURST_SIZE(`BURST_SIZE)) A_generation_2 (clk, internal_reset, {8'd2,input_counter_rho, rho_delay_cap}, data_valid_out_rho_reg,A_gen_valid_2 ,SHAKE_128_out_2);

wire sample_valid_0, sample_valid_1, sample_valid_2;


sample_ntt sample_0 (clk, SHAKE_128_out,A_gen_valid_0 ,sample_valid_0 , A_0_burst);
sample_ntt sample_1 (clk, SHAKE_128_out_1,A_gen_valid_1 ,sample_valid_1 , A_1_burst);
sample_ntt sample_2 (clk, SHAKE_128_out_2,A_gen_valid_2 ,sample_valid_2 , A_2_burst);

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] A_0_stream;  
wire stream_valid_A_0;
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE), 
.OUTPUT_BURST((`BURST_SIZE<<(`LOG_N-`LOG_COEF_PER_CC))) //ends up being 24, which makes sense, has to match t
) Burst_A_0
(clk, internal_reset, A_0_burst_reversed, sample_valid_0, stream_valid_A_0, A_0_stream);

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] A_1_stream;  
wire stream_valid_A_1;
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE), 
.OUTPUT_BURST((`BURST_SIZE<<(`LOG_N-`LOG_COEF_PER_CC))) //ends up being 24, which makes sense, has to match t
) Burst_A_1
(clk, internal_reset, A_1_burst_reversed, sample_valid_1, stream_valid_A_1, A_1_stream);

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] A_2_stream;  
wire stream_valid_A_2;
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE), 
.OUTPUT_BURST((`BURST_SIZE<<(`LOG_N-`LOG_COEF_PER_CC))) //ends up being 24, which makes sense, has to match t
) Burst_A_2
(clk, internal_reset, A_2_burst_reversed, sample_valid_2, stream_valid_A_2, A_2_stream);


//////////////////////////////////////////////////////////////// LATENCY BLOCK BECAUSE SIMULATION STRUGGLES
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] t_stream_0, t_stream_1, t_stream_1_one_half, t_stream_2;  


constant_delay_buffer #(.shift(4*`ROUNDS_OF_KECCAK), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_0(clk, t_stream, t_stream_0);
constant_delay_buffer #(.shift(4*`ROUNDS_OF_KECCAK), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_1(clk, t_stream_0, t_stream_1);
constant_delay_buffer #(.shift(3*`ROUNDS_OF_KECCAK), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_1_one_half(clk, t_stream_1, t_stream_1_one_half);
constant_delay_buffer #(.shift(`BURST_LATENCY+`CAPTURE_R_LATENCY+`SAMPLE_POLY_CBD_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_2(clk, t_stream_1_one_half, t_stream_2);
constant_delay_buffer #(.shift(`FORWARD_NTT_1024_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_3(clk, t_stream_2, t_stream_delayed);

////////////////////////////////////////////////////////////////



constant_delay_buffer #(.shift(`TOTAL_LATENCY_ENCRYPTION), .width(`K_WIDTH)) shift_1(clk, K_stream, K_output);
shift_reg_data_valid #(`TOTAL_LATENCY_ENCRYPTION) shift_instance_2 (clk, stream_valid_K, data_valid_out);  

wire y_valid_out;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] NTT_y_OUT_wire, poly_out,ty_out, ty_half_out, Ay0_out, Ay1_out,Ay2_out,Ay0, Ay1,Ay2;
NTT_incomplete NTT_128_instance(clk,internal_reset, Y_stream,stream_valid_y, y_valid_out , NTT_y_OUT_wire);
wire [0:(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)-1] data_valid_out_coef;
wire [0:(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)-1] data_valid_out_coef_A_0;
wire [0:(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)-1] data_valid_out_coef_A_1;
wire [0:(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)-1] data_valid_out_coef_A_2;

wire [0:`COEF_PER_CLOCK_CYCLE-1] ty_valid_out_coef;
wire [0:`COEF_PER_CLOCK_CYCLE-1] A0_valid_out_coef;
wire [0:`COEF_PER_CLOCK_CYCLE-1] A1_valid_out_coef;
wire [0:`COEF_PER_CLOCK_CYCLE-1] A2_valid_out_coef;


wire [(`MODULUS_WIDTH)-1:0] twiddles [0:(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)-1]; 
wire data_valid_twiddle;

shift_reg_data_valid #(`FORWARD_NTT_1024_LATENCY-1) shift_instance_3 (clk, stream_valid_y, data_valid_twiddle);  

function [`LOG_N_BAILEY_NTT-1:0] bit_inverse;//TODO: FIX TO DEAL WITH KYBER PARAMETERS
 input [`LOG_N_BAILEY_NTT-1:0] normal_order;
 integer index_bitreverse;
 begin
     for(index_bitreverse=0; index_bitreverse<(`LOG_N_BAILEY_NTT); index_bitreverse=index_bitreverse+1) begin
        bit_inverse[index_bitreverse] = normal_order[`LOG_N_BAILEY_NTT - 1-index_bitreverse];
     end
 end
endfunction

generate
genvar i;
for (i=0; i<(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH); i=i+1) begin
///t * y component
twiddle_generation_coefficient #(.TWIDDLE_INDEX(i)) twiddle_gen_here (clk, internal_reset, data_valid_twiddle, twiddles[i] );
coefficient_multiplication coef_mult (clk, twiddles[i], NTT_y_OUT_wire[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH], t_stream_delayed[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH],y_valid_out, data_valid_out_coef[i], poly_out[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH]);
//A * y component
coefficient_multiplication A_y_mult_0 (clk, twiddles[i], NTT_y_OUT_wire[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH], A_0_stream[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH],y_valid_out, data_valid_out_coef_A_0[i], Ay0_out[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH]);
coefficient_multiplication A_y_mult_1 (clk, twiddles[i], NTT_y_OUT_wire[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH], A_1_stream[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH],y_valid_out, data_valid_out_coef_A_1[i], Ay1_out[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH]);
coefficient_multiplication A_y_mult_2 (clk, twiddles[i], NTT_y_OUT_wire[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH], A_2_stream[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH],y_valid_out, data_valid_out_coef_A_2[i], Ay2_out[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH]);

end  
genvar coef;
for (coef=0; coef<`COEF_PER_CLOCK_CYCLE; coef=coef+1) begin
///t * y component
three_to_one_accumulator three_to_one_accumulator_inst (clk, internal_reset, poly_out[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH], data_valid_out_coef[(coef>>`REDUCED_POLYNOMIAL_DEPTH)],ty_valid_out_coef[coef], ty_out[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH]);
//A * y component
three_to_one_accumulator three_to_one_accumulator_inst_A0 (clk, internal_reset, Ay0_out[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH], data_valid_out_coef_A_0[(coef>>`REDUCED_POLYNOMIAL_DEPTH)],A0_valid_out_coef[coef], Ay0[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH]);
three_to_one_accumulator three_to_one_accumulator_inst_A1 (clk, internal_reset, Ay1_out[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH], data_valid_out_coef_A_1[(coef>>`REDUCED_POLYNOMIAL_DEPTH)],A1_valid_out_coef[coef], Ay1[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH]);
three_to_one_accumulator three_to_one_accumulator_inst_A2 (clk, internal_reset, Ay2_out[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH], data_valid_out_coef_A_2[(coef>>`REDUCED_POLYNOMIAL_DEPTH)],A2_valid_out_coef[coef], Ay2[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH]);

end
endgenerate
wire ty_valid, ty_half_valid;
shift_reg_data_valid #((`ACCUMULATOR_LATENCY+`MULTIPLIER_LATENCY+`REDUCTION_LATENCY+`MULTIPLIER_LATENCY+1+`REDUCTION_LATENCY)) shift_instance_4 (clk, y_valid_out, ty_valid); //ty_valid also denotes A valid; 


///////////////////////////////////////////////////////E2 BLOCK///////////////////////////////////////////////////////////
wire e2_valid;
wire [`OUTPUT_WIDTH_CLUSTER_SHAKE_256-1:0] e2_burst_out;
SHAKE_256 #(.BURST_SIZE(`BURST_SIZE_DIV_BY_3)) e2_generation (clk, internal_reset, {8'd6, r_burst}, data_valid_out_SHA_512, e2_valid,e2_burst_out);
wire [`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE-1:0] sampled_e2_burst;
generate
genvar e2;
    for (e2=0; e2<`NTT_POLYNOMIAL_SIZE; e2=e2+1) begin
        SamplePolyCBD Sample_e2 (clk, e2_burst_out[e2*(`SAMPLE_INPUT_WIDTH)+:`SAMPLE_INPUT_WIDTH], sampled_e2_burst[e2*(`MODULUS_WIDTH)+:`MODULUS_WIDTH]);
    end
endgenerate

reg temp_e2_data_valid_buffer;
always @(posedge clk) begin
    temp_e2_data_valid_buffer <= e2_valid;
end
wire stream_valid_e2;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] e2_stream;  
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC))) 
) Burst_e2
(clk, internal_reset, sampled_e2_burst, temp_e2_data_valid_buffer, stream_valid_e2, e2_stream);

///////////////////////////////////////////////////////E2 BLOCK///////////////////////////////////////////////////////////

///////////////////////////////////////////////////////E1 BLOCK///////////////////////////////////////////////////////////
wire e1_valid_0, e1_valid_1,e1_valid_2;
wire [`OUTPUT_WIDTH_CLUSTER_SHAKE_256-1:0] e1_burst_out_0, e1_burst_out_1, e1_burst_out_2;
SHAKE_256 #(.BURST_SIZE(`BURST_SIZE_DIV_BY_3)) e1_generation_0 (clk, internal_reset, {8'd3, r_burst}, data_valid_out_SHA_512, e1_valid_0,e1_burst_out_0);
SHAKE_256 #(.BURST_SIZE(`BURST_SIZE_DIV_BY_3)) e1_generation_1 (clk, internal_reset, {8'd4, r_burst}, data_valid_out_SHA_512, e1_valid_1,e1_burst_out_1);
SHAKE_256 #(.BURST_SIZE(`BURST_SIZE_DIV_BY_3)) e1_generation_2 (clk, internal_reset, {8'd5, r_burst}, data_valid_out_SHA_512, e1_valid_2,e1_burst_out_2);

wire [`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE-1:0] sampled_e1_burst_0,sampled_e1_burst_1,sampled_e1_burst_2;
generate
genvar e1;
    for (e1=0; e1<`NTT_POLYNOMIAL_SIZE; e1=e1+1) begin
        SamplePolyCBD Sample_e1_0 (clk, e1_burst_out_0[e1*(`SAMPLE_INPUT_WIDTH)+:`SAMPLE_INPUT_WIDTH], sampled_e1_burst_0[e1*(`MODULUS_WIDTH)+:`MODULUS_WIDTH]);
        SamplePolyCBD Sample_e1_1 (clk, e1_burst_out_1[e1*(`SAMPLE_INPUT_WIDTH)+:`SAMPLE_INPUT_WIDTH], sampled_e1_burst_1[e1*(`MODULUS_WIDTH)+:`MODULUS_WIDTH]);
        SamplePolyCBD Sample_e1_2 (clk, e1_burst_out_2[e1*(`SAMPLE_INPUT_WIDTH)+:`SAMPLE_INPUT_WIDTH], sampled_e1_burst_2[e1*(`MODULUS_WIDTH)+:`MODULUS_WIDTH]);

    end
endgenerate

reg temp_e1_data_valid_buffer_0, temp_e1_data_valid_buffer_1, temp_e1_data_valid_buffer_2;
always @(posedge clk) begin
    temp_e1_data_valid_buffer_0 <= e1_valid_0;
    temp_e1_data_valid_buffer_1 <= e1_valid_1;
    temp_e1_data_valid_buffer_2 <= e1_valid_2;
end


wire stream_valid_e1_0;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] e1_stream_0;  
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC))) 
) Burst_e1_0
(clk, internal_reset, sampled_e1_burst_0, temp_e1_data_valid_buffer_0, stream_valid_e1_0, e1_stream_0);

wire stream_valid_e1_1;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] e1_stream_1;  
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC))) 
) Burst_e1_1
(clk, internal_reset, sampled_e1_burst_1, temp_e1_data_valid_buffer_1, stream_valid_e1_1, e1_stream_1);

wire stream_valid_e1_2;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] e1_stream_2;  
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC))) 
) Burst_e1_2
(clk, internal_reset, sampled_e1_burst_2, temp_e1_data_valid_buffer_2, stream_valid_e1_2, e1_stream_2);

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] e1_stream_delayed_0, e1_stream_delayed_1, e1_stream_delayed_2;
constant_delay_buffer #(.shift(2*`FORWARD_NTT_1024_LATENCY+`COEF_MULT_2+`ACCUMULATOR_LATENCY+`CAPTURE_R_LATENCY+`BURST_LATENCY), 
.width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e1_0(clk, e1_stream_2, e1_stream_delayed_0);
constant_delay_buffer #(.shift(2*`FORWARD_NTT_1024_LATENCY+`COEF_MULT_2+`ACCUMULATOR_LATENCY+`CAPTURE_R_LATENCY+`BURST_LATENCY), 
.width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e1_1(clk, e1_stream_2, e1_stream_delayed_1);
constant_delay_buffer #(.shift(2*`FORWARD_NTT_1024_LATENCY+`COEF_MULT_2+`ACCUMULATOR_LATENCY+`CAPTURE_R_LATENCY+`BURST_LATENCY), 
.width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e1_2(clk, e1_stream_2, e1_stream_delayed_2);
///////////////////////////////////////////////////////E1 BLOCK///////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////// LATENCY BLOCK BECAUSE SIMULATION STRUGGLES
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] e2_stream_0,e2_stream_1, e2_stream_delayed;  
constant_delay_buffer #(.shift(`FORWARD_NTT_1024_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e2_0(clk, e2_stream, e2_stream_0);
constant_delay_buffer #(.shift(`FORWARD_NTT_1024_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e2_1(clk, e2_stream_0, e2_stream_1);
constant_delay_buffer #(.shift(`COEF_MULT_2+`ACCUMULATOR_LATENCY+`CAPTURE_R_LATENCY+`BURST_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e2_2(clk, e2_stream_1, e2_stream_delayed);



////////////////////////////////////////////////////////////////

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] INTT_ty_out;
wire INTT_ty_out_valid;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] INTT_A_0_out;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] INTT_A_1_out;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] INTT_A_2_out;
wire INTT_A_0_out_valid;
wire INTT_A_1_out_valid;
wire INTT_A_2_out_valid;

NTT_incomplete #(.DIRECTION("INVERSE")) INTT_256_A_0 (clk,internal_reset, Ay0,ty_valid_out_coef[0], INTT_A_0_out_valid, INTT_A_0_out); //Stalls 2/3 of the time OPTIMIZATION: reduce
NTT_incomplete #(.DIRECTION("INVERSE")) INTT_256_A_1 (clk,internal_reset, Ay1,ty_valid_out_coef[0], INTT_A_1_out_valid, INTT_A_1_out); //Stalls 2/3 of the time OPTIMIZATION: reduce
NTT_incomplete #(.DIRECTION("INVERSE")) INTT_256_A_2 (clk,internal_reset, Ay2,ty_valid_out_coef[0], INTT_A_2_out_valid, INTT_A_2_out); //Stalls 2/3 of the time OPTIMIZATION: reduce by using one INTT


/* TODO: HALF THE THROUGHPUT OF THIS INTT, BECAUSE YOU CAN AFFORD IT
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE>>1)), 
.BURST_SIZE(`NTT_DIV_BY_RING), 
.OUTPUT_BURST((`NTT_DIV_BY_RING<<1)), 
.CYCLES_PER_OUTPUT_LOG(2)
) Burst_ty_to_ty_half
(clk, internal_reset, ty_out, temp_e2_data_valid_buffer, stream_valid_e2, ty_half_out);

NTT_incomplete #(.DIRECTION("INVERSE")) INTT_256 (clk,internal_reset, ty_half_out,ty_half_valid, INTT_ty_out_valid, INTT_ty_out);*/
NTT_incomplete #(.DIRECTION("INVERSE")) INTT_256 (clk,internal_reset, ty_out,ty_valid_out_coef[0], INTT_ty_out_valid, INTT_ty_out); //Stalls 2/3 of the time OPTIMIZATION: reduce

//------------------------MU calculation
reg [(`MODULUS_WIDTH+2)-1:0] v_to_be_reduced [0:`COEF_PER_CLOCK_CYCLE-1];
wire [(2*`MODULUS_WIDTH)-1:0] v_shifted_plus_half_modulus [0:`COEF_PER_CLOCK_CYCLE-1];

wire [(`D_V*`COEF_PER_CLOCK_CYCLE)-1:0] c_2;
generate
genvar mu;
for (mu=0; mu<`COEF_PER_CLOCK_CYCLE; mu=mu+1) begin
    always @(posedge clk) begin
        if (message_for_mu[mu]) begin
            v_to_be_reduced[mu] <= INTT_ty_out[mu*`MODULUS_WIDTH+:`MODULUS_WIDTH] + e2_stream_delayed[mu*`MODULUS_WIDTH+:`MODULUS_WIDTH] + (`MODULUS/2+1);
        end else begin
            v_to_be_reduced[mu] <= INTT_ty_out[mu*`MODULUS_WIDTH+:`MODULUS_WIDTH] + e2_stream_delayed[mu*`MODULUS_WIDTH+:`MODULUS_WIDTH];
        end
    end
    //assign v_shifted_plus_half_modulus[mu] = (v_to_be_reduced[mu]<<`D_V) + (`MODULUS/2);
    assign v_shifted_plus_half_modulus[mu] = {{(`MODULUS_WIDTH-`D_V-2){1'b0}},v_to_be_reduced[mu], {`D_V{1'b0}}};

    //tail_reduction #(.ADDED_WIDTH(2)) reduc_mu(clk, v_to_be_reduced[mu], v[mu]); 
    Xing_and_Li_compress #(.COMPRESS_WIDTH(`D_V)) Xis_masterpiece_barrett (clk, v_shifted_plus_half_modulus[mu], c_2[mu*`D_V+:`D_V]);
end
endgenerate

//------------------------U calculation
reg [(`MODULUS_WIDTH+1)-1:0] u_to_be_reduced [0:`SMALL_K*`COEF_PER_CLOCK_CYCLE-1];
wire [(2*`MODULUS_WIDTH)-1:0] u_shifted_plus_half_modulus [0:`SMALL_K*`COEF_PER_CLOCK_CYCLE-1];

wire [(`D_U*`SMALL_K*`COEF_PER_CLOCK_CYCLE)-1:0] c_1;
generate
genvar u_index;
for (u_index=0; u_index<`COEF_PER_CLOCK_CYCLE; u_index=u_index+1) begin
    always @(posedge clk) begin
        u_to_be_reduced[u_index] <= INTT_ty_out[u_index*`MODULUS_WIDTH+:`MODULUS_WIDTH] + e2_stream_delayed[u_index*`MODULUS_WIDTH+:`MODULUS_WIDTH];

    end
    //assign v_shifted_plus_half_modulus[mu] = (v_to_be_reduced[mu]<<`D_V) + (`MODULUS/2);
    assign u_shifted_plus_half_modulus[u_index] = {{(`MODULUS_WIDTH-`D_U-1){1'b0}},u_to_be_reduced[u_index], {`D_U{1'b0}}};

    //tail_reduction #(.ADDED_WIDTH(2)) reduc_mu(clk, v_to_be_reduced[mu], v[mu]); 
    Xing_and_Li_compress #(.COMPRESS_WIDTH(`D_U)) Xis_masterpiece_barrett (clk, u_shifted_plus_half_modulus[u_index], c_1[u_index*`D_U+:`D_U]);
end
endgenerate

















constant_delay_buffer #(.shift(1), .width((`D_V*`COEF_PER_CLOCK_CYCLE))) shift_c2_out (clk, c_2, ciphertext[(`D_U*`COEF_PER_CLOCK_CYCLE)+(`D_V*`COEF_PER_CLOCK_CYCLE)-1:(`D_U*`COEF_PER_CLOCK_CYCLE)]);
constant_delay_buffer #(.shift(1), .width((`SMALL_K*`D_U*`COEF_PER_CLOCK_CYCLE))) shift_c1_out (clk, c_1, ciphertext[(`D_U*`COEF_PER_CLOCK_CYCLE)-1:0]);


endmodule
