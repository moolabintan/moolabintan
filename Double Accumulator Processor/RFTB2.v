module Register_FileTB2;

	reg write;
	reg CLK,rst;
	reg [1:0] Dest;
	reg [15:0] wrData;
	wire [15:0] ACCO;
	wire [15:0] ACC;
	wire [15:0] SP;
	wire [15:0] RA;
//	parameter HALF_PERIOD=50;
//	parameter PERIOD = HALF_PERIOD*2;
	
	Register_File uut(
	.write(write),
	.CLK(CLK),
	.rst(rst),

	.Dest(Dest),
	.wrData(wrData),
	.ACC(ACC),
	.ACCO(ACCO),
	.SP(SP),
	.RA(RA)
);


	parameter HALF_PERIOD=50;
	parameter PERIOD = HALF_PERIOD*2; 
 
initial begin
    CLK = 1;
    forever begin
        #(HALF_PERIOD);
        CLK = ~CLK;
    end
end

	integer fails;
	
	initial begin
		fails =0;
		
		 // Test 1: Reset
    rst = 1;
    #PERIOD;
	 $display("ACC = %b, ACCO = %b, SP = %b, RA = %b", 
	 ACC, ACCO, SP, RA);	 
    
  	 #(2 * PERIOD)
	 #(2 * PERIOD)
	 rst = 0;
    // Test 2
    write = 1;
//	 R1 = 0;
//	 R2 = 1;
//    R3 = 0;
	 Dest = 0;
    wrData = 16'b1101001000100001;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP = %b, RA = %b", 
	 ACC, ACCO, SP, RA);	 
	 
	 #(2*PERIOD)
	 // Test 3
    write = 1;
	 Dest = 1;
    wrData = 16'b0000000000001111;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP = %b, RA = %b", 
	 ACC, ACCO, SP, RA);	 
	 
	 
	 #(2*PERIOD)
	 // Test 4
    write = 0;
	 Dest = 2;
    wrData = 16'b0001110001110001;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP = %b, RA = %b", 
	 ACC, ACCO, SP, RA);	  
	 
	 #(2*PERIOD)
	 // Test 4
    write = 1;
	 Dest = 3;
    wrData = 16'b1111111100000000;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP = %b, RA = %b", 
	 ACC, ACCO, SP, RA);	 
	 
	 #(2*PERIOD)
	 // Test 4
    write = 1;
	 Dest = 1;
    wrData = 16'b0000000011111111;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP = %b, RA = %b", 
	 ACC, ACCO, SP, RA);	 
	 
	 
	 
	 
	 
	
    
    $display("Number of tests failed: %d", fails);
	 $stop;
  end
  
endmodule
		