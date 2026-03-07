`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2022 11:55:54 AM
// Design Name: 
// Module Name: butterfly_test
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

module mult_mod_tb( );
localparam EXTRA_BIT = 1;
reg clk, reset;
reg [`MODULUS_WIDTH*2+EXTRA_BIT-1:0] input_a;
wire [`MODULUS_WIDTH-1:0]  output_a;

always #5 clk=~clk;
// THIS TESTBENCH DOES NOT WORK: USE BUTTERFLY TEST INSTEAD AND EAT YOUR VEGGIES.
//modular_multiplier modular_multiplier(.clk(clk),.input_a(input_a), .input_b(input_b), .output_product(output_a));
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [4*`MODULUS_WIDTH-1:0] input1;
 input [4*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction

reduction #(.EXTRA_INPUT_BIT(EXTRA_BIT)) reduction_0(.clk(clk), .data_in(input_a), .data_out(output_a));


integer clock_cycle_counter, clock_cycle_counter_4,m;
integer iterator_a, iterator_b;
// THIS TESTBENCH DOES NOT WORK: USE BUTTERFLY TEST INSTEAD AND EAT YOUR VEGGIES.
initial begin: TEST_BUTTERFLY
    clk       = 0;
    #10;
    input_a = (1<<25-1)-(5*`MODULUS);
    //input_b = 20'd1;
    iterator_a = 0;
    iterator_b = 0;
    #40;
    for(clock_cycle_counter = 0; clock_cycle_counter < (1<<(`MODULUS_WIDTH)); clock_cycle_counter=clock_cycle_counter+1) begin: CLOCK_CYLE
        input_a = input_a+1;
        #10;
    end
    input_a = input_a+1;
    #100;
end
initial begin: CHECK_FOR_OUTPUT
    #70;
    clock_cycle_counter_4 = 0;
    for(clock_cycle_counter_4 = 0; clock_cycle_counter_4 < (1<<(`MODULUS_WIDTH)); clock_cycle_counter_4=clock_cycle_counter_4+1) begin: CLOCK_CYLE_2
            if(output_a%`MODULUS == modular_mult((input_a-1),3316,`MODULUS)) begin

                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Index-%d -- Calculated:%d, Expected:%d",clock_cycle_counter_4,output_a%`MODULUS,modular_mult((input_a-1),3316,`MODULUS));
            end
    
        #10;
    end

    if(iterator_a == 1<<(`MODULUS_WIDTH))
		$display("Modular reduction:  Correct");
	else
		$display("Modular reduction:  Incorrect");

	$stop();
    
end

endmodule
