module alu (
    input logic clk,
    input logic AluRegEn,
    input logic[3:0] AluControl,
    input logic[31:0] RegOutput1,
    input logic[31:0] RegOutput2,
    input logic AluSrc2Sel,
    input logic BranchSel,
    input logic [31:0] Instruction,
    output logic[63:0] ALU, // output can be even bigger
    output logic Zero
);
    logic [31:0] Immediate;
    logic [5:0] Opcode;
    logic [5:0] Funccode;
    logic [31:0] SignedImmediate, UnsignedImmediate;
    logic signed [31:0] SignedAluSrc1;
    logic signed [31:0] SignedAluSrc2;
    logic [31:0] AluSrc1, AluSrc2;
    logic [63:0] Result;

    assign Opcode = Instruction[31:26];
    assign Funccode = Instruction[5:0];
    assign UnsignedImmediate = Instruction[15:0];
    assign SignedImmediate =  {{16{Instruction[15]}}, (Instruction[15:0])};
    assign Immediate = ((Opcode[5]==1) || (Opcode == 6'b001001)|| (Opcode == 6'b001010) || (Opcode == 6'b001011)) ? SignedImmediate : UnsignedImmediate; //immediate is signed for load store
    assign AluSrc2= (BranchSel == 1)? 0 : (AluSrc2Sel)? Immediate : RegOutput2;   
    assign AluSrc1 = (Opcode == 0 && Funccode[5:2] ==0)? RegOutput2 : RegOutput1; 
    assign SignedAluSrc1 = AluSrc1;
    assign SignedAluSrc2 = AluSrc2;

    always @(*) begin
        if (AluControl == 4'b0000) begin
            Result = AluSrc1 & AluSrc2; // AND 
        end
        
        else if (AluControl == 4'b0001) begin
            Result = AluSrc1 | AluSrc2; // OR and ORI
        end
        
        else if (AluControl == 4'b0010) begin
            Result = AluSrc1 + AluSrc2; //for the add and since the operation codes are the same for LW and SW
        end
        
        else if(AluControl == 4'b0011 )begin // SLL SLLV
            if(AluSrc2Sel == 0)begin
                //SLLV
                //read_out_1 = reg_output_1 = rs;
                //read_output_2 = reg_output_2 = rt;
                Result = AluSrc2 << AluSrc1;
            end
            else begin
                //SLL
                //read_out_1 = reg_output_2 = rt;
                //read_out_2 = immediate [10:6] = sa;
                Result = AluSrc1 << AluSrc2[10:6];
            end

        end
        else if(AluControl == 4'b0100) begin // SLTU SLTIU
            Result = (AluSrc1 < AluSrc2);
        end
        else if(AluControl == 4'b0101) begin // SRA SRAV
            if(AluSrc2Sel == 0)begin
                //SRAV
                Result[31:0] = SignedAluSrc2 >>> SignedAluSrc1;
            end
            else begin
                //SRA
                Result = SignedAluSrc1 >>> SignedAluSrc2[10:6];
            end
        end
        else if(AluControl == 4'b0110) begin // all Branch(BEQ BGEZ BGEZAL BGTZ BLEZ BLTZ BLTZAL BNE), SUBU
            Result = AluSrc1 - AluSrc2;
        end
        else if(AluControl == 4'b0111) begin // SLT SLTI
            Result = (SignedAluSrc1 < SignedAluSrc2);
        end
        else if(AluControl == 4'b1000) begin // divide signed
            Result[31:0] = SignedAluSrc1 / SignedAluSrc2;
            Result[63:32] = SignedAluSrc1 % SignedAluSrc2;
        end
        else if(AluControl == 4'b1001) begin // divide unsigned
            Result[31:0] = AluSrc1 / AluSrc2;
            Result[63:32] = AluSrc1 % AluSrc2;
        end
        
        else if(AluControl == 4'b1010) begin // multiply signed
            Result = SignedAluSrc1 * SignedAluSrc2;
        end
        
        else if(AluControl == 4'b1011) begin // multiply unsigned
            Result = AluSrc1 * AluSrc2;
        end
        
        else if(AluControl == 4'b1100) begin // shift right logical
            if(AluSrc2Sel == 0)begin //SRLV
                Result = AluSrc2 >> AluSrc1;
            end
            else begin //SRL
                Result = AluSrc1 >> AluSrc2[10:6];
            end
        end

        else if(AluControl == 4'b1101) begin // XOR
            Result = AluSrc1 ^ AluSrc2; 
        end
        else if(AluControl == 4'b1110) begin // LUI
            Result = AluSrc2 << 16; 
        end
        else if(AluControl == 4'b1111) begin // do nothing
            Result = 32'hxxxxxxxx;
        end
    end

    always @(*) begin
        Zero = (ALU == 0) ? 1:0;
    end

    always_ff @(posedge clk) begin
        if (AluRegEn==1)begin
            ALU <= Result;
        end
    end

endmodule

