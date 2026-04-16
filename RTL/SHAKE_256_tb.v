`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 09/09/2022 06:46:34 PM
// Design Name: 
// Module Name: matrix_tranpose_tb
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

module SHAKE_256_tb( );

reg  clk, reset;
reg  [(`MODULUS_WIDTH+1)-1:0] input_a, input_b;
reg data_valid;
wire data_valid_out, data_ntt_valid_2, data_ntt_valid_3;
reg [1*(`SHAKE_256_INPUT)-1:0] NTT_IN_wire;
wire [1*(`SHAKE_256_INPUT)-1:0] NTT_IN_wire_2, NTT_IN_wire_3; //so we can test all outputs
wire [1*(`OUTPUT_WIDTH_CLUSTER_SHAKE_256)-1:0] Burst_in_wire; //so we can test all outputs
wire [1*(`OUTPUT_WIDTH_BURST_256)-1:0] NTT_OUT_wire; //so we can test all outputs
reg [(`SHAKE_256_INPUT+1)-1:0] output_reg_a [0:1-1]; 
reg [(`SHAKE_256_INPUT+1)-1:0] NTT_OUT_reg [0:1-1]; 
reg [(`SHAKE_256_INPUT)-1:0] NTT_IN[0:1* `TEST_CLOCK_CYCLES-1];
reg [(`OUTPUT_WIDTH_BURST_256)-1:0] NTT_OUT [0:1*`NTT_DIV_BY_RING*`BURST_SIZE-1];
always #5 clk=~clk;



//matrix_rectangular_transpose #(.direction("FORWARD")) matrix_1(clk, reset, NTT_IN_wire, data_valid,data_ntt_valid_2, NTT_IN_wire_2);

//NTT_1024 NTT_1024_element(clk, reset, NTT_IN_wire_2, data_ntt_valid_2,data_ntt_valid_3, NTT_IN_wire_3);

// NTT_128
/*NTT_const_mult #(.STREAM_SIZE(1), 
.PSI(modular_pow(`TWIDDLE_2N, 1, `MODULUS)), 
.OMEGA(modular_pow(`TWIDDLE_2N, 2, `MODULUS)), 
.PRECOMP_FACTOR(`PRECOMP_FACTOR)) 
NTT_128_instance(clk,NTT_IN_wire,data_valid, data_valid_out, NTT_OUT_wire);*/

SHAKE_256 SHAKE_instance(clk,reset, NTT_IN_wire,data_valid, data_ntt_valid_2, Burst_in_wire);
Burst_into_stream #(.INPUT_WIDTH(`OUTPUT_WIDTH_CLUSTER_SHAKE_256), .OUTPUT_WIDTH((`OUTPUT_WIDTH_BURST_256)), .BURST_SIZE(`BURST_SIZE), .OUTPUT_BURST((`BURST_SIZE<<(`LOG_N-`LOG_COEF_PER_CC))), .CYCLES_PER_OUTPUT_LOG((`LOG_N-`LOG_COEF_PER_CC))) burst_instance(clk, reset,Burst_in_wire ,data_ntt_valid_2, data_valid_out, NTT_OUT_wire);
// matrix_rectangular_transpose #(.direction("FORWARD")) matrix_3(clk, reset, NTT_IN_wire_3, data_ntt_valid_3,data_valid_out, NTT_OUT_wire);

initial begin
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/SHAKE256_IN.txt", NTT_IN);
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/SHAKE256_OUT_STREAM.txt", NTT_OUT);
end


 

integer k;
integer iterator_a, iterator_b;
integer j;
integer clock_cycle_counter,clock_cycle_counter_2, clock_cycle_counter_3,  clock_cycle_counter_4,
clock_cycle_counter_5, clock_cycle_counter_6;
initial begin: TEST_BUTTERFLY
    clk       = 0;
    reset = 1;
    data_valid = 0;
    #10;
    reset = 0;
    iterator_a = 0;
    data_valid = 1;
    clock_cycle_counter = 0;

    for(clock_cycle_counter = 0; clock_cycle_counter < `TEST_CLOCK_CYCLES; clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = NTT_IN[1*clock_cycle_counter+j];
        end
        #10;
    end
    data_valid = 0;
    for(clock_cycle_counter_2 = 0; clock_cycle_counter_2 < (`ROUNDS_OF_KECCAK - `TEST_CLOCK_CYCLES); clock_cycle_counter_2=clock_cycle_counter_2+1) begin: CLOCK_CYLE_EXTRA
        /*for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = NTT_IN[1*clock_cycle_counter_2+j];
        end*/
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = 64'b0;
        end
        #10;
    end
    data_valid = 1;
    for(clock_cycle_counter = 0; clock_cycle_counter < `TEST_CLOCK_CYCLES; clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE_3
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = NTT_IN[1*clock_cycle_counter+j];
        end
        #10;
    end
    data_valid = 0;
    for(clock_cycle_counter_2 = 0; clock_cycle_counter_2 < (`ROUNDS_OF_KECCAK - `TEST_CLOCK_CYCLES); clock_cycle_counter_2=clock_cycle_counter_2+1) begin: CLOCK_CYLE_EXTRA_4
        /*for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = NTT_IN[1*clock_cycle_counter_2+j];
        end*/
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = 64'b0;
        end
        #10;
    end
        data_valid = 1;
    for(clock_cycle_counter = 0; clock_cycle_counter < `TEST_CLOCK_CYCLES; clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE_5
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = NTT_IN[1*clock_cycle_counter+j];
        end
        #10;
    end
    data_valid = 0;
    for(clock_cycle_counter_2 = 0; clock_cycle_counter_2 < (`ROUNDS_OF_KECCAK - `TEST_CLOCK_CYCLES); clock_cycle_counter_2=clock_cycle_counter_2+1) begin: CLOCK_CYLE_EXTRA_6
        /*for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = NTT_IN[1*clock_cycle_counter_2+j];
        end*/
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`SHAKE_256_INPUT)+:(`SHAKE_256_INPUT)] = 64'b0;
        end
        #10;
    end
    while (data_valid_out == 1'b0) begin //designed to just wait
        #10;
    end
    while (data_valid_out == 1'b1) begin //until we're definitely done
        #10;
    end
 end
 
 initial begin: CHECK_FOR_OUTPUT
    #100
    while (data_valid_out == 1'b0) begin
        #10;
    end

    for(clock_cycle_counter_4 = 0; clock_cycle_counter_4 < `NTT_DIV_BY_RING*`BURST_SIZE; clock_cycle_counter_4=clock_cycle_counter_4+1) begin: CLOCK_CYLE_2
        for(k=0; k<(1); k=k+1) begin
            if(NTT_OUT_wire[k*(`OUTPUT_WIDTH_BURST_256)+:(`OUTPUT_WIDTH_BURST_256)] == NTT_OUT[1*clock_cycle_counter_4+k]) begin
            // +: is the same as (k+1)*`SHAKE_256_INPUT-1:k*`SHAKE_256_INPUT, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`SHAKE_256_INPUT-1:k*`SHAKE_256_INPUT
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%h -- Calculated:%h, Expected:%h",clock_cycle_counter_4,NTT_OUT_wire[k*(`OUTPUT_WIDTH_BURST_256)+:(`OUTPUT_WIDTH_BURST_256)],NTT_OUT[1*clock_cycle_counter_4+k]);
            end
    
        end
        #10;
    end
    for(clock_cycle_counter_3 = 0; clock_cycle_counter_3 < `NTT_DIV_BY_RING*`BURST_SIZE; clock_cycle_counter_3=clock_cycle_counter_3+1) begin: CLOCK_CYLE_WAIT
        
        #10;
    end
    for(clock_cycle_counter_6 = 0; clock_cycle_counter_6 < `NTT_DIV_BY_RING*`BURST_SIZE; clock_cycle_counter_6=clock_cycle_counter_6+1) begin: CLOCK_CYLE_WAIT_6
        for(k=0; k<(1); k=k+1) begin
            if(NTT_OUT_wire[k*(`OUTPUT_WIDTH_BURST_256)+:(`OUTPUT_WIDTH_BURST_256)] == NTT_OUT[1*clock_cycle_counter_6+k]) begin
            // +: is the same as (k+1)*`SHAKE_256_INPUT-1:k*`SHAKE_256_INPUT, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`SHAKE_256_INPUT-1:k*`SHAKE_256_INPUT
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%h -- Calculated:%h, Expected:%h",clock_cycle_counter_6,NTT_OUT_wire[k*(`OUTPUT_WIDTH_BURST_256)+:(`OUTPUT_WIDTH_BURST_256)],NTT_OUT[1*clock_cycle_counter_6+k]);
            end
    
        end
        #10;
    end
	if(iterator_a == (2*`NTT_DIV_BY_RING*`BURST_SIZE))
		$display("NTT Transform:  Correct");
	else
		$display("NTT Transform:  Incorrect");

	$stop();
    
end

endmodule
