#!/bin/zsh

# Create an image
docker-compose build 
# Start a container
docker-compose run --rm terraform bash