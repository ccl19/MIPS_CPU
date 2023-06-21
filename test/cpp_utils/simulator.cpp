#include "MIPS.hpp"
#include <iostream>
#include <sstream>
#include <cassert>
#include <iostream>
#include <cstdint>
#include <string>
#include <vector>
#include <fstream>
#include <cmath>

int main(int argc, char** argv)
{   
    std::string src1, src2;
    uint32_t v0;
    src1 = argv[1]; 
    src2 = argv[2];
    std::vector<std::uint32_t> mem_1=mips_read(src1);
    std::vector<std::uint32_t> mem_2=mips_read(src2);


    // Simulate it
    v0=MIPS_simulate(&mem_1[0],&mem_2[0]);
    std::cout << v0 << std::endl;
    return v0;
}
