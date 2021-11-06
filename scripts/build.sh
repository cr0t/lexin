#!/bin/bash
#
# Defines Docker build process for production ready image.
#
# We want to define Elixir/Erlang versions in minimum places to improve maintainability, so we use
# `.env` file and parse it to convert to build arguments list.

if ! docker version > /dev/null 2>&1; then
  echo "Docker is not running. We cannot build release without Docker!"
  exit 1
fi

APP_NAME=$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
APP_VERSION=$(grep 'version:' mix.exs | cut -d '"' -f2)

DOCKER_NAMESPACE="cr0t"
DOCKER_BUILD_ARGS=$(for i in `cat .env`; do out+="--build-arg $i "; done; echo $out; out="")

docker image build $DOCKER_BUILD_ARGS --tag $DOCKER_NAMESPACE/$APP_NAME:$APP_VERSION .
