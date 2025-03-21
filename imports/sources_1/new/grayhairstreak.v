`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2025 09:37:44 AM
// Design Name: 
// Module Name: grayhairstreak
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


module grayhairstreak
#(parameter TWIDDLE = 0)
(
input clk,
input [`MODULUS_WIDTH+5-1:0] mult_input,
output [`MODULUS_WIDTH+1-1:0] mult_output_0,
output [`MODULUS_WIDTH+1-1:0] mult_output_1,
output [`MODULUS_WIDTH-1:0] mult_output_2
    );
function [`MODULUS_WIDTH-1:0] modular_mult;
 input [2*`MODULUS_WIDTH-1:0] input1;
 input [2*`MODULUS_WIDTH-1:0] input2;
 input [`MODULUS_WIDTH-1:0] modulus;
 begin

     modular_mult = (input1 * input2) % modulus;
 end
endfunction    
    
    
function [63:0] LUT_parameter;
 input [4:0] LUT_index_output_0;
 input [4:0] LUT_index_output_1;
 input [2:0] part;
 integer i_iterator;
 integer full_output;
 begin
    for (i_iterator=0; i_iterator<32; i_iterator=i_iterator+1) begin
        full_output = modular_mult((i_iterator << (part*5))%`MODULUS, TWIDDLE, `MODULUS);
        //full_output = 0;
        LUT_parameter[i_iterator] = full_output[LUT_index_output_0];
        LUT_parameter[32+i_iterator] = full_output[LUT_index_output_1];
    end
 end
endfunction    
    
wire [`MODULUS_WIDTH-1:0] LUT_out [`SECTIONS-2:0];
wire [`MODULUS_WIDTH-1:0] LUT_out_LAST [1:0];

wire [`MODULUS_WIDTH-1:0] CO [1:0];
wire [8-1:0] last_output_rounded_CO [1:0];
wire [8-1:0] last_output_rounded_O [1:0];

wire [`MODULUS_WIDTH+1-1:0] sum [1:0];


function [63:0] LUT_parameter_add_one_bit;
 input [4:0] LUT_index_output_0;
 input [2:0] part;
 integer i_iterator_add_one;
 integer full_output_add_one;
 begin
    for (i_iterator_add_one=0; i_iterator_add_one<64; i_iterator_add_one=i_iterator_add_one+1) begin
        full_output_add_one = modular_mult((i_iterator_add_one[4:0] << (part*5))%`MODULUS, TWIDDLE, `MODULUS);
        //full_output = 0;
        LUT_parameter_add_one_bit[i_iterator_add_one] = i_iterator_add_one[5] ^ full_output_add_one[LUT_index_output_0];
    end
 end
endfunction        

    
generate
genvar i;
genvar j;
for (j=0; j<`SECTIONS-1; j=j+1) begin: MULTIPLE_SECTIONS_DIVINDING_INPUT
    for (i=0; i<`MODULUS_WIDTH>>1; i=i+1) begin: LUTS_0
      LUT6_2 #(
     .INIT(LUT_parameter((i<<1),(i<<1)+1,j))  // Specify LUT Contents
      ) LUT6_inst (   // LUT general output
      .O6(LUT_out[j][(i<<1)+1]), // 1-bit LUT6 output
      .O5(LUT_out[j][(i<<1)]), // 1-bit lower LUT5 output
         .I0(mult_input[5*j+0]), // LUT input
         .I1(mult_input[5*j+1]), // LUT input
         .I2(mult_input[5*j+2]), // LUT input
         .I3(mult_input[5*j+3]), // LUT input
         .I4(mult_input[5*j+4]), // LUT input
         .I5(1'b1)  // LUT input
      );
      end
     
  end
 //special lazy reduction: we need to deal with a 5th element, and choose to do it with maximum efficientcy
 for (j=0; j<2; j=j+1) begin: LAST_TWO_ADDs
    for (i=0; i<`MODULUS_WIDTH; i=i+1) begin: LUTS_END
          LUT6 #(
         .INIT(LUT_parameter_add_one_bit(i,`SECTIONS-1+j))  // Specify LUT Contents
          ) LUT6_inst (   // LUT general output
              .O(LUT_out_LAST[j][i]), // 1-bit LUT6 output
             .I0(mult_input[(`SECTIONS-1+j)*5]), // LUT input
             .I1(mult_input[(`SECTIONS-1+j)*5+1]), // LUT input
             .I2(mult_input[(`SECTIONS-1+j)*5+2]), // LUT input
             .I3(mult_input[(`SECTIONS-1+j)*5+3]), // LUT input
             .I4(mult_input[(`SECTIONS-1+j)*5+4]), // LUT input
             .I5(LUT_out[1+j][i])  // LUT input
          );
      end
      // One day, parametrize this
 CARRY8 #(
      .CARRY_TYPE("SINGLE_CY8")  // 8-bit or dual 4-bit carry (DUAL_CY4, SINGLE_CY8)
  )
  CARRY8_inst_0_to_7 (
      .CO(CO[j][7:0]),         // 8-bit output: Carry-out
      .O(sum[j][7:0]),           // 8-bit output: Carry chain XOR data out
      .CI(1'b0),         // 1-bit input: Lower Carry-In
      .CI_TOP(1'b0), // 1-bit input: Upper Carry-In
      .DI(LUT_out[1+j][7:0]),         // 8-bit input: Carry-MUX data in
      .S(LUT_out_LAST[j][7:0])            // 8-bit input: Carry-mux select
  );
   CARRY8 #(
      .CARRY_TYPE("SINGLE_CY8")  // 8-bit or dual 4-bit carry (DUAL_CY4, SINGLE_CY8)
  )
  CARRY8_inst_8_to_15 (
      .CO(CO[j][15:8]),         // 8-bit output: Carry-out
      .O(sum[j][15:8]),           // 8-bit output: Carry chain XOR data out
      .CI(CO[j][7]),         // 1-bit input: Lower Carry-In
      .CI_TOP(1'b0), // 1-bit input: Upper Carry-In
      .DI(LUT_out[1+j][15:8]),         // 8-bit input: Carry-MUX data in
      .S(LUT_out_LAST[j][15:8])            // 8-bit input: Carry-mux select
  );
   CARRY8 #(
      .CARRY_TYPE("SINGLE_CY8")  // 8-bit or dual 4-bit carry (DUAL_CY4, SINGLE_CY8)
  )
    CARRY8_inst_16_to_19 (
      .CO(last_output_rounded_CO[j]),         // 8-bit output: Carry-out
      .O(last_output_rounded_O[j]),           // 8-bit output: Carry chain XOR data out
      .CI(CO[j][15]),         // 1-bit input: Lower Carry-In
      .CI_TOP(1'bx), // 1-bit input: Upper Carry-In
      .DI({4'bx,LUT_out[1+j][19:16]}),         // 8-bit input: Carry-MUX data in
      .S({4'bx,LUT_out_LAST[j][19:16]})            // 8-bit input: Carry-mux select
  );
    assign sum[j][`MODULUS_WIDTH] = CO[j][`MODULUS_WIDTH-1];
    assign CO[j][19:16] = last_output_rounded_CO[j][3:0];
    assign sum[j][19:16] = last_output_rounded_O[j][3:0];
end
endgenerate

  


  //TODO: add sum_carried + c_ouput <<1 plus whatever is left using ternary adder after saving both in register.
reg [`MODULUS_WIDTH+1-1:0] output_0;
reg [`MODULUS_WIDTH+1-1:0] output_1;
reg [`MODULUS_WIDTH-1:0] output_2;
always @(posedge clk) begin
    output_0 <= sum[0];
    output_1 <= sum[1];
    output_2 <= LUT_out[0];
end

assign mult_output_0 =output_0;
assign mult_output_1 =output_1;
assign mult_output_2 =output_2;

endmodule
