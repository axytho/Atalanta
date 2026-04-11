`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2026 04:10:01 PM
// Design Name: 
// Module Name: three_to_one_accumulator
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


module three_to_one_accumulator(
    input clk,
    input rst,
    input [`MODULUS_WIDTH-1:0] data_in,
    input data_valid,
    output data_valid_out,
    output [`MODULUS_WIDTH-1:0] data_out

    );
reg [`MODULUS_WIDTH+2-1:0] accumulator [0:`NTT_DIV_BY_RING-1];
reg [`MODULUS_WIDTH+2-1:0] accumulator_chosen;
reduction_tail_ntt #(.ADDED_WIDTH(2)) reduc (clk, accumulator_chosen, data_out);
reg [$clog2(`SHAKE_COUNTER_SIZE<<(`LOG_N-`LOG_COEF_PER_CC))-1:0] input_counter;
reg [((`LOG_N-`LOG_COEF_PER_CC))-1:0] output_counter;

reg counter_reached_ready_point;
wire acc_valid;
assign acc_valid = ~(output_counter ==0) || counter_reached_ready_point;
reg reduction_valid;

shift_reg_data_valid #(`REDUCTION_LATENCY) shift_instance_3 (clk, reduction_valid, data_valid_out);
always @(posedge clk) begin
    accumulator_chosen <= accumulator[output_counter];
    reduction_valid <= acc_valid;
    counter_reached_ready_point <= (input_counter == ((`SMALL_K-1)<<(`LOG_N-`LOG_COEF_PER_CC)));
 end
generate
genvar i;
for (i=0;i<`NTT_DIV_BY_RING;i=i+1) begin
    always @(posedge clk) begin
        if (rst || (acc_valid && output_counter==i) ) begin
            accumulator[i] <= 0;
        end else if (data_valid && (input_counter[(`LOG_N-`LOG_COEF_PER_CC)-1:0])==i) begin
            accumulator[i] <= accumulator[i] + data_in;
        end else begin
            accumulator[i] <= accumulator[i];
        end
    end    
end
endgenerate

always @(posedge clk) begin
    if (rst) begin
        input_counter <= 0;
    end else if (data_valid) begin
        if (input_counter == (`SMALL_K<<(`LOG_N-`LOG_COEF_PER_CC))-1) begin
            input_counter <= 0; 
        end else begin
            input_counter <= input_counter + 1;  
        end  
    end else begin
        input_counter <= input_counter;
    end
end    


always @(posedge clk) begin
    if (rst) begin
        output_counter <= 0;
    end else if (acc_valid) begin
        if (output_counter == `NTT_DIV_BY_RING-1)
            output_counter <= 0; 
        else
            output_counter <= output_counter + 1;    
    end else begin
        output_counter <= output_counter;
    end
end



endmodule