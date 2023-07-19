`timescale 1 ns/1 ps

//PC Register, Memory, Instruction Register, RegisterFile, 2:1 Mux, 4:1 Mux, ALU
module implementation3(
// Register inputs and out
input [15:0] input_value,
input CLK, RST,write_signal,
output wire [15:0] output_value,


// Memory input and out
input  [15:0] din,
input  [15:0] Addr,
input  Mem_Write,
output wire [15:0] dout,

// ALU inputs and out
input  [15:0] A, B,
input  Op,
output wire [15:0] ALU_Out,


//Instruction Register
input  [15:0] instruction,
output wire [1:0] reg1, reg2, regDest,
output wire [5:0] imm1,
output wire [7:0] imm2,
output wire [9:0] imm3,

// Register File 
input  write, rst,
input  [1:0] wrAddr,
input  [15:0] wrData,
input  [1:0] rdAddrA, rdAddrB,
output wire [15:0] rdDataA, rdDataB,
output wire [15:0] ACCData,
output wire [15:0] ACCOData,
output wire [15:0] SPData,
output wire [15:0] RAData,


//4:1 Mux
input  [1:0] mux1Sel,
input  [15:0] mux1A, mux1B, mux1C, mux1D,
output wire [15:0] mux1Out,

//2:1 Mux
input  mux2Sel,
input  [15:0] mux2A, mux2B,
output wire [15:0] mux2Out
);

ALU alu (
		.A(A),
		.B(B),
		.Op(Op),
		.ALU_Out(ALU_Out)
);

Memory mem (
.Data(din),
.Addr(output_value),
.Mem_Write(Mem_Write),
.CLK(CLK),
.Mem_Data(dout)
);

Register PC(
.CLK(CLK),
.input_value(ALU_Out),
.RST(RST),
.output_value(output_value),
.write_signal(write_signal)
);

InstructionRegister IR(
.instruction(dout),
.CLK(CLK),.RST(RST),
.reg1(reg1), .reg2(reg2), .regDest(regDest),
.imm1(imm1), .imm2(imm2), .imm3(imm3)
);

Register_File regFile(
.write(write), .rst(RST), .CLK(CLK),
.wrAddr(wrAddr), .wrData(wrData),
.rdAddrA(rdAddrA), .rdAddrB(rdAddrB),
.rdDataA(rdDataA), .rdDataB(rdDataB),
.ACCData(ACCData), .ACCOData(ACCOData), .SPData(SPData), .RAData(RAData)
);

mux4_1 Mux1(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
.sel(mux1Sel), .a(rdDataB), .b(mux1B), .c(mux1C), .d(mux1D), .out(mux1Out)
);

mux2_1 Mux2(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
.sel(mux2Sel), .a(rdDataA), .b(output_value), .out(mux2Out)
);



endmodule

module implementation3TB();
reg [15:0] input_value;
reg CLK, RST, write_signal;
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

// Register File 
reg write;
reg [1:0] wrAddr;
reg [15:0] wrData;
reg [1:0] rdAddrA, rdAddrB;
wire [15:0] rdDataA, rdDataB;
wire [15:0] ACCData;
wire [15:0] ACCOData;
wire [15:0] SPData;
wire [15:0] RAData;


//4:1 Mux
reg [1:0] mux1Sel;
reg [15:0] mux1A, mux1B, mux1C, mux1D;
wire [15:0] mux1Out;

//2:1 Mux
reg  mux2Sel;
reg [15:0] mux2A, mux2B;
wire [15:0] mux2Out;


implementation3  UUT(
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
.A(A),
.ALU_Out(ALU_Out),
.B(B),
.Op(Op),

//instruction reg
.instruction(dout),
.reg1(reg1), .reg2(reg2), .regDest(regDest),
.imm1(imm1), .imm2(imm2), .imm3(imm3),

// Register file
.write(write),
.rst(RST),
.wrAddr(wrAddr),
.wrData(wrData),
.rdAddrA(rdAddrA),
.rdDataA(rdDataA),
.rdAddrB(rdAddrB),
.rdDataB(rdDataB),
.ACCData(ACCData), .ACCOData(ACCOData), .SPData(SPData), .RAData(RAData),


//4:1 Mux
.mux1Sel(mux1Sel), .mux1A(rdDataB), .mux1B(mux1B), .mux1C(mux1C), .mux1D(mux1D), .mux1Out(mux1Out),

//2:1 Mux
.mux2Sel(mux2Sel), .mux2A(rdDataA), .mux2B(output_value), .mux2Out(mux2Out)
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
	wrData = 50;
	wrAddr = regDest;
	rdAddrA = reg1;
	rdAddrB = reg2;
	write = 1;
	#(PERIOD)
	mux2Sel = 2'b00;
	mux1Sel = 2'b00;
	#(HALF_PERIOD)
	A = mux2Out;
	B = mux1Out;
	Op = 0;
	#(4 * PERIOD)
	$display("A = %d, B = %d ALU_OUT= %d", A, B, ALU_Out);
	if (ALU_Out != 100) begin
		$display("Test #1 failed");
		failed_tests = failed_tests + 1;
	end

	#(PERIOD)
	
		
	//Test 2
	#(2 * PERIOD);
	write = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#PERIOD;
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	wrData = 100;
	wrAddr = regDest;
	rdAddrA = reg1;
	rdAddrB = reg2;
	write = 1;
	#(PERIOD)
	mux2Sel = 2'b00;
	mux1Sel = 2'b00;
	#(HALF_PERIOD)
	A = mux2Out;
	B = mux1Out;
	Op = 0;
	#(4 * PERIOD)
	$display("A = %d, B = %d ALU_OUT= %d", A, B, ALU_Out);
	if (ALU_Out != 200) begin
		$display("Test #2 failed");
		failed_tests = failed_tests + 1;
	end
	#PERIOD;
	
	
	//Test 3
	#(2 * PERIOD);
	write = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#PERIOD;
	write_signal = 1;
	input_value = ALU_Out;
	#(HALF_PERIOD)
	write_signal = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	wrData = 12;
	wrAddr = regDest;
	rdAddrA = reg1;
	rdAddrB = reg2;
	write = 1;
	#(PERIOD)
	mux2Sel = 2'b00;
	mux1Sel = 2'b00;
	#(HALF_PERIOD)
	A = mux2Out;
	B = mux1Out;
	Op = 0;
	#(4 * PERIOD)
	$display("A = %d, B = %d ALU_OUT= %d", A, B, ALU_Out);
	if (ALU_Out != 50) begin
		$display("Test #3 failed");
		failed_tests = failed_tests + 1;
	end
	#PERIOD;

	//Test 4
	#(2 * PERIOD);
	write = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#PERIOD;
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2*PERIOD);
	wrData = 300;
	wrAddr = regDest;
	rdAddrA = reg1;
	rdAddrB = reg2;
	write = 1;
	#(PERIOD)
	mux2Sel = 2'b00;
	mux1Sel = 2'b00;
	#(HALF_PERIOD)
	A = mux2Out;
	B = mux1Out;
	Op = 0;
	#(4 * PERIOD)
	$display("A = %d, B = %d ALU_OUT= %d", A, B, ALU_Out);
	if (ALU_Out != 350) begin
		$display("Test #4 failed");
		failed_tests = failed_tests + 1;
	end
	#PERIOD;
	
	//Test 5
	#(2*PERIOD)
	write = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#PERIOD;
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	wrData = 20;
	wrAddr = regDest;
	rdAddrA = reg1;
	rdAddrB = reg2;
	write = 1;
	#(PERIOD)
	mux2Sel = 2'b00;
	mux1Sel = 2'b00;
	#(HALF_PERIOD)
	A = mux2Out;
	B = mux1Out;
	Op = 0;
	#(4 * PERIOD)
	$display("A = %d, B = %d ALU_OUT= %d", A, B, ALU_Out);
	if (ALU_Out != 32) begin
		$display("Test #5 failed");
		failed_tests = failed_tests + 1;
	end
	#(PERIOD);
	
	
	//Test 6
	#(2*PERIOD)
	write = 0;
	A = output_value;
	B = 16'b0000000000000001;
	Op = 0;
	#PERIOD;
	write_signal = 1;
	input_value = ALU_Out;
	#(PERIOD)
	write_signal = 0;
	#(HALF_PERIOD)
	din = 0;
	Mem_Write = 0;
	Addr = output_value;
	#(2 * PERIOD)
	instruction = dout;
	#(2 * PERIOD)
	wrData = 0;
	wrAddr = regDest;
	rdAddrA = reg1;
	rdAddrB = reg2;
	write = 1;
	#(PERIOD)
	mux2Sel = 2'b00;
	mux1Sel = 2'b00;
	#(HALF_PERIOD)
	A = mux2Out;
	B = mux1Out;
	Op = 0;
	#(4 * PERIOD)
	$display("A = %d, B = %d ALU_OUT= %d", A, B, ALU_Out);
	if (ALU_Out != 12) begin
		$display("Test #6 failed");
		failed_tests = failed_tests + 1;
	end
	#(PERIOD);
	
	

	
	
	$display("Failed tests: %d fails", failed_tests);
	$stop;
end
endmodule



