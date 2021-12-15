#!/bin/bash

echo "Usage: ./local-test.sh [/bin/bash or other container command override]"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

. local-test-vars.env

# This script will mount this repo to this path within the container, so the container can pick up on code changes in realtime
# Change this to wherever the main Ruby code is copied
CONTAINER_MOUNT_PATH="/root/project"

docker build -t wcl-cms-api:local -f Dockerfile .
docker run \
-v ${DIR}:${CONTAINER_MOUNT_PATH} \
-it --rm \
--env DEBUG_ON="${DEBUG_ON}" \
--env SOME_STATIC_VARIABLE="${SOME_STATIC_VARIABLE}" \
--env SOME_SECRET_API_KEY="${SOME_SECRET_API_KEY}" \
wcl-cms-api:local $@