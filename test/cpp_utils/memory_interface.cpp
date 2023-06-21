#include<iostream>
#include<vector>
#include<string>
#include "MIPS.hpp"

//mem_1 stores data from 0 to 65535 address; mem_2 stores data from 0xBFC00000 to 0xBFC00000+2^16-1 address
int32_t read_from_mem(std::uint32_t index, uint32_t *mem_1,  uint32_t *mem_2){
    if (index<65536){
        return mem_1[index];
    }
    else if (3217031168 <= index  && index< 3217031168+65536){
        return mem_2[index-3217031168];
    }
    else {
        std::cerr << "Read memory index out of range." <<index<< std::endl;
        return 0;
    }
}





void write_to_mem(std::uint32_t index, uint32_t *mem_1, uint32_t *mem_2, uint32_t write_data){

    if(index < 65536){
        if(index % 4 == 0){
            mem_1[index] = write_data;
        }
    }
    else if ( 3217031168 <= index && index < 3217031168+65536){
        if(index % 4 == 0){
            mem_2[index-3217031168] = write_data;
        }
    }
    else {
        std::cerr << "Write memory index out of range." << std::endl;
    }

}

