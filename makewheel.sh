#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function makewheel_init () {
  set -o pipefail
  source -- common.sh --lib || return $?

  exec </dev/null || return $?

  local TZ="${TZ:-UTC}"
  ln --symbolic --no-target-directory --force \
    -- /usr/share/zoneinfo/"$TZ" /etc/localtime || return $?

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

  local SL_REPO_URL='https://github.com/streamlink/streamlink.git'
  local SL_REPO_DIR='3rd-party/sl-repo'
  [ -d "$SL_REPO_DIR" ] || git clone "$SL_REPO_URL" "$SL_REPO_DIR"
  pushd -- "$SL_REPO_DIR" >/dev/null || return $?
  makewheel_fallible_pip_stuff &> >(ts | tee -- tmp."$FUNCNAME".log.txt)
  local RV=$?
  popd >/dev/null || return $?

  step find_files tmp.files.workspace.txt .
  step find_files tmp.files.ephem-wheel.txt '/tmp/pip-ephem-wheel-cache-*'

  echo D: "Core action return value was $RV"
  return "$RV"
}


function find_files () {
  eval "find $2 -type f" |& sort --version-sort | nl -ba | tee -- "$1" | tail
}


function makewheel_fallible_pip_stuff () {
  step python3 -m venv pyvenv || return $?
  source -- pyvenv/bin/activate || return $?

  mkdir --parents -- $(echo $(echo '
    tmp.build
    tmp.cache-dir
    tmp.packages
    tmp.wheels
    ') ) || return $?

  local COMMON=(
    --cache-dir tmp.cache
    --editable .
    --isolated
    --no-color
    --prefer-binary
    --requirement dev-requirements.txt
    --src .
    )

  local STEP=(
    pip3
    install
    --fail
    --log tmp.pip--log.install.txt
    "${COMMON_PIP_OPT[@]}"
    --compile
    --target tmp.packages
    --upgrade
    )
  step "${STEP[@]}" || return $?

  STEP=(
    pip3
    wheel
    --log tmp.pip--log.wheel.txt
    "${COMMON_PIP_OPT[@]}"
    --build tmp.build
    --wheel-dir tmp.wheels
    )
  step "${STEP[@]}" || return $?

  step which streamlink
  step streamlink --version
}










makewheel_init "$@"; exit $?
