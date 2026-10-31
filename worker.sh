#!/bin/sh
set -eu

DATA_DIR=${DATA_DIR:-/shared}
LOCK_FILE="$DATA_DIR/.lock"

mkdir -p "$DATA_DIR"

CONTAINER_ID=$(cat /proc/sys/kernel/random/uuid)
counter=0

exec 9>"$LOCK_FILE"

echo "Worker started: $CONTAINER_ID"

while :
do
    flock -x 9

    number=1

    while :
    do
        filename=$(printf '%03d' "$number")
        filepath="$DATA_DIR/$filename"

        if [ ! -e "$filepath" ]; then
            if (set -C; : > "$filepath") 2>/dev/null; then
                counter=$((counter + 1))
                printf '%s\n%s\n' "$CONTAINER_ID" "$counter" > "$filepath"
                break
            fi
        fi

        number=$((number + 1))
    done

    flock -u 9

    echo "Created $filename (worker=$CONTAINER_ID, count=$counter)"
    sleep 1
    rm -f "$filepath"
    echo "Deleted $filename"
    sleep 1
done
