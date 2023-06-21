module mips_cpu_bus(
    input logic clk,
    input logic reset,
    input logic waitrequest,
    input logic[31:0] readdata,

    output logic read,
    output logic write,
    output logic active,
    output logic[31:0] address,
    output logic[31:0] writedata,
    output logic[31:0] register_v0,
    output logic[3:0] byteenable
);

    logic[2:0] state;
    // instruction
    logic [31:0] Instruction, reg_instruction, tmp_instruction, RegPC;
    logic Verify;

    //control Part
    logic MemReadEn, MemWriteEn, RegWriteEn, RegReadEn, HiEn, LoEn, Branch;
    logic[1:0] RegWriteDst;
    logic[2:0] RegWriteDataSel;

    //alu
    logic[3:0] AluControl;
    logic AluSrc2Sel;
    logic[63:0] ALU;
    logic Zero;
    logic AluRegEn;

    //memory
    logic[31:0] MemOut, MemAddressOut, ReadOutMem;
    
    //Regfile
    logic[31:0] RegOutput1, RegOutput2;
    
    // output active
    logic reg_active;

    // instruction register
    always @(*) begin
        if(state == 2)begin
            tmp_instruction = ReadOutMem;
        end
    end
    
    always_ff @(posedge clk)begin
        if(state == 2)begin
            reg_instruction <= ReadOutMem;
        end
    end
    assign Instruction = (state == 2) ? tmp_instruction : reg_instruction;

    always @(*)begin
        if(state == 1)begin
            address = RegPC;
        end
        else if(state == 4)begin
            address = MemAddressOut;
        end
    end

    // assign read and write port of real memory
    assign write = MemWriteEn;
    assign read = MemReadEn;


    //halt
    //The active signal should be driven high when reset is asserted, 
    //and remain high until the CPU halts. Once the CPU has halted (for any reason) the active signal should be sent low.
    always_ff @(posedge clk)begin
        if (reset==1) begin
            reg_active <= 1;
        end
        else if (RegPC==0) begin
            reg_active <= 0;
        end
    end
    assign active = reset || reg_active;
    
    // always @(*) begin
    //     if(reg_active == 0)begin
    //         $finish;
    //     end
    // end
    
    fsm Finite_State_Machine(
        .WaitRequest(waitrequest),
        .clk(clk),
        .reset(reset),
        .State(state)
    );
    
    
    pc Program_Counter(
        .reset(reset),
        .clk(clk),
        .Zero(Zero),
        .State(state),
        .Instruction(Instruction),
        .ALU(ALU),
        // output of instruction address
        .RegPC(RegPC)
    ); 

// problem: instruction obtained and mem_out
    mem_interface Mem_Interface(
        .Verify(Verify),
        .MemOut(readdata),
        .Instruction(Instruction),
        .ALU(ALU),
        .State(state),
        //read_out_2
        .RegOutput2(RegOutput2),
        //output
        .ByteEnable(byteenable),
        .ReadOutMem(ReadOutMem),
        // two  total cpu outputs
        .WriteInMem(writedata),
        .MemAddressOut(MemAddressOut) 
    );
    
    
    regfile Regfile(
        .Verify(Verify),
        .clk(clk),
        .reset(reset),
        .Instruction(Instruction),
        .RegWriteEn(RegWriteEn),
        .RegReadEn(RegReadEn),
        .HiEn(HiEn),
        .LoEn(LoEn),
        .RegWriteDst(RegWriteDst),
        .RegWriteDataSel(RegWriteDataSel),
        //PC input to register
        .RegPC(RegPC),
        //connect to the read port of meminterface
        .ReadOutMem(ReadOutMem),
        .ALU(ALU),
        //output
        .RegOutput1(RegOutput1),
        .RegOutput2(RegOutput2),
        //one of the outputs of the total cpu
        .V0(register_v0) 
    );

    control Control(
        .Instruction(Instruction),
        .State(state),
        .Verify(Verify),
        //below is the output
        .RegWriteDst(RegWriteDst),
        .RegWriteDataSel(RegWriteDataSel),
        .AluControl(AluControl),
        .MemReadEn(MemReadEn),
        .MemWriteEn(MemWriteEn),
        .RegWriteEn(RegWriteEn),
        .RegReadEn(RegReadEn),
        .AluSrc2Sel(AluSrc2Sel),
        .HiEn(HiEn),
        .LoEn(LoEn),
        .BranchSel(BranchSel),
        .AluRegEn(AluRegEn)
    );


    alu Alu(
        .clk(clk),
        .AluRegEn(AluRegEn),
        .Instruction(Instruction),
        .AluControl(AluControl),
        .RegOutput1(RegOutput1),
        .RegOutput2(RegOutput2),
        .AluSrc2Sel(AluSrc2Sel),
        .ALU(ALU), // output can be even bigger
        .Zero(Zero),
        .BranchSel(BranchSel)
    );

    verify_instr VerifyBlock(
        .Instruction(Instruction),
        .Verify(Verify)
    ); 
  
endmodule