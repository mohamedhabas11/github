#!/bin/sh

# {{ ansible_managed }}

cmds="$@"
set -- $SSH_ORIGINAL_COMMAND
for allowed in $cmds; do
    if [ "$allowed" = "$1" ]; then
        exec "$@"
    fi
done
    echo you may only $cmds, denied: $@ >&2
exit 1
