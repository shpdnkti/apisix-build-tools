#!/usr/bin/env bash
set -euo pipefail
set -x
mkdir /output
dist=$(cat /tmp/dist)
codename=$(cat /tmp/codename)

# Determine the name of artifact
# The defaut is apisix-runtime
artifact="openresty"
if [ "$ARTIFACT" != "0" ]; then
    artifact=${ARTIFACT}
fi

ARCH=${ARCH:-`(uname -m | tr '[:upper:]' '[:lower:]')`}

fpm -f -s dir -t "$PACKAGE_TYPE" \
    --"$PACKAGE_TYPE"-dist "$dist" \
    -n "$artifact" \
    -a "$(uname -i)" \
    -v "$RUNTIME_VERSION" \
    -v "1.25.3.1" \
    --iteration "$ITERATION" \
    --post-install post-install-runtime.sh \
    --description "Scalable Web Platform by Extending NGINX with Lua" \
    --license "BSD" \
    -C /tmp/build/output \
    -p /output \
    --url 'https://openresty.org' \
    --conflicts openresty \
    --config-files usr/lib/systemd/system/openresty.service \
    --prefix=/usr/local

PACKAGE_ARCH="amd64"
if [[ $ARCH == "arm64" ]] || [[ $ARCH == "aarch64" ]]; then
    PACKAGE_ARCH="arm64"
fi

if [ "$PACKAGE_TYPE" == "deb" ]; then
    # Rename deb file with adding $DIST section
    mv /output/apisix-runtime_"${RUNTIME_VERSION}"-"${ITERATION}"_"${PACKAGE_ARCH}".deb /output/apisix-runtime_"${RUNTIME_VERSION}"-"${ITERATION}"~"${dist}"_"${PACKAGE_ARCH}".deb
fi
