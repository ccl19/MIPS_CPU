//Control + ALU control
module control (
    input logic[31:0] Instruction,
    input logic[2:0] State,
    input Verify,
    output logic [1:0]RegWriteDst,
    // RegWriteDst = 0, inst[20:16]; RegWriteDst = 1, inst[15-11]; RegWriteDst = 2 write to $31
    output logic [2:0] RegWriteDataSel,
    // RegWriteDataSel = 0, reg input = ALU out; RegWriteDataSel = 1, reg input = mem out; RegWriteDataSel = 2, PC output connect;
    // RegWriteDataSel = 3, reg input = Hi; RegWriteDataSel = 4, reg input = Lo
    output logic[3:0] AluControl,
    output logic MemReadEn,
    output logic MemWriteEn,
    output logic RegWriteEn,
    output logic RegReadEn,
    output logic AluSrc2Sel,
    output logic HiEn,
    output logic LoEn,
    output logic BranchSel,
    output logic AluRegEn
    //as defined by the control bus
);
    logic[5:0] Opcode;
    logic[5:0] Funccode;
    logic[4:0] Branchcode;
    assign Opcode = Instruction[31:26];
    assign Funccode = Instruction[5:0];
    assign Branchcode = Instruction[20:16];
    
    //State 1
    always @(*) begin
        if(State == 1)begin
            MemReadEn = 1;
            MemWriteEn = 0;
            RegWriteEn = 0;
            RegReadEn = 0;
            HiEn = 0;
            LoEn = 0;
            RegWriteDataSel = 0;
            AluRegEn = 0;
        end
    end

    //State 2
    always @(*) begin
        if(State==2 && Verify) begin
            MemReadEn = 0;
            MemWriteEn = 0;
            RegWriteEn = 0;
            RegReadEn = 1;
            HiEn = 0;
            LoEn = 0;
            AluRegEn = 0;
        end
    end

    
    //State 3 ALU
    always @(*) begin
        if(State == 3 && Verify)begin
            MemReadEn = 0;
            MemWriteEn = 0;
            RegWriteEn = 0;
            RegReadEn = 0;
            HiEn = 0;
            LoEn = 0;
            AluRegEn = 1;
        end
    end

    //State 4
    always @(*) begin
        if(State == 4 && Verify )begin
            MemWriteEn = 0;
            RegReadEn = 0;
            LoEn = 0;
            HiEn = 0;
            AluRegEn = 0;
            //MemReadEn: if Load, MemReadEn = 1; or MemReadEn = 0
            if(Opcode[5:3] == 3'b100)begin
                MemReadEn = 1;
            end
            else begin
                MemReadEn = 0;
            end
            
            //MemWriteEn: if Store, MemWriteEn = 1; or MemWriteEn = 0
            if(Opcode[5:3] == 3'b101)begin
                MemWriteEn = 1;
            end
            else begin
                MemWriteEn = 0;
            end

            //RegWriteEn: if Branch/Jump with link (JAL, BGETAL, BLTZAL, JALR), RegWriteEn=1; else RegWriteEn=0
            //RegWriteDst: if JAL, BGETAL, BLTZAL, RegWriteDst=2 ($31); if JALR RegWriteDst=1($rd) not clear
            if(Opcode == 6'b000011 || (Opcode == 6'b000001 && (Branchcode==5'b10001||Branchcode==5'b10000)))begin
                RegWriteEn = 1;
                RegWriteDst = 2;
                RegWriteDataSel = 2;
            end
            else if(Opcode==6'b000000 && Funccode==6'b001001)begin
                RegWriteEn = 1;
                RegWriteDst = 1;
                RegWriteDataSel = 2;
            end
            else begin
                RegWriteEn = 0;
            end
            
        end
    end

    //State 5
    always @(*) begin
        if(State == 5 && Verify)begin
            MemReadEn = 0;
            RegReadEn = 0;
            AluRegEn = 0;
            MemWriteEn = 0;
            //all Load, write to reg file
            if(Opcode[5:3] == 3'b100)begin
                RegWriteDataSel = 1;
                RegWriteEn = 1;
                RegWriteDst = 0;
            end

            //Arithmetic R & shift
            else if (Opcode == 6'b000000 && (Funccode == 6'b100001 || Funccode == 6'b100100 || // ADDU AND
                                            Funccode == 6'b100101 || Funccode == 6'b101010 || // OR SLT
                                            Funccode == 6'b101011 || Funccode == 6'b100011 || //SLTU SUBU
                                            Funccode == 6'b100110 || // XOR 
                                            Funccode[5:3] == 3'b000))begin // all shift Instructions
                RegWriteDataSel = 0;
                RegWriteEn = 1;
                RegWriteDst = 1;
            end
            //Arithmetic I
            else if (Opcode[5:3] == 3'b 001)begin
                RegWriteDataSel = 0;
                RegWriteEn = 1;
                RegWriteDst = 0;
            end
            //MFHI 
            else if(Opcode == 0 && Funccode == 6'b010000)begin
                RegWriteDataSel = 3;
                RegWriteEn = 1;
                RegWriteDst = 1;
                //RegWriteDst= 1 is because it select the rd val 
            end
            //MFLO
            else if(Opcode == 0 && Funccode == 6'b010010)begin
                RegWriteDataSel = 4;
                RegWriteEn = 1;
                RegWriteDst = 1;
                //same as MFHI
            end
            
            //MUL MULU DIV DIVU Hi&LoEn
            if (Opcode == 6'b000000 && (Funccode == 6'b011000 || Funccode == 6'b011001 || Funccode == 6'b011010 || Funccode == 6'b011011))begin 
                LoEn = 1;
                HiEn = 1;
            end
            //Move to High HiEn
            else if(Opcode == 6'b000000 && Funccode == 6'b010001)begin // MTHI
                LoEn = 0;
                HiEn = 1;
            end
            //Move to Low LoEn
            else if(Opcode == 6'b000000 && Funccode == 6'b010011)begin // MTLO
                LoEn = 1;
                HiEn = 0;
            end
            else begin
                LoEn = 0;
                HiEn = 0;
            end
        end
    end

    always @(*) begin
        // BGEZ BGEZAL BGTZ BLEZ BLTZ BLTZAL
        if (Opcode == 6'b000001  ||  Opcode == 6'b000111 || Opcode == 6'b000110)begin
            BranchSel = 1;
        end
        else begin
            BranchSel = 0;
        end
    end


    alu_control alu_con(
        .State(State),
        .Opcode(Opcode),
        .Funccode(Funccode),
        .AluControl(AluControl),
        .AluSrc2Sel(AluSrc2Sel)
    );
endmodule
