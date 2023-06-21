module mem_int_tb();

    logic[31:0] mem_out; 
    logic[31:0] instruction;
    logic[31:0] reg_in;
    logic[63:0] Alu_out;
    logic [2:0] state;
    logic[31:0] read_out_mem;//outputs below
    logic[31:0] write_in_mem;//o/p value
    logic [3:0] byteenable;//o/p value
    logic [31:0] mem_address;//o/p value
    logic Verify;

    // LB, LH, LWL, STORES, LBU, LHU,LW, LWR
    initial begin
        Verify = 1;
        // $dumpfile("mem_int_tb.vcd");
        // $dumpvars(0, mem_int_tb); 
        Alu_out[31:0] = 32'h30303030;
        state = 1;
        #1;
        assert(byteenable == 4'hf);

        #1
        state = 2;
        mem_out = 32'h23456789;

        //LB
        instruction = 32'h80020003;//this is an lb instruction
        #1
        //reads in reverse, big endian
        //testing the load byte
        assert(read_out_mem == 32'h89674523);//reverse bytes.

        state = 3;
        #1
        state = 4;
        #1
        // $display("%h",byteenable);
        // $display("mem out is ","%h",read_out_mem);

        state = 5;
        #1
        // $display("mem out is ","%h",read_out_mem);
        assert(read_out_mem == 32'hffffff89);

        #1 
        // $display(byteenable);//this is because byteenable is 0 we set everything to xxx
        // $display("%h", write_in_mem);// we can set to xxxxxx\\
        //testing STORES
        state = 1;
        instruction = 32'hA0000000;        
        reg_in = 32'h98765432;
        #1;
        state = 2;
        #1;
        //$display(byteenable);
        state = 4;
        #1

        //$display("line 54 %h",instruction);
        //$display(byteenable);//this is because byteenable is 0 we set everything to xxx
        // $display("%h", write_in_mem);// we can set to xxxxxx
        //TESTING LWL INSTRUCTIONS
        //LWL HERE

        state = 1;
        instruction = 32'h88020001;
        mem_out = 32'h88765432;
        #1
        //LWL
        state = 2;
        #1
        //$display("%h",read_out_mem);
        //assert(read_out_mem == 32'h01000288);
        state = 4;
        #1
        // $display(byteenable);//made all mem address divisible by 4.
        //hence for LWL byteenable should be 4. 
        assert(byteenable == 4'hf);
        state = 5;
        #1
        assert(mem_out == 32'h88765432);// this worls quite succesfully. 

        //No need to change instruction for next test
        mem_out = 32'h88888888;
        Alu_out = 32'h30303032;//mod 4 gives 2.
        state = 1;
        #1
        state = 2;
        #1
        state = 4;
        #1
        //$display("byteenable changed Alu_out","%b",byteenable);
        assert(byteenable == 4'b1100);//we can see the change given by the modulo
        state = 5;
        #1
        // $display("%h",read_out_mem);// gives 88885432
        //This is because reg_in is 32'h98765432
        //hence we can see that where byteenable is unchanged.
        assert(read_out_mem == 32'h88885432);

        //TEST LH 
        //THIS IS TESTED BELOW UNTIL OTHERWISE SPECIFIED.
        //SAME INSTRUCTION TESTED TWICE.

        instruction = 32'h84000000; //example for LH
        mem_out = 32'h12345678;

        state = 1;
        #1
        //as we know mem_address
        assert(byteenable == 15);
        state = 2;
        #1
        state = 4;
        #1
        //here mem_add %4 = 2 given by Alu_out
        // $display("final ",byteenable);// we can see that it changes from state1.
        assert(byteenable == 4'b1100);
        state = 5;
        #1
        // $display("%h",read_out_mem);// this gives 3412... and skips the condition.
        assert(read_out_mem == 32'h00003412);//we know g_l is 2.
        //this is because byteenable is non-zero at 2 postions
        //also as byte[2][7] corresponding to the value h'34 0011 0100 is zero
        //we enter the stage where we initate everything as 0.
        
        mem_out = 32'h12F45678;//same LH instruction as above with bytes[2][7] == 1
        state = 1;
        #1
        state = 2;
        #1
        state = 4;
        #1
        assert(byteenable == 4'b1100);
        state = 5;
        #1
        //this is because bytes[2][7] == 1
        assert(read_out_mem == 32'hFFFFF412);
        //assert(read_out_mem == 32'hffff3412);//this happens b/c calculated ff. 
        //we also got that the values of instruction

       
        //TESTBENCHING THE LBU INSTRUCTION
        //90020003 ----  100100
        instruction = 32'h90020003;//LBU
        state = 1;
        #1
        state = 2;
        #1
        state = 4;
        #1
        state = 5;
        #1
        assert(read_out_mem == 32'h000000F4);//done by tracing through code.
        //byteenable[2] != 0 as 2 = mem_addr %4. (Somehow this is offset+rs)

        //TESTING LHU
        mem_out = 32'h12345678;
        instruction = 32'h94000000;

        state = 1;
        #1
        //as we know mem_address
        assert(byteenable == 15);
        state = 2;
        #1
        state = 4;
        #1
        //here mem_add %4 = 2 given by Alu_out
        // we can see that it changes from state1.
        assert(byteenable == 4'b1100);
        state = 5;
        #1
        assert(read_out_mem == 32'h00003412);
        // $display("%h",read_out_mem);// this gives 3412... and skips the condition.

        //mem out -> 0-8 as before
        //This is an LW test.
        #5
        state = 1;
        #1
        state = 2;
        #1
        Alu_out = 64'h4;
        instruction = 32'h8C020004;
        mem_out= 32'h88765432;
        state = 4;
        
        #1
        state = 5;
        #1
        assert(read_out_mem == 32'h32547688);
        //THIS TESTS LWR
        
        #5
        state = 1;
        #1
        state = 2;
        #1
        state = 4;
        instruction = 32'h98020001;
        mem_out = 32'h87654321;
        #1
        state = 5;

    end

    mem_interface test(
        .MemOut(mem_out),
        .Instruction(instruction),
        .RegOutput2(reg_in),
        .ALU(Alu_out),
        .State(state),
        .ReadOutMem(read_out_mem),
        .WriteInMem(write_in_mem),
        .ByteEnable(byteenable),
        .MemAddressOut(mem_address),
        .Verify(Verify)
    );
endmodule


