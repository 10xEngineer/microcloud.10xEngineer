# Misc

call flow


Server.prototype.initIO sockets.on('connection') -> socket.io as entry point
Server.prototype.handleConnection
Session.prototype.handleCreate
pty.fork (TARGET)


TODO establish session data within the authentication
TODO data is stored in socket.handshake
TODO session.handleCreate should have access to socket via this.socket

---- auth flow ----

1. Server.socket.io.on('authorization') -> self.handleAuth(data, next)
2. Server.handleAuth(data, next) -> this._auth(data, null, next)
where _auth = _BasicAuth
3. _basicAuth returns express.basicAuth(verify)
	- build hashedUsers from users hash
	- calls next, user


--- work in progress ----

TODO provide own BasicAuth
TODO authentication is triggered for all resources at the same time 
	 res == null for socket.io calls

callback (verify) can have more than 3 params
https://github.com/senchalabs/connect/blob/master/lib/middleware/basicAuth.js#L82




-> ENTRY point setAuth


headers.host 

--- tty.js authorization
{ headers: 
   { host: 'localhost:9000',
     connection: 'keep-alive',
     authorization: 'Basic Zm9vOmJhcg==',
     'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.82 Safari/537.1',
     accept: '*/*',
     referer: 'http://localhost:9000/',
     'accept-encoding': 'gzip,deflate,sdch',
     'accept-language': 'en-US,en;q=0.8',
     'accept-charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3' },
  address: { address: '127.0.0.1', port: 49865 },
  time: 'Wed Aug 22 2012 11:20:30 GMT+0200 (CEST)',
  query: { t: '1345627230835' },
  url: '/socket.io/1/?t=1345627230835',
  xdomain: false,
  secure: undefined,
  issued: 1345627230840 }


--- socket connection
{ id: '5766875211151188841',
  namespace: 
   { manager: 
      { server: [Object],
        namespaces: [Object],
        sockets: [Circular],
        _events: [Object],
        settings: [Object],
        handshaken: [Object],
        connected: [Object],
        open: [Object],
        closed: {},
        rooms: [Object],
        roomClients: [Object],
        oldListeners: [Object],
        gc: [Object] },
     name: '',
     sockets: { '5766875211151188841': [Circular] },
     auth: false,
     flags: { endpoint: '', exceptions: [] },
     _events: { connection: [Object] } },
  manager: 
   { server: 
      { _connections: 7,
        connections: [Getter/Setter],
        allowHalfOpen: true,
        _handle: [Object],
        httpAllowHalfOpen: false,
        _events: [Object],
        _connectionKey: '4:0.0.0.0:9000' },
     namespaces: { '': [Object] },
     sockets: 
      { manager: [Circular],
        name: '',
        sockets: [Object],
        auth: false,
        flags: [Object],
        _events: [Object] },
     _events: 
      { 'set:transports': [Object],
        'set:store': [Function],
        'set:origins': [Function],
        'set:flash policy port': [Function] },
     settings: 
      { origins: '*:*',
        log: false,
        store: [Object],
        logger: [Object],
        static: [Object],
        heartbeats: true,
        resource: '/socket.io',
        transports: [Object],
        authorization: [Function],
        blacklist: [Object],
        'log level': 3,
        'log colors': true,
        'close timeout': 60,
        'heartbeat interval': 25,
        'heartbeat timeout': 60,
        'polling duration': 20,
        'flash policy server': true,
        'flash policy port': 10843,
        'destroy upgrade': true,
        'destroy buffer size': 100000000,
        'browser client': true,
        'browser client cache': true,
        'browser client minification': false,
        'browser client etag': false,
        'browser client expires': 315360000,
        'browser client gzip': false,
        'browser client handler': false,
        'client store expiration': 15,
        'match origin protocol': false },
     handshaken: { '5766875211151188841': [Object] },
     connected: { '5766875211151188841': true },
     open: { '5766875211151188841': true },
     closed: {},
     rooms: { '': [Object] },
     roomClients: { '5766875211151188841': [Object] },
     oldListeners: [ [Object] ],
     gc: { ontimeout: [Function] } },
  disconnected: false,
  ackPackets: 0,
  acks: {},
  flags: { endpoint: '', room: '' },
  readable: true,
  store: 
   { store: { options: undefined, clients: [Object], manager: [Object] },
     id: '5766875211151188841',
     data: {} },
  _events: { error: [Function] } }