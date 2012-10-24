db.users.drop();
db.access_tokens.drop()
db.accounts.drop()

// demo@10xengineer.me / lab123
email = 'demo@10xengineer.me'

demo_user = {
	email: email,
	name: "Demo Lab User",
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

// radim@laststation.net / lab123
email = 'radim@laststation.net'

radim_user = {
	email: email,
	name: "Radim Marek",
	cpwd: '$2a$10$Jkr42F/TxB/kLxhGW3oSh.Z4fK57WTCbW5qmjYNG.VtBcjtb7tDvu',
	service: false,
	disabled: false,
	meta: {
		created_at: new Date(),
		updated_at: new Date(),
		deleted_at: new Date()
	}	
}

db.users.save(radim_user)
radim = db.users.findOne({email: email})

// demo access token
// 
// token:14, secret:24
// require('crypto').randomBytes(14, function(ex, buf) {
// 	console.log(buf.toString('hex').replace(/\//g,'_').replace(/\+/g,'-'));
// });
demo_token = {
	user: demo._id,
	alias: 'default',
	auth_token: 'a7b59762d8d7523f797b1ca83e33',
	auth_secret: '0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af'	 
}

db.access_tokens.save(demo_token)

radim_token = {
	user: radim._id,
	alias: 'default',
	auth_token: '7f08fe3106f287e001a3f1752a09',
	auth_secret:'4223305def98423ef13fd8463a2705f6d90f350571e95194' 
}

db.access_tokens.save(radim_token)

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

// internal account
internal_account = {
	handle: '_internal',
	owners: [radim],

	disabled: false,
	organization: false,

	meta: {
		created_at: new Date(),
		updated_at: new Date(),
		deleted_at: new Date()		
	}
}

db.accounts.save(internal_account)

account = db.accounts.findOne({handle: 'demo'})
db.users.update({_id: demo._id}, {$set: {def_account: account._id}})