`timescale 1ns / 1ps

module comparator_16bit_tb;

reg [15:0] a, b;
wire equal, greaterthan, lessthan;

comparator uut(a, b, equal, greaterthan, lessthan);

integer failed_tests;

initial begin
  failed_tests = 0;

  // Test case 1
  a = 10;
  b = 20;

  if (equal != 0 || greaterthan != 0 || lessthan != 1) begin
    $display("Test case 1 failed");
	 failed_tests = failed_tests + 1;
  #1;
	end
	
	
	 // Test case 1
  a = 100;
  b = 100;

  if (equal != 1 || greaterthan != 0 || lessthan != 0) begin
    $display("Test case 1 failed");
	 failed_tests = failed_tests + 1;
  #1;
	end
	
	
 // Test case 1
  a = 110;
  b = 20;

  if (equal != 0 || greaterthan != 1 || lessthan != 0) begin
    $display("Test case 1 failed");
	 failed_tests = failed_tests + 1;
  #1;
	end
	
	
	
end


endmodule
