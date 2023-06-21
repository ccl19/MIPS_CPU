module forwarding_unit (
    input logic [4:0] ID_EX_Rs,
    input logic [4:0] ID_EX_Rt,
    input logic [4:0] EX_MEM_Rdest,
    input logic [4:0] MEM_WB_Rdest,
    input logic EX_MEM_RegWrite,
    input logic MEM_WB_RegWrite,
    output logic [1:0] Forward_A,
    output logic [1:0] Forward_B
);

logic MEM_h_d_s, MEM_h_d_t, EX_h_d_s, EX_h_d_t, MEM_check_d_s, MEM_check_d_t;


//MEM hazard 
// assign MEM_h_d_s = (((MEM_WB_RegWrite==1) && (MEM_WB_Rdest != 0)) && (MEM_WB_Rdest == ID_EX_Rs)) ? 1 : 0;
// assign MEM_h_d_t = (((MEM_WB_RegWrite==1) && (MEM_WB_Rdest != 0)) && (MEM_WB_Rdest == ID_EX_Rt)) ? 1 : 0;
// to avoid two hazards happen at the same time
// assign MEM_check_d_s = (((MEM_WB_RegWrite==1) && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rs))? 1 : 0;
// assign MEM_check_d_t = (((MEM_WB_RegWrite==1) && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rt))? 1 : 0;

//EX hazard
// assign EX_h_d_s = (EX_MEM_RegWrite && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rs);

// assign EX_h_d_t = (EX_MEM_RegWrite && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rt);


always @(*) begin
    if(MEM_WB_Rdest == 5'bxxxxx)begin
        MEM_h_d_s = 0;
        MEM_h_d_t = 0;
    end
    else if ((MEM_WB_RegWrite==1) && (MEM_WB_Rdest != 0) && (MEM_WB_Rdest == ID_EX_Rs && MEM_WB_Rdest == ID_EX_Rt))begin
        MEM_h_d_s = 1;
        MEM_h_d_t = 1;
    end
    else if((MEM_WB_RegWrite==1) && (MEM_WB_Rdest != 0) && (MEM_WB_Rdest == ID_EX_Rs))begin
        MEM_h_d_s = 1;
        MEM_h_d_t = 0;
    end
    else if((MEM_WB_RegWrite==1) && (MEM_WB_Rdest != 0) && (MEM_WB_Rdest == ID_EX_Rt))begin
        MEM_h_d_s = 0;
        MEM_h_d_t = 1;
    end
    else begin
        MEM_h_d_s = 0;
        MEM_h_d_t = 0;
    end
end
always @(*) begin
    if(EX_MEM_Rdest == 5'bxxxxx)begin
        MEM_check_d_s = 0;
        MEM_check_d_t = 0;
    end
    else if((MEM_WB_RegWrite==1) && (EX_MEM_Rdest != 0) && (EX_MEM_Rdest == ID_EX_Rs) && (EX_MEM_Rdest == ID_EX_Rt))begin
        MEM_check_d_t = 1;
        MEM_check_d_s = 1;
    end
    else if((MEM_WB_RegWrite==1) && (EX_MEM_Rdest != 0) && (EX_MEM_Rdest == ID_EX_Rs))begin
        MEM_check_d_t = 0;
        MEM_check_d_s = 1;
    end
    else if(((MEM_WB_RegWrite==1) && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rt))begin
        MEM_check_d_t = 1;
        MEM_check_d_s = 0;
    end
    else begin
        MEM_check_d_s = 0;
        MEM_check_d_t = 0;
    end
end

always @(*) begin
    if(EX_MEM_Rdest == 5'bxxxxx)begin
        EX_h_d_s = 0;
        EX_h_d_t = 0;
    end
    else if ((EX_MEM_RegWrite && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rs) && (EX_MEM_Rdest == ID_EX_Rt))begin
        EX_h_d_s = 1;
        EX_h_d_t = 1;
    end
    else if ((EX_MEM_RegWrite && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rs))begin
        EX_h_d_s = 1;
        EX_h_d_t = 0;
    end
    else if ((EX_MEM_RegWrite && (EX_MEM_Rdest != 0)) && (EX_MEM_Rdest == ID_EX_Rt))begin
        EX_h_d_s = 0;
        EX_h_d_t = 1;
    end
    else begin
        EX_h_d_s = 0;
        EX_h_d_t = 0;
    end
    
end


always @(*) begin
    //Forward A

    if(EX_h_d_s)begin
        Forward_A = 2'b10;
    end
    else if(MEM_h_d_s && !MEM_check_d_s)begin
        Forward_A = 2'b01;
    end

    else if(MEM_h_d_s && MEM_check_d_s)begin
        Forward_A = 2'b10;
    end

    else begin
        Forward_A = 2'b00;
    end


    //Forward B

    if(EX_h_d_t)begin
        Forward_B = 2'b10;
    end
    else if(MEM_h_d_t && !MEM_check_d_t)begin
        Forward_B = 2'b01;
    end
    else if(MEM_h_d_t && MEM_check_d_t)begin
        Forward_B = 2'b10;
    end
    else begin
        Forward_B = 2'b00;
    end

end

    
endmodule