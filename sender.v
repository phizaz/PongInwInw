`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:07:05 03/08/2014 
// Design Name: 
// Module Name:    sender 
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

module sender(
    input clock,
	 input send_start, //IF 1 -> START TO SEND.
	 input [7:0] to_send, //DATA TO SEND.
	 output busy, //TELL THAT DATA SENT.
	 output out //CONNECT TO TX
    );

	parameter	baud_rate = 460800,
					clock_per_bit = 54,
					half_clock_per_bit = 27;

	reg _out = 1;
	assign out = _out;

	reg sending = 0, send_end = 0;
	reg [7:0] send_data;

	reg [3:0] sender_state = 0, sender_next_state = 0;

	reg _busy = 0;
	assign busy = _busy;

	reg [3:0] old_state = 0;
	always @ (posedge clock) begin
		if(send_start) begin
			sending <= 1;
			_busy <= 1;
			send_data <= to_send;
		end
		else if(old_state == 9 && sender_state == 10) begin
			sending <= 0;
		end
		else if(old_state == 10 && sender_state == 0) begin
			_busy <= 0;
		end
		old_state <= sender_state;
	end

	//SENDER STATE
	reg [11:0] baud_cnt = 0;
	wire baud_clock = (baud_cnt == clock_per_bit - 1);

	always @ (posedge baud_clock) begin
		sender_state <= sender_next_state;
	end

	always @ (*) begin
		if(sending) begin
			case(sender_state)
				0: begin
					_out = 0;
					sender_next_state = 1;
				end
				1: begin
					_out = to_send[0];
					sender_next_state = 2;
				end
				2: begin
					_out = to_send[1];
					sender_next_state = 3;
				end
				3: begin
					_out = to_send[2];
					sender_next_state = 4;
				end
				4: begin
					_out = to_send[3];
					sender_next_state = 5;
				end
				5: begin
					_out = to_send[4];
					sender_next_state = 6;
				end
				6: begin
					_out = to_send[5];
					sender_next_state = 7;
				end
				7: begin
					_out = to_send[6];
					sender_next_state = 8;
				end
				8: begin
					_out = to_send[7];
					sender_next_state = 9;
				end
				9: begin
					_out = 1;
					sender_next_state = 10;
				end
				10: begin
					_out = 1;
					sender_next_state = 0;
				end
			endcase
		end else begin
			sender_next_state = 0;
			_out = 1;
		end
	end


	//BAUD COUNTER, TO GENEREATE BAUD CLOCK
	always @ (posedge clock) begin
		if(send_start)
			baud_cnt <= 0;
		else begin
			if(baud_cnt == clock_per_bit - 1)
				baud_cnt <= 0;
			else
				baud_cnt <= baud_cnt + 1;
		end
	end

endmodule



