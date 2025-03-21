`timescale 1ns / 1ps

//GENERATE WITH CSA3_GENERATE.PY

module csa3_8_two_negatives(input wire clk, input wire BBUS_IN, input wire cin, input wire [7:0] in_a, input wire [7:0] in_b, input wire [7:0] in_c, output wire [7:0] sum, output wire BBUS7, output wire cout); 

localparam I0_val = 64'haaaaaaaaaaaaaaaa;
localparam I1_val = 64'hcccccccccccccccc;
localparam I2_val = 64'hf0f0f0f0f0f0f0f0;
localparam I3_val = 64'hff00ff00ff00ff00;
localparam I4_val = 64'hffff0000ffff0000;
localparam I5_val = 64'hffffffff00000000;
localparam I2_val_tweaked = ~I2_val; 
localparam I3_val_tweaked = ~I3_val; 
localparam init_val = (I5_val & (I1_val ^ I2_val_tweaked ^ I3_val ^ I4_val)) | (~ I5_val & ((I2_val_tweaked & I3_val) | (I3_val & I1_val) | (I1_val & I2_val_tweaked)));


  wire [7:0] O6;
  wire [7:0] BBUS;
  assign BBUS7 = BBUS[7];
  wire [7:0] CO;
  assign cout = CO[7];

  CARRY8 #(
      .CARRY_TYPE("SINGLE_CY8")  // 8-bit or dual 4-bit carry (DUAL_CY4, SINGLE_CY8)
  )
  CARRY8_inst (
      .CO(CO[7:0]),         // 8-bit output: Carry-out
      .O(sum[7:0]),           // 8-bit output: Carry chain XOR data out
      .CI(cin),         // 1-bit input: Lower Carry-In
      .CI_TOP(1'b0), // 1-bit input: Upper Carry-In
      .DI({BBUS[6:0],BBUS_IN}),         // 8-bit input: Carry-MUX data in
      .S(O6[7:0])            // 8-bit input: Carry-mux select
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_0 (
      .O6(O6[0]), // 1-bit LUT6 output
      .O5(BBUS[0]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[0]), // 1-bit LUT input
      .I2(in_b[0]), // 1-bit LUT input
      .I3(in_a[0]), // 1-bit LUT input
      .I4(BBUS_IN), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_1 (
      .O6(O6[1]), // 1-bit LUT6 output
      .O5(BBUS[1]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[1]), // 1-bit LUT input
      .I2(in_b[1]), // 1-bit LUT input
      .I3(in_a[1]), // 1-bit LUT input
      .I4(BBUS[0]), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_2 (
      .O6(O6[2]), // 1-bit LUT6 output
      .O5(BBUS[2]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[2]), // 1-bit LUT input
      .I2(in_b[2]), // 1-bit LUT input
      .I3(in_a[2]), // 1-bit LUT input
      .I4(BBUS[1]), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_3 (
      .O6(O6[3]), // 1-bit LUT6 output
      .O5(BBUS[3]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[3]), // 1-bit LUT input
      .I2(in_b[3]), // 1-bit LUT input
      .I3(in_a[3]), // 1-bit LUT input
      .I4(BBUS[2]), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_4 (
      .O6(O6[4]), // 1-bit LUT6 output
      .O5(BBUS[4]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[4]), // 1-bit LUT input
      .I2(in_b[4]), // 1-bit LUT input
      .I3(in_a[4]), // 1-bit LUT input
      .I4(BBUS[3]), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_5 (
      .O6(O6[5]), // 1-bit LUT6 output
      .O5(BBUS[5]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[5]), // 1-bit LUT input
      .I2(in_b[5]), // 1-bit LUT input
      .I3(in_a[5]), // 1-bit LUT input
      .I4(BBUS[4]), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_6 (
      .O6(O6[6]), // 1-bit LUT6 output
      .O5(BBUS[6]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[6]), // 1-bit LUT input
      .I2(in_b[6]), // 1-bit LUT input
      .I3(in_a[6]), // 1-bit LUT input
      .I4(BBUS[5]), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  LUT6_2 #(
      .INIT(init_val) // Specify LUT Contents
  ) LUT6_2_inst_7 (
      .O6(O6[7]), // 1-bit LUT6 output
      .O5(BBUS[7]), // 1-bit lower LUT5 output
      .I0(1'bz), // 1-bit LUT input
      .I1(in_c[7]), // 1-bit LUT input
      .I2(in_b[7]), // 1-bit LUT input
      .I3(in_a[7]), // 1-bit LUT input
      .I4(BBUS[6]), // 1-bit LUT input
      .I5(1'b1) // 1-bit LUT input (fast MUX select only available to O6 output)
  );

endmodule
