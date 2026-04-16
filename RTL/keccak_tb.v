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

module keccak_tb( );

reg clk, reset;
reg [16-1:0] input_b;
wire [40-1:0] output_a;

always #5 clk=~clk;

hw_eval_keccak keccak(.clk(clk), .reset(reset), .in_init(input_b), .out(output_a));



integer m;
integer iterator_a, iterator_b;
initial begin: TEST_BUTTERFLY
    clk       = 0;
    reset=1;
    #10;
    reset=0;
    input_b = 16'h9842;
    iterator_a = 0;
    iterator_b = 0;
    #260;
    if(output_a == 16'h9686) begin
        $display("a:  Correct");
    end
    else begin
        $display("a: --Expected :%d, Calculated:%d",16'h9686,output_a);
    end



	$stop();
    
end

endmodule
