#include <iostream>
#include <fstream>
#include <vector>
#include <bitset>
#include <sstream>
#include <sys/stat.h>
#include <math.h>
#include <tuple>
#include <string>

using namespace std;

string MIPS_Disassembly(string instruction){
    std::string D_instr;
    std::uint64_t instr = std::stoull(instruction,nullptr,16);
    std::uint16_t opcode = instr>>26; //std::stoul(instr.substr(0,6), 0, 16);
    std::uint16_t funccode = instr & 0x000003F; 
    std::uint16_t rs = (instr & 0x03E00000)>>21; 
    std::uint16_t rt = (instr & 0x001F0000)>>16; 
    std::uint16_t rd = (instr & 0x0000F800)>>11;
    std::uint16_t immediate = (instr & 0x0000FFFF);
    std::uint16_t sa = (instr & 0x000007C0) >> 6;
    std::uint32_t target = instr & 0x03FFFFFF;
    if(opcode==0){
        if(funccode == 0b100001){
            //ADDU
            D_instr = "ADDU $" + to_string(rd) + ", $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b100100){
            //AND
            D_instr = "AND $" + to_string(rd) + ", $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b100101){
            //OR
            D_instr = "OR $" + to_string(rd) + ", $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b101010){
            //SLT
            D_instr = "SLT $" + to_string(rd) + ", $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b101011){
            //SLTU
            D_instr = "SLTU $" + to_string(rd) + ", $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b100011){
            //SUBU
            D_instr = "SUBU $" + to_string(rd) + ", $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b100110){
            //XOR
            D_instr = "XOR $" + to_string(rd) + ", $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b000000){
            //SLL
            D_instr = "SLL $" + to_string(rd) + ", $" + to_string(rt) +", " + to_string(sa); 
        }
        else if(funccode == 0b000100){
            //SLLV
            D_instr = "SLLV $" + to_string(rd) + ", $" + to_string(rt) +", $" + to_string(rs); 
        }
        else if(funccode == 0b000011){
            //SRA
            D_instr = "SRA $" + to_string(rd) + ", $" + to_string(rt) +", " + to_string(sa); 
        }
        else if(funccode == 0b000111){
            //SRAV
            D_instr = "SRAV $" + to_string(rd) + ", $" + to_string(rt) +", $" + to_string(rs); 
        }
        else if(funccode == 0b000010){
            //SRL
            D_instr = "SRL $" + to_string(rd) + ", $" + to_string(rt) +", " + to_string(sa); 
        }
        else if(funccode == 0b000110){
            //SRLV
            D_instr = "SRLV $" + to_string(rd) + ", $" + to_string(rt) +", $" + to_string(rs); 
        }
        else if(funccode == 0b011010){
            //DIV
            D_instr = "DIV $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b011011){
            //DIVU
            D_instr = "DIVU $" + to_string(rs) +", $" + to_string(rt);
        }
        else if(funccode == 0b010000){
            //MFHI
            D_instr = "MFHI $" + to_string(rd);
        }
        else if(funccode == 0b010010){
            //MFLO
            D_instr = "MFLO $" + to_string(rd);
        }
        else if(funccode == 0b010001){
            //MTHI
            D_instr = "MFHI $" + to_string(rs);
        }
        else if(funccode == 0b010011){
            //MTLO
            D_instr = "MTLO $" + to_string(rs);
        }
        else if(funccode == 0b011000){
            //MULT
            D_instr = "MULT $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b011001){
            //MULTU
            D_instr = "MULTU $" + to_string(rs) +", $" + to_string(rt); 
        }
        else if(funccode == 0b001001){
            //JALR
            D_instr = "JALR $" + to_string(rd) + to_string(rs);
        }
        else if(funccode == 0b001000){
            //JR
            D_instr = "JR $" + to_string(rs);
        }
    }
    else if(opcode == 0b001001){
        //ADDIU
        D_instr = "ADDIU $"+to_string(rt)+", $"+ to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b001100){
        //ANDI
        D_instr = "ANDI $"+to_string(rt)+", $"+ to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b001111){
        //LUI
        D_instr = "LUI $"+to_string(rt)+", "+to_string(immediate);
    }
    else if(opcode == 0b001101){
        //ORI
        D_instr = "ORI $"+to_string(rt)+", $"+ to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b001010){
        //SLTI
        D_instr = "SLTI $"+to_string(rt)+", $"+ to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b001011){
        //SLTIU
        D_instr = "SLTIU $"+to_string(rt)+", $"+ to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b001110){
        //XORI
        D_instr = "XORI $"+to_string(rt)+", $"+ to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b000100){
        //BEQ
        D_instr = "BEQ $"+to_string(rs)+", $"+ to_string(rt)+", "+to_string(immediate);
    }
    else if(opcode == 0b000001){
        if(rt == 0b00001){
            //BGEZ
            D_instr = "BGEZ $"+to_string(rs)+", "+to_string(immediate);
        }
        else if(rt == 0b10001){
            //BGEZAL
            D_instr = "BGEZAL $"+to_string(rs)+", "+to_string(immediate);
        }
        else if(rt == 0b00000){
            //BLTZ
            D_instr = "BLTZ $"+to_string(rs)+", "+to_string(immediate);
        }
        else if(rt == 0b10000){
            //BLTZAL
            D_instr = "BLTZAL $"+to_string(rs)+", "+to_string(immediate);
        }
    }
    else if(opcode == 0b000111){
        //BGTZ
        D_instr = "BGTZ $"+to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b000110){
        //BLEZ
        D_instr = "BLEZ $"+to_string(rs)+", "+to_string(immediate);
    }
    else if(opcode == 0b000101){
        //BNE
        D_instr = "BNE $"+to_string(rs)+", $"+ to_string(rt)+", "+to_string(immediate);
    }
    else if(opcode == 0b000010){
        //J
        D_instr = "J "+ to_string(target);
    }
    else if(opcode == 0b000011){
        //JAL
        D_instr = "JAL "+ to_string(target);
    }
    else if(opcode == 0b100000){
        //LB
        D_instr = "LB $" + to_string(rt)+", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b100100){
        //LBU
        D_instr = "LBU $" +to_string(rt)+ ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b100001){
        //LH
        D_instr = "LH $" + to_string(rt) + ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b100101){
        //LHU
        D_instr = "LHU $" + to_string(rt) + ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b100011){
        //LW
        D_instr = "LW $" + to_string(rt) + ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    
    else if(opcode == 0b101000){
        //SB
        D_instr = "SB $" +to_string(rt)+ ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b101001){
        //SH
        D_instr = "SH $" +to_string(rt)+ ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b101011){
        //SW
        D_instr = "SW $" +to_string(rt)+ ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b100010){
        //LWL
        D_instr = "LWL $" +to_string(rt)+ ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else if(opcode == 0b100110){
        //LWR
        D_instr = "LWR $" +to_string(rt)+ ", " + to_string(immediate) + "($" + to_string(rs) + ")";
    }
    else {
        D_instr = "Invalid Instruction";
    }
    return D_instr;
}

vector<string>MIPS_Disassembler(vector<string> hex_code){
    vector<string> machine_code;
    int count = 0;
    for (int i=0;i<hex_code.size();i++){
        if (hex_code[i] != "00000000"){
            if (count!=0){
                machine_code.push_back("---There are "+to_string(count)+" skipped instructions---");
                count = 0;
            }
            string D_instr=MIPS_Disassembly(hex_code[i]);
            machine_code.push_back(D_instr);
        }
        else{
            count = count+1;     
        }
    }
    return machine_code;
}


void disassembler_write_file(vector< vector<string> > machine_code, string filename){
    int mem_num = (machine_code).size();
    int mem_length;
    std::ofstream file;
    file.open(filename);
    for(int i=0;i<mem_num;i++){
        file<<"Testcase "+to_string(i+1)+":"<<endl;
        mem_length = machine_code[i].size();
        for (int j=0;j<mem_length;j++){
            file<<machine_code[i][j]<<endl;
        }
        file<<endl;
    }
    file.close();
}
