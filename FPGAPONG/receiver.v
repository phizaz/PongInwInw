`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:05:54 03/08/2014 
// Design Name: 
// Module Name:    receiver 
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
module receiver(
		input clock,
		input in,
		output received,
		output [7:0] received_data
    );
	 
	parameter baud_rate = 115200,
			  clock_per_bit = 217,
			  half_clock_per_bit = 108;

	reg [7:0] data;
	assign received_data = data;

	reg [11:0] baud_cnt = 0;
	wire baud_clock = (baud_cnt == clock_per_bit - 1);

	reg [3:0] receiver_state = 0;
	assign received = (receiver_state == 9);

	//RECIEVER STATE
	always @ (posedge baud_clock) begin
		case(receiver_state) 
			0: begin
				if(in == 0) receiver_state <= 1;
				else receiver_state <= 0;
			end
			1: begin
				data[0] <= in;
				receiver_state <= 2;
			end
			2: begin
				data[1] <= in;
				receiver_state <= 3;
			end
			3: begin
				data[2] <= in;
				receiver_state <= 4;
			end
			4: begin
				data[3] <= in;
				receiver_state <= 5;
			end
			5: begin
				data[4] <= in;
				receiver_state <= 6;
			end
			6: begin 
				data[5] <= in;
				receiver_state <= 7;
			end
			7: begin 
				data[6] <= in;
				receiver_state <= 8;
			end
			8: begin
				data[7] <= in;
				receiver_state <= 9;
			end
			9: begin
				receiver_state <= 0;
			end
		endcase
	end

	//BAUD COUNTER, TO GENEREATE BAUD CLOCK
	reg before = 1;
	always @ (posedge clock) begin
		if(in == 0 && in != before && receiver_state == 0)
			baud_cnt <= half_clock_per_bit;
		else begin
			if(baud_cnt == clock_per_bit - 1)
				baud_cnt <= 0;
			else 
				baud_cnt <= baud_cnt + 1;
		end
		before <= in;
	end

endmodule
