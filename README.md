Puggernaut
==========

Simple server push implementation using eventmachine and long polling.

![Puggernaut](https://github.com/winton/puggernaut/raw/master/puggernaut.png)

Requirements
------------

<pre>
gem install puggernaut
</pre>

How it works
------------

Puggernaut consists of four pieces:

* TCP client to send push messages
* TCP server to receive push messages
* TCP server to deliver messages via WebSockets ([em-websocket](https://github.com/igrigorik/em-websocket))
* HTTP server to deliver messages via long poll

Start it up
-----------

Run the <code>puggernaut</code> binary with optional port numbers:

<pre>
puggernaut &lt;http port&gt; &lt;tcp port&gt; &lt;tcp port (websocket)&gt;
</pre>

The default HTTP and TCP ports are 8100, 8101, and 8102, respectively.

Set up proxy pass
-----------------

Set up a URL on your public facing web server that points to the Puggernaut HTTP server (long poll).

We all use Nginx, right?

### nginx.conf

<pre>
server {
	location /long_poll {
	  proxy_pass http://localhost:8100/;
	}
}
</pre>

Send push messages
------------------

<pre>
require 'puggernaut'

client = Puggernaut::Client.new("localhost:8101", "localhost:9101")
client.push :channel => "message"
client.push :channel => [ "message 1", "message 2" ], :channel_2 => "message"
</pre>

The <code>Client.new</code> initializer accepts any number of TCP server addresses.

Receive push messages
---------------------

Include [jQuery](http://jquery.com) and [puggernaut.js](https://github.com/winton/puggernaut/public/puggernaut.js) into to your HTML page.

Javascript client example:

<pre>
Puggernaut.path = '/long_poll'; // (default long poll path)
Puggernaut.port = 8102; 		// (default WebSocket port)

Puggernaut
  .watch('channel', function(e, message) {
    // do something with message
  })
  .watch('channel_2', function(e, message) {
    // do something with message
  });

Puggernaut.unwatch('channel');
</pre>

Running specs
-------------

Specs are a work in progress, though we can vouch for some of the functionality :).

Set up Nginx to point to a cloned copy of this project:

### nginx.conf

<pre>
server {
	listen 80;
	server_name localhost;
	root /Users/me/puggernaut/public;
	passenger_enabled on;
	
	location /long_poll {
		proxy_pass http://localhost:8100/;
	}
}
</pre>

You have now set up an instance of [Puggernaut's spec server](https://github.com/winton/puggernaut/blob/master/lib/puggernaut/spec_server.rb).

Start up an instance of Puggernaut by running <code>bin/puggernaut</code>.

When you visit <code>http://localhost</code> you will find a page that executes [QUnit specs](https://github.com/winton/puggernaut/blob/master/public/spec.js).