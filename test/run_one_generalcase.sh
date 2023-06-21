#!/bin/bash
set -eou pipefail

TESTCASE="$1"
DIRECTORY="$2"

iverilog -g 2012\
    -s mips_cpu_tb \
    -o ./test/2-simulator/mips_cpu_tb_${TESTCASE}\
    -P mips_cpu_tb.MEM_1=\"./test/1-hex/mem_1/general/${TESTCASE}.txt\" \
    -P mips_cpu_tb.MEM_2=\"./test/1-hex/mem_2/general/${TESTCASE}.txt\" \
    ./${DIRECTORY}/mips_cpu_*.v \
    ./test/src/mips_cpu_*.v \
    ./${DIRECTORY}/mips_cpu/*.v

set +e
./test/2-simulator/mips_cpu_tb_${TESTCASE} > ./test/3-output/mips_cpu_tb_${TESTCASE}.stdout

RESULT=$?

set -e

if [[ "${RESULT}" -ne 0 ]] ; then
    echo " ${TESTCASE} general Fail"
    exit
fi

PATTERN="CPU MIPS : V0 = "
NOTHING=""
set +e
grep "${PATTERN}" ./test/3-output/mips_cpu_tb_${TESTCASE}.stdout > ./test/3-output/mips_cpu_tb_${TESTCASE}.out-lines
set -e
sed -e "s/${PATTERN}/${NOTHING}/g" ./test/3-output/mips_cpu_tb_${TESTCASE}.out-lines > ./test/3-output/mips_cpu_tb_${TESTCASE}.out

set +e
./test/bin/simulator ./test/1-hex/mem_1/general/${TESTCASE}.txt ./test/1-hex/mem_2/general/${TESTCASE}.txt > ./test/4-reference/${TESTCASE}.out
set -e

set +e
diff -w ./test/4-reference/${TESTCASE}.out ./test/3-output/mips_cpu_tb_${TESTCASE}.out

RESULT=$?
set -e

if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE} general Fail"
   echo "${TESTCASE} general Fail" >> test/RESULT.out
   exit 1
else
   echo "${TESTCASE} general Pass"
   echo "${TESTCASE} general Pass" >> test/RESULT.out
   exit 0
fi
