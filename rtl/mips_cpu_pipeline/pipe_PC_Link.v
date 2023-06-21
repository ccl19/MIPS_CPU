module pipe_PC_Link (
    input logic clk,
    input logic [31:0] IF_Reg_PC,
    input logic Is_JB_stall,
    input logic IF_ID_Write,
    output logic [31:0] PC_to_Reg
);
    logic [31:0]IF_ID_RegPC, ID_EX_RegPC, EX_MEM_RegPC;
    assign PC_to_Reg = EX_MEM_RegPC;
    always @(posedge clk) begin
        // if(Is_JB_stall)begin
        //     IF_ID_RegPC <= IF_Reg_PC;
        //     ID_EX_RegPC <= IF_ID_RegPC;
        //     EX_MEM_RegPC <= ID_EX_RegPC;
        // end
        // else begin
        //     IF_ID_RegPC <= IF_Reg_PC;
        //     ID_EX_RegPC <= IF_ID_RegPC;
        //     EX_MEM_RegPC <= ID_EX_RegPC;
        // end
        if(IF_ID_Write)begin
            IF_ID_RegPC <= IF_Reg_PC; 
        end
        ID_EX_RegPC <= IF_ID_RegPC;
        EX_MEM_RegPC <= ID_EX_RegPC;
    end
endmodule