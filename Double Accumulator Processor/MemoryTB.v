//`timescale 1ns / 1ps
module tb_memory();

reg [15:0] din;
reg [15:0] sp;
reg CLK;
reg [15:0] Addr;
reg Mem_Write;
wire [15:0] sp_out;
wire [15:0] dout;



Memory UUT (
.Data(din),
.Addr(Addr),
.Mem_Write(Mem_Write),
.CLK(CLK),
.Mem_Data(dout),
.SP(sp),
.SP_Data(sp_out)
);

	parameter HALF_PERIOD=50;
	parameter PERIOD = HALF_PERIOD*2; 
 
initial begin
    CLK = 0;
    forever begin
        #(HALF_PERIOD);
        CLK = ~CLK;
    end
end

  initial begin

//test one read
         CLK = 0;
         Addr = 16'h0000;
		//	sp = 16'hFFFF;
         din = 16'h1111;

         #PERIOD;
         Addr = 16'h0001;

//test two write
	#PERIOD;
	din = 16'heeea;
	Mem_Write = 1; 
	#PERIOD;
	Mem_Write  = 0;
	sp = 16'hFFFD;
	din = 16'hdead;
	//#PERIOD;
	Mem_Write = 1; 
	#PERIOD;
	 $stop;

	end
endmodule
	