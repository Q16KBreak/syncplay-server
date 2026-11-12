#!/bin/bash

set -eu

echo "==> [1/2] Getting latest Syncplay commit..."
SYNCPLAY_SHA="$(git ls-remote \
  https://github.com/Syncplay/syncplay.git \
  refs/heads/master | cut -f1)"
echo "    Syncplay SHA: $SYNCPLAY_SHA"


echo "==> [2/2] Building Docker image..."
BUILD_SHA="$(git rev-parse --short=7 HEAD)"
BUILD_ARGS=(
  --pull=false
  --build-arg SYNCPLAY_SHA="$SYNCPLAY_SHA"
  --build-arg BUILD_SHA="$BUILD_SHA"
  # --build-arg HTTP_PROXY=http://127.0.0.1:7890   
  # --build-arg HTTPS_PROXY=http://127.0.0.1:7890  
  -t "syncplay-server:$SYNCPLAY_SHA-$BUILD_SHA"
  -t syncplay-server:latest
  .
)
sudo docker build "${BUILD_ARGS[@]}"
echo
echo "==> Build completed successfully."
