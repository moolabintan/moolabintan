`timescale 1 ns/1 ps

//Full Datapath Pretty much
//PC Register, Memory, Instruction Register, RegisterFile, 2:1 Mux, 4:1 Mux, ALU
module Implementation4 (
// Register inputs and out
input CLK, RST,

input [15:0] PC_input_value,
input PC_write_signal,
output wire [15:0] PC_output_value,

//2:1 Mux
input PCSource_sel,
input [15:0] PCSource_a, PCSource_b,
output wire [15:0] PCSource_out,


input [15:0] memData_input_value,
input memData_write_signal,
output wire [15:0] memData_output_value,

input [15:0] reg1_input_value,
input reg1_write_signal,
output wire [15:0] reg1_output_value,

input [15:0] reg2_input_value,
input reg2_write_signal,
output wire [15:0] reg2_output_value,

input [15:0] ALUOUT_input_value,
input ALUOUT_write_signal,
output wire [15:0] ALUOUT_output_value,

input [15:0] immReg_input_value,
input immReg_write_signal,
output wire [15:0] immReg_output_value,

// Memory input and out
input [15:0] din,
input [15:0] Addr,
input Mem_Write,
output wire [15:0] dout,

// ALU inputs and out
input [15:0] A, B,
input Op,
output wire [15:0] ALU_Out,


//Instruction Register
input [15:0] instruction,
input ir_write,
output wire [1:0] reg1, reg2, regDest,
output wire [5:0] imm1,
output wire [7:0] imm2,
output wire [9:0] imm3,
output wire [11:0] imm4,
// Register File 
input write, rst,
input [1:0] wrAddr,
input [15:0] wrData,
input [1:0] rdAddrA, rdAddrB,
output wire [15:0] rdDataA, rdDataB,
output wire [15:0] ACCData,
output wire [15:0] ACCOData,
output wire [15:0] SPData,
output wire [15:0] RAData,

//4:1 Mux
input [1:0] r1_sel,
input [15:0] r1_a, r1_b, r1_c, r1_d,
output wire [15:0] r1_out,

//4:1 Mux
input [1:0] r2_sel,
input [15:0] r2_a, r2_b, r2_c, r2_d,
output wire [15:0] r2_out,


//4:1 Mux
input [1:0] iord_sel,
input [15:0] iord_a, iord_b, iord_c, iord_d,
output wire [15:0] iord_out,

//4:1 Mux
input [1:0] imm_sel,
input [15:0] imm_a, imm_b, imm_c, imm_d,
output wire [15:0] imm_out,

//4:1 Mux
input [1:0] memtoreg_sel,
input [15:0] memtoreg_a, memtoreg_b, memtoreg_c, memtoreg_d,
output wire [15:0] memtoreg_out,

//4:1 Mux
input [1:0] src2_sel,
input [15:0] src2_a, src2_b, src2_c, src2_d,
output wire [15:0] src2_out,

//2:1 Mux
input src1_sel,
input [15:0] src1_a, src1_b,
output wire [15:0] src1_out,

//2:1 Mux
input datatomem_sel,
input [15:0] datatomem_a, datatomem_b,
output wire [15:0] datatomem_out,

//Comparator
input [15:0] cmp_a, cmp_b,
output wire equal, greaterthan, lessthan,

//6b sign extender
input [5:0] in6,
output wire[15:0] out6,

//8b SignExtender
input [7:0] in8,
output wire[15:0] out8,

//10b sign extender
input [9:0] in10,
output wire[15:0] out10,

//10b sign extender
input [11:0] in12,
output wire[15:0] out12,



//Control
input [3:0] Opcode,
input [1:0] R1,
input [1:0] R2,
input [1:0] R3,
output wire MemWrite,
output wire ALUSRC1,
output wire [1:0] ALUSRC2,
output wire IRWrite,
output wire ALUOPP,
output wire [1:0] R1Out,
output wire [1:0] IorD,
output wire [1:0] ImmSel,
output wire [1:0] R2Out,
output wire DatatoMem,
output wire regWrite,
output wire [1:0]MemtoReg,
output wire PCWrite,
output wire PCSource,
output wire R1Write,
output wire R2Write,
output wire MDWrite,
output wire ALUOutWrite,
output wire ImmWrite,
output wire [4:0] State
);

Register PC(
.CLK(CLK),
.input_value(PCSource_out),
.RST(RST),
.output_value(PC_output_value),
.write_signal(PCWrite)
);

mux2_1 PCSource_Mux(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
.sel(PCSource), .a(ALUOUT_output_value), .b(immReg_output_value), .out(PCSource_out)
);

mux4_1 InstorData(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Change what I am doing with C. Should be output of R2
.sel(IorD), .a(PC_output_value), .b(ALUOUT_output_value), .c(reg2_output_value), .d(iord_d), .out(iord_out)
);

Memory mem (
.Data(din),
.Addr(iord_out),
.Mem_Write(MemWrite),
.CLK(CLK),
.Mem_Data(dout),
.SP_Data(sp_out)
);

Register MemData(
.CLK(CLK),
.input_value(dout),
.RST(RST),
.output_value(memData_output_value),
.write_signal(MDWrite)
);

mux2_1 DatatoMemory(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Change what I am doing with this. A will be the output of r2. b will be the chosen immediate
.sel(DatatoMem), .a(reg2_output_value), .b(immReg_output_value), .out(datatomem_out)
);


InstructionRegister IR(
.instruction(dout),
.CLK(CLK),.RST(RST), .write(IRWrite),
.reg1(reg1), .reg2(reg2), .regDest(regDest),
.imm1(imm1), .imm2(imm2), .imm3(imm3), .imm4(imm4)
);


sign_extender6b se1(
.in(imm1), .out(out6)

);

sign_extender8b se2(
.in(imm2), .out(out8)

);

sign_extender10b se3(
.in(imm3), .out(out10)
);

sign_extender12b se4(
.in(imm4), .out(out12)
);

mux4_1 Immediates(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Change what I am doing with C. Should be output of R2
.sel(ImmSel), .a(out6), .b(out8), .c(out10), .d(out12), .out(imm_out)
);

Register ImmReg(
.CLK(CLK),
.input_value(imm_out),
.RST(RST),
.output_value(immReg_output_value),
.write_signal(ImmWrite)
);



Register_File regFile(
.write(regWrite), .rst(RST), .CLK(CLK),
.wrAddr(regDest), .wrData(memtoreg_out),
.rdAddrA(rdAddrA), .rdAddrB(rdAddrB),
.rdDataA(rdDataA), .rdDataB(rdDataB),
.ACCData(ACCData), .ACCOData(ACCOData), .SPData(SPData), .RAData(RAData)
);

mux4_1 R1In(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this. check names
.sel(R1Out), .a(ACCData), .b(ACCOData), .c(SPData), .d(RAData), .out(r1_out)
);

mux4_1 R2In(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this. check names
.sel(R2Out), .a(ACCData), .b(ACCOData), .c(SPData), .d(RAData), .out(r2_out)
);




Register Reg1(
.CLK(CLK),
.input_value(r1_out),
.RST(RST),
.output_value(reg1_output_value),
.write_signal(R1Write)
);

Register Reg2(
.CLK(CLK),
.input_value(r2_out),
.RST(RST),
.output_value(reg2_output_value),
.write_signal(R2Write)
);


mux4_1 MemtoRegister(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this. check names
.sel(MemtoReg), .a(memData_output_value), .b(ALUOUT_output_value), .c(immReg_output_value), .d(memtoreg_d), .out(memtoreg_out)
);



ALU alu (
		.A(src1_out),
		.B(src2_out),
		.Op(ALUOPP),
		.ALU_Out(ALU_Out)
);

mux2_1 ALUSrc1(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
.sel(ALUSRC1), .a(reg1_output_value), .b(PC_output_value), .out(src1_out)
);

mux4_1 ALUSrc2(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this, hardwire a 1 or 2 to this
.sel(ALUSRC2), .a(reg2_output_value), .b(immReg_output_value), .c(src2_c), .d(src2_d), .out(src2_out)
);


Register ALUOut(
.CLK(CLK),
.input_value(ALU_Out),
.RST(RST),
.output_value(ALUOUT_output_value),
.write_signal(ALUOutWrite)
);

Comparator Compare(
.a(reg1_output_value), .b(reg2_output_value), .equal(equal), .greaterthan(greaterthan), .lessthan(lessthan)
);

Control Cont(
	.Opcode(Opcode),
	.R1(reg1),
	.R2(reg2),
	.R3(reg2),
	.CLK(CLK),
	.RST(RST),
	.MemWrite(MemWrite),
	.ALUSRC1(ALUSRC1),
	.ALUSRC2(ALUSRC2),
	.IRWrite(IRWrite),
	.ALUOPP(ALUOPP),
	.R1Out(R1Out),
	.IorD(IorD),
	.R2Out(R2Out),
	.DatatoMem(DatatoMem),
	.regWrite(regWrite),
	.MemtoReg(MemtoReg),
	.PCWrite(PCWrite),
	.PCSource(PCSource),
	.R1Write(R1Write),
	.R2Write(R2Write),
	.MDWrite(MDWrite),
	.ALUOutWrite(ALUOutWrite),
	.State(State),
	.ImmSel(ImmSel),
	.ImmWrite(ImmWrite)
	
);

endmodule

module SystemTest();
// Register inputs and out
//reg[15:0] input_value;
reg CLK, RST;
//wire[15:0] output_value;
parameter HALF_PERIOD=50;
parameter PERIOD = HALF_PERIOD*2;



reg [15:0] PC_input_value;
reg PC_write_signal;
wire [15:0] PC_output_value;

reg PCSource_sel;
reg [15:0] PCSource_a, PCSource_b;
wire [15:0] PCSource_out;


reg [15:0] memData_input_value;
reg memData_write_signal;
wire [15:0] memData_output_value;

reg [15:0] reg1_input_value;
reg reg1_write_signal;
wire [15:0] reg1_output_value;


reg [15:0] reg2_input_value;
reg reg2_write_signal;
wire [15:0] reg2_output_value;

reg [15:0] ALUOUT_input_value;
reg ALUOUT_write_signal;
wire[15:0] ALUOUT_output_value;


reg [15:0] immReg_input_value;
reg immReg_write_signal;
wire [15:0] immReg_output_value;



//4:1 Mux
reg [1:0] r1_sel;
reg [15:0] r1_a, r1_b, r1_c, r1_d;
wire [15:0] r1_out;

//4:1 Mux
reg [1:0] r2_sel;
reg [15:0] r2_a, r2_b, r2_c, r2_d;
wire [15:0] r2_out;

//4:1 Mux
reg [1:0] iord_sel;
reg [15:0] iord_a, iord_b, iord_c, iord_d;
wire [15:0] iord_out;

//4:1 Mux
reg[1:0] imm_sel;
reg[15:0] imm_a, imm_b, imm_c, imm_d;
wire [15:0] imm_out;

//4:1 Mux
reg[1:0] memtoreg_sel;
reg[15:0] memtoreg_a, memtoreg_b, memtoreg_c, memtoreg_d;
wire [15:0] memtoreg_out;

//4:1 Mux
reg[1:0] src2_sel;
reg[15:0] src2_a, src2_b, src2_c, src2_d;
wire [15:0] src2_out;

//2:1 Mux
reg src1_sel;
reg[15:0] src1_a, src1_b;
wire [15:0] src1_out;

//2:1 Mux
reg datatomem_sel;
reg[15:0] datatomem_a, datatomem_b;
wire [15:0] datatomem_out;


// Memory input and out
reg[15:0] din;
reg[15:0] Addr;
reg Mem_Write;
reg [15:0] SP;
wire [15:0] sp_out;
wire[15:0] dout;

// ALU inputs and out
reg[15:0] A, B;
reg Op;
wire[15:0] ALU_Out;


// Instruction Register
reg [15:0] instruction;
reg ir_write;
wire[1:0] reg1, reg2, regDest;
wire[5:0] imm1;
wire[7:0] imm2;
wire[9:0] imm3;
wire[11:0] imm4;

// Register File 
reg write, rst;
reg[1:0] wrAddr;
reg[15:0] wrData;
reg[1:0] rdAddrA, rdAddrB;
wire [15:0] rdDataA, rdDataB;
wire [15:0] ACCData;
wire [15:0] ACCOData;
wire [15:0] SPData;
wire [15:0] RAData;


//Comparator
reg[15:0] cmp_a, cmp_b;
wire equal, greaterthan, lessthan;



//6b sign extender
reg[5:0] in6;
wire[15:0] out6;

//8b SignExtender
reg[7:0] in8;
wire[15:0] out8;

//10b sign extender
reg[9:0] in10;
wire[15:0] out10;

//12b sign extender
reg[11:0] in12;
wire[15:0] out12;

//Control
reg[3:0] Opcode;
reg [1:0] R1;
reg [1:0] R2;
reg [1:0] R3;
wire MemWrite;
wire ALUSRC1;
wire [1:0] ALUSRC2;
wire IRWrite;
wire ALUOPP;
wire [1:0] R1Out;
wire [1:0] IorD;
wire [1:0] R2Out;
wire DatatoMem;
wire Write;
wire [1:0]MemtoReg;
wire PCWrite;
wire PCSource;
wire R1Write;
wire R2Write;
wire MDWrite;
wire [1:0] ImmSel;
wire ImmWrite;
wire ALUOutWrite;
wire [4:0] State;



Implementation4 UUT(
//Register PC
.CLK(CLK),
.PC_input_value(PCSource_out),
.RST(RST),
.PC_write_signal(PCWrite),
.PC_output_value(PC_output_value),

.PCSource_sel(PCSource),
.PCSource_a(ALUOUT_output_value), .PCSource_b(immReg_output_value),
.PCSource_out(PCSource_out),


//mux4_1 InstorData
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Change what I am doing with C. Should be output of R2
.iord_sel(IorD), .iord_a(PC_output_value), .iord_b(ALUOUT_output_value), .iord_c(reg2_output_value), .iord_d(iord_d), .iord_out(iord_out),


//Memory 
.din(datatomem_out),
.Addr(iord_out),
.Mem_Write(MemWrite),
.dout(dout),


//Register MemData
.memData_input_value(dout),
.memData_write_signal(MDWrite),
.memData_output_value(memData_output_value),


//mux2_1 DatatoMemory
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Change what I am doing with this. A will be the output of r2. b will be the chosen immediate
.datatomem_sel(DatatoMem), .datatomem_a(reg2_output_value), .datatomem_b(immReg_output_value), .datatomem_out(datatomem_out),



//InstructionRegister IR
.instruction(dout),
.ir_write(IRWrite),
.reg1(reg1), .reg2(reg2), .regDest(regDest),
.imm1(imm1), .imm2(imm2), .imm3(imm3), .imm4(imm4),



//sign_extender6b se1(
.in6(imm1), .out6(out6),


//sign_extender8b se2(
.in8(imm2), .out8(out8),



//sign_extender10b se3(
.in10(imm3), .out10(out10),

//sign_extender12b se4(
.in12(imm4), .out12(out12),


//Immediates(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Change what I am doing with C. Should be output of R2
.imm_sel(ImmSel), .imm_a(out6), .imm_b(out8), .imm_c(out10), .imm_d(imm_d), .imm_out(imm_out),


//ImmReg
.immReg_input_value(imm_out),
.immReg_output_value(immReg_output_value),
.immReg_write_signal(ImmWrite),




//regFile(
.write(regWrite), .rst(RST),
.wrAddr(regDest), .wrData(memtoreg_out),
.rdAddrA(rdAddrA), .rdAddrB(rdAddrB),
.rdDataA(rdDataA), .rdDataB(rdDataB),
.ACCData(ACCData), .ACCOData(ACCOData), .SPData(SPData), .RAData(RAData),

//mux4_1 R1In(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this. check names
.r1_sel(R1Out), .r1_a(ACCData), .r1_b(ACCOData), .r1_c(SPData), .r1_d(RAData), .r1_out(r1_out),


//mux4_1 R2In(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this. check names
.r2_sel(R2Out), .r2_a(ACCData), .r2_b(ACCOData), .r2_c(SPData), .r2_d(RAData), .r2_out(r2_out),




//Reg1(
.reg1_input_value(r1_out),
.reg1_output_value(reg1_output_value),
.reg1_write_signal(R1Write),


//Reg2(
.reg2_input_value(r2_out),
.reg2_output_value(reg2_output_value),
.reg2_write_signal(R2Write),



//MemtoRegister(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this. check names
.memtoreg_sel(MemtoReg), .memtoreg_a(memData_output_value), .memtoreg_b(ALUOUT_output_value), .memtoreg_c(immReg_output_value), .memtoreg_d(memtoreg_d), .memtoreg_out(memtoreg_out),




//ALU
.A(src1_out),
.B(src2_out),
.Op(ALUOPP),
.ALU_Out(ALU_Out),


//ALUSrc1(
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
.src1_sel(ALUSRC1), .src1_a(reg1_output_value), .src1_b(PC_output_value), .src1_out(src1_out),


//ALUSrc2
//TODO: Figure out what to do with immdeiate. Something with selecting which size immediate we want.
//TODO: Add immediate to this, hardwire a 1 or 2 to this
.src2_sel(ALUSRC2), .src2_a(reg2_output_value), .src2_b(immReg_output_value), .src2_c(src2_c), .src2_d(src2_d), .src2_out(src2_out),



//Register ALUOut
.ALUOUT_input_value(ALU_Out),
.ALUOUT_output_value(ALUOUT_output_value),
.ALUOUT_write_signal(ALUOutWrite),


//Comparator Compare
.cmp_a(reg1_output_value), .cmp_b(reg2_output_value), .equal(equal), .greaterthan(greaterthan), .lessthan(lessthan),


//Control
.Opcode(dout[15:12]),
.R1(reg1),
.R2(reg2),
.R3(reg2),
.MemWrite(MemWrite),
.ALUSRC1(ALUSRC1),
.ALUSRC2(ALUSRC2),
.IRWrite(IRWrite),
.ALUOPP(ALUOPP),
.R1Out(R1Out),
.IorD(IorD),
.R2Out(R2Out),
.DatatoMem(DatatoMem),
.regWrite(regWrite),
.MemtoReg(MemtoReg),
.PCWrite(PCWrite),
.PCSource(PCSource),
.R1Write(R1Write),
.R2Write(R2Write),
.MDWrite(MDWrite),
.ALUOutWrite(ALUOutWrite),
.State(State),
.ImmSel(ImmSel),
.ImmWrite(ImmWrite)
	

);

integer failed_tests = 0;


always
	begin
	CLK = 1; #5; CLK = 0; #5;
	end


initial begin
	
	RST = 1;
	imm_sel = 2;
	src2_c = 1;
	#PERIOD;
	RST = 0;
	#(46 * PERIOD);
	
	$stop;
	
	
	
	
	
	

end


endmodule
