#!/bin/sh

ssh-add /home/compile/.ssh/id_rsa
bundle exec ruby compile.rb $@