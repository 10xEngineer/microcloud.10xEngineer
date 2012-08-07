# Gitolite hooks

For ruby add .bundle/config 

		---                                                                             
		BUNDLE_PATH: vendor/bundle

* add `LOCAL_CODE` to ~/.gitolite.rc pointing to location with compilation directory (for example `/home/tenx/compilation)
* add `~/.ssh/compile` private key

Don't forget to run `gitolite setup` to install hooks.

# Maintain Admin repository

Keep gitolite admin repository up-to-date in ~/gitolite-admin.