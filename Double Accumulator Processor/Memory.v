module Memory
#(parameter DATA_WIDTH=16)
(
	input [(DATA_WIDTH-1):0] Data, //data that is to written to the memory
	input [(DATA_WIDTH-1):0] Addr, // memory address
	input [(DATA_WIDTH-1):0] SP, // SP address
	input Mem_Write,
	input CLK,
   input	MemRead, //if Mem_Write is 1 then the data is written to the addr
	output [(DATA_WIDTH-1):0] Mem_Data,
	output [(DATA_WIDTH-1):0] SP_Data
);


	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[0:2**DATA_WIDTH-1]; 

	// Variable to hold the registered read address
	reg [DATA_WIDTH-1:0] addr_reg;
	reg [DATA_WIDTH-1:0] sp_reg;
	
	wire [DATA_WIDTH-1:0] addr_bus = Addr;
	wire [DATA_WIDTH-1:0] SP_bus = SP;
		
	initial begin
		$readmemb("memory.txt", ram);
	end

	always @ (posedge CLK)
	begin
		// Write
		if (Mem_Write)
			ram[SP_bus] <= Data;
		

		
			sp_reg = SP_bus;
			addr_reg = addr_bus;
	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.

	assign Mem_Data = (MemRead == 1) ? ram[Addr] : 16'h0;
	assign SP_Data = ram[sp_reg];

endmodule