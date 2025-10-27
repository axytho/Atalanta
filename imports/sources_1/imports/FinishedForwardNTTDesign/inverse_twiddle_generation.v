`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jonas Bertels
// 
// Create Date: 07/31/2022 03:55:27 PM
// Design Name: 
// Module Name: twiddle_generation
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
`include "ntt_params.v"
module inverse_twiddle_generation #(
parameter TWIDDLE_INDEX=0
)
(
    input clk,
    input rst,
    input data_valid,
    output [`GOLD_MODULUS_WIDTH-1:0] twiddle
    );
    
reg [`RING_DEPTH-1:0] counter;
reg [`GOLD_MODULUS_WIDTH-1:0] twiddle_output;
wire [`GOLD_MODULUS_WIDTH-1:0] OMEGA [`RING_SIZE-1:0];

assign twiddle = twiddle_output;

always @(posedge clk) begin
    if (rst)
        counter <= 0;
    else if (data_valid)
        counter <= counter + 1;
    else
        counter <= counter;
end



always @(posedge clk) begin
    twiddle_output <= OMEGA[counter];
end


   //twiddle = OMEGA[TWIDDLE_INDEX * counter];


generate

    case(TWIDDLE_INDEX)
           0:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd786177;
assign OMEGA[2] = 32'd786177;
assign OMEGA[3] = 32'd786177;
assign OMEGA[4] = 32'd786177;
assign OMEGA[5] = 32'd786177;
assign OMEGA[6] = 32'd786177;
assign OMEGA[7] = 32'd786177;
assign OMEGA[8] = 32'd786177;
assign OMEGA[9] = 32'd786177;
assign OMEGA[10] = 32'd786177;
assign OMEGA[11] = 32'd786177;
assign OMEGA[12] = 32'd786177;
assign OMEGA[13] = 32'd786177;
assign OMEGA[14] = 32'd786177;
assign OMEGA[15] = 32'd786177;
assign OMEGA[16] = 32'd786177;
assign OMEGA[17] = 32'd786177;
assign OMEGA[18] = 32'd786177;
assign OMEGA[19] = 32'd786177;
assign OMEGA[20] = 32'd786177;
assign OMEGA[21] = 32'd786177;
assign OMEGA[22] = 32'd786177;
assign OMEGA[23] = 32'd786177;
assign OMEGA[24] = 32'd786177;
assign OMEGA[25] = 32'd786177;
assign OMEGA[26] = 32'd786177;
assign OMEGA[27] = 32'd786177;
assign OMEGA[28] = 32'd786177;
assign OMEGA[29] = 32'd786177;
assign OMEGA[30] = 32'd786177;
assign OMEGA[31] = 32'd786177;
end
1:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd642554;
assign OMEGA[2] = 32'd289195;
assign OMEGA[3] = 32'd785276;
assign OMEGA[4] = 32'd636904;
assign OMEGA[5] = 32'd646545;
assign OMEGA[6] = 32'd71571;
assign OMEGA[7] = 32'd101416;
assign OMEGA[8] = 32'd301661;
assign OMEGA[9] = 32'd31627;
assign OMEGA[10] = 32'd630385;
assign OMEGA[11] = 32'd328101;
assign OMEGA[12] = 32'd760412;
assign OMEGA[13] = 32'd720146;
assign OMEGA[14] = 32'd128109;
assign OMEGA[15] = 32'd450718;
assign OMEGA[16] = 32'd618943;
assign OMEGA[17] = 32'd84400;
assign OMEGA[18] = 32'd396584;
assign OMEGA[19] = 32'd256785;
assign OMEGA[20] = 32'd37384;
assign OMEGA[21] = 32'd391540;
assign OMEGA[22] = 32'd506211;
assign OMEGA[23] = 32'd46078;
assign OMEGA[24] = 32'd774248;
assign OMEGA[25] = 32'd373978;
assign OMEGA[26] = 32'd238971;
assign OMEGA[27] = 32'd328930;
assign OMEGA[28] = 32'd701020;
assign OMEGA[29] = 32'd370404;
assign OMEGA[30] = 32'd374544;
assign OMEGA[31] = 32'd182294;
end
2:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd289195;
assign OMEGA[2] = 32'd636904;
assign OMEGA[3] = 32'd71571;
assign OMEGA[4] = 32'd301661;
assign OMEGA[5] = 32'd630385;
assign OMEGA[6] = 32'd760412;
assign OMEGA[7] = 32'd128109;
assign OMEGA[8] = 32'd618943;
assign OMEGA[9] = 32'd396584;
assign OMEGA[10] = 32'd37384;
assign OMEGA[11] = 32'd506211;
assign OMEGA[12] = 32'd774248;
assign OMEGA[13] = 32'd238971;
assign OMEGA[14] = 32'd701020;
assign OMEGA[15] = 32'd374544;
assign OMEGA[16] = 32'd531267;
assign OMEGA[17] = 32'd485963;
assign OMEGA[18] = 32'd30199;
assign OMEGA[19] = 32'd478993;
assign OMEGA[20] = 32'd242407;
assign OMEGA[21] = 32'd75805;
assign OMEGA[22] = 32'd378557;
assign OMEGA[23] = 32'd369371;
assign OMEGA[24] = 32'd553592;
assign OMEGA[25] = 32'd748398;
assign OMEGA[26] = 32'd349011;
assign OMEGA[27] = 32'd83522;
assign OMEGA[28] = 32'd87416;
assign OMEGA[29] = 32'd462383;
assign OMEGA[30] = 32'd162520;
assign OMEGA[31] = 32'd652868;
end
3:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd785276;
assign OMEGA[2] = 32'd71571;
assign OMEGA[3] = 32'd31627;
assign OMEGA[4] = 32'd760412;
assign OMEGA[5] = 32'd450718;
assign OMEGA[6] = 32'd396584;
assign OMEGA[7] = 32'd391540;
assign OMEGA[8] = 32'd774248;
assign OMEGA[9] = 32'd328930;
assign OMEGA[10] = 32'd374544;
assign OMEGA[11] = 32'd660570;
assign OMEGA[12] = 32'd30199;
assign OMEGA[13] = 32'd667942;
assign OMEGA[14] = 32'd75805;
assign OMEGA[15] = 32'd290379;
assign OMEGA[16] = 32'd553592;
assign OMEGA[17] = 32'd658774;
assign OMEGA[18] = 32'd83522;
assign OMEGA[19] = 32'd150152;
assign OMEGA[20] = 32'd162520;
assign OMEGA[21] = 32'd562482;
assign OMEGA[22] = 32'd201288;
assign OMEGA[23] = 32'd590239;
assign OMEGA[24] = 32'd618577;
assign OMEGA[25] = 32'd371867;
assign OMEGA[26] = 32'd479511;
assign OMEGA[27] = 32'd634235;
assign OMEGA[28] = 32'd583946;
assign OMEGA[29] = 32'd126263;
assign OMEGA[30] = 32'd119065;
assign OMEGA[31] = 32'd547334;
end
4:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd636904;
assign OMEGA[2] = 32'd301661;
assign OMEGA[3] = 32'd760412;
assign OMEGA[4] = 32'd618943;
assign OMEGA[5] = 32'd37384;
assign OMEGA[6] = 32'd774248;
assign OMEGA[7] = 32'd701020;
assign OMEGA[8] = 32'd531267;
assign OMEGA[9] = 32'd30199;
assign OMEGA[10] = 32'd242407;
assign OMEGA[11] = 32'd378557;
assign OMEGA[12] = 32'd553592;
assign OMEGA[13] = 32'd349011;
assign OMEGA[14] = 32'd87416;
assign OMEGA[15] = 32'd162520;
assign OMEGA[16] = 32'd481863;
assign OMEGA[17] = 32'd750692;
assign OMEGA[18] = 32'd618577;
assign OMEGA[19] = 32'd407285;
assign OMEGA[20] = 32'd449816;
assign OMEGA[21] = 32'd583946;
assign OMEGA[22] = 32'd574433;
assign OMEGA[23] = 32'd526015;
assign OMEGA[24] = 32'd22234;
assign OMEGA[25] = 32'd176571;
assign OMEGA[26] = 32'd692593;
assign OMEGA[27] = 32'd287738;
assign OMEGA[28] = 32'd231230;
assign OMEGA[29] = 32'd537850;
assign OMEGA[30] = 32'd44525;
assign OMEGA[31] = 32'd727428;
end
5:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd646545;
assign OMEGA[2] = 32'd630385;
assign OMEGA[3] = 32'd450718;
assign OMEGA[4] = 32'd37384;
assign OMEGA[5] = 32'd373978;
assign OMEGA[6] = 32'd374544;
assign OMEGA[7] = 32'd192307;
assign OMEGA[8] = 32'd242407;
assign OMEGA[9] = 32'd290379;
assign OMEGA[10] = 32'd748398;
assign OMEGA[11] = 32'd695701;
assign OMEGA[12] = 32'd162520;
assign OMEGA[13] = 32'd333310;
assign OMEGA[14] = 32'd368756;
assign OMEGA[15] = 32'd371867;
assign OMEGA[16] = 32'd449816;
assign OMEGA[17] = 32'd36018;
assign OMEGA[18] = 32'd119065;
assign OMEGA[19] = 32'd623227;
assign OMEGA[20] = 32'd176571;
assign OMEGA[21] = 32'd687646;
assign OMEGA[22] = 32'd528716;
assign OMEGA[23] = 32'd92730;
assign OMEGA[24] = 32'd44525;
assign OMEGA[25] = 32'd196467;
assign OMEGA[26] = 32'd156288;
assign OMEGA[27] = 32'd466860;
assign OMEGA[28] = 32'd108911;
assign OMEGA[29] = 32'd88211;
assign OMEGA[30] = 32'd770058;
assign OMEGA[31] = 32'd538434;
end
6:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd71571;
assign OMEGA[2] = 32'd760412;
assign OMEGA[3] = 32'd396584;
assign OMEGA[4] = 32'd774248;
assign OMEGA[5] = 32'd374544;
assign OMEGA[6] = 32'd30199;
assign OMEGA[7] = 32'd75805;
assign OMEGA[8] = 32'd553592;
assign OMEGA[9] = 32'd83522;
assign OMEGA[10] = 32'd162520;
assign OMEGA[11] = 32'd201288;
assign OMEGA[12] = 32'd618577;
assign OMEGA[13] = 32'd479511;
assign OMEGA[14] = 32'd583946;
assign OMEGA[15] = 32'd119065;
assign OMEGA[16] = 32'd22234;
assign OMEGA[17] = 32'd216723;
assign OMEGA[18] = 32'd287738;
assign OMEGA[19] = 32'd208264;
assign OMEGA[20] = 32'd44525;
assign OMEGA[21] = 32'd205542;
assign OMEGA[22] = 32'd661;
assign OMEGA[23] = 32'd254498;
assign OMEGA[24] = 32'd39539;
assign OMEGA[25] = 32'd770058;
assign OMEGA[26] = 32'd777959;
assign OMEGA[27] = 32'd65109;
assign OMEGA[28] = 32'd521066;
assign OMEGA[29] = 32'd495470;
assign OMEGA[30] = 32'd20594;
assign OMEGA[31] = 32'd109976;
end
7:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd101416;
assign OMEGA[2] = 32'd128109;
assign OMEGA[3] = 32'd391540;
assign OMEGA[4] = 32'd701020;
assign OMEGA[5] = 32'd192307;
assign OMEGA[6] = 32'd75805;
assign OMEGA[7] = 32'd271622;
assign OMEGA[8] = 32'd87416;
assign OMEGA[9] = 32'd562482;
assign OMEGA[10] = 32'd368756;
assign OMEGA[11] = 32'd289848;
assign OMEGA[12] = 32'd583946;
assign OMEGA[13] = 32'd319813;
assign OMEGA[14] = 32'd534195;
assign OMEGA[15] = 32'd687646;
assign OMEGA[16] = 32'd231230;
assign OMEGA[17] = 32'd163691;
assign OMEGA[18] = 32'd205542;
assign OMEGA[19] = 32'd313132;
assign OMEGA[20] = 32'd108911;
assign OMEGA[21] = 32'd378378;
assign OMEGA[22] = 32'd754262;
assign OMEGA[23] = 32'd382999;
assign OMEGA[24] = 32'd521066;
assign OMEGA[25] = 32'd64262;
assign OMEGA[26] = 32'd445344;
assign OMEGA[27] = 32'd521616;
assign OMEGA[28] = 32'd583657;
assign OMEGA[29] = 32'd311422;
assign OMEGA[30] = 32'd638882;
assign OMEGA[31] = 32'd380089;
end
8:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd301661;
assign OMEGA[2] = 32'd618943;
assign OMEGA[3] = 32'd774248;
assign OMEGA[4] = 32'd531267;
assign OMEGA[5] = 32'd242407;
assign OMEGA[6] = 32'd553592;
assign OMEGA[7] = 32'd87416;
assign OMEGA[8] = 32'd481863;
assign OMEGA[9] = 32'd618577;
assign OMEGA[10] = 32'd449816;
assign OMEGA[11] = 32'd574433;
assign OMEGA[12] = 32'd22234;
assign OMEGA[13] = 32'd692593;
assign OMEGA[14] = 32'd231230;
assign OMEGA[15] = 32'd44525;
assign OMEGA[16] = 32'd301186;
assign OMEGA[17] = 32'd739369;
assign OMEGA[18] = 32'd39539;
assign OMEGA[19] = 32'd419570;
assign OMEGA[20] = 32'd192891;
assign OMEGA[21] = 32'd521066;
assign OMEGA[22] = 32'd598492;
assign OMEGA[23] = 32'd127964;
assign OMEGA[24] = 32'd145617;
assign OMEGA[25] = 32'd580733;
assign OMEGA[26] = 32'd204827;
assign OMEGA[27] = 32'd710220;
assign OMEGA[28] = 32'd346775;
assign OMEGA[29] = 32'd204569;
assign OMEGA[30] = 32'd442845;
assign OMEGA[31] = 32'd583481;
end
9:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd31627;
assign OMEGA[2] = 32'd396584;
assign OMEGA[3] = 32'd328930;
assign OMEGA[4] = 32'd30199;
assign OMEGA[5] = 32'd290379;
assign OMEGA[6] = 32'd83522;
assign OMEGA[7] = 32'd562482;
assign OMEGA[8] = 32'd618577;
assign OMEGA[9] = 32'd634235;
assign OMEGA[10] = 32'd119065;
assign OMEGA[11] = 32'd684168;
assign OMEGA[12] = 32'd287738;
assign OMEGA[13] = 32'd425159;
assign OMEGA[14] = 32'd205542;
assign OMEGA[15] = 32'd466860;
assign OMEGA[16] = 32'd39539;
assign OMEGA[17] = 32'd180969;
assign OMEGA[18] = 32'd65109;
assign OMEGA[19] = 32'd726812;
assign OMEGA[20] = 32'd20594;
assign OMEGA[21] = 32'd521616;
assign OMEGA[22] = 32'd192973;
assign OMEGA[23] = 32'd781654;
assign OMEGA[24] = 32'd710220;
assign OMEGA[25] = 32'd546705;
assign OMEGA[26] = 32'd666144;
assign OMEGA[27] = 32'd572970;
assign OMEGA[28] = 32'd625388;
assign OMEGA[29] = 32'd705169;
assign OMEGA[30] = 32'd749856;
assign OMEGA[31] = 32'd454570;
end
10:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd630385;
assign OMEGA[2] = 32'd37384;
assign OMEGA[3] = 32'd374544;
assign OMEGA[4] = 32'd242407;
assign OMEGA[5] = 32'd748398;
assign OMEGA[6] = 32'd162520;
assign OMEGA[7] = 32'd368756;
assign OMEGA[8] = 32'd449816;
assign OMEGA[9] = 32'd119065;
assign OMEGA[10] = 32'd176571;
assign OMEGA[11] = 32'd528716;
assign OMEGA[12] = 32'd44525;
assign OMEGA[13] = 32'd156288;
assign OMEGA[14] = 32'd108911;
assign OMEGA[15] = 32'd770058;
assign OMEGA[16] = 32'd192891;
assign OMEGA[17] = 32'd253147;
assign OMEGA[18] = 32'd20594;
assign OMEGA[19] = 32'd658531;
assign OMEGA[20] = 32'd580733;
assign OMEGA[21] = 32'd638882;
assign OMEGA[22] = 32'd55870;
assign OMEGA[23] = 32'd337942;
assign OMEGA[24] = 32'd442845;
assign OMEGA[25] = 32'd735859;
assign OMEGA[26] = 32'd531002;
assign OMEGA[27] = 32'd749856;
assign OMEGA[28] = 32'd166525;
assign OMEGA[29] = 32'd598211;
assign OMEGA[30] = 32'd774274;
assign OMEGA[31] = 32'd10291;
end
11:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd328101;
assign OMEGA[2] = 32'd506211;
assign OMEGA[3] = 32'd660570;
assign OMEGA[4] = 32'd378557;
assign OMEGA[5] = 32'd695701;
assign OMEGA[6] = 32'd201288;
assign OMEGA[7] = 32'd289848;
assign OMEGA[8] = 32'd574433;
assign OMEGA[9] = 32'd684168;
assign OMEGA[10] = 32'd528716;
assign OMEGA[11] = 32'd266988;
assign OMEGA[12] = 32'd661;
assign OMEGA[13] = 32'd753347;
assign OMEGA[14] = 32'd754262;
assign OMEGA[15] = 32'd168310;
assign OMEGA[16] = 32'd598492;
assign OMEGA[17] = 32'd344865;
assign OMEGA[18] = 32'd192973;
assign OMEGA[19] = 32'd504981;
assign OMEGA[20] = 32'd55870;
assign OMEGA[21] = 32'd715636;
assign OMEGA[22] = 32'd392025;
assign OMEGA[23] = 32'd379686;
assign OMEGA[24] = 32'd566614;
assign OMEGA[25] = 32'd17845;
assign OMEGA[26] = 32'd454779;
assign OMEGA[27] = 32'd99947;
assign OMEGA[28] = 32'd64405;
assign OMEGA[29] = 32'd58797;
assign OMEGA[30] = 32'd537003;
assign OMEGA[31] = 32'd50877;
end
12:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd760412;
assign OMEGA[2] = 32'd774248;
assign OMEGA[3] = 32'd30199;
assign OMEGA[4] = 32'd553592;
assign OMEGA[5] = 32'd162520;
assign OMEGA[6] = 32'd618577;
assign OMEGA[7] = 32'd583946;
assign OMEGA[8] = 32'd22234;
assign OMEGA[9] = 32'd287738;
assign OMEGA[10] = 32'd44525;
assign OMEGA[11] = 32'd661;
assign OMEGA[12] = 32'd39539;
assign OMEGA[13] = 32'd777959;
assign OMEGA[14] = 32'd521066;
assign OMEGA[15] = 32'd20594;
assign OMEGA[16] = 32'd145617;
assign OMEGA[17] = 32'd89345;
assign OMEGA[18] = 32'd710220;
assign OMEGA[19] = 32'd636864;
assign OMEGA[20] = 32'd442845;
assign OMEGA[21] = 32'd625388;
assign OMEGA[22] = 32'd566614;
assign OMEGA[23] = 32'd632118;
assign OMEGA[24] = 32'd703865;
assign OMEGA[25] = 32'd774274;
assign OMEGA[26] = 32'd223306;
assign OMEGA[27] = 32'd130893;
assign OMEGA[28] = 32'd227037;
assign OMEGA[29] = 32'd709809;
assign OMEGA[30] = 32'd518288;
assign OMEGA[31] = 32'd137586;
end
13:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd720146;
assign OMEGA[2] = 32'd238971;
assign OMEGA[3] = 32'd667942;
assign OMEGA[4] = 32'd349011;
assign OMEGA[5] = 32'd333310;
assign OMEGA[6] = 32'd479511;
assign OMEGA[7] = 32'd319813;
assign OMEGA[8] = 32'd692593;
assign OMEGA[9] = 32'd425159;
assign OMEGA[10] = 32'd156288;
assign OMEGA[11] = 32'd753347;
assign OMEGA[12] = 32'd777959;
assign OMEGA[13] = 32'd380136;
assign OMEGA[14] = 32'd445344;
assign OMEGA[15] = 32'd200392;
assign OMEGA[16] = 32'd204827;
assign OMEGA[17] = 32'd182764;
assign OMEGA[18] = 32'd666144;
assign OMEGA[19] = 32'd356537;
assign OMEGA[20] = 32'd531002;
assign OMEGA[21] = 32'd538178;
assign OMEGA[22] = 32'd454779;
assign OMEGA[23] = 32'd711140;
assign OMEGA[24] = 32'd223306;
assign OMEGA[25] = 32'd344232;
assign OMEGA[26] = 32'd389180;
assign OMEGA[27] = 32'd96064;
assign OMEGA[28] = 32'd691382;
assign OMEGA[29] = 32'd569319;
assign OMEGA[30] = 32'd620108;
assign OMEGA[31] = 32'd171325;
end
14:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd128109;
assign OMEGA[2] = 32'd701020;
assign OMEGA[3] = 32'd75805;
assign OMEGA[4] = 32'd87416;
assign OMEGA[5] = 32'd368756;
assign OMEGA[6] = 32'd583946;
assign OMEGA[7] = 32'd534195;
assign OMEGA[8] = 32'd231230;
assign OMEGA[9] = 32'd205542;
assign OMEGA[10] = 32'd108911;
assign OMEGA[11] = 32'd754262;
assign OMEGA[12] = 32'd521066;
assign OMEGA[13] = 32'd445344;
assign OMEGA[14] = 32'd583657;
assign OMEGA[15] = 32'd638882;
assign OMEGA[16] = 32'd346775;
assign OMEGA[17] = 32'd496943;
assign OMEGA[18] = 32'd625388;
assign OMEGA[19] = 32'd420984;
assign OMEGA[20] = 32'd166525;
assign OMEGA[21] = 32'd203599;
assign OMEGA[22] = 32'd64405;
assign OMEGA[23] = 32'd360967;
assign OMEGA[24] = 32'd227037;
assign OMEGA[25] = 32'd494417;
assign OMEGA[26] = 32'd691382;
assign OMEGA[27] = 32'd432215;
assign OMEGA[28] = 32'd11338;
assign OMEGA[29] = 32'd230564;
assign OMEGA[30] = 32'd90313;
assign OMEGA[31] = 32'd89456;
end
15:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd450718;
assign OMEGA[2] = 32'd374544;
assign OMEGA[3] = 32'd290379;
assign OMEGA[4] = 32'd162520;
assign OMEGA[5] = 32'd371867;
assign OMEGA[6] = 32'd119065;
assign OMEGA[7] = 32'd687646;
assign OMEGA[8] = 32'd44525;
assign OMEGA[9] = 32'd466860;
assign OMEGA[10] = 32'd770058;
assign OMEGA[11] = 32'd168310;
assign OMEGA[12] = 32'd20594;
assign OMEGA[13] = 32'd200392;
assign OMEGA[14] = 32'd638882;
assign OMEGA[15] = 32'd546705;
assign OMEGA[16] = 32'd442845;
assign OMEGA[17] = 32'd774362;
assign OMEGA[18] = 32'd749856;
assign OMEGA[19] = 32'd15037;
assign OMEGA[20] = 32'd774274;
assign OMEGA[21] = 32'd659030;
assign OMEGA[22] = 32'd537003;
assign OMEGA[23] = 32'd259691;
assign OMEGA[24] = 32'd518288;
assign OMEGA[25] = 32'd443648;
assign OMEGA[26] = 32'd620108;
assign OMEGA[27] = 32'd508906;
assign OMEGA[28] = 32'd90313;
assign OMEGA[29] = 32'd682287;
assign OMEGA[30] = 32'd429549;
assign OMEGA[31] = 32'd492234;
end
16:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd618943;
assign OMEGA[2] = 32'd531267;
assign OMEGA[3] = 32'd553592;
assign OMEGA[4] = 32'd481863;
assign OMEGA[5] = 32'd449816;
assign OMEGA[6] = 32'd22234;
assign OMEGA[7] = 32'd231230;
assign OMEGA[8] = 32'd301186;
assign OMEGA[9] = 32'd39539;
assign OMEGA[10] = 32'd192891;
assign OMEGA[11] = 32'd598492;
assign OMEGA[12] = 32'd145617;
assign OMEGA[13] = 32'd204827;
assign OMEGA[14] = 32'd346775;
assign OMEGA[15] = 32'd442845;
assign OMEGA[16] = 32'd345889;
assign OMEGA[17] = 32'd194949;
assign OMEGA[18] = 32'd703865;
assign OMEGA[19] = 32'd292270;
assign OMEGA[20] = 32'd227304;
assign OMEGA[21] = 32'd227037;
assign OMEGA[22] = 32'd709759;
assign OMEGA[23] = 32'd572653;
assign OMEGA[24] = 32'd240719;
assign OMEGA[25] = 32'd703351;
assign OMEGA[26] = 32'd361486;
assign OMEGA[27] = 32'd95907;
assign OMEGA[28] = 32'd601265;
assign OMEGA[29] = 32'd454592;
assign OMEGA[30] = 32'd541910;
assign OMEGA[31] = 32'd518833;
end
17:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd84400;
assign OMEGA[2] = 32'd485963;
assign OMEGA[3] = 32'd658774;
assign OMEGA[4] = 32'd750692;
assign OMEGA[5] = 32'd36018;
assign OMEGA[6] = 32'd216723;
assign OMEGA[7] = 32'd163691;
assign OMEGA[8] = 32'd739369;
assign OMEGA[9] = 32'd180969;
assign OMEGA[10] = 32'd253147;
assign OMEGA[11] = 32'd344865;
assign OMEGA[12] = 32'd89345;
assign OMEGA[13] = 32'd182764;
assign OMEGA[14] = 32'd496943;
assign OMEGA[15] = 32'd774362;
assign OMEGA[16] = 32'd194949;
assign OMEGA[17] = 32'd559322;
assign OMEGA[18] = 32'd311979;
assign OMEGA[19] = 32'd609515;
assign OMEGA[20] = 32'd33307;
assign OMEGA[21] = 32'd471529;
assign OMEGA[22] = 32'd403973;
assign OMEGA[23] = 32'd66393;
assign OMEGA[24] = 32'd278638;
assign OMEGA[25] = 32'd640716;
assign OMEGA[26] = 32'd511029;
assign OMEGA[27] = 32'd160853;
assign OMEGA[28] = 32'd3852;
assign OMEGA[29] = 32'd499518;
assign OMEGA[30] = 32'd171177;
assign OMEGA[31] = 32'd335715;
end
18:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd396584;
assign OMEGA[2] = 32'd30199;
assign OMEGA[3] = 32'd83522;
assign OMEGA[4] = 32'd618577;
assign OMEGA[5] = 32'd119065;
assign OMEGA[6] = 32'd287738;
assign OMEGA[7] = 32'd205542;
assign OMEGA[8] = 32'd39539;
assign OMEGA[9] = 32'd65109;
assign OMEGA[10] = 32'd20594;
assign OMEGA[11] = 32'd192973;
assign OMEGA[12] = 32'd710220;
assign OMEGA[13] = 32'd666144;
assign OMEGA[14] = 32'd625388;
assign OMEGA[15] = 32'd749856;
assign OMEGA[16] = 32'd703865;
assign OMEGA[17] = 32'd311979;
assign OMEGA[18] = 32'd130893;
assign OMEGA[19] = 32'd150581;
assign OMEGA[20] = 32'd518288;
assign OMEGA[21] = 32'd432215;
assign OMEGA[22] = 32'd152859;
assign OMEGA[23] = 32'd85890;
assign OMEGA[24] = 32'd95907;
assign OMEGA[25] = 32'd429549;
assign OMEGA[26] = 32'd694809;
assign OMEGA[27] = 32'd185344;
assign OMEGA[28] = 32'd707662;
assign OMEGA[29] = 32'd156048;
assign OMEGA[30] = 32'd85413;
assign OMEGA[31] = 32'd417062;
end
19:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd256785;
assign OMEGA[2] = 32'd478993;
assign OMEGA[3] = 32'd150152;
assign OMEGA[4] = 32'd407285;
assign OMEGA[5] = 32'd623227;
assign OMEGA[6] = 32'd208264;
assign OMEGA[7] = 32'd313132;
assign OMEGA[8] = 32'd419570;
assign OMEGA[9] = 32'd726812;
assign OMEGA[10] = 32'd658531;
assign OMEGA[11] = 32'd504981;
assign OMEGA[12] = 32'd636864;
assign OMEGA[13] = 32'd356537;
assign OMEGA[14] = 32'd420984;
assign OMEGA[15] = 32'd15037;
assign OMEGA[16] = 32'd292270;
assign OMEGA[17] = 32'd609515;
assign OMEGA[18] = 32'd150581;
assign OMEGA[19] = 32'd360970;
assign OMEGA[20] = 32'd204540;
assign OMEGA[21] = 32'd669347;
assign OMEGA[22] = 32'd76052;
assign OMEGA[23] = 32'd256843;
assign OMEGA[24] = 32'd304079;
assign OMEGA[25] = 32'd711327;
assign OMEGA[26] = 32'd225810;
assign OMEGA[27] = 32'd143879;
assign OMEGA[28] = 32'd749049;
assign OMEGA[29] = 32'd118491;
assign OMEGA[30] = 32'd324050;
assign OMEGA[31] = 32'd496585;
end
20:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd37384;
assign OMEGA[2] = 32'd242407;
assign OMEGA[3] = 32'd162520;
assign OMEGA[4] = 32'd449816;
assign OMEGA[5] = 32'd176571;
assign OMEGA[6] = 32'd44525;
assign OMEGA[7] = 32'd108911;
assign OMEGA[8] = 32'd192891;
assign OMEGA[9] = 32'd20594;
assign OMEGA[10] = 32'd580733;
assign OMEGA[11] = 32'd55870;
assign OMEGA[12] = 32'd442845;
assign OMEGA[13] = 32'd531002;
assign OMEGA[14] = 32'd166525;
assign OMEGA[15] = 32'd774274;
assign OMEGA[16] = 32'd227304;
assign OMEGA[17] = 32'd33307;
assign OMEGA[18] = 32'd518288;
assign OMEGA[19] = 32'd204540;
assign OMEGA[20] = 32'd703351;
assign OMEGA[21] = 32'd90313;
assign OMEGA[22] = 32'd402025;
assign OMEGA[23] = 32'd495446;
assign OMEGA[24] = 32'd541910;
assign OMEGA[25] = 32'd48178;
assign OMEGA[26] = 32'd484772;
assign OMEGA[27] = 32'd85413;
assign OMEGA[28] = 32'd232841;
assign OMEGA[29] = 32'd35741;
assign OMEGA[30] = 32'd212000;
assign OMEGA[31] = 32'd498695;
end
21:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd391540;
assign OMEGA[2] = 32'd75805;
assign OMEGA[3] = 32'd562482;
assign OMEGA[4] = 32'd583946;
assign OMEGA[5] = 32'd687646;
assign OMEGA[6] = 32'd205542;
assign OMEGA[7] = 32'd378378;
assign OMEGA[8] = 32'd521066;
assign OMEGA[9] = 32'd521616;
assign OMEGA[10] = 32'd638882;
assign OMEGA[11] = 32'd715636;
assign OMEGA[12] = 32'd625388;
assign OMEGA[13] = 32'd538178;
assign OMEGA[14] = 32'd203599;
assign OMEGA[15] = 32'd659030;
assign OMEGA[16] = 32'd227037;
assign OMEGA[17] = 32'd471529;
assign OMEGA[18] = 32'd432215;
assign OMEGA[19] = 32'd669347;
assign OMEGA[20] = 32'd90313;
assign OMEGA[21] = 32'd344148;
assign OMEGA[22] = 32'd601028;
assign OMEGA[23] = 32'd735001;
assign OMEGA[24] = 32'd707662;
assign OMEGA[25] = 32'd66287;
assign OMEGA[26] = 32'd300470;
assign OMEGA[27] = 32'd90732;
assign OMEGA[28] = 32'd379148;
assign OMEGA[29] = 32'd56092;
assign OMEGA[30] = 32'd471785;
assign OMEGA[31] = 32'd40675;
end
22:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd506211;
assign OMEGA[2] = 32'd378557;
assign OMEGA[3] = 32'd201288;
assign OMEGA[4] = 32'd574433;
assign OMEGA[5] = 32'd528716;
assign OMEGA[6] = 32'd661;
assign OMEGA[7] = 32'd754262;
assign OMEGA[8] = 32'd598492;
assign OMEGA[9] = 32'd192973;
assign OMEGA[10] = 32'd55870;
assign OMEGA[11] = 32'd392025;
assign OMEGA[12] = 32'd566614;
assign OMEGA[13] = 32'd454779;
assign OMEGA[14] = 32'd64405;
assign OMEGA[15] = 32'd537003;
assign OMEGA[16] = 32'd709759;
assign OMEGA[17] = 32'd403973;
assign OMEGA[18] = 32'd152859;
assign OMEGA[19] = 32'd76052;
assign OMEGA[20] = 32'd402025;
assign OMEGA[21] = 32'd601028;
assign OMEGA[22] = 32'd462167;
assign OMEGA[23] = 32'd459139;
assign OMEGA[24] = 32'd167490;
assign OMEGA[25] = 32'd307440;
assign OMEGA[26] = 32'd623913;
assign OMEGA[27] = 32'd82433;
assign OMEGA[28] = 32'd93840;
assign OMEGA[29] = 32'd580891;
assign OMEGA[30] = 32'd679601;
assign OMEGA[31] = 32'd533286;
end
23:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd46078;
assign OMEGA[2] = 32'd369371;
assign OMEGA[3] = 32'd590239;
assign OMEGA[4] = 32'd526015;
assign OMEGA[5] = 32'd92730;
assign OMEGA[6] = 32'd254498;
assign OMEGA[7] = 32'd382999;
assign OMEGA[8] = 32'd127964;
assign OMEGA[9] = 32'd781654;
assign OMEGA[10] = 32'd337942;
assign OMEGA[11] = 32'd379686;
assign OMEGA[12] = 32'd632118;
assign OMEGA[13] = 32'd711140;
assign OMEGA[14] = 32'd360967;
assign OMEGA[15] = 32'd259691;
assign OMEGA[16] = 32'd572653;
assign OMEGA[17] = 32'd66393;
assign OMEGA[18] = 32'd85890;
assign OMEGA[19] = 32'd256843;
assign OMEGA[20] = 32'd495446;
assign OMEGA[21] = 32'd735001;
assign OMEGA[22] = 32'd459139;
assign OMEGA[23] = 32'd702033;
assign OMEGA[24] = 32'd544026;
assign OMEGA[25] = 32'd223951;
assign OMEGA[26] = 32'd99709;
assign OMEGA[27] = 32'd159550;
assign OMEGA[28] = 32'd785772;
assign OMEGA[29] = 32'd247999;
assign OMEGA[30] = 32'd588159;
assign OMEGA[31] = 32'd310574;
end
24:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd774248;
assign OMEGA[2] = 32'd553592;
assign OMEGA[3] = 32'd618577;
assign OMEGA[4] = 32'd22234;
assign OMEGA[5] = 32'd44525;
assign OMEGA[6] = 32'd39539;
assign OMEGA[7] = 32'd521066;
assign OMEGA[8] = 32'd145617;
assign OMEGA[9] = 32'd710220;
assign OMEGA[10] = 32'd442845;
assign OMEGA[11] = 32'd566614;
assign OMEGA[12] = 32'd703865;
assign OMEGA[13] = 32'd223306;
assign OMEGA[14] = 32'd227037;
assign OMEGA[15] = 32'd518288;
assign OMEGA[16] = 32'd240719;
assign OMEGA[17] = 32'd278638;
assign OMEGA[18] = 32'd95907;
assign OMEGA[19] = 32'd304079;
assign OMEGA[20] = 32'd541910;
assign OMEGA[21] = 32'd707662;
assign OMEGA[22] = 32'd167490;
assign OMEGA[23] = 32'd544026;
assign OMEGA[24] = 32'd304570;
assign OMEGA[25] = 32'd212000;
assign OMEGA[26] = 32'd555203;
assign OMEGA[27] = 32'd47064;
assign OMEGA[28] = 32'd593542;
assign OMEGA[29] = 32'd658469;
assign OMEGA[30] = 32'd581606;
assign OMEGA[31] = 32'd581864;
end
25:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd373978;
assign OMEGA[2] = 32'd748398;
assign OMEGA[3] = 32'd371867;
assign OMEGA[4] = 32'd176571;
assign OMEGA[5] = 32'd196467;
assign OMEGA[6] = 32'd770058;
assign OMEGA[7] = 32'd64262;
assign OMEGA[8] = 32'd580733;
assign OMEGA[9] = 32'd546705;
assign OMEGA[10] = 32'd735859;
assign OMEGA[11] = 32'd17845;
assign OMEGA[12] = 32'd774274;
assign OMEGA[13] = 32'd344232;
assign OMEGA[14] = 32'd494417;
assign OMEGA[15] = 32'd443648;
assign OMEGA[16] = 32'd703351;
assign OMEGA[17] = 32'd640716;
assign OMEGA[18] = 32'd429549;
assign OMEGA[19] = 32'd711327;
assign OMEGA[20] = 32'd48178;
assign OMEGA[21] = 32'd66287;
assign OMEGA[22] = 32'd307440;
assign OMEGA[23] = 32'd223951;
assign OMEGA[24] = 32'd212000;
assign OMEGA[25] = 32'd350679;
assign OMEGA[26] = 32'd531935;
assign OMEGA[27] = 32'd624289;
assign OMEGA[28] = 32'd348591;
assign OMEGA[29] = 32'd387309;
assign OMEGA[30] = 32'd289490;
assign OMEGA[31] = 32'd63867;
end
26:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd238971;
assign OMEGA[2] = 32'd349011;
assign OMEGA[3] = 32'd479511;
assign OMEGA[4] = 32'd692593;
assign OMEGA[5] = 32'd156288;
assign OMEGA[6] = 32'd777959;
assign OMEGA[7] = 32'd445344;
assign OMEGA[8] = 32'd204827;
assign OMEGA[9] = 32'd666144;
assign OMEGA[10] = 32'd531002;
assign OMEGA[11] = 32'd454779;
assign OMEGA[12] = 32'd223306;
assign OMEGA[13] = 32'd389180;
assign OMEGA[14] = 32'd691382;
assign OMEGA[15] = 32'd620108;
assign OMEGA[16] = 32'd361486;
assign OMEGA[17] = 32'd511029;
assign OMEGA[18] = 32'd694809;
assign OMEGA[19] = 32'd225810;
assign OMEGA[20] = 32'd484772;
assign OMEGA[21] = 32'd300470;
assign OMEGA[22] = 32'd623913;
assign OMEGA[23] = 32'd99709;
assign OMEGA[24] = 32'd555203;
assign OMEGA[25] = 32'd531935;
assign OMEGA[26] = 32'd588387;
assign OMEGA[27] = 32'd127902;
assign OMEGA[28] = 32'd76213;
assign OMEGA[29] = 32'd394408;
assign OMEGA[30] = 32'd443728;
assign OMEGA[31] = 32'd582834;
end
27:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd328930;
assign OMEGA[2] = 32'd83522;
assign OMEGA[3] = 32'd634235;
assign OMEGA[4] = 32'd287738;
assign OMEGA[5] = 32'd466860;
assign OMEGA[6] = 32'd65109;
assign OMEGA[7] = 32'd521616;
assign OMEGA[8] = 32'd710220;
assign OMEGA[9] = 32'd572970;
assign OMEGA[10] = 32'd749856;
assign OMEGA[11] = 32'd99947;
assign OMEGA[12] = 32'd130893;
assign OMEGA[13] = 32'd96064;
assign OMEGA[14] = 32'd432215;
assign OMEGA[15] = 32'd508906;
assign OMEGA[16] = 32'd95907;
assign OMEGA[17] = 32'd160853;
assign OMEGA[18] = 32'd185344;
assign OMEGA[19] = 32'd143879;
assign OMEGA[20] = 32'd85413;
assign OMEGA[21] = 32'd90732;
assign OMEGA[22] = 32'd82433;
assign OMEGA[23] = 32'd159550;
assign OMEGA[24] = 32'd47064;
assign OMEGA[25] = 32'd624289;
assign OMEGA[26] = 32'd127902;
assign OMEGA[27] = 32'd406344;
assign OMEGA[28] = 32'd529459;
assign OMEGA[29] = 32'd776641;
assign OMEGA[30] = 32'd391861;
assign OMEGA[31] = 32'd442201;
end
28:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd701020;
assign OMEGA[2] = 32'd87416;
assign OMEGA[3] = 32'd583946;
assign OMEGA[4] = 32'd231230;
assign OMEGA[5] = 32'd108911;
assign OMEGA[6] = 32'd521066;
assign OMEGA[7] = 32'd583657;
assign OMEGA[8] = 32'd346775;
assign OMEGA[9] = 32'd625388;
assign OMEGA[10] = 32'd166525;
assign OMEGA[11] = 32'd64405;
assign OMEGA[12] = 32'd227037;
assign OMEGA[13] = 32'd691382;
assign OMEGA[14] = 32'd11338;
assign OMEGA[15] = 32'd90313;
assign OMEGA[16] = 32'd601265;
assign OMEGA[17] = 32'd3852;
assign OMEGA[18] = 32'd707662;
assign OMEGA[19] = 32'd749049;
assign OMEGA[20] = 32'd232841;
assign OMEGA[21] = 32'd379148;
assign OMEGA[22] = 32'd93840;
assign OMEGA[23] = 32'd785772;
assign OMEGA[24] = 32'd593542;
assign OMEGA[25] = 32'd348591;
assign OMEGA[26] = 32'd76213;
assign OMEGA[27] = 32'd529459;
assign OMEGA[28] = 32'd591484;
assign OMEGA[29] = 32'd12159;
assign OMEGA[30] = 32'd238283;
assign OMEGA[31] = 32'd198039;
end
29:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd370404;
assign OMEGA[2] = 32'd462383;
assign OMEGA[3] = 32'd126263;
assign OMEGA[4] = 32'd537850;
assign OMEGA[5] = 32'd88211;
assign OMEGA[6] = 32'd495470;
assign OMEGA[7] = 32'd311422;
assign OMEGA[8] = 32'd204569;
assign OMEGA[9] = 32'd705169;
assign OMEGA[10] = 32'd598211;
assign OMEGA[11] = 32'd58797;
assign OMEGA[12] = 32'd709809;
assign OMEGA[13] = 32'd569319;
assign OMEGA[14] = 32'd230564;
assign OMEGA[15] = 32'd682287;
assign OMEGA[16] = 32'd454592;
assign OMEGA[17] = 32'd499518;
assign OMEGA[18] = 32'd156048;
assign OMEGA[19] = 32'd118491;
assign OMEGA[20] = 32'd35741;
assign OMEGA[21] = 32'd56092;
assign OMEGA[22] = 32'd580891;
assign OMEGA[23] = 32'd247999;
assign OMEGA[24] = 32'd658469;
assign OMEGA[25] = 32'd387309;
assign OMEGA[26] = 32'd394408;
assign OMEGA[27] = 32'd776641;
assign OMEGA[28] = 32'd12159;
assign OMEGA[29] = 32'd581232;
assign OMEGA[30] = 32'd307570;
assign OMEGA[31] = 32'd518721;
end
30:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd374544;
assign OMEGA[2] = 32'd162520;
assign OMEGA[3] = 32'd119065;
assign OMEGA[4] = 32'd44525;
assign OMEGA[5] = 32'd770058;
assign OMEGA[6] = 32'd20594;
assign OMEGA[7] = 32'd638882;
assign OMEGA[8] = 32'd442845;
assign OMEGA[9] = 32'd749856;
assign OMEGA[10] = 32'd774274;
assign OMEGA[11] = 32'd537003;
assign OMEGA[12] = 32'd518288;
assign OMEGA[13] = 32'd620108;
assign OMEGA[14] = 32'd90313;
assign OMEGA[15] = 32'd429549;
assign OMEGA[16] = 32'd541910;
assign OMEGA[17] = 32'd171177;
assign OMEGA[18] = 32'd85413;
assign OMEGA[19] = 32'd324050;
assign OMEGA[20] = 32'd212000;
assign OMEGA[21] = 32'd471785;
assign OMEGA[22] = 32'd679601;
assign OMEGA[23] = 32'd588159;
assign OMEGA[24] = 32'd581606;
assign OMEGA[25] = 32'd289490;
assign OMEGA[26] = 32'd443728;
assign OMEGA[27] = 32'd391861;
assign OMEGA[28] = 32'd238283;
assign OMEGA[29] = 32'd307570;
assign OMEGA[30] = 32'd730280;
assign OMEGA[31] = 32'd710381;
end
31:
begin
assign OMEGA[0] = 32'd786177;
assign OMEGA[1] = 32'd182294;
assign OMEGA[2] = 32'd652868;
assign OMEGA[3] = 32'd547334;
assign OMEGA[4] = 32'd727428;
assign OMEGA[5] = 32'd538434;
assign OMEGA[6] = 32'd109976;
assign OMEGA[7] = 32'd380089;
assign OMEGA[8] = 32'd583481;
assign OMEGA[9] = 32'd454570;
assign OMEGA[10] = 32'd10291;
assign OMEGA[11] = 32'd50877;
assign OMEGA[12] = 32'd137586;
assign OMEGA[13] = 32'd171325;
assign OMEGA[14] = 32'd89456;
assign OMEGA[15] = 32'd492234;
assign OMEGA[16] = 32'd518833;
assign OMEGA[17] = 32'd335715;
assign OMEGA[18] = 32'd417062;
assign OMEGA[19] = 32'd496585;
assign OMEGA[20] = 32'd498695;
assign OMEGA[21] = 32'd40675;
assign OMEGA[22] = 32'd533286;
assign OMEGA[23] = 32'd310574;
assign OMEGA[24] = 32'd581864;
assign OMEGA[25] = 32'd63867;
assign OMEGA[26] = 32'd582834;
assign OMEGA[27] = 32'd442201;
assign OMEGA[28] = 32'd198039;
assign OMEGA[29] = 32'd518721;
assign OMEGA[30] = 32'd710381;
assign OMEGA[31] = 32'd112867;
end



    endcase




endgenerate

    
endmodule