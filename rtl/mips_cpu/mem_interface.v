module mem_interface (
    input logic[31:0] MemOut,
    input logic[31:0] Instruction,
    input logic [63:0] ALU,
    input logic [2:0] State,
    input logic [31:0] RegOutput2,
    input logic Verify,
    //RT
    output logic [31:0] ReadOutMem,//what is loaded from mem after organization
    output logic [31:0] WriteInMem, //what is going to be stored in memory
    output logic [3:0] ByteEnable,
    output logic [31:0] MemAddressOut
);
//LB LBU LH LHU LW SB SH SW LWL LWR
    logic[5:0] Opcode;
    logic[7:0] bytes[3:0];
    //store the byte want to store
    logic[31:0] alu_out;
    logic[31:0] mem_address;
    integer g_l, h, i, index;
    assign Opcode = Instruction[31:26];
    assign mem_address = alu_out; //the address of memory that we are going to store into/load from
    assign MemAddressOut = mem_address - mem_address%4;
    assign alu_out = ALU[31:0];
//little endian
    always @(*) begin
        if (State==1)begin
            ByteEnable=4'hF;
        end
        else if(State == 4 || State == 5)begin
            if (Opcode==6'b100000 || Opcode == 6'b100100 || Opcode == 6'b101000) begin //LB LBU SB
                for (i = 0; i < 4; i = i + 1)begin
                    if(i == mem_address % 4) begin  //mem_address=offset+rs
                        ByteEnable[i] = 1;
                    end
                    else begin
                        ByteEnable[i] = 0;
                    end
                end
            end
            else if (Opcode == 6'b100001 || Opcode == 6'b100101 || Opcode == 6'b101001) begin //LHU LH SH
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
            else if (Opcode == 6'b100011 || Opcode == 6'b101011) begin //LW SW
                if ((mem_address %4) == 0)begin
                    ByteEnable = 4'b1111;
                end
                else begin
                    ByteEnable = 4'b0000;
                end
            end
            else if (Opcode == 6'b100010)begin//LWL 
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
            else if (Opcode == 6'b100110)begin //LWR
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
        else begin
            ByteEnable = 4'b0000;
        end

    end
    
// used to reorganize the output.
// LOAD
    always @(*) begin
        if (State==2) begin
            ReadOutMem = {MemOut[7:0],MemOut[15:8],MemOut[23:16],MemOut[31:24]};
        end
        //Load
        else if (State==5 && (Opcode[5:3]==3'b100) && Verify == 1) begin
            // LWL
            if (Opcode == 6'b100010)begin 
                g_l = 0;
                for (index = 0; index < 4; index = index + 1)begin
                    if(ByteEnable[index] != 0)begin
                        bytes[3-g_l] = MemOut[index*8 +:8]; //indexed part selected
                        g_l = g_l + 1;
                    end
                    else begin
                        bytes[index] = RegOutput2[index*8 +:8];
                    end
                end 
                ReadOutMem = {bytes[3], bytes[2], bytes[1], bytes[0]};
            end
            //LWR
            else if (Opcode == 6'b100110)begin 
                g_l = 0;
                for (index = 3; index >= 0; index = index - 1)begin
                    if(ByteEnable[index] != 0)begin
                        bytes[index] = MemOut[g_l*8 +:8]; //indexed part selected
                        g_l += 1;
                    end
                    else begin
                        bytes[index] = RegOutput2[index*8 +:8];
                    end
                end
                ReadOutMem = {bytes[3], bytes[2], bytes[1], bytes[0]};
            end

            //all other load Instructions
            else begin 
                g_l = 0;
                for (index = 3; index >= 0; index = index - 1)begin
                    if(ByteEnable[index] != 0)begin
                        bytes[3 - g_l] = MemOut[(index)*8 +:8];
                        g_l = g_l+1; 
                    end
                end
                if( (Opcode == 6'b100000 || Opcode == 6'b100001) && bytes[4-g_l][7]==1 )begin // LB LH 
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

    //To Store certain val into the byte position, need to retrieve the value from the memory first  and change the content
    //and store back.
    // at State 4 retrieve the value store the output into the tmp_str_mem
    
        //STORE

        else if(State==4 && (Opcode[5:3] == 3'b101) && Verify) begin 
            //convert from 
            g_l = 0;
            
            for (index=3;index>=0;index=index - 1)begin
                if(ByteEnable[index]!=0) begin
                    bytes[index] = RegOutput2[g_l*8 +:8];
                    g_l = g_l + 1;
                end
                else begin
                    bytes[index] = 8'hxx;
                end
            end
            WriteInMem = {bytes[3], bytes[2], bytes[1], bytes[0]}; 
            
        end
        else begin
            ReadOutMem = 0;
            WriteInMem = 0;
        end
    end
endmodule
