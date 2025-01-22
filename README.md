# Docker Image - ComfyUI

_Revision Date: 1/21/2025_


<!---------- BREAK START ------------->
<!---------> &nbsp;<br>
<!---------- BREAK END --------------->

# Overview

This image installs Rill based on their install script: `curl https://rill.sh | sh` taken from [https://www.rilldata.com/](https://www.rilldata.com/).


<!---------- BREAK START ------------->
<!---------> &nbsp;<br>
<!---------- BREAK END --------------->


# Build Image

- **Docker Hub** image is accessible here: [automaatio / comfyui](https://hub.docker.com/repository/docker/automaatio/comfyui/general)
- `Dockerfile` is accesible here: [automaatio-dev / comfyui / Dockerfile](Dockerfile)

Example instructions for how to build and push this image:

```
docker buildx build --push --platform linux/amd64 \
  --tag automaatio/comfyui:latest \
  --tag automaatio/comfyui:0.3.12 .
```


<!---------- BREAK START ------------->
<!---------> &nbsp;<br>
<!---------- BREAK END --------------->


# Nvidia Drivers for Docker Containers

This image was made for usage with an Nvidia GPU. The following steps should be run on the host machine.

- Configure the production repository

```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

- Update packages and install drivers

```
sudo -i
apt update && apt upgrade -y
apt install nvidia-container-toolkit -y
```

- Configure Docker runtime

```
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker
```


<!---------- BREAK START ------------->
<!---------> &nbsp;<br>
<!---------- BREAK END --------------->


# Docker Compose

- Example [docker-compose.yml](docker-compose.yml) for running this image
- Example [docker-compose.env](docker-compose.env) for environment variables

Access the web ui by going to `http://localhost:8188/`.

```
# Docker-Compose

################################################
# Services
################################################

services:

  ################################################
  # ComfyUI
  ################################################

  comfyui:
    image: "automaatio/comfyui:latest"
    container_name: "comfyui"
    environment:
      PUID: ${PUID}
      PGID: ${PGID}
      TZ: ${TZ}
      NVIDIA_VISIBLE_DEVICES: ${NVIDIA_VISIBLE_DEVICES}
      CUDA_VISIBLE_DEVICES: ${CUDA_VISIBLE_DEVICES}
      NVIDIA_DRIVER_CAPABILITIES: ${NVIDIA_DRIVER_CAPABILITIES}
      LISTEN_ADDRESS: ${LISTEN_ADDRESS}
    runtime: "nvidia"
    restart: "unless-stopped"
    ports:
      - "8188:8188"
    volumes:
      - "/home/docker/comfyui/app:/comfyui/app"
      - "/home/docker/comfyui/venv:/comfyui/venv"
    networks:
      - "comfyui"


################################################
# Networks
################################################

networks:
  comfyui:
    name: "comfyui"
```