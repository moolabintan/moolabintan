module sign_extender8b(in, out);
// module for a sign-extender that will output a 16-b sign
// extended number
input [7:0] in;
output reg [15:0] out;

always @(in) begin
	 out = {{8{in[7]}}, in};
end

endmodule


module sign_extender10b(in, out);
// module for a sign-extender that will output a 16-b sign
// extended number
input [9:0] in;
output reg [15:0] out;

always @(in) begin
	 out = {{6{in[9]}}, in};
end

endmodule

module sign_extender6b(in, out);
// module for a sign-extender that will output a 16-b sign
// extended number
input [5:0] in;
output reg [15:0] out;

always @(in) begin
 out = {{10{in[5]}}, in};
end

endmodule


module sign_extender12b(in, out);
// module for a sign-extender that will output a 16-b sign
// extended number
input [11:0] in;
output reg [15:0] out;

always @(in) begin
out = {{4{in[11]}}, in};
end
endmodule
