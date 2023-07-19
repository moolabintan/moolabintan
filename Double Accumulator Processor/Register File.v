module Register_File(
	input write,
	input CLK,rst,
//	input [1:0] R1,
//	input [1:0] R2,
//	input [1:0] R3,
	input [1:0] Dest,
	input [15:0] wrData,
//	output wire [15:0] Out1,
//	output wire [15:0] Out2,
//	output wire [15:0] Out3,
	output wire [15:0] SP,
	output wire [15:0] ACC,
	output wire [15:0] RA,
	output wire [15:0] ACCO	
);


//	reg [15:0] ACC, ACCO, SP, RA;
//	assign ACCData = ACC;
//	assign ACCOData = ACCO;
//	assign SPData = SP;
//	assign RAData = RA;
	
	reg [15:0] reg_file [0:3];
	
//	assign rdDataA = R1 == 0 ? ACC :
//		    R1 == 1 ? ACCO :
//		    R1 == 2 ? SP :
//		    R1 == 3 ? RA : 0;
//
//			 
//   assign rdDataB = rdAddrB == 0 ? ACC :
//		    rdAddrB == 1 ? ACCO :
//		    rdAddrB == 2 ? SP :
//	    rdAddrB == 3 ? RA : 0;
	
	integer i;
	initial begin
		for(i = 0; i<4; i = i+1) begin
			if(i == 2)
				reg_file[i] <= 16'hffff;
			else
				reg_file[i] <= 16'd0;
			//end
			//$display("in for loop the %dth item is %b", i, reg_file[i]);
		end
	end
	
//	assign Out1 = reg_file[R1];
//   assign Out2 = reg_file[R2];
//   assign Out3 = reg_file[R3];
	assign ACC = reg_file[2'b00];
	assign ACCO = reg_file[2'b01];
	assign SP = reg_file[2'b10];
	assign RA = reg_file[2'b11];


		
	
	always @(posedge CLK) begin
	if(rst)begin
			for(i = 0; i<4; i = i+1) begin
			if(i == 2)
				reg_file[i] = 16'hffff;
			else
				reg_file[i] = 16'd0;
			//end
			//$display("in for loop the %dth item is %b", i, reg_file[i]);
		end
		end
	if (write && !rst)begin
			reg_file[Dest] = wrData;
		end 
	end
	

	//end
		
		
	//always @(posedge CLK) begin
//		if (write) begin
//			case (R3)
//				2'b00: begin
//					ACC = R3;
//					ACCO = ACCO;
//					SP = SP;
//					RA = RA;
//				end
//				2'b01: begin
//					ACCO = R3;
//					ACC = ACC;
//					SP = SP;
//					RA = RA;
//				end
//				2'b10: begin
//					SP = R3;
//					ACC = ACC;
//					ACCO = ACCO;
//					RA = RA;
//				end
//				2'b11: begin
//					RA = R3;
//					ACC = ACC;
//					ACCO = ACCO;
//					SP = SP;
//				end
//			endcase
//		end
//		
//		case(R1)
//		2'b00: begin
//					ACC = R3;
//					ACCO = ACCO;
//					SP = SP;
//					RA = RA;
//				end
//				2'b01: begin
//					ACCO = R3;
//					ACC = ACC;
//					SP = SP;
//					RA = RA;
//				end
//				2'b10: begin
//					SP = R3;
//					ACC = ACC;
//					ACCO = ACCO;
//					RA = RA;
//				end
//				2'b11: begin
//					RA = R3;
//					ACC = ACC;
//					ACCO = ACCO;
//					SP = SP;
//				end
//		endcase
	//end
	
endmodule

