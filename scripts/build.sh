#!/usr/bin/env bash

# Strict mode for better error handling
set -euo pipefail

usage() {
  echo "Usage: $0 IMAGE_TAG [OPTIONS]"
  echo ""
  echo "Build and push a Docker image for an Elixir application"
  echo ""
  echo "Arguments:"
  echo ""
  echo "  IMAGE_TAG      Full image tag (e.g., ghcr.io/cr0t/lexin:0.3.0)"
  echo ""
  echo "Options:"
  echo ""
  echo "  --force        Force rebuild, removing existing image"
  echo "  --no-cache     Disable Docker build cache"
  echo ""
  echo "Examples:"
  echo ""
  echo "  $0 ghcr.io/cr0t/lexin:0.3.0"
  echo "  $0 ghcr.io/cr0t/lexin:0.3.0 --force"
  echo "  $0 ghcr.io/cr0t/lexin:0.3.0 --force --no-cache"
  exit 1
}

check_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed." >&2
    exit 1
  fi

  if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running." >&2
    exit 1
  fi
}

parse_arguments() {
  FORCE_FLAG=false
  NO_CACHE_FLAG=false

  # Validate at least one argument
  [[ $# -lt 1 ]] && usage

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
        FORCE_FLAG=true
        shift
        ;;
      --no-cache)
        NO_CACHE_FLAG=true
        shift
        ;;
      -*)
        echo "Error: Unknown option $1" >&2
        usage
        ;;
      *)
        if [[ -z "${IMAGE_NAME:-}" ]]; then
          IMAGE_NAME="$1"
          shift
        else
          echo "Error: Too many arguments" >&2
          usage
        fi
        ;;
    esac
  done
}

build_docker_image() {
  # Check if image exists and handle force rebuild
  local existing_image_id
  existing_image_id=$(docker images -q "$IMAGE_NAME" 2> /dev/null || true)

  if [[ -n "$existing_image_id" ]]; then
    if [[ "$FORCE_FLAG" == "true" ]]; then
      echo "Removing existing image $IMAGE_NAME"
      docker image rm "$existing_image_id"
    else
      echo "Image $IMAGE_NAME already exists. Use --force to rebuild."
      exit 3
    fi
  fi

  readonly BUILD_PLATFORM="linux/amd64"
  readonly BUILD_ENV_ARGS=$(awk '!/^($|#)/ {printf "--build-arg %s ", $0}' .env)

  local build_flags="$BUILD_ENV_ARGS --platform $BUILD_PLATFORM --file .docker/Dockerfile.build"

  [[ "$NO_CACHE_FLAG" == "true" ]] && build_flags="${build_flags} --no-cache"

  # Ensure that buildx plugin is available (in macOS check info in `brew info docker-buildx`)
  docker build --debug $build_flags --tag "$IMAGE_NAME" .
}

main() {
  check_docker
  parse_arguments "$@"
  build_docker_image
  docker push "$IMAGE_NAME"
}

main "$@"
