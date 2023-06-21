module pipe_control_register (
    input IF_ID_valid,
    input logic clk,
    input logic [31:0] IF_ID_Instruction,
    input logic[31:0] RegOutput1, //Rs
    input logic[31:0] RegOutput2, //Rt
    input logic [31:0] EX_MEM_RegWrite,
    input logic [31:0] MEM_WB_RegWrite,
    input logic reset,
    input logic reg_active3,
    output logic ID_EX_MemReadEn,
    output logic EX_MEM_MemReadEn,
    output logic EX_MEM_MemWriteEn,
    output logic [1:0] MEM_WB_RegWriteDst,
    // RegWriteDst = 0, inst[20:16]; RegWriteDst = 1, inst[15-11]; RegWriteDst = 2 write to $31
    output logic [2:0] EX_MEM_RegWriteDataSel,
    output logic MEM_WB_RegWriteDataSel,
    output logic[3:0] AluControl,
    output logic MemReadEn,
    output logic MemWriteEn,
    output logic MEM_WB_RegWriteEn,
    output logic RegReadEn,
    output logic AluSrc2Sel,
    output logic HiEn,
    output logic LoEn,
    output logic AluRegEn,
    output logic [31:0] AluSrc1,
    output logic [31:0] AluSrc2,
    output logic [4:0] ID_EX_Rdest, 
    output logic [4:0] EX_MEM_Rdest,
    output logic [4:0] MEM_WB_Rdest
);
    
    //instruction Opcode Funccode
    logic [5:0] ID_Opcode, EX_Opcode, MEM_Opcode, WB_Opcode, ID_EX_Opcode, ID_EX_Funccode;
    logic [5:0] ID_Funccode, EX_Funccode, MEM_Funccode, WB_Funccode;
    logic [4:0] MEM_Branchcode, WB_Branchcode, ID_EX_Branchcode;
    logic [31:0] ID_EX_Instruction, EX_MEM_Instruction, MEM_WB_Instruction, ID_EX_InstructionNext;

    // ID_EX
    logic [4:0] ID_EX_Rd, ID_EX_Rt, ID_EX_Rs, IF_ID_Rs, IF_ID_Rt;
    logic ID_EX_MemWriteEN, EX_MEM_RegWriteEn;
    
    logic [1:0] Forward_A, Forward_B;
    logic ID_EX_valid, EX_MEM_valid, MEM_WB_valid;
    
    assign ID_EX_Rd = ID_EX_Instruction[15:11];
    assign ID_EX_Rt = ID_EX_Instruction [20:16];
    assign ID_EX_Rs = ID_EX_Instruction [25:21];
    assign IF_ID_Rs = IF_ID_Instruction [25:21];
    assign ID_Opcode = IF_ID_Instruction[31:26];
    assign ID_Funccode = IF_ID_Instruction[5:0];
    assign WB_Branchcode = MEM_WB_Instruction[20:16];
    assign MEM_Branchcode = EX_MEM_Instruction[20:16];
    assign ID_EX_Branchcode = ID_EX_Instruction[20:16];
    assign ID_EX_Opcode = ID_EX_Instruction[31:26];
    assign ID_EX_Funccode = ID_EX_Instruction[5:0];

    always @(posedge clk) begin
        ID_EX_Instruction <= ID_EX_InstructionNext;
        EX_MEM_Instruction <= ID_EX_Instruction;
        MEM_WB_Instruction <= EX_MEM_Instruction;    
        EX_MEM_Rdest <= ID_EX_Rdest;
        MEM_WB_Rdest <= EX_MEM_Rdest;
        EX_MEM_MemReadEn <= ID_EX_MemReadEn;
        EX_MEM_MemWriteEn <= ID_EX_MemWriteEN;
        EX_Opcode <= ID_Opcode;
        EX_Funccode <= ID_Funccode;
        MEM_Opcode <= EX_Opcode;
        MEM_Funccode <= EX_Funccode;
        WB_Opcode <= MEM_Opcode;
        WB_Funccode <= MEM_Funccode;
        ID_EX_valid <= IF_ID_valid;
        EX_MEM_valid <= ID_EX_valid;
        MEM_WB_valid <= EX_MEM_valid;
    end

    always @(*) begin
        if(IF_ID_valid==0)begin
            ID_EX_InstructionNext = 32'hxxxxxxxx;
        end
        else begin
            ID_EX_InstructionNext = IF_ID_Instruction;
        end
    end
    //SIGNALS USED FOR OUTPUT
    //assign ID_EX_Rdest = (ID_EX_Instruction[31:26]==6'b000000)? ID_EX_Rd : ID_EX_Rt;
    assign ID_EX_MemReadEn = (ID_EX_Instruction[31:29]==3'b100)? 1 : 0;
    assign ID_EX_MemWriteEN = (ID_EX_Instruction[31:29]==3'b101)? 1 : 0;

    always @(*) begin
        if (ID_EX_Opcode==6'b000000 && ID_EX_Funccode != 6'b001000) begin
            ID_EX_Rdest = ID_EX_Rd;
        end
        else if (ID_EX_Opcode == 6'b000100 || (ID_EX_Opcode == 6'b000001 && ID_EX_Branchcode == 5'b00001)|| ID_EX_Opcode == 6'b000111 || ID_EX_Opcode == 6'b000110
                || (ID_EX_Opcode == 6'b000001 && ID_EX_Branchcode == 5'b00000) || ID_EX_Opcode == 6'b000101 || ID_EX_Opcode == 6'b000010 || (ID_EX_Opcode == 6'b000000 && ID_EX_Funccode == 6'b001000)) begin
            ID_EX_Rdest = ID_EX_Rt;
        end
        else if((ID_EX_Opcode == 6'b000001 && ID_EX_Branchcode == 5'b10001) || (ID_EX_Opcode == 6'b000011))begin
            ID_EX_Rdest = 5'b11111;
        end
        else begin
            ID_EX_Rdest = ID_EX_Rt;
        end
    end
    
    //SIGNALS USED FOR BLOCKS DIRECTLY
    //MemReadEn always 1 except STORE

    //RegReadEn always 1
    assign RegReadEn = 1;
    assign AluRegEn = (ID_EX_valid)? 1 : 0; 
    assign MemWriteEn = (EX_MEM_Instruction[31:29]==3'b101)? 1 : 0;
    always @(*) begin
        if (reset) begin
            MemReadEn = 1;
        end
        else if (EX_MEM_Instruction[31:29]==3'b101)begin
            MemReadEn = 0;
        end
        else begin
            MemReadEn = 1;
        end
    end
    //MEM
    always @(*) begin
        if(EX_MEM_valid) begin
            if(MEM_Opcode[5:3] == 3'b100)begin
                EX_MEM_RegWriteEn = 1;
                EX_MEM_RegWriteDataSel = 1;
            end
            else if (MEM_Opcode == 6'b000000 && (MEM_Funccode == 6'b100001 || MEM_Funccode == 6'b100100 || // ADDU AND
                                            MEM_Funccode == 6'b100101 || MEM_Funccode == 6'b101010 || // OR SLT
                                            MEM_Funccode == 6'b101011 || MEM_Funccode == 6'b100011 || //SLTU SUBU
                                            MEM_Funccode == 6'b100110 || // XOR 
                                            MEM_Funccode[5:3] == 3'b000))begin // all shift Instructions
                EX_MEM_RegWriteEn = 1;
                EX_MEM_RegWriteDataSel = 0;
            end
            else if (MEM_Opcode[5:3] == 3'b 001)begin
                EX_MEM_RegWriteEn = 1;
                EX_MEM_RegWriteDataSel = 0;
            end
            //MFHI 
            else if(MEM_Opcode == 0 && MEM_Funccode == 6'b010000)begin
                EX_MEM_RegWriteEn = 1;
                EX_MEM_RegWriteDataSel = 3;
            end
            //MFLO
            else if(MEM_Opcode == 0 && MEM_Funccode == 6'b010010)begin
                EX_MEM_RegWriteEn = 1;
                EX_MEM_RegWriteDataSel = 4;
            end
            else if(MEM_Opcode == 6'b000011 || (MEM_Opcode == 6'b000001 && (MEM_Branchcode==5'b10001||MEM_Branchcode==5'b10000)))begin
                EX_MEM_RegWriteEn = 1;
                EX_MEM_RegWriteDataSel = 2;
                
            end
            else if(MEM_Opcode==6'b000000 && MEM_Funccode==6'b001001)begin
                EX_MEM_RegWriteEn = 1;
                EX_MEM_RegWriteDataSel = 2;
            end
            else begin
                EX_MEM_RegWriteEn = 0;
                EX_MEM_RegWriteDataSel = 0;
            end

            //MUL MULU DIV DIVU Hi&LoEn
            if (MEM_Opcode == 6'b000000 && (MEM_Funccode == 6'b011000 || MEM_Funccode == 6'b011001 || MEM_Funccode == 6'b011010 || MEM_Funccode == 6'b011011))begin 
                LoEn = 1;
                HiEn = 1;
            end
            //Move to High HiEn
            else if(MEM_Opcode == 6'b000000 && MEM_Funccode == 6'b010001)begin // MTHI
                LoEn = 0;
                HiEn = 1;
            end
            //Move to Low LoEn
            else if(MEM_Opcode == 6'b000000 && MEM_Funccode == 6'b010011)begin // MTLO
                LoEn = 1;
                HiEn = 0;
            end
            else begin
                LoEn = 0;
                HiEn = 0;
            end
        end
        else begin
            LoEn = 0;
            HiEn = 0;
            EX_MEM_RegWriteEn = 0;
        end
    end


    //WB
    always @(*) begin
        //all Load, write to reg file
        if(reg_active3 != 0)begin
            if(MEM_WB_valid)begin
                if(WB_Opcode[5:3] == 3'b100)begin
                    MEM_WB_RegWriteDataSel = 1;
                    MEM_WB_RegWriteEn = 1;
                    MEM_WB_RegWriteDst = 0;
                end

                //Arithmetic R & shift
                else if (WB_Opcode == 6'b000000 && (WB_Funccode == 6'b100001 || WB_Funccode == 6'b100100 || // ADDU AND
                                                WB_Funccode == 6'b100101 || WB_Funccode == 6'b101010 || // OR SLT
                                                WB_Funccode == 6'b101011 || WB_Funccode == 6'b100011 || //SLTU SUBU
                                                WB_Funccode == 6'b100110 || // XOR 
                                                WB_Funccode[5:3] == 3'b000))begin // all shift Instructions
                    MEM_WB_RegWriteDataSel = 0;
                    MEM_WB_RegWriteEn = 1;
                    MEM_WB_RegWriteDst = 1;
                end
                //Arithmetic I
                else if (WB_Opcode[5:3] == 3'b 001)begin
                    MEM_WB_RegWriteDataSel = 0;
                    MEM_WB_RegWriteEn = 1;
                    MEM_WB_RegWriteDst = 0;
                end
                //MFHI 
                else if(WB_Opcode == 0 && WB_Funccode == 6'b010000)begin
                    MEM_WB_RegWriteDataSel = 0;
                    MEM_WB_RegWriteEn = 1;
                    MEM_WB_RegWriteDst = 1;
                    //RegWriteDst= 1 is because it select the rd val 
                end
                //MFLO
                else if(WB_Opcode == 0 && WB_Funccode == 6'b010010)begin
                    MEM_WB_RegWriteDataSel = 0;
                    MEM_WB_RegWriteEn = 1;
                    MEM_WB_RegWriteDst = 1;
                    //same as MFHI
                end
                //here is the part originally in state 4 put the data into register in MEM part. 
                // RegWriteEn: if Branch/Jump with link (JAL, BGETAL, BLTZAL, JALR), RegWriteEn=1; else RegWriteEn=0
                // RegWriteDst: if JAL, BGETAL, BLTZAL, RegWriteDst=2 ($31); if JALR RegWriteDst=1($rd) not clear
                else if(WB_Opcode == 6'b000011 || (WB_Opcode == 6'b000001 && (WB_Branchcode==5'b10001||WB_Branchcode==5'b10000)))begin
                    MEM_WB_RegWriteEn = 1;
                    MEM_WB_RegWriteDst = 2;
                    MEM_WB_RegWriteDataSel = 0;
                end
                else if(WB_Opcode==6'b000000 && WB_Funccode==6'b001001)begin
                    //JALR
                    MEM_WB_RegWriteEn = 1;
                    MEM_WB_RegWriteDst = 1;
                    MEM_WB_RegWriteDataSel = 0;
                end
                else begin
                    MEM_WB_RegWriteEn = 0;
                    MEM_WB_RegWriteDataSel = 0;
                end
            end
            else begin
                MEM_WB_RegWriteEn = 0;
            end
        end
        else begin
            MEM_WB_RegWriteEn = 0;
        end
    end




    //MUX used to select 
    always @(*) begin
        if(Forward_A == 0)begin
            AluSrc1 = RegOutput1;
        end
        else if(Forward_A == 2'b01)begin
            AluSrc1 = MEM_WB_RegWrite;
        end
        else if(Forward_A == 2'b10)begin
            AluSrc1 = EX_MEM_RegWrite;
        end
        else begin
            AluSrc1 = 0;
        end
        
        if(Forward_B == 0)begin
            AluSrc2 = RegOutput2;
        end
        else if(Forward_B == 2'b01)begin
            AluSrc2 = MEM_WB_RegWrite;
        end
        else if(Forward_B == 2'b10)begin
            AluSrc2 = EX_MEM_RegWrite;
        end
        else begin
            AluSrc2 = 0;
        end
    end

    pipe_alu_control alu_con(
        .Opcode(EX_Opcode),
        .Funccode(EX_Funccode),
        .AluControl(AluControl),
        .AluSrc2Sel(AluSrc2Sel)
    );
    pipe_forwarding_unit Forward_U (
        .ID_EX_Rs(ID_EX_Rs),
        .ID_EX_Rt(ID_EX_Rt),
        .EX_MEM_Rdest(EX_MEM_Rdest),
        .MEM_WB_Rdest(MEM_WB_Rdest),
        .EX_MEM_RegWrite(EX_MEM_RegWriteEn),
        .MEM_WB_RegWrite(MEM_WB_RegWriteEn),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B)
    );
    

endmodule