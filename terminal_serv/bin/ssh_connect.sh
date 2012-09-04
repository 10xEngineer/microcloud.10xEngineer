#!/bin/sh

set -e

SSH=/usr/bin/ssh
key=/tmp/$1.key

chmod 0600 $key
${SSH} -o "StrictHostKeyChecking=no" $2@$3 -i $key

