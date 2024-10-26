#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function invoke_ci_build () {
  ! git status --short -uall | grep . || return 4
  git push origin HEAD:build-$EPOCHSECONDS
}


invoke_ci_build "$@"; exit $?
