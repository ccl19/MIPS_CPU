module pipe_regfile(
    // Clocking
    input logic clk,
    input logic reset,
    input logic[31:0] IF_ID_Instruction,
    input logic[31:0] MEM_WB_Instruction,
    input logic RegWriteEn,
    input logic RegReadEn,
    input logic [31:0] MEM_WB_RegWrite,
    input logic [1:0] MEM_WB_RegWriteDst,
    output logic[31:0] RegOutput1,
    output logic[31:0] RegOutput1Imm,
    output logic[31:0] RegOutput2,
    output logic[31:0] RegOutput2Imm,
    output logic[31:0] V0
);
//BGEZAL BLTZAL JAL JALR
    logic[31:0] reg_file[31:0];
    logic[4:0] IF_ID_read_reg_1, IF_ID_read_reg_2, MEM_WB_read_reg_2, MEM_WB_read_reg_3;
    logic[4:0] write_reg_address;
    logic[31:0] write_data;
    logic [31:0] RegData1, RegData2;
    integer index; 

    assign IF_ID_read_reg_1 = IF_ID_Instruction[25:21];
    assign IF_ID_read_reg_2 = IF_ID_Instruction[20:16];
    assign MEM_WB_read_reg_2 = MEM_WB_Instruction[20:16];
    assign MEM_WB_read_reg_3 = MEM_WB_Instruction[15:11];
    
    
    assign V0 = reg_file[2];

    //READ
    assign RegData1 = reg_file[IF_ID_read_reg_1];
    assign RegData2 = reg_file[IF_ID_read_reg_2];
        
    //WRITE
    always_comb begin
        if(MEM_WB_RegWriteDst==2'b00)begin
            //rt
            write_reg_address = MEM_WB_read_reg_2;
        end
        else if(MEM_WB_RegWriteDst==2'b01) begin
            //rd
            write_reg_address = MEM_WB_read_reg_3;
        end
        else if(MEM_WB_RegWriteDst == 2'b10) begin
            write_reg_address = 5'd31; //used for link instructions
        end
    end
    
    // Read  
    always @(posedge clk)begin
        //read RS
        if(RegReadEn)begin
            RegOutput1 <= RegData1;
            RegOutput2 <= RegData2; 
        end
        else begin
            RegOutput1 <= 0;
            RegOutput2 <= 0; 
        end
        
    end
    assign RegOutput2Imm = RegData2;
    assign RegOutput1Imm = RegData1;
    always @(posedge clk) begin
        if (reset==1) begin
            for(index = 0; index < 32; index =index + 1) begin
                reg_file[index] <= 0;
            end
        end
        else if(RegWriteEn && (write_reg_address!=0))begin
            reg_file[write_reg_address] <= MEM_WB_RegWrite;
        end
    end
endmodule