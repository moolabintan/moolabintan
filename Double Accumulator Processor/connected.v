`timescale 1ns / 1ps
module connected(
		input CLK, RST,
		input [15:0] ACCInput,
		output [4:0] State,
		output [15:0] ACC
);

//control
	wire PCWrite;
	wire MemWrite;
	wire IRWrite;
	wire RegWrite;
	wire ALUSRC1;
	wire [1:0] ALUSRC2;	
	wire OPP;
	wire ALUOutWrite;
	wire MemRead;
	wire [1:0] RSRC1;
	wire [1:0] ImmSel;
	wire [1:0] MemtoReg;
	wire [1:0] cmp;
	wire Branch;
	wire DataInSel;
	wire [1:0] DestIn;
	wire [1:0] PCSRC;
	wire [15:0] numIns;


	//control
	wire[15:0] Instruction;
	Control Control(
	//inputs
	.Opcode(Instruction[15:12]),
	.CLK(CLK),
	.RST(RST),
	
	//outputs
	.PCWrite(PCWrite),
	.MemWrite(MemWrite),
	.IRWrite(IRWrite),
	.RegWrite(RegWrite),
	.ALUSRC1(ALUSRC1),
	.ALUSRC2(ALUSRC2),	
	.ALUOPP(OPP),
	.ALUOutWrite(ALUOutWrite),
	.MemRead(MemRead),
	.MemtoReg(MemtoReg),
	.RSRC1(RSRC1),
	.State(State),
	.cmp(cmp),
	.ImmSel(ImmSel),
	.PCSRC(PCSRC),
	.DestIn(DestIn),
	.DataInSel(DataInSel),
	.Branch(Branch),
	.numIns(numIns)	
	);
	
	//PC
	wire [15:0] PCOut, PCIn;
	wire PCWrite2;
	wire compOut;
//	
	assign  PCWrite2 = ((compOut && Branch) || PCWrite);
	wire [15:0] ALUtoALUOut;

	Register PC(
	.input_value(PCIn),
	.CLK(CLK), 
	.RST(RST), 
	.output_value(PCOut), 
	.write_signal(PCWrite2)
	);
	
	//PCSRCMux
	wire [15:0] SEImm;
	wire [15:0] ALUOut_Out;	
	wire [15:0] SP;
	wire [15:0] RA;
	mux4_1 PCSRCMux(
	.sel(PCSRC),
	.a(SEImm),
	.b(ALUtoALUOut),
	.c(RA),
	.d(ALUOut_Out),
	.out(PCIn)
	);
	
	//DataInMux
	wire [15:0] DataIn;
	wire [15:0] RFOut;
	mux2_1 DataInMux(
	.sel(DataInSel),
	.a(RFOut),
	.b(SEImm),
	.out(DataIn)
	);
	
		//Mem
//	wire [15:0] DatatoMem_to_Mem;
//	wire [15:0] MDIn;
	wire [15:0] SPData;
	Memory Mem(
	.Data(DataIn), 
	.Addr(PCOut), //address of PC
	.SP(SP), 
	.Mem_Write(MemWrite),
	.CLK(CLK), 
	.MemRead(MemRead),
	.Mem_Data(Instruction),
	.SP_Data(SPData)
	);
	
	//IR
	wire [5:0]imm1;
	wire [7:0]imm2;
	wire [9:0]imm3;
	wire [11:0]imm4;
	wire [1:0] R1;
	wire [1:0] R2;
	wire [1:0] R3;
	InstructionRegister IR(
	.instruction(Instruction),
	.CLK(CLK),
	.RST(RST),
	.write_signal(IRWrite),
	.reg1(R1),
	.reg2(R2),
	.regDest(R3),
	.imm1(imm1),
	.imm2(imm2),
	.imm3(imm3),
	.imm4(imm4)
	);
	
	//RSRC1Mux
	wire [1:0] RSRC1Out;
	miniMux4_1 RSRC1Mux(
	.sel(RSRC1),
	.a(R1),
	.b(R3),
	.c(2'd2),
	.d(),
	.out(RSRC1Out)
	);
	
	//SEs
	wire [15:0]SEImm1;
	sign_extender6b SE1(
	.in(imm1),
	.out(SEImm1)
	);
	
	wire [15:0]SEImm2;
	sign_extender8b SE2(
	.in(imm2),
	.out(SEImm2)
	);
	
   //SE3
	wire[15:0] SEImm3;
sign_extender10b SE3(
	.in(imm3),
	.out(SEImm3)
	);
	
	wire [15:0] SEImm4;
sign_extender12b SE4(
	.in(imm4),
	.out(SEImm4)
	);
	
	//ImmSelMux
mux4_1 ImmSelMux(
	.sel(ImmSel), //add ImmSel to control
	.a(SEImm1),
	.b(SEImm2),
	.c(SEImm3),
	.d(SEImm4),
	.out(SEImm)
	);
	
	//MemtoRegMux
	wire [15:0] RFData;	
	mux4_1 MemtoRegMux(
	.sel(MemtoReg), //add ImmSel to control
	.a(ALUOut_Out),
	.b(SEImm),
	.c(SPData),
	.d(ACCInput),//
	.out(RFData)
	);
	
	//DestInMux
	wire [1:0] Dest;
	miniMux4_1 DestInMux(
	.sel(DestIn), //add ImmSel to control
	.a(R3),
	.b(2'd2),
	.c(2'd3),
	.d(2'd0),//
	.out(Dest)
	);
	
	//RF
	//wire [15:0] ACC;
	wire [15:0] ACCO;
Register_File RF(
	.CLK(CLK),
	.rst(RST),
	.write(RegWrite),
	.Dest(Dest),
	.wrData(RFData),
	.ACC(ACC),
	.SP(SP),
	.RA(RA),
	.ACCO(ACCO)
);
	
	//RSRC1OutMux mux
	//wire [15:0] R1Out;
	mux4_1 RSRC1OutMux(
	.sel(RSRC1Out),
	.a(ACC),
	.b(ACCO),
	.c(SP),
	.d(RA),
	.out(RFOut)
	);
	
	//R2 Mux
	wire [15:0] RFOut2;
	mux4_1 R2Mux(
	.sel(R2),
	.a(ACC),
	.b(ACCO),
	.c(SP),
	.d(RA),
	.out(RFOut2)
	);
	
	//ALUSRC1Mux
	wire [15:0] SRC1Out;
	mux2_1 ALUSRC1Mux(
	.sel(ALUSRC1), 
	.a(PCOut),
	.b(RFOut),
	.out(SRC1Out)
	);
	
	//ALUSRC2Mux
	wire [15:0]SRC2Out;
	mux4_1 ALUSRC2Mux(
	.sel(ALUSRC2), //add ImmSel to control
	.a(16'd1),
	.b(SEImm),
	.c(RFOut2),
	.d(16'd0),
	.out(SRC2Out)
	);
	
	//ALU
	ALU ALU(
	.A(SRC1Out),
	.B(SRC2Out),
	.Op(OPP),
	.ALU_Out(ALUtoALUOut)
	);
	
	//ALUOut
	Register ALUOut(
	.input_value(ALUtoALUOut),
	.CLK(CLK), 
	.RST(RST), 
	.output_value(ALUOut_Out), 
	.write_signal(ALUOutWrite)
	);
	

		//Comparator
	Comparator CMP(
	.a(RFOut2),
	.b(RFOut),
	.cmp(cmp),
	.dout(compOut)
	);
	
	
	
	endmodule
	
	