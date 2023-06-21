
#ifndef MIPS_hpp
#define MIPS_hpp

#include <cstdint>
#include <string>
#include <vector>
#include <fstream>
//transfer the content in .txt file to vector<string>
std::vector<std::uint32_t> mips_read(std::string &src);

//simulate the function of a mips, generate reference register_v0 value.
std::uint32_t MIPS_simulate(std::uint32_t *mem_1, std::uint32_t *mem_2);

// divide the total memory into 2 parts, and choose the content according to the index.
std::int32_t read_from_mem(std::uint32_t index, uint32_t *mem_1,  uint32_t *mem_2);

// dicide the total memory into 2 parts, choose which one to write into, and then write to the corresponding memory
void write_to_mem(std::uint32_t index, uint32_t *mem_1, uint32_t *mem_2, uint32_t write_data);

std::string to_hex4(uint32_t x);
// disassemble machine code
std::vector<std::string>MIPS_Disassembler(std::vector<std::string> hex_code);

void disassembler_write_file(std::vector< std::vector<std::string> > machine_code, std::string filename);
#endif