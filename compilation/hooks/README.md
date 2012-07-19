# Gitolite hooks

* add `LOCAL_CODE` to ~/.gitolite.rc pointing to location with hooks (for example `/home/tenx/10xlabs)
* create `hooks/common` within `LOCAL_CODE` location
* create `pre-receive`

Use following hook code (shell script)

		#!/bin/sh

		PATH=~/.rbenv/shims:~/.rbenv/bin:$PATH

		echo `pwd` | grep "gitolite-admin.git$"
		if [ $? -eq 0 ]; then
		  echo "gitolite-admin repository; skipping 10xlabs hooks"
		else
		  ~/compilation/hooks/pre-receive.rb
		fi

Don't forget to run `gitolite setup` to install hooks.

# Maintain Admin repository

Keep gitolite admin repository up-to-date in ~/gitolite-admin.