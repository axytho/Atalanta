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

module sample_ntt_tb( );

reg  clk, reset;
reg  [(`MODULUS_WIDTH+1)-1:0] input_a, input_b;
reg data_valid;
wire data_valid_out, data_ntt_valid_2, data_ntt_valid_3;
reg [1*(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)-1:0] NTT_IN_wire;
wire [1*(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)-1:0] NTT_IN_wire_2, NTT_IN_wire_3; //so we can test all outputs
wire [1*(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)-1:0] NTT_OUT_wire; //so we can test all outputs
reg [(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)-1:0] NTT_IN[0:1* `TEST_CLOCK_CYCLES_SAMPLE-1];
reg [(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)-1:0] NTT_OUT [0:1*`TEST_CLOCK_CYCLES_SAMPLE-1];
always #5 clk=~clk;



//matrix_rectangular_transpose #(.direction("FORWARD")) matrix_1(clk, reset, NTT_IN_wire, data_valid,data_ntt_valid_2, NTT_IN_wire_2);

//NTT_1024 NTT_1024_element(clk, reset, NTT_IN_wire_2, data_ntt_valid_2,data_ntt_valid_3, NTT_IN_wire_3);

// NTT_128
/*NTT_const_mult #(.STREAM_SIZE(1), 
.PSI(modular_pow(`TWIDDLE_2N, 1, `MODULUS)), 
.OMEGA(modular_pow(`TWIDDLE_2N, 2, `MODULUS)), 
.PRECOMP_FACTOR(`PRECOMP_FACTOR)) 
NTT_128_instance(clk,NTT_IN_wire,data_valid, data_valid_out, NTT_OUT_wire);*/

sample_ntt sample_inst(clk, NTT_IN_wire,data_valid, data_valid_out, NTT_OUT_wire);
// matrix_rectangular_transpose #(.direction("FORWARD")) matrix_3(clk, reset, NTT_IN_wire_3, data_ntt_valid_3,data_valid_out, NTT_OUT_wire);

initial begin
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/SAMPLENTT_IN.txt", NTT_IN);
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/SAMPLENTT_OUT.txt", NTT_OUT);
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

    for(clock_cycle_counter = 0; clock_cycle_counter < `TEST_CLOCK_CYCLES_SAMPLE; clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)+:(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)] = NTT_IN[1*clock_cycle_counter+j];
        end
        #10;
    end
    data_valid = 0;
    for(clock_cycle_counter_2 = 0; clock_cycle_counter_2 < (`ROUNDS_OF_KECCAK - `TEST_CLOCK_CYCLES_SAMPLE); clock_cycle_counter_2=clock_cycle_counter_2+1) begin: CLOCK_CYLE_EXTRA
        /*for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)+:(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)] = NTT_IN[1*clock_cycle_counter_2+j];
        end*/
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)+:(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)] = 64'b0;
        end
        #10;
    end
    data_valid = 1;
    for(clock_cycle_counter_5 = 0; clock_cycle_counter_5 < `TEST_CLOCK_CYCLES_SAMPLE; clock_cycle_counter_5=clock_cycle_counter_5+1) begin: CLOCK_CYLE_EXTRA_5
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)+:(`OUTPUT_WIDTH_CLUSTER_SHAKE_128)] = NTT_IN[1*clock_cycle_counter_5+j];
        end
        #10;
    end
    data_valid = 0;
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

    for(clock_cycle_counter_4 = 0; clock_cycle_counter_4 < `TEST_CLOCK_CYCLES_SAMPLE; clock_cycle_counter_4=clock_cycle_counter_4+1) begin: CLOCK_CYLE_2
        for(k=0; k<(1); k=k+1) begin
            if(NTT_OUT_wire[k*(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)+:(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)] == NTT_OUT[1*clock_cycle_counter_4+k]) begin
            // +: is the same as (k+1)*`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:k*`OUTPUT_WIDTH_CLUSTER_SHAKE_128, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:k*`OUTPUT_WIDTH_CLUSTER_SHAKE_128
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%h -- Calculated:%h, Expected:%h",clock_cycle_counter_4,NTT_OUT_wire[k*(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)+:(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)],NTT_OUT[1*clock_cycle_counter_4+k]);
            end
    
        end
        #10;
    end
    for(clock_cycle_counter_3 = 0; clock_cycle_counter_3 < (`ROUNDS_OF_KECCAK - `TEST_CLOCK_CYCLES_SAMPLE); clock_cycle_counter_3=clock_cycle_counter_3+1) begin: CLOCK_CYLE_WAIT
        
        #10;
    end
    for(clock_cycle_counter_6 = 0; clock_cycle_counter_6 < `TEST_CLOCK_CYCLES_SAMPLE; clock_cycle_counter_6=clock_cycle_counter_6+1) begin: CLOCK_CYLE_WAIT_6
        for(k=0; k<(1); k=k+1) begin
            if(NTT_OUT_wire[k*(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)+:(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)] == NTT_OUT[1*clock_cycle_counter_6+k]) begin
            // +: is the same as (k+1)*`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:k*`OUTPUT_WIDTH_CLUSTER_SHAKE_128, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`OUTPUT_WIDTH_CLUSTER_SHAKE_128-1:k*`OUTPUT_WIDTH_CLUSTER_SHAKE_128
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%h -- Calculated:%h, Expected:%h",clock_cycle_counter_6,NTT_OUT_wire[k*(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)+:(`MODULUS_WIDTH*`NTT_POLYNOMIAL_SIZE)],NTT_OUT[1*clock_cycle_counter_6+k]);
            end
    
        end
        #10;
    end
	if(iterator_a == (2*`TEST_CLOCK_CYCLES_SAMPLE))
		$display("NTT Transform:  Correct");
	else
		$display("NTT Transform:  Incorrect");

	$stop();
    
end

endmodule
