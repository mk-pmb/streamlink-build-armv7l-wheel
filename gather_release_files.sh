#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function gather_release_files () {
  mkdir --parents -- release
  local FILES=(
    tmp.*/dist/*
    tmp.*.txt
    tmp.*.log
    )
  local SRC= DEST=
  for SRC in "${FILES[@]}"; do
    [ -f "$SRC" ] || continue
    DEST="$(basename -- "$SRC")"
    DEST="${DEST#tmp.}"
    mv --verbose --no-target-directory -- "$SRC" release/"$DEST"
  done

  git show --no-patch --format=tformat:%B -- "$GITHUB_SHA" >.rlsbody.txt
  echo tag="rolling/${GITHUB_REF#*-}" >>"$GITHUB_OUTPUT"
}


gather_release_files "$@"; exit $?
