#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function run_in_armhf_docker () {
  set -o pipefail
  source -- common.sh --lib || return $?

  prepare_for_armhf_emulation || return $?

  mkdir --parents -- tmp.pip-wheels-cache

  local DK_NAME="$(basename -- "$PWD")"
  docker stop "$DK_NAME" || true
  docker rm "$DK_NAME" || true
  step docker run \
    --platform linux/armhf \
    --name "$DK_NAME" \
    --volume "$PWD:/app:rw" \
    --volume "$PWD/tmp.pip-wheels-cache:/root/.cache/pip/wheels:rw" \
    --workdir /app \
    --init \
    ubuntu:jammy \
    bash ./makewheel.sh \
    || return $?
}


function prepare_for_armhf_emulation () {
  case "$(uname -m)" in
    armv7l | \
    armhf )
      echo D: $FUNCNAME: "According to uname, we're already on armhf natively."
      return 0;;
  esac
  local NEED_PKG='
      binfmt-support
      qemu
      qemu-user-static
      '
  local MISS_PKG= VAL=
  for VAL in $NEED_PKG; do
    [ -f /usr/share/doc/"$VAL"/copyright ] || MISS_PKG+=" $VAL"
  done
  [ -z "$MISS_PKG" ] || step sudo apt-get install --assume-yes \
    $MISS_PKG || return $?

  step '= Register the armhf arch with the kernel' \
    docker run --rm --privileged \
    multiarch/qemu-user-static \
    --reset --persistent yes \
    || return $?
    # The `--persistent yes` only applies until next reboot.
}










run_in_armhf_docker "$@"; exit $?
