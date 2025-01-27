###
# Created on 1/20/2025
# Modified on 1/27/2025
# Image Name: comfyui
###


################################################################
### Base Image
################################################################

# Use an official Python base image
FROM python:3.12-slim


################################################################
###  Environment
################################################################

# Define the working directory for the application
ENV WORKDIR=/comfyui

# Set the working directory within the container
WORKDIR ${WORKDIR}


################################################################
### Users
################################################################

# Specify the default user for running the application
ENV APP_USER=docker

# Create a non-root user and group
RUN groupadd --gid 1000 ${APP_USER} && \
    useradd --uid 1000 --gid 1000 --create-home ${APP_USER}

# Adjust permissions for the working directory
RUN chown -R ${APP_USER}:${APP_USER} ${WORKDIR}


################################################################
### Install/Update Packages & Entrypoint Script
################################################################

# Install required system packages and clean up
RUN apt-get update && \
    apt-get install -y git python3-venv wget curl && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint script to the image
COPY entrypoint.sh ${WORKDIR}/entrypoint.sh

# Make script executable
RUN chmod +x ${WORKDIR}/entrypoint.sh


################################################################
###  ComfyUI
################################################################

# Expose the default port the app listens on
EXPOSE 8188

# Switch to the non-root user
USER ${APP_USER}

# Set the entrypoint to the script
ENTRYPOINT ["./entrypoint.sh"]