module pc(
    input logic clk,
    input logic reset,
    input logic Zero,
    input logic [2:0] State,
    input logic [31:0] Instruction,
    input logic [63:0] ALU,
    output logic[31:0] RegPC 
); 

    logic Branch_Decide;
    logic Jump_I_Decide;
    logic Jump_R_Decide;
    logic delay_decide;
    logic[5:0] Opcode; 
    logic[5:0] Funccode;
    logic[4:0] Branchcode;
    logic[31:0] prep_address; 
    logic[31:0] RegPC_next;
    logic[31:0] Alu;
    logic [3:0] pc_upper;
    logic pc_control;
    logic [25:0] target;
    logic [27:0] temp_target;
    logic [31:0] branch_jump_address;
    logic [15:0] immediate_address;
    assign immediate_address = Instruction[15:0];

    assign pc_upper = RegPC_next[31:28];
    assign target = Instruction[25:0];
    assign prep_address = {{14{immediate_address[15]}}, immediate_address, 2'b00};

    assign Opcode = Instruction[31:26];
    assign Branchcode = Instruction[20:16];
    assign Funccode = Instruction[5:0];
    assign Alu = ALU[31:0];


    always@(*) begin
        if ((Opcode==6'b000100 && Zero==1) //BEQ
            ||(Opcode==6'b000001 && (Branchcode==5'b00001||Branchcode==5'b10001) && (Zero==1 || Alu[31]==0)) //BGEZ BGEZAL
            ||(Opcode==6'b000111 && (Alu[31]==0 && Zero==0)) //BGTZ
            ||(Opcode==6'b000110 && (Alu[31]==1 || Zero==1))//BLEZ
            ||(Opcode==6'b000001 && (Branchcode==5'b00000||Branchcode==5'b10000) && (Alu[31]==1))//BLTZ BLTZAL
            ||(Opcode==6'b000101 && Zero==0))//BNE
            begin 
                Branch_Decide=1;
                Jump_I_Decide = 0;
                Jump_R_Decide = 0;
        end
        else if (Opcode==6'b000010 || Opcode==6'b000011)begin //J Jal 
            Jump_I_Decide = 1;
            Branch_Decide = 0;
            Jump_R_Decide = 0;
        end
        else if (Opcode==6'b000000 && (Funccode==6'b001001 || Funccode==6'b001000)) begin //J Jal 
            Jump_R_Decide = 1;
            Jump_I_Decide = 0;
            Branch_Decide = 0;
        end
        else begin
            Branch_Decide = 0;
            Jump_I_Decide = 0;
            Jump_R_Decide = 0;
        end
    end
    
    always_comb begin
        RegPC_next = RegPC + 4;
        if(State == 5)begin
            pc_control = 1;
        end
        else begin
            pc_control = 0;
        end
    end

    assign temp_target = target<<2;
    always @(posedge clk)begin
        if (reset) begin
            RegPC <= 32'hBFC00000;
        end
        else if(pc_control)begin
            
            if(Branch_Decide)begin // all branch
                branch_jump_address <=  prep_address + RegPC_next;
                delay_decide <= 1;
            end
            else if (Jump_I_Decide) begin //J Jal 
                branch_jump_address <= {pc_upper, temp_target};
                delay_decide <= 1;
            end
            else if (Jump_R_Decide)begin // Jalr Jr
                if (Alu %4 ==0)begin
                    branch_jump_address <= Alu;
                    delay_decide <= 1;
                end
                else begin
                    $fatal(1,"Jumped to an invalid address - not divisible by 4.");
                end            
            end
            else begin
                delay_decide <= 0;
            end   
            if (delay_decide) begin
                RegPC <= branch_jump_address;
            end
            else begin
                RegPC <= RegPC_next;
            end    
        end
    end


endmodule
