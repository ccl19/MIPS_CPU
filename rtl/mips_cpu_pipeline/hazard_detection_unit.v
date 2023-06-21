module hazard_detection_unit (
    input clk,
    input logic [31:0] IF_ID_Instruction,
    input logic ID_EX_MemReadEn,
    input logic EX_MEM_MemReadEn, // Stall in state MEM
    input logic EX_MEM_MemWriteEn, // Stall in state MEM
    input logic [4:0] EX_MEM_Rdest,
    input logic [4:0] ID_EX_Rdest,
    input logic [4:0] MEM_WB_Rdest,
    output logic PCWrite,
    output logic IF_ID_Write, // also the mux selector in ID
    output logic FetchMemSel, // if 1, select pc; if 0, select load/write data mem
    output logic IF_ID_valid,
    output logic Is_JB_stall
);
    logic[5:0] IF_ID_Opcode, IF_ID_Funccode;
    logic[4:0] IF_ID_Rs, IF_ID_Rt;
    logic Verify;
    logic IF_ID_valid_delay1;
    logic Is_LS, Is_LS_next;
    logic Is_General_stall;
    logic Is_valid_hold;
    logic IF_ID_WriteNext;
    logic [31:0] Hold_Instr;
    logic check_stall_valid;
    logic IS_GJ_Stall_next;


    
    logic IF_ID_Arithmetic_R, IF_ID_Arithmetic_I, IF_ID_Branch_R, IF_ID_Branch_I, IF_ID_J_RS, IF_ID_S, IF_ID_L;    
    // three kinds of way to make instruction invalid
    //1. not verify, pass the instruction
    //2. the instruction itself have some limitation that requires to stall
    //3. the instruction stopped due to the load and write accessing memory    

           
    assign IF_ID_Opcode = IF_ID_Instruction[31:26];
    assign IF_ID_Rs = IF_ID_Instruction[25:21]; 
    assign IF_ID_Rt = IF_ID_Instruction[20:16];
    assign IF_ID_Funccode = IF_ID_Instruction[5:0];

    //R:Rs&Rt; I:Rs
    assign IF_ID_Arithmetic_R = ((IF_ID_Opcode==6'b000000) && ((IF_ID_Funccode==6'b100001)||(IF_ID_Funccode==6'b100100)||(IF_ID_Funccode==6'b100111)||(IF_ID_Funccode==6'b100101)||
                                                               (IF_ID_Funccode==6'b101010)||(IF_ID_Funccode==6'b101011)||(IF_ID_Funccode==6'b100010)||(IF_ID_Funccode==6'b100011)||
                                                               (IF_ID_Funccode==6'b100110)||(IF_ID_Funccode==6'b000100)||(IF_ID_Funccode==6'b000111)||(IF_ID_Funccode==6'b000110)||
                                                               (IF_ID_Funccode==6'b011010)||(IF_ID_Funccode==6'b011011)||(IF_ID_Funccode==6'b011000)||(IF_ID_Funccode==6'b011001)||
                                                               (IF_ID_Funccode==6'b000000) || (IF_ID_Funccode==6'b000011) || (IF_ID_Funccode==6'b000010)));

    assign IF_ID_Arithmetic_I = ((IF_ID_Opcode==6'b001001) || (IF_ID_Opcode==6'b001100) || (IF_ID_Opcode==6'b001101) || (IF_ID_Opcode==6'b001010) || (IF_ID_Opcode==6'b001011) ||
                                 (IF_ID_Opcode==6'b001110) || ((IF_ID_Opcode==6'b000000) && ((IF_ID_Funccode==6'b010001) || (IF_ID_Funccode==6'b010011))));
    assign IF_ID_Branch_R = ((IF_ID_Opcode==6'b000100) || (IF_ID_Opcode==6'b000101));
    assign IF_ID_Branch_I = ((IF_ID_Opcode==6'b000001) || (IF_ID_Opcode==6'b000111) || (IF_ID_Opcode==6'b000110));
    assign IF_ID_J_RS = (IF_ID_Opcode == 6'b000000 && (IF_ID_Funccode == 6'b001001 || IF_ID_Funccode == 6'b001000));
    assign IF_ID_L = ((IF_ID_Opcode==6'b100000) || (IF_ID_Opcode==6'b100100) || (IF_ID_Opcode==6'b100001) || (IF_ID_Opcode==6'b100101) || (IF_ID_Opcode==6'b100011) || (IF_ID_Opcode==6'b100010) || (IF_ID_Opcode==6'b100110));
    assign IF_ID_S = ((IF_ID_Opcode==6'b101000) || (IF_ID_Opcode==6'b101001) || (IF_ID_Opcode==6'b101011));
    
    assign check_stall_valid = (IF_ID_WriteNext)? 1 : Is_valid_hold;
    always @(posedge clk) begin
        // if(IF_ID_Instruction != Hold_Instr )begin
        //     Is_valid_hold <= 1;
        // end
        if( IF_ID_WriteNext == 1)begin
            //indicate that it is new instruction.
            if(IF_ID_valid == 1)begin
                //the start is already valid
                Is_valid_hold <= 0;
            end
            else begin
                //the start is a stall
                Is_valid_hold <= 1;
            end
        end
        else begin
            if(IF_ID_valid)begin
                Is_valid_hold <= 0;
            end
        end

        Hold_Instr <= IF_ID_Instruction;
    end

    always @(posedge clk) begin
        Is_LS_next <= Is_LS;
        IF_ID_WriteNext <= IF_ID_Write;
        if(Is_General_stall == 1 || Is_JB_stall == 1)begin
            IS_GJ_Stall_next <= 1;
        end
        else begin
            IS_GJ_Stall_next <= 0;
        end
    end


    always @(*) begin
        
       if(Is_General_stall || Is_JB_stall)begin
            //if it is general and jump stall.
            IF_ID_Write = 0;
            PCWrite = 0;
        end
        else if(IS_GJ_Stall_next && Is_LS_next && Is_valid_hold == 1)begin
            // if previously it is general and LS same time and the instruction is still not valid.
            IF_ID_Write = 0;
            PCWrite = 0;
        end
        else if(Is_LS)begin
            // if previously is only Forced stall.
            IF_ID_Write = 0;
            PCWrite = 0;
        end
        else begin
            IF_ID_Write = 1;
            PCWrite = 1;
        end

    end
    always @(*) begin
        if(Verify == 0)begin
            IF_ID_valid = 0;
        end
        else if (Is_LS_next || Is_General_stall || Is_JB_stall)begin
            IF_ID_valid = 0;

        end
        else if (IF_ID_Write == 1 && IF_ID_WriteNext == 0 && Is_valid_hold == 0)begin
            IF_ID_valid = 0;
        end

        else begin
            IF_ID_valid = 1;
        end
    end

    // assign FetchMemSel = (EX_MEM_MemReadEn || EX_MEM_MemWriteEn)? 0 : 1;
    // assign Is_LS = (EX_MEM_MemReadEn || EX_MEM_MemWriteEn) ? 1 : 0;
    always @(*) begin
        if(EX_MEM_MemReadEn || EX_MEM_MemWriteEn)begin
            Is_LS = 1;
            FetchMemSel = 0;
        end
        else begin
            Is_LS = 0;
            FetchMemSel = 1;
        end
        //load + add
        if((ID_EX_MemReadEn==1) && (ID_EX_Rdest==IF_ID_Rs) && (IF_ID_Arithmetic_R||IF_ID_Arithmetic_I) && (check_stall_valid == 1 ))begin
            //all arithmetic except J target and JAL target
            Is_General_stall = 1;
            Is_JB_stall = 0;
        end
        else if ((ID_EX_MemReadEn==1) && (ID_EX_Rdest==IF_ID_Rt) && (IF_ID_Arithmetic_R) && (check_stall_valid == 1))begin
            Is_JB_stall = 0;
            Is_General_stall = 1;
        end

        // Stall in state MEM
        

        // (don't care) + add + branch 
        else if((((IF_ID_Rs == ID_EX_Rdest) && (IF_ID_Branch_I || IF_ID_J_RS))|| (((IF_ID_Rs == ID_EX_Rdest)||(IF_ID_Rt == ID_EX_Rdest)) && IF_ID_Branch_R)) && (check_stall_valid)) begin
            Is_General_stall = 0;
            Is_JB_stall = 1;
        end

        // arithmetic + (don't care) + branch 
        else if((((IF_ID_Rs == EX_MEM_Rdest) && (IF_ID_Branch_I || IF_ID_J_RS))|| ((IF_ID_Rt == EX_MEM_Rdest || IF_ID_Rs == EX_MEM_Rdest) && IF_ID_Branch_R))&&(check_stall_valid))begin
            Is_General_stall = 0;
            Is_JB_stall = 1;
        end
        
        //load + branch r
        else if (ID_EX_MemReadEn==1 &&  (IF_ID_Branch_R && ((IF_ID_Rs == ID_EX_Rdest) || (IF_ID_Rt == ID_EX_Rdest)))&& (check_stall_valid))begin // Rs or Rt of branch = Rt of load
                Is_General_stall = 0;
                Is_JB_stall = 1;
        end
        else if (ID_EX_MemReadEn==1 && (IF_ID_Branch_I ||IF_ID_J_RS) && (IF_ID_Rs == ID_EX_Rdest) && (check_stall_valid))begin // Rs of branch = Rt of load
                Is_General_stall = 0;
                Is_JB_stall = 1;
        end  
        

        //load + ( ) + branch r
        else if(EX_MEM_MemReadEn==1 && (((IF_ID_Branch_R) &&(EX_MEM_Rdest == IF_ID_Rs || EX_MEM_Rdest == IF_ID_Rt)) ||  ((IF_ID_Branch_I || IF_ID_J_RS) &&(EX_MEM_Rdest == IF_ID_Rs))) && (check_stall_valid))begin
            Is_General_stall = 0;
            Is_JB_stall = 1;
        end
        
        //read from reg that is just written when the instruction is at ID, the content of the original reg would come out.
        //For every MEM_WB instruction that need to write to certain reg where the IF_ID_Instruction is trying to access. 
        else if((((MEM_WB_Rdest == IF_ID_Rs || MEM_WB_Rdest == IF_ID_Rt) && (IF_ID_Arithmetic_R || IF_ID_Branch_R)) || ((MEM_WB_Rdest == IF_ID_Rs) && (IF_ID_Arithmetic_I || IF_ID_Branch_I || IF_ID_J_RS)))&& (check_stall_valid))begin

            if(IF_ID_Branch_I || IF_ID_Branch_R)begin
                Is_JB_stall = 1;
                Is_General_stall = 0;
            end
            else begin
                Is_JB_stall = 0;
                Is_General_stall = 1;
            end
        end

        //if the calculation of the offset involves the addition of rs + offset. 
        else if ((MEM_WB_Rdest == IF_ID_Rs) && (IF_ID_L || IF_ID_S) && (check_stall_valid))begin
            Is_General_stall = 1;
            Is_JB_stall = 0;
        end
        
        // SW get access to the dest register in MEM_WB
        else if((MEM_WB_Rdest == IF_ID_Rs || MEM_WB_Rdest == IF_ID_Rt) && (IF_ID_S)&& (check_stall_valid))begin
            Is_General_stall = 1;
            Is_JB_stall = 0;
        end

        else begin
            Is_General_stall = 0;
            Is_JB_stall = 0;
        end
      
    end
    verify_instr verifyblock(
        .Instruction (IF_ID_Instruction),
        .Verify (Verify)
    ); 
endmodule
