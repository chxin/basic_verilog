// Copyright 2011 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

//
// 32 bit CRC of 64 data bits (reversed - MSB first)
// polynomial : 1edc6f41 
//    x^28 + x^27 + x^26 + x^25 + x^23 + x^22 + x^20 + x^19 + x^18 + x^14 + x^13 + x^11 + x^10 + x^9 + x^8 + x^6 + x^0
//
//        CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD 
//        00000000001111111111222222222233 0000000000111111111122222222223333333333444444444455555555556666 
//        01234567890123456789012345678901 0123456789012345678901234567890123456789012345678901234567890123 
// C00  = ...###....##.####..#.##....#..#. ................................................................ 
// C01  = #...###....##.####..#.##....#..# ................................................................ 
// C02  = ##...###....##.####..#.##....#.. ................................................................ 
// C03  = .##...###....##.####..#.##....#. ................................................................ 
// C04  = #.##...###....##.####..#.##....# ................................................................ 
// C05  = ##.##...###....##.####..#.##.... ................................................................ 
// C06  = ####.....#...###.#..#....#..#.#. ................................................................ 
// C07  = .####.....#...###.#..#....#..#.# ................................................................ 
// C08  = #.#.......#..##..#...#.......... ................................................................ 
// C09  = .#..##....#..#..#.##.#.....#..#. ................................................................ 
// C10  = #.###.#...#..#.###..##.....##.## ................................................................ 
// C11  = .#.....#..#..#.#.###.......##### ................................................................ 
// C12  = ..#.....#..#..#.#.###.......#### ................................................................ 
// C13  = ....##...######.##..#.#....#.#.# ................................................................ 
// C14  = #..##.#.....#...####..##...##... ................................................................ 
// C15  = .#..##.#.....#...####..##...##.. ................................................................ 
// C16  = #.#..##.#.....#...####..##...##. ................................................................ 
// C17  = ##.#..##.#.....#...####..##...## ................................................................ 
// C18  = .###.#.##..#.###...##..#..#...## ................................................................ 
// C19  = #.#..##.######.....##.#.#.....## ................................................................ 
// C20  = .#..####.#..#..##..##.##.#.#..## ................................................................ 
// C21  = #.#..####.#..#..##..##.##.#.#..# ................................................................ 
// C22  = .#..#######..#.#####....##...##. ................................................................ 
// C23  = #.###.####...#.#.##.###..###...# ................................................................ 
// C24  = .#.###.####...#.#.##.###..###... ................................................................ 
// C25  = #.##..#.##...##.##..##.##...###. ................................................................ 
// C26  = .#...#.#.#.#.#..####....##.#.#.# ................................................................ 
// C27  = #.#####.#..###.####.###..####... ................................................................ 
// C28  = ##....##.####..#.##....#..#.###. ................................................................ 
// C29  = ###....##.####..#.##....#..#.### ................................................................ 
// C30  = .###....##.####..#.##....#..#.## ................................................................ 
// C31  = ..###....##.####..#.##....#..#.# ................................................................ 
//
// Number of XORs used is 32
// Maximum XOR input count is 21
//   Best possible depth in 4 LUTs = 3
//   Best possible depth in 5 LUTs = 2
//   Best possible depth in 6 LUTs = 2
// Total XOR inputs 484
//
// Special signal relations -
//    none
//

module crc32c_zer64 (c,crc_out);
input[31:0] c;
output[31:0] crc_out;
wire[31:0] crc_out;

parameter METHOD = 1;

generate 
	if (METHOD == 0)
		crc32c_zer64_flat cc (.c(c),.crc_out(crc_out));
	else
		crc32c_zer64_factor cc (.c(c),.crc_out(crc_out));
endgenerate

endmodule

module crc32c_zer64_flat (c,crc_out);
input[31:0] c;
output[31:0] crc_out;
wire[31:0] crc_out;

assign crc_out[0] =
    c[3] ^ c[4] ^ c[5] ^ c[10] ^ c[11] ^ c[13] ^ 
    c[14] ^ c[15] ^ c[16] ^ c[19] ^ c[21] ^ c[22] ^ c[27] ^ 
    c[30];

assign crc_out[1] =
    c[0] ^ c[4] ^ c[5] ^ c[6] ^ c[11] ^ c[12] ^ 
    c[14] ^ c[15] ^ c[16] ^ c[17] ^ c[20] ^ c[22] ^ c[23] ^ 
    c[28] ^ c[31];

assign crc_out[2] =
    c[0] ^ c[1] ^ c[5] ^ c[6] ^ c[7] ^ c[12] ^ 
    c[13] ^ c[15] ^ c[16] ^ c[17] ^ c[18] ^ c[21] ^ c[23] ^ 
    c[24] ^ c[29];

assign crc_out[3] =
    c[1] ^ c[2] ^ c[6] ^ c[7] ^ c[8] ^ c[13] ^ 
    c[14] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[22] ^ c[24] ^ 
    c[25] ^ c[30];

assign crc_out[4] =
    c[0] ^ c[2] ^ c[3] ^ c[7] ^ c[8] ^ c[9] ^ 
    c[14] ^ c[15] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[23] ^ 
    c[25] ^ c[26] ^ c[31];

assign crc_out[5] =
    c[0] ^ c[1] ^ c[3] ^ c[4] ^ c[8] ^ c[9] ^ 
    c[10] ^ c[15] ^ c[16] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^ 
    c[24] ^ c[26] ^ c[27];

assign crc_out[6] =
    c[0] ^ c[1] ^ c[2] ^ c[3] ^ c[9] ^ c[13] ^ 
    c[14] ^ c[15] ^ c[17] ^ c[20] ^ c[25] ^ c[28] ^ c[30];

assign crc_out[7] =
    c[1] ^ c[2] ^ c[3] ^ c[4] ^ c[10] ^ c[14] ^ 
    c[15] ^ c[16] ^ c[18] ^ c[21] ^ c[26] ^ c[29] ^ c[31];

assign crc_out[8] =
    c[0] ^ c[2] ^ c[10] ^ c[13] ^ c[14] ^ c[17] ^ 
    c[21];

assign crc_out[9] =
    c[1] ^ c[4] ^ c[5] ^ c[10] ^ c[13] ^ c[16] ^ 
    c[18] ^ c[19] ^ c[21] ^ c[27] ^ c[30];

assign crc_out[10] =
    c[0] ^ c[2] ^ c[3] ^ c[4] ^ c[6] ^ c[10] ^ 
    c[13] ^ c[15] ^ c[16] ^ c[17] ^ c[20] ^ c[21] ^ c[27] ^ 
    c[28] ^ c[30] ^ c[31];

assign crc_out[11] =
    c[1] ^ c[7] ^ c[10] ^ c[13] ^ c[15] ^ c[17] ^ 
    c[18] ^ c[19] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];

assign crc_out[12] =
    c[2] ^ c[8] ^ c[11] ^ c[14] ^ c[16] ^ c[18] ^ 
    c[19] ^ c[20] ^ c[28] ^ c[29] ^ c[30] ^ c[31];

assign crc_out[13] =
    c[4] ^ c[5] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ 
    c[13] ^ c[14] ^ c[16] ^ c[17] ^ c[20] ^ c[22] ^ c[27] ^ 
    c[29] ^ c[31];

assign crc_out[14] =
    c[0] ^ c[3] ^ c[4] ^ c[6] ^ c[12] ^ c[16] ^ 
    c[17] ^ c[18] ^ c[19] ^ c[22] ^ c[23] ^ c[27] ^ c[28];

assign crc_out[15] =
    c[1] ^ c[4] ^ c[5] ^ c[7] ^ c[13] ^ c[17] ^ 
    c[18] ^ c[19] ^ c[20] ^ c[23] ^ c[24] ^ c[28] ^ c[29];

assign crc_out[16] =
    c[0] ^ c[2] ^ c[5] ^ c[6] ^ c[8] ^ c[14] ^ 
    c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[24] ^ c[25] ^ c[29] ^ 
    c[30];

assign crc_out[17] =
    c[0] ^ c[1] ^ c[3] ^ c[6] ^ c[7] ^ c[9] ^ 
    c[15] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[25] ^ c[26] ^ 
    c[30] ^ c[31];

assign crc_out[18] =
    c[1] ^ c[2] ^ c[3] ^ c[5] ^ c[7] ^ c[8] ^ 
    c[11] ^ c[13] ^ c[14] ^ c[15] ^ c[19] ^ c[20] ^ c[23] ^ 
    c[26] ^ c[30] ^ c[31];

assign crc_out[19] =
    c[0] ^ c[2] ^ c[5] ^ c[6] ^ c[8] ^ c[9] ^ 
    c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[19] ^ c[20] ^ c[22] ^ 
    c[24] ^ c[30] ^ c[31];

assign crc_out[20] =
    c[1] ^ c[4] ^ c[5] ^ c[6] ^ c[7] ^ c[9] ^ 
    c[12] ^ c[15] ^ c[16] ^ c[19] ^ c[20] ^ c[22] ^ c[23] ^ 
    c[25] ^ c[27] ^ c[30] ^ c[31];

assign crc_out[21] =
    c[0] ^ c[2] ^ c[5] ^ c[6] ^ c[7] ^ c[8] ^ 
    c[10] ^ c[13] ^ c[16] ^ c[17] ^ c[20] ^ c[21] ^ c[23] ^ 
    c[24] ^ c[26] ^ c[28] ^ c[31];

assign crc_out[22] =
    c[1] ^ c[4] ^ c[5] ^ c[6] ^ c[7] ^ c[8] ^ 
    c[9] ^ c[10] ^ c[13] ^ c[15] ^ c[16] ^ c[17] ^ c[18] ^ 
    c[19] ^ c[24] ^ c[25] ^ c[29] ^ c[30];

assign crc_out[23] =
    c[0] ^ c[2] ^ c[3] ^ c[4] ^ c[6] ^ c[7] ^ 
    c[8] ^ c[9] ^ c[13] ^ c[15] ^ c[17] ^ c[18] ^ c[20] ^ 
    c[21] ^ c[22] ^ c[25] ^ c[26] ^ c[27] ^ c[31];

assign crc_out[24] =
    c[1] ^ c[3] ^ c[4] ^ c[5] ^ c[7] ^ c[8] ^ 
    c[9] ^ c[10] ^ c[14] ^ c[16] ^ c[18] ^ c[19] ^ c[21] ^ 
    c[22] ^ c[23] ^ c[26] ^ c[27] ^ c[28];

assign crc_out[25] =
    c[0] ^ c[2] ^ c[3] ^ c[6] ^ c[8] ^ c[9] ^ 
    c[13] ^ c[14] ^ c[16] ^ c[17] ^ c[20] ^ c[21] ^ c[23] ^ 
    c[24] ^ c[28] ^ c[29] ^ c[30];

assign crc_out[26] =
    c[1] ^ c[5] ^ c[7] ^ c[9] ^ c[11] ^ c[13] ^ 
    c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[24] ^ c[25] ^ c[27] ^ 
    c[29] ^ c[31];

assign crc_out[27] =
    c[0] ^ c[2] ^ c[3] ^ c[4] ^ c[5] ^ c[6] ^ 
    c[8] ^ c[11] ^ c[12] ^ c[13] ^ c[15] ^ c[16] ^ c[17] ^ 
    c[18] ^ c[20] ^ c[21] ^ c[22] ^ c[25] ^ c[26] ^ c[27] ^ 
    c[28];

assign crc_out[28] =
    c[0] ^ c[1] ^ c[6] ^ c[7] ^ c[9] ^ c[10] ^ 
    c[11] ^ c[12] ^ c[15] ^ c[17] ^ c[18] ^ c[23] ^ c[26] ^ 
    c[28] ^ c[29] ^ c[30];

assign crc_out[29] =
    c[0] ^ c[1] ^ c[2] ^ c[7] ^ c[8] ^ c[10] ^ 
    c[11] ^ c[12] ^ c[13] ^ c[16] ^ c[18] ^ c[19] ^ c[24] ^ 
    c[27] ^ c[29] ^ c[30] ^ c[31];

assign crc_out[30] =
    c[1] ^ c[2] ^ c[3] ^ c[8] ^ c[9] ^ c[11] ^ 
    c[12] ^ c[13] ^ c[14] ^ c[17] ^ c[19] ^ c[20] ^ c[25] ^ 
    c[28] ^ c[30] ^ c[31];

assign crc_out[31] =
    c[2] ^ c[3] ^ c[4] ^ c[9] ^ c[10] ^ c[12] ^ 
    c[13] ^ c[14] ^ c[15] ^ c[18] ^ c[20] ^ c[21] ^ c[26] ^ 
    c[29] ^ c[31];

endmodule


module crc32c_zer64_factor (c,crc_out);
input[31:0] c;
output[31:0] crc_out;
wire[31:0] crc_out;

wire[47:0] h ;

xor6 cx_0 (crc_out[0],    h[2] , h[8] , h[10] , h[13] , h[46] , 1'b0);
xor6 cx_1 (crc_out[1],    h[6] , h[13] , h[14] , h[28] , h[45] , 1'b0);
xor6 cx_2 (crc_out[2],    c[21] , c[23] , h[0] , h[5] , h[14] , h[34]);
xor6 cx_3 (crc_out[3],    c[24] , h[0] , h[1] , h[4] , h[44] , 1'b0);
xor6 cx_4 (crc_out[4],    h[8] , h[42] , h[43] , h[47] , 1'b0 , 1'b0);
xor6 cx_5 (crc_out[5],    h[0] , h[7] , h[9] , h[13] , h[40] , 1'b0);
xor6 cx_6 (crc_out[6],    h[1] , h[4] , h[12] , h[14] , h[39] , 1'b0);
xor6 cx_7 (crc_out[7],    h[2] , h[7] , h[11] , h[38] , 1'b0 , 1'b0);
xor6 cx_8 (crc_out[8],    c[0] , c[14] , h[3] , h[47] , 1'b0 , 1'b0);
xor6 cx_9 (crc_out[9],    c[7] , c[30] , c[31] , h[0] , h[3] , h[13]);
xor6 cx_10 (crc_out[10],    h[1] , h[3] , h[13] , h[14] , h[36] , h[41]);
xor6 cx_11 (crc_out[11],    c[30] , h[0] , h[2] , h[35] , 1'b0 , 1'b0);
xor6 cx_12 (crc_out[12],    c[13] , c[14] , c[18] , h[1] , h[10] , h[37]);
xor6 cx_13 (crc_out[13],    c[3] , h[2] , h[12] , h[13] , h[28] , 1'b0);
xor6 cx_14 (crc_out[14],    h[13] , h[14] , h[15] , h[27] , h[32] , h[41]);
xor6 cx_15 (crc_out[15],    c[4] , h[0] , h[5] , h[6] , 1'b0 , 1'b0);
xor6 cx_16 (crc_out[16],    c[14] , c[21] , h[1] , h[4] , h[5] , h[43]);
xor6 cx_17 (crc_out[17],    h[0] , h[4] , h[7] , h[14] , h[22] , h[31]);
xor6 cx_18 (crc_out[18],    h[0] , h[1] , h[8] , h[10] , h[30] , 1'b0);
xor6 cx_19 (crc_out[19],    c[24] , h[1] , h[10] , h[15] , h[29] , 1'b0);
xor6 cx_20 (crc_out[20],    c[31] , h[0] , h[4] , h[13] , h[15] , h[27]);
xor6 cx_21 (crc_out[21],    h[1] , h[2] , h[5] , h[14] , h[26] , h[27]);
xor6 cx_22 (crc_out[22],    h[0] , h[4] , h[5] , h[25] , h[33] , 1'b0);
xor6 cx_23 (crc_out[23],    h[1] , h[7] , h[14] , h[22] , h[24] , 1'b0);
xor6 cx_24 (crc_out[24],    c[28] , h[0] , h[7] , h[13] , h[23] , 1'b0);
xor6 cx_25 (crc_out[25],    h[1] , h[7] , h[8] , h[14] , h[21] , h[37]);
xor6 cx_26 (crc_out[26],    h[0] , h[2] , h[13] , h[20] , h[33] , 1'b0);
xor6 cx_27 (crc_out[27],    h[1] , h[7] , h[13] , h[14] , h[15] , h[19]);
xor6 cx_28 (crc_out[28],    c[28] , h[0] , h[2] , h[10] , h[14] , h[18]);
xor6 cx_29 (crc_out[29],    h[0] , h[1] , h[9] , h[10] , h[17] , h[34]);
xor6 cx_30 (crc_out[30],    h[1] , h[6] , h[10] , h[12] , h[16] , 1'b0);
xor6 cx_31 (crc_out[31],    c[8] , c[12] , h[1] , h[2] , h[7] , h[11]);
xor6 hx_0 (h[0],    c[1] , c[7] , c[18] , c[19] , 1'b0 , 1'b0);   // used by 14
xor6 hx_1 (h[1],    c[2] , c[8] , c[13] , c[20] , 1'b0 , 1'b0);   // used by 14
xor6 hx_2 (h[2],    c[10] , c[13] , c[29] , c[31] , 1'b0 , 1'b0);   // used by 8
xor6 hx_3 (h[3],    c[10] , c[13] , c[21] , c[31] , 1'b0 , 1'b0);   // used by 3
xor6 hx_4 (h[4],    c[6] , c[20] , c[25] , c[30] , 1'b0 , 1'b0);   // used by 6
xor6 hx_5 (h[5],    c[5] , c[13] , c[24] , c[29] , 1'b0 , 1'b0);   // used by 5
xor6 hx_6 (h[6],    c[17] , c[20] , c[23] , c[28] , 1'b0 , 1'b0);   // used by 3
xor6 hx_7 (h[7],    c[3] , c[9] , c[21] , c[26] , 1'b0 , 1'b0);   // used by 8
xor6 hx_8 (h[8],    c[3] , c[14] , c[15] , c[26] , 1'b0 , 1'b0);   // used by 4
xor6 hx_9 (h[9],    c[0] , c[8] , c[20] , c[24] , 1'b0 , 1'b0);   // used by 2
xor6 hx_10 (h[10],    c[11] , c[19] , c[30] , c[31] , 1'b0 , 1'b0);   // used by 7
xor6 hx_11 (h[11],    c[4] , c[13] , c[14] , c[15] , c[18] , 1'b0);   // used by 2
xor6 hx_12 (h[12],    c[3] , c[9] , c[14] , c[20] , 1'b0 , 1'b0);   // used by 3
xor6 hx_13 (h[13],    c[4] , c[5] , c[16] , c[27] , 1'b0 , 1'b0);   // used by 11
xor6 hx_14 (h[14],    c[0] , c[6] , c[15] , c[17] , 1'b0 , 1'b0);   // used by 11
xor6 hx_15 (h[15],    c[9] , c[12] , c[18] , c[22] , 1'b0 , 1'b0);   // used by 4
xor6 hx_16 (h[16],    c[1] , c[12] , c[23] , c[25] , 1'b0 , 1'b0);   // used by 1
xor6 hx_17 (h[17],    c[8] , c[10] , c[27] , c[29] , 1'b0 , 1'b0);   // used by 1
xor6 hx_18 (h[18],    c[9] , c[12] , c[13] , c[23] , c[26] , 1'b0);   // used by 1
xor6 hx_19 (h[19],    c[11] , c[25] , c[28] , 1'b0 , 1'b0 , 1'b0);   // used by 1
xor6 hx_20 (h[20],    c[11] , c[24] , c[25] , 1'b0 , 1'b0 , 1'b0);   // used by 1
xor6 hx_21 (h[21],    c[3] , c[23] , c[24] , c[30] , 1'b0 , 1'b0);   // used by 1
xor6 hx_22 (h[22],    c[18] , c[22] , c[31] , 1'b0 , 1'b0 , 1'b0);   // used by 2
xor6 hx_23 (h[23],    c[8] , c[10] , c[14] , c[22] , c[23] , 1'b0);   // used by 1
xor6 hx_24 (h[24],    c[4] , c[7] , c[25] , c[27] , 1'b0 , 1'b0);   // used by 1
xor6 hx_25 (h[25],    c[8] , c[15] , c[16] , c[20] , 1'b0 , 1'b0);   // used by 1
xor6 hx_26 (h[26],    c[7] , c[16] , c[21] , c[26] , c[28] , 1'b0);   // used by 1
xor6 hx_27 (h[27],    c[15] , c[23] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 3
xor6 hx_28 (h[28],    c[11] , c[12] , c[17] , c[22] , 1'b0 , 1'b0);   // used by 2
xor6 hx_29 (h[29],    c[0] , c[5] , c[6] , c[10] , c[18] , 1'b0);   // used by 1
xor6 hx_30 (h[30],    c[5] , c[18] , c[19] , c[23] , 1'b0 , 1'b0);   // used by 1
xor6 hx_31 (h[31],    c[6] , c[17] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
xor6 hx_32 (h[32],    c[9] , c[19] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
xor6 hx_33 (h[33],    c[4] , c[9] , c[10] , c[17] , 1'b0 , 1'b0);   // used by 2
xor6 hx_34 (h[34],    c[12] , c[16] , c[19] , 1'b0 , 1'b0 , 1'b0);   // used by 2
xor6 hx_35 (h[35],    c[15] , c[17] , c[27] , c[28] , 1'b0 , 1'b0);   // used by 1
xor6 hx_36 (h[36],    c[8] , c[13] , c[30] , 1'b0 , 1'b0 , 1'b0);   // used by 1
xor6 hx_37 (h[37],    c[16] , c[28] , c[29] , 1'b0 , 1'b0 , 1'b0);   // used by 2
xor6 hx_38 (h[38],    c[1] , c[2] , c[9] , c[16] , 1'b0 , 1'b0);   // used by 1
xor6 hx_39 (h[39],    c[1] , c[8] , c[28] , 1'b0 , 1'b0 , 1'b0);   // used by 1
xor6 hx_40 (h[40],    c[5] , c[7] , c[10] , c[15] , 1'b0 , 1'b0);   // used by 1
xor6 hx_41 (h[41],    c[3] , c[5] , c[28] , 1'b0 , 1'b0 , 1'b0);   // used by 2
xor6 hx_42 (h[42],    c[7] , c[8] , c[9] , c[23] , c[25] , 1'b0);   // used by 1
xor6 hx_43 (h[43],    c[0] , c[18] , c[19] , c[20] , 1'b0 , 1'b0);   // used by 2
xor6 hx_44 (h[44],    c[14] , c[16] , c[17] , c[22] , 1'b0 , 1'b0);   // used by 1
xor6 hx_45 (h[45],    c[14] , c[27] , c[31] , 1'b0 , 1'b0 , 1'b0);   // used by 1
xor6 hx_46 (h[46],    c[21] , c[22] , c[26] , c[29] , 1'b0 , 1'b0);   // used by 1
xor6 hx_47 (h[47],    c[2] , c[17] , c[31] , 1'b0 , 1'b0 , 1'b0);   // used by 2
endmodule


