module.exports = function() {};

module.exports.status = function(req, res, next) {
	res.send('pool_status NOT IMPLEMENTED');
}

module.exports.startup = function(req, res, next) {
	res.send('pool_startup NOT IMPLEMENTED');
}

module.exports.shutdown = function(req, res, next) {
	res.send('pool_shutdown NOT IMPLEMENTED');
}

module.exports.addserver = function(req, res, next) {
	res.send('pool_addserver NOT IMPLEMENTED');
}

module.exports.removeserver = function(req, res, next) {
	res.send('pool_removeserver NOT IMPLEMENTED');
}

module.exports.allocate = function(req, res, next) {
	res.send('pool_allocate NOT IMPLEMENTED');
}

module.exports.deallocate = function(req, res, next) {
	res.send('pool_deallocate NOT IMPLEMENTED');
}
