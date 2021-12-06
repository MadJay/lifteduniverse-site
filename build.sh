#!/bin/bash

# Go to script location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

repo_name=$(basename $PWD)
image_name="${repo_name}-build:local"

docker build -f .circleci/build.sh/Dockerfile  -t "$image_name" .

docker run -it --rm \
	-v $PWD:/project \
	-v ~/.ssh:/root/.ssh \
	-e HOST_USER=$(whoami) \
	"$image_name" $@
