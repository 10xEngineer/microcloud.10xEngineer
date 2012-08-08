# Gitolite hooks

For ruby add .bundle/config 

		---                                                                             
		BUNDLE_PATH: vendor/bundle

* add `LOCAL_CODE` to ~/.gitolite.rc pointing to location with compilation directory (for example `/home/tenx/compilation)
* add `~/.ssh/compile` private key
* don't forget to add target GIT repo hosting key to .ssh/known_host ([known issue](https://trello.com/card/ssh-wrapper-for-compile-service-git-clone/50067c2712a969ae032917f4/33))

Don't forget to run `gitolite setup` to install hooks.

# Maintain Admin repository

Keep gitolite admin repository up-to-date in ~/gitolite-admin.