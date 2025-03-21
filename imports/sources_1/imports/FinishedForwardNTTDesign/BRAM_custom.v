`timescale 1 ns / 1 ps
//  Xilinx Simple Dual Port Single Clock RAM
//  This code implements a parameterizable SDP single clock memory.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

module BRAM_custom #(
  parameter RAM_WIDTH = 64,                       // Specify RAM data width
  parameter RAM_DEPTH = 512,                      // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
  input clka,                          // Clock
  input [clogb2(RAM_DEPTH-1)-1:0] addra, // Write address bus, width determined from RAM_DEPTH
  input [clogb2(RAM_DEPTH-1)-1:0] addrb, // Read address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,          // RAM input data
  input wea,                           // Write enable
  output [RAM_WIDTH-1:0] doutb         // RAM output data
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data;

  // The following code either initializes the memory values to all zeros to match hardware

  integer ram_index;
  initial begin
    for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1) begin: LOOP
      BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
 end

  always @(posedge clka) begin
    if (wea) begin
      BRAM[addra] <= dina;
    end
  end
always @(posedge clka) begin
   ram_data <= BRAM[addrb];
end
  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)


      // The following is a 2 clock cycle read latency with improve clock-to-out timing

reg [RAM_WIDTH-1:0] doutb_reg;

always @(posedge clka) begin
  doutb_reg <= ram_data; //one statement is allowed
end
assign doutb = doutb_reg;

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

// The following is an instantiation template for xilinx_simple_dual_port_1_clock_ram
/*
//  Xilinx Simple Dual Port Single Clock RAM
  xilinx_simple_dual_port_1_clock_ram #(
    .RAM_WIDTH(18),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .addra(addra),   // Write address bus, width determined from RAM_DEPTH
    .addrb(addrb),   // Read address bus, width determined from RAM_DEPTH
    .dina(dina),     // RAM input data, width determined from RAM_WIDTH
    .clka(clka),     // Clock
    .wea(wea),       // Write enable
    .enb(enb),	     // Read Enable, for additional power savings, disable when not in use
    .rstb(rstb),     // Output reset (does not affect memory contents)
    .regceb(regceb), // Output register enable
    .doutb(doutb)    // RAM output data, width determined from RAM_WIDTH
  );
*/
						
						