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
          if query && !query['room'].empty?
            @rooms = query['room'].collect do |room|
              Puggernaut::Server.rooms[room] ||= Room.new(room)
            end
            if query['last'] && !query['last'].empty?
              last = query['last'].dup
              last = @rooms.inject([]) { |array, room|
                array += room.all_messages_after(last.shift)
                array
              }.join("\n")
            end
            if last && !last.empty?
              respond last
            else
              EM::Timer.new(30) { respond }
              @subscription_ids = @rooms.collect do |room|
                logger.info "Server::Http#receive_data - Subscribed - #{room.room}"
                room.subscribe { |str| respond str }
              end
            end
          else
            respond "no room specified", 500
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
        if @subscription_ids
          @subscription_ids.each do |id|
            room = @rooms.shift
            room.unsubscribe(id)
            logger.info "Sever::Http#unbind - #{room.room} - #{id}"
          end
        end
      end
    end
  end
end