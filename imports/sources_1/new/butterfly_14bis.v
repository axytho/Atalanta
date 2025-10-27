`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven
// Engineer: Jonas Bertels
// 
// Create Date: 06/27/2022 07:45:14 PM
// Design Name: BASIC NTT
// Module Name: butterfly
// Project Name: ZPRIZE
// Target Devices: Varium C1100
// Tool Versions: Vivado 2020.2
// Description: Basic butterfly unit
// 
// Dependencies: None
// Revision 0.04-- works in simulation
// Revision 0.03 - Fixed shift_rotate problems
// Revision 0.02 - first version, trying to make all shifts work to `MODULUS_WIDTH (so simple CT works)
// Revision 0.01 - File Created
// Additional Comments:


//TODO:
//1) replace by shift_reg if twiddle = 1 DONE
//2) Improve modular add and modular sub to only take 20 LUTS and increase possibillities to range between 0 to 2^20
//3) Replace small shift regs of 4 by 4 FDREs chained (use primitives) (10% improvement)

// 
//////////////////////////////////////////////////////////////////////////////////
`include "parameters.v" 
`include "ntt_params.v"

module butterfly_14bis
#(parameter TWIDDLE = 0, parameter DIRECTION = "FORWARD")
(
    input clk,
    input [`MODULUS_WIDTH-1:0] input_a,
    input [`MODULUS_WIDTH-1:0] input_b,
    output [`MODULUS_WIDTH-1:0] output_a,
    output [`MODULUS_WIDTH-1:0] output_b
    );

reg [`MODULUS_WIDTH+2-1:0] pipeline_a_0;
reg [`MODULUS_WIDTH+2-1:0] pipeline_b_0;
wire [`MODULUS_WIDTH-1:0] pipeline_out_a;
//,pipeline_a_8;
//reg [`MODULUS_WIDTH+2-1:0] pipeline_b_0, pipeline_b_1, pipeline_b_2, pipeline_b_3, pipeline_b_4, pipeline_b_5; 
wire [`MODULUS_WIDTH+2-1:0] add_mod_option0;
wire [`MODULUS_WIDTH+2-1:0] add_mod_option1;
wire [`MODULUS_WIDTH+2-1:0] sub_mod_option0 = pipeline_b_0;
wire [`MODULUS_WIDTH+2-1:0] sub_mod_option1 = pipeline_b_0+`MODULUS;
wire [`MODULUS_WIDTH-1:0] mult_output;

reg [`MODULUS_WIDTH-1:0] out_a, out_b;

assign add_mod_option0 = pipeline_a_0;
assign add_mod_option1 = pipeline_a_0-`MODULUS;
always @(posedge clk) begin
    out_a <= add_mod_option1[`MODULUS_WIDTH+2-1] ? add_mod_option0[`MODULUS_WIDTH-1:0] : add_mod_option1[`MODULUS_WIDTH-1:0];
    out_b <= sub_mod_option0[`MODULUS_WIDTH+2-1] ? sub_mod_option1[`MODULUS_WIDTH-1:0] : sub_mod_option0[`MODULUS_WIDTH-1:0];    
end
generate
if (DIRECTION=="FORWARD") begin
    //if (~(TWIDDLE==`MODULUS-1)) begin
        pearl_of_the_butterfly #(.TWIDDLE(TWIDDLE)) pearl_of_the_butterfly_inst(.clk(clk),.input_a(input_b), .output_product(mult_output));
        assign output_a = out_a;
        assign output_b = out_b;
        shift_reg_width #(.shift(`PEARL_LATENCY), .width(`MODULUS_WIDTH)) delay_input_a (.clk(clk), .data_in(input_a), .data_out(pipeline_out_a));
        always @(posedge clk) begin
            pipeline_a_0 <= {2'b0, pipeline_out_a} + {2'b0,mult_output};
            pipeline_b_0 <= {2'b0, pipeline_out_a} - {2'b0,mult_output};
        end
   /* end else begin //If twiddle = -1, flip the calculation
        pearl_of_the_butterfly #(.TWIDDLE(1)) pearl_of_the_butterfly_inst(.clk(clk),.input_a(input_b), .output_product(mult_output));
        assign output_a = out_a;
        assign output_b = out_b;
        shift_reg_width #(.shift(`PEARL_LATENCY), .width(`MODULUS_WIDTH)) delay_input_a (.clk(clk), .data_in(input_a), .data_out(pipeline_out_a));
        always @(posedge clk) begin
            pipeline_a_0 <= {2'b0, pipeline_out_a} - {2'b0,mult_output};
            pipeline_b_0 <= {2'b0, pipeline_out_a} + {2'b0,mult_output};
        end
    end*/
end else begin
pearl_of_the_butterfly #(.TWIDDLE(TWIDDLE)) pearl_of_the_butterfly_inst(.clk(clk),.input_a(out_b), .output_product(mult_output));
assign output_b = mult_output;
shift_reg_width #(.shift(`PEARL_LATENCY), .width(`MODULUS_WIDTH)) delay_input_a (.clk(clk), .data_in(out_a), .data_out(output_a));
always @(posedge clk) begin
    pipeline_a_0 <= {2'b0, input_a} + {2'b0,input_b};
    pipeline_b_0 <= {2'b0, input_a} - {2'b0,input_b};
end
end
endgenerate
endmodule
