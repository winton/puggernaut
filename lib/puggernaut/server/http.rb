require 'cgi'

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
          
          unless channels.empty?
            @channel = Channel.create(channels)
            unless lasts.empty?
              lasts = channels.inject([]) { |array, channel|
                array += Channel.all_messages_after(channel, lasts.shift)
                array
              }.join("\n")
            end
            unless lasts.empty?
              respond lasts
            else
              EM::Timer.new(30) { respond }
              logger.info "Server::Channel#create - Subscribed - #{@channel.channels.join(", ")}"
              @subscription_id = @channel.subscribe { |str| respond str }
            end
          else
            respond "no channel specified", 500
          end
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
          Channel.channels.delete @channel
          logger.info "Sever::Http#unbind - Unsubscribe - #{@subscription_id}"
        end
      end
    end
  end
end