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

module butterfly_test( );
`define TESTBENCH_SIZE  16
reg clk, reset;
localparam STAGE = 1;
reg [`MODULUS_WIDTH+$clog2(1+(STAGE)*5)-1:0] input_a;
reg [`MODULUS_WIDTH+5-1:0] input_b;
reg [`MODULUS_WIDTH-1:0] input_a_python [0:`TESTBENCH_SIZE*1-1];
reg [`MODULUS_WIDTH-1:0] input_b_python [0:`TESTBENCH_SIZE*1-1];
wire [`MODULUS_WIDTH+$clog2(1+(STAGE+1)*5)-1:0] output_a [0:(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)-1];
wire [`MODULUS_WIDTH+$clog2(1+(STAGE+1)*5)-1:0] output_b [0:(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)-1]; //so we can test all outputs
reg [`MODULUS_WIDTH-1:0] input_and_output_a_reg[0:`TESTBENCH_SIZE*(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)-1];
reg [`MODULUS_WIDTH-1:0] input_and_output_b_reg[0:`TESTBENCH_SIZE*(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)-1];
reg [2*`MODULUS_WIDTH-1:0] K_inverse = 524289;
function [`MODULUS_WIDTH-1:0] modular_pow;
 input [2*`MODULUS_WIDTH-1:0] base;
 input [`MODULUS_WIDTH-1:0] modulus, exponent;
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
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [2*`MODULUS_WIDTH-1:0] input1;
 input [2*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction
    
    
always #5 clk=~clk;
generate
    genvar i;
    for(i = 0; i < (`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1); i=i+1) begin: BUTTERFLIES

		                    //butterfly #(.TWIDDLE((524289*(146569**(i)))%`MODULUS)) 
	butterfly_jewel #(.TWIDDLE(modular_mult(1,modular_pow(146569,`MODULUS, i),`MODULUS)), .DIRECTION("FORWARD"), .STAGE(STAGE))
                    butterfly0(.clk(clk),
                    .input_a(input_a), 
                    .input_b(input_b), 
                    .output_a(output_a[i]),
                    .output_b(output_b[i]));
    end
endgenerate

initial begin
    $readmemh("D:/Jonas/Google Drive/KULeuven6/ZPRICE/pythonGeneratorCode/Quinten/input_a.txt", input_a_python);
    $readmemh("D:/Jonas/Google Drive/KULeuven6/ZPRICE/pythonGeneratorCode/Quinten/input_b.txt", input_b_python);
	$readmemh("D:/Jonas/Google Drive/KULeuven6/ZPRICE/pythonGeneratorCode/Quinten/result_a.txt", input_and_output_a_reg);
	$readmemh("D:/Jonas/Google Drive/KULeuven6/ZPRICE/pythonGeneratorCode/Quinten/result_b.txt", input_and_output_b_reg);
end
integer m, test_bench;
integer iterator_a, iterator_b;
initial begin: TEST_BUTTERFLY
    clk       = 0;
    #10;
    
    iterator_a = 0;
    iterator_b = 0;
    #100
    for(test_bench=0; test_bench<(`TESTBENCH_SIZE); test_bench=test_bench+1) begin
        input_a = input_a_python[test_bench];
        input_b = input_b_python[test_bench];
        #30; //(1+BUTTERFLY_LATENCY)
        for(m=0; m<((`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)); m=m+1) begin
            if(input_and_output_a_reg[test_bench*(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)+m] == output_a[m]%`MODULUS) begin
                iterator_a = iterator_a+1;
            end
            else begin
                $display("a: Testbench: %d Index-%d --Expected :%d, Calculated:%d",test_bench, m,input_and_output_a_reg[test_bench*(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)+m],output_a[m]%`MODULUS);
            end
            if(input_and_output_b_reg[test_bench*(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)+m]== output_b[m]%`MODULUS) begin
                iterator_b = iterator_b+1;
            end
            else begin
                $display("b: Testbench: %d Index-%d -- Expected :%d, Calculated:%d",test_bench, m,input_and_output_b_reg[test_bench*(`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)+m],output_b[m]%`MODULUS);
            end
        end
        #100;
    end

	if(iterator_a == ((`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)*`TESTBENCH_SIZE))
		$display("a:  Correct");
	else
		$display("a:  Incorrect");

	if(iterator_b == ((`COEF_PER_CLOCK_CYCLE_BAILEY_NTT>>1)*`TESTBENCH_SIZE))
		$display("b:  Correct");
	else
		$display("b:  Incorrect");

	$stop();
    
end

endmodule
