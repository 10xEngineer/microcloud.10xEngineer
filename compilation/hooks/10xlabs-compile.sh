#!/bin/sh
#
# arguments:
# * repository name
# * lab_token
# * revision
# * ref_name

# FIXME hardcoded ip address of compilation node

ssh -A -o "StrictHostKeyChecking=no" -i ~/.ssh/compile compile@176.34.236.201 "cd /home/compile/deploy/compilation && bin/compile.sh $@"
