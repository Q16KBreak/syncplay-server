#!/bin/bash

set -eu

echo "==> [1/3] Getting latest Syncplay commit..."
SYNCPLAY_SHA="$(git ls-remote \
  https://github.com/Syncplay/syncplay.git \
  refs/heads/master | cut -f1)"
echo "    Syncplay SHA: $SYNCPLAY_SHA"


# echo "==> [1.1/3] Getting Python image digest..."
# PYTHON_IMAGE="$(docker buildx imagetools inspect python:3.14-alpine \
#   | awk '/^Digest:/ {print $2; exit}')"
# PYTHON_IMAGE="python:3.14-alpine@$PYTHON_IMAGE"
# echo "    Python image: $PYTHON_IMAGE"
# printf '%s\n' "$PYTHON_IMAGE" > python-image.digest


echo "==> [2/3] Reading PYTHON_IMAGE..."
PYTHON_IMAGE="$(cat python-image.digest)"
echo "    Python image: $PYTHON_IMAGE"


# echo "==> [2.1/3] Pulling Python image..."
# sudo docker pull "$PYTHON_IMAGE"


# echo "==> [2.2/3] Generating requirements.lock..."
# PROXY_ENV=(
#   # -e HTTP_PROXY=http://127.0.0.1:7890
#   # -e HTTPS_PROXY=http://127.0.0.1:7890
# )
# sudo docker run --rm \
#   "${PROXY_ENV[@]}" \
#   "$PYTHON_IMAGE" \
#   sh -c '
#     wget -qO /tmp/requirements.in \
#       https://github.com/Syncplay/syncplay/raw/refs/heads/master/requirements.txt &&
#     python -m pip install --no-cache-dir pip-tools >/dev/null 2>&1 &&
#     pip-compile \
#       --strip-extras \
#       --quiet \
#       --output-file=- \
#       /tmp/requirements.in
#   ' > requirements.lock
# echo "    requirements.lock generated."


echo "==> [3/3] Building Docker image..."
BUILD_SHA="$(git rev-parse --short=7 HEAD)"
BUILD_ARGS=(
  --pull=false
  --build-arg PYTHON_IMAGE="$PYTHON_IMAGE"
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