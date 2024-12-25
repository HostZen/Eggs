#!/bin/bash

# FiveM Installation Script
# HostZen (c) 2024. All rights reserved.
# Jack Perry <jack@hostzen.net>

# Update system & install deps
apt update -y
apt install -y xz-utils jq


# Update default server resources
cd /mnt/server
mkdir -p /mnt/server/resources

echo "updating citizenfx resource files"
git clone https://github.com/citizenfx/cfx-server-data.git /tmp
cp -Rf /tmp/resources/* resources/


# Prepare FiveM Server Binary
CHANGELOGS_PAGE=$(curl -sSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server)
LATEST_VERSION=$(echo $CHANGELOGS_PAGE | jq -r '.latest_download')

if [ ! -z "${LATEST_VERSION}" ]; then
  if curl --output /dev/null --silent --head --fail ${LATEST_VERSION}; then
    echo -e "link is valid. setting download link to ${LATEST_VERSION}"
    DOWNLOAD_LINK=${LATEST_VERSION}
  else
    echo -e "link is invalid closing out"
    exit 2
  fi
fi


# Download the latest version of the FiveM server (we allow users to change via the panel later)
echo -e "Running curl -sSL ${LATEST_VERSION} -o ${LATEST_VERSION##*/}"
curl -sSL ${LATEST_VERSION} -o ${LATEST_VERSION##*/}


# Extract the FiveM server
echo "Extracting fivem files"
tar xf ${LATEST_VERSION##*/}
rm -rf ${LATEST_VERSION##*/} run.sh # Delete the tar file and the run.sh file to prevent any issues


# Download default server config
if [ -e server.cfg ]; then
  echo "Skipping downloading default server config file as one already exists"
else
  echo "Downloading default fivem config"
  curl https://raw.githubusercontent.com/HostZen/Eggs/refs/heads/main/misc-games/fivem/server.cfg >> server.cfg
fi


# Echo
echo "FiveM server has been installed successfully!"