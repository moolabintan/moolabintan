`timescale 1ns / 1ps

module sign_extender8b_tb;
reg [7:0] in;
wire [15:0] out;

sign_extender8b uut(in, out);

integer failed_tests;
initial begin
  failed_tests = 0;
  // Test case 1
  in = 8'b11111111;
  #1;
  if (out != 16'b1111111111111111) begin
    $display("Test case 1 failed");
    failed_tests = failed_tests + 1;
  end
  
  $display("All tests finished, %d tests failed", failed_tests);
end

endmodule

module sign_extender10b_tb;
reg [9:0] in;
wire [15:0] out;

sign_extender10b uut(in, out);

integer failed_tests;
initial begin
  failed_tests = 0;
  // Test case 1
  in = 10'b1111111111;
  #1;
  if (out != 16'b1111111111111111) begin
    $display("Test case 1 failed");
    failed_tests = failed_tests + 1;
  end
  // Test case 1
  in = 10'b0111111111;
  #1;
  if (out != 16'b0000001111111111) begin
    $display("Test case 2 failed");
    failed_tests = failed_tests + 1;
  end
  
  // Test case 1
  in = 10'b0011111111;
  #1;
  if (out != 16'b0000000111111111) begin
    $display("Test case 3 failed");
    failed_tests = failed_tests + 1;
  end
  
  $display("All tests finished, %d tests failed", failed_tests);
end

endmodule

module sign_extender6b_tb;
reg [5:0] in;
wire [15:0] out;

sign_extender6b uut(in, out);

integer failed_tests;
initial begin
  failed_tests = 0;
  // Test case 1
  in = 6'b111111;
  #1;
  if (out != 16'b1111111111111111) begin
    $display("Test case 1 failed");
    failed_tests = failed_tests + 1;
  end
  
  // Test case 1
  in = 6'b000000;
  #1;
  if (out != 16'b0000000000000000) begin
    $display("Test case 2 failed");
    failed_tests = failed_tests + 1;
  end
  
  // Test case 1
  in = 6'b011111;
  #1;
  if (out != 16'b0000000000011111) begin
    $display("Test case 3 failed");
    failed_tests = failed_tests + 1;
  end
  
  
  $display("All tests finished, %d tests failed", failed_tests);
end

endmodule
