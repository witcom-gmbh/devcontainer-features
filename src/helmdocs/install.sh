#!/bin/sh
set -e

# grab the version
readonly HELMDOCS_VERSION="${VERSION:-latest}"

readonly HELMDOCS_SKIP_TLS="${SKIPTLS:-false}"

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
        "Linux") OS="Linux" ;;
        *) echo "The current OS (${OS}) is not supported."; exit 1 ;;
    esac

    WGET_PARAMS=""
    if [ "${HELMDOCS_SKIP_TLS}" = true ]; then
	  WGET_PARAMS="--no-check-certificate"
    fi

    echo "Installing helm-docs ${HELMDOCS_VERSION} for ${ARCH} on OS ${OS} ..."

    # https://github.com/norwoodj/helm-docs/releases/download/v1.14.2/helm-docs_1.14.2_Linux_arm6.rpm
    if [ "${HELMDOCS_VERSION}" != "latest" ] ; then
        HELMDOCS_URL="https://github.com/norwoodj/helm-docs/releases/download/v${HELMDOCS_VERSION}/helm-docs_${HELMDOCS_VERSION}_${OS}_${ARCH}.tar.gz"
    else
        local RELEASES_RESPONSE="$(wget -O- --tries=3 ${WGET_PARAMS} https://api.github.com/repos/norwoodj/helm-docs/releases)"
        echo 
        HELMDOCS_URL="$(echo "${RELEASES_RESPONSE}" | grep "browser_download_url.*${OS}_${ARCH}.tar.gz" | head -n 1 | cut -d '"' -f 4)"
    fi

    echo "Downloading ${HELMDOCS_URL} ..."
    wget ${WGET_PARAMS} -O /tmp/helmdocs.tar.gz "${HELMDOCS_URL}"

    echo "Extracting..."
	tar xzf /tmp/helmdocs.tar.gz --directory=/usr/local/bin helm-docs
    rm /tmp/helmdocs.tar.gz

    echo "Helm-docs ${HELMDOCS_VERSION} for ${ARCH} installed at $(command -v helm-docs)."
}

echo "Activating feature 'helmdocs'"
echo "The provided version is: ${VERSION}"



main "$@"