`timescale 1ns / 1ps

module connected_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [15:0] ACCInput;

	// Outputs
	wire [4:0] State;
	wire [15:0] ACC;


	connected uut (
		.CLK(clk), 
		.RST(rst), 
		.ACCInput(ACCInput),
		.State(State),
		.ACC(ACC)
	);

	parameter HALF_PERIOD=50;
	parameter PERIOD = HALF_PERIOD*2; 
 
initial begin
    clk = 0;
    forever begin
        #(HALF_PERIOD);
        clk = ~clk;
    end
end

	initial begin
		//clk = 0;
		rst = 1;
		ACCInput = 5040;

		#(4*PERIOD);
	//	$stop;
		rst = 0;
      #(PERIOD * 2000000);  
		$stop;
	end
      
endmodule
