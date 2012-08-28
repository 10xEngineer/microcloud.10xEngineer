#!/bin/sh

ssh -o "StrictHostKeyChecking no" -i /tmp/bootstrap.key ${@}