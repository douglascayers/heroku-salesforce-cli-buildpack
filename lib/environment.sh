#!/usr/bin/env bash

# Inspired by https://github.com/heroku/heroku-buildpack-nodejs/blob/main/lib/environment.sh

# Prints the operating system lowercased. (e.g. 'linux' or 'macos')
get_os() {
  local os="$(uname | tr '[:upper:]' '[:lower:]')"
  case $os in
    # darwin)
    #   echo "macos"
    #   ;;
    *)
      echo "${os}"
      ;;
  esac
}

# Detects the machine architecture.
# Prints 'x64' for 64-bit or 'x86' for 32-bit.
# https://askubuntu.com/a/41334/990663
get_arch() {
  # Use the `-m` flag instead of `-p` otherwise
  # you get the incorrect value on macOS.
  local arch="$(uname -m)"
  case $arch in
    amd64 | x86_64)
      echo "x64"
      ;;
    i386 | i586 | i686)
      echo "x86"
      ;;
    aarch64)
      echo "arm64"
      ;;
    *)
      echo "x86"
      ;;
  esac
}

# Prints the concatenation of the 'os-arch'. (e.g. 'linux-x64')
get_platform() {
  local os=$(get_os)
  local cpu=$(get_arch)
  echo "$os-$arch"
}

# For each file in the given directory, exports as an environment variable
# the filename as the variable name and the file contents as the value.
# @param $1 path to directory with environment variable files
# @param $2 regex pattern of variables to export (default is to export all)
export_env_dir() {
  local env_dir="${1}"
  if [ -d "${env_dir}" ]; then
    local allowlist_regex=${2:-''}
    local denylist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|LANG|BUILD_DIR)$'}
    pushd "${env_dir}" > /dev/null
    for e in *; do
      [ -e "$e" ] || continue
      echo "$e" | grep -E "${allowlist_regex}" | grep -qvE "${denylist_regex}" \
        && export "$e=$(cat "$e")"
      :
    done
    popd > /dev/null
  fi
}

# Prints environment variables that match the given pattern.
# @param $1 regex pattern
print_env() {
  local pattern="${1}"
  (printenv | grep -Ei "${pattern}" || '') | xargs -I{} echo "       {}"
}
