#!/bin/sh
#
# arguments:
# * repository name
# * lab_token
# * revision
# * ref_name

# FIXME hardcoded ip address of compilation node
. /home/git/.compile.conf

ssh -A -o "StrictHostKeyChecking no" -i ~/.ssh/compile compile@$COMPILE_NODE"cd /home/compile/deploy/compilation && bin/compile.sh $@"
