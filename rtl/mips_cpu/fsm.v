module fsm (
    input logic clk,
    input logic WaitRequest,
    input logic reset,
    output logic[2:0] State
);
    always @(posedge clk) begin
        if(reset || (State == 5))begin
            State <= 1;
        end
        else if (!WaitRequest) begin
            State <= State +1;
        end
    end
    
endmodule