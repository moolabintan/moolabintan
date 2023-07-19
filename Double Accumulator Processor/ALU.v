module ALU(
	input wire signed [15:0] A,
	input wire signed [15:0] B,
	input wire Op,
	output reg [15:0] ALU_Out
);
	
	
	always @(Op, A, B) begin
		case (Op)
		0 : ALU_Out = A + B;
		1 : ALU_Out = A - B;
		endcase	
	end
endmodule
	
	
