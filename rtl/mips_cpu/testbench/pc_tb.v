module pc_tb(
);
    logic clk;
    logic reset;
    logic Alu_Zero;
    logic [2:0] state;
    logic [31:0] Instruction;
    logic [63:0] Alu_out;
    logic [15:0] immediate_address;
    logic[31:0] instr_address;


    initial begin
        $dumpfile("pc_tb.vcd");
        $dumpvars(0,pc_tb);

        //initialise the pc
        clk = 0;
        reset = 0;
        #5;

        clk = 1;
        #5;

        clk = 0;
        reset = 1;
        state = 3;
        #5;

        clk = 1;
        #5;

        assert(instr_address == 32'hbfc00000) else $fatal(0, "failed, pc = %d", instr_address);

        clk = 0;
        state = 4;
        #5;

        //test the normal incrementation

        clk = 1;
        reset = 0;
        #1;

        assert(instr_address == 32'hbfc00000) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //should not increment when state is not 5

        clk = 1;
        state = 4;
        #1;
       
        assert(instr_address == 32'hbfc00000) else $fatal(0, "failed, pc = %d", instr_address);
        #4

        //should increment when state is 5
        clk = 0;
        state = 5;
        #5;


        clk = 1;
        #1;

        assert(instr_address == 32'hbfc00004) else $fatal(0, "failed, pc = %d", instr_address);
        #4

        clk = 0;
        #5;

        clk = 1;
        #1;

        assert(instr_address == 32'hbfc00008) else $fatal(0, "failed, pc = %d", instr_address);
        #4

        //BEQ
        state = 5;
        clk = 0;
        Instruction = 32'h10650005;
        immediate_address = 16'h5;
        Alu_Zero = 1;
        #5
        
        clk = 1;
        #5;
        clk = 0;
        #5;

        clk = 1;
        #1;

        assert(instr_address == 32'hbfc00020) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5

        //BGEZ
        
        //instr_address = 32'h18;
        Instruction = 32'h04A10004;
        immediate_address = 16'h4;
        Alu_Zero = 1;
        Alu_out = 0;

        clk = 1;
        #5;
        clk = 0;
        #5;

        clk = 1;
        #1;

        assert(instr_address == 32'hbfc00034) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //BGEZAL 
        
        Instruction = 32'h04B10004;
        immediate_address = 16'h4;
        Alu_Zero = 0;
        Alu_out = 64'h1;

        clk = 1;
        #5;
        clk = 0;
        #5;
        
        clk = 1;
        #1;

        assert(instr_address == 32'hBFC00048) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //BGTZ
        
        //instr_address = 32'hBFC00008;
        Instruction = 32'h1CC00001;
        immediate_address = 16'h1;

        clk = 1;
        #5;
        clk = 0;
        #5;
        
        clk = 1;
        #1;

        assert(instr_address == 32'hBFC00050) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5

        //BLEZ
        
        Alu_out = -3;
        //instr_address = 32'hBFC00008;
        Instruction = 32'h18C00001;
        immediate_address = 16'h1;
        
        clk = 1;
        #5;
        clk = 0;
        #5;
        
        clk = 1;
        #1;

        assert(instr_address == 32'hBFC00058) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //reset
        reset = 1;
        
        clk = 1;
        #1;

        assert(instr_address == 32'hBFC00000) else $fatal(0, "failed, pc = %d", instr_address);
        #4;
        
        reset = 0;
        
        clk = 1;
        #1;
        clk = 0;
        #5;

        //BLTZ BLTZAL (link instr does not have a difference in the pc)
        
        Alu_out = -3;
        //instr_address = 32'hBFC00008;
        Instruction = 32'h04C00002;
        immediate_address = 16'h2;
        
        clk = 1;
        #5;
        clk = 0;
        #5;
        
        clk = 1;
        #1;

        assert(instr_address == 32'hBFC0000C) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //BNE
        
        Alu_out = 3;
        //instr_address = 32'hBFC00008;
        Instruction = 32'h14660002;
        immediate_address = 16'h2;
        
        clk = 1;
        #5;
        clk = 0;
        #5;
        
        clk = 1;
        #1;
        clk = 0;
        #1;
        clk = 1;
        assert(instr_address == 32'hBFC00018) else $fatal(0, "failed, pc = %d", instr_address);
        #4;
        clk = 0;
        #5;

        //J
        Instruction = 32'h08000009;
        #1;
        clk = 1;
        #5;
        clk = 0;
        #5;
    
        clk = 1;
        #1;

        assert(instr_address == 32'hB0000024) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //JAL
    
        Instruction = 32'h0C00000A;
        #5;

        clk = 1;
        #5;
        $display("instr_address: ", instr_address);
        #1;
        clk = 0;
        #5;
        
        clk = 1;
        #1;


        assert(instr_address == 32'hB0000028) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //JALR
        
        Instruction = 32'h00C02809;
        Alu_out = 4;
        #5;
        clk = 1;
        #5;
        clk = 0;
        #5;
       
        clk = 1;
        #1;

        assert(instr_address == 4) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        //JR
        state = 5;
        clk = 0;
        Instruction = 32'h00C00008;
        Alu_out = 100;
        #5;
        clk = 1;
        #5;
        clk = 0;
        #5;
        
        clk = 1;
        #1;

        assert(instr_address == 100) else $fatal(0, "failed, pc = %d", instr_address);
        #4;

        clk = 0;
        #5;

        
 
    end


pc pc1(
    .clk(clk),
    .reset(reset),
    .Zero(Alu_Zero),
    .State(state),
    .Instruction(Instruction),
    .ALU(Alu_out),
    .RegPC(instr_address)
);

endmodule