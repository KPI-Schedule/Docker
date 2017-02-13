#!/bin/sh

./_conf.sh

#docker-compose -f docker-compose-erp.yml up --build -d
docker-compose -f ../docker-compose-gepard2.yml up $1