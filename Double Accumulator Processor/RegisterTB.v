module tb();
reg [15:0] input_value;
reg CLK, RST, write_signal;
wire [15:0] output_value;

Register UUT(
.CLK(CLK),
.input_value(input_value),
.RST(RST),
.output_value(output_value),
.write_signal(write_signal)
);

parameter HALF_PERIOD=50;
parameter PERIOD = HALF_PERIOD*2; 

initial begin
    CLK = 0;
    forever begin
        #(HALF_PERIOD);
        CLK = ~CLK;
    end
end

integer failures = 0;

//Test 1
initial begin
	RST = 1;
	if(output_value != 16'b0000000000000000)begin
	$display("Test 1 failed");
	failures = failures + 1;
	end
	#(PERIOD);

//Test 2
	RST = 1;
	#HALF_PERIOD;
	RST = 0;
	write_signal = 1;
	input_value = 16'b1100010110100000;
	#PERIOD;
	if(output_value != 16'b1100010110100000)begin
	$display("Test 2 failed");
	failures = failures + 1;
	end

//test 3
	RST = 1;
	#HALF_PERIOD;
	RST = 0;
	write_signal = 1;
	input_value = 16'b1111111111111111;
	#PERIOD;
	if(output_value != 16'b1111111111111111)begin
	$display("Test 3 failed");
	failures = failures + 1;
	end
	$display("You failed %d Test", failures);
	$stop;
	
	end
	
endmodule
