`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:06:30 03/08/2014 
// Design Name: 
// Module Name:    mapper 
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
module mapper(
	input clock,
   output out, //CONNECT TO TX. (FOR SENDER)
	//BALL POSITION.
	input [7:0] ball_x,
	input [7:0] ball_y,
	//FIRST PADDLE POSITION.
	input [7:0] paddle_0_x,
	input [7:0] paddle_0_y,
	//SECOND PADDLE POSITION.
	input [7:0] paddle_1_x,
	input [7:0] paddle_1_y,
    //SCORE.
    input [3:0] score_0,
    input [3:0] score_1,
	input start,
	output busy
	
	//For testing only.
	/*,
	output [7:0] out_row,
	output [7:0] out_col,
	output [7:0] out_to_send,
	output [3:0] out_state
	*/
	);

parameter MAP_HEIGHT = 24,
		  MAP_WIDTH = 80,
          MAP_MIDDLE = 40,
          MARGIN_TOP = 1,
	      PADDLE_WIDTH = 2,
		  PADDLE_HEIGHT = 10;

reg _busy = 0;
assign busy = _busy;

reg [MAP_WIDTH - 1 : 0] map [0 : MAP_HEIGHT - 1];
reg [3:0] digit [0 : 9][0 : 4]; //digit[number][row][col]


//###############################################################
//INIT ARRAY

integer i, j;

initial begin
	
	for (i = 0; i < MAP_HEIGHT; i = i + 1) begin
		for (j = 0; j < MAP_WIDTH; j = j + 1) begin
			map[i][j] = 0;
		end
	end

   //digit: zero
   digit[0][0] = 4'b1111;
   digit[0][1] = 4'b1001;
   digit[0][2] = 4'b1001;
   digit[0][3] = 4'b1001;
   digit[0][4] = 4'b1111;
   //digit: one
   digit[1][0] = 4'b0001;
   digit[1][1] = 4'b0001;
   digit[1][2] = 4'b0001;
   digit[1][3] = 4'b0001;
   digit[1][4] = 4'b0001;
   //digit: two
   digit[2][0] = 4'b1111;
   digit[2][1] = 4'b0001;
   digit[2][2] = 4'b1111;
   digit[2][3] = 4'b1000;
   digit[2][4] = 4'b1111;
   //digit: three
   digit[3][0] = 4'b1111;
   digit[3][1] = 4'b0001;
   digit[3][2] = 4'b1111;
   digit[3][3] = 4'b0001;
   digit[3][4] = 4'b1111;
   //digit: four
   digit[4][0] = 4'b1001;
   digit[4][1] = 4'b1001;
   digit[4][2] = 4'b1111;
   digit[4][3] = 4'b0001;
   digit[4][4] = 4'b0001;
   //digit: five
   digit[5][0] = 4'b1111;
   digit[5][1] = 4'b1000;
   digit[5][2] = 4'b1111;
   digit[5][3] = 4'b0001;
   digit[5][4] = 4'b1111;
   //digit: six
   digit[6][0] = 4'b1111;
   digit[6][1] = 4'b1000;
   digit[6][2] = 4'b1111;
   digit[6][3] = 4'b1001;
   digit[6][4] = 4'b1111;
   //digit: seven
   digit[7][0] = 4'b1111;
   digit[7][1] = 4'b0001;
   digit[7][2] = 4'b0001;
   digit[7][3] = 4'b0001;
   digit[7][4] = 4'b0001;
   //digit: eight
   digit[8][0] = 4'b1111;
   digit[8][1] = 4'b1001;
   digit[8][2] = 4'b1111;
   digit[8][3] = 4'b1001;
   digit[8][4] = 4'b1111;
   //digit: nine
   digit[9][0] = 4'b1111;
   digit[9][1] = 4'b1001;
   digit[9][2] = 4'b1111;
   digit[9][3] = 4'b0001;
   digit[9][4] = 4'b1111;
end
//END INITIAL ARARY
//###############################################################

//###############################################################
//CLEAR ARRAY
reg arr_clear = 0;
reg w_frame = 0;
reg w_score = 0;
reg w_ball = 0;
reg w_paddle = 0;
 integer k,m,n,o,p,q;
always @ (posedge clock) begin
   if(arr_clear) begin
   	for(k = 0; k < MAP_HEIGHT; k = k + 1) begin
   		map[k] = 0;
   	end
   end
	
	else if(w_frame) begin
      for(m = 0; m < MAP_HEIGHT; m = m + 1) begin
         map[m][0] = 1;
         map[m][MAP_WIDTH-1] = 1;
      end

      for(m = 0; m < MAP_WIDTH; m = m + 1) begin
         map[0][m] = 1;
         map[MAP_HEIGHT-1][m] = 1;
      end
   end
	
	else if(w_score) begin
      //WRITE COLLON
      map[1][MAP_MIDDLE] = 1;
      map[3][MAP_MIDDLE] = 1;
      //WRITE SCORE
      for(n = 0; n < 5; n = n + 1) begin
			for(q = 0; q < 4; q = q + 1) begin
				//SCORE PLAYER 1.
				map[MARGIN_TOP + n][q + MAP_MIDDLE - 5] = digit[score_0][n][q];
			end
			for(q = 0; q < 4; q = q + 1) begin
				//SCORE PLAYER 2.
				map[MARGIN_TOP + n][q + MAP_MIDDLE + 1] = digit[score_1][n][q];
			end
      end
   end
	
	else if(w_ball) begin
      map[ball_y][ball_x] = 1;
   end
	
	else if(w_paddle) begin
      for(p = 0; p < PADDLE_HEIGHT; p = p + 1) begin
			map[paddle_0_y + p][paddle_0_x] = 1;
         map[paddle_1_y + p][paddle_1_x] = 1;
         map[paddle_0_y + p][paddle_0_x + 1] = 1;
         map[paddle_1_y + p][paddle_1_x + 1] = 1;
      end
   end
end

//###############################################################
//MAPPER CORE
reg [3:0] state = 0, next_state = 0;
reg [7:0] row = 0, col = 0;
reg [7:0] to_send;

assign out_state = state;
assign out_row = row;
assign out_col = col;
assign out_to_send = to_send;

reg send_start = 0, reset_row = 0, reset_col = 0, inc_row = 0, inc_col = 0;

sender s(clock, send_start, to_send, sender_busy, out);

always @ (posedge clock) begin
   if(reset_col) col <= 0;
   else if(inc_col) col <= col + 1;
end
always @ (posedge clock) begin
   if(reset_row) row <= 0;
   else if(inc_row) row <= row + 1;
end

always @ (state, start, sender_busy, row, col) begin
   arr_clear = 0;
   w_frame = 0;
   w_score = 0;
   w_paddle = 0;
   w_ball = 0;
   send_start = 0;
   reset_row = 0; reset_col = 0; inc_row = 0; inc_col = 0;
   //NORMALLY SET TO BUSY, EXCEPT THE IDLE STATE.
   _busy = 1;
	case(state)
		0: begin
         //IDLE STATE, NOT BUSY.
         _busy = 0;
			if(start) next_state = 1;
			else next_state = 0;
		end
      //CLEAR THE FRAME. (CLEAR ARRAY)
		1: begin
			arr_clear = 1;
			next_state = 2;
		end
      //WRITE THE FRAME,
      //WRITE SCORE,
      //WRITE NEW PADDLES,
      //INTO ARRAY
		2: begin
         w_frame = 1;
         w_score = 1;
			w_paddle = 1;
			next_state = 3;
		end
      //WRITE BALL INTO ARRAY.
		3: begin
			w_ball = 1;
         next_state = 4;
		end
      //START TRANSMIT TO THE SENDER.
		4: begin
         reset_row = 1;
         reset_col = 1;
         next_state = 11;
		end
		11: begin next_state = 5; end
      5: begin
         if(row < MAP_HEIGHT) next_state = 6;
         else next_state = 0; //END
      end
      6: begin
         if(col < MAP_WIDTH) next_state = 7;
         else next_state = 10;
      end
      7: begin
         //to_send = map[row][col] ? 8'b1011_0010 : 8'b0100_0001;//8'b0010_0000;
         to_send = map[row][col] ? 8'b0100_0011 : 8'b0010_0000;
			send_start = 1;
         next_state = 8;
      end
      8: begin
         //next_state = 9;
			
			if(sender_busy) next_state = 8;
         else next_state = 9;
      end
      9: begin
         inc_col = 1;
         next_state = 12;
      end
		12: begin next_state = 6; end
      10: begin
         inc_row = 1;
         reset_col = 1;
         next_state = 13;
      end
		13: begin next_state = 5; end
	endcase
end

always @ (posedge clock) begin
	state <= next_state;
end

//END MAPPER CORE
//###############################################################

endmodule
