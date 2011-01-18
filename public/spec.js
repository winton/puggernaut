$(function() {
	
	module("Basic", {
		setup: function() {
			Puggernaut.watch('basic', function(e, message) {
				equals(message, 'basic message');
				start();
			});
		},
		teardown: function() {
			Puggernaut.unwatch('test');
		}
	});
	
	test("should receive a message", function() {
		stop();
		$.get('/basic/push');
	});
});