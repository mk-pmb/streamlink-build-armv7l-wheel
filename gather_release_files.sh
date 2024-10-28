#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function gather_release_files () {
  git show --no-patch --format=tformat:%B -- "$GITHUB_SHA" >.rlsbody.txt
  echo tag="rolling/${GITHUB_REF#*-}" >>"$GITHUB_OUTPUT"

  local RLS_DIR="$PWD/release"
  mkdir --parents -- "$RLS_DIR"
  exec &> >(tee -- "$RLS_DIR/$FUNCNAME.log.txt")
  sudo chown --reference . --recursive .

  echo '==== Find and move: ===='
  local FIND=(
    find
    -maxdepth 8
    -type f
    '(' -false
      -o -name '*.whl'
      -o -name '*.wgn'
      -o -name 'tmp.*.txt'
      -o -name 'tmp.*.log'
      -o -path '.ghciu/logs.local/*.log'
    ')'
    -print
    -execdir mv --target-directory="$RLS_DIR" -- '{}' ';'
    )
  "${FIND[@]}"

  cd -- "$RLS_DIR" || return $?
  local VAL= REN=
  for VAL in [a-z]*; do
    REN="${REN#tmp.}"
    case "$VAL" in
      *.log ) REN+='.txt';;
    esac
    [ "$REN" == "$VAL" ] || mv --no-target-directory -- "$VAL" "$REN"
    VAL="$REN"
    case "$VAL" in
      *.wgn | \
      *.whl | \
      *.zip )
        echo "==== Files in $VAL: ===="; unzip -lv -- "$SRC";;
    esac
  done

  >.sha
  for VAL in sha1 sha256 sha512 ; do
    "$VAL"sum --binary -- [a-z]* | tee --append -- .sha
  done
  sort --version-sort --key=2 -- .sha >checksums.sha
  rm -- .sha
  echo '==== Release dir: ===='
  ls -al .
  echo '===='
}


gather_release_files "$@"; exit $?
