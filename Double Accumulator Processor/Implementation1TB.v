`timescale 1 ns/1 ps

module implementation1TB();
reg [15:0] input_value;
reg CLK, RST,write_signal;
wire [15:0] output_value;
parameter HALF_PERIOD=50;
parameter PERIOD = HALF_PERIOD*2;

// Memory input and out
reg [15:0] din;
reg [15:0] Addr;
reg Mem_Write;
wire [15:0] dout;

// ALU inputs and out
reg [15:0] A, B;
reg Op;
wire [15:0] ALU_Out;

//Instruction Register
reg [15:0] instruction;
wire [1:0] reg1, reg2, regDest;
wire [5:0] imm1;
wire [7:0] imm2;
wire [9:0] imm3;


implementation UUT(
//Used by all
.CLK(CLK),.RST(RST),

//PC Register
.input_value(ALU_Out),
.output_value(output_value),
.write_signal(write_signal),

// Memory
.din(din),
.Addr(output_value),
.Mem_Write(Mem_Write),
.dout(dout),

// ALU
.A(output_value),
.ALU_Out(ALU_Out),
.B(B),
.Op(Op),

//instruction reg
.instruction(dout),
.reg1(reg1), .reg2(reg2), .regDest(regDest),
.imm1(imm1), .imm2(imm2), .imm3(imm3)
);

integer failed_tests = 0;

initial begin
    CLK = 0;
    forever begin
        #(HALF_PERIOD);
        CLK = ~CLK;
    end
end


initial begin 

	//Test 1
	RST = 1;
	#(2 * PERIOD)
	RST = 0;
	write_signal = 0;
	input_value = 16'b0000000000000000;
	#(PERIOD)
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#(PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	$display("instruction = %b, reg1 = %b reg2 = %b regDest = %b imm1 = %b imm2 = %b imm3 = %b", instruction, reg1, reg2, regDest, imm1, imm2, imm3);
	if(instruction != 16'b0001000000000000 || reg1 != 2'b00 || reg2 != 2'b00 || regDest != 2'b00 || imm1 != 6'b000000 || imm2 != 8'b00000000 || imm3 != 10'b0000000000) begin
	 $display("Failed test 1");
    failed_tests = failed_tests + 1;
	end
	

	//Test 2
	#(2 * PERIOD);
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	$display("instruction = %b, reg1 = %b reg2 = %b regDest = %b imm1 = %b imm2 = %b imm3 = %b", instruction, reg1, reg2, regDest, imm1, imm2, imm3);
	if(instruction != 16'b0001000000010101 || reg1 != 2'b01 || reg2 != 2'b01 || regDest != 2'b01 || imm1 != 6'b000000 || imm2 != 8'b00000001 || imm3 != 10'b0000000101) begin
	 $display("Failed test 2");
    failed_tests = failed_tests + 1;
	end
	

	//Test 3
	#(2 * PERIOD);
	write_signal = 1;
	input_value = ALU_Out;
	#(HALF_PERIOD)
	write_signal = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	$display("instruction = %b, reg1 = %b reg2 = %b regDest = %b imm1 = %b imm2 = %b imm3 = %b", instruction, reg1, reg2, regDest, imm1, imm2, imm3);
	if(instruction != 16'b1101000011100001 || reg1 != 2'b10 || reg2 != 2'b00 || regDest != 2'b01 || imm1 != 6'b000011 || imm2 != 8'b00001110 || imm3 != 10'b0000111000) begin
	 $display("Failed test 3");
    failed_tests = failed_tests + 1;
	end
	


	//Test 4
	#(2 * PERIOD);
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	$display("instruction = %b, reg1 = %b reg2 = %b regDest = %b imm1 = %b imm2 = %b imm3 = %b", instruction, reg1, reg2, regDest, imm1, imm2, imm3);
	if(instruction != 16'b1001000000001010 || reg1 != 2'b00 || reg2 != 2'b10 || regDest != 2'b10 || imm1 != 6'b000000 || imm2 != 8'b00000000 || imm3 != 10'b0000000010) begin
	 $display("Failed test 4");
    failed_tests = failed_tests + 1;
	end
	

//	
	
	//Test 5

//	#(2 * PERIOD);
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	$display("instruction = %b, reg1 = %b reg2 = %b regDest = %b imm1 = %b imm2 = %b imm3 = %b", instruction, reg1, reg2, regDest, imm1, imm2, imm3);
	if(instruction != 16'b0111000000010000 || reg1 != 2'b01 || reg2 != 2'b00 || regDest != 2'b00 || imm1 != 6'b000000 || imm2 != 8'b00000001 || imm3 != 10'b0000000100) begin
	 $display("Failed test 5");
    failed_tests = failed_tests + 1;
	end
	
//	
	//Test 6
	#(2 * PERIOD);
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	$display("instruction = %b, reg1 = %b reg2 = %b regDest = %b imm1 = %b imm2 = %b imm3 = %b", instruction, reg1, reg2, regDest, imm1, imm2, imm3);
	if(instruction != 16'b0000000000000100 || reg1 != 2'b00 || reg2 != 2'b01 || regDest != 2'b00 || imm1 != 6'b000000 || imm2 != 8'b00000000 || imm3 != 10'b0000000001) begin
	 $display("Failed test 6");
    failed_tests = failed_tests + 1;
	end	
	
	
	
	$display("You failed %d Test", failed_tests);
	$stop;
	
end

endmodule
	
