Puggernaut
==========

Simple server push implementation using eventmachine and long polling.

![Puggernaut](/winton/puggernaut/raw/master/puggernaut.png)

Requirements
------------

<pre>
gem install puggernaut
</pre>

How it works
------------

Puggernaut consists of three pieces:

* TCP client to send push messages
* TCP server to receive push messages
* HTTP server to deliver long poll requests

Start it up
-----------

Run the <code>puggernaut</code> binary with optional port numbers:

<pre>
puggernaut &lt;http port&gt; &lt;tcp port&gt;
</pre>

The default HTTP and TCP ports are 8000 and 8001, respectively.

Send push messages
------------------

<pre>
require 'puggernaut'

client = Puggernaut::Client.new("localhost:8001", "localhost:9001")
client.push :channel => "message"
client.push :channel => [ "message 1", "message 2" ], :channel_2 => "message"
</pre>

The <code>Client.new</code> initializer accepts any number of TCP server addresses.

Set up proxy pass
-----------------

You will need to set up a URL on your public facing web server that points to the Puggernaut HTTP server.

If you do not see your web server below, [Google](http://google.com) is your friend.

### Apache

*http.conf*

<pre>
ProxyPass /long_poll http://localhost:8000
ProxyPassReverse /long_poll http://localhost:8000
</pre>

### Nginx

*nginx.conf*

<pre>
location /long_poll {
  proxy_pass http://localhost:8000
}
</pre>

Receive push messages
---------------------

Include [puggernaut.js](/winton/puggernaut/public/puggernaut.js) into to your HTML page.

Javascript client example:

<pre>
Puggernaut('/long_poll')
  .watch('channel', function(message) {
    // do something with message
  })
  .watch('channel_2', function(message) {
    // do something with message
  });
</pre>