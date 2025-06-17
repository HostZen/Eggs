#!/bin/bash

# FiveM Installation Script
# HostZen (c) 2025. All rights reserved.
# Jack Perry <jack@hostzen.net>

## Update Apt
apt update -y
apt install -y jq curl tar xz-utils sed grep

# Hardcoded variables
CHANGELOGS_PAGE=$(curl -sSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server)
RELEASE_PAGE=$(curl -sSL https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/)

CRITIAL_VERSION=$(echo $CHANGELOGS_PAGE | jq -r '.critical_download')
RECOMMENDED_VERSION=$(echo $CHANGELOGS_PAGE | jq -r '.recommended_download')
OPTIONAL_VERSION=$(echo $CHANGELOGS_PAGE | jq -r '.optional_download')
LATEST_VERSION=$(echo $CHANGELOGS_PAGE | jq -r '.latest_download')

DOWNLOAD_LINK=""
FIVEM_VERSION=${FIVEM_VERSION:-recommended}

# Get the download link based on the FIVEM_VERSION environment variable
case "${FIVEM_VERSION}" in
  "recommended")
    DOWNLOAD_LINK=$RECOMMENDED_VERSION
    ;;
  "latest")
    DOWNLOAD_LINK=$LATEST_VERSION
    ;;
  "critical")
    DOWNLOAD_LINK=$CRITIAL_VERSION
    ;;
  "optional")
    DOWNLOAD_LINK=$OPTIONAL_VERSION
    ;;
  *)
    # Extract the version link containing the specified FIVEM_VERSION
    VERSION_LINK=$(echo -e "${RELEASE_PAGE}" | grep -Eo '".*/*.tar.xz"' | sed 's/\"//g' | sed 's/\.\///1' | grep -i "${FIVEM_VERSION}" | grep -o '=.*' | tr -d '=')
    if [[ -z "${VERSION_LINK}" ]]; then
      echo "[WARN] Version specified does not exist on releases page. Defaulting to latest server artifact."
      DOWNLOAD_LINK=$LATEST_VERSION
    else
      DOWNLOAD_LINK="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${VERSION_LINK}"
    fi
    ;;
esac

echo "Using download link: ${DOWNLOAD_LINK}"

# Check if DOWNLOAD_URL environment variable is set
if [ -n "${DOWNLOAD_URL}" ]; then
  # Validate that the URL is accessible using curl
  if curl --output /dev/null --silent --head --fail "${DOWNLOAD_URL}"; then
    echo "Link is valid. Using the download link."
  else
    echo "Error: Provided download URL is invalid. Exiting."
    exit 2
  fi
fi

echo -e "Running curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}"
cd /mnt/server
curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}

echo "Extracting fivem files"
FILE_NAME=${DOWNLOAD_LINK##*/}

# Extract the tar.xz file
tar -xf $FILE_NAME

# Check if extraction was successful
if [ $? -eq 0 ]; then
  echo "Successfully extracted $FILE_NAME"
else
  echo "Failed to extract $FILE_NAME"
  exit 1
fi

# Remove unused files
rm -rf ${DOWNLOAD_LINK##*/} run.sh


# If TXADMIN_ENABLE is 1, return now and exit
if [ "${TXADMIN_ENABLE}" == "1" ]; then
  echo "Skipping resource download as txAdmin is enabled"
  exit 0
fi 

# If txAdmin is not enabled, download the resources
mkdir -p /mnt/server/{resources,logs}

echo "Downloading default CitizenFX resources"
git clone https://github.com/citizenfx/cfx-server-data.git /tmp
cp -Rf /tmp/resources/* resources/[cfx]/
rm -rf /tmp/cfx-server-data

# Download the default server config file if it does not exist
if [ -e server.cfg ]; then
  echo "Skipping downloading default server.cfg as it already exists"
else
  echo "Downloading default FXServer config file"
  curl -o server.cfg https://raw.githubusercontent.com/parkervcp/eggs/master/game_eggs/gta/fivem/server.cfg
fi

echo "Install complete"
