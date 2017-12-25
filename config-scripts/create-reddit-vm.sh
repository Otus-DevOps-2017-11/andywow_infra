#!/bin/bash

gcloud compute instances create reddit-baked-app \
  --image-family reddit-full \
  --image-project=windy-skyline-188819 \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
