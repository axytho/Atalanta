
//  Xilinx UltraRAM Simple Dual Port.  This code implements 
//  a parameterizable UltraRAM block 1 Read and 1 write. 
//  when addra == addrb, old data will show at doutb 
module URAM_custom #(
  parameter AWIDTH = 12,  // Address Width
  parameter DWIDTH = 72,  // Data Width
  parameter NBPIPE = 3   // Number of pipeline Registers
 ) ( 
    input clk,                    // Clock 
    input wea,                    // Write Enable
    input mem_en,                 // Memory Enable
    input [DWIDTH-1:0] dina,      // Data Input  
    input [AWIDTH-1:0] addra,     // Write Address
    input [AWIDTH-1:0] addrb,     // Read  Address
    output reg [DWIDTH-1:0] doutb // Data Output
   );

(* ram_style = "ultra" *)
reg [DWIDTH-1:0] mem[(1<<AWIDTH)-1:0];        // Memory Declaration
reg [DWIDTH-1:0] memreg;               
reg [DWIDTH-1:0] mem_pipe_reg[NBPIPE-1:0];    // Pipelines for memory
reg mem_en_pipe_reg[NBPIPE:0];                // Pipelines for memory enable  

integer          i;

// RAM : Both READ and WRITE have a latency of one
always @ (posedge clk)
begin
 if(mem_en) 
  begin
   if(wea)
     mem[addra] <= dina;

   memreg <= mem[addrb];
  end
end

// The enable of the RAM goes through a pipeline to produce a
// series of pipelined enable signals required to control the data
// pipeline.
always @ (posedge clk)
begin
 mem_en_pipe_reg[0] <= mem_en;
 for (i=0; i<NBPIPE; i=i+1)
   mem_en_pipe_reg[i+1] <= mem_en_pipe_reg[i];
end

// RAM output data goes through a pipeline.
always @ (posedge clk)
begin
 if (mem_en_pipe_reg[0])
  mem_pipe_reg[0] <= memreg;
end    

always @ (posedge clk)
begin
 for (i = 0; i < NBPIPE-1; i = i+1)
  if (mem_en_pipe_reg[i+1])
   mem_pipe_reg[i+1] <= mem_pipe_reg[i];
end      

always @ (posedge clk)
begin
 if (mem_en_pipe_reg[NBPIPE] )
   doutb <= mem_pipe_reg[NBPIPE-1];
end
endmodule
/* 
// The following is an instantation template for
// xilinx_ultraram_simple_dual_port

   xilinx_ultraram_simple_dual_port # (
                                             .AWIDTH(AWIDTH),
                                             .DWIDTH(DWIDTH),
                                             .NBPIPE(NBPIPE)
                                            )
                      your_instance_name    (
                                             clk(clk),   
                                             wea(wea),    
                                             mem_en(mem_en),
                                             dina(dina), 
                                             addra(addra),
                                             addrb(addrb),
                                             doutb(doutb)
                                            );
*/                                            
					
					