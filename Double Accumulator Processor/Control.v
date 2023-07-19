`timescale 1 ns/1 ps

module Control(
	input [3:0] Opcode,
	input CLK,
	input RST,
	
	output reg MemWrite, //
	output reg ALUSRC1, //
	output reg [1:0] ALUSRC2,//
	output reg IRWrite, //
	output reg ALUOPP, //
	output reg RegWrite, //
	output reg PCWrite, //
	output reg ALUOutWrite, //
	output reg MemRead,	//
	output reg [1:0] MemtoReg,//
	output reg [1:0] RSRC1, ///
	output reg [4:0] State,
	output reg [1:0]cmp,
	output reg Branch, //
	output reg [1:0] PCSRC,	
	output reg [1:0] ImmSel,
	output reg DataInSel,
	output reg [1:0] DestIn,
	output reg [15:0] numIns
);//	output reg IorD,
//	output reg [1:0] R2Out,
//	output reg DatatoMem,
//	output reg R1Write,
//	output reg R2Write,
//	output reg MDWrite,
//	output reg ImmWrite,

 reg [3:0] op;



parameter [4:0] Reset_s = 0, Fetch = 1, Decode = 2, PushDec = 3,
 PushMemWrite = 4, PushRegWrite = 5, Pushi = 6, Pop = 7, PopInc = 8,
 PopWrite = 9, AddiOpp = 10, AddiWrite = 11, Load = 12, Peek = 13,
 PeekRead = 14, PeekWrite = 15, SAdd = 16, SSub = 17, SWrite = 18,
 gte = 19, JumpProc = 20, Ret = 21, Proc = 22, LessThan = 23,
 Equal = 24, NotEqual = 25, Lui= 26, getInput = 27;
 

always @ (posedge CLK)
	begin
	if(RST) State = Reset_s;

			//$display("The opcode is %d", Opcode);
	case (State)
				Reset_s: 
					begin
						 numIns = 0;
						 ALUSRC1 = 0;
						 ALUSRC2 = 0;	
						 ALUOPP = 0;
						 IRWrite = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						 MemRead = 0;
						 DestIn = 0;
						 PCSRC = 0;
						 ALUOutWrite = 0;
						 ImmSel = 2'b00;
		   			 cmp = 2'b00;
						 RSRC1 = 2'b00;
						 MemtoReg = 2'b00;
						 Branch = 0;
						 DataInSel = 0;
						 cmp = 0;


		if(!RST) begin
						 State = getInput;
						 end
					end
				getInput: 
					begin 
						DestIn = 3;
						RegWrite = 1;
						MemtoReg = 3;
						State = Fetch;
					end
				Fetch: 
					begin
					    numIns = numIns + 1;
						 PCSRC = 2'b01;
						 PCWrite = 1;
						 MemRead = 1;
						 ALUSRC1 = 0;
						 MemWrite = 0;
						 ALUSRC2 = 0;
						 IRWrite = 1;
						 ALUOPP = 0;
						 RegWrite = 0;
						 ALUOutWrite = 0;
						 Branch = 0;
						 DataInSel = 0;
                   cmp = 0;
						State = Decode;
					end
				Decode: 
					begin
						 IRWrite = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						 MemRead = 0;
						 DataInSel = 0;
						 ALUOutWrite = 1;
						 
						 ALUOPP = 0;
						 ALUSRC1 = 0;
						 ALUSRC2 = 1;
						 ImmSel = 1;
						 op = Opcode;

						if(Opcode == 4'b0000) State = AddiOpp; //addi0 && R1 == 2'b00
						//else if (Opcode == 4'b0000 && R1 == 2'b01) State = AddiOpp1; //addi1
						else if (Opcode == 4'b0001) State = Load; //li
						else if (Opcode == 4'b1110) State = Lui;
						else if (Opcode == 4'b1111) State = Peek; //peek
						else if (Opcode == 4'b0010) State = SAdd; //add, R1 = 00, R2 = 00;
						else if (Opcode == 4'b0011) State = SSub; //sub, R1 = 00, R2 = 00
				
						else if (Opcode == 4'b0100 || Opcode == 4'b0101) State = PushDec; //push/pushi
						else if (Opcode == 4'b0110) State = Pop; //pop
						else if (Opcode == 4'b1010) State = Equal;
						else if (Opcode == 4'b1011) State = gte;
						else if (Opcode == 4'b1100) State = LessThan;
						else if (Opcode == 4'b1101) State = NotEqual; 
						else if (Opcode == 4'b0111 || Opcode == 4'b1001) State = JumpProc; // jump/proc
						else if (Opcode == 4'b1000) State = Ret; //ret 
					end
					
				AddiOpp: 
					begin
						// R1Sel = 1;
						//ImmSel = 2'b10;	
					 ALUSRC1 = 1;
					 ALUSRC2 = 1;
					 ALUOPP = 0;
					 DataInSel = 0;
					 RSRC1 = 1;
					 ImmSel = 2;
					 
					 ALUOutWrite = 1;
					 IRWrite = 0;
					 MemRead = 0;
					 MemWrite = 0;
					 RegWrite = 0;
					 PCWrite = 0;
					 State = AddiWrite;
					end


				AddiWrite: 
					begin
					   MemtoReg = 0;
					   RegWrite = 1;
						ALUOutWrite = 0;
						IRWrite = 0;
						DataInSel = 0;
						MemWrite = 0;
						PCWrite = 0;
						MemRead = 0;
						DestIn = 0;
						State = Fetch;
					end
					
					
				Load: 
					begin
					 ImmSel = 2;
					 DestIn = 0;
					 MemtoReg = 1;
					 DataInSel = 0;
					 ALUOutWrite = 0;
					 IRWrite = 0;
					 MemRead = 0;
					 MemWrite = 0;
					 RegWrite = 1;
					 PCWrite = 0;
					 State = Fetch;
					end
					
				Lui:
					begin
						 DestIn = 0;
						 MemtoReg = 1;
						 ImmSel = 3;
						 DataInSel = 0;
					
						 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 1;
						 PCWrite = 0;
						 State = Fetch;
					end
					
				SAdd: 
					begin		
					 ALUSRC1 = 1;
					 ALUSRC2 = 2'b10;
					 ALUOPP = 0;
					 DataInSel = 0;
					 RSRC1 = 0;
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						 State = AddiWrite;
					end
					
				SSub: 
					begin
					 ALUSRC1 = 1;
					 ALUSRC2 = 2'b10;
					 DataInSel = 0;
					 ALUOPP = 1;
					 RSRC1 = 0;
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						 //MDSel = 0;
						 State = AddiWrite;
					end
					
				Peek:
					begin
						DestIn = 0; 
						MemtoReg = 2; 
						DataInSel = 0;
	    			   ALUOutWrite = 0;
					   IRWrite = 0;
					   MemRead = 0;
						MemWrite = 0;
						RegWrite = 1;
						PCWrite = 0;
						State = Fetch;
					end
								
				PushDec: 
					begin
						 ALUSRC1 = 1;
						 DataInSel = 0;
						 ALUSRC2 = 0;
						 ALUOPP = 1;
						 RSRC1 = 2;
						 
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						 $display("OPcode is %b, Op is %b",Opcode, op);
						 State = PushMemWrite;
					end
					
				PushMemWrite: 
					begin
						MemtoReg = 0;
						DataInSel = 0;
						DestIn = 1;
						 
						 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 1;
						 PCWrite = 0;
						 //MDSel = 0;
						 if(op == 4'b0101) State = PushRegWrite;
						//else if(Opcode == 0101 && R2 == 01) State = PushMemWrite1;
						else if(op == 4'b0100) State = Pushi;
					end

				Pushi: 
					begin
						 DataInSel = 1;
						 ImmSel = 3;
						 
						 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 1;
						 RegWrite = 0;
						 PCWrite = 0;
						 State = Fetch;
					end
					
				PushRegWrite: 
					begin
						 DestIn = 0;
						 DataInSel = 0;
						 RSRC1 = 1;
						 			
						 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 1;
						 RegWrite = 0;
						 PCWrite = 0;
						State = Fetch;
					end
					
				Pop: 
					begin
						DestIn = 0; 
						DataInSel = 0;
						MemtoReg = 2;
						 
	    				 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 1;
						 PCWrite = 0;
						State = PopInc;
					end
					
				PopInc: 
					begin
						 ALUSRC1 = 1;
						 DataInSel = 0;
						 ALUSRC2 = 2'b00;
						 ALUOPP = 0;
						 RSRC1 = 2;
						 
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						State = PopWrite;
					end
					
				PopWrite:
					begin
						 MemtoReg = 0;
						 DataInSel = 0;
						 DestIn = 1;
					
						 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 1;
						 PCWrite = 0;
						 State = Fetch;
					end
					
					
				Equal:
					begin
						 RSRC1 = 1;
						 DataInSel = 0;
						 cmp = 2'b00;
						 Branch =1;
						 PCSRC = 3;
							
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						State = Fetch;
					end
				
				LessThan:
					begin
						 RSRC1 = 1;
						 DataInSel = 0;
						 cmp = 2'b10;
						 Branch =1;
						 PCSRC = 3;
							
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						State = Fetch;
					end
				
				gte:
					begin
						 RSRC1 = 1;
						 DataInSel = 0;
						 cmp = 2'b01;
						 Branch =1;
						 PCSRC = 3;
							
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						State = Fetch;
					end
				
				NotEqual:
					begin
						 RSRC1 = 1;
						 DataInSel = 0;
						 cmp = 2'b11;
						 Branch =1;
						 PCSRC = 3;
							
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 0;
						State = Fetch;
					end
				

				JumpProc:
					begin					
						 ALUSRC1 = 0;
						 DataInSel = 0;
						 ALUSRC2 = 2'b11;
						 ALUOPP = 0;
						 ImmSel = 3;
						 PCSRC =0;
						 
						 ALUOutWrite = 1;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						 PCWrite = 1;
						if(op == 4'b1001) State = Proc;
						else if(op == 4'b0111) State = Fetch;
					end
					
				Proc: 
					begin
						 DestIn = 2'b10;
						 DataInSel = 0;
						 MemtoReg = 0;						 
						 
						 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 1;
						 PCWrite = 0;
						State = Fetch;
					end
					
				Ret: 
					begin
						ALUSRC1 = 0;
						DataInSel = 0;
					   ALUSRC2 = 2'b00;
						ALUOPP = 0;
					   PCSRC =2'b10;
						PCWrite = 1;
						 
						 ALUOutWrite = 0;
						 IRWrite = 0;
					    MemRead = 0;
						 MemWrite = 0;
						 RegWrite = 0;
						State = Fetch;
					end
					
				default: 
					begin
						 ALUSRC1 = 0;
						 ALUSRC2 = 2'b00;
						 IRWrite = 0;
						 DataInSel = 0;
						 ALUOPP = 0;
						 RegWrite = 0;
						 MemWrite = 0;
						 PCWrite = 0;
						 ALUOutWrite = 0;
						 
						$display("inside default, Opcode wrong");
						State = Reset_s;
					end
			endcase
end
endmodule
				