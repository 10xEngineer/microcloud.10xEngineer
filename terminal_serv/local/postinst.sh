#!/bin/sh

# fix for node-gyp rebuild error
rm -Rf /root/.node-gyp

su -c "cd /opt/10xlabs/term_serv && npm install --ws:verbose" - root
