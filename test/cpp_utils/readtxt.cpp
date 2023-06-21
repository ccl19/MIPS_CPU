#include "MIPS.hpp"
#include <sstream>
#include <cassert>
#include <iostream>
#include <cstdint>
#include <string>
#include <vector>
#include <fstream>
#include <cmath>



std::vector<std::uint32_t> mips_read(std::string &src)
//read in from hex.txt file; make sure that the format is correct; convert string to integer
{   
    std::ifstream f;
    f.open(src);
    std::vector<std::uint32_t> memory;
    // 4 bytes 4*8 = uint32_t
    int num=1;
    std::string line;
    while(getline(f, line) ){
        assert(num <= 65536);

        // Trim initial space
        while(line.size()>0 && isspace(line.front())){
            line = line.substr(1); // Remove first characters
        }

        // Trim trailing space
        while(line.size()>0 && isspace(line.back())){
            line.pop_back();
        }

        if(line.size()!=8){
            std::cerr<<"Line "<<num<<" : expected exactly eight characterss, got '"<<line<<'"'<<std::endl;
            exit(1);
        }
        for(int i=0; i<line.size(); i++){
            if(!isxdigit(line[i])){
                std::cerr<<"Line "<<num<<" : expected only hexadecimal digits, got '"<<line[i]<<'"'<<std::endl;
                exit(1);
            }
        }
        unsigned x=stoull(line, nullptr, 16); //16 means integer base is hexadecimal
        assert(x<std::pow(2,32));
        memory.push_back(x);
        num++;
    }
    memory.resize(65536, 0);

    return memory;
}
