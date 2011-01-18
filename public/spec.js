$(function() {
	
	module("Single", {
		setup: function() {
			Puggernaut.watch('single', function(e, message) {
				equals(message, 'single message');
				Puggernaut.unwatch('single');
				start();
			});
		}
	});
	
	test("should receive a message", function() {
		stop();
		$.get('/single');
	});
	
	module("Multiple", {
		setup: function() {
			var executions = 0;
			Puggernaut.watch('multiple', function(e, message) {
				executions += 1;
				equals(message, 'multiple message ' + executions);
				if (executions == 2) {
					Puggernaut.unwatch('multiple');
					start();
				}
			});
		}
	});
	
	test("should receive multiple messages", function() {
		stop();
		$.get('/multiple');
	});
	
	module("Last", {
		setup: function() {
			var ran = false;
			Puggernaut.watch('last', function(e, message) {
				if (ran == false) {
					ran = true;
					equals(message, 'last message 1');
					Puggernaut.disabled = true;
					$.get('/last/2', function() {
						Puggernaut.disabled = false;
						Puggernaut.watch('last', function(e, message) {
							equals(message, 'last message 2');
							Puggernaut.unwatch('last');
							start();
						});
					});
				}
			});
		}
	});
	
	test("should receive multiple messages", function() {
		stop();
		$.get('/last/1');
	});
});