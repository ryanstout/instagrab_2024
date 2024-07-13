#!/bin/bash

# Build the Docker image
docker build -t proxidize-server .

# Run the Docker container, mapping port 29204
docker run -d -p 29204:29204 --name proxidize-server proxidize-server