`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:57:09 03/08/2014
// Design Name:   mapper
// Module Name:   C:/Users/zxxcv/Documents/GitHub/PongInwInw/FPGAPONG/mapper_test.v
// Project Name:  FPGAPONG
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mapper
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mapper_test;

	// Inputs
	reg clock;
	reg [7:0] ball_x;
	reg [7:0] ball_y;
	reg [7:0] paddle_0_x;
	reg [7:0] paddle_0_y;
	reg [7:0] paddle_1_x;
	reg [7:0] paddle_1_y;
	reg [3:0] score_0;
	reg [3:0] score_1;
	reg start;

	// Outputs
	wire out;
	wire busy;
	wire [7:0] out_row;
	wire [7:0] out_col;
	wire [7:0] out_to_send;
	wire [3:0] out_state;
	wire [7:0] out_map;

	// Instantiate the Unit Under Test (UUT)
	mapper uut (
		.clock(clock), 
		.out(out), 
		.ball_x(ball_x), 
		.ball_y(ball_y), 
		.paddle_0_x(paddle_0_x), 
		.paddle_0_y(paddle_0_y), 
		.paddle_1_x(paddle_1_x), 
		.paddle_1_y(paddle_1_y), 
		.score_0(score_0), 
		.score_1(score_1), 
		.start(start), 
		.busy(busy), 
		.out_row(out_row), 
		.out_col(out_col), 
		.out_to_send(out_to_send),
		.out_state(out_state),
		.out_map(out_map)
	);

	
   // Note: CLK must be defined as a wire when using this method
   
   parameter PERIOD = 100;

   initial begin
      clock = 1'b0;
      #(PERIOD/2);
      forever
         #(PERIOD/2) clock = ~clock;
   end
				

	initial begin
		// Initialize Inputs
		clock = 0;
		ball_x = 0;
		ball_y = 0;
		paddle_0_x = 0;
		paddle_0_y = 0;
		paddle_1_x = 0;
		paddle_1_y = 0;
		score_0 = 0;
		score_1 = 0;
		start = 0;

		// Wait 100 ns for global reset to finish
		#121;
		start = 1;
		#100;
		start = 0;
        
		// Add stimulus here
		#100000;
		$stop;
	end
      
endmodule

