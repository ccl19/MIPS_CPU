#include "MIPS.hpp"
#include <cassert>
#include <iostream>
#include <vector>
#include <string>
//everything in registers and memory is unsigned

std::uint32_t endianness_convert (uint32_t input){
    return (((input & 0xff)<<24)+((input & 0xff00)<<8) +((input & 0xff0000)>>8)+((input & 0xff000000)>>24));
}

std::string to_hex4(uint32_t x)
{
    char tmp[16]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
    std::string res;
    res.push_back(tmp[(x>>28)&0xF]);
    res.push_back(tmp[(x>>24)&0xF]);
    res.push_back(tmp[(x>>20)&0xF]);
    res.push_back(tmp[(x>>16)&0xF]);
    res.push_back(tmp[(x>>12)&0xF]);
    res.push_back(tmp[(x>>8)&0xF]);
    res.push_back(tmp[(x>>4)&0xF]);
    res.push_back(tmp[(x>>0)&0xF]);
    return res;
}

const char* hex_char_to_bin(char c)
{
    switch(c)
    {
        case '0': return "0000";
        case '1': return "0001";
        case '2': return "0010";
        case '3': return "0011";
        case '4': return "0100";
        case '5': return "0101";
        case '6': return "0110";
        case '7': return "0111";
        case '8': return "1000";
        case '9': return "1001";
        case 'A': return "1010";
        case 'B': return "1011";
        case 'C': return "1100";
        case 'D': return "1101";
        case 'E': return "1110";
        case 'F': return "1111";
    }
    return "error";
}

std::string hex_str_to_bin_str(const std::string& hex)
{
    // TODO use a loop from <algorithm> or smth
    std::string bin;
    for(unsigned i = 0; i != hex.length(); ++i)
       bin += hex_char_to_bin(hex[i]);
    return bin;
}

std::uint32_t load_val (uint16_t opcode, int byte_address, uint32_t load_data, int32_t reg_input){
    uint32_t converted_data;
    if (opcode == 0b100000){
        //LB
        if(byte_address == 0){
            if(load_data & 0x00000080){
                return((load_data & 0x000000FF) + 0xFFFFFF00);
            }
            else{
                return (load_data & 0x000000FF);
            }
        }
        else if(byte_address == 1){
            if(load_data & 0x00008000){
                return(((load_data & 0x0000FF00)>>8) + 0xFFFFFF00);
            }
            else{
                return ((load_data & 0x0000FF00)>>8);
            }
        }
        else if(byte_address == 2){
            if(load_data & 0x00800000){
                return(((load_data & 0x00FF0000)>>16) + 0xFFFFFF00);
            }
            else{
                return ((load_data & 0x00FF0000)>>16);
            }
        }
        else if(byte_address == 3){
            if(load_data & 0x80000000){
                return(((load_data & 0xFF000000)>>24) + 0xFFFFFF00);
            }
            else{
                return ((load_data & 0xFF000000)>>24);
            }
        }
        else {
            return 0;
        }
    }
    else if (opcode == 0b100100){
        //LBU
        if(byte_address == 0){
            return(load_data & 0x000000FF);
        }
        else if(byte_address == 1){
            return((load_data & 0x0000FF00) >> 8);
        }
        else if(byte_address == 2){
            return((load_data & 0x00FF0000) >> 16);
        }
        else if(byte_address == 3){
            return((load_data & 0xFF000000) >> 24);
        }
        else {
            return 0;
        }
    }

    else if (opcode == 0b100001){
        //LH
        //std::cout<<"convert_data" << converted_data<< std::endl;
        //std::cout << "byte_address" <<byte_address<<std::endl;
        converted_data = endianness_convert(load_data);
        if(byte_address == 0){
            if((converted_data & 0x80000000) == 0x80000000){
                return(((converted_data & 0xFFFF0000)>>16) + 0xFFFF0000);
            }
            else{
                return ((converted_data & 0xFFFF0000) >> 16);
            }
        }        
        else if(byte_address == 2){
            if((converted_data & 0x00008000) == 0x00008000){
                return((converted_data & 0x0000FFFF) + 0xFFFF0000);
            }
            else{
                return (converted_data & 0x0000FFFF);
            }
        }
        else {
            return 0;
        }
        
    }

    else if (opcode == 0b100101){
        //LHU
        converted_data = endianness_convert(load_data);
        if(byte_address == 0){
            return((converted_data & 0xFFFF0000) >> 16);
        }
        else if(byte_address == 2){
            return (converted_data & 0x0000FFFF);
        }
        else {
            return 0;
        }
    }
    else if (opcode == 0b100011){
        //LW
        converted_data = endianness_convert(load_data);
        if(byte_address == 0){
            return converted_data;
        }
        else {
            return 0;
        }
    }
    else if (opcode == 0b100010){
        //LWL
        converted_data = endianness_convert(load_data);
        if(byte_address == 0){
            return converted_data;
        }
        else if(byte_address == 1){
            return ((converted_data & 0x00FFFFFF)<<8) + (reg_input & 0x000000FF);
        }
        else if(byte_address == 2){
            return ((converted_data & 0x0000FFFF)<<16) + (reg_input & 0x0000FFFF);
        }
        else if(byte_address == 3){
            return ((converted_data & 0x000000FF)<<24) + (reg_input & 0x00FFFFFF);
        }
        else{
            return reg_input;
        }
    }
    else if (opcode == 0b100110){
        //LWR
        converted_data = endianness_convert(load_data);
        if(byte_address == 0){
            return (reg_input & 0xFFFFFF00) + ((converted_data & 0xFF000000)>>24);
        }
        else if(byte_address == 1){
            return (reg_input & 0xFFFF0000) + ((converted_data & 0xFFFF0000)>>16);
        }
        else if(byte_address == 2){
            return (reg_input & 0xFF000000) + ((converted_data & 0xFFFFFF00)>>8);
        }
        else if(byte_address == 3){
            return converted_data;
        }
        else{
            return reg_input;
        }
    }
    else{
        return 0;
    }
}

std::uint32_t store_val(uint16_t opcode, int byte_address, uint32_t mem_data, int32_t reg_data){
    //SB
    // std::cout<<"hihi"<<reg_data<<std::endl;
    uint32_t reg_data_converted = endianness_convert(reg_data);
    if(opcode==0b101000){
        if(byte_address == 0){
            return (mem_data & 0xFFFFFF00) + ((reg_data_converted & 0xFF000000)>>24);

        } 
        else if(byte_address == 1){
            return (mem_data & 0xFFFF00FF) + ((reg_data_converted & 0xFF000000) >> 16);
        }
        else if(byte_address == 2){
            return (mem_data & 0xFF00FFFF) + ((reg_data_converted & 0xFF000000) >> 8);
        }
        else if(byte_address == 3){
            return (mem_data & 0x00FFFFFF) + (reg_data_converted & 0xFF000000);
        }
        else {
            return mem_data;
        }
    }
    else if(opcode == 0b101001){
        //SH
        if(byte_address == 0){
            return (mem_data & 0xFFFF0000) + ((reg_data_converted & 0xFFFF0000)>>16);
        }
        
        else if(byte_address == 2){
            return (mem_data & 0x0000FFFF) + (reg_data_converted & 0xFFFF0000);
        }
        else{
            return mem_data;
        }
        
    }
    else if(opcode == 0b101011){
        //SW
        //std::cout<<"SW"<<endianness_convert(reg_data)<<std::endl;
        return endianness_convert(reg_data);
    }
    else{
        return mem_data;
    }
    
}


std::uint32_t MIPS_simulate(uint32_t *mem_1, uint32_t *mem_2){
    std::uint32_t PC = 0xBFC00000;
    
    std::uint32_t V_0 = 0;
    //result
    std::vector<uint32_t> regfile(32, 0);
    //create 32 vectors with all values initialized to zero
    std::vector<uint64_t> hi_lo (2, 0);
    // hi_lo[1] is hi, and hi_lo[0] is low
    std::int64_t AC = 0;
    uint32_t tmp_str_mem_read;
    uint32_t tmp_str_mem_write;
    std::uint32_t tmp_val;
    int byte_address;

    int branch_delay = 0;
    uint32_t branch_jump_address;

    while(true){
    
        //stop until the stop instruction
        assert(PC < 4294967295);
        std::uint32_t instr = endianness_convert(read_from_mem(PC, mem_1, mem_2)); 
        //std::cout<<PC<<std::endl;
        // need to convert from string to hex
        // need a mips_is_instruction to verify it is an instruction
        std::uint16_t opcode = instr>>26; //std::stoul(instr.substr(0,6), 0, 16);
        //substr means start position is 0 and length is 6, different from the position of bit number.
        std::uint16_t funccode = instr & 0x000003F; 
        std::uint16_t rs = (instr & 0x03E00000)>>21; 
        std::uint16_t rt = (instr & 0x001F0000)>>16; 
        std::uint16_t rd = (instr & 0x0000F800)>>11;
        std::uint16_t immediate = (instr & 0x0000FFFF);
        std::uint16_t sa = (instr & 0x000007C0) >> 6;
        std::uint32_t target = instr & 0x03FFFFFF;
        std::int32_t signed_input_rs = static_cast<int32_t>(regfile[rs]);
        std::int32_t signed_input_rt = static_cast<int32_t>(regfile[rt]);
        std::int32_t signed_immediate = static_cast<int16_t>(immediate);
        std::uint32_t address_im_rs;
        address_im_rs = signed_immediate + regfile[rs];
        
        if(PC == 0){
            return regfile[2];
        }

        if(branch_delay){
            PC = branch_jump_address;
            branch_delay = 0;
        }

        if(opcode == 0){
            //r-type
            if(funccode == 0b100001){
                //ADDU
                regfile[rd] = regfile[rt] + regfile[rs];
            }
            else if(funccode == 0b100100){
                //AND
                regfile[rd] = regfile[rt] & regfile[rs];
            }
            else if(funccode == 0b100101){
                //OR
                regfile[rd] = regfile[rt] | regfile[rs];
            }
            else if(funccode == 0b101010){
                //SLT
                if(signed_input_rs < signed_input_rt){
                    regfile[rd] = 1;
                }
                else{
                    regfile[rd] = 0;
                }
            }
            else if(funccode == 0b101011){
                //SLTU
                if(regfile[rs] < regfile[rt]){
                    regfile[rd] = 1;
                }
                else{
                    regfile[rd] = 0;
                }
            }
            else if(funccode == 0b100011){
                //SUBU
                regfile[rd] = regfile[rs] - regfile[rt];
            }
            else if(funccode == 0b100110){
                //XOR
                regfile[rd] = regfile[rs] ^ regfile[rt];
            }

            else if(funccode == 0b000000){
                //SLL
                regfile[rd] = regfile[rt] << sa;
            }
            else if(funccode == 0b000100){
                //SLLV
                if(regfile[rs]>=32){
                    regfile[rd] = 0;
                }
                else{
                    regfile[rd] = regfile[rt] << regfile[rs];
                }
            }
            else if(funccode == 0b000011){
                //SRA signed arithmetic shift
                regfile[rd] = signed_input_rt >> sa;
            }
            else if(funccode == 0b000111){
                //SRAV signed arithmetic shift
                if (regfile[rs]>=32){
                    regfile[rd]=0;
                }
                else{
                    regfile[rd] = signed_input_rt >> regfile[rs];
                }
            }
            else if(funccode == 0b000010){
                //SRL 
                regfile[rd] = regfile[rt] >> sa;
            }
            else if(funccode == 0b000110){
                //SRLV
                if(regfile[rs]>=32){
                    regfile[rd] = 0;
                }
                else{
                    regfile[rd] = regfile[rt] >> regfile[rs];
                }
            }
            else if(funccode == 0b011010){
                //DIV
                hi_lo[1] = signed_input_rs % signed_input_rt;
                hi_lo[0] = signed_input_rs / signed_input_rt;
            }
            else if(funccode == 0b011011){
                //DIVU
                hi_lo[1] = regfile[rs] % regfile[rt];
                hi_lo[0] = regfile[rs] / regfile[rt];
            }
            else if(funccode == 0b010000){
                //MFHI
                regfile[rd] = (uint32_t)hi_lo[1];
            }
            else if(funccode == 0b010010){
                //MFLO
                regfile[rd] = (uint32_t)hi_lo[0];
            }
            else if(funccode == 0b010001){
                //MTHI
                hi_lo[1] = regfile[rs];
            }
            else if(funccode == 0b010011){
                //MTLO
                hi_lo[0] = regfile[rs];
            } 
            else if(funccode == 0b011000){
                //MULT
                AC =(std::int64_t)signed_input_rt * signed_input_rs;
                hi_lo[1] = (AC & 0xFFFFFFFF00000000) >> 32;
                hi_lo[0] = AC & 0xFFFFFFFF;
            }
            
            else if(funccode == 0b011001){
                //MULTU
                AC = (std::uint64_t) regfile[rt] * regfile[rs];
                hi_lo[1] = (AC & 0xFFFFFFFF00000000) >> 32;
                hi_lo[0] = AC & 0xFFFFFFFF;
            }
            
            else if(funccode == 0b001001){
                //JALR
                regfile[rd] = PC+8;
                branch_jump_address = regfile[rs] - 4;
                branch_delay = 1;
            }

            else if(funccode == 0b001000){
                //JR
                branch_jump_address = regfile[rs] - 4;
                branch_delay = 1;
            }
        }

        else if (opcode == 0b001001){
            //ADDIU
            regfile[rt] = signed_immediate + regfile[rs];
        }
        else if (opcode == 0b001100){
            //ANDI
            regfile[rt] = regfile[rs] & immediate;
        }
        else if  (opcode == 0b001111){
            //LUI
            regfile[rt] = immediate << 16; 
        }
        else if (opcode == 0b001101){
            //ORI
            regfile[rt] = regfile[rs] | immediate;
        }
        else if (opcode == 0b001010){
            //SLTI
            regfile[rt] = signed_input_rs < signed_immediate;
        }
        else if (opcode == 0b001011){
            //SLTIU
            regfile[rt] = regfile[rs] < (uint32_t) signed_immediate;
        }
        else if (opcode == 0b001110){
            //XORI
            regfile[rt] = regfile[rs] ^ immediate;
        }
        else if (opcode == 0b000100){
            //BEQ
            if (regfile[rs] == regfile[rt]){
                branch_jump_address = PC + signed_immediate * 4;
                branch_delay = 1;
            }
        }
        else if (opcode == 0b000001){
            //BGEZ
            if ((rt == 0b00001) & (signed_input_rs >= 0)){
                branch_jump_address = PC + signed_immediate * 4;
                branch_delay = 1;
            }
            //BGEZAL
            else if ((rt == 0b10001) & (signed_input_rs >= 0)){
                regfile[31] = PC+8;
                branch_jump_address = PC + signed_immediate * 4;
                //<<"branch_jump_address_BGEZAL"<<branch_jump_address<<std::endl;
                //std::cout<<"branch_jump_address_BGEZAL"<<signed_immediate<<std::endl;
                branch_delay = 1;
            }
            //BLTZ
            else if ((rt == 0b00000)& (signed_input_rs < 0)){
                branch_jump_address = PC + signed_immediate * 4;
                branch_delay = 1;
            }

            //BLTZAL
            else if ((rt == 0b10000) & (signed_input_rs < 0)){
                regfile[31] = PC+8;
                branch_jump_address = PC + signed_immediate * 4;
                branch_delay = 1;
            }
        }
        else if (opcode == 0b000111){
            //BGTZ
            if (signed_input_rs > 0){
                branch_jump_address = PC + signed_immediate * 4;
                branch_delay = 1;
            }
        }
        else if (opcode == 0b000110){
            //BLEZ
            if (signed_input_rs <= 0){
                branch_jump_address = PC + signed_immediate * 4;
                branch_delay = 1;
            }
            
        }
        else if (opcode == 0b000101){
            //BNE
            if (regfile[rs] != regfile[rt]){
                branch_jump_address = PC + signed_immediate * 4;
                branch_delay = 1;
            }
        }
        else if (opcode == 0b000010){
            //J target
            //std::cout<<"target"<<target<<std::endl;
            //std::cout<<"branch_jump"<<branch_jump_address<<std::endl;
            branch_jump_address = (PC & 0xF0000000) + (target<<2) - 4;
            branch_delay = 1;
        }
        else if (opcode == 0b000011){
            //JAL target
            regfile[31] = PC + 8;
            branch_jump_address = (PC & 0xF0000000) + (target<<2) - 4;
            branch_delay = 1;
        }


        //Memory Part
        else if(opcode == 0b100000 || opcode == 0b100100 || opcode == 0b100001 || opcode == 0b100101 || opcode == 0b100011 || opcode == 0b100010 || opcode == 0b100110){
            //load part
            byte_address = (immediate + regfile[rs])%4;
            regfile[rt] = load_val(opcode, byte_address, read_from_mem((address_im_rs - address_im_rs%4), mem_1, mem_2), regfile[rt]);
        }

        
        else if(opcode == 0b101000 || opcode == 0b101001 || opcode == 0b101011){
            //store part
            byte_address = (immediate + regfile[rs])%4;
            tmp_val = store_val(opcode, byte_address, read_from_mem((address_im_rs - address_im_rs%4), mem_1, mem_2), regfile[rt]);
            write_to_mem(address_im_rs - address_im_rs%4, mem_1, mem_2, tmp_val);
           
        }

        PC += 4;

    }
}

// int main(){
//     std::vector<std::string> v1;
//     std::vector<std::string> v2;
//     v1.push_back("00000000");
//     v1.push_back("00000001");
//     v1.push_back("00000002");
//     v1.push_back("00000003");
//     v1.push_back("00000004");
//     v1.push_back("00000006");
//     v1.push_back("00000006");
//     v1.push_back("00000007");
//     v2.push_back("00000000");
//     v2.push_back("00000001");
//     v2.push_back("00000002");
//     v2.push_back("00000003");
//     v2.push_back("00000004");
//     v2.push_back("00000006");
//     v2.push_back("00000006");
//     v2.push_back("00000007");
//     std::cout << MIPS_simulate(v1, v2);
// }