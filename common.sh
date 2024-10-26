#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function step () {
  local DESCR=
  case "$1" in
    '= '* ) DESCR="${1#= }"; shift;;
    * )
      DESCR="$*"
      DESCR="${DESCR#eval }"
      DESCR="${DESCR#sudo }"
      DESCR="${DESCR:0:50}"
      ;;
  esac
  local STARTED="$EPOCHSECONDS"
  echo
  echo ">>-- ∑$(seconds_to_dura $SECONDS) -->>-- $DESCR -->>---->>---->>---->>"
  "$@"
  local RV=$?
  local ENDED="$EPOCHSECONDS"
  echo "<<-- ∑$(seconds_to_dura $SECONDS) --<<-- $DESCR --<<-- rv=$RV --<<-- $(
    seconds_to_dura $(( ENDED - STARTED )) ) --<<----<<"
  return "$RV"
}


function seconds_to_dura () {
  local T="$(TZ=UTC printf -- ' %(%T)Ts' "$1")"
  T="${T/:/h }"
  T="${T/:/m }"
  T="${T// 0/ }"
  T="${T/# 0[a-z]/}"
  T="${T/# 0[a-z]/}"
  T="${T# }"
  echo "${T:-0s}"
}







[ "$1" == --lib ] && return 0; "$@"; exit $?
