ARG VARIANT=bullseye
FROM mcr.microsoft.com/devcontainers/javascript-node:1-20-bullseye

# Brute force around certificate-inspection
ARG SKIP_APT_PEER_VERIFY="false"
RUN if [ "${SKIP_APT_PEER_VERIFY}" = "true" ]; then \
    touch /etc/apt/apt.conf.d/99verify-peer.conf && echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Acquire { https::Verify-Peer false }"; \
    fi

RUN apt-get update && apt-get -y install python3-pip && export DEBIAN_FRONTEND=noninteractive
    
# Add custom CAs
COPY ./ca-trust/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/wit-ca-crt-19f321a4661f40884bb8af5146932975.crt

ARG INSTALL_COCOGITTO="true"
ARG COCOGITTO_VERSION="6.1.0"

RUN if [ "${INSTALL_COCOGITTO}" = "true" ]; then \
    su node -c "umask 0002 && mkdir -p /home/node/.local/bin && wget -qO- https://github.com/cocogitto/cocogitto/releases/download/${COCOGITTO_VERSION}/cocogitto-${COCOGITTO_VERSION}-x86_64-unknown-linux-musl.tar.gz | tar xvz --strip-components=1 -C /home/node/.local/bin && chmod +x /home/node/.local/bin/cog"; \
    fi

# ARG INSTALL_HELMDOCS="false"
# ARG HELMDOCS_VERSION="1.13.1"

# RUN if [ "${INSTALL_HELMDOCS}" = "true" ]; then \
#     su vscode -c "umask 0002 && mkdir -p /home/vscode/.local/bin && wget -qO- https://github.com/norwoodj/helm-docs/releases/download/v${HELMDOCS_VERSION}/helm-docs_${HELMDOCS_VERSION}_Linux_x86_64.tar.gz | tar xz -C /home/vscode/.local/bin && chmod +x /home/vscode/.local/bin/helm-docs"; \
#     fi
