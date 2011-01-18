var Puggernaut = new function() {
	
	var $ = jQuery;
	var self = this;
	
	this.path = '/long_poll';
	this.unwatch = unwatch;
	this.watch = watch;
	
	var channels = {};
	var events = $('<div/>');
	var started = false;
	
	function ajax() {
		started = true;
		$.ajax({
			cache: false,
			data: params(),
			dataType: 'text',
			error: ajax,
			success: function(data) {
				$.each(data.split("\n"), function(i, line) {
					line = line.split('|', 3);
					channels[line[0]] = line[1];
					events.trigger('watch.' + line[0], line[2]);
				});
				ajax();
			},
			timeout: 100000,
			traditional: true,
			url: self.path
		});
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
		var args = $.map(arguments, function(item) {
			if (item.constructor == String)
				return 'watch.' + item;
			else
				return item;
		});
		events.unbind.apply(events, args);
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
	}
};