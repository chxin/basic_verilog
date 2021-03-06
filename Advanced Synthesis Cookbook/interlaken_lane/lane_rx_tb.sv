`timescale 1 ps / 1 ps
// Copyright 2009 Altera Corporation. All rights reserved.  
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

// baeckler - 02-26-2009
// Note - this file was generated by a small C program

// It does detailed inspection of the lane RX response
// to skew and error conditions, per spec 1.2

module lane_rx_tb ();

localparam WIDTH = 20;
localparam SAMPLE_BYTES = (WIDTH / 4) + 2;
localparam META_FRAME_LEN = 100;

/////////////////////////////////////
// load sample data out of file
/////////////////////////////////////
reg [WIDTH-1:0] lane_bits,lane_bits_err;
reg clk = 0, arst = 0;

integer pfile = 0, pfile_err;

initial begin
	pfile = $fopen ("lane_bits.txt","r");
    if (pfile == 0) begin
        $display ("Unable to read lane_bits data file");
        $stop();
    end
	pfile_err = $fopen ("lane_bits_err.txt","r");
    if (pfile_err == 0) begin
        $display ("Unable to read lane_bits_err data file");
        $stop();
    end
end

reg [SAMPLE_BYTES*8-1:0] buffer;
integer r,s = 0;
always @(negedge clk) begin
  r = $fgets (buffer,pfile);	
  r = $sscanf (buffer,"%x",lane_bits);
  s = s + 1;
  r = $fgets (buffer,pfile_err);	
  r = $sscanf (buffer,"%x",lane_bits_err);
end

/////////////////////////////////////
// shift sample data 
/////////////////////////////////////
reg [2*WIDTH-1:0] sample_dat;
always @(posedge clk or posedge arst) begin
	if (arst) sample_dat <= 0;
	else sample_dat <= (sample_dat << WIDTH) | lane_bits;
end

/////////////////////////////////////
// test units
//    look at all (width) shifts of the
//   input stream
/////////////////////////////////////
wire [65:0] dout [0:WIDTH-1];
wire [WIDTH-1:0] dout_valid,word_locked,sync_locked;
wire [WIDTH-1:0] framing_error,crc32_error,scrambler_mismatch,missing_sync;
reg [15:0] words_to_sync_lock [0:WIDTH-1];

genvar i;
generate
	for (i=0; i<WIDTH; i=i+1)
	begin : du
		lane_rx lr (
			.clk,.arst,
			.din(sample_dat[2*WIDTH-1-i:WIDTH-i]),
			.dout(dout[i]),
			.dout_valid(dout_valid[i]),
			.word_locked(word_locked[i]),
			.sync_locked(sync_locked[i]),
			.framing_error(framing_error[i]),
			.crc32_error(crc32_error[i]),
			.scrambler_mismatch(scrambler_mismatch[i]),
			.missing_sync(missing_sync[i])
		);
		defparam lr .META_FRAME_LEN = META_FRAME_LEN;

        // monitor time from word lock to meta frame sync
        always @(posedge clk or posedge arst) begin
            if (arst) words_to_sync_lock[i] <= 0;
            else begin
                if (!word_locked[i]) words_to_sync_lock[i] <= 0;
                else if (!sync_locked[i] & dout_valid[i]) words_to_sync_lock[i] <= words_to_sync_lock[i] + 1'b1;
            end
        end
    end
endgenerate

/////////////////////////////////////
// spec rules
/////////////////////////////////////
reg fail = 1'b0;

// Observe lane locking
wire all_aligned = &word_locked;
wire all_locked = &sync_locked;
initial begin
   // allow 1200 words to acquire word alignment.
   // This is data dependent, could in theory take forever
   #40200
   if (!all_aligned) begin
      $display ("Failed to acquire word alignment within expected window");
      fail = 1;
   end

   // allow 4 more frames to acquire frame lock
   #13400
   if (!all_locked) begin
      $display ("Failed to acquire frame lock within expected window");
      fail = 1;
   end
end

// Lanes should sync lock after word lock +4 good sync words, not earlier or later
integer n;
initial begin
   @(posedge all_locked) begin
      for (n=0; n<WIDTH;n=n+1) begin
         if (words_to_sync_lock[n] < 300) begin
            $display ("Chan %d acquired sync in less than 3 frames",n);
            fail = 1;
         end
         
         // allow a little bit of slush for propagation latency
         // 4.01 frames is 4
         if (words_to_sync_lock[n] > (400 + 4)) begin
            $display ("Chan %d failed to acquired sync lock in 4 frames",n);
            fail = 1;
         end
      end
   end
   @(negedge clk);
   if (!fail) $display ("All 20 shifted data test lanes have locked properly");
end

// Locked lanes should not have any error flags
integer k;
always @(posedge clk) begin
   #1 
   for (k=0; k<WIDTH;k=k+1) begin
     if (sync_locked[k]) begin
       if (crc32_error[k] | framing_error[k] | scrambler_mismatch[k] | missing_sync[k]) begin
         $display ("Chan %d is reporting an unexpected error",k);
         fail = 1;
       end
     end
   end
end

// Due dilligence that the data stream passing CRC is the original test string
reg [WIDTH-1:0] text_ok = 0;
integer y;
always @(posedge clk) begin
   for (y=0; y<WIDTH;y=y+1) begin
     if (sync_locked[y] & dout_valid[y] && dout[y] == " Humpty ") begin
       text_ok[y] = 1'b1;
     end
   end
end

////////////////////////////////////////////////
// look at response to corrupted data stream
////////////////////////////////////////////////
wire [65:0] dout_err;
wire dout_valid_err,word_locked_err,sync_locked_err;
wire framing_error_err,crc32_error_err,scrambler_mismatch_err,missing_sync_err;
reg [20-1:0] lane_bits_noise = 0;
reg lane_bits_noise_ena = 1'b0;
lane_rx dut_err (
		.clk,.arst,
		.din(lane_bits_err ^ (lane_bits_noise_ena ? lane_bits_noise : 19'b0)),
		.dout(dout_err),
		.dout_valid(dout_valid_err),
		.word_locked(word_locked_err),
		.sync_locked(sync_locked_err),
		.framing_error(framing_error_err),
		.crc32_error(crc32_error_err),
		.scrambler_mismatch(scrambler_mismatch_err),
		.missing_sync(missing_sync_err)
);
defparam dut_err .META_FRAME_LEN = META_FRAME_LEN;

always @(posedge clk) begin
   lane_bits_noise <= $random();end

reg good_error_response = 1'b0;
reg good_noise_recovery = 1'b0;
initial begin
   // look at response to framing layer errors in the data stream
   @(posedge sync_locked_err);
   @(posedge missing_sync_err);
   @(posedge missing_sync_err);
   @(posedge missing_sync_err);
   @(posedge crc32_error_err);
   @(posedge crc32_error_err);
   @(posedge scrambler_mismatch_err);
   @(posedge missing_sync_err);
   @(posedge missing_sync_err);
   $display ("Correct response to data stream with sync / scrambler / CRC32 errors");
   @(posedge scrambler_mismatch_err);
   @(posedge scrambler_mismatch_err);
   @(posedge scrambler_mismatch_err);
   @(negedge sync_locked_err);
   @(posedge sync_locked_err);
   good_error_response = 1'b1;
   $display ("Correct recovery from incorrect scrambler state");

   // look at response to catastrophic line noise
   @(negedge clk) lane_bits_noise_ena = 1'b1;
   @(negedge word_locked_err);
   #100 @(negedge clk) lane_bits_noise_ena = 1'b0;
   @(posedge framing_error_err);
   @(posedge word_locked_err);
   @(posedge sync_locked_err);
   good_noise_recovery = 1'b1;
   $display ("Correct recovery from catastrophic noise burst");
end

// stop shortly before data file is exhausted
always @(posedge clk) begin
   if (s == (16750-2)) begin
      if (~&text_ok) begin
        $display ("Sample text was not properly recovered on the dout");
        fail = 1'b1;
      end
      if (!good_error_response) begin
        $display ("dut_err did not respond properly to error injected data stream");
        fail = 1'b1;
      end
      if (!good_noise_recovery) begin
        $display ("dut_err did not recover from catastrophic noise burst");
        fail = 1'b1;
      end
   end
   else if (s == 16750) begin
      if (!fail) $display ("PASS");
      else $display ("FAIL");
      $stop();
   end
end

/////////////////////////////////////
// clock driver
/////////////////////////////////////
always begin
	#5 clk = ~clk;
end

initial begin
	arst = 0;
	#1 arst = 1;
	@(negedge clk) arst = 0;
end

endmodule
