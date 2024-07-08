#!/bin/sh
set -e

# grab the version
readonly COCOGITTO_VERSION="${VERSION:-latest}"

readonly COCOGITTO_SKIP_TLS="${SKIPTLS:-false}"

# apt-get configuration
export DEBIAN_FRONTEND=noninteractive

preflight () {
    if command -v wget > /dev/null; then
        return
    fi

    if [ -e /etc/os-release ]; then
        . /etc/os-release
    fi

    case "${ID}" in
        'debian' | 'ubuntu')
            apt-get update
            apt-get install -y --no-install-recommends \
                wget \
                ca-certificates
        ;;
        'fedora')
            dnf -y install wget
        ;;
        *) echo "The ${ID} distribution is not supported."; exit 1 ;;
    esac
}

main () {
    preflight

    local ARCH="$(uname -m)"
    case "${ARCH}" in
        "x86_64") ARCH="x86_64" ;;
        *) echo "The current architecture (${ARCH}) is not supported."; exit 1 ;;
    esac

    local OS="$(uname -s)"
    case "${OS}" in
        "Linux") OS="unknown-linux-musl" ;;
        *) echo "The current OS (${OS}) is not supported."; exit 1 ;;
    esac

    WGET_PARAMS=""
    if [ "${COCOGITTO_SKIP_TLS}" = true ]; then
	  WGET_PARAMS="--no-check-certificate"
    fi

    echo "Installing cocogitto ${COCOGITTO_VERSION} for ${ARCH} on OS ${OS} ..."

    if [ "${COCOGITTO_VERSION}" != "latest" ] ; then
        COCOGITTO_URL="https://github.com/cocogitto/cocogitto/releases/download/${COCOGITTO_VERSION}/cocogitto-${COCOGITTO_VERSION}-${ARCH}-${OS}.tar.gz"
    else
        local RELEASES_RESPONSE="$(wget -qO- --tries=3 ${WGET_PARAMS} https://api.github.com/repos/cocogitto/cocogitto/releases)"
        COCOGITTO_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*${ARCH}-${OS}.tar.gz" | head -n 1 | cut -d '"' -f 4)"
    fi

    echo "Downloading ${COCOGITTO_URL} ..."
    wget ${WGET_PARAMS} -qO /tmp/cocogitto.tar.gz "${COCOGITTO_URL}"

    echo "Extracting..."
	tar xzf /tmp/cocogitto.tar.gz --strip-components=1 --directory=/usr/local/bin ${ARCH}-${OS}/cog
    rm /tmp/cocogitto.tar.gz

    echo "Cocogitto ${COCOGITTO_VERSION} for ${ARCH} installed at $(command -v cog)."
}

echo "Activating feature 'cocogitto'"
echo "The provided version is: ${VERSION}"


# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

main "$@"