var Puggernaut = new function() {
	
	var $ = jQuery;
	var self = this;
	
	this.disabled = false;
	this.path = '/long_poll';
	this.inhabitants = inhabitants;
	this.unwatch = unwatch;
	this.watch = watch;
	
	var channels = {};
	var errors = 0;
	var events = $('<div/>');
	var started = false;
	var request;

	function ajax(time, user_id) {
		if (channelLength() > 0 && !self.disabled && errors <= 10) {
			started = true;
			request = $.ajax({
				cache: false,
				data: params(time, user_id),
				dataType: 'text',
				error: function(xhr, status, error) {
					if (started && status != 'abort') {
						errors += 1;
						ajax();
					}
				},
				success: function(data, status, xhr) {
					if (started) {
						errors = 0;
						$.each(data.split("\n"), function(i, line) {
							line = line.split('|', 4);
							if (line[0] && typeof channels[line[0]] != 'undefined') {
								channels[line[0]] = line[1];
								events.trigger(line[0], [ line[2], new Date(line[3]) ]);
							}
						});
						ajax();
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
	
	function params(time, user_id) {
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
			});
		} else
			events.unbind();
		return this;
	}
	
	function watch() {
		var ch = $.makeArray(arguments);
		var fn = ch.pop();
		var user_id, time;

		if (ch[ch.length-1] && ch[ch.length-1].constructor === Object) {
			var options = ch.pop();
			time = options.time;
			user_id = options.user_id;
		}
		
		if (ch.length && fn) {
			$.each(ch, function(i, item) {
				channels[item] = channels[item] || null;
				events.bind(item, fn);
			});
			
			if (!started)
				ajax(time, user_id);
		}
		
		return this;
	}
};