module RegWrite (
    input reset,
    input clk,
    input logic [63:0] EX_MEM_ALU,
    input logic HiEn,
    input logic LoEn,
    input logic [2:0] EX_MEM_RegWriteDataSel,
    input logic [31:0] ReadOutMem,
    input logic MEM_WB_RegWriteDataSel,
    input logic [31:0] RegPC,
    output logic [31:0] EX_MEM_RegWrite,
    output logic [31:0] MEM_WB_RegWrite
);
    logic [31:0] hi, lo;
    logic [31:0] tmp_MEM_WB_RegWrite;
    //Write Multi/Div hi 63:32 lo 31:0
    always @(posedge clk)begin
        if(reset)begin
            hi <= 0;
            lo <= 0;
        end
        else begin
            if(HiEn && LoEn)begin
                hi <= EX_MEM_ALU[63:32];
                lo <= EX_MEM_ALU[31:0];
            end
            else if(HiEn && (!LoEn))begin
                //Move to high
                hi <= EX_MEM_ALU[31:0];
            end
            else if(!HiEn && LoEn)begin
                //Move to Low
                lo <= EX_MEM_ALU[31:0];
            end
        end
    end
    always_ff @(posedge clk) begin
        tmp_MEM_WB_RegWrite <= EX_MEM_RegWrite;
    end
    always @(*) begin
        if(EX_MEM_RegWriteDataSel==3'b000)begin
            EX_MEM_RegWrite = EX_MEM_ALU[31:0];
        end
        else if (EX_MEM_RegWriteDataSel ==3'b010 )begin
                EX_MEM_RegWrite = RegPC + 8; //used for link      
        end
        else if (EX_MEM_RegWriteDataSel == 3'b011)begin
            //Move from Hi
            EX_MEM_RegWrite = hi;
        end
        else if (EX_MEM_RegWriteDataSel == 3'b100)begin
            //Move from Lo
            EX_MEM_RegWrite = lo;
        end
        else begin
            EX_MEM_RegWrite = 0;
        end

        if (MEM_WB_RegWriteDataSel == 1)begin
            MEM_WB_RegWrite = ReadOutMem;
        end
        else begin
            MEM_WB_RegWrite = tmp_MEM_WB_RegWrite;
        end
    end
endmodule