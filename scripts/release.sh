#!/bin/bash

# We need to do a few things to prepare a release:
#
# 1. Clean up any previosly compiled assets
# 2. Build:
#    - Compile static assets (mix assets.deploy)
#    - Gzip and add fingerprints to these files (part of previous step)
#    - Compile and pack a release tarball
# 3. Distribute this file
#
# See https://hexdocs.pm/phoenix/releases.html for more detailed documentation

APP_NAME=$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
APP_VERSION=$(grep 'version:' mix.exs | cut -d '"' -f2)
TAR_FILENAME=${APP_NAME}-${APP_VERSION}.tar.gz
RELEASE_ARTEFACT=_build/prod/${TAR_FILENAME}

RUN_IN_DOCKER="docker-compose run --rm phoenix"

### Clean previously compiled assets

$RUN_IN_DOCKER rm -rf /app/priv/static/assets/*

### Build

$RUN_IN_DOCKER mix setup
$RUN_IN_DOCKER mix assets.deploy
$RUN_IN_DOCKER env MIX_ENV=prod mix release --force --overwrite

### Clean assets' artefacts again, to avoid developer's confusion

$RUN_IN_DOCKER rm -rf /app/priv/static/assets/*
git clean -fd -- ./priv/static/

### Distribute

$RUN_IN_DOCKER mv $RELEASE_ARTEFACT /app/${TAR_FILENAME} # we have to move it out of _build, as it's a volume in `phoenix` container

echo "Sending archive to host..."
scp $TAR_FILENAME summercode.com:~
rm $TAR_FILENAME
