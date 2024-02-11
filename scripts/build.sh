#!/bin/bash
#
# Defines Docker build process for production ready image of our Elixir app.
#
# We want to define Elixir/Erlang versions in minimum places to improve maintainability,
# so we use `.env` file and parse it to convert to build arguments list.
#
# Example:
#
# $ ./scripts/build.sh lexin 0.3.0
# $ ./scripts/build.sh lexin 0.3.0 --force
# $ ./scripts/build.sh lexin 0.3.0 --force --no-cache
#
# Note: `--no-cache` should always be used only with `--force` going first; `--no-cache` tells
# Docker to skip local cache.

if ! docker version > /dev/null 2>&1; then
  echo "Docker is not running. We cannot build release without Docker!"
  exit 1
fi

# We expect at least two arguments: application name and version number
if [[ $# -lt 2 ]]; then
  echo "Please, provide application name and version number, for example:"
  echo "$0 my_app 1.1.0"
  exit 2
fi

# But in addition we can also accept --force and --no-cache as third and fourth arguments
if [ -n "$3" ] && [[ $3 == "--force" ]]; then
  FORCE_FLAG=true
else
  FORCE_FLAG=false
fi

if [ -n "$4" ] && [[ $4 == "--no-cache" ]]; then
  NO_CACHE_FLAG=true
else
  NO_CACHE_FLAG=false
fi

# Some information we will need to name and tag the image we're building
APP_NAME=$1
APP_VERSION=$2
IMAGE_NAME="ghcr.io/cr0t/$APP_NAME:$APP_VERSION"
EXISTING_IMAGE_ID=$(docker images -q $IMAGE_NAME 2> /dev/null)

if [ -n "$EXISTING_IMAGE_ID" ] && ! $FORCE_FLAG; then
  echo "The image $IMAGE_NAME already exists: $EXISTING_IMAGE_ID!"
  echo "You can use --force to delete and rebuild it forcefully, or bump the version in mix.exs."
  echo "Note: add --no-cache to tell Docker skip local cache."
  exit 3
fi

BUILD_PLATFORM="linux/amd64"
BUILD_ENV_ARGS=$(for i in `cat .env | grep -v '#'`; do out+="--build-arg $i "; done; echo $out; out="")
BUILD_FLAGS="$BUILD_ENV_ARGS --platform $BUILD_PLATFORM --file .docker/Dockerfile.build "

if $FORCE_FLAG && [ -n "$EXISTING_IMAGE_ID" ]; then
  docker image rm $EXISTING_IMAGE_ID
fi

if $NO_CACHE_FLAG; then
  docker build $BUILD_FLAGS --no-cache --tag $IMAGE_NAME .
else
  docker build $BUILD_FLAGS --tag $IMAGE_NAME .
fi

# push it to GitHub
docker push $DOCKER_IMAGE
