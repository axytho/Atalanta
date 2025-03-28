`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 05:18:43 PM
// Design Name: 
// Module Name: hw_eval_wrapper
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


module hw_eval_wrapper(
    input clk,
    input [`MODULUS_WIDTH-1:0] random_input,
    output [`RING_SIZE>>2-1:0] random_output,
    output data_valid_out_quick
    );
    
//reg [`MODULUS_WIDTH-1:0] counter = 0;
//always @(posedge clk)
//counter <= counter+1;
//end
wire [`RING_SIZE*`MODULUS_WIDTH-1:0] random_output_raw;

reg [`RING_SIZE*`MODULUS_WIDTH-1:0] randomness;
always @(posedge clk) begin
    randomness <= {random_input, randomness[`RING_SIZE*`MODULUS_WIDTH-1:`MODULUS_WIDTH]};
end
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
NTT_const_mult #(.STREAM_SIZE(`RING_SIZE), 
.PSI(modular_pow(`TWIDDLE_2048, 1, `MODULUS)), 
.OMEGA(modular_pow(`TWIDDLE_2048, 2, `MODULUS)), 
.PRECOMP_FACTOR(`PRECOMP_FACTOR)) 
NTT_128_instance(clk,randomness,randomness[0], data_valid_out_quick, random_output_raw);


generate
genvar i;
for (i=0;i<(`RING_SIZE>>2);i=i+1) begin
assign random_output[i] = ^random_output_raw[4*`MODULUS_WIDTH*i+:4*`MODULUS_WIDTH];
end
endgenerate
//pearl_of_the_butterfly #(.TWIDDLE(258853)) inst (.clk(clk), .input_a(random_input), .output_product(output_raw));
//assign random_output = output_raw[4:0] + output_raw[9:5] + output_raw[14:10] + output_raw[19:5];

endmodule