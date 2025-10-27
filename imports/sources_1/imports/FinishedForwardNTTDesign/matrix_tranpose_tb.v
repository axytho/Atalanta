`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven COSIC
// Engineer: Jonas Bertels
// 
// Create Date: 06/28/2022 11:55:54 AM
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

module matrix_tranpose_tb( );

reg  clk, reset;
reg  [(`GOLD_MODULUS_WIDTH+1)-1:0] input_a, input_b;
reg data_valid;
wire data_valid_out;
reg [`RING_SIZE*(`GOLD_MODULUS_WIDTH)-1:0] NTT_IN_wire;
wire [`RING_SIZE*(`GOLD_MODULUS_WIDTH)-1:0] NTT_OUT_wire; //so we can test all outputs
reg [(`GOLD_MODULUS_WIDTH+1)-1:0] output_reg_a [0:`RING_SIZE-1]; 
reg [(`GOLD_MODULUS_WIDTH+1)-1:0] NTT_OUT_reg [0:`RING_SIZE-1]; 
reg [(`GOLD_MODULUS_WIDTH+1)-1:0] NTT_IN[0:`RING_SIZE* `RING_SIZE-1];
reg [(`GOLD_MODULUS_WIDTH+1)-1:0] NTT_OUT [0:`RING_SIZE*`RING_SIZE-1];
always #5 clk=~clk;

matrix_transpose matrix(clk, reset, NTT_IN_wire, data_valid,data_valid_out, NTT_OUT_wire);

initial begin
	$readmemh("D:/Jonas/Google Drive/KULeuven6/ZPRICE/pythonGeneratorCode/matrix_in.txt", NTT_IN);
	$readmemh("D:/Jonas/Google Drive/KULeuven6/ZPRICE/pythonGeneratorCode/matrix_out.txt", NTT_OUT);
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

    for(clock_cycle_counter = 0; clock_cycle_counter < `RING_SIZE; clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE
        for(j = 0; j < `RING_SIZE; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`GOLD_MODULUS_WIDTH)+:(`GOLD_MODULUS_WIDTH)] = NTT_IN[`RING_SIZE*clock_cycle_counter+j];
        end
        #10;
    end
    for(clock_cycle_counter_2 = 0; clock_cycle_counter_2 < `RING_SIZE; clock_cycle_counter_2=clock_cycle_counter_2+1) begin: CLOCK_CYLE_EXTRA
        for(j = 0; j < `RING_SIZE; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`GOLD_MODULUS_WIDTH)+:(`GOLD_MODULUS_WIDTH)] = NTT_IN[`RING_SIZE*clock_cycle_counter_2+j];
        end
        #10;
    end
    for(clock_cycle_counter_5 = 0; clock_cycle_counter_5 < `RING_SIZE; clock_cycle_counter_5=clock_cycle_counter_5+1) begin: CLOCK_CYLE_EXTRA_5
        for(j = 0; j < `RING_SIZE; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`GOLD_MODULUS_WIDTH)+:(`GOLD_MODULUS_WIDTH)] = NTT_IN[`RING_SIZE*clock_cycle_counter_5+j];
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
    for(clock_cycle_counter_3 = 0; clock_cycle_counter_3 < `RING_SIZE; clock_cycle_counter_3=clock_cycle_counter_3+1) begin: CLOCK_CYLE_WAIT
        #10;
    end
    for(clock_cycle_counter_6 = 0; clock_cycle_counter_6 < `RING_SIZE; clock_cycle_counter_6=clock_cycle_counter_6+1) begin: CLOCK_CYLE_WAIT_6
        #10;
    end
    for(clock_cycle_counter_4 = 0; clock_cycle_counter_4 < `RING_SIZE; clock_cycle_counter_4=clock_cycle_counter_4+1) begin: CLOCK_CYLE_2
        for(k=0; k<(`RING_SIZE); k=k+1) begin
            if(NTT_OUT_wire[k*(`GOLD_MODULUS_WIDTH)+:(`GOLD_MODULUS_WIDTH)] == NTT_OUT[`RING_SIZE*clock_cycle_counter_4+k]) begin
            // +: is the same as (k+1)*`MODULUS_WIDTH-1:k*`MODULUS_WIDTH, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`MODULUS_WIDTH-1:k*`MODULUS_WIDTH
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%d -- Calculated:%d, Expected:%d",k,NTT_OUT_wire[k*(`GOLD_MODULUS_WIDTH)+:(`GOLD_MODULUS_WIDTH)],NTT_OUT[`RING_SIZE*clock_cycle_counter_4+k]);
            end
    
        end
        #10;
    end
	if(iterator_a == (`RING_SIZE*`RING_SIZE))
		$display("NTT Transform:  Correct");
	else
		$display("NTT Transform:  Incorrect");

	$stop();
    
end

endmodule
