`timescale 1ns / 1ps

module ALUTB;

	reg [15:0] A, B;
	reg [2:0] Op;
	
	wire [15:0] ALU_Out;
	
	ALU UUT (
		.A(A),
		.B(B),
		.Op(Op),
		.ALU_Out(ALU_Out)
	);
	
	integer failed_tests;
	
	initial begin
		failed_tests = 0;
		
		// Test Case 1
      A = 3;
      B = 1;
		Op = 0;
		#1;
		if (ALU_Out != 4) begin
			$display("Test case 1 failed");
			failed_tests = failed_tests + 1;
		end
		
		// Test Case 2
      A = 199;
      B = 1;
		Op = 0;
		#1;
		if (ALU_Out != 200) begin
			$display("Test case 2 failed");
			failed_tests = failed_tests + 1;
		end
		
		// Test Case 3
      A = -3;
      B = 10;
		Op = 0;
		#1;
		if (ALU_Out != 7) begin
			$display("Test case 3 failed");
			failed_tests = failed_tests + 1;
		end
		
		// Test Case 4
      A = 20;
      B = 40;
		Op = 0;
		#1;
		if (ALU_Out != 60) begin
			$display("Test case 4 failed");
			failed_tests = failed_tests + 1;
		end
		
		// Test Case 5
      A = -200;
      B = 200;
		Op = 0;
		#1;
		if (ALU_Out != 0) begin
			$display("Test case 5 failed");
			failed_tests = failed_tests + 1;
		end
		
		
		// Test Case 6
		A = 3;
      B = 1;
		Op = 1;
		#1;
		if (ALU_Out != 2) begin
			$display("Test case 6 failed");
			failed_tests = failed_tests + 1;
		end
		
		
		// Test Case 7
		A = 3;
      B = -1;
		Op = 1;
		#1;
		if (ALU_Out != 4) begin
			$display("Test case 7 failed");
			failed_tests = failed_tests + 1;
		end
		
		// Test Case 8
		A = 23;
      B = 11;
		Op = 1;
		#1;
		if (ALU_Out != 12) begin
			$display("Test case 8 failed");
			failed_tests = failed_tests + 1;
		end
		
		// Test Case 9
		A = 45000;
      B = 45000;
		Op = 1;
		#1;
		if (ALU_Out != 0) begin
			$display("Test case 9 failed");
			failed_tests = failed_tests + 1;
		end
		
		// Test Case 10
		A = 10;
      B = 3;
		Op = 1;
		#1;
		if (ALU_Out != 7) begin
			$display("Test case 10 failed");
			failed_tests = failed_tests + 1;
		end
		
//		//Test Case 11
//		A = 10;
//		B = 3;
//		Op = 2;
//		#1;
//		if (ALU_Out != 0) begin
//			$display("Test case 11 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//		//Test Case 12
//		A = 3;
//		B = 3;
//		Op= 2;
//		#1;
//		if (ALU_Out != 1) begin
//			$display("Test case 12 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//				//Test Case 13
//		A = 19;
//		B = 13;
//		Op = 3;
//		#1;
//		if (ALU_Out != 1) begin
//			$display("Test case 13 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//		//Test Case 14
//		A = 12;
//		B = 12;
//		Op= 3;
//		#1;
//		if (ALU_Out != 0) begin
//			$display("Test case 14 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//				//Test Case 15
//		A = 10;
//		B = 3;
//		Op = 4;
//		#1;
//		if (ALU_Out != 1) begin
//			$display("Test case 15 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//		//Test Case 16
//		A = 3;
//		B = 3;
//		Op= 4;
//		#1;
//		if (ALU_Out != 1) begin
//			$display("Test case 16 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//				//Test Case 17
//		A = 2;
//		B = 9;
//		Op = 4;
//		#1;
//		if (ALU_Out != 0) begin
//			$display("Test case 17 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//		//Test Case 18
//		A = 3;
//		B = 3;
//		Op= 5;
//		#1;
//		if (ALU_Out != 0) begin
//			$display("Test case 18 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//		//Test Case 19
//		A = 10;
//		B = 3;
//		Op = 5;
//		#1;
//		if (ALU_Out != 0) begin
//			$display("Test case 19 failed");
//			failed_tests = failed_tests + 1;
//		end
//		
//		//Test Case 20
//		A = 6;
//		B = 8;
//		Op= 5;
//		#1;
//		if (ALU_Out != 1) begin
//			$display("Test case 20 failed");
//			failed_tests = failed_tests + 1;
//		end
		
		#1;
		$display("All tests finsihed, %d tests failed", failed_tests);
    end
	 
endmodule 