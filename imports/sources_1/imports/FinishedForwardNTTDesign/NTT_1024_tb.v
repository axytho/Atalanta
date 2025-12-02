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

module NTT_1024_tb( );

reg  clk, reset;
reg  [(`MODULUS_WIDTH+1)-1:0] input_a, input_b;
reg data_valid;
wire data_valid_out, data_ntt_valid_2, data_ntt_valid_3;
reg [`COEF_PER_CLOCK_CYCLE*(`MODULUS_WIDTH)-1:0] NTT_IN_wire;
wire [`COEF_PER_CLOCK_CYCLE*(`MODULUS_WIDTH)-1:0] NTT_OUT_wire,  NTT_IN_wire_2, NTT_IN_wire_3; //so we can test all outputs
reg [(`MODULUS_WIDTH+1)-1:0] output_reg_a [0:`COEF_PER_CLOCK_CYCLE-1]; 
reg [(`MODULUS_WIDTH+1)-1:0] NTT_OUT_reg [0:`COEF_PER_CLOCK_CYCLE-1]; 
reg [(`MODULUS_WIDTH+1)-1:0] NTT_IN[0:`COEF_PER_CLOCK_CYCLE* `NTT_DIV_BY_RING-1];
reg [(`MODULUS_WIDTH+1)-1:0] NTT_OUT [0:`COEF_PER_CLOCK_CYCLE*`NTT_DIV_BY_RING-1];
always #5 clk=~clk;



//matrix_rectangular_transpose #(.direction("FORWARD")) matrix_1(clk, reset, NTT_IN_wire, data_valid,data_ntt_valid_2, NTT_IN_wire_2);

//NTT_1024 NTT_1024_element(clk, reset, NTT_IN_wire_2, data_ntt_valid_2,data_ntt_valid_3, NTT_IN_wire_3);
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
// NTT_128
/*NTT_const_mult #(.STREAM_SIZE(`COEF_PER_CLOCK_CYCLE), 
.PSI(modular_pow(`TWIDDLE_2N, 1, `MODULUS)), 
.OMEGA(modular_pow(`TWIDDLE_2N, 2, `MODULUS)), 
.PRECOMP_FACTOR(`PRECOMP_FACTOR)) 
NTT_128_instance(clk,NTT_IN_wire,data_valid, data_valid_out, NTT_OUT_wire);*/

NTT_incomplete NTT_128_instance(clk,reset, NTT_IN_wire,data_valid, data_valid_out, NTT_OUT_wire);
// matrix_rectangular_transpose #(.direction("FORWARD")) matrix_3(clk, reset, NTT_IN_wire_3, data_ntt_valid_3,data_valid_out, NTT_OUT_wire);

initial begin
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/NTT_IN_256.txt", NTT_IN);
	$readmemh("D:/Jonas/Google Drive/KULeuven8/ACompendiumOfButterflies/PythonChasingButterflies/NTT_OUT_256.txt", NTT_OUT);
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

    for(clock_cycle_counter = 0; clock_cycle_counter < `NTT_DIV_BY_RING; clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE
        for(j = 0; j < `COEF_PER_CLOCK_CYCLE; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`MODULUS_WIDTH)+:(`MODULUS_WIDTH)] = NTT_IN[`COEF_PER_CLOCK_CYCLE*clock_cycle_counter+j];
        end
        #10;
    end
    for(clock_cycle_counter_2 = 0; clock_cycle_counter_2 < `NTT_DIV_BY_RING; clock_cycle_counter_2=clock_cycle_counter_2+1) begin: CLOCK_CYLE_EXTRA
        /*for(j = 0; j < `COEF_PER_CLOCK_CYCLE; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`MODULUS_WIDTH)+:(`MODULUS_WIDTH)] = NTT_IN[`COEF_PER_CLOCK_CYCLE*clock_cycle_counter_2+j];
        end*/
        for(j = 0; j < `COEF_PER_CLOCK_CYCLE; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`MODULUS_WIDTH)+:(`MODULUS_WIDTH)] = 64'b0;
        end
        #10;
    end
    data_valid = 1;
    for(clock_cycle_counter_5 = 0; clock_cycle_counter_5 < `NTT_DIV_BY_RING; clock_cycle_counter_5=clock_cycle_counter_5+1) begin: CLOCK_CYLE_EXTRA_5
        for(j = 0; j < `COEF_PER_CLOCK_CYCLE; j=j+1) begin: OUTPUT
            NTT_IN_wire[j*(`MODULUS_WIDTH)+:(`MODULUS_WIDTH)] = NTT_IN[`COEF_PER_CLOCK_CYCLE*clock_cycle_counter_5+j];
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

    for(clock_cycle_counter_4 = 0; clock_cycle_counter_4 < `NTT_DIV_BY_RING; clock_cycle_counter_4=clock_cycle_counter_4+1) begin: CLOCK_CYLE_2
        for(k=0; k<(`COEF_PER_CLOCK_CYCLE); k=k+1) begin
            if(NTT_OUT_wire[k*(`MODULUS_WIDTH)+:(`MODULUS_WIDTH)] == NTT_OUT[`COEF_PER_CLOCK_CYCLE*clock_cycle_counter_4+k]) begin
            // +: is the same as (k+1)*`MODULUS_WIDTH-1:k*`MODULUS_WIDTH, with the added advantage
            // that it actually works, because for some reason it's fine to have non-contant values
            // for this expression and not for k+1)*`MODULUS_WIDTH-1:k*`MODULUS_WIDTH
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%d -- Calculated:%d, Expected:%d",k,NTT_OUT_wire[k*(`MODULUS_WIDTH)+:(`MODULUS_WIDTH)],NTT_OUT[`COEF_PER_CLOCK_CYCLE*clock_cycle_counter_4+k]);
            end
    
        end
        #10;
    end
    for(clock_cycle_counter_3 = 0; clock_cycle_counter_3 < `NTT_DIV_BY_RING; clock_cycle_counter_3=clock_cycle_counter_3+1) begin: CLOCK_CYLE_WAIT
        
        #10;
    end
    for(clock_cycle_counter_6 = 0; clock_cycle_counter_6 < `NTT_DIV_BY_RING; clock_cycle_counter_6=clock_cycle_counter_6+1) begin: CLOCK_CYLE_WAIT_6
        #10;
    end
	if(iterator_a == (`COEF_PER_CLOCK_CYCLE*`NTT_DIV_BY_RING))
		$display("NTT Transform:  Correct");
	else
		$display("NTT Transform:  Incorrect");

	$stop();
    
end

endmodule
