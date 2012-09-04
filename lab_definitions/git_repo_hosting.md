# Git repository hosting

Initial implementation is based on Gitolite and custom broker server (gitadm). 



---



For development purposes the repositories are hosted on my personal server (RdM).

Administration is available as GIT repo

		git clone ssh://tenx@bunny.laststation.net:440/gitolite-admin

Ping me if you want access (needed for development/testing).

## GIT Repo uses cases

* 1. create new repo 
* 2. clone existing repo - hosted anywhere, only public repositories hosted on github applicable for now
* 3. manage users - flat permissions for now

## Gitolite setup for 10xlabs

Initial githosting bootstrap script is

		cd ./chef_repo
		export TARGET=TARGET_HOSTNAME
		./githost_bootstrap.sh

Additional steps:

1. create `10xlabs/metadata.json` with following content

		{
			"gitolite-admin":{
				"permissions": [
					{"tenxgit":"RW+"}
				]
			}
		}

2. Save it and commit