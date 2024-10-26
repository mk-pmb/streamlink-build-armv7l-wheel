#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function gather_release_files () {
  mkdir --parents -- release
  mv --target-directory=release/ -- tmp.*.txt
  mv --target-directory=release/ -- tmp.*.log
  git show --no-patch --format=tformat:%B -- "$GITHUB_SHA" >.rlsbody.txt
  # echo tag="rolling/${GITHUB_REF#*-}" >>"$GITHUB_OUTPUT"
  echo tag=latest >>"$GITHUB_OUTPUT"
}


gather_release_files "$@"; exit $?
