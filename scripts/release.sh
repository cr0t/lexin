#!/bin/bash
#
# Build a Docker image and send it to remote machine to run it there.

FULLPATH=$(realpath $0)
SCRIPTS_DIR=$(dirname $FULLPATH)

APP_NAME=$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
APP_VERSION=$(grep 'version:' mix.exs | cut -d '"' -f2)

IMAGE_ID=$($SCRIPTS_DIR/build.sh $APP_NAME $APP_VERSION --force | tail -n 1)

if [[ $? -eq 0 ]]; then
  IMAGE_TAR="$APP_NAME-$APP_VERSION.tar"

  echo "Making an artefact of $IMAGE_ID to distribute..."
  docker save $IMAGE_ID -o $IMAGE_TAR

  echo "Sending $IMAGE_TAR to remote host..."
  scp $IMAGE_TAR summercode.com:~
  ssh summercode.com "docker load -i $IMAGE_TAR && docker tag $IMAGE_ID cr0t/$APP_NAME:$APP_VERSION"
  rm $IMAGE_TAR
fi

exit 0
