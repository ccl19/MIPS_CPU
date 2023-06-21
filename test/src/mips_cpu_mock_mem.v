module mips_cpu_mock_mem (
    input logic clk,
    input logic[31:0] address,
    input logic[31:0] write_data,
    input logic [3:0] byteenable,
    input logic write_enable,
    input logic MemRead,
    output logic [31:0] read_data,
    output logic waitrequest
);
    
    logic[31:0] mem_for_data[0:65535];
    logic[31:0] mem_for_inst[0:65535];
    logic[31:0] mem_for_data_add;
    logic[31:0] mem_for_inst_add;
    logic choose_inst;
    logic wait_next;
    // distinguish mem for data and mem for inst.
    // byteenable 
    logic[7:0] byte0, byte1, byte2, byte3;
    //byte for the read output
    logic[7:0] byte_out0, byte_out1, byte_out2, byte_out3;
    //byte for the write input
    logic[7:0] byte_in0, byte_in1, byte_in2, byte_in3;
    //to rearrange the write data for the byte store.
    logic[7:0] write_byte0, write_byte1, write_byte2, write_byte3;
    logic[31:0] read_data_prep, write_data_prep;
    integer i, j;
    parameter MEM_1 = "";
    parameter MEM_2 = "";
    initial begin
        integer i;
        for(i=0 ; i < 1001 ; i = i + 1)begin
            mem_for_data[i] = 0;
            mem_for_inst[i] = 0;
        end
        /*Load from mem_1.txt mem_2.txt */
        if (MEM_1 != "") begin
            $display("MEM_1 : INIT : Loading MEM_1 contents from %s", MEM_1);
            $readmemh(MEM_1, mem_for_data);
        end
        if (MEM_2 != "") begin
            $display("MEM_2 : INIT : Loading MEM_2 contents from %s", MEM_2);
            $readmemh(MEM_2, mem_for_inst);
            
        end    
    end
    always_ff @(posedge clk) begin
        wait_next <= $urandom_range(1,0);
    end
    assign waitrequest = (MemRead==1||write_enable==1)? wait_next : 0;
//prepare the content of memory in the address array in the form of bytes
    always @(*) begin
        if(address >= 32'hBFC00000)begin
            mem_for_inst_add = address - 32'hBFC00000;
            choose_inst = 1;
        end
        else if(address < 65536)begin
            mem_for_data_add = address;
            choose_inst = 0;
        end
    end

    assign byte0 = (choose_inst)? mem_for_inst[mem_for_inst_add][7:0] : mem_for_data[mem_for_data_add][7:0];
    assign byte1 = (choose_inst)? mem_for_inst[mem_for_inst_add][15:8] :mem_for_data[mem_for_data_add][15:8];
    assign byte2 = (choose_inst)? mem_for_inst[mem_for_inst_add][23:16]: mem_for_data[mem_for_data_add][23:16];
    assign byte3 = (choose_inst)? mem_for_inst[mem_for_inst_add][31:24]: mem_for_data[mem_for_data_add][31:24];

//Read part
always @(*) begin
    if(MemRead)begin
        if(byteenable[0] == 0)begin
            byte_out0 = 8'hxx;
        end
        else begin
            byte_out0 = byte0;
        end
        
        if(byteenable[1] == 0)begin
            byte_out1 = 8'hxx;
        end
        else begin
            byte_out1 = byte1;
        end
        if(byteenable[2] == 0)begin
            byte_out2 = 8'hxx;
        end
        else begin
            byte_out2 = byte2;
        end
        //3
        if(byteenable[3] == 0)begin
            byte_out3 = 8'hxx;
        end
        else begin
            byte_out3 = byte3;
        end
        read_data_prep = {byte_out3, byte_out2, byte_out1, byte_out0};
    end
end

always_ff @(posedge clk)begin
    if (MemRead)begin
        read_data <= read_data_prep;
    end
end


//Write part 
always @(*) begin
// here is used to put the write data into the correct position in order to facilitate the store process
    case (byteenable)
       4'b0000 : begin write_byte0 = byte0; write_byte1 = byte1; write_byte2 = byte2; write_byte3 = byte3; end
       4'b0001 : begin write_byte0 = write_data[7:0]; write_byte1 = byte1; write_byte2 = byte2; write_byte3 = byte3; end
       4'b0010 : begin write_byte0 = byte0; write_byte1 = write_data[15:8]; write_byte2 = byte2; write_byte3 = byte3; end
       4'b0011 : begin write_byte0 = write_data[7:0]; write_byte1 = write_data[15:8]; write_byte2 = byte2; write_byte3 = byte3; end
       4'b0100 : begin write_byte0 = byte0; write_byte1 = byte1; write_byte2 = write_data[23:16]; write_byte3 = byte3; end
       4'b0101 : begin write_byte0 = write_data[7:0]; write_byte1 = byte1; write_byte2 = write_data[23:16]; write_byte3 = byte3; end
       4'b0110 : begin write_byte0 = byte0; write_byte1 = write_data[15:8]; write_byte2 = write_data[23:16]; write_byte3 = byte3; end
       4'b0111 : begin write_byte0 = write_data[7:0]; write_byte1 = write_data[15:8]; write_byte2 = write_data[23:16]; write_byte3 = byte3; end
       4'b1000 : begin write_byte0 = byte0; write_byte1 = byte1; write_byte2 = byte2; write_byte3 = write_data[31:24]; end
       4'b1001 : begin write_byte0 = write_data[7:0]; write_byte1 = byte1; write_byte2 = byte2; write_byte3 = write_data[31:24]; end
       4'b1010 : begin write_byte0 = byte0; write_byte1 = write_data[15:8]; write_byte2 = 0; write_byte3 = write_data[31:24]; end
       4'b1011 : begin write_byte0 = write_data[7:0]; write_byte1 = write_data[15:8]; write_byte2 = 0; write_byte3 = write_data[31:24];end
       4'b1100 : begin write_byte0 = byte0; write_byte1 = byte1; write_byte2 = write_data[23:16]; write_byte3 = write_data[31:24]; end
       4'b1101 : begin write_byte0 = write_data[7:0]; write_byte1 = byte1; write_byte2 = write_data[23:16]; write_byte3 = write_data[31:24];end
       4'b1110 : begin write_byte0 = byte0; write_byte1 = write_data[15:8]; write_byte2 = write_data[23:16]; write_byte3 = write_data[31:24];end
       4'b1111 : begin write_byte0 = write_data[7:0]; write_byte1 = write_data[15:8]; write_byte2 = write_data[23:16]; write_byte3 = write_data[31:24];end
        default: begin write_byte0 = byte0; write_byte1 = byte1; write_byte2 = byte2; write_byte3 = byte3;end
    endcase
    write_data_prep = {write_byte3 , write_byte2, write_byte1, write_byte0};
end

always_ff @(posedge clk)begin
    if(write_enable)begin
        if(choose_inst == 0)begin
            mem_for_data[mem_for_data_add - mem_for_data_add%4] <= write_data_prep;    
        end 
        else begin
            mem_for_inst[mem_for_inst_add - mem_for_inst_add%4] <= write_data_prep;
        end

    end
end

endmodule