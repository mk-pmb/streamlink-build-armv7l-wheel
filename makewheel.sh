#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function makewheel_init () {
  local ORIG_WD="$PWD"
  set -o pipefail
  source -- common.sh --lib || return $?

  exec </dev/null || return $?
  export DEBIAN_FRONTEND=noninteractive
  export TERM=dumb

  local TZ="${TZ:-UTC}"
  ln --symbolic --no-target-directory --force \
    -- /usr/share/zoneinfo/"$TZ" /etc/localtime || return $?
  export TZ

  step apt update || return $?
  local APT_PKG=(
    # Actually required stuff:
    git
    libxml2-dev
    libxslt1-dev
    moreutils # <- for "ts", which we use to see where pip gets stuck later.
    python3
    python3-pip
    python3-venv
    python3-wheel

    # Stuff not strictly required but avoids log clutter from warnings:
    locales
    tzdata

    nano
    rlwrap
    screen
    bash-completion
    less
    )
  step apt install --assume-yes "${APT_PKG[@]}" || return $?
  step locale-gen en_US.UTF-8 || return $?
  step update-locale || return $?

  local RELEASE_DIR="$PWD/release"
  mkdir --parents -- "$RELEASE_DIR" || return $?

  local SL_REPO_URL='https://github.com/streamlink/streamlink.git'
  local SL_REPO_DIR='tmp.sl-repo'
  [ -d "$SL_REPO_DIR" ] || step git clone "$SL_REPO_URL" "$SL_REPO_DIR"

  cd -- "$SL_REPO_DIR" || return $?
  makewheel_fallible_core &> >(
    ts | tee -- "$ORIG_WD/tmp.fallible_core.log")
  local RV=$?
  cd -- "$ORIG_WD" || return $?

  step find_files tmp.files.workspace.txt .

  echo
  echo D: "Core action return value was $RV"
  return "$RV"
}


function find_files () {
  local FIND=()
  eval "FIND=( $2 )"
  FIND=(
    find
    "${FIND[@]}"
    -name .git -prune ,
    -type f
    )
  "${FIND[@]}" |& sort --version-sort | nl -ba | tee -- "$1" | tail || true
}


function makewheel_fallible_core () {
  step python3 -m venv pyvenv || return $?
  source -- pyvenv/bin/activate || return $?

  local STEP=(
    pip3
    install
    --upgrade

    build # https://pypi.org/project/build/
    setuptools
    'wagon[dist]'
    wheel
    )
  step "${STEP[@]}" || return $?

  step wagon create -r dev-requirements.txt . || return $?

  #mkdir --parents -- $(echo $(echo '
  #  tmp.build
  #  tmp.cache-dir
  #  tmp.packages
  #  tmp.wheels
  #  ') ) || return $?

  #STEP=(
  #  pip3
  #  wheel
  #  --cache-dir tmp.cache
  #  --no-color
  #  --prefer-binary
  #  --requirement dev-requirements.txt
  #  --src .
  #  --build tmp.build
  #  --wheel-dir .
  #  .
  #  )
  #step "${STEP[@]}" || return $?

  # step which streamlink
  # step streamlink --version
}










makewheel_init "$@"; exit $?
