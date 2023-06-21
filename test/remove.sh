
#!/bin/bash
# This script is to clean the previous result

set -euo pipefail

rm -r ./test/bin
rm -r ./test/0-assembly/AUTO_*
rm -r ./test/1-hex/mem_1/AUTO_*
rm -r ./test/1-hex/mem_2/AUTO_* 
rm ./test/2-simulator/*
rm ./test/3-output/*
rm ./test/4-reference/*


