// Limit Profiles
db.profiles.drop();

beta = {
	name: "beta_public",
	machines: 2,
	memory: 1024,
	transfer: 2048
}

db.profiles.save(beta)

// Users

eu_1_aws = {
	email: "support+eu-1-aws@10xengineer.me",
	name: "dev-1",
	cpwd: '$2a$10$Jkr42F/TxB/kLxhGW3oSh.Z4fK57WTCbW5qmjYNG.VtBcjtb7tDvu',
	limits: {machines:0, memory: 0, transfer: 0},
	service: true,
	disabled: false,
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.users.save(eu_1_aws);

// Token

eu_1_token = {
	user_id: eu_1_aws._id,
	alias: 'default',
	auth_token: 'f933c346c502c11b64164143087f',
	auth_secret: '55347d223f161014a8659361afe771929f61246d09a3b22f',
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}
db.access_tokens.save(eu_1_token);