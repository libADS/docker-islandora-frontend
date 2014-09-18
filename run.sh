#!/bin/bash

docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source islandora/frontend:latest

