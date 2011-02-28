$(function() {
	
	module("Single message", {
		setup: function() {
			Puggernaut.watch('single', function(e, message, time) {
				equals(message, 'single message');
				ok(time.constructor === Date);
				Puggernaut.unwatch('single');
				start();
			});
		}
	});
	
	test("should receive a message", function() {
		stop();
		expect(2);
		$.get('/single');
	});

	module("Single message unbind", {
		setup: function() {
			Puggernaut.watch('single', function(e, message, time) {
				equals(message, 'single message');
				ok(time.constructor === Date);
				time_test = [ message, time ];
				Puggernaut.unwatch('single');
			});
		}
	});

	test("should only receive one message", function() {
		stop();
		expect(2);
		$.get('/single', function() {
			$.get('/single', function() {
				setTimeout(function() {
					start();
				}, 2000);
			});
		});
	});

	module("Single message after time");

	test("should receive messages after time", function() {
		stop();
		expect(2);
		var time_now = new Date();
		$.get('/single', function() {
			Puggernaut.watch('single', { time: time_now }, function(e, message, time) {
				equals(message, 'single message');
				ok(time.constructor === Date);
				Puggernaut.unwatch('single');
				start();
			});
		});
	});

	module("Single message inhabitants", {
		setup: function() {
			Puggernaut.watch('single', { user_id: 'test' }, function(e, message, time) {});
		}
	});
	
	test("should receive a message", function() {
		stop();
		expect(2);
		Puggernaut.inhabitants('single', function(users) {
			equals(users[0], 'test');
			equals(users.length, 1);
			Puggernaut.unwatch('single');
			start();
		});
	});

	module("Single message join/leave/join", {
		setup: function() {
			Puggernaut
				.watch('single', { join_leave: true }, function(e, message, time) {})
				.watch_join('single', function(e, user_id) {
					equals(user_id, 'test');
					setTimeout(function() {
						Puggernaut.unwatch('single');
						start();
					}, 1000);
				})
				.watch_leave('single', function(e, user_id) {
					ok(false);
				});
		}
	});
	
	test("should trigger join event without leave", function() {
		stop();
		expect(1);
		$.get('/join_leave_join');
	});
	
	module("Multiple messages", {
		setup: function() {
			var executions = 0;
			Puggernaut.watch('multiple', function(e, message, time) {
				executions += 1;
				equals(message, 'multiple message ' + executions);
				ok(time.constructor === Date);
				if (executions == 2) {
					Puggernaut.unwatch('multiple');
					start();
				}
			});
		}
	});
	
	test("should receive multiple messages", function() {
		stop();
		expect(4);
		$.get('/multiple');
	});
	
	module("Last message", {
		setup: function() {
			Puggernaut.watch('last', function(e, message, time) {
				if (message != 'last message 2') {
					equals(message, 'last message 1');
					ok(time.constructor === Date);
					Puggernaut.disabled = true;
					$.get('/last/2', function() {
						Puggernaut.disabled = false;
						Puggernaut.watch('last', function(e, message, time) {
							equals(message, 'last message 2');
							ok(time.constructor === Date);
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
		expect(4);
		$.get('/last/1');
	});
	
	module("Multiple channels");
	
	test("should receive all messages", function() {
		stop();
		expect(6);
		
		var executions = 0;
		var total_runs = 0;
		
		Puggernaut.disabled = true;
		
		Puggernaut
			.watch('single', function(e, message, time) {
				total_runs += 1;
				equals(message, 'single message');
				ok(time.constructor === Date);
				Puggernaut.unwatch('single');
				if (total_runs == 3)
					start();
			});
		
		Puggernaut.disabled = false;
		
		Puggernaut
			.watch('multiple', function(e, message, time) {
				executions += 1;
				total_runs += 1;
				equals(message, 'multiple message ' + executions);
				ok(time.constructor === Date);
				if (executions == 2)
					Puggernaut.unwatch('multiple');
				if (total_runs == 3)
					start();
		});
		
		$.get('/multiple/channels');
	});
});