#!/bin/sh

ENDPOINT=10.0.2.2
USER=$1
TOKEN=MnMFqjHo368Pmf2R

curl http://${ENDPOINT}/proxy_users/${USER}\?token\=${TOKEN} -H 'Accept: text/plain'