#!/bin/bash

docker run -d -p 8080:8080 --name fedora --link mysql:db islandora/frontend:latest

