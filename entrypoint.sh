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

# Check if the repository exists in the volume
if [ ! -d "/comfyui/app/.git" ]; then

    # Print status
    echo "    Alert: Repository not found. Cloning the ComfyUI repository: https://github.com/comfyanonymous/ComfyUI"
    echo " "

    # Clone ComfyUI repo
    git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui/app_tmp

    # Move files to the volume directory
    cp -r /comfyui/app_tmp/* /comfyui/app/
    find /comfyui/app_tmp -name ".*" -exec cp -r {} /comfyui/app/ \;  # Copy hidden files like .git
    rm -rf /comfyui/app_tmp

    # Print status
    echo "[✔] Status: Repository cloned successfully."

else

    # Print status
    echo "[✔] Status: Repository found."

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