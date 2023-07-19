// PC register, 2:1 mux, memData register, memory, instruction register
module implementation(
// Register inputs and out
input [15:0] input_value,
input  CLK, RST,write_signal,
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
output wire [9:0] imm3
);



//wire [15:0] output_value;


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


endmodule
