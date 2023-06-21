module mips_cpu_bus_pipeline(
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
    //need to delete
);

    // instruction
    logic [31:0] IF_ID_Instruction, ID_EX_Instruction, EX_MEM_Instruction, MEM_WB_Instruction, tmp_Instruction;
    logic [31:0]  IF_RegPC, PC_to_Reg;
    logic Verify;

    //control Part
    logic MemReadEn, MemWriteEn, RegWriteEn, RegReadEn, HiEn, LoEn, Branch;
    logic [31:0] EX_MEM_RegWrite, MEM_WB_RegWrite;
    logic[1:0] RegWriteDst;
    logic[2:0] RegWriteDataSel;
    logic EX_MEM_RegWriteEn, MEM_WB_RegWriteEn;
    logic ID_EX_MemReadEn, EX_MEM_MemReadEn;
    logic [1:0] MEM_WB_RegWriteDst;
    logic [2:0] EX_MEM_RegWriteDataSel;
    logic MEM_WB_RegWriteDataSel;
    logic IF_ID_WriteNext;
    logic Is_JB_stall;

    //alu
    logic[31:0] AluSrc1, AluSrc2;
    logic[3:0] AluControl;
    logic AluSrc2Sel;
    logic[63:0] ALU;
    logic Zero;
    logic AluRegEn;

    //memory
    logic[31:0] MemAddressOut, ReadOutMem;
    
    //Regfile
     
    logic [4:0] EX_MEM_Rdest, ID_EX_Rdest, MEM_WB_Rdest;
    logic[31:0] RegOutput1, RegOutput2, RegOutput2Imm, RegOutput1Imm;
    
    // hazard detection
    logic PCWrite;
    logic IF_ID_Write;
    logic FetchMemSel; // if 1, select pc; if 0, select load/write data mem
    logic IF_ID_valid;

    // output active
    logic reg_active, reg_active1, reg_active2, reg_active3, reg_active4;

    // instruction register
    always @(posedge clk) begin
        IF_ID_WriteNext <= IF_ID_Write;
    end

    assign IF_ID_Instruction = (IF_ID_WriteNext) ? ReadOutMem : tmp_Instruction;
    
    always_ff @(posedge clk)begin
        if(IF_ID_WriteNext == 1)begin
            tmp_Instruction <= ReadOutMem;          
        end 
    end

    always @(posedge clk) begin

        ID_EX_Instruction <= IF_ID_Instruction;
        EX_MEM_Instruction <= ID_EX_Instruction;
        MEM_WB_Instruction <= EX_MEM_Instruction;


    end

    always @(*)begin
        if(FetchMemSel == 1)begin
            address = IF_RegPC;
        end
        else begin
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

        reg_active1 <= reg_active;
        reg_active2 <= reg_active1;
        reg_active3 <= reg_active2;
        reg_active4 <= reg_active3;
        if (reset==1) begin
            reg_active <= 1;
        end
        else if (IF_RegPC==0 && IF_ID_Write) begin
            reg_active <= 0;
        end
    end
    assign active = (reset || reg_active || reg_active1 || reg_active2 || reg_active3 || reg_active4);
    
    
    
    
    


    pipe_pc Program_Counter(
        .reset(reset),
        .clk(clk),
        .IF_ID_Instruction(IF_ID_Instruction),
        .PCWrite(PCWrite),
        .RegOutput1(RegOutput1),
        .RegOutput2(RegOutput2),
        .RegOutput1Imm(RegOutput1Imm),
        .RegOutput2Imm(RegOutput2Imm),
        .RegPC(IF_RegPC) 
    ); 

    pipe_mem_interface Mem_Interface(
        .clk(clk),
        .MemOut(readdata),
        .MEM_WB_Instruction(MEM_WB_Instruction),
        .EX_MEM_Instruction(EX_MEM_Instruction),
        .ALU(ALU),
        .RegOutput2(AluSrc2),
        .FetchMemSel(FetchMemSel),
        .ReadOutMem(ReadOutMem),
        .WriteInMem(writedata),
        .ByteEnable(byteenable),
        .MemAddressOut(MemAddressOut) 
    );
    
    
    pipe_regfile rf(
        .clk(clk),
        .reset(reset),
        .IF_ID_Instruction(IF_ID_Instruction),
        .MEM_WB_Instruction(MEM_WB_Instruction),
        .RegWriteEn(MEM_WB_RegWriteEn),
        .RegReadEn(RegReadEn),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_RegWriteDst(MEM_WB_RegWriteDst),
        .RegOutput1(RegOutput1),
        .RegOutput2(RegOutput2),
        .RegOutput1Imm(RegOutput1Imm),
        .RegOutput2Imm(RegOutput2Imm),
        .V0(register_v0)
    );


    pipe_control_register ControlReg(
        .IF_ID_valid(IF_ID_valid),
        .clk(clk),
        .IF_ID_Instruction(IF_ID_Instruction),
        .RegOutput1(RegOutput1), //Rs
        .RegOutput2(RegOutput2), //Rt
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ID_EX_MemReadEn(ID_EX_MemReadEn),
        .EX_MEM_MemReadEn(EX_MEM_MemReadEn),
        .EX_MEM_MemWriteEn(EX_MEM_MemWriteEn),
        .MEM_WB_RegWriteDst(MEM_WB_RegWriteDst),
        // RegWriteDst = 0, inst[20:16]; RegWriteDst = 1, inst[15-11]; RegWriteDst = 2 write to $31
        .EX_MEM_RegWriteDataSel(EX_MEM_RegWriteDataSel),
        .MEM_WB_RegWriteDataSel(MEM_WB_RegWriteDataSel),
        .MEM_WB_Rdest (MEM_WB_Rdest),
        .EX_MEM_Rdest (EX_MEM_Rdest),
        .ID_EX_Rdest (ID_EX_Rdest),
        .AluControl(AluControl),
        .MemReadEn(MemReadEn),
        .MemWriteEn(MemWriteEn),
        .MEM_WB_RegWriteEn(MEM_WB_RegWriteEn),
        .RegReadEn(RegReadEn),
        .AluSrc2Sel(AluSrc2Sel),
        .HiEn(HiEn),
        .LoEn(LoEn),
        .AluRegEn(AluRegEn),
        .AluSrc1(AluSrc1),
        .AluSrc2(AluSrc2),
        .reset(reset),
        .reg_active3(reg_active3)
    );


    pipe_alu Alu_Block(
        .clk(clk),
        .AluRegEn(AluRegEn),
        .Instruction(ID_EX_Instruction),
        .AluControl(AluControl),
        .AluSrcIn1(AluSrc1),
        .AluSrcIn2(AluSrc2),
        .AluSrc2Sel(AluSrc2Sel),
        .ALU(ALU) // output can be even bigger
    );

    pipe_hazard_detection_unit Hazard_Unit(
        .clk(clk),
        .IF_ID_Instruction (IF_ID_Instruction),
        .ID_EX_MemReadEn (ID_EX_MemReadEn),
        .EX_MEM_MemReadEn (EX_MEM_MemReadEn), // Stall in state MEM
        .EX_MEM_MemWriteEn (EX_MEM_MemWriteEn), // Stall in state MEM
        .EX_MEM_Rdest (EX_MEM_Rdest),
        .ID_EX_Rdest (ID_EX_Rdest),
        .MEM_WB_Rdest (MEM_WB_Rdest),
        .PCWrite (PCWrite),
        .IF_ID_Write (IF_ID_Write), // also the mux selector in ID
        .FetchMemSel (FetchMemSel), // if 1, select pc; if 0, select load/write data mem
        .IF_ID_valid (IF_ID_valid),
        .Is_JB_stall(Is_JB_stall)
    );

    pipe_RegWrite RW(
        .reset(reset),
        .clk(clk),
        .EX_MEM_ALU(ALU),
        .HiEn(HiEn),
        .LoEn(LoEn),
        .EX_MEM_RegWriteDataSel(EX_MEM_RegWriteDataSel),
        .ReadOutMem(ReadOutMem),
        .MEM_WB_RegWriteDataSel(MEM_WB_RegWriteDataSel),
        .RegPC(PC_to_Reg),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite)
    );

    pipe_PC_Link PC_L(
        .clk(clk),
        .IF_Reg_PC(IF_RegPC),
        .IF_ID_Write(IF_ID_Write),
        .Is_JB_stall(Is_JB_stall),
        .PC_to_Reg(PC_to_Reg)
    );

endmodule