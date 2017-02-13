#!/bin/sh

./_conf.sh

#docker-compose -f docker-compose-home.yml up --build -d
docker-compose -f ../docker-compose-home.yml up $1