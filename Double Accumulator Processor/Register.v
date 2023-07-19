module Register
(input_value, CLK, RST, output_value, write_signal);

input [15:0] input_value;
input CLK;
input RST;
input write_signal;
output [15:0] output_value;

reg [15:0] output_value;


always @ (posedge CLK) begin
	if(!RST) begin
		if (write_signal) begin
			output_value <= input_value;
		end
	end else
		output_value  <= 16'b0000000000000000;
end	

endmodule


module InstructionRegister
(instruction, CLK, RST, reg1, reg2, regDest, imm1, imm2, imm3, imm4, write_signal);

input [15:0] instruction;
input CLK;
input RST;
input write_signal;
output reg[1:0] reg1;
output reg[1:0] reg2; 
output reg[1:0] regDest;
output reg[5:0] imm1;
output reg[7:0] imm2;
output reg[9:0] imm3;
output reg[11:0] imm4;



always @ (posedge CLK) begin
	if (!RST && write_signal) begin
	reg1 = instruction[5:4];
	reg2 = instruction[3:2];
	regDest = instruction [1:0];
	imm1 = instruction[11:6];
	imm2 = instruction[11:4];
	imm3 = instruction[11:2];
	imm4 = instruction[11:0];
	end 
	else if(RST) begin
	reg1 = 2'b00;
	reg2 = 2'b00;
	regDest = 2'b00;
	imm1 = 6'b000000;
	imm2 = 8'b00000000;
	imm3 = 10'b0000000000;
	imm4 = 12'b000000000000;
	end
end
	
endmodule

