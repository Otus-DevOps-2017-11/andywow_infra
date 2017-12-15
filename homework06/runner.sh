#!/bin/bash
# Functions for script execution

# Execute pack of commands
function execute_cmd_list {
    filename=$1;
    if [[ -f "$filename" ]]; then
        echo "Command list file: $filename doest not exists"
        return 1
    fi
    while IFS=";\n" read cmd && [[ -n "$cmd" ]]; do
        $cmd
        local rc=$?
        if [[ "$rc" != 0 ]]; then
            echo "Command <$cmd> failed. Installation stopped"
            return 1
        fi
    done < "$filename"
    return 0
}


execute_cmd_list $1
exit $?
