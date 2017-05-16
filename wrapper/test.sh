#!/bin/bash

#adapted from http://eradman.com/posts/ut-shell-scripts.html

typeset -i tests_run=0

function try { this="$1"; }

trap 'printf "$0: exit code $? on line $LINENO\nFAIL: $this\n"; exit 1' ERR

#check returned value is what is expected
function assert {
        let tests_run+=1
        [ "$1" = "$2" ] && { echo -n "."; return; }
        printf "\nFAIL: $this\n'$1' != '$2'\n"; exit 1
}

#check the script fails as expected
function assert_fail {
        let tests_run+=1
        [ "${1//$2}" != "${1}" ] && { echo -n "."; return; }
        printf "\nFAIL: $this\n '$1' exit code = 0\n"; exit 1
}

#check we are in an empty directory to avoid deleting files
if [ "`ls`" != "" ]
  then
    echo "ERROR: Run this script in an empty directory!!!!!"
    exit 1;
fi

try "pattern file is required in adaptors removal mode"
assert_fail "`../wrapper.sh 2>&1 >/dev/null`" "Pattern file is required to remove adaptors."

echo; echo "PASS: $tests_run tests run"
