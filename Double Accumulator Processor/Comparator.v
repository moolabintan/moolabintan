module Comparator(a, b, cmp,dout);
// module for a comparator that compares two 16b numbers a, b and outputs flags
// for equal to, greater than, less than
input [15:0] a, b;
input [1:0] cmp;
output reg dout;

//reg temp;

always @(a, b, cmp) begin
	case(cmp)
	2'b00: dout <= (a==b);
	2'b01: dout <= (a>=b);
	2'b10: dout <= (a<b);
	2'b11: dout <= !(a==b);
	default: dout <= !(a==b);
	endcase
end

endmodule


