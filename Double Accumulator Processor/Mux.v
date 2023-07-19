module mux4_1(sel, a, b, c, d, out);
// 4-1 mux w/ inputs a, b, c, d and output out
input [1:0] sel;
input [15:0] a;
input [15:0] b;
input [15:0] c;
input [15:0] d;
output reg [15:0] out;

// cases: 00 - a, 01 - b, 10 - c, 11 - d
always @(*) begin 
if (sel==2'b00) begin
	out = a;
end
else if (sel==2'b01) begin
	out = b;
end
else if (sel==2'b10) begin
	out = c;
end
else begin
	out = d;
end 
end
endmodule

module mux2_1(sel, a, b, out);
// 2-1 mux w/ inputs a, b and output out
input sel;
input [15:0] a;
input [15:0] b;
output reg [15:0] out;

always @(*) begin
if (sel==1'b0) begin
	out = a;
end
else begin
	out = b;
end
end
endmodule

module miniMux2_1(sel, a, b, out);
// 2-1 mux w/ inputs a, b and output out
input sel;
input [1:0] a;
input [1:0] b;
output reg [1:0] out;

always @(*) begin
if (sel==1'b0) begin
	out = a;
end
else begin
	out = b;
end
end
endmodule

module miniMux4_1(sel, a, b, c, d, out);
// 4-1 mux w/ inputs a, b, c, d and output out
input [1:0] sel;
input [1:0] a;
input [1:0] b;
input [1:0] c;
input [1:0] d;
output reg [1:0] out;

// cases: 00 - a, 01 - b, 10 - c, 11 - d
always @(*) begin 
if (sel==2'b00) begin
	out = a;
end
else if (sel==2'b01) begin
	out = b;
end
else if (sel==2'b10) begin
	out = c;
end
else begin
	out = d;
end 
end
endmodule
