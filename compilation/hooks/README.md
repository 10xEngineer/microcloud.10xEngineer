# Gitolite hooks

* add `LOCAL_CODE` to ~/.gitolite.rc pointing to location with hooks
* create `hooks/common` within `LOCAL_CODE` location
* create `pre-receive`

Use following hook code (shell script)

		#!/bin/sh

		PATH=~/.rbenv/shims:~/.rbenv/bin:$PATH

		echo `pwd` | grep "gitolite-admin.git$"
		if [ $? -eq 0 ]; then
		  echo "gitolite admin repository; skipping pre-receive hook"
		else
		  ~/compilation/hooks/pre-receive.rb
		fi