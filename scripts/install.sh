#!/usr/bin/env bash
set -euo pipefail

if ! type "curl" > /dev/null; then
    echo "curl is required"
    exit 1
fi

# initArch discovers the architecture for this system.
initArch() {
  ARCH=$(uname -m)
  case $ARCH in
    armv5*) ARCH="armv5";;
    armv6*) ARCH="armv6";;
    armv7*) ARCH="arm";;
    aarch64) ARCH="arm64";;
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
  esac
}

# runs the given command as root (detects if we are root already)
runAsRoot() {
  if [ $EUID -ne 0 -a "$USE_SUDO" = "true" ]; then
    sudo "${@}"
  else
    "${@}"
  fi
}

# initOS discovers the operating system for this system.
initOS() {
  OS=$(uname)
}

# detect OS ARCH
initArch
initOS

# default version
export INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
export USE_SUDO="${USE_SUDO:-true}"
FORCE_INSTALL="${FORCE_INSTALL:-false}"

HELMIFY_VERSION="${HELMIFY_VERSION:-v0.4.18}"
HELMIFY_ARCHIVE="helmify_${OS}_${ARCH}.tar.gz"
HELMIFY_BINARY="helmify"
HELMIFY_URL="https://github.com/arttor/helmify/releases/download/${HELMIFY_VERSION}/${HELMIFY_ARCHIVE}"

helmify_is_installed="false"

[ -d "$INSTALL_DIR" ] || mkdir -p $INSTALL_DIR

if [[ "${FORCE_INSTALL}" == "false" ]]; then
   # check if exist
   type helmify && helmify_is_installed="true"
else
    echo "# force install ${FORCE_INSTALL}"
fi

if [[ "$helmify_is_installed" == "false" ]];then
  echo "# Install helmify ${HELMIFY_VERSION} from ${HELMIFY_URL}"
  curl -LOs ${HELMIFY_URL}
  tar -zxvf ${HELMIFY_ARCHIVE} ${HELMIFY_BINARY}
  runAsRoot mv ${HELMIFY_BINARY} ${INSTALL_DIR}/helmify
  runAsRoot chmod 755 ${INSTALL_DIR}/helmify
  rm -rf ${HELMIFY_ARCHIVE}
fi
echo "# helmify"
helmify  -version
