var Puggernaut = new function() {
	
	var $ = jQuery;
	var self = this;
	
	this.disabled = false;
	this.path = '/long_poll';
	this.inhabitants = inhabitants;
	this.unwatch = unwatch;
	this.watch = watch;
	this.watch_join = watch_join;
	this.watch_leave = watch_leave;
	
	var channels = {};
	var errors = 0;
	var events = $('<div/>');
	var leaves = {};
	var started = false;
	var request;

	function ajax(join_leave, time, user_id) {
		if (channelLength() > 0 && !self.disabled && errors <= 10) {
			started = true;
			request = $.ajax({
				cache: false,
				data: params(join_leave, time, user_id),
				dataType: 'text',
				error: function(xhr, status, error) {
					if (started && status != 'abort') {
						errors += 1;
						ajax(join_leave, null, user_id);
					}
				},
				success: function(data, status, xhr) {
					if (started) {
						errors = 0;
						$.each(data.split("\n"), function(i, line) {
							line = line.split('|', 4);
							if (line[0] && typeof channels[line[0]] != 'undefined') {
								channels[line[0]] = line[1];
								if (line[2].substring(0, 8) == '!PUGJOIN') {
									var id = line[2].substring(8)
									if (leaves[id]) {
										delete leaves[id];
										clearTimeout(leaves[id]);
									} else
										events.trigger('join_' + line[0], id);
								} else if (line[2].substring(0, 9) == '!PUGLEAVE') {
									var id = line[2].substring(9)
									leaves[id] = setTimeout(function() {
										events.trigger('leave_' + line[0], id);
									}, 10000);
								} else
									events.trigger(line[0], [ line[2], new Date(line[3]) ]);
							}
						});
						ajax(join_leave, null, user_id);
					}
				},
				timeout: 100000,
				traditional: true,
				url: self.path
			});
		} else
			started = false;
	}
	
	function channelLength() {
		var length = 0;
		$.each(channels, function(channel, last) {
			length += 1;
		});
		return length;
	}

	function inhabitants() {
		var args = $.makeArray(arguments);
		var fn = args.pop();
		$.ajax({
			cache: false,
			data: { channel: args },
			dataType: 'text',
			success: function(data, status, xhr) {
				fn(data.split('|'));
			},
			traditional: true,
			url: self.path + '/inhabitants'
		});
	}
	
	function params(join_leave, time, user_id) {
		var ch = [];
		var la = [];

		$.each(channels, function(channel, last) {
			ch.push(channel);
			if (last)
				la.push(last);
		});
		
		var data = { channel: ch };

		if (la.length)
			data.last = la;
		if (join_leave)
			data.join_leave = join_leave;
		if (time)
			data.time = time + '';
		if (user_id)
			data.user_id = user_id;
		
		return data;
	}
	
	function unwatch() {
		var args = $.makeArray(arguments);
		started = false;
		request.abort();
		if (args.length) {
			$.each(args, function(i, item) {
				delete channels[item];
				events.unbind(item);
				events.unbind('join_' + item);
				events.unbind('leave_' + item);
			});
		} else
			events.unbind();
		return this;
	}
	
	function watch() {
		var ch = $.makeArray(arguments);
		var fn = ch.pop();
		var join_leave, time, user_id;

		if (ch[ch.length-1] && ch[ch.length-1].constructor === Object) {
			var options = ch.pop();

			join_leave = options.join_leave;
			time = options.time;
			user_id = options.user_id;
		}
		
		if (ch.length && fn) {
			$.each(ch, function(i, item) {
				channels[item] = channels[item] || null;
				events.bind(item, fn);
			});
			
			if (!started)
				ajax(join_leave, time, user_id);
		}
		
		return this;
	}

	function watch_join() {
		var args = $.makeArray(arguments);
		var fn = args.pop();
		$.each(args, function(i, item) {
			events.bind('join_' + item, fn);
		});
		return this;
	}

	function watch_leave() {
		var args = $.makeArray(arguments);
		var fn = args.pop();
		$.each(args, function(i, item) {
			events.bind('leave_' + item, fn);
		});
		return this;
	}
};