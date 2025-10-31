`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: COSIC
// Engineer: Jonas Berte;s
// 
// Create Date: 03/05/2024 05:54:52 PM
// Design Name: MAC unit
// Module Name: multiply_and_accumulate
// Project Name: FINAL Hardware accelerator
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


module multiply_and_accumulate(

    input clk,
    input rst,
    input [`L*`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE-1:0] data_in,
    input data_valid,
    input [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE-1:0] BSK,
    input BSK_valid,
    output data_valid_out,
    output [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE-1:0] data_out
    );

//TEMPORARY MEASURE: we use a file to load in the bootstrapping key
//FINAL_MEASURE: we load in the BSK via HBM or DDR

//reg [`ITERATION_DEPTH+`L_WIDTH+`LOG_N-`LOG_COEF_PER_CC-1+1:0] counter_bsk;
reg [`LOG_N-`LOG_COEF_PER_CC-1:0] counter_bsk,counter_bsk_reg, counter_bsk_reg_2 ;
reg [`ITERATION_DEPTH-1+1:0] counter_iterations, counter_iterations_reg, counter_iterations_reg_2;
reg [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE-1:0] BSK_in_reg, BSK_in_reg_2, BSK_in_reg_3;
reg BSK_valid_reg;
reg [`L-1:0] BSK_URAM_wea_reg, BSK_URAM_wea_reg_2;
reg [`L-1:0] L_shift_reg;
always @(posedge clk) begin
    BSK_in_reg <= BSK;
    BSK_in_reg_2 <= BSK_in_reg;
    BSK_in_reg_3 <= BSK_in_reg_2;
    BSK_valid_reg <= BSK_valid;
    BSK_URAM_wea_reg <= {`L{BSK_valid_reg}} & L_shift_reg;
    counter_bsk_reg <= counter_bsk;
    counter_iterations_reg <= counter_iterations;
    counter_bsk_reg_2 <= counter_bsk_reg;
    counter_iterations_reg_2 <= counter_iterations_reg;
    BSK_URAM_wea_reg_2 <= BSK_URAM_wea_reg;
end

wire state_reading_bsk = ~(counter_iterations == `ITERATIONS);

always @(posedge clk) begin
    if (rst) begin
        counter_bsk <= 0;
    end else if (BSK_valid_reg) begin
        counter_bsk <= counter_bsk+1;
    end else begin
        counter_bsk <= counter_bsk;
    end
end

always @(posedge clk) begin
    if (rst) begin
        counter_iterations <= 0;
    end else if (&counter_bsk[`LOG_N - `LOG_COEF_PER_CC - 1:0] && BSK_valid_reg && L_shift_reg[`L-1]) begin
        counter_iterations <= counter_iterations+1;
    end else begin
        counter_iterations <= counter_iterations;
    end
end

reg [`ITERATION_DEPTH+`BATCH_DEPTH+`LOG_N-`LOG_COEF_PER_CC-1:0] counter, counter_reg, counter_reg_2; 
always @(posedge clk) begin
    if (rst)
        counter <= 0;
    else if (data_valid)
        counter <= counter + 1;
    else
        counter <= counter;
end
always @(posedge clk) begin
    counter_reg <= counter;
    counter_reg_2 <= counter_reg;
end

reg [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE*`L-1:0] BSK_mem [0:`NTT_DIV_BY_RING*`ITERATIONS-1];
wire [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE*`L-1:0] BSK_out;
reg [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE*`L-1:0] BSK_reg, BSK_reg_2;
reg [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE*`L-1:0] data_in_reg, data_in_reg_2, data_in_reg_3, data_in_reg_4, data_in_reg_5, data_in_reg_6, data_in_reg_7;
reg [`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE*`L-1:0] data_in_reg_8, data_in_reg_9, data_in_reg_10, data_in_reg_11, data_in_reg_12, data_in_reg_13, data_in_reg_14;


always @(posedge clk) begin
    if (rst) begin
        L_shift_reg <= 1;
    end else if (&counter_bsk[`LOG_N - `LOG_COEF_PER_CC - 1:0] && BSK_valid_reg) begin
        L_shift_reg <= {L_shift_reg[`L-2:0], L_shift_reg[`L-1]};
    end else begin
        L_shift_reg <= L_shift_reg;
    end
end

/// `L=7 differnt BRAMS which contain the secret key values
//wire [`L*`LOG_COEF_PER_CC*`MODULUS_WIDTH] BSK_out;
generate
    genvar l;
    for(l = 0; l < `L; l=l+1) begin: URAM_BSK
URAM_custom #(
            .DWIDTH(`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE),
            .AWIDTH(`LOG_N-`LOG_COEF_PER_CC+`ITERATION_DEPTH),
            .NBPIPE(8)
        ) URAM_instance (
            .clk(clk),
            .mem_en(1'b1),
            .addra({counter_iterations_reg_2[`ITERATION_DEPTH-1:0], counter_bsk_reg_2[`LOG_N-`LOG_COEF_PER_CC-1:0]}),
            .addrb({counter_reg_2[`ITERATION_DEPTH+`BATCH_DEPTH+`LOG_N-`LOG_COEF_PER_CC-1:`BATCH_DEPTH+`LOG_N-`LOG_COEF_PER_CC],counter_reg_2[`LOG_N-`LOG_COEF_PER_CC-1:0]}),
            .dina(BSK_in_reg_3),
            .wea(BSK_URAM_wea_reg_2[l]),// load each BRAM for every 1024 coefficients
            .doutb(BSK_out[l*`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE+:`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE])
        ); 
    end
endgenerate


always @(posedge clk) begin
    BSK_reg <= BSK_out;
    BSK_reg_2 <= BSK_reg;
    data_in_reg <= data_in;
    data_in_reg_2 <= data_in_reg;
    data_in_reg_3 <= data_in_reg_2;
    data_in_reg_4 <= data_in_reg_3;
    data_in_reg_5 <= data_in_reg_4;
    data_in_reg_6 <= data_in_reg_5;
    data_in_reg_7 <= data_in_reg_6;
    data_in_reg_8 <= data_in_reg_7;
    data_in_reg_9 <= data_in_reg_8;
    data_in_reg_10 <= data_in_reg_9;
    data_in_reg_11 <= data_in_reg_10;
    data_in_reg_12 <= data_in_reg_11;
    data_in_reg_13 <= data_in_reg_12;
    data_in_reg_14 <= data_in_reg_13;
end

//modular multiplier, then accumulate
wire [`MODULUS_WIDTH-1:0] mult_out [0:`COEF_PER_CLOCK_CYCLE*`L-1];
reg [`MODULUS_WIDTH-1:0] mult_out_reg [0:`COEF_PER_CLOCK_CYCLE*`L-1];

wire [(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE*(`L+1)-1:0] sum;
wire [(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE*(1<<(`L_WIDTH))-1:0] initial_sum;
reg [(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE*((1<<(`L_WIDTH+1))-1)-1:0] temp_sum;

assign sum[0+:(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE] = 0;

wire [`COUNTER_SIZE-1:0] iteration_counter; //purposefeully too large
generate
      if (`ITERATIONS==1) begin: NO_ITERATION_COUNTER
         assign iteration_counter = 0;
      end else begin: WITH_ITERATION_COUNTER
         assign iteration_counter = counter[`COUNTER_SIZE-1:(`LOG_N-`LOG_COEF_PER_CC+`BATCH_DEPTH)];
      end
   endgenerate



generate
    genvar i,j;
    for (i = 0; i< `L; i=i+1) begin: PER_L
        for (j = 0; j<`COEF_PER_CLOCK_CYCLE; j=j+1) begin: PER_COEF_PER_CLOCK_CYCLE//                                                                   alternatively: counter[(`LOG_N-`LOG_COEF_PER_CC)+:clog(`iterations)]
            //assign BSK_out[i*`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE+j*`MODULUS_WIDTH+:`MODULUS_WIDTH] = BSK[counter[(`LOG_N-`LOG_COEF_PER_CC-1):0]*`COEF_PER_CLOCK_CYCLE+iteration_counter*`NTT_POLYNOMIAL_SIZE*`L +i*`NTT_POLYNOMIAL_SIZE+j];
            modular_multiplier modular_multiplier(
            .clk(clk),.input_a(BSK_reg_2[i*`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE+j*`MODULUS_WIDTH+:`MODULUS_WIDTH]), 
            //.clk(clk),.input_a(BSK_out[i*`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE+j*`MODULUS_WIDTH+:`MODULUS_WIDTH]), 
            .input_b(data_in_reg_14[i*`MODULUS_WIDTH*`COEF_PER_CLOCK_CYCLE+j*`MODULUS_WIDTH+:`MODULUS_WIDTH]), 
            .output_product(mult_out[i*`COEF_PER_CLOCK_CYCLE+j]));
            always @(posedge clk) begin
                mult_out_reg[i*`COEF_PER_CLOCK_CYCLE+j] <= mult_out[i*`COEF_PER_CLOCK_CYCLE+j];
            end
        end
    end
endgenerate      

generate
    genvar i_2,j_2;
    for (i_2 = 0; i_2< (1<<(`L_WIDTH)); i_2=i_2+1) begin: PER_L_maxed
        for (j_2 = 0; j_2<`COEF_PER_CLOCK_CYCLE; j_2=j_2+1) begin: PER_COEF_PER_CLOCK_CYCLE_2//        
            //EXPLANATION FOR sum:
            //
            // sum should be seen as a bunch of blocks of wires, each (`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE big
            // each block consists of the coefficient wise addition with a certain result from mult_out
            // the j is the coefficient wise part of it
            // (in case of confusion, draw a diagram and group the wires by (`MODULUS_WIDTH+`L_WIDTH))
            //assign sum[(i+1)*(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE + j*(`MODULUS_WIDTH+`L_WIDTH)+:(`MODULUS_WIDTH+`L_WIDTH)] = sum[i*(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE + j*(`MODULUS_WIDTH+`L_WIDTH)+:(`MODULUS_WIDTH+`L_WIDTH)] + mult_out[i*`COEF_PER_CLOCK_CYCLE+j];
            if (i_2<(`L)) begin
                assign initial_sum[i_2*(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE + j_2*(`MODULUS_WIDTH+`L_WIDTH)+:(`MODULUS_WIDTH+`L_WIDTH)] =  {{`L_WIDTH{1'b0}},mult_out_reg[i_2*`COEF_PER_CLOCK_CYCLE+j_2]};
            end else begin
                assign initial_sum[i_2*(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE + j_2*(`MODULUS_WIDTH+`L_WIDTH)+:(`MODULUS_WIDTH+`L_WIDTH)] =  0;
            end
        end
    end
endgenerate   





function [32-1:0] input_selector;
 input [32-1:0] ring_iterator;
 input [32-1:0] stage;
 input [32-1:0] loop_iter;
 input [1:0] constant;
 begin
     input_selector = ring_iterator + `COEF_PER_CLOCK_CYCLE*( (1<<(`L_WIDTH + 1)) - (1<<(`L_WIDTH + 1- stage)) +  (loop_iter<<1)+constant );
 end
endfunction

function [32-1:0] output_selector;
 input [32-1:0] ring_iterator;
 input [32-1:0] stage;
 input [32-1:0] loop_iter;
 begin
     output_selector = ring_iterator + `COEF_PER_CLOCK_CYCLE*( (1<<(`L_WIDTH + 1)) - (1<<(`L_WIDTH - stage)) +  (loop_iter) );
 end
endfunction

reg [`MODULUS_WIDTH+2-1:0] add_out_reg [0:`COEF_PER_CLOCK_CYCLE*3-1];
wire [`MODULUS_WIDTH+2-1:0] add_out [0:`COEF_PER_CLOCK_CYCLE*2-1];
wire [`MODULUS_WIDTH+3-1:0] add_out_final [0:`COEF_PER_CLOCK_CYCLE-1];
//reg [(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE-1:0] sum_reg;

//always @(posedge clk) begin
//    sum_reg <= sum[(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE*(`L)+:(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE];
//end
reg [(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE-1:0] sum_wire;
generate
    if (`L==7) begin
        genvar ring_iterator;
        for (ring_iterator = 0; ring_iterator<`COEF_PER_CLOCK_CYCLE; ring_iterator=ring_iterator+1) begin: PER_COEF_PER_CLOCK_CYCLE
            efficient_adder add_L_together (.clk(clk), .input_a(mult_out_reg[0*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .input_b(mult_out_reg[1*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .input_c(mult_out_reg[2*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .sum(add_out[0*`COEF_PER_CLOCK_CYCLE+ring_iterator]));
            efficient_adder add_L_together_2 (.clk(clk), .input_a(mult_out_reg[3*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .input_b(mult_out_reg[4*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .input_c(mult_out_reg[5*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .sum(add_out[1*`COEF_PER_CLOCK_CYCLE+ring_iterator]));

            efficient_adder_no_3 add_L_together_3 (.clk(clk), .input_a(add_out_reg[0*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .input_b(add_out_reg[1*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .input_c(add_out_reg[2*`COEF_PER_CLOCK_CYCLE+ring_iterator]), .sum(add_out_final[0*`COEF_PER_CLOCK_CYCLE+ring_iterator]));

           always @(posedge clk) begin
                add_out_reg[0*`COEF_PER_CLOCK_CYCLE+ring_iterator] <= add_out[0*`COEF_PER_CLOCK_CYCLE+ring_iterator];
                add_out_reg[1*`COEF_PER_CLOCK_CYCLE+ring_iterator] <= add_out[1*`COEF_PER_CLOCK_CYCLE+ring_iterator];
                add_out_reg[2*`COEF_PER_CLOCK_CYCLE+ring_iterator] <= mult_out_reg[6*`COEF_PER_CLOCK_CYCLE+ring_iterator];
                sum_wire[(`MODULUS_WIDTH+`L_WIDTH)*ring_iterator+:(`MODULUS_WIDTH+`L_WIDTH)] <= add_out_final[ring_iterator];
            end
            
        end
        
    end else begin
        // SPECIFIC EXCEPTION TO MY RULES OF NEVER USING THESE KIND OF STATEMENTS WITH ALWAYS @* HERE TO MAKE THE SUBSEQUENT LOGIC MAKE SENSE
        always @(*) begin
            temp_sum[(`MODULUS_WIDTH+`L_WIDTH)*`COEF_PER_CLOCK_CYCLE*(1<<`L_WIDTH)-1:0] = initial_sum;
        end
            genvar stage;
            genvar ring_iterator;
            genvar loop_iter;
            for (ring_iterator = 0; ring_iterator<`COEF_PER_CLOCK_CYCLE; ring_iterator=ring_iterator+1) begin: PER_COEF_PER_CLOCK_CYCLE//   
                for (stage = 0; stage<`L_WIDTH; stage=stage+1) begin
                    for (loop_iter = 0; loop_iter<(1<<(`L_WIDTH-1-stage)); loop_iter=loop_iter+1) begin
                        //input_selector = ( (1<<`L_WIDTH) + (1<<(`L_WIDTH + 1)) - (1<<(`L_WIDTH + 1- stage)) +  1);
                        always @(posedge clk) begin
                            temp_sum[(`MODULUS_WIDTH+`L_WIDTH)*output_selector(ring_iterator,stage, loop_iter) +:(`MODULUS_WIDTH+`L_WIDTH)] <= temp_sum[(`MODULUS_WIDTH+`L_WIDTH)*input_selector(ring_iterator,stage, loop_iter, 0) +:(`MODULUS_WIDTH+`L_WIDTH)] + temp_sum[(`MODULUS_WIDTH+`L_WIDTH)*input_selector(ring_iterator,stage, loop_iter, 1) +:(`MODULUS_WIDTH+`L_WIDTH)] ;
                        end
                    end
                end
            end
            always @(posedge clk) begin
            sum_wire <= temp_sum[`COEF_PER_CLOCK_CYCLE*(`MODULUS_WIDTH+`L_WIDTH)*((1<<(`L_WIDTH + 1)) - 2) +:`COEF_PER_CLOCK_CYCLE*(`MODULUS_WIDTH+`L_WIDTH)];
            end
    end
endgenerate





generate
    genvar k;
    for (k = 0; k<`COEF_PER_CLOCK_CYCLE; k=k+1) begin: PER_COEF_PER_CLOCK_CYCLE_K
        reduction reduction_0(.clk(clk), 
        //.data_in({{(`MODULUS_WIDTH-`L_WIDTH){1'b0}} ,sum_reg[(`MODULUS_WIDTH+`L_WIDTH)*k+:(`MODULUS_WIDTH+`L_WIDTH)]}), 
        .data_in({{(`MODULUS_WIDTH-`L_WIDTH){1'b0}} ,sum_wire[(`MODULUS_WIDTH+`L_WIDTH)*k+:(`MODULUS_WIDTH+`L_WIDTH)]}), 
        .data_out(data_out[`MODULUS_WIDTH*k+:`MODULUS_WIDTH]));
    end
endgenerate  
shift_reg_data_valid #(`MAC_LATENCY) shift_instance_2 (clk, data_valid, data_valid_out);  
endmodule
