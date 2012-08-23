#!/bin/sh

set -e

SSH=/usr/bin/ssh

${SSH} -o "StrictHostKeyChecking=no" $1@$2 -i $3 
