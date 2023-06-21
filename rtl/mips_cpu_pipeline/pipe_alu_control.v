module pipe_alu_control (
    input logic[5:0] Opcode,
    input logic[5:0] Funccode,
    output logic[3:0] AluControl,
    output logic AluSrc2Sel
);
    
    
    always @(*) begin
        // ALUsrc 
        if(Opcode[5:3] ==3'b001 || Opcode[5]==1'b1 || (Opcode == 0 && Funccode[5:2] == 0))begin
            AluSrc2Sel = 1;
        end
        else begin
            AluSrc2Sel = 0;
        end
        // AluControl = 0000 (AND): ANDI AND
        if(Opcode == 6'b001100 || (Opcode == 6'b000000 && Funccode ==  6'b100100))begin 
            AluControl = 4'b0000;
        end
        //OR and ORI
        else if((Opcode == 0 && Funccode == 6'b100101) || Opcode == 6'b001101) begin
            AluControl = 4'b0001;
        end
        // AluControl = 0010 (Add unsigned): ADDIU ADDU LB LBU LH LHU LW LWL LWR SB SH SW
        else if(Opcode == 6'b001001 || (Opcode == 6'b000000 && Funccode ==  6'b100001)|| //ADDIU ADDU
                Opcode == 6'b100000 || Opcode == 6'b100100 || //LB LBU
                Opcode == 6'b100001 || Opcode == 6'b100101 || //LH LHU
                Opcode == 6'b100011 || Opcode == 6'b100010 || Opcode == 6'b100110 || // LW LWL LWR       
                Opcode == 6'b101000 || Opcode == 6'b101001 || Opcode == 6'b101011 || //SB SH SW   
                (Opcode == 6'b000000 && (Funccode == 6'b001000 || Funccode == 6'b001001) )|| // JR JALR
                (Opcode == 6'b000000 && (Funccode == 6'b010001 || Funccode == 6'b010011)))begin  //MTHI MTLO
            AluControl = 4'b0010;
        end
        // AluControl = 0011 (left shift): SLL SLLV
        else if(Opcode == 6'b000000 && (Funccode ==  6'b000000 || Funccode == 6'b000100))begin //SLL SLLV
            AluControl = 4'b0011;
        end
        //ALU_control = 0100 (set on less than unsigned): SLTIU SLTU
        else if (Opcode == 6'b001011 || (Opcode == 6'b000000 && Funccode==6'b101011))begin
            AluControl = 4'b0100;
        end
        //ALU_control = 0101 (shift right arithmetic): SRA SRAV
        else if (Opcode == 6'b000000 && (Funccode==6'b000011 || Funccode==6'b000111))begin
            AluControl = 4'b0101;
        end
        //ALU_control = 0110 (subtract unsigned) SUBU
        else if(Opcode == 6'b000000 && Funccode==6'b100011) begin
            AluControl = 4'b0110;
        end
        // SLT SLTI ALU_control = 0111
        else if((Opcode == 0 && Funccode == 6'b101010) || (Opcode == 6'b001010))begin
            AluControl = 4'b0111;
        end
        //  Divide ALU_control = 1000 
        else if(Opcode == 0 && Funccode == 6'b011010)begin
            AluControl = 4'b1000;
        end
        //  Divide Unsigned ALU_control = 1001 
        else if(Opcode == 0 && Funccode == 6'b011011)begin
            AluControl = 4'b1001;
        end  
        //  Multiply  ALU_control = 1010
        else if(Opcode == 0 && Funccode == 6'b011000)begin
            AluControl = 4'b1010;
        end
        // Multiply Unsigned ALU_control = 1011
        else if(Opcode == 0 && Funccode == 6'b011001)begin
            AluControl = 4'b1011;
        end
        // SRL SRLV ALU_control = 1100
        else if(Opcode == 0 && (Funccode == 6'b000010 || Funccode == 6'b000110))begin
            AluControl = 4'b1100;
        end
        // XOR XORI ALU_control = 1101
        else if((Opcode == 0 && Funccode == 6'b100110) || (Opcode == 6'b001110))begin
            AluControl = 4'b1101;
        end
        // ALU_control = 1110 (left shift by 16 bits): LUI
        else if(Opcode == 6'b001111) begin
            AluControl = 4'b1110;
        end
        //undefined
        else begin
            AluControl = 4'b1111;
        end
            
    end

endmodule