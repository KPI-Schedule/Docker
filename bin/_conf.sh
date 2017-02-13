#!/usr/bin/env bash

scope launch

if [ -f ../nginx/_default.conf ]; then
    rm ../nginx/_default.conf
fi

cat ../nginx/*.conf >> ../nginx/_default.conf