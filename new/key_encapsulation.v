`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2026 02:40:54 PM
// Design Name: 
// Module Name: key_encapsulation
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
shift_reg_width #(.shift(`ROUNDS_OF_KECCAK), .width(`INPUT_WIDTH_CLUSTER_MESSAGE)) shift_message_in_512 (clk, message, message_in_512);
Burst_into_stream #(
.INPUT_WIDTH((`INPUT_WIDTH_CLUSTER_MESSAGE)), 
.OUTPUT_WIDTH(`INPUT_WIDTH_CLUSTER_MESSAGE>>(`LOG_N-`LOG_COEF_PER_CC)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST((`BURST_SIZE_DIV_BY_3<<(`LOG_N-`LOG_COEF_PER_CC)))
) Burst_message
(clk, internal_reset, message_in_512, data_valid_out_SHA_512, data_empty, message_stream);

shift_reg_width #(.shift(`MESSAGE_LATENCY), .width((`INPUT_WIDTH_CLUSTER_MESSAGE>>(`LOG_N-`LOG_COEF_PER_CC)))) shift_mu (clk, message_stream, message_for_mu);

wire [`SHA_512_OUTPUT/2-1:0] K, r, r_burst;  

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


wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] t_stream;  
Burst_into_stream #(
.INPUT_WIDTH((`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*`SMALL_K)), 
.OUTPUT_WIDTH((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)), 
.BURST_SIZE(`BURST_SIZE_DIV_BY_3), 
.OUTPUT_BURST(((`BURST_SIZE_DIV_BY_3*`SMALL_K)<<(`LOG_N-`LOG_COEF_PER_CC))) //ends up being 24, which makes sense
) Burst_ciphertext
(clk, internal_reset, public_key[`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE*`SMALL_K-1:0], data_valid, stream_valid_t, t_stream);


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

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] t_stream_0, t_stream_1, t_stream_2;  

//////////////////////////////////////////////////////////////// LATENCY BLOCK BECAUSE SIMULATION STRUGGLES
shift_reg_width #(.shift(4*`ROUNDS_OF_KECCAK), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_0(clk, t_stream, t_stream_0);
shift_reg_width #(.shift(4*`ROUNDS_OF_KECCAK), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_1(clk, t_stream_0, t_stream_1);
shift_reg_width #(.shift(3*`ROUNDS_OF_KECCAK+`BURST_LATENCY+`CAPTURE_R_LATENCY+`SAMPLE_POLY_CBD_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_2(clk, t_stream_1, t_stream_2);
shift_reg_width #(.shift(`FORWARD_NTT_1024_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_t_3(clk, t_stream_2, t_stream_delayed);

////////////////////////////////////////////////////////////////



shift_reg_width #(.shift(`TOTAL_LATENCY_ENCRYPTION), .width(`K_WIDTH)) shift_1(clk, K_stream, K_output);
shift_reg_data_valid #(`TOTAL_LATENCY_ENCRYPTION) shift_instance_2 (clk, stream_valid_K, data_valid_out);  

wire y_valid_out;
wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] NTT_y_OUT_wire, poly_out,ty_out, ty_half_out;
NTT_incomplete NTT_128_instance(clk,internal_reset, Y_stream,stream_valid_y, y_valid_out , NTT_y_OUT_wire);
wire [0:(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)-1] data_valid_out_coef;
wire [0:`COEF_PER_CLOCK_CYCLE-1] ty_valid_out_coef;
wire [(`MODULUS_WIDTH)-1:0] twiddles [0:(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH)-1]; 
wire data_valid_twiddle;

shift_reg_data_valid #(`FORWARD_NTT_1024_LATENCY-1) shift_instance_3 (clk, stream_valid_y, data_valid_twiddle);  
generate
genvar i;
for (i=0; i<(`COEF_PER_CLOCK_CYCLE>>`REDUCED_POLYNOMIAL_DEPTH); i=i+1) begin
twiddle_generation_coefficient #(.TWIDDLE_INDEX(i)) twiddle_gen_here (clk, internal_reset, data_valid_twiddle, twiddles[i] );
coefficient_multiplication coef_mult (clk, twiddles[i], NTT_y_OUT_wire[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH], t_stream_delayed[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH],y_valid_out, data_valid_out_coef[i], poly_out[2*i*`MODULUS_WIDTH+:2*`MODULUS_WIDTH]);

end  
genvar coef;
for (coef=0; coef<`COEF_PER_CLOCK_CYCLE; coef=coef+1) begin
three_to_one_accumulator three_to_one_accumulator_inst (clk, internal_reset, poly_out[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH], data_valid_out_coef[(coef>>`REDUCED_POLYNOMIAL_DEPTH)],ty_valid_out_coef[coef], ty_out[coef*`MODULUS_WIDTH+:`MODULUS_WIDTH]);

end
endgenerate
wire ty_valid, ty_half_valid;
shift_reg_data_valid #((`ACCUMULATOR_LATENCY+`MULTIPLIER_LATENCY+`REDUCTION_LATENCY+`MULTIPLIER_LATENCY+1+`REDUCTION_LATENCY)) shift_instance_4 (clk, y_valid_out, ty_valid);  


wire e2_valid;
wire [`OUTPUT_WIDTH_CLUSTER_SHAKE_256-1:0] e2_burst_out;
SHAKE_256 #(.BURST_SIZE(`BURST_SIZE_DIV_BY_3)) e2_generation (clk, internal_reset, {8'd6, r}, data_valid_out_SHA_512_spaced, e2_valid,e2_burst_out);
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

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] e2_stream_0,e2_stream_1, e2_stream_delayed;  

//////////////////////////////////////////////////////////////// LATENCY BLOCK BECAUSE SIMULATION STRUGGLES
shift_reg_width #(.shift(`FORWARD_NTT_1024_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e2_0(clk, e2_stream, e2_stream_0);
shift_reg_width #(.shift(`FORWARD_NTT_1024_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e2_1(clk, e2_stream_0, e2_stream_1);
shift_reg_width #(.shift(`COEF_MULT_2+`ACCUMULATOR_LATENCY+`CAPTURE_R_LATENCY), .width((`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE))) shift_e2_2(clk, e2_stream_1, e2_stream_delayed);



////////////////////////////////////////////////////////////////

wire [(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE)-1:0] INTT_ty_out;
wire INTT_ty_out_valid;
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
wire [(`MODULUS_WIDTH+2)-1:0] v [0:`COEF_PER_CLOCK_CYCLE-1];
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
    //tail_reduction #(.ADDED_WIDTH(2)) reduc_mu(clk, v_to_be_reduced[mu], v[mu]); 
    Xing_and_Li_compress #(.COMPRESS_WIDTH(`D_V)) Xis_masterpiece_barrett (clk, {6'b0 ,v_to_be_reduced[mu], 4'b0}, c_2[mu*`D_V+:`D_V], );
end
endgenerate
shift_reg_width #(.shift(`TOTAL_LATENCY_ENCRYPTION-`MESSAGE_LATENCY-`COMPRESS_LATENCY-`ADDITION_LATENCY), .width((`D_V*`COEF_PER_CLOCK_CYCLE))) shift_c2_out (clk, c_2, ciphertext[(`D_U*`COEF_PER_CLOCK_CYCLE)+(`D_V*`COEF_PER_CLOCK_CYCLE)-1:(`D_U*`COEF_PER_CLOCK_CYCLE)]);


endmodule
