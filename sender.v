`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    02:11:07 03/08/2014
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

parameter   baud_rate = 115200,
            clock_per_bit = 217,
            half_clock_per_bit = 108;

reg _out = 1;
assign out = _out;

reg sending = 0;
reg [7:0] send_data;

reg [3:0] sender_state = 0;
reg sending = 0, trigger_send, trigger_send_end;

assign busy = !(sender_state == 9);


always @ (*) begin
   trigger_send = 0;
   trigger_send_end = 0;
   if(send_start) begin
      trigger_send = 1;
   end
end

always @ (posedge clock) begin
   if(trigger_send) begin
      sending <= 1;
      send_data <= to_send;
   end
   else if(trigger_send_end) sending <= 0;
end

//SENDER STATE
reg [11:0] baud_cnt = 0;
wire baud_clock = (baud_cnt == clock_per_bit - 1);
always @ (posedge baud_clock) begin
	if(sending) begin
		case(sender_state)
			0: begin
				_out <= 0;
				sender_state <= 1;
			end
			1: begin
				_out <= to_send[0];
				sender_state <= 2;
			end
			2: begin
				_out <= to_send[1];
				sender_state <= 3;
			end
			3: begin
				_out <= to_send[2];
				sender_state <= 4;
			end
			4: begin
				_out <= to_send[3];
				sender_state <= 5;
			end
			5: begin
				_out <= to_send[4];
				sender_state <= 6;
			end
			6: begin
				_out <= to_send[5];
				sender_state <= 7;
			end
			7: begin
				_out <= to_send[6];
				sender_state <= 8;
			end
			8: begin
				_out <= to_send[7];
				sender_state <= 9;
			end
			9: begin
				_out <= 1;
				trigger_send_end = 1; //SENT. MARK SENDING TO 0.
				sender_state <= 0;
			end
		endcase
	end else begin
      sender_state <= 0;
		_out <= 1;
	end
end


//BAUD COUNTER, TO GENEREATE BAUD CLOCK
always @ (posedge clock) begin
	if(baud_cnt == clock_per_bit - 1)
		baud_cnt <= 0;
	else
		baud_cnt <= baud_cnt + 1;
end


endmodule
