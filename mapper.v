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
   input game_start,
   input game_end,
	output busy
	);

	parameter MAP_HEIGHT = 24, // MAP PARAMETERS
		 		 MAP_WIDTH = 80,
		 		 MAP_MIDDLE = 30,
             MARGIN_TOP = 1,
		       MARGIN_BOT = 22,
		       MARGIN_LEFT = 7,
		       MARGIN_RIGHT = 72,
				 
		       PADDLE_HEIGHT = 5, // PADDLE PARAMETER
			    
				 TARGET_SCORE = 9, 
             
				 CREDITS_LENGTH = 38, // TITLE PARAMETER
             INSTRUCTIONS_LENGTH = 22,
             COVER_MARGIN_TOP = 5,
             COVER_MARGIN_LEFT = MARGIN_LEFT + 5;

reg _busy = 0;
assign busy = _busy;

reg map [0 : MAP_HEIGHT - 1][0 : MAP_WIDTH - 1];
reg [5:0] digit [0 : 9][0 : 6]; //digit[number][row][col]
reg [3:0] alpha [0 : 25][0 : 4];
reg [7:0] credits [0 : CREDITS_LENGTH - 1];
reg [7:0] instructions [0 : INSTRUCTIONS_LENGTH - 1];


//###############################################################
//INIT ARRAY

integer i, j;

initial begin

   //credits: by Worrachate Bosri, Konpat Preechakul
   //by
   credits[0] = 98;
   credits[1] = 121;
   credits[2] = 32;
   //Worrachate
   credits[3] = 87;
   credits[4] = 111;
   credits[5] = 114;
   credits[6] = 114;
   credits[7] = 97;
   credits[8] = 99;
   credits[9] = 104;
   credits[10] = 97;
   credits[11] = 116;
   credits[12] = 101;
   credits[13] = 32;
   //Bosri
   credits[14] = 66;
   credits[15] = 111;
   credits[16] = 115;
   credits[17] = 114;
   credits[18] = 105;
   //,
   credits[19] = 44;
   credits[20] = 32;
   //Konpat
   credits[21] = 75;
   credits[22] = 111;
   credits[23] = 110;
   credits[24] = 112;
   credits[25] = 97;
   credits[26] = 116;
   credits[27] = 32;
   //Preechakul
   credits[28] = 80;
   credits[29] = 114;
   credits[30] = 101;
   credits[31] = 101;
   credits[32] = 99;
   credits[33] = 104;
   credits[34] = 97;
   credits[35] = 107;
   credits[36] = 117;
   credits[37] = 108;


   //Instructions: Press "space" to start
   //Press
   instructions[0] = 80;
   instructions[1] = 114;
   instructions[2] = 101;
   instructions[3] = 115;
   instructions[4] = 115;
   instructions[5] = 32;
   //"space"
   instructions[6] = 34;
   instructions[7] = 115;
   instructions[8] = 112;
   instructions[9] = 97;
   instructions[10] = 99;
   instructions[11] = 101;
   instructions[12] = 34;
   instructions[13] = 32;
   //to
   instructions[14] = 116;
   instructions[15] = 111;
   instructions[16] = 32;
   //start
   instructions[17] = 115;
   instructions[18] = 116;
   instructions[19] = 97;
   instructions[20] = 114;
   instructions[21] = 116;

   //digit: zero
	digit[0][0] = 6'b000000;
   digit[0][1] = 6'b011110;
   digit[0][2] = 6'b010010;
   digit[0][3] = 6'b010010;
   digit[0][4] = 6'b010010;
   digit[0][5] = 6'b011110;
	digit[0][6] = 6'b000000;
   //digit: one
	digit[1][0] = 6'b000000;
   digit[1][1] = 6'b000010;
   digit[1][2] = 6'b000010;
   digit[1][3] = 6'b000010;
   digit[1][4] = 6'b000010;
   digit[1][5] = 6'b000010;
	digit[1][6] = 6'b000000;
   //digit: two
	digit[2][0] = 6'b000000;
   digit[2][1] = 6'b011110;
   digit[2][2] = 6'b000010;
   digit[2][3] = 6'b011110;
   digit[2][4] = 6'b010000;
   digit[2][5] = 6'b011110;
	digit[2][6] = 6'b000000;
   //digit: three
	digit[3][0] = 6'b000000;
   digit[3][1] = 6'b011110;
   digit[3][2] = 6'b000010;
   digit[3][3] = 6'b011110;
   digit[3][4] = 6'b000010;
   digit[3][5] = 6'b011110;
	digit[3][6] = 6'b000000;
   //digit: four
	digit[4][0] = 6'b000000;
   digit[4][1] = 6'b010010;
   digit[4][2] = 6'b010010;
   digit[4][3] = 6'b011110;
   digit[4][4] = 6'b000010;
   digit[4][5] = 6'b000010;
	digit[4][6] = 6'b000000;
   //digit: five
	digit[5][0] = 6'b000000;
   digit[5][1] = 6'b011110;
   digit[5][2] = 6'b010000;
   digit[5][3] = 6'b011110;
   digit[5][4] = 6'b000010;
   digit[5][5] = 6'b011110;
	digit[5][6] = 6'b000000;
   //digit: six
	digit[6][0] = 6'b000000;
   digit[6][1] = 6'b011110;
   digit[6][2] = 6'b010000;
   digit[6][3] = 6'b011110;
   digit[6][4] = 6'b010010;
   digit[6][5] = 6'b011110;
	digit[6][6] = 6'b000000;
   //digit: seven
	digit[7][0] = 6'b000000;
   digit[7][1] = 6'b011110;
   digit[7][2] = 6'b000010;
   digit[7][3] = 6'b000010;
   digit[7][4] = 6'b000010;
   digit[7][5] = 6'b000010;
	digit[7][6] = 6'b000000;
   //digit: eight
	digit[8][0] = 6'b000000;
   digit[8][1] = 6'b011110;
   digit[8][2] = 6'b010010;
   digit[8][3] = 6'b011110;
   digit[8][4] = 6'b010010;
   digit[8][5] = 6'b011110;
	digit[8][6] = 6'b000000;
   //digit: nine
	digit[9][0] = 6'b000000;
   digit[9][1] = 6'b011110;
   digit[9][2] = 6'b010010;
   digit[9][3] = 6'b011110;
   digit[9][4] = 6'b000010;
   digit[9][5] = 6'b011110;
	digit[9][6] = 6'b000000;

   //#############################################################
   //ALPHABETS
   //Alpha: P
   alpha[0][0] = 4'b1110;
   alpha[0][1] = 4'b1001;
   alpha[0][2] = 4'b1110;
   alpha[0][3] = 4'b1000;
   alpha[0][4] = 4'b1000;
	//Alpha: O
   alpha[1][0] = 4'b0110;
   alpha[1][1] = 4'b1001;
   alpha[1][2] = 4'b1001;
   alpha[1][3] = 4'b1001;
   alpha[1][4] = 4'b0110;
	//Alpha: N
   alpha[2][0] = 4'b1001;
   alpha[2][1] = 4'b1101;
   alpha[2][2] = 4'b1111;
   alpha[2][3] = 4'b1011;
   alpha[2][4] = 4'b1001;
	//Alpha: G
   alpha[3][0] = 4'b0111;
   alpha[3][1] = 4'b1000;
   alpha[3][2] = 4'b1011;
   alpha[3][3] = 4'b1001;
   alpha[3][4] = 4'b0110;
	//Alpha: I
   alpha[4][0] = 4'b1110;
   alpha[4][1] = 4'b0100;
   alpha[4][2] = 4'b0100;
   alpha[4][3] = 4'b0100;
   alpha[4][4] = 4'b1110;
   //Alpha: W
   alpha[5][0] = 4'b1001;
   alpha[5][1] = 4'b1001;
   alpha[5][2] = 4'b1001;
   alpha[5][3] = 4'b1111;
   alpha[5][4] = 4'b1001;
end
//END INITIAL ARARY
//###############################################################

//###############################################################
//MODIFY ARRAY
reg arr_clear = 0;
reg w_frame = 0;
reg w_score = 0;
reg w_ball = 0;
reg w_paddle = 0;
reg w_title = 0;
reg title_clear = 0;

integer k,m,n,o,p,q;

always @ (posedge clock) begin

	if(arr_clear) begin

		for(k = MARGIN_TOP + 1; k < MARGIN_BOT; k = k + 1) begin
			for(m = MARGIN_LEFT + 1; m < MARGIN_RIGHT; m = m + 1) begin
				map[k][m] = 1'b0;
			end
   	end
		
		map[2][3] = 1'b0;
		map[3][4] = 1'b0;
		map[4][3] = 1'b0;
		map[5][4] = 1'b0;
		map[6][3] = 1'b0;
		
		map[2][76] = 1'b0;
		map[3][75] = 1'b0;
		map[4][76] = 1'b0;
		map[5][75] = 1'b0;
		map[6][76] = 1'b0;
		
		map[16][3] = 1'b0;
		map[17][4] = 1'b0;
		map[18][3] = 1'b0;
		map[19][4] = 1'b0;
		map[20][3] = 1'b0;
		map[21][4] = 1'b0;
		
		map[16][76] = 1'b0;
		map[17][75] = 1'b0;
		map[18][76] = 1'b0;
		map[19][75] = 1'b0;
		map[20][76] = 1'b0;
		map[21][75] = 1'b0;
    
      //WRITE SCORE
      for(n = 8; n <= 14; n = n + 1) begin
			for(q = 1; q <= 6; q = q + 1) begin
				//SCORE PLAYER 1.
				map[n][q] = digit[score_0][n-8][5-(q-1)];
			end
			for(q = 73; q <= 78; q = q + 1) begin
				//SCORE PLAYER 2.
				map[n][q] = digit[score_1][n-8][5-(q-73)];
			end
      end
   end

	else if(w_ball) begin
      map[ball_y][ball_x] = 1'b1;
   end

	else if(w_paddle) begin
      for(p = 0; p < PADDLE_HEIGHT; p = p + 1) begin
			map[paddle_0_y + p][paddle_0_x] = 1'b1;
         map[paddle_1_y + p][paddle_1_x] = 1'b1;
      end
   end

   else if(w_title) begin
      for(n = 0; n < 5; n = n + 1) begin
         for(q = 0; q < 4; q = q + 1) begin
            //PONG INW INW
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 1] = alpha[0][n][3-q];
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 6] = alpha[1][n][3-q];
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 11] = alpha[2][n][3-q];
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 16] = alpha[3][n][3-q];

            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 24] = alpha[4][n][3-q];
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 28] = alpha[2][n][3-q];
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 33] = alpha[5][n][3-q];

            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 41] = alpha[4][n][3-q];
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 45] = alpha[2][n][3-q];
            map[COVER_MARGIN_TOP + n][COVER_MARGIN_LEFT + q + 50] = alpha[5][n][3-q];
         end
      end
   end
end

//###############################################################
//MAPPER CORE
reg [5:0] state = 0, next_state = 0;
reg [7:0] row = 0, col = 0;
reg [7:0] to_send;
reg started = 0;

always @ (posedge clock) begin
   if(game_start) started <= 1;
   else if(game_end) started <= 0;
end

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

reg send_signal;
always @ (posedge clock) begin
	if(send_signal) send_start <= 1;
	else send_start <= 0;
end

reg [7:0] esc [0:7];

initial begin
	esc[0] = 8'h1B;
	esc[1] = 8'h5B;
	esc[2] = 8'h00;
	esc[3] = 8'h00;
	esc[4] = 8'h3B;
	esc[5] = 8'h00;
	esc[6] = 8'h00;
	esc[7] = 8'h48;
end

reg [3:0] esc_idx;
reg reset_esc, inc_esc;
always @ (posedge clock) begin
	if(reset_esc) esc_idx <= 0;
	else if(inc_esc) esc_idx <= esc_idx + 1;
end

reg data_signal, esc_signal;
always @ (posedge clock) begin
	if(data_signal) begin
      if(!started) begin
         if(row == COVER_MARGIN_TOP + 5 + 2 && col >= COVER_MARGIN_LEFT + 9 && col < COVER_MARGIN_LEFT + 9 + CREDITS_LENGTH) to_send <= credits[col - COVER_MARGIN_LEFT - 9];
         else if(row == COVER_MARGIN_TOP + 5 + 8 && col >= 29 && col < 29 + INSTRUCTIONS_LENGTH) to_send <= instructions[col - 29];
         else to_send <= map[row][col] ? 8'd254 : 8'b0010_0000;
      end
      //else if(map[row][col] && row == ball_y && col == ball_x) to_send <= 8'd79;
		else to_send <= map[row][col] ? 8'd254 : 8'b0010_0000; //8'b1011_0010 8'd111
   end
	else if(esc_signal) to_send <= esc[esc_idx];
end

always @ (*) begin

	arr_clear = 0;
   w_frame = 0;
   w_score = 0;
   w_paddle = 0;
   w_ball = 0;
   w_title = 0;
	title_clear = 0;
   reset_row = 0; reset_col = 0; inc_row = 0; inc_col = 0;
   //NORMALLY SET TO BUSY, EXCEPT THE IDLE STATE.
   _busy = 1;

	send_signal = 0;
	data_signal = 0;

	reset_esc = 0;
	inc_esc = 0;
	esc_signal = 0;

	case(state)
		0: begin
         //IDLE STATE, NOT BUSY.
         _busy = 0;
			reset_esc = 1;
			if(start) next_state = 17;
			else next_state = 0;
		end
		17: begin
			esc_signal = 1;
			send_signal = 1;
			next_state = 18;
		end
		18: begin
			send_signal = 1;
			inc_esc = 1;
			next_state = 19;
		end
		19: begin
			send_signal = 1;
			next_state = 20;
		end
		20: begin
			if(sender_busy) next_state = 20;
			else next_state = 21;
		end
		21: begin
			if(esc_idx == 8) next_state = 1;
		   else next_state = 17;
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
         if(started) begin
            //w_score = 1;
            next_state = 16;
         end
         else begin
            //WRITE TITLE.
            w_title = 1;
            next_state = 4;
         end
		end
		16 : begin
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
         if(row < MAP_HEIGHT) next_state = 6; // MAP_HEIGHT
         else next_state = 0; //END
      end
      6: begin
         if(col < MAP_WIDTH) next_state = 22; // MAP_WIDTH
         else next_state = 10;
      end
		22 : begin
			next_state = 7;
		end
      7: begin
         //to_send = map[row][col] ? 8'b1011_0010 : 8'b0010_0000;
         //to_send = map[row][col] ? 8'b0100_0011 : 8'b0010_0000;
			data_signal = 1;
			send_signal = 1;
         next_state = 14;
      end

		14 : begin
			send_signal = 1;
			next_state = 15;
		end

		15 : begin
			send_signal = 1;
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

