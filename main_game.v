`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:04:30 03/08/2014 
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
		input in,
		output out
    );
	
	 parameter MAP_HEIGHT = 24, // MAP PARAMETER
			     MAP_WIDTH = 80,
			     MAP_MIDDLE = 30,
              MARGIN_TOP = 1,
				  MARGIN_BOT = 22,
				  MARGIN_LEFT = 7,
				  MARGIN_RIGHT = 72,
				  PERIOD_CLOCK = 29,
				  
		        PADDLE_HEIGHT = 5, // PADDLE PARAMETER
			     
				  TARGET_SCORE = 9;
	   	   
				
// ---------------------- PADDLE0 DATA PATH ------------------------------

	 reg [7:0] paddle_0_x = MARGIN_LEFT + 5;
	 reg [7:0] paddle_0_y = 9;
	 reg paddle_0_up, paddle_0_down, reset_paddle_0; 
	 
	 // PADDLE_0
	 always@(posedge clock) begin
		
		if(reset_paddle_0) paddle_0_y <= 9;
 		
		else if(paddle_0_up && paddle_0_y > MARGIN_TOP + 1) begin
			paddle_0_y <= paddle_0_y - 1;
		end
		
		else if(paddle_0_down && paddle_0_y + PADDLE_HEIGHT - 1 < MARGIN_BOT - 1) begin
			paddle_0_y <= paddle_0_y + 1;
	   end
		
	 end
// -----------------------------------------------------------------------


// ---------------------- PADDLE1 DATA PATH ------------------------------

	 reg [7:0] paddle_1_x = MARGIN_RIGHT - 5;
	 reg [7:0] paddle_1_y = 9;
	 reg paddle_1_up, paddle_1_down, reset_paddle_1;
	 
	 // PADDLE_1
	 always@(posedge clock) begin
	 
		if(reset_paddle_1) paddle_1_y <= 9;
		
		else if(paddle_1_up && paddle_1_y > MARGIN_TOP + 1) begin
			paddle_1_y <= paddle_1_y - 1;
		end
		
		else if(paddle_1_down && paddle_1_y + PADDLE_HEIGHT - 1 < MARGIN_BOT - 1) begin
			paddle_1_y <= paddle_1_y + 1;
		end
		
	 end
// ------------------------------------------------------------------------


// --------------------- BALL DERECTION DATA PATH -------------------------- 
	 
	 reg direction_x = 1,direction_y = 1; // 0 -> -1, 1 -> 1
	 reg reflect_x,reflect_y;
	 
	 // BALL_DIRECTION
	 always@(posedge clock) begin
		if(reflect_x) direction_x <= !direction_x;
		else if(reflect_y) direction_y <= !direction_y;
	 end
// -------------------------------------------------------------------------


// --------------------- BALL POSITION DATA PATH ----------------------------	 
	 reg [7:0] ball_x = (MARGIN_LEFT + MARGIN_RIGHT)>>1;
	 reg [7:0] ball_y = (MARGIN_TOP + MARGIN_BOT)>>1;
	 reg reset_ball, move_ball; 

	 // BALL_POSITION
	 always@(posedge clock) begin
		
		if(reset_ball) begin
			ball_x <= (MARGIN_LEFT + MARGIN_RIGHT)>>1;
			ball_y <= (MARGIN_TOP + MARGIN_BOT)>>1;
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
// -------------------------------------------------------------------


// ----------------- SCORE DATA PATH ----------------------------------

	 reg [3:0] score_0 = 0;
	 reg [3:0] score_1 = 0;
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
	 
// -------------------------------------------------------------------

	 reg [21:0] ball_counter1;
	 reg [20:0] ball_counter2;
	 reg [20:0] ball_counter3;

	 // BALL_COUNTER
	 always@(posedge clock) begin
		
		if(ball_counter1 == 22'd3200000) ball_counter1 <= 0;
		else ball_counter1 <= ball_counter1 + 1;

		ball_counter2 <= ball_counter2 + 1;
		
		if(ball_counter3 == 21'd1300000) ball_counter3 <= 0;
		else ball_counter3 <= ball_counter3 + 1;
	 end
	 
	 reg [19:0] map_counter;
	 
	 // MAP_COUNTER
	 always@(posedge clock) begin
		map_counter <= map_counter + 1;
	 end
	 
	 // GAME_PERIOD
	 reg [PERIOD_CLOCK-1 : 0] p_clock;
	 reg reset_p_clock, run_p_clock;
	 always@(posedge clock) begin
		if(reset_p_clock) p_clock <= 0;
		else if(run_p_clock) p_clock <= p_clock + 1;
	 end
	
	 // WIRE
	 wire received, rev_signal, ball_signal;
	 wire [7:0] received_data;
	 wire map_signal = (map_counter == 0);
	 wire game_start, game_end;

	 receiver receiver_module(clock, in, received, received_data);
	 singleP singleP_module(clock, received, rev_signal);
	 mapper mapper_module(clock, out, ball_x, ball_y, paddle_0_x, paddle_0_y, paddle_1_x, paddle_1_y, score_0, score_1, map_signal, game_start, game_end, map_busy);
	 
	 reg [3:0] pstate = 0, nstate;
	 parameter [4:0] READY=0, START=1, PLAY1=2, DEATH0=3, DEATH1=4, INIT=5, WAIT=6, SAVE=7, PLAY2=8, PLAY3=9;
	 
	 // GAME STATE
	 always@(posedge clock) begin
		pstate <= nstate;
	 end
	 
	 assign game_start = (pstate != READY);
	 assign game_end = (pstate == READY); 
	 assign ball_signal = (pstate == PLAY1) ? (ball_counter1 == 0) : ((pstate == PLAY2) ? (ball_counter2 == 0) : ((pstate == PLAY3) ? (ball_counter3 == 0) : 0));
	 
// --------------------- CONTROL UNIT -------------------------------
 	 
	 always@(*) begin
	 
		paddle_0_up = 0;
		paddle_0_down = 0;
		reset_paddle_0 = 0;
		
		paddle_1_up = 0;
		paddle_1_down = 0;
		reset_paddle_1 = 0;
		
		reset_ball = 0;
		move_ball = 0;
		
		reflect_x = 0;
		reflect_y = 0;
		
		reset_score = 0;
		update_0 = 0;
		update_1 = 0;
		
		reset_p_clock = 0;
		run_p_clock = 0;
		
		nstate = READY;
		
		case(pstate) 
					
			READY : begin 
				// 'space' = start the game
				if(rev_signal && received_data == 32) nstate = INIT;
				else nstate = READY;
			end
			
			INIT : begin
				reset_score = 1;
				nstate = START;
			end
			
			START : begin
				reset_ball = 1;
				reset_paddle_0 = 1;
				reset_paddle_1 = 1;
				reset_p_clock = 1;
				nstate = PLAY1;
				
			end
			
			PLAY1 : begin 
				run_p_clock = 1;
				if(direction_x == 0 && ball_x - 1 == MARGIN_LEFT) nstate = DEATH0;
			   else if(direction_x == 1 && ball_x + 1 == MARGIN_RIGHT) nstate = DEATH1;		
				else if(p_clock == (1<<PERIOD_CLOCK)-1) nstate = PLAY2;
				else nstate = PLAY1;
			end
			
			PLAY2 : begin
				run_p_clock = 1;
				if(direction_x == 0 && ball_x - 1 == MARGIN_LEFT) nstate = DEATH0;
			   else if(direction_x == 1 && ball_x + 1 == MARGIN_RIGHT) nstate = DEATH1;
				else if(p_clock == (1<<PERIOD_CLOCK)-1) nstate = PLAY3;
				else nstate = PLAY2;
			end
			
			PLAY3 : begin
				run_p_clock = 1;
				if(direction_x == 0 && ball_x - 1 == MARGIN_LEFT) nstate = DEATH0;
			   else if(direction_x == 1 && ball_x + 1 == MARGIN_RIGHT) nstate = DEATH1;	
				else nstate = PLAY3;
			end
		
			DEATH0 : begin 
				update_1 = 1;
				if(score_1 + 1 == TARGET_SCORE) nstate = WAIT;
				else nstate = START;
			end
			
			DEATH1 : begin
				update_0 = 1;
				if(score_0 + 1 == TARGET_SCORE) nstate = WAIT;
				else nstate = START;
			end
			
			WAIT : begin
				if(map_signal) nstate = SAVE;
				else nstate = WAIT;
			end
			
			SAVE : begin
				nstate = READY;
			end
			
		endcase
		
		if(pstate == PLAY1 || pstate == PLAY2 || pstate == PLAY3) begin
		
			if(direction_x == 0) begin
			
				if(direction_y == 0) begin
					if(ball_x - 1 == paddle_0_x && ball_y - 1 >= paddle_0_y && ball_y - 1 < paddle_0_y + PADDLE_HEIGHT) begin
						reflect_x = 1;
					end
					if(ball_y - 1 == MARGIN_TOP) reflect_y = 1;
				end
			
				else if(direction_y == 1) begin
					if(ball_x - 1 == paddle_0_x && ball_y + 1 >= paddle_0_y && ball_y + 1 < paddle_0_y + PADDLE_HEIGHT) begin
						reflect_x = 1;
					end
					if(ball_y + 1 == MARGIN_BOT) reflect_y = 1;
				end
			end
			
			else begin
		
				if(direction_y == 0) begin
					if(ball_x + 1 == paddle_1_x && ball_y - 1 >= paddle_1_y && ball_y - 1 < paddle_1_y + PADDLE_HEIGHT) begin
						reflect_x = 1;
					end
					if(ball_y - 1 == MARGIN_TOP) reflect_y = 1;
				end
			
				else if(direction_y == 1) begin
					if(ball_x + 1 == paddle_1_x && ball_y + 1 >= paddle_1_y && ball_y + 1 < paddle_1_y + PADDLE_HEIGHT) begin
						reflect_x = 1;
					end
					if(ball_y + 1 == MARGIN_BOT) reflect_y = 1;
				end		
			end
		end
		
		if(rev_signal && pstate != READY) begin
		
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

		if(ball_signal && pstate != READY) begin
			move_ball = 1;
		end
		
	 end

// --------------------------------------------------------------------------

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
