`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:03:36 03/08/2014 
// Design Name: 
// Module Name:    main_game 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module main_game(
		input clock,
		input in
    );
	
	 parameter MAP_HEIGHT = 24,
			   MAP_WIDTH = 80,
			   MAP_MIDDLE = 40,
               MARGIN_TOP = 1,
	           PADDLE_WIDTH = 2,
		       PADDLE_HEIGHT = 10,
			   PADDLE_0_COLUMN = 6,
			   PADDLE_1_COLUMN = 74,
			   TARGET_SCORE = 10;
			   	   
	 reg [7:0] paddle_0_x = 5;
	 reg [7:0] paddle_0_y = 8;
	 reg paddle_0_up, paddle_0_down; 
	 
	 // PADDLE_0
	 always@(posedge clock) begin
		
		if(paddle_0_up && paddle_0_x > 1) begin
			paddle_0_x <= paddle_0_x - 1;
		end
		
		else if(paddle_0_down && paddle_0_x + PADDLE_HEIGHT < MAP_HEIGHT - 1) begin
			paddle_0_x <= paddle_0_x + 1;
		end
		
	 end
	 
	 reg [7:0] paddle_1_x = 75;
	 reg [7:0] paddle_1_y = 8;
	 reg paddle_1_up, paddle_1_down;
	 
	 // PADDLE_1
	 always@(posedge clock) begin
		
		if(paddle_1_up && paddle_1_x > 1) begin
			paddle_1_x <= paddle_1_x - 1;
		end
		
		else if(paddle_1_down && paddle_1_x + PADDLE_HEIGHT < MAP_HEIGHT - 1) begin
			paddle_1_x <= paddle_1_y + 1;
		end
		
	 end
	 
	 reg direction_x = 1,direction_y = 1; // 0 -> -1, 1 -> 1
	 reg reflect_x,reflect_y;
	 
	 // BALL_DIRECTION
	 always@(posedge clock) begin
		if(reflect_x) direction_x <= !direction_x;
		else if(reflect_y) direction_y <= !direction_y;
	 end
	 
	 reg [7:0] ball_x;
	 reg [7:0] ball_y;
	 reg reset_ball, move_ball; 
	 
	 // BALL_POSITION
	 always@(posedge clock) begin
		
		if(reset_ball) begin
			ball_x <= (MAP_WIDTH + 1)>>1;
			ball_y <= (MAP_HEIGHT + 1)>>1;
		end
		
		else if(move_ball) begin
			
			if(direction_x == 0) begin
				ball_x <= ball_x - 1;
			end
			
			else begin
				ball_x <= ball_x + 1;
			end
			
			if(direction_y == 0) begin
				ball_y <= ball_y - 1;
			end
			
			else begin
				ball_y <= ball_y + 1;
			end
		
		end
		
	 end
	 
	 reg [3:0] score_0;
	 reg [3:0] score_1;
	 reg reset_score, update_0, update_1;
	 // SCORE
	 always@(posedge clock) begin
		if(reset_score) begin
			score_0 <= 0;
			score_1 <= 0;
		end
		else if(update_0) score_0 <= score_0 + 1;
		else if(update_1) score_1 <= score_1 + 1;
	 end
	 
	 reg [22:0] ball_counter;

	 // BALL_COUNTER
	 always@(posedge clock) begin
		ball_counter <= ball_counter + 1;
	 end
	
	 wire received, rev_signal, ball_signal;
	 wire [7:0] received_data;
	 assign ball_signal = (ball_counter == 0);

	 receiver receiver_module(clock, in, received, received_data);
	 singleP singleP_module(clock, received, rev_signal);
	 //mapper mapper_module(clock, ball_x, ball_y, paddle_0_x, paddle_0_y, paddle_1_x, paddle_1_y, score_0, score_1);
	 
	 reg [2:0] pstate = 0, nstate;
	 parameter [2:0] READY=0, START=1, PLAY=2, DEATH0=3, DEATH1=4;
	 // GAME STATE
	 always@(posedge clock) begin
		pstate <= nstate;
	 end
	 
	 // CONTROL UNIT
	 always@(*) begin
	 
		paddle_0_up = 0;
		paddle_0_down = 0;
		paddle_1_up = 0;
		paddle_1_down = 0;
		
		reset_ball = 0;
		move_ball = 0;
		
		reflect_x = 0;
		reflect_y = 0;
		
		reset_score = 0;
		update_0 = 0;
		update_1 = 0;
		
		nstate = READY;
		
		case(pstate) 
			
			READY : begin 
				reset_ball = 1;
				reset_score = 1;
				// 'y' = start the game
				if(rev_signal && received_data == 121) nstate = START;
			end
			
			START : begin
				nstate = PLAY;
			end
			
			PLAY : begin 
				if(direction_x == 0) begin
					if(ball_x - 1 == 0) nstate = DEATH0;
					else begin
						if(ball_x - 1 == PADDLE_0_COLUMN && ball_y >= paddle_0_y && ball_y < paddle_0_y + PADDLE_HEIGHT) begin
							reflect_x = 1;
						end
						if(direction_y == 0 && ball_y - 1 == 0) reflect_y = 1;
						if(direction_y == 1 && ball_y + 1 == MAP_HEIGHT-1) reflect_y = 1;
						nstate = PLAY;
					end
				end
				
				else begin
					if(ball_x + 1 >= MAP_WIDTH-1) nstate = DEATH1;
					else begin
						if(ball_x + 1 == PADDLE_1_COLUMN && ball_y >= paddle_1_y && ball_y < paddle_1_y + PADDLE_HEIGHT) begin
							reflect_x = 1;
						end
						if(direction_y == 0 && ball_y - 1 == 0) reflect_y = 1;
						if(direction_y == 1 && ball_y + 1 == MAP_HEIGHT-1) reflect_y = 1;
						nstate = PLAY;
					end
				end
			end
		
			DEATH0 : begin 
				update_1 = 1;
				if(score_1 + 1 == TARGET_SCORE) nstate = READY;
				else nstate = PLAY;
			end
			
			DEATH1 : begin
				update_0 = 1;
				if(score_0 + 1 == TARGET_SCORE) nstate = READY;
				else nstate = PLAY;
			end
			
		endcase
		
		if(rev_signal) begin
		
			// 's' = paddle_0_up
			if(received_data == 119) begin
				paddle_0_up = 1;
			end
		
			// 'w' = paddle_0_down
			else if(received_data == 115) begin
				paddle_0_down = 1;
			end
			
			// 'p' = paddle_1_up
			else if(received_data == 112) begin
				paddle_1_up = 1;
			end
		
			// 'l' = paddle_1_down
			else if(received_data == 108) begin
				paddle_1_down = 1;
			end
		end	

		if(ball_signal) begin
			move_ball = 1;
		end
		
	 end
	 
endmodule

module singleP(
		input clock,
		input X,
		output reg P
	);
	
	reg temp;
	
	always@(posedge clock) begin	
		
		if(X==0) begin
			temp <= 0;
			P <= 0;
		end
		
		else begin
			if(temp) begin
				P <= 0;
			end
			else begin
				P <= 1;
				temp <= 1;
			end
		end
	end
	
endmodule
