#!/bin/bash


################################################################
### Entrypoint
################################################################

echo "################################################"
echo "### Entrypoint"
echo "################################################"


################################################################
### Clone Repository
################################################################

echo " "
echo "### Clone Repository"
echo " "

# Set release tag and URL for this build
RELEASE_TAG="v0.3.12"
RELEASE_URL="https://github.com/comfyanonymous/ComfyUI/archive/refs/tags/${RELEASE_TAG}.tar.gz"
APP_DIR="/comfyui/app"
TMP_DIR="/comfyui/app_tmp"


# Check if the application files are present
if [ ! -f "${APP_DIR}/README.md" ]; then

    # Print status
    echo "    Alert: ComfyUI files not found. Downloading release: ${RELEASE_TAG}"
    echo " "

    # Create a temporary directory
    mkdir -p "${TMP_DIR}"

    # Download the release tarball
    echo "[ ] Downloading: ${RELEASE_URL}."
    wget -q -O "${TMP_DIR}/release.tar.gz" "${RELEASE_URL}" || curl -sL -o "${TMP_DIR}/release.tar.gz" "${RELEASE_URL}"

    # Extract the release tarball
    echo "[ ] Extracting: Release files."
    tar -xzf "${TMP_DIR}/release.tar.gz" -C "${TMP_DIR}" --strip-components=1

    # Move the files to the application directory
    echo "[ ] Setup: Moving files to application directory."
    mkdir -p "${APP_DIR}"
    cp -r "${TMP_DIR}/"* "${APP_DIR}/"

    # Clean up the temporary directory
    rm -rf "${TMP_DIR}"

    # Print status
    echo "[✔] Status: Release ${RELEASE_TAG} set up successfully."

else
    
    # Print status
    echo "[✔] Status: ComfyUI files found. Skipping download."

fi


################################################################
### Install ComfyUI-Manager
################################################################

echo " "
echo "### Install ComfyUI-Manager"
echo " "

# Check if ComfyUI-Manager is already installed
if [ ! -d "/comfyui/app/custom_nodes/comfyui-manager/.git" ]; then

    # Print status
    echo "    Alert: ComfyUI-Manager not found. Cloning the repository: https://github.com/ltdrdata/ComfyUI-Manager"
    echo " "

    # Clone ComfyUI-Manager repo
    git clone https://github.com/ltdrdata/ComfyUI-Manager /comfyui/app/custom_nodes/comfyui-manager

    # Print status
    echo "[✔] Status: ComfyUI-Manager installed successfully."

else

    # Print status
    echo "[✔] Status: ComfyUI-Manager already installed."

fi


################################################################
### Virtual Environment
################################################################

echo " "
echo " "
echo "### Virtual Environment"
echo " "

# Add local bin directory to PATH
export PATH="/comfyui/venv/bin:/home/docker/.local/bin:$PATH"

# Print status
echo "[✔] Status: Updated PATH: $PATH"

# Check if the virtual environment exists
if [ ! -d "/comfyui/venv/bin" ]; then

    # Print status
    echo " "
    echo "    Alert: Virtual environment not found. Creating virtual environment: /comfyui/venv."
    echo " "

    # Create virtual environment `/comfyui/venv`
    python3 -m venv /comfyui/venv

    # Print status
    echo "[✔] Status: Virtual environment created: /comfyui/venv"

else

    echo "[✔] Status: Virtual environment found: /comfyui/venv"

fi

# Activate the virtual environment
source /comfyui/venv/bin/activate

# Confirm the virtual environment is activated
if [ $? -eq 0 ]; then

    # Print status
    echo "[✔] Status: Virtual environment activated."

else

    # Print status
    echo "[x] Status: Virtual environment failed to activate."
    echo " "
    echo "    Alert: Exiting script."
    echo " "

    # Quit setup
    exit 1

fi


################################################################
### Requirements
################################################################

echo " "
echo " "
echo "### Requirements"
echo " "

# Install dependencies if they are not already installed
if [ ! -f "/comfyui/venv/.dependencies_installed" ]; then

    # Print status
    echo "    Alert: Dependencies not found. Installing dependencies from /comfyui/app/requirements_versions.txt."
    echo " "

    # PIP install requirements
    /comfyui/venv/bin/pip install -r /comfyui/app/requirements.txt
    /comfyui/venv/bin/pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

    # Create file flag to indicate dependencies have been installed
    touch /comfyui/venv/.dependencies_installed

    # Print status
    echo " "
    echo "[✔] Status: Dependencies installed successfully."

else

    # Print status
    echo "[✔] Status: Dependencies already installed."
    
fi


################################################################
### Variables
################################################################

echo " "
echo " "
echo "### Variables"
echo " "

# Navigate to the repo directory and start the application
cd /comfyui/app

# Determine if `listen` was set in Docker
LISTEN_ADDRESS_FLAG=""

if [ -n "$LISTEN_ADDRESS" ] && [ "$LISTEN_ADDRESS" != "none" ]; then

    # Set LISTEN_ADDRESS_FLAG
    LISTEN_ADDRESS_FLAG="--listen $LISTEN_ADDRESS"

    # Print status
    echo "[+] LISTEN_ADDRESS: $LISTEN_ADDRESS"

else

    # Print status
    echo "[-] LISTEN_ADDRESS: 127.0.0.1"

fi


################################################################
### ComfyUI
################################################################

echo " "
echo " "
echo "################################################"
echo "### ComfyUI"
echo "################################################"
echo " "
echo " "

echo "Starting ComfyUI:"
echo " "
echo "    python main.py $LISTEN_ADDRESS_FLAG"

echo " "
echo " "
echo "################################################"
echo " "

# Start the application with the determined arguments
/comfyui/venv/bin/python main.py $LISTEN_ADDRESS_FLAG