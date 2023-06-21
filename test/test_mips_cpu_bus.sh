#!/bin/bash
source_directory="$1";
instruction="${2:-1}";
start=$(date +%s)
./test/remove.sh
rm ./test/RESULT.out
./test/build_utils.sh
set -eou pipefail

if [ "${instruction}" == "1" ] ; then
   
    INSTRUCTIONS="test/1-hex/mem_1/AUTO_*"
    GENERAL_TESTCASES="test/1-hex/mem_1/general/*"
    Word="AUTO_"
    >&2 echo "Start to do Random Test"
    for i in ${INSTRUCTIONS} ; do
        # Extract just the testcase name from the filename. See `man basename` for what this command does.
        base=$(basename ${i})
        INSTRUCTION=${base//${Word}/}
        #echo "${INSTRUCTION}:" >> RESULT.out
        set +e
        ./test/run_one_instruction.sh ${INSTRUCTION} ${source_directory}
        result=$?
        set -e
        if [[ "${result}" -ne 0 ]] ; then
            >&2 echo "${INSTRUCTION}: Fail"
        else
            >&2 echo "${INSTRUCTION}: Pass"
        fi
    done
    >&2 echo "Complete"

    #now we consider the general testcase.
    >&2 echo "Start to do General Test"
    for i in ${GENERAL_TESTCASES} ; do
        # Extract just the testcase name from the filename. See `man basename` for what this command does.
        GENERAL_TESTCASE=$(basename ${i} .txt)
        set +e
        ./test/run_one_generalcase.sh ${GENERAL_TESTCASE} ${source_directory}
        result=$?
        set -e
        if [[ "${result}" -ne 0 ]] ; then
            >&2 echo "${GENERAL_TESTCASE}: Fail"
        else
            >&2 echo "${GENERAL_TESTCASE}: Pass"
        fi
    done

else
./test/run_one_instruction.sh ${instruction} ${source_directory} 
fi


>&2 echo "All Tests Completed"
>&2 echo "Detailed test result for all testcases are stored in RESULT.out"
end=$(date +%s)
runtime=$((end-start))
>&2 echo "Execution Time = ${runtime} s"
