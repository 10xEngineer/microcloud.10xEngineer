db.users.drop();
db.access_tokens.drop()
db.accounts.drop()

// demo@10xengineer.me / lab123
email = 'demo@10xengineer.me'

demo_user = {
	email: email, 
	cpwd: '$2a$10$Jkr42F/TxB/kLxhGW3oSh.Z4fK57WTCbW5qmjYNG.VtBcjtb7tDvu',
	service: false,
	disabled: false,
	meta: {
		created_at: new Date(),
		updated_at: new Date(),
		deleted_at: new Date()
	}
}

db.users.save(demo_user)
demo = db.users.findOne({email: email})

// demo access token
demo_token = {
	user: demo._id,
	alias: 'default',
	auth_token: 'a7b59762d8d7523f797b1ca83e33',
	auth_secret: '0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af'
}

db.access_tokens.save(demo_token)

// account
demo_account = {
	handle: 'demo',
	owners: [demo._id],

	disabled: false,
	organization: false,

	meta: {
		created_at: new Date(),
		updated_at: new Date(),
		deleted_at: new Date()
	}
}

db.accounts.save(demo_account)

account = db.accounts.findOne({handle: 'demo'})
db.users.update({_id: demo._id}, {$set: {def_account: account._id}})