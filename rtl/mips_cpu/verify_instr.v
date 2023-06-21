module verify_instr(
    input logic[31:0] Instruction,
    output logic Verify
); 
    logic [5:0] Opcode;
    logic [5:0] Funccode;
    logic [4:0] Rtcode;
    logic [5:0] Sacode;
    logic [4:0] Rscode;
    logic [9:0] RdSacode;
    logic [9:0] RsRtcode;
    logic [14:0] RtRdSacode;
    assign Opcode = Instruction[31:26];
    assign Funccode = Instruction[5:0];
    assign Rtcode = Instruction[20:16];
    assign Sacode = Instruction[10:6];
    assign Rscode = Instruction[25:21];
    assign RdSacode = Instruction[15:6];
    assign RsRtcode = Instruction[25:16];
    assign RtRdSacode = Instruction[20:6];
    always @(*) begin
        Verify = (((Opcode==0)&(((Funccode==6'b100001 || Funccode==6'b100100 || Funccode==6'b100111 || Funccode==6'b100101 || Funccode==6'b101010 || 
                                  Funccode==6'b101011 || Funccode==6'b100011 || Funccode==6'b100110 || Funccode==6'b000100 || Funccode==6'b000111 ||
                                  Funccode==6'b000110) & Sacode==0) ||
                               ((Funccode==6'b000000 || Funccode==6'b000011 ||  Funccode==6'b000010) & Rscode==0) || 
                               ((Funccode==6'b011010 || Funccode==6'b011011 || Funccode==6'b011000 || Funccode==6'b011001) & RdSacode==0) ||
                               ((Funccode==6'b010000 || Funccode==6'b010010) & RsRtcode==0 & Sacode==0) || 
                               ((Funccode==6'b010001 || Funccode==6'b010011) & RtRdSacode==0))) ||
                  Opcode==6'b001001 || Opcode==6'b001100 || ((Opcode==6'b001111) && (Rscode == 0)) || Opcode==6'b001010 || Opcode==6'b001011 || Opcode==6'b001110 ||
                  Opcode==6'b000100 || Opcode==6'b000101 || Opcode==6'b000010 || Opcode==6'b000011 || Opcode==6'b100000 || Opcode==6'b100100 ||
                  Opcode==6'b100001 || Opcode==6'b100101 || Opcode==6'b100011 || Opcode==6'b101000 || Opcode==6'b101001 || Opcode==6'b101011 ||
                  Opcode==6'b100010 || Opcode==6'b100110 || Opcode==6'b001101 ||
                  (Opcode==6'b000001 & (Rtcode==5'b00001 || Rtcode==5'b10001 || Rtcode==5'b00000 || Rtcode==5'b10000)) ||
                  ((Opcode==6'b000111 || Opcode==6'b000110) & Rtcode==5'b00000) ||
                  (Opcode==6'b000000 & Rtcode==0 & Sacode==0 & Funccode==6'b001001) ||
                  (Opcode==6'b000000 & RtRdSacode==0 & Funccode==6'b001000));
    end
endmodule