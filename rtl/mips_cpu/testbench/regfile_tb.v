module regfile_tb();

logic clk, reset, reg_write, reg_read, Hi_enable, Lo_enable;
logic[31:0] instruction, PC, mem_out, read_out_1, read_out_2, v0, write_data;
logic[1:0] RegDst;
logic[2:0] DatatoReg;
logic[63:0] alu_out;
logic[31:0] reg_file[31:0];
logic[4:0] write_reg_address;
logic Verify;

initial begin
    $dumpfile("regfile.vcd");
    $dumpvars(0,regfile_tb);
    Verify = 1;

    //testing write and read (write alu_out to reg[3] and read this value from read_out_2))
    clk = 0;
    instruction = 32'h00832821;
    reset = 0;
    reg_write = 1;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b000;
    alu_out = 5;
    reg_read = 0;
    Hi_enable = 0;
    Lo_enable = 0;
    #5;
    //ADDU $5 $4 $3(rt)
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    clk = 0;
    #5;

    instruction = 32'h00832821;
    reset = 0;
    reg_write = 0;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b000;
    alu_out = 5;
    reg_read = 1;
    Hi_enable = 0;
    Lo_enable = 0;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    assert(read_out_2 == 5) else $fatal(0, "failed, result = %d", read_out_2);


    //testing write and read (write PC to reg[3] and read this value from read_out_2))
    clk = 0;
    instruction = 32'h00832821;
    reset = 0;
    reg_write = 1;
    RegDst = 2'b00;
    PC = 32'h2;
    mem_out = 32'h1234;
    DatatoReg = 3'b010;
    alu_out = 5;
    reg_read = 0;
    Hi_enable = 0;
    Lo_enable = 0;
    #5;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    clk = 0;
    #5;

    instruction = 32'h00832821;
    reset = 0;
    reg_write = 0;
    RegDst = 2'b00;
    PC = 32'h2;
    mem_out = 32'h1234;
    DatatoReg = 3'b010;
    alu_out = 5;
    reg_read = 1;
    Hi_enable = 0;
    Lo_enable = 0;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    assert(read_out_2 == 10) else $fatal(0, "failed, result = %d", read_out_2);

    //testing write and read (write mem_out to reg[3] and read this value from read_out_2))
    clk = 0;
    instruction = 32'h00832821;
    reset = 0;
    reg_write = 1;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b001;
    alu_out = 5;
    reg_read = 0;
    Hi_enable = 0;
    Lo_enable = 0;
    #5;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    clk = 0;
    #5;

    instruction = 32'h00832821;
    reset = 0;
    reg_write = 0;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b001;
    alu_out = 5;
    reg_read = 1;
    Hi_enable = 0;
    Lo_enable = 0;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    assert(read_out_2 == 32'h1234) else $fatal(0, "failed, result = %d", read_out_2);






    //find hi and lo
    clk = 0;
    instruction = 32'h00832821;
    reset = 0;
    reg_write = 1;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b000;
    alu_out = 32'h1234;
    reg_read = 0;
    Hi_enable = 0;
    Lo_enable = 1; // load write_data into lo first
    #5;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    clk = 0;
    #5;


    /*clk = 0;
        instruction = 32'h00832821;
        reset = 0;
        reg_write = 1;
        RegDst = 2'b00;
        PC = 32'h1;
        mem_out = 32'h1234;
        DatatoReg = 3'b100;
        alu_out = 64'h1234;
        reg_read = 0;
        Hi_enable = 1;
        Lo_enable = 1;
        #5;
        
        clk = 1;
        #5;

        clk = 0;
        #5;

        clk = 1;
        #5;

        clk = 0;
        #5;*/
    

    
    
    
    instruction = 32'h00832821;
    reset = 0;
    reg_write = 0;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b100;
    alu_out = 64'h1234;
    reg_read = 1;
    Hi_enable = 1;
    Lo_enable = 1;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    //check lo for DIV MULT
    assert(read_out_2 == 32'h1234) else $fatal(0, "failed, result = %d", read_out_2);

clk = 0;
    instruction = 32'h00832821;
    reset = 0;
    reg_write = 1;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b011;
    alu_out = 64'h211111234; // alu[63:32] = 2
    reg_read = 0;
    Hi_enable = 1;
    Lo_enable = 1;
    #5;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    clk = 0;
    #5;


    instruction = 32'h00832821;
    reset = 0;
    reg_write = 0;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b011;
    alu_out = 64'h1234;
    reg_read = 1;
    Hi_enable = 1;
    Lo_enable = 1;
    #5
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    assert(read_out_2 == 2) else $fatal(0, "failed, result = %d", read_out_2);



    //reset (even when something is written in reg[3])
    clk = 0;
    instruction = 32'h00832821;
    reset = 0;
    reg_write = 1;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b000;
    alu_out = 5;
    reg_read = 0;
    Hi_enable = 0;
    Lo_enable = 0;
    #5;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    clk = 0;
    #5;

    instruction = 32'h00832821;
    reset = 1;
    reg_write = 0;
    RegDst = 2'b00;
    PC = 32'h1;
    mem_out = 32'h1234;
    DatatoReg = 3'b000;
    alu_out = 5;
    reg_read = 1;
    Hi_enable = 0;
    Lo_enable = 0;
    
    clk = 1;
    #5;

    clk = 0;
    #5;

    clk = 1;
    #5;

    assert(read_out_1 == 0) else $fatal(0, "failed, result = %d", read_out_1);
    assert(read_out_2 == 0) else $fatal(0, "failed, result = %d", read_out_2);



end     



regfile r(
    .clk(clk),
    .reset(reset),
    .Instruction(instruction),
    .RegWriteEn(reg_write),
    .RegReadEn(reg_read),
    .HiEn(Hi_enable),
    .LoEn(Lo_enable),
    .RegWriteDst(RegDst),
    .RegWriteDataSel(DatatoReg),
    .RegPC(PC),
    .ReadOutMem(mem_out),
    .Verify(Verify),
    .ALU(alu_out),
    .RegOutput1(read_out_1),
    .RegOutput2(read_out_2),
    .V0(v0)
);

endmodule