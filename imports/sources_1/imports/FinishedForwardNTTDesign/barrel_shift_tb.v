`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven COSIC
// Engineer: Jonas Bertels
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

module barrel_shift_tb( );

reg  clk;
wire [`COEF_PER_CLOCK_CYCLE*`GOLD_MODULUS_WIDTH-1:0] NTT_IN_wire;
wire [`COEF_PER_CLOCK_CYCLE*`GOLD_MODULUS_WIDTH-1:0] NTT_OUT_wire; //so we can test all outputs
reg [`GOLD_MODULUS_WIDTH-1:0] NTT_IN[0:`COEF_PER_CLOCK_CYCLE-1];
reg data_valid;
wire data_valid_out;
reg [5:0] shift;
always #5 clk=~clk;

barrel_shifter #(.STREAM_SIZE(`COEF_PER_CLOCK_CYCLE)) barrel_instance(clk,NTT_IN_wire, shift, data_valid, data_valid_out, NTT_OUT_wire);

initial begin
	$readmemh("D:/Jonas/Google Drive/KULeuven6/ZPRICE/pythonGeneratorCode/NTT_IN.txt", NTT_IN);
end

generate
    genvar j;
    for(j = 0; j < `COEF_PER_CLOCK_CYCLE; j=j+1) begin: OUTPUT
        assign NTT_IN_wire[(j+1)*`GOLD_MODULUS_WIDTH-1:j*`GOLD_MODULUS_WIDTH] = NTT_IN[j];
    end
endgenerate  

 

integer k;
integer iterator_a;
initial begin: TEST_BUTTERFLY
    clk       = 0;
    data_valid = 0;
    #10;
    data_valid = 1;
    iterator_a = 0;
    shift = 6'd17;
    
    #300
    
    for(k=0; k<(`COEF_PER_CLOCK_CYCLE); k=k+1) begin
		if(NTT_OUT_wire[k*`GOLD_MODULUS_WIDTH+:`GOLD_MODULUS_WIDTH] == NTT_IN[(k-shift)%`COEF_PER_CLOCK_CYCLE]) begin
		// +: is the same as (k+1)*`MODULUS_WIDTH-1:k*`MODULUS_WIDTH, with the added advantage
		// that it actually works, because for some reason it's fine to have non-contant values
		// for this expression and not for k+1)*`MODULUS_WIDTH-1:k*`MODULUS_WIDTH
			iterator_a = iterator_a+1;
		end
		else begin
		    $display("a: Index-%d -- Calculated:%d, Expected:%d",k,NTT_OUT_wire[k*`GOLD_MODULUS_WIDTH+:`GOLD_MODULUS_WIDTH],NTT_IN[(k-shift)%`COEF_PER_CLOCK_CYCLE][`GOLD_MODULUS_WIDTH-1:0]);
		end

	end


	if(iterator_a == (`COEF_PER_CLOCK_CYCLE))
		$display("NTT Transform:  Correct");
	else
		$display("NTT Transform:  Incorrect");

	$stop();
    
end

endmodule
