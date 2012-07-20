#!/bin/sh

ssh-add /home/tenx/.ssh/id_rsa
bundle exec ruby compile.rb $@