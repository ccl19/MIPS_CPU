module fsm_tb(
);
    logic clk;
    logic waitrequest;
    logic reset;
    logic[2:0] state;

    initial begin
        //do we need to test timeout?
        //inspired by lab mu0 delay testbench
        clk = 0;
        repeat(1000) begin
            #5;
            clk = !clk;
            #5;
            clk = !clk;
        end
    end

    //the real testing

    initial begin
        clk = 0;
        waitrequest = 0;
        reset = 1;
        #5;
        clk = 1;
        #5;
        clk = 0;
        reset = 0;
        #5
        clk = 1;
        assert(state == 1);
        #5;
        clk = 0;
        assert(state == 2) else $fatal(0,"state = %d", state);
    
        #5;
        clk = 1;
        assert(state == 2);
        #5;
        clk = 0;

        #5;
        reset = 1;
        #5;
        clk = 1;
        #5;
        clk = 0;
        reset = 0;
        #5
        clk = 1;
        assert(state == 1);
        #5;
        clk = 0;
        assert(state == 2);
        #5
        reset = 0;
        clk = 1;
        assert(state == 2);
        #5;
        clk = 0;
        #5;
        clk = 1;
        assert(state == 3);
        #5;
        clk = 0;
        #5;
        clk = 1;
        assert(state == 4);
        #5;
        clk = 0;
        assert(state == 5);
        #5;
        waitrequest = 1;
        clk = 1;
        assert(state == 5);
        #5;
        clk = 0;
        #5;
        waitrequest = 0;
        clk = 1;
        assert(state == 1);
        #5;
        clk = 0;
        assert(state == 2);
        #5;
        clk = 1;
        assert(state == 2);
        #5;
        clk = 0;
        assert(state == 3);
        $finish;
    end

    fsm f(
        .clk(clk),
        .WaitRequest(waitrequest),
        .reset(reset),
        .State(state)
    );
endmodule