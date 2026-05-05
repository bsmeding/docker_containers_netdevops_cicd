#!/bin/bash

set -eo pipefail

get_build_info() {
  case "$1" in
    ubuntu2404) echo "ubuntu.Dockerfile ubuntu:24.04" ;;
    ubuntu2604) echo "ubuntu.Dockerfile ubuntu:26.04" ;;
    ubuntu) echo "ubuntu.Dockerfile ubuntu:26.04" ;;
    debian12) echo "debian.Dockerfile debian:bookworm" ;;
    debian13) echo "debian.Dockerfile debian:trixie" ;;
    debian) echo "debian.Dockerfile debian:trixie" ;;
    rockylinux8) echo "rocky.Dockerfile rockylinux:8" ;;
    rockylinux9) echo "rocky.Dockerfile rockylinux:9" ;;
    rockylinux) echo "rocky.Dockerfile rockylinux:9" ;;
    alpine3.22) echo "alpine.Dockerfile alpine:3.22" ;;
    alpine3.23) echo "alpine.Dockerfile alpine:3.23" ;;
    alpine3) echo "alpine.Dockerfile alpine:3.23" ;;
    *) echo "" ;;
  esac
}

get_all_tags() {
  echo "ubuntu2404 ubuntu2604 ubuntu debian12 debian13 debian rockylinux8 rockylinux9 rockylinux alpine3.22 alpine3.23 alpine3"
}

get_python_version() {
  case "$1" in
    debian13|debian)
      echo "3.13"
      ;;
    *)
      echo "system"
      ;;
  esac
}

BUILD_TAG=""
PUSH_FLAG=""
for arg in "$@"; do
  if [[ "$arg" == "--push" ]]; then
    PUSH_FLAG="--push"
  elif [[ "$arg" != "--push" && -z "$BUILD_TAG" ]]; then
    BUILD_TAG="$arg"
  fi
done

if [[ -n "${BUILD_TAG:-}" ]]; then
  build_info=$(get_build_info "$BUILD_TAG")
  if [[ -z "$build_info" ]]; then
    echo "Error: Unknown tag '$BUILD_TAG'"
    echo "Available tags: $(get_all_tags)"
    exit 1
  fi
  tags_to_build=("$BUILD_TAG")
else
  tags_to_build=($(get_all_tags))
fi

for tag in "${tags_to_build[@]}"; do
  IFS=' ' read -r dockerfile base_image <<< "$(get_build_info "$tag")"
  python_version=${PYTHON_VERSION:-$(get_python_version "$tag")}

  echo
  echo "Building NetDevOps image for: $tag"
  echo "Base image: $base_image"
  echo "Dockerfile: $dockerfile"
  echo "Python version: $python_version"

  cp requirements/pip-common.txt requirements/pip.txt

  if [[ -n "$PUSH_FLAG" ]]; then
    case "$tag" in
      rockylinux8)
        platforms="linux/amd64"
        ;;
      *)
        platforms="linux/amd64,linux/arm64"
        ;;
    esac
  else
    case "$(uname -m)" in
      x86_64) platforms="linux/amd64" ;;
      arm64|aarch64) platforms="linux/arm64" ;;
      *) platforms="linux/amd64" ;;
    esac
  fi

  docker buildx build \
    $PUSH_FLAG \
    --pull \
    --platform "$platforms" \
    -f "dockerfiles/$dockerfile" \
    --build-arg BASE_IMAGE="$base_image" \
    --build-arg PYTHON_VERSION="$python_version" \
    -t "bsmeding/netdevops_cicd_${tag}:latest" .

  echo "Image built: bsmeding/netdevops_cicd_${tag}:latest"
done
