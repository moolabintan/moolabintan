module Register_FileTB;

  reg write, rst, CLK;
  reg [1:0] wrAddr;
  reg [15:0] wrData;
  reg [1:0] rdAddrA, rdAddrB;
  wire [15:0] rdDataA, rdDataB;
  wire [15:0] ACC, ACCO, SP, RA;
  parameter HALF_PERIOD=50;
  parameter PERIOD = HALF_PERIOD*2;

  Register_File uut (
	 .CLK(CLK),
    .write(write),
    .rst(rst),
    .wrAddr(wrAddr),
    .wrData(wrData),
    .rdAddrA(rdAddrA),
    .rdDataA(rdDataA),
    .rdAddrB(rdAddrB),
    .rdDataB(rdDataB),
	 .ACCData(ACC),
	 .ACCOData(ACCO), 
	 .SPData(SP), 
	 .RAData(RA)
  );
  
  
initial begin
    CLK = 0;
    forever begin
        #(HALF_PERIOD);
        CLK = ~CLK;
    end
end

  
integer failed_tests;
  
  initial begin
    failed_tests = 0;
    
    // Test 1: Reset
    rst = 1;
    #PERIOD;
	 $display("rdDataA = %b, rdDataB = %b", rdDataA, rdDataB);
    
    
	 #(2 * PERIOD)
	 rst = 0;
    // Test 2
    write = 1;
	 rdAddrA = 0;
	 rdAddrB = 1;
    wrAddr = 0;
    wrData = 16'b1101001000100001;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP=%d, RA = %d", ACC, ACCO, SP, RA);
	 
	 
	 #(2*PERIOD)
	 // Test 3
    write = 0;
	 rdAddrA = 0;
	 rdAddrB = 1;
    wrAddr = 1;
    wrData = 16'b0000000000001111;
	 #(2*PERIOD)
    $display("ACC = %b, ACCO = %b, SP=%d, RA = %d", ACC, ACCO, SP, RA);
	 
	 
	 
	 #(2*PERIOD)
	 // Test 4
    write = 1;
	 rdAddrA = 3;
	 rdAddrB = 1;
    wrAddr = 2;
    wrData = 16'b0001110001110001;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP=%d, RA = %d", ACC, ACCO, SP, RA);
	 
	 
	 #(2*PERIOD)
	 // Test 4
    write = 1;
	 rdAddrA = 3;
	 rdAddrB = 1;
    wrAddr = 3;
    wrData = 16'b1111111100000000;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP=%d, RA = %d", ACC, ACCO, SP, RA);
	 
	 
	 #(2*PERIOD)
	 // Test 4
    write = 1;
	 rdAddrA = 3;
	 rdAddrB = 1;
    wrAddr = 1;
    wrData = 16'b0000000011111111;
	 #(2*PERIOD)
	 $display("ACC = %b, ACCO = %b, SP=%d, RA = %d", ACC, ACCO, SP, RA);
	 
	 
	 
	 
	 
	 
	
    
    $display("Number of tests failed: %d", failed_tests);
	 $stop;
  end
  
endmodule
