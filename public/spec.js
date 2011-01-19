$(function() {
	
	module("Single message", {
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
	
	module("Multiple messages", {
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
	
	module("Last message", {
		setup: function() {
			Puggernaut.watch('last', function(e, message) {
				if (message != 'last message 2') {
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
	
	test("should pick up last message", function() {
		stop();
		$.get('/last/1');
	});
	
	module("Multiple channels");
	
	test("should receive all messages", function() {
		stop();
		
		var executions = 0;
		var total_runs = 0;
		
		Puggernaut.disabled = true;
		
		Puggernaut
			.watch('single', function(e, message) {
				total_runs += 1;
				equals(message, 'single message');
				Puggernaut.unwatch('single');
				if (total_runs == 3)
					start();
			});
		
		Puggernaut.disabled = false;
		
		Puggernaut
			.watch('multiple', function(e, message) {
				executions += 1;
				total_runs += 1;
				equals(message, 'multiple message ' + executions);
				if (executions == 2)
					Puggernaut.unwatch('multiple');
				if (total_runs == 3)
					start();
		});
		
		$.get('/multiple/channels');
	});
});