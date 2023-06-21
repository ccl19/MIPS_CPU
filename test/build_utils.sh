#!/bin/bash
#set -eou pipefail
echo "Building MIPS utils" > /dev/stderr
mkdir -p ./test/bin

mips_src="test/cpp_utils/MIPS_simulate.cpp test/cpp_utils/memory_interface.cpp test/cpp_utils/readtxt.cpp test/cpp_utils/Disassembler.cpp"
g++ -o test/bin/generator test/cpp_utils/instruction_generator.cpp ${mips_src} 
g++ -o test/bin/simulator test/cpp_utils/simulator.cpp ${mips_src} 

test/bin/generator

echo "Complete Compiling" > /dev/stderr


