#!/bin/bash
set -eou pipefail

TESTCASE="$1"
DIRECTORY="$2"

iverilog -g 2012\
    -s mips_cpu_pipeline_tb \
    -o test/2-simulator/mips_cpu_pipeline_tb_${TESTCASE} \
    -P mips_cpu_pipeline_tb.MEM_1=\"./test/1-hex/mem_1/general/${TESTCASE}.txt\" \
    -P mips_cpu_pipeline_tb.MEM_2=\"./test/1-hex/mem_2/general/${TESTCASE}.txt\" \
    ./${DIRECTORY}/mips_cpu_*.v \
    ./test/src/mips_cpu_*.v \
    ./${DIRECTORY}/mips_cpu_pipeline/*.v
set +e
./test/2-simulator/mips_cpu_pipeline_tb_${TESTCASE} > ./test/3-output/mips_cpu_pipeline_tb_${TESTCASE}.stdout

RESULT=$?
#close the automatic script failure and store in Result
set -e
#if return failure code, exit
if [[ "${RESULT}" -ne 0 ]] ; then
    echo " ${TESTCASE} general FAIL"
    exit
fi

# This is the prefix for simulation output lines containing result of OUT instruction
PATTERN="CPU MIPS : V0 = "
NOTHING=""
# Use "grep" to look only for lines containing PATTERN
set +e
grep "${PATTERN}" ./test/3-output/mips_cpu_pipeline_tb_${TESTCASE}.stdout > ./test/3-output/mips_cpu_pipeline_tb_${TESTCASE}.out-lines
set -e
sed -e "s/${PATTERN}/${NOTHING}/g" ./test/3-output/mips_cpu_pipeline_tb_${TESTCASE}.out-lines > ./test/3-output/mips_cpu_pipeline_tb_${TESTCASE}.out
# s/: substitution operator
# /g (global replacement) specifies the sed command to replace all the occurrences of the string in the line.
# Use "sed" to replace "CPU MIPS : V0 = " in every line of file "test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.out-lines"  with nothing and store it in " test/3-output/CPU_MU0_${VARIANT}_tb_${TESTCASE}.out"

set +e
./test/bin/simulator ./test/1-hex/mem_1/general/${TESTCASE}.txt ./test/1-hex/mem_2/general/${TESTCASE}.txt > ./test/4-reference/${TESTCASE}.out
#test/1-hex/mem_2/testcase1.txt  utils/MIPS.hpp
set -e

set +e
diff -w ./test/4-reference/${TESTCASE}.out ./test/3-output/mips_cpu_pipeline_tb_${TESTCASE}.out
# diff is used to compare the result of 2 files (in this case compare the output of our built mu0 and the simulator)
# -w means writable
RESULT=$?
set -e

# Based on whether differences were found, either pass or fail
if [[ "${RESULT}" -ne 0 ]] ; then
    echo "${TESTCASE} general Fail" 
    echo "${TESTCASE} general Fail" >> test/RESULT_PIPELINE.out
    exit 1
else
    echo "${TESTCASE} general Pass" 
    echo "${TESTCASE} general Pass" >> test/RESULT_PIPELINE.out
    exit 0
fi
