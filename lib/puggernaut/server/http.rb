require 'cgi'
require 'time'

module Puggernaut
  class Server
    module Http

      include Logger

      def receive_data(data)
        lines = data.split(/[\r\n]+/)
        method, request, version = lines.shift.split(' ', 3)

        if request.nil?
          logger.error "Server::Http#receive_data - Strange request - #{[method, request, version].inspect}"
          close_connection
          return
        else
          path, query = request.split('?', 2)
          logger.info "Server::Http#receive_data - Request - #{path} - #{query}"
          query = CGI.parse(query) if not query.nil?
        end

        if path == '/'
          channels = query['channel'].dup rescue []
          lasts = query['last'].dup rescue []
          time = query['time'].dup[0] rescue nil
          user_id = query['user_id'].dup[0] rescue nil
          
          unless channels.empty?
            @channel = Channel.create(channels, user_id)
            messages = []
            if time
              messages = channels.inject([]) { |array, channel|
                array += Channel.all_messages_after_time(channel, Time.parse(time))
                array
              }.join("\n")
            elsif !lasts.empty?
              messages = channels.inject([]) { |array, channel|
                array += Channel.all_messages_after_id(channel, lasts.shift)
                array
              }.join("\n")
            end
            unless messages.empty?
              respond messages
            else
              EM::Timer.new(30) { respond }
              logger.info "Server::Http#receive_data - Subscribed - #{@channel.channels.join(", ")}"
              @subscription_id = @channel.subscribe { |str| respond str }
            end
          else
            respond "no channel specified", 500
          end
        elsif path == '//inhabitants'
          channels = query['channel'].dup rescue []
          user_ids = channels.collect do |c|
            Channel.inhabitants(c)
          end
          respond user_ids.flatten.uniq.join('|')
        else
          respond "not found", 404
        end
      end

      def respond(body='', status=200, content_type='text/plain; charset=utf-8')
        logger.info "Server::Http#respond - #{status} - #{body}"
        response = [
          "HTTP/1.1 %d Puggernaut",
          "Content-length: %d",
          "Content-type: %s",
          "Connection: close",
          "",
          "%s"
        ].join("\r\n")
        send_data response % [ status, body.length, content_type, body ]
        close_connection_after_writing
      end

      def unbind
        if @subscription_id
          @channel.unsubscribe(@subscription_id)
          logger.info "Sever::Http#unbind - Unsubscribe - #{@channel.channels.join(", ")}"
          Channel.channels.delete @channel
        end
      end
    end
  end
end