`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 07:21:10 PM
// Design Name: 
// Module Name: gen_acc
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

module gen_acc(
input clk,
input rst,
input [`LOG_N+1-1:0] data_in,
input data_valid_in,
output data_valid_out, //we're going to use the convention that gen_acc starts running as soon as it has enough information
// and thus that the coefficients should be fed in before the b's
output [`RING_SIZE*`MODULUS_WIDTH-1:0] data_out
    );
    
    
wire [`LOG_N+1-1:0] b_in;    
wire next_acc;
wire [`LOG_N+1-1:0] b_out;

wire [`LOG_N+1-1:0] b_temp; 

assign b_temp = data_in + (`NTT_VECTOR_SIZE>>1);

assign b_in= b_temp;// we interpret b[`LOG_N] ==1 as being sign=-1

reg [`BATCH_DEPTH-1:0] counter_in;
always @(posedge clk) begin
    if (rst) begin
        counter_in <= 0;
    end else if (data_valid_in) begin
        counter_in <= counter_in + 1;
    end else begin
         counter_in <= counter_in;
    end
end

reg start;
reg [`BATCH_DEPTH+(`LOG_N-`RING_DEPTH)-1:0] counter_out;
always @(posedge clk) begin
    if (rst)
        start <= 0;
    else if ((&counter_in) && data_valid_in)
        start <= 1;
    else if (counter_out==`NTT_DIV_BY_RING*`BATCH_SIZE-1) // && start, but because else is start<= start, this doesn't matter
        start <= 0;
    else
        start <= start;
end



assign data_valid_out = start;

always @(posedge clk) begin
        if (rst) begin
        counter_out <= 0;
    end else if (start) begin
        counter_out <= counter_out + 1;
    end else if (counter_out==`NTT_DIV_BY_RING*`BATCH_SIZE-1 && start) begin//technically, this statement is not necessary if ring_size and batch_size are powers of two
        counter_out <= 0;
    end else begin
        counter_out <= counter_out;
    end

end

assign next_acc = &counter_out[(`LOG_N-`RING_DEPTH)-1:0];//shift to the next b

shift_reg_width_CE  #(.shift(`BATCH_SIZE), .width(`LOG_N+1)) coef_storage_space (
  .clk(clk),  // input wire CLK
  .data_in(b_in),      // input wire [9 : 0] D
  .CE(data_valid_in || next_acc),    // choose which shift register to write to
  .data_out(b_out)      // output wire [9 : 0] Q
);
    
// acc = +-modulus/8    
generate
    genvar l;
    wire [`LOG_N+1:0] coefficient [0:`RING_SIZE-1];
    for(l = 0; l < `RING_SIZE; l=l+1) begin: ADD_SUBTACT //the minus one makes it so it goes up to, but not including coef
       assign coefficient[l] =  b_out[`LOG_N-1:0] - (l+`RING_SIZE*counter_out[(`LOG_N-`RING_DEPTH)-1:0]) - 1; 
       assign data_out[l*`MODULUS_WIDTH+:`MODULUS_WIDTH] = (coefficient[l][`LOG_N] ^ b_out[`LOG_N]) ? (`MODULUSEIGHTH) : (`MODULUS - `MODULUSEIGHTH);
    end
endgenerate 



endmodule
