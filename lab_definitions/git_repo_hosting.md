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

GIT hosting bootstrap script is

		cd ./chef_repo
		export TARGET=TARGET_HOSTNAME
		./githost_bootstrap.sh

Private key for the default access is `chef_repo/cookbooks/10xlab-githost/files/default/tenxgit`

For each deployed GIT host you still need to do follow manual setup within `gitolite-admin` repository

1. create 10xlabs/metadata.json with following content

	{
	    "gitolite-admin":{
	        "permissions": [
	            {"tenxgit":"RW+"},
	            {"mchammer":"RW+"}
	        ]
	    }
	}

2. Add user `mchammer` to conf/gitotline.conf with RW+ access to `gitolite-admin` repository.