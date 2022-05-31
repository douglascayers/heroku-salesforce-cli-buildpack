#!/usr/bin/env bash

# Indents then outputs any input piped to it from stdin.
indent() {
  local c='s/^/       /'
  case $(uname) in
    Darwin)
      sed -l "$c"
      ;;
    *)
      sed -u "$c"
      ;;
  esac
}

puts_header() {
  echo "" || true
  echo -e "-----> $*" || true
  echo "" || true
}

puts_info() {
  echo -e "       $*" || true
}

puts_warn() {
  echo "" || true
  echo -e "\033[1;33m-----> $* \033[0m" || true
  echo "" || true
}

puts_error() {
  # no leading newline so that error is closest to last output/command
  echo -e "\033[1m\033[31m !     $* \033[0m" >&2 || true
  echo "" || true
}
