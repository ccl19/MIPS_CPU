module mem_interface (
    input clk,
    input logic[31:0] MemOut,
    input logic[31:0] EX_MEM_Instruction,
    input logic[31:0] MEM_WB_Instruction,
    input logic [63:0] ALU,
    input logic [31:0] RegOutput2,
    input logic FetchMemSel,
    //RT
    output logic [31:0] ReadOutMem,//what is loaded from mem after organization
    output logic [31:0] WriteInMem, //what is going to be stored in memory
    output logic [3:0] ByteEnable,
    output logic [31:0] MemAddressOut
);
//LB LBU LH LHU LW SB SH SW LWL LWR
    logic[5:0] EX_MEM_Opcode, MEM_WB_Opcode;
    logic[7:0] bytes[3:0];
    //store the byte want to store
    logic[31:0] alu_out;
    logic[31:0] mem_address;
    logic FetchMemSelNext;
    logic [3:0] MEM_WB_ByteEnable;
    logic [31:0] RegOutput2Next, RegOutput2NextNext;
    integer g_l, h, i, index;
    assign EX_MEM_Opcode = EX_MEM_Instruction[31:26];
    assign MEM_WB_Opcode = MEM_WB_Instruction[31:26];
    assign mem_address = alu_out; //the address of memory that we are going to store into/load from
    assign MemAddressOut = mem_address - mem_address%4;
    assign alu_out = ALU[31:0];
   
//little endian
    always @(*) begin
        if(FetchMemSel==0)begin
            if (EX_MEM_Opcode==6'b100000 || EX_MEM_Opcode == 6'b100100 || EX_MEM_Opcode == 6'b101000) begin //LB LBU SB
                for (i = 0; i < 4; i = i + 1)begin
                    if(i == mem_address % 4) begin  //mem_address=offset+rs
                        ByteEnable[i] = 1;
                    end
                    else begin
                        ByteEnable[i] = 0;
                    end
                end
            end
            else if (EX_MEM_Opcode == 6'b100001 || EX_MEM_Opcode == 6'b100101 || EX_MEM_Opcode == 6'b101001) begin //LHU LH SH
                if((mem_address % 4) == 2)begin
                    ByteEnable = 4'b1100;
                end
                else if((mem_address % 4) == 0)begin
                    ByteEnable = 4'b0011;
                end
                else begin
                    ByteEnable = 4'b0000;
                end
            end
            else if (EX_MEM_Opcode == 6'b100011 || EX_MEM_Opcode == 6'b101011) begin //LW SW
                if ((mem_address %4) == 0)begin
                    ByteEnable = 4'b1111;
                end
                else begin
                    ByteEnable = 4'b0000;
                end
            end
            else if (EX_MEM_Opcode == 6'b100010)begin//LWL 
                for (i=0; i<4; i++)begin
                    if(i<mem_address%4)begin
                        ByteEnable[i]=0;
                    end
                    else begin
                        ByteEnable[i] = 1;
                    end
                end
                
                // ByteEnable[3:mem_address%4] = 2**(4-mem_address%4) - 1; //produce 1/11/111/1111
                // ByteEnable[(mem_address%4)-1:0] = 0;
            end
            else if (EX_MEM_Opcode == 6'b100110)begin //LWR
                for (i=0; i<4; i++)begin
                    if(i>mem_address%4)begin
                        ByteEnable[i]=0;
                    end
                    else begin
                        ByteEnable[i] = 1;
                    end
                end
            end
            else begin
                ByteEnable = 4'b0000; 
            end
        end
        //when PC
        else begin
            ByteEnable=4'b1111;
        end
    end
    
    always @(posedge clk) begin
        FetchMemSelNext <= FetchMemSel;
        MEM_WB_ByteEnable <= ByteEnable;
        RegOutput2Next <= RegOutput2;
        RegOutput2NextNext <= RegOutput2Next;
    end
// used to reorganize the output.
// LOAD
    always @(*) begin
        if (FetchMemSelNext==1) begin
            ReadOutMem = {MemOut[7:0],MemOut[15:8],MemOut[23:16],MemOut[31:24]};
        end
        //Load
        else if ((FetchMemSelNext == 0) && (MEM_WB_Opcode[5:3]==3'b100)) begin
            // LWL
            if (MEM_WB_Opcode == 6'b100010)begin 
                g_l = 0;
                for (index = 0; index < 4; index = index + 1)begin
                    if(MEM_WB_ByteEnable[index] != 0)begin
                        bytes[3-g_l] = MemOut[index*8 +:8]; //indexed part selected
                        g_l = g_l + 1;
                    end
                    else begin
                        bytes[index] = RegOutput2NextNext[index*8 +:8];
                    end
                end 
                ReadOutMem = {bytes[3], bytes[2], bytes[1], bytes[0]};
            end
            //LWR
            else if (MEM_WB_Opcode == 6'b100110)begin 
                g_l = 0;
                for (index = 3; index >= 0; index = index - 1)begin
                    if(MEM_WB_ByteEnable[index] != 0)begin
                        bytes[index] = MemOut[g_l*8 +:8]; //indexed part selected
                        g_l += 1;
                    end
                    else begin
                        bytes[index] = RegOutput2NextNext[index*8 +:8];
                    end
                end
                ReadOutMem = {bytes[3], bytes[2], bytes[1], bytes[0]};
            end

            //all other load Instructions
            else begin 
                g_l = 0;
                for (index = 3; index >= 0; index = index - 1)begin
                    if(MEM_WB_ByteEnable[index] != 0)begin
                        bytes[3 - g_l] = MemOut[(index)*8 +:8];
                        g_l = g_l+1; 
                    end
                end
                if( (MEM_WB_Opcode == 6'b100000 || MEM_WB_Opcode == 6'b100001) && bytes[4-g_l][7]==1 )begin // LB LH 
                    //when signed load LB & LH and the MSB of byte is 1
                    for (h = 3-g_l; h >=0 ; h = h - 1)begin 
                        bytes[h] = 8'b11111111;
                    end
                    
                end
                else begin //LBU LHU
                    
                    for (h = 3-g_l; h >= 0; h = h - 1)begin 
                        bytes[h] = 8'b00000000;
                    end
                end

                ReadOutMem = {bytes[0], bytes[1], bytes[2], bytes[3]};
                
            end
        end
        else begin
            ReadOutMem = 32'hxxxxxxxx;
        end
    end

    //To Store certain val into the byte position, need to retrieve the value from the memory first  and change the content
    //and store back.
    // at State 4 retrieve the value store the output into the tmp_str_mem
    
    //STORE
    always @(*) begin
        if((FetchMemSel == 0) && (EX_MEM_Opcode[5:3] == 3'b101)) begin 
            //convert from 
            g_l = 0;
            for (index=3;index>=0;index=index - 1)begin
                if(ByteEnable[index]!=0) begin
                    bytes[index] = RegOutput2Next[g_l*8 +:8];
                    g_l = g_l + 1;
                end
                else begin
                    bytes[index] = 8'hxx;
                end
            end
            WriteInMem = {bytes[3], bytes[2], bytes[1], bytes[0]}; 
        end
        else begin          
            WriteInMem = 32'hxxxxxxxx;
        end
    end
        
endmodule
