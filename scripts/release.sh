#!/bin/bash
#
# Build a Docker image and send it to remote machine to run it there.

FULLPATH=$(realpath $0)
SCRIPTS_DIR=$(dirname $FULLPATH)

APP_NAME=$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
APP_VERSION=$(grep 'version:' mix.exs | cut -d '"' -f2)

# Pre-generate sitemap files on the host machine (ensure that all dictionaries available!)
mix sitemap.gen

# Time to build the image and push it to the registry
$SCRIPTS_DIR/build.sh $APP_NAME $APP_VERSION --force
