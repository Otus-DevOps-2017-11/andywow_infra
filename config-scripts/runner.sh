#!/bin/bash
# Functions for script execution

# Execute pack of commands
function execute_cmd_list {
    local filename=$1;
    local current_dir=$(realpath $(dirname $0))
    if [[ ! -f "$filename" ]]; then
        cmdlist_url="$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/cmdlist -H 'Metadata-Flavor: Google')"
        wget -O "/tmp/startup.txt" "$cmdlist_url"
        if [[ "$?" != 0 ]]; then
            echo "Command list file: $filename doest not exists"
            return 1
        fi
    filename="/tmp/startup.txt"
    fi
    cat $filename
    while IFS= read cmd && [[ -n "$cmd" ]]; do
        echo "Executing $cmd"
        eval "$cmd"
        local rc=$?
        if [[ "$rc" != 0 ]]; then
            echo "Command <$cmd> failed. Installation stopped"
            return 1
        fi
    done <<< "$(sed ':a;N;$!ba;s/\\\s\n//g' $filename)"
    # back to current directory
    cd $current_dir
    return 0
}

execute_cmd_list $1
exit $?

