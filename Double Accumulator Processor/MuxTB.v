`timescale 1ns / 1ps

module mux_4_1_tb;

reg [1:0] sel;
reg [15:0] a, b, c, d;
wire [15:0] out;
mux4_1 uut(sel, a, b, c, d, out);

integer failed_tests;

initial begin
  failed_tests = 0;
  // Test case 1
  sel = 2'b00;
  a = 1;
  b = 2;
  c = 3;
  d = 4;
  #10;
  if (out != a) begin
    $display("Test case 1 failed");
    failed_tests = failed_tests + 1;
  end
  
  // Test case 2
  sel = 2'b01;
  a = 1;
  b = 2;
  c = 3;
  d = 4;
  #10;
  if (out != b) begin
    $display("Test case 1 failed");
    failed_tests = failed_tests + 1;
  end
  
  
  // Test case 3
  sel = 2'b10;
  a = 1;
  b = 2;
  c = 3;
  d = 4;
  #10;
  if (out != c) begin
    $display("Test case 1 failed");
    failed_tests = failed_tests + 1;
  end
  
  
  // Test case 4
  sel = 2'b11;
  a = 1;
  b = 2;
  c = 3;
  d = 4;
  #10;
  if (out != d) begin
    $display("Test case 1 failed");
    failed_tests = failed_tests + 1;
  end
  
  
  #1;
  $display("All tests finished, %d tests failed", failed_tests);
end
endmodule



