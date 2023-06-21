module regfile(
    // Clocking
    input logic clk,
    input logic reset,
    input logic[31:0] Instruction,
    input logic RegWriteEn,
    input logic RegReadEn,
    input logic HiEn,
    input logic LoEn,
    input logic [1:0] RegWriteDst,
    input logic [2:0] RegWriteDataSel,
    input logic [31:0] RegPC,
    input logic [31:0] ReadOutMem,
    input logic [63:0] ALU,
    input logic Verify,
    output logic[31:0] RegOutput1,
    output logic[31:0] RegOutput2,
    output logic[31:0] V0 
);
//BGEZAL BLTZAL JAL JALR
    logic[31:0] reg_file[31:0];
    logic[31:0] hi, lo;
    logic[4:0] read_reg_1, read_reg_2, read_reg_3;
    logic[4:0] write_reg_address;
    logic[31:0] write_data;
    logic[5:0] Opcode, Funccode;
    logic[31:0] read_out_1_prep, read_out_2_prep;
    logic[15:0] Immediate;
    integer index; 

    assign read_reg_1 = Instruction[25:21];
    assign read_reg_2 = Instruction[20:16];
    assign read_reg_3 = Instruction[15:11];
    assign Immediate = Instruction[15:0];
    assign Opcode = Instruction[31:26];
    assign Funccode = Instruction[5:0];
    
    
    assign V0 = reg_file[2];

    //READ
    assign read_out_1_prep = reg_file[read_reg_1];
    assign read_out_2_prep = reg_file[read_reg_2];
        
    //WRITE
    always_comb begin
        if(RegWriteDst==2'b00)begin
            write_reg_address = read_reg_2;
        end
        else if(RegWriteDst==2'b01) begin
            write_reg_address = read_reg_3;
        end
        else if(RegWriteDst == 2'b10) begin
            write_reg_address = 5'd31; //used for link instructions
        end
    end
    
    always @(*) begin
        if(RegWriteDataSel==3'b000)begin
            write_data = ALU[31:0];
        end
        else if (RegWriteDataSel==3'b001)begin
            write_data = ReadOutMem;
        end
        else if (RegWriteDataSel ==3'b010 )begin
            write_data = RegPC+8; //used for link
        end
        else if (RegWriteDataSel == 3'b011)begin
            //Move from Hi
            write_data = hi;
        end
        else if (RegWriteDataSel == 3'b100)begin
            //Move from Lo
            write_data = lo;
        end
    end

    
    // Read  
    always @(posedge clk)begin
        //read RS
        if(Verify)begin
            if(RegReadEn)begin
                RegOutput1 <= read_out_1_prep;
                RegOutput2 <= read_out_2_prep; 
            end
        end
        else begin
            RegOutput1 <= 0;
            RegOutput2 <= 0; 
        end
        
    end

    //Write Multi/Div hi 63:32 lo 31:0
    always @(posedge clk)begin
        if(HiEn && LoEn)begin
            hi <= ALU[63:32];
            lo <= write_data;
        end
        else if(HiEn && (!LoEn))begin
            //Move to high
            hi <= write_data;
        end
        else if(!HiEn && LoEn)begin
            //Move to Low
            lo <= write_data;
        end
    end

    always @(posedge clk) begin
        if (reset==1) begin
            for(index = 0; index < 32; index =index + 1) begin
                reg_file[index] <= 0;
            end
            lo <= 0;
            hi <= 0;
        end
        else if(RegWriteEn && (write_reg_address!=0) && Verify)begin
            reg_file[write_reg_address] <= write_data;
        end
    end
endmodule