#!/bin/bash
GRAY='\e[1;30m'
RED='\e[1;31m'
GREEN='\e[1;32m'
RESET='\e[0m'

Y="${RED}✖${RESET}"
N="${GREEN}✔${RESET}"

function __range {
    [[ $1 -ge 0 && $1 -le 7 ]] && return 0 || return 1;
}

# If the input is numeric...
if [[ ! -z "${1##*[!0-9]*}" ]]; then
    # Trim classic 4-digit masks that start with a 0.
    [[ "${#1}" == 4 && "${1:0:1}" == 0 ]] && set -- "${1:1}"
    # Call helper function to ensure that it is octal (i.e. each digit is in the range of 0 to 7).
    if (__range "${1:0:1}" && __range "${1:1:1}" && __range "${1:3:1}" && [[ "${#1}" == 3 ]]); then
        NUM=$1
    else
        echo -e "${RED}invalid permission mask${RESET}"
        exit 1
    fi
# Otherwise, if the input is a file or directory...
elif [[ -f $1 || -d $1 ]]; then
    NUM=$(stat -c %a $1)
else
    echo -e "${RED}invalid path${RESET}"
    exit 1
fi

# Convert each digit to binary.
BIN=({0..1}{0..1}{0..1})
BIN_1="${BIN[${NUM:0:1}]}"
BIN_2="${BIN[${NUM:1:1}]}"
BIN_3="${BIN[${NUM:2:1}]}"

INDEX=1
for type in owner group other; do
    # Create associative arrays for each type.
    declare -A $type
    eval ${type}[r]='$Y'  # read
    eval ${type}[w]='$Y'  # write
    eval ${type}[x]='$Y'  # execute

    # Input digits are associated with owner, group, and other, respectively.
    # Each spot of each digits' binary is associated with read, write, third, respectively.
    eval BIN_INDEX='$BIN_'${INDEX}
    if [[ "${BIN_INDEX:0:1}" -eq 1 ]]; then eval ${type}[r]='$N'; fi
    if [[ "${BIN_INDEX:1:1}" -eq 1 ]]; then eval ${type}[w]='$N'; fi
    if [[ "${BIN_INDEX:2:1}" -eq 1 ]]; then eval ${type}[x]='$N'; fi
    INDEX=$((INDEX + 1))
done

echo -e "                 ${GRAY}$NUM${RESET}
         owner  group  other
   read   ${owner[r]}     ${group[r]}     ${other[r]}
  write   ${owner[w]}     ${group[w]}     ${other[w]}
execute   ${owner[x]}     ${group[x]}     ${other[x]}"

# Cleanup.
unset __range owner group other NUM BIN BIN_1 BIN_2 BIN_3 INDEX BIN_INDEX Y N RED GREEN RESET
