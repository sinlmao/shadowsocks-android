#!/bin/bash -e

API_URL="https://api.github.com/repos/tcnksm/ghr/releases/latest"
DOWNLOAD_TAG=$(curl -sSL $API_URL | grep "tag_name" | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL=$(curl -sSL $API_URL | grep "browser_download_url" | grep "linux" | grep "amd64" | cut -d '"' -f 4)
curl -sSL $DOWNLOAD_URL | sudo -E tar -zxf - -C /usr/local/bin/ ghr_${DOWNLOAD_TAG}_linux_amd64/ghr --strip-components 1

mkdir release
cp mobile/build/outputs/apk/release/*.apk release/ 2>/dev/null || true
cp tv/build/outputs/apk/release/*.apk release/ 2>/dev/null || true

RELEASE_VERSION=$(date +'%Y%m%d')
ghr -t $GITHUB_TOKEN \
  -u $CIRCLE_PROJECT_USERNAME \
  -r $CIRCLE_PROJECT_REPONAME \
  -c $CIRCLE_SHA1 \
  -n $RELEASE_VERSION \
  -delete \
  $RELEASE_VERSION release
