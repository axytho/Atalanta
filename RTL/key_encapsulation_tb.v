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

module key_encapsulation_tb( );

reg  clk, reset;
reg  [(`MODULUS_WIDTH+1)-1:0] input_a, input_b;
reg data_valid;
wire data_valid_out, data_ntt_valid_2, data_ntt_valid_3;
reg [1*(`INPUT_WIDTH_CLUSTER_PK)-1:0] NTT_IN_wire;
wire [1*(`INPUT_WIDTH_CLUSTER_PK)-1:0] NTT_IN_wire_2, NTT_IN_wire_3; //so we can test all outputs
wire [1*(`K_WIDTH)-1:0] KYBER_K_OUT_wire; //so we can test all outputs
wire [1*(`CIPHERTEXT_WIDTH)-1:0] ciphertext; //so we can test all outputs
reg [(`INPUT_WIDTH_CLUSTER_PK+1)-1:0] output_reg_a [0:1-1]; 
reg [(`INPUT_WIDTH_CLUSTER_PK+1)-1:0] KYBER_K_OUT_reg [0:1-1]; 
reg [(`INPUT_WIDTH_CLUSTER_PK)-1:0] NTT_IN[0:1* `TEST_CLOCK_CYCLES_ONE_THIRD-1];
reg [(`K_WIDTH)-1:0] KYBER_K_OUT [0:1*`ONE_THIRD_KECCAK-1];
reg [(`CIPHERTEXT_WIDTH)-1:0] KYBER_CT2_OUT [0:1*`ONE_THIRD_KECCAK-1];
wire [(`CIPHERTEXT_WIDTH)-1:0] KYBER_CT2_OUT_wire;

always #5 clk=~clk;



//matrix_rectangular_transpose #(.direction("FORWARD")) matrix_1(clk, reset, NTT_IN_wire, data_valid,data_ntt_valid_2, NTT_IN_wire_2);

//NTT_1024 NTT_1024_element(clk, reset, NTT_IN_wire_2, data_ntt_valid_2,data_ntt_valid_3, NTT_IN_wire_3);

// NTT_128
/*NTT_const_mult #(.STREAM_SIZE(1), 
.PSI(modular_pow(`TWIDDLE_2N, 1, `MODULUS)), 
.OMEGA(modular_pow(`TWIDDLE_2N, 2, `MODULUS)), 
.PRECOMP_FACTOR(`PRECOMP_FACTOR)) 
NTT_128_instance(clk,NTT_IN_wire,data_valid, data_valid_out, KYBER_K_OUT_wire);*/

key_encapsulation keyencap(clk,reset, 256'b0, NTT_IN_wire,data_valid, KYBER_K_OUT_wire, KYBER_CT2_OUT_wire, data_valid_out);
// matrix_rectangular_transpose #(.direction("FORWARD")) matrix_3(clk, reset, NTT_IN_wire_3, data_ntt_valid_3,data_valid_out, KYBER_K_OUT_wire);

initial begin
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/KYBER_IN.txt", NTT_IN);
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/KYBER_K_OUT.txt", KYBER_K_OUT);
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/KYBER_CT2_OUT.txt", KYBER_CT2_OUT);

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

    for(clock_cycle_counter = 0; clock_cycle_counter < `TEST_CLOCK_CYCLES_ONE_THIRD; clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`INPUT_WIDTH_CLUSTER_PK)+:(`INPUT_WIDTH_CLUSTER_PK)] = NTT_IN[1*clock_cycle_counter+j];
        end
        #10;
    end
    data_valid = 0;
    for(clock_cycle_counter_2 = 0; clock_cycle_counter_2 < (`ROUNDS_OF_KECCAK - `TEST_CLOCK_CYCLES_ONE_THIRD); clock_cycle_counter_2=clock_cycle_counter_2+1) begin: CLOCK_CYLE_EXTRA
        /*for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`INPUT_WIDTH_CLUSTER_PK)+:(`INPUT_WIDTH_CLUSTER_PK)] = NTT_IN[1*clock_cycle_counter_2+j];
        end*/
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`INPUT_WIDTH_CLUSTER_PK)+:(`INPUT_WIDTH_CLUSTER_PK)] = 64'b0;
        end
        #10;
    end
    data_valid = 1;
    for(clock_cycle_counter_5 = 0; clock_cycle_counter_5 < `TEST_CLOCK_CYCLES_ONE_THIRD; clock_cycle_counter_5=clock_cycle_counter_5+1) begin: CLOCK_CYLE_EXTRA_5
        for(j = 0; j < 1; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`INPUT_WIDTH_CLUSTER_PK)+:(`INPUT_WIDTH_CLUSTER_PK)] = NTT_IN[1*clock_cycle_counter_5+j];
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

    for(clock_cycle_counter_4 = 0; clock_cycle_counter_4 < `ONE_THIRD_KECCAK; clock_cycle_counter_4=clock_cycle_counter_4+1) begin: CLOCK_CYLE_2
        for(k=0; k<(1); k=k+1) begin
            if(KYBER_K_OUT_wire[k*(`K_WIDTH)+:(`K_WIDTH)] == KYBER_K_OUT[1*clock_cycle_counter_4+k]) begin
            // +: is the same as (k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%d -- Calculated:%d, Expected:%d",clock_cycle_counter_4,KYBER_K_OUT_wire[k*(`K_WIDTH)+:(`K_WIDTH)],KYBER_K_OUT[1*clock_cycle_counter_4+k]);
            end
            if(KYBER_CT2_OUT_wire[(0)+k*(`CIPHERTEXT_WIDTH)+:(`CIPHERTEXT_WIDTH)] == KYBER_CT2_OUT[1*clock_cycle_counter_4+k]) begin
            // +: is the same as (k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK
                iterator_a = iterator_a+1;
            end
            else begin
                $display("ct2: Index-%h -- Calculated:%h, Expected:%h",clock_cycle_counter_4,KYBER_CT2_OUT_wire[(0)+k*(`CIPHERTEXT_WIDTH)+:(`CIPHERTEXT_WIDTH)],KYBER_CT2_OUT[1*clock_cycle_counter_4+k]);
            end
        end
        #10;
    end
    for(clock_cycle_counter_3 = 0; clock_cycle_counter_3 < (`ROUNDS_OF_KECCAK - `ONE_THIRD_KECCAK); clock_cycle_counter_3=clock_cycle_counter_3+1) begin: CLOCK_CYLE_WAIT
        
        #10;
    end
    for(clock_cycle_counter_6 = 0; clock_cycle_counter_6 < `ONE_THIRD_KECCAK; clock_cycle_counter_6=clock_cycle_counter_6+1) begin: CLOCK_CYLE_WAIT_6
        for(k=0; k<(1); k=k+1) begin
            if(KYBER_K_OUT_wire[k*(`K_WIDTH)+:(`K_WIDTH)] == KYBER_K_OUT[1*clock_cycle_counter_6+k]) begin
            // +: is the same as (k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%d -- Calculated:%d, Expected:%d",clock_cycle_counter_6,KYBER_K_OUT_wire[k*(`K_WIDTH)+:(`K_WIDTH)],KYBER_K_OUT[1*clock_cycle_counter_6+k]);
            end
            if(KYBER_CT2_OUT_wire[(0)+k*(`CIPHERTEXT_WIDTH)+:(`CIPHERTEXT_WIDTH)] == KYBER_CT2_OUT[1*clock_cycle_counter_6+k]) begin
            // +: is the same as (k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`INPUT_WIDTH_CLUSTER_PK-1:k*`INPUT_WIDTH_CLUSTER_PK
                iterator_a = iterator_a+1;
            end
            else begin
                $display("ct2: Index-%h -- Calculated:%h, Expected:%h",clock_cycle_counter_6,KYBER_CT2_OUT_wire[(0)+k*(`CIPHERTEXT_WIDTH)+:(`CIPHERTEXT_WIDTH)],KYBER_CT2_OUT[1*clock_cycle_counter_6+k]);
            end
    
        end
        #10;
    end
	if(iterator_a == (4*`ONE_THIRD_KECCAK))
		$display("NTT Transform:  Correct");
	else
		$display("NTT Transform:  Incorrect");

	$stop();
    
end

endmodule
