#include <iostream>
#include <fstream>
#include <vector>
#include <bitset>
#include <sstream>
#include <sys/stat.h>
#include <math.h>
#include <string>
#include "MIPS.hpp"
using namespace std;


std::string classify_instr(std::string i){
    // set rd == $2
    if(i == "addu" || i == "and" || i == "or"  || i == "slt" || i == "sltu" ||i == "subu" || i == "xor" || i == "sll"
    || i == "sllv" || i == "sra" || i == "srav" || i == "srl" || i == "srlv"|| i == "mfhi" || i == "mflo" || i == "jalr"){
        return "set_rd_2";
    }
    // set rt == $2
    else if (i=="addiu" || i == "andi" || i == "lui" || i == "ori" || i == "slti" || i == "sltiu" || i == "xori"
    || i == "lb" || i == "lbu" || i == "lh" || i == "lhu" || i == "lw" || i == "lwl" || i == "lwr"){
        return "set_rt_2";
    }
    else {
        return "";
    }
}



void split(std::string const &str, const char delim, std::vector<std::string> &result){
    // construct a stream from the string
    std::stringstream ss(str);

    // clear previous values
    result.clear();
 
    std::string s;
    while (std::getline(ss, s, delim)) {
        result.push_back(s);
    }
}

vector<vector<string> > read_file(string filename){
    vector<vector<string> > mem;
    ifstream f;
    char delim = ',';
    vector<string> row;

    f.open(filename);
    string line;
    while(getline(f, line)){
        
    split(line, delim, row);
    // print_vector(row);
	mem.push_back(row);
	}
    return mem;
}

void write_file(vector<string> mem_in, string filename, string directory){
    int mem_length = (mem_in).size()*4;
    // create folders if not exists
    struct stat info;
    if( stat(directory.c_str(), &info ) != 0 ){ // doesn't exist
        //Make the directory
        mkdir(directory.c_str(),0777); // 0777 grant all rights to everyone
    }
    std::ofstream file;
    file.open (filename);
    for(int i=0;i<mem_length;i++){
        if(i%4 == 0){
            file<<mem_in[int(i/4)]<<endl;
        }
        else{
            file<<"00000000"<<endl;
        }
	  }
    file.close();
}



std::vector<std::string> binStr_to_hexStr(std::vector<std::string> bin_str_vector){
    int value;
    std::string hex_str;
    std::vector<std::string> hex_str_vector;
    for (int i=0; i<bin_str_vector.size(); i++){
        value = stoull(bin_str_vector[i], 0, 2); // binary string to integer
        hex_str = to_hex4(value); // integer to hex string
        hex_str_vector.push_back(hex_str);
    }
    return hex_str_vector;
}

void print_vector(std::vector<std::string> v){
    for (int i=0; i<v.size();i++){
        cout << v[i] << endl;
    }
}

std::string construct_instruction(std::string instr, std::string rs, std::string rt, std::string rd, std::string imm, std::string sa, std::string target, std::string set){
    if (instr.find('s')<instr.length()){
        instr.replace(instr.find("s"), rs.size(), rs);
    }
    if (instr.find('t')<instr.length()){
        if (set == "set_rt_2"){
            instr.replace(instr.find("t"),5,"00010");
        }
        else{
            instr.replace(instr.find("t"), rt.size(), rt);
        }
    }
    if (instr.find('d')<instr.length()){
        if (set == "set_rd_2"){
            instr.replace(instr.find("d"),5,"00010");
        }
        else{
            instr.replace(instr.find("d"), rd.size(), rd);
        }
    }
    if (instr.find('i')<instr.length()){
        instr.replace(instr.find("i"), imm.size(), imm);
    }
    if (instr.find('a')<instr.length()){
        instr.replace(instr.find("a"), sa.size(), sa);
    }
    if (instr.find('j')<instr.length()){
        instr.replace(instr.find("j"), target.size(), target);
    }
    return instr;
}

vector<string> generate_data(string instruction_name){

    int randNum1;
    int randNum2;
    string num1_h_str;
    string num2_h_str;
 
    vector<string> out;

    // int randNum = rand()%(max-min + 1) + min; include min&max
    randNum1 = rand()%(0x100000000); //random number between 0-0xFFFFFFFF
    randNum2 = rand()%(0x100000000);

    // for DIV and DIVU, the value in rt cannot be 0
    if (instruction_name == "div" || instruction_name == "divu"){
        randNum2 = 1 + rand()%(0xFFFFFFFF); // 1-0xFFFFFFFF
    }

    num1_h_str = to_hex4(randNum1);
    num2_h_str = to_hex4(randNum2);

    out.push_back(num1_h_str);
    out.push_back(num2_h_str);

    return out;
}


vector<string> big_endian_conversion(vector<string> hex_vector){
    vector<string> converted_vector;
    string converted_instr;
    for (int i=0; i<hex_vector.size(); i++){
        converted_instr = hex_vector[i].substr(6,2) + hex_vector[i].substr(4,2) + hex_vector[i].substr(2,2) + hex_vector[i].substr(0,2);
        converted_vector.push_back(converted_instr);
    }
    return converted_vector;
}


vector<string> generate_instruction_general(string instr_b_str_gap, string instruction_name){
    int randRs;
    int randRt;
    int randImm;
    int randSa;
    string Rs_b_str;
    string Rt_b_str;
    string Imm_b_str;
    string Sa_b_str;
    string Sa_b_str2;
    string Target_b_str;
    string ADDIU1_b_str;
    string LW1_b_str;
    string LW2_b_str;
    string instr_b_str;
    string JR_b_str;

    vector<string> vector_b_str;
    vector<string> vector_h_str; 

    //////// Generate random rs and rt
    randRs = rand()%(0b11111)+1; // 1-11111
    randRt = rand()%(0b11111)+1; // 1-11111
    Rs_b_str = std::bitset<5>(randRs).to_string();
    Rt_b_str = std::bitset<5>(randRt).to_string();

    // cout << "Rs: " << Rs_b_str << endl;
    // cout << "Rt: " << Rt_b_str << endl;

    //////// Generate immediate
    randImm = rand()%(0x10000); //random number between 0-0xFFFF
    Imm_b_str = std::bitset<16>(randImm).to_string();

    //////// Generate sa
    randSa = rand()%(0b100000); //0-11111
    Sa_b_str = std::bitset<5>(randSa).to_string();
    Sa_b_str2 = std::bitset<16>(randSa).to_string();
    /*-------------------------------------------- LW1 & LW2 -------------------------------------------------------*/
    //// Preset instructions
    // LW1: $randRS = mem[0]
    // LW2: $randRt = mem[4]
    // instruction to be tested goes here
    // JR $0
    LW1_b_str = "10001100000" + Rs_b_str + "0000000000000000";

    LW2_b_str = "10001100000" + Rt_b_str + "0000000000000100";
    ADDIU1_b_str = "00100100000" + Rt_b_str + Sa_b_str2;
    
    vector_b_str.push_back(LW1_b_str);
    
    if (instruction_name == "sllv" || instruction_name == "srav" || instruction_name == "srlv")
        vector_b_str.push_back(ADDIU1_b_str); // limit the shift amount for testing purposes
    else {
        vector_b_str.push_back(LW2_b_str);
    }
    /*-------------------------------------------- Instruction to be tested-------------------------------------------------------*/
    string Rd_b_str = "00010";
    string rd_or_rt = classify_instr(instruction_name);
    instr_b_str = construct_instruction(instr_b_str_gap, Rs_b_str, Rt_b_str, Rd_b_str, Imm_b_str, Sa_b_str, Target_b_str, rd_or_rt);
    vector_b_str.push_back(instr_b_str);
    /*-------------------------------------------- Multiplication and Division ----------------------------------------------------*/
    // LW1: $randRS = mem[0]
    // LW2: $randRt = mem[4]
    // MULTU Hi,Lo = Rs*Rt
    // MFHI or MFLO (random)
    bool mult_div = (instruction_name == "multu" || instruction_name == "mult" || 
                          instruction_name == "div" || instruction_name == "divu");
    //randNum = rand()%(max-min + 1) + min;
    int HiLo = rand()%(2);
    if ((mult_div & HiLo) || (instruction_name == "mthi")){
            //move from hi
            vector_b_str.push_back("00000000000000000001000000010000");
        }
    else if ((mult_div & !HiLo) || (instruction_name == "mtlo")){
        //move from lo
        vector_b_str.push_back("00000000000000000001000000010010");
    }
    
    /*-------------------------------------------- Jump to address 0 and halt ----------------------------------------------------*/
    JR_b_str = std::bitset<32>(8).to_string();
    vector_b_str.push_back(JR_b_str);
    /*-------------------------------------------- Change from binary string to hex string ---------------------------------------*/
    vector_h_str = binStr_to_hexStr(vector_b_str); 
    return vector_h_str;
}


vector<string> generate_instruction_jump_branch(string instr_b_str_gap, string instruction_name){
    int randRs;
    int randRt;
    int randRd;
    int randNum;
    signed int randImm;
    signed int randBranchBack;
    signed int randBJForward;
    int randTarget;
    int target;
    int randRtorRs;


    string Rs_b_str;
    string Rt_b_str;
    string Rd_b_str;
    string Num_b_str;
    string Imm_b_str;
    string Target_b_str;
    string Sa_b_str;

    string ADDIU1_b_str;
    string LW1_b_str;
    string LW2_b_str;
    string ADDIUB_b_str;
    string JR_b_str;
    string ADDIU0_b_str;
    string BJ_str;
    string SLL1_b_str;
    string Branch2_b_str;
    string instr_back_str;
    string instr_b_str;
    
    vector<string> vector_b_str;
    vector<string> vector_h_str;
    
    //////// Generate random rs, rt, offset, target

    randRs = 1+rand()%(0b11110); // 1-11110 (can't be register 0 or 31)
    if (randRs == 2){ // randRs cannot be 2
        randRs += 1; 
    }
    randRt = 1+rand()%(0b11111); // 1-11111
    if (randRt == 2){ // randRt cannot be 2
        randRt += 1; 
    }
    randRd = 1+rand()%(0b11111); // 1-11111
    randNum = 48+(rand()%(0x0010))*4; // a multiple of 4 in the range of 0-0x00FF
    //randImm = 0x10 + rand()%(1+0x0020); //0 to 0x001F (chose a small number else txt file would be too big)
    randTarget = 5+rand()%(0x001C); //0-0x001F (chose a small number else txt file would be too big)
    randBranchBack =  0 - (8+rand()%(0b10001)); //-8~-24 for jamp back 
    randBJForward =  3 + rand()%(5) - randBranchBack;
    Rs_b_str = std::bitset<5>(randRs).to_string();
    Rt_b_str = std::bitset<5>(randRt).to_string();
    Num_b_str = std::bitset<16>(randNum).to_string();
    BJ_str = std::bitset<16>(randBJForward).to_string();
    Target_b_str = std::bitset<26>(randTarget +0x3F00000).to_string(); 
    Branch2_b_str = std::bitset<16>(randBranchBack).to_string();
    string rd_or_rt = classify_instr(instruction_name);
    instr_b_str = construct_instruction(instr_b_str_gap, Rs_b_str, Rt_b_str, Rd_b_str, BJ_str, Sa_b_str, Target_b_str, rd_or_rt);
    
    //// Preset instructions for Jump and Branch

    // ADDIU1: $randRs = $0 + randNum
    // LW1: $randRt = mem[4]
    // ADDIU2: $2 = $0 + 0x1111
    // instruction to be tested goes here
    // ADDIU3: $2 = $2 + 0x1111
    // ADDIU4: $2 = $2 + 0x2222
    // ...
    // (address it jumps to) JR $0
    
    bool branch = (instruction_name[0] == 'b');
    bool jump_itype = (instruction_name == "j" || instruction_name == "jal");
    bool jump_rtype = (instruction_name == "jr" || instruction_name == "jalr");
    bool branch_AL = (instruction_name == "bgezal" || instruction_name == "bltzal");
    bool jump_AL = (instruction_name == "jal" || instruction_name == "jalr");

    if (jump_rtype){ 
    // we need to store smaller value into rs when doing JR and JALR, due to limited txt file space
    // we also need to make sure that the value in rs is a multiple of 4 -> Num_b_str need to be a multiple of 4
        ADDIU0_b_str = "00100100000" + Rs_b_str + "1011111111000000";
        vector_b_str.push_back(ADDIU0_b_str);
        SLL1_b_str = "00000000000" + Rs_b_str + Rs_b_str + "10000000000";
        vector_b_str.push_back(SLL1_b_str);
        ADDIU1_b_str = "001001"+ Rs_b_str + Rs_b_str + Num_b_str;
    }
    else{
        LW1_b_str = "10001100000" + Rs_b_str + "0000000000000000";
        vector_b_str.push_back(LW1_b_str);
    }
    if(jump_rtype){
        LW2_b_str = ADDIU1_b_str; //ADDIU1
    }
    else{
        randRtorRs = rand()%(0b10); //0/1
        if(randRtorRs){
            LW2_b_str = "10001100000" + Rt_b_str + "0000000000000100";
        }
        else{
            LW2_b_str = "10001100000" + Rt_b_str + "0000000000000000";
        }
    }
    
    ADDIUB_b_str = "00100100010000100001000100010001";
    JR_b_str = std::bitset<32>(8).to_string();
    
    vector_b_str.push_back(LW2_b_str);
    vector_b_str.push_back(ADDIUB_b_str);
    vector_b_str.push_back(instr_b_str);
    vector_b_str.push_back(ADDIUB_b_str);
    vector_b_str.push_back(ADDIUB_b_str);
    vector_b_str.push_back(JR_b_str);


    if (branch){
        instr_back_str = construct_instruction(instr_b_str_gap, Rs_b_str, Rt_b_str, Rd_b_str, Branch2_b_str, Sa_b_str, Target_b_str, rd_or_rt);
        
        // if offset = 0,1,2: no blank line
        // if offset = 3: 1 blank line
        // if offset = n: n-2 blank lines
        // branch     branch PC
        //            addiu
        //            addiu
        //            00000
        //            00000
        //            addiu (PC + offset1*4 +4 + offset2 * 4 + 4 = PC+(offset1+offset2)*4+8)
        //            jr0
        //            ADDIU
        //            00000000  
        //             8 < (offset1+offset2)*4+8) < (offset1 * 4 + 4) - 16
        //             0<offset1+offset2    offset2 < -5 offset1 > -offset2 + 1
        //            addiu     
        //            branch (PC + offset1 * 4 + 4)
        //            addiu

        // branch with link
        //            LW LW ADDIU BRANCH ADDIU ADDIU JR0 0 ADDIU JR31 ADDIU JR0
                   
        if (randBJForward >=3){
            for (int i=0; i<randBJForward-3; i++){

                if((i == randBJForward + randBranchBack + 2 ) && (!branch_AL)){
                    //addiu
                    vector_b_str.push_back(ADDIUB_b_str);
                }
                else if ((i == randBJForward + randBranchBack + 3) && (!branch_AL)){
                    vector_b_str.push_back(JR_b_str);
                }
                else if ((i == randBJForward + randBranchBack + 4) && (!branch_AL)){
                    vector_b_str.push_back(ADDIUB_b_str);
                }
                else{
                    vector_b_str.push_back("00000000000000000000000000000000");
                }
            }
            //addiu
            vector_b_str.push_back(ADDIUB_b_str);
            if (branch_AL){
                // JR $31
                vector_b_str.push_back("00000011111000000000000000001000");
            }
            else{
                //branch_back - negative offset
                vector_b_str.push_back(instr_back_str);
            }
            //addiu
            vector_b_str.push_back(ADDIUB_b_str);
        }
        
    }
    else if (jump_itype){
        // not testing jumping back -> target >= 7
        // target = 7: no blank line
        // target = 8: 1 blank line
        // target = n: n-7 blank lines
        if (randTarget >=7){
            for (int i=0; i<randTarget-7; i++){
                vector_b_str.push_back("00000000000000000000000000000000");
            }
        }
    }
    else if (jump_rtype){
        // not testing jumping back -> target >= 8
        // target = 8: no blank line
        // target = 9: 1 blank line
        // target = n: n-8 blank lines

        target = randNum/4;
        if (target >=8){
            for (int i=0; i<target-8; i++){
                vector_b_str.push_back("00000000000000000000000000000000");
            }
        }
    }

    if (jump_AL && (jump_rtype||jump_itype)){
        //addiu
        vector_b_str.push_back(ADDIUB_b_str);
        
        // JR $31
        vector_b_str.push_back("00000011111000000000000000001000");
        
        //addiu
        vector_b_str.push_back(ADDIUB_b_str);
    }
    
    vector_b_str.push_back(JR_b_str);
    vector_h_str = binStr_to_hexStr(vector_b_str); 
    return vector_h_str;
}




vector<string> generate_instruction_load_store(string instruction_name){
/*------------------------------------------------ Store--------------------------------------------------------------*/
//LW rt mem[0]; used as rt
//ADDIU rt = $0 + immediate (range 0-32)  used as rs
//if SW:
//  SW rt (offset*4)+(rs*4)  offset: range(range 0-32)
//if SB
//  SB rt offset+(rs*4)  offset: range(range 0-128)
//if SH:
//  SH rt (offset*2)+(rs*4)  offset: range(range 0-64)
//LW $2 (offset*4)+(rs*4) the same as above value 
    string LW1_b_str, ADDIU_b_str, Rs_b_str, Rt_b_str , S_b_str, L_b_str,Imm_b_str,Offset_b_str,Offset_b_half;
    vector<string> vector_b_str, vector_h_str;
    int randRs, randRt, randImm, randOffset, randByte;
    randRs = 1+rand()%(0b11111); // 1-11111
    randRt = 1+rand()%(0b11111); // 1-11111
    randImm = (rand()%(0b100001))*4; //0-100000
    randOffset = rand()%(0b100); //0-3

    Rs_b_str = std::bitset<5>(randRs).to_string();
    Rt_b_str = std::bitset<5>(randRt).to_string();
    Imm_b_str = std::bitset<16>(randImm).to_string();
    Offset_b_str = std::bitset<16>(randOffset).to_string();
    Offset_b_half = std::bitset<16>((randOffset/2)*2).to_string();

    LW1_b_str = "10001100000" + Rt_b_str + "0000000000000000";
    vector_b_str.push_back(LW1_b_str);
    ADDIU_b_str = "00100100000" + Rs_b_str + Imm_b_str; 
    //the content of rs being used must be divisible by 4
    vector_b_str.push_back(ADDIU_b_str);
    if(instruction_name == "sw" || instruction_name == "sb" || instruction_name == "sh"){
        if(instruction_name == "sw"){
            S_b_str = "101011" + Rs_b_str + Rt_b_str + "0000000000000000";
        }
        else if(instruction_name == "sb"){
            S_b_str = "101000" + Rs_b_str + Rt_b_str +  Offset_b_str ;
        }
        else if(instruction_name == "sh"){
            S_b_str = "101001" + Rs_b_str + Rt_b_str +  Offset_b_half;
        }
        vector_b_str.push_back(S_b_str); 
        L_b_str = "100011" + Rs_b_str + "00010" + "0000000000000000";
        vector_b_str.push_back(L_b_str); 
    }
/*------------------------------------------------ Load --------------------------------------------------------------*/
//LW rt mem[0]; used as rt
//ADDIU rt = $0 + immediate (range 0-32)  used as rs for SW 
//SW rt 0(rs*4)  
//if LW:
//LW $2 0(rs*4) the same value as LW
//if LB LBU
//LB $2 offset(rs*4) offset : range(0, 3)
//if LH LHU:
//LH $2 (offset*2)(rs*4) offset : range (0,1)
    else {
        S_b_str = "101011" + Rs_b_str + Rt_b_str + "0000000000000000";
        vector_b_str.push_back(S_b_str);
        
        if(instruction_name == "lw"){
            L_b_str = "100011" + Rs_b_str + "00010" + "0000000000000000";
        }
        else if(instruction_name == "lb"){
            L_b_str = "100000" + Rs_b_str + "00010" + Offset_b_str;
        }
        else if(instruction_name == "lbu"){
            L_b_str = "100100" + Rs_b_str + "00010" + Offset_b_str;
        }
        else if(instruction_name == "lh"){
            L_b_str = "100001" + Rs_b_str + "00010" + Offset_b_half;
        } 
        else if(instruction_name == "lhu"){
            L_b_str = "100101" + Rs_b_str + "00010" + Offset_b_half;
        }
        else if(instruction_name == "lwl"){
            L_b_str = "100010" + Rs_b_str + "00010" + Offset_b_str;
        }
        else if(instruction_name == "lwr"){
            L_b_str = "100110" + Rs_b_str + "00010" + Offset_b_str;
        }
        vector_b_str.push_back(L_b_str);
    }
    vector_b_str.push_back(std::bitset<32>(8).to_string());
    vector_h_str = binStr_to_hexStr(vector_b_str); 
    return vector_h_str;
}

std::vector<std::string> generate_instruction(std::string instr_b_str_gap, std::string in){
    std::vector <std::string> instruction_set;
    if (in=="sb" || in=="sw" || in=="sh"||in.substr(0,2)=="lb" || in.substr(0,2)=="lh"||in.substr(0,2)=="lw"){
        instruction_set = generate_instruction_load_store(in);
    }
    else if (in[0]=='b' || in[0]=='j'){
        instruction_set = generate_instruction_jump_branch(instr_b_str_gap, in);
    }
    else{
        instruction_set = generate_instruction_general(instr_b_str_gap, in);
    }
    return instruction_set;
}

int main () {
  
    // seed for the random number generator
    srand((unsigned int)time(NULL));
    // int randNum = rand()%(max-min + 1) + min; include min&max
        
    int total_test = 20;

    vector<string> data;
    vector<string> data_big_endian;
    string filename_data;
    string filename_instr;
    string machine_filename;

    vector<string> instr_vector_h_str;
    vector<string> instr_big_endian;
    vector<string> instr_vector_b_str;
    vector<string> machine_code;

    string instr_name;
    string dir1;
    string dir2;
    string instr_b_str_orig;

    vector<vector<string> > instructions = read_file("./test/cpp_utils/instructions_format.txt");
    vector<vector<string> > machine_code_sum;
    // loop through instructions
    for (int i=0; i<instructions.size();i++){
        instr_name = instructions[i][0];
        instr_b_str_orig = instructions[i][1];

        int test_no = 1;
        machine_filename = "./test/0-assembly/AUTO_"+instr_name+ ".txt";
        // produce multiple test cases
        for (int i=0; i<total_test; i++){

            // cout << "Test " << i+1 << endl;

            // Data
            data = generate_data(instr_name); 
            data_big_endian = big_endian_conversion(data);
            dir1 = "./test/1-hex/mem_1/AUTO_"+ instr_name;
            filename_data =  dir1 +"/"+ instr_name + "_" +to_string(test_no)+".txt";
            write_file(data_big_endian, filename_data, dir1);

            // Instruction
            instr_vector_h_str = generate_instruction(instr_b_str_orig, instr_name);
            instr_big_endian = big_endian_conversion(instr_vector_h_str);
            dir2 = "./test/1-hex/mem_2/AUTO_"+ instr_name;
            filename_instr = dir2 +"/"+ instr_name + "_" +to_string(test_no)+".txt";
            write_file(instr_big_endian, filename_instr, dir2);
            
            // Write Machine_Code
            machine_code = MIPS_Disassembler(instr_vector_h_str);
            machine_code_sum.push_back(machine_code);
            // reset
            instr_vector_b_str.clear();
            instr_vector_h_str.clear();
            //machine_code.clear();
            test_no += 1;
        }
        
        disassembler_write_file(machine_code_sum,machine_filename);
        machine_code_sum.clear();
    }
}