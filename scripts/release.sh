#!/bin/bash
#
# Prepares data, shows notifications, and bootstraps the image build process.

RED='\033[0;31m'
ORANGE='\033[0;33m'
NOCOLOR='\033[0m'
echo -e "${RED}WARNING: ${ORANGE}Don't forget to pre-generate sitemaps and put them in the right place!${NOCOLOR}"
echo -e "${RED}WARNING: ${NOCOLOR}Run gzip -k * in the directory with sitemaps to make their gz-versions"

# ---

FULLPATH=$(realpath $0)
SCRIPTS_DIR=$(dirname $FULLPATH)

# retrieve app's name and its version to name the image we will make
APP_NAME=$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
APP_VERSION=$(grep 'version:' mix.exs | cut -d '"' -f2)

# time to build the image and push it to the registry
$SCRIPTS_DIR/build.sh $APP_NAME $APP_VERSION --force
