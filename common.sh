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
  printf -- '>>-- %(%F %T)T -->>-- ' "$STARTED"
  echo "$DESCR -->>---->>---->>---->>"
  "$@"
  local RV=$?
  local ENDED="$EPOCHSECONDS"
  local DELTA_SEC= DELTA_MIN=
  (( DELTA_SEC = ENDED - STARTED ))
  (( DELTA_MIN = DELTA_SEC / 60 ))
  (( DELTA_SEC = DELTA_SEC % 60 ))
  printf -- '<<-- %(%F %T)T --<<-- ' "$ENDED"
  echo "$DESCR --<<-- rv=$RV --<<-- $DELTA_MIN min $DELTA_SEC sec --<<----<<"
  return "$RV"
}







[ "$1" == --lib ] && return 0; "$@"; exit $?
