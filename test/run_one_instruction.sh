#!/bin/bash
set -eou pipefail
INSTRUCTION="$1"
DIRECTORY="$2"

TESTCASES="test/1-hex/mem_1/AUTO_${INSTRUCTION}/*.txt"
for i in ${TESTCASES} ; do
    TESTCASE=$(basename ${i} .txt)
    ./test/run_one_testcase.sh ${INSTRUCTION} ${TESTCASE} ${DIRECTORY}
    rm ./test/3-output/*.out-lines
    rm ./test/3-output/*.stdout
done
