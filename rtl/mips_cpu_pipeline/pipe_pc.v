module pipe_pc(
    input logic clk,
    input logic reset,
    input logic [31:0] IF_ID_Instruction,
    input logic PCWrite,
    input logic [31:0] RegOutput1,
    input logic [31:0] RegOutput1Imm,
    input logic [31:0] RegOutput2,
    input logic [31:0] RegOutput2Imm,
    output logic[31:0] RegPC 
); 

    logic Branch_Decide;
    logic Jump_I_Decide;
    logic Jump_R_Decide;
    
    logic[5:0] Opcode; 
    logic[5:0] Funccode;
    logic[4:0] Branchcode;
    logic[31:0] prep_address; 
    logic[31:0] RegPC_next;
    logic [3:0] pc_upper;
    logic [25:0] target;
    logic [27:0] temp_target;
    logic [31:0] branch_jump_address;
    logic [15:0] immediate_address;
    logic [31:0] BranchResult;
    logic Zero;
    
    assign immediate_address = IF_ID_Instruction[15:0];

    assign pc_upper = RegPC_next[31:28];
    assign target = IF_ID_Instruction[25:0];
    assign prep_address = {{14{immediate_address[15]}}, immediate_address, 2'b00};

    assign Opcode = IF_ID_Instruction[31:26];
    assign Branchcode = IF_ID_Instruction[20:16];
    assign Funccode = IF_ID_Instruction[5:0];
    assign Zero = (BranchResult == 0)? 1 : 0;
    //ID
    //need to obtain the branch condition
    always @(*) begin
        // Branch comparing 2 register data (BEQ BNE)
        if(Opcode == 6'b000100 || Opcode == 6'b000101) begin
            BranchResult = RegOutput1Imm-RegOutput2Imm;
        end
        // BGEZ BGEZAL BGTZ BLEZ BLTZ BLTZAL comparing with zero
        else if (Opcode == 6'b000001  || Opcode == 6'b000111 || Opcode == 6'b000110)begin
            //use zero to compare with rs
            BranchResult = RegOutput1Imm;
        end
        else begin
            BranchResult = 32'hxxxxxxxx;
        end
    end

    always@(*) begin

        if ((Opcode==6'b000100 && Zero==1) //BEQ
            ||(Opcode==6'b000001 && (Branchcode==5'b00001||Branchcode==5'b10001) && (Zero==1 || BranchResult[31]==0)) //BGEZ BGEZAL
            ||(Opcode==6'b000111 && (BranchResult[31]==0 && Zero==0)) //BGTZ
            ||(Opcode==6'b000110 && (BranchResult[31]==1 || Zero==1))//BLEZ
            ||(Opcode==6'b000001 && (Branchcode==5'b00000||Branchcode==5'b10000) && (BranchResult[31]==1))//BLTZ BLTZAL
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

    

    assign RegPC_next = RegPC + 4;

    assign temp_target = target<<2;

    always @(posedge clk)begin
        if (reset) begin
            RegPC <= 32'hBFC00000;
        end
        else if(PCWrite)begin
            if (RegPC==0) begin
                RegPC <= 0;
            end
            else begin
                if(Branch_Decide)begin // all branch
                    RegPC <=  prep_address + RegPC;
                end
                
                else if (Jump_I_Decide) begin //J Jal 
                    RegPC <= {pc_upper, temp_target};
                end
                else if (Jump_R_Decide)begin // Jalr Jr
                    if (RegOutput1Imm %4 ==0)begin
                        RegPC <= RegOutput1Imm ;
                    end
                    else begin
                        $fatal(1,"Jumped to an invalid address - not divisible by 4.");
                    end            
                end
                else begin
                    RegPC <= RegPC_next;
                end 
            end
               
        end

    end


endmodule
