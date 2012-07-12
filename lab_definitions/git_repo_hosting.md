# Git repository hosting

Initial implementation is based on Gitolite and custom broker server (gitadm). For development purposes the repositories are hosted on my personal server (RdM).

Administration is available as GIT repo

		git clone ssh://tenx@bunny.laststation.net:440/gitolite-admin

Ping me if you want access (needed for development/testing).

## GIT Repo uses cases

* 1. create new repo 
* 2. clone existing repo - hosted anywhere, only public repositories hosted on github applicable for now
* 3. manage users - flat permissions for now

## Gitolite setup for 10xlabs

Create user (in this case `tenx`) and setup gitolite according to [instructions](https://github.com/sitaramc/gitolite/). Use your public key (don't forget to call it name.pub), otherwise you'll be called `id_rsa`.

Additional steps:

1. add mchammer.pub to `keydir/`
2. create `10xlabs/metadata.json` with following content

		{
			"gitolite-admin":{
				"permissions": [
					{"your_username":"RW+"},
					{"mchammer":"RW+"}
				]
			}
		}

3. Save it and commit