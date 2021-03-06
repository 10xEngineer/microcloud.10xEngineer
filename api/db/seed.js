	// === Microclouds
db.microclouds.drop();

mc_default = {
	name: "dev-1",
	endpoint_url: "mc.default.labs.dev",
	disabled: false,

	created_at: new Date(), updated_at: new Date(), deleted_at: null
}
db.microclouds.save(mc_default);

// Limit Profiles
db.profiles.drop();

beta = {
	name: "beta_public",
	machines: 2,
	memory: 1024,
	transfer: 2048
}

db.profiles.save(beta)

// === Users - default password is 'lab123'
db.users.drop();

demo = {
	email: "demo@10xengineer.me",
	name: "Demo Lab User",
	password: '$2a$10$zYieNqhUQE5ZKGqhOA5ck.fYPQ9Qoj25diVDiu99.jdOQr9M3MGei',
	salt: 'fBCSyorrywT4qqzK1BsC',
	limits: {machines:2, memory: 1024, transfer: 2048},
	service: false,
	disabled: false,
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}
db.users.save(demo);

radim = {
	email: "radim@10xengineer.me",
	name: "Radim Marek",
	password: '$2a$10$zYieNqhUQE5ZKGqhOA5ck.fYPQ9Qoj25diVDiu99.jdOQr9M3MGei',
	salt: 'fBCSyorrywT4qqzK1BsC',
	limits: {machines:10, memory: 10240, transfer: 5192},
	service: false,
	disabled: false,
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.users.save(radim);

dev_1 = {
	email: "support+dev-1@10xengineer.me",
	name: "dev-1",
	cpwd: '$2a$10$Jkr42F/TxB/kLxhGW3oSh.Z4fK57WTCbW5qmjYNG.VtBcjtb7tDvu',
	limits: {machines:0, memory: 0, transfer: 0},
	service: true,
	disabled: false,
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.users.save(dev_1);

http_proxy = {
	email: "support+http-proxy@10xengineer.me",
	name: "http-proxy",
	cpwd: '$2a$10$Jkr42F/TxB/kLxhGW3oSh.Z4fK57WTCbW5qmjYNG.VtBcjtb7tDvu',
	limits: {machines:0, memory: 0, transfer: 0},
	service: true,
	disabled: false,
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.users.save(http_proxy);

// === Access Tokens
//
// require('crypto').randomBytes(14, function(ex, buf) {
// 	console.log(buf.toString('hex').replace(/\//g,'_').replace(/\+/g,'-'));
// });
//
// token:14, secret:24

db.access_tokens.drop()

demo_token = {
	user_id: demo._id,
	alias: 'default',
	auth_token: 'a7b59762d8d7523f797b1ca83e33',
	auth_secret: '0ec6bc855e719fc0638429c1fa04226fa7931f90ea6339af',
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}
db.access_tokens.save(demo_token);

radim_token = {
	user_id: radim._id,
	alias: 'default',
	auth_token: '7f08fe3106f287e001a3f1752a09',
	auth_secret:'4223305def98423ef13fd8463a2705f6d90f350571e95194',
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}
db.access_tokens.save(radim_token);

dev_1_token = {
	user_id: dev_1._id,
	alias: 'default',
	auth_token: 'f933c346c502c11b64164143087f',
	auth_secret: '55347d223f161014a8659361afe771929f61246d09a3b22f',
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.access_tokens.save(dev_1_token);

http_proxy_token = {
	user_id: http_proxy._id,
	alias: 'default',	           
	auth_token: 'af124df24862fb214a7385c37acd',	          
	auth_secret: '73dbede5a8cbef14cfd67892a4ad039bb71c6b82b83e9f32',
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.access_tokens.save(http_proxy_token);

// === Account 
db.accounts.drop();

demo_account = {
	handle: 'demo',
	account_ref: 'ac-344e22a',
	owners: [demo._id],

	disabled: false,
	organization: false,

	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.accounts.save(demo_account)

// internal account
internal_account = {
	handle: '_internal',
	account_ref: 'ac-451a23aa',
	owners: [radim],

	disabled: false,
	organization: false,

	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.accounts.save(internal_account)

db.users.update({_id: demo._id}, {$set: {def_account: demo_account._id}})
db.users.update({_id: dev_1._id}, {$set: {def_account: internal_account._id}})

// === Keys
db.keys.drop();

db.keys.save({
	name: "default",
	fingerprint: "1b:4f:d1:e3:35:61:28:b2:9b:cb:bc:e2:a0:e5:3c:58",
	public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAYEAvv0rqbFbirX3wHlQE0d/c1zR+mEG4B0nGynBjvHbG0jwQuUSIHu2ZyQaveqiqoEsOMT1HdyoHZw9cHNI2VA9xNb0Ou4n7xUKYRYJwEGWHTSlB1r5ScVw4GIK8lkd2GMmQVzBYWIbY2EmfpT/s6Cmqn4SgmfbCJXxhkA9lO0Dixd2hlSlmEvG1ar/3Zfzg/Xsaf14y2tC8qh5Y1moGYOH4DHIQjhcnicgDBTa5RUQny7wcmVE2i4RdNSd4uGYTJ1Cnu397Go5ANdt5eAuOZnR2hOIUDSeGXKgqcUyG8ERVCmwJ3NXf9nfLH15jrZpahqVcOmmy+FaaKTXyTHwkj47KBRf9kGrq5S7KyLX+JsXvoVnYoqFA3aOmq0QuFXVqF89oJ2qj8oRBuZuuSALQo1Uv7J2qd1/7CsvdCTJ6crSZaD08T/dJkbH++ORCV6BWTPN9nPlHbLatShXiwrZYAW3gxNxggjYuz2g48Xdz4pSpovg5ASJXBRLOlcRyiWgfqQT",
	user_id: demo._id,
	created_at: new Date(), updated_at: new Date(), deleted_at: null
})