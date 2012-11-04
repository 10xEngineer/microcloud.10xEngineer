db.pools.drop();

default_pool = {
	name: "default",
	nodes: [],
	allocation: "random",
	disabled: false,
	statistics: {},
	created_at: new Date(), updated_at: new Date(), deleted_at: null
}

db.pools.save(default_pool);

// ssh proxies
db.proxy_users.drop()

db.proxy_users.save({name: 'lab-ec649', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-b3fa4', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-1311f', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-4e718', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-b697e', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-4e3c3', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-718e2', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-9fdfa', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-0f8a6', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-fc290', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-3862f', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-66c55', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-f3a53', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-bd78e', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-2d868', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-aefcb', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-4c945', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-9c8c9', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-880a7', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-ab010', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-1f803', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-dee75', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-60bfd', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-016b8', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-b6d45', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-ea13e', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-f690e', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-8f127', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-31edc', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-c8ac4', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-21d55', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-978d6', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-94079', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-29043', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-31911', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-cc54f', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-37cd1', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-17344', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-39647', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-ccde9', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-33410', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-fd92e', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-c5564', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-3c2cd', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-15ab6', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-aedf7', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-d8d6b', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-1e2f2', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-21137', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})
db.proxy_users.save({name: 'lab-a3bf8', disabled: false, created_at: new Date(), updated_at: new Date(), deleted_at: null})