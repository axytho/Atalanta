`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU LEUVEN COSIC
// Engineer: Jonas Bertels
// 
// Keccak round
// 
//////////////////////////////////////////////////////////////////////////////////

`include "parameters.v" 
`include "ntt_params.v"
module keccak_f #(BURST_SIZE=`BURST_SIZE) (
//module keccak_f #(parameter RATE=1088)(
    input clk,
    input rst,
    input [`KECCAK_WIDTH-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`KECCAK_WIDTH-1:0] data_out
    );


generate
genvar i;
wire [`KECCAK_WIDTH-1:0] internal_wiring [0:BURST_SIZE+1-1];
reg [`KECCAK_WIDTH-1:0] internal_wiring_reg [0:BURST_SIZE-1];

if (`COEF_PER_CLOCK_CYCLE == `NTT_POLYNOMIAL_SIZE) begin
///////////////////////////////////////////////////////////////////////////////////
// SPECIAL CASE IF FULLY UNROLLED
///////////////////////////////////////////////////////////////////////////////////
keccak_wrapper keccak_inst_0 (internal_wiring[0],round_constant_signal_out(0) ,internal_wiring[1]);
shift_reg_data_valid #(`ROUNDS_OF_KECCAK) keccak_instance (clk, data_valid, data_valid_out);   
assign data_out = internal_wiring_reg[BURST_SIZE-1];
assign internal_wiring[0] = data_in;

for (i=0;i<BURST_SIZE-1;i=i+1) begin
always @(posedge clk) begin
    internal_wiring_reg[i] <= internal_wiring[i+1];
end
keccak_wrapper keccak_inst_0 (internal_wiring_reg[i],round_constant_signal_out(i+1) ,internal_wiring[i+2]);
always @(posedge clk) begin
    internal_wiring_reg[BURST_SIZE-1] <=internal_wiring[BURST_SIZE];
end
end

end else begin
///////////////////////////////////////////////////////////////////////////////////
// DEFAULT CASE
///////////////////////////////////////////////////////////////////////////////////

reg [`LOG_ROUNDS_OF_KECCAK-1:0] counter;
//assign internal_wiring[0] = {data_in, {(`KECCAK_WIDTH-RATE){1'b0}}};
assign internal_wiring[0] = data_valid ? data_in : internal_wiring_reg[BURST_SIZE-1];
assign data_out = internal_wiring_reg[BURST_SIZE-1];





reg burst_processing;
always @(posedge clk) begin
    if (rst) begin
        counter <=0;
        burst_processing <= 0;
    end else if (data_valid || burst_processing) begin
        if (counter==`ROUNDS_OF_KECCAK-1) begin
            counter<= 0;
            burst_processing <=0;
        end else begin
            counter<= counter+1;
            burst_processing <=1;
        end
    end else begin
        burst_processing <=0;// equivalent to 
        counter <= counter; //burst are guaranteed, continuous bursts are not
    end
end
reg burst_out;
reg [`LOG_ROUNDS_OF_KECCAK-1:0] counter_out;
always @(posedge clk) begin
    if (rst) begin
        counter_out <=0;
        burst_out <= 0;
    end else if ((burst_processing ==1 && counter==`ROUNDS_OF_KECCAK-1) || burst_out) begin
        if (counter_out==BURST_SIZE) begin
            counter_out<= 0;
            burst_out <=0;
        end else begin
            counter_out<= counter_out+1;
            burst_out <=1;
        end
    end else begin
        counter_out <= counter_out; 
        burst_out <=0;

    end
end
assign data_valid_out = burst_out;


keccak_wrapper keccak_inst_0 (internal_wiring[0],round_constant_signal_out(round_number_eval(0, counter)) ,internal_wiring[1]);
always @(posedge clk) begin
    internal_wiring_reg[BURST_SIZE-1] <=internal_wiring[BURST_SIZE];
end

for (i=0;i<BURST_SIZE-1;i=i+1) begin
always @(posedge clk) begin
    internal_wiring_reg[i] <= internal_wiring[i+1];
end
keccak_wrapper keccak_inst_0 (internal_wiring_reg[i],round_constant_signal_out(round_number_eval(i+1, counter)) ,internal_wiring[i+2]);
end


end //END OF DEFAULT CASE
endgenerate
    
    
//functions    
function [63:0] round_constant_signal_out;
input [`LOG_ROUNDS_OF_KECCAK-1:0] round_number;
        case(round_number)
            5'b00000 : round_constant_signal_out = 64'h0000_0000_0000_0001;
            5'b00001 : round_constant_signal_out = 64'h0000_0000_0000_8082;
            5'b00010 : round_constant_signal_out = 64'h8000_0000_0000_808A;
            5'b00011 : round_constant_signal_out = 64'h8000_0000_8000_8000;
            5'b00100 : round_constant_signal_out = 64'h0000_0000_0000_808B;
            5'b00101 : round_constant_signal_out = 64'h0000_0000_8000_0001;
            5'b00110 : round_constant_signal_out = 64'h8000_0000_8000_8081;
            5'b00111 : round_constant_signal_out = 64'h8000_0000_0000_8009;
            5'b01000 : round_constant_signal_out = 64'h0000_0000_0000_008A;
            5'b01001 : round_constant_signal_out = 64'h0000_0000_0000_0088;
            5'b01010 : round_constant_signal_out = 64'h0000_0000_8000_8009;
            5'b01011 : round_constant_signal_out = 64'h0000_0000_8000_000A;
            5'b01100 : round_constant_signal_out = 64'h0000_0000_8000_808B;
            5'b01101 : round_constant_signal_out = 64'h8000_0000_0000_008B;
            5'b01110 : round_constant_signal_out = 64'h8000_0000_0000_8089;
            5'b01111 : round_constant_signal_out = 64'h8000_0000_0000_8003;
            5'b10000 : round_constant_signal_out = 64'h8000_0000_0000_8002;
            5'b10001 : round_constant_signal_out = 64'h8000_0000_0000_0080;
            5'b10010 : round_constant_signal_out = 64'h0000_0000_0000_800A;
            5'b10011 : round_constant_signal_out = 64'h8000_0000_8000_000A;
            5'b10100 : round_constant_signal_out = 64'h8000_0000_8000_8081;
            5'b10101 : round_constant_signal_out = 64'h8000_0000_0000_8080;
            5'b10110 : round_constant_signal_out = 64'h0000_0000_8000_0001;
            5'b10111 : round_constant_signal_out = 64'h8000_0000_8000_8008;
            default : round_constant_signal_out = 64'h0;

        endcase
endfunction 
 
function [`LOG_ROUNDS_OF_KECCAK-1:0] round_number_eval;
input [`LOG_ROUNDS_OF_KECCAK-1:0] i;
input [`LOG_ROUNDS_OF_KECCAK-1:0] counter;
round_number_eval = (i+BURST_SIZE*(((counter-i+`ROUNDS_OF_KECCAK)%`ROUNDS_OF_KECCAK)/BURST_SIZE)); //correct for streaming by -i
endfunction 

endmodule







