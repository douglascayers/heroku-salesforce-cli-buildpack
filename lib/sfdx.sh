#!/usr/bin/env bash

# Prints a JSON array of the cli version manifest.
# The 'key' property is the version number.
# The 'value' property is the download url.
# @param $1 <operating system> (e.g. 'linux' or 'darwin' or 'win32')
# @param $2 <machine architecture> (e.g. 'x86' or 'x64')
get_cli_version_manifest() {
  local os="${1}"
  local arch="${2}"
  local json=$(
    curl \
      --silent \
      --show-error \
      --fail \
      --retry 3 \
      --retry-max-time 15 \
      --location \
      https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/sfdx-${os}-${arch}-tar-gz.json \
      | jq -r '. | to_entries'
  )
  echo "${json}"
}

# Prints the latest cli version.
# @param $1 <operating system> (e.g. 'linux' or 'darwin' or 'win32')
# @param $2 <machine architecture> (e.g. 'x86' or 'x64')
get_latest_version() {
  local os="${1}"
  local arch="${2}"
  local json=$(get_cli_version_manifest $os $arch)
  echo "${json}" | jq -r '. | max_by(.key) | .key'
}

# Prints the download url for the given cli version.
# @param $1 <operating system> (e.g. 'linux' or 'darwin' or 'win32')
# @param $2 <machine architecture> (e.g. 'x86' or 'x64')
# @param $3 [version] (e.g. 7.152.0) If not specified then assumes latest version.
get_download_url() {
  local os=${1}
  local arch=${2}
  local version=${3:-$(get_latest_version $os $arch)}
  local json=$(get_cli_version_manifest $os $arch)
  echo "${json}" | jq --arg version "${version}" -r '.[] | select(.key == $version) | .value'
}
