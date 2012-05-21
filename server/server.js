var restify = require('restify');
var log = require('log4js').getLogger();

var routes = require('./routes');

// Setup the REST API
var server = module.exports = restify.createServer({
	name: 'microcloud.10xengineer.me',
	version: '0.0.1'
});
server.use(restify.acceptParser(server.acceptable));
//server.use(restify.authorizationParser());
server.use(restify.dateParser());
server.use(restify.queryParser());
server.use(restify.bodyParser());
server.use(restify.throttle({
	burst: 100,
	rate: 50,
	ip: true,
	overrides: {
		'192.168.1.106': {
			rate: 0, //unlimited
			burst: 0
		},
		'127.0.0.1': {
			rate: 0, //unlimited
			burst: 0
		}
	}
}));
server.use(restify.conditionalRequest());

// register the routes with the server
routes.registerRoutes(server);

server.listen(8080, function() {
  console.log('%s listening at %s', server.name, server.url);
});

// ------------------------------------------------------------------------------------
// Return the admin page

server.get( {url : '/admin'}, function(req, res, next) {
	res.render('ADMIN PAGE TO GO HERE');
});