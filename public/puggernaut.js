var Puggernaut = new function() {
	
	var $ = jQuery;
	var self = this;
	
	this.disabled = false;
	this.path = '/long_poll';
	this.unwatch = unwatch;
	this.watch = watch;
	
	var channels = {};
	var errors = 0;
	var events = $('<div/>');
	var started = false;
	
	function ajax() {
		if (channelLength() > 0 && !self.disabled && errors <= 10) {
			started = true;
			$.ajax({
				cache: false,
				data: params(),
				dataType: 'text',
				error: function() {
					errors += 1;
					ajax();
				},
				success: function(data) {
					errors = 0;
					$.each(data.split("\n"), function(i, line) {
						line = line.split('|', 3);
						if (typeof channels[line[0]] != 'undefined')
							channels[line[0]] = line[1];
						events.trigger('watch.' + line[0], line[2]);
					});
					ajax();
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
	
	function params() {
		var ch = [];
		var la = [];
		$.each(channels, function(channel, last) {
			ch.push(channel);
			la.push(last);
		});
		return { channel: ch, last: la };
	}
	
	function unwatch() {
		var args = $.makeArray(arguments);
		if (args.length) {
			if (args[args.length-1].constructor == String)
				$.each(args, function(i, item) {
					delete channels[item];
				});
			args = $.map(args, function(item) {
				if (item.constructor == String)
					return 'watch.' + item;
				else
					return item;
			});
			events.unbind.apply(events, args);
		} else
			events.unbind('watch');
		return this;
	}
	
	function watch() {
		var ch = $.makeArray(arguments);
		var fn = ch.pop();
		
		if (ch.length && fn) {
			$.each(ch, function(i, item) {
				channels[item] = channels[item] || null;
				events.bind('watch.' + item, fn);
			});
			
			if (!started)
				ajax();
		}
		
		return this;
	}
};