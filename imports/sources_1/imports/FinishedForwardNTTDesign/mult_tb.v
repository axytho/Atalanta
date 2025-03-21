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

module mult_tb( );

reg clk, reset;
reg [`MODULUS_WIDTH-1:0] input_a, input_b;
wire [40-1:0] output_a;

always #5 clk=~clk;

FINAL_multiplier twiddle_multiplier(.CLK(clk), .A(input_a), .B(input_b), .P(output_a));



integer m;
integer iterator_a, iterator_b;
initial begin: TEST_BUTTERFLY
    clk       = 0;
    #10;
    input_a = 20'd898483;
    input_b = 20'd189842;
    iterator_a = 0;
    iterator_b = 0;
    #30;
    #100;
    if(output_a == 40'd170569809686) begin
        $display("a:  Correct");
    end
    else begin
        $display("a: --Expected :%d, Calculated:%d",128'd170569809686,output_a);
    end



	$stop();
    
end

endmodule
