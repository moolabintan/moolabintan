module shifter_1bit(in, out);
	input [15:0] in;
	output [15:0] out;

	reg [15:0] out;

always @(in) begin
	out = in << 1;
end

endmodule

module shifter_6bit(in, out);
	input [15:0] in;
	output [15:0] out;

	reg [15:0] out;

always @(in) begin
	out = in << 6;
end

endmodule
