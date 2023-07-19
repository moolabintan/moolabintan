`timescale 1ns / 1ps

module shifter_6bit_tb;

reg [15:0] in;
wire [15:0] out;

shifter_6bit uut(in, out);

integer failed_tests;

initial begin
  failed_tests = 0;
  
  in = 16'h0001;
  #1;
  assert(out == in << 6); else $error("Test case 1 failed");
  failed_tests = failed_tests + 1;


  // Test case 2
  in = 16'h1234;
  #1;
  assert(out == in << 6); else $error("Test case 2 failed");
  failed_tests = failed_tests + 1;


  // Test case 3
  in = 16'h8000;
  #1;
  assert(out == in << 6); else $error("Test case 3 failed");
  failed_tests = failed_tests + 1;


  // Test case 4
  in = 16'h7fff;
  #1;
  assert(out == in << 6); else $error("Test case 4 failed");
  failed_tests = failed_tests + 1;


  // Test case 5
  in = 16'h0000;
  #1;
  assert(out == in << 6); else $error("Test case 5 failed");
  failed_tests = failed_tests + 1;


  // Test case 6
  in = 16'h5555;
  #1;
  assert(out == in << 6); else $error("Test case 6 failed");
  failed_tests = failed_tests + 1;


  // Test case 7
  in = 16'h1111;
  #1;
  assert(out == in << 6); else $error("Test case 7 failed");
  failed_tests = failed_tests + 1;


  // Test case 8
  in = 16'habcd;
  #1;
  assert(out == in << 6); else $error("Test case 8 failed");
  failed_tests = failed_tests + 1;


  // Test case 9
  in = 16'hffff;
  #1;
  assert(out == in << 6); else $error("Test case 9 failed");
  failed_tests = failed_tests + 1;

  // Test case 10
  in = 16'h5678;
  #1;
  assert(out == in << 6); else $error("Test case 10 failed");
  failed_tests = failed_tests + 1;

  
  $finish;
end

endmodule


module shifter_1bit_tb;

reg [15:0] in;
wire [15:0] out;

shifter_1bit uut(in, out);

initial begin
  in = 16'h0001;
  #1;
  assert(out == in << 1); else $display("Test case 1 failed");

  // Test case 2
  in = 16'h1234;
  #1;
  assert(out == in << 1); else $display("Test case 2 failed");

  // Test case 3
  in = 16'h8000;
  #1;
  assert(out == in << 1); else $display("Test case 3 failed");

  // Test case 4
  in = 16'h7fff;
  #1;
  assert(out == in << 1); else $display("Test case 4 failed");

  // Test case 5
  in = 16'h0000;
  #1;
  assert(out == in << 1) else $display("Test case 5 failed");

  // Test case 6
  in = 16'h5555;
  #1;
  assert(out == in << 1); else $display("Test case 6 failed");

  // Test case 7
  in = 16'h1111;
  #1;
  assert(out == in << 1); else $display("Test case 7 failed");

  // Test case 8
  in = 16'habcd;
  #1;
  assert(out == in << 1); else $display("Test case 8 failed");

  // Test case 9
  in = 16'hffff;
  #1;
  assert(out == in << 1); else $display("Test case 9 failed");

  // Test case 10
  in = 16'h5678;
  #1;
  assert(out == in << 1); else $display("Test case 10 failed");
  
  $display("All tests finished, %d tests failed", failed_tests);
end

endmodule
