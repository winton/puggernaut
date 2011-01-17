require 'cgi'

module Puggernaut
  class Server
    module Http

      def logger
        Puggernaut.logger
      end

      def receive_data(data)
        lines = data.split(/[\r\n]+/)
        method, request, version = lines.shift.split(' ', 3)

        if request.nil?
          logger.error "Strange request: #{[method, request, version].inspect}"
          close_connection
          return
        else
          path, query = request.split('?', 2)
          logger.info "Request on #{path} with #{query}"
          query = CGI.parse(query) if not query.nil?
        end

        if path == '/'
          if query && !query['room'].empty?
            @rooms = query['room'].inject([]) do |array, room|
              array << (Puggernaut::Server.rooms[room] ||= Room.new(room))
              array
            end
            if query['last'] && !query['last'].empty?
              last = query['last'].dup
              last = @rooms.inject([]) { |array, room|
                array += room.all_messages_after(last.pop)
                array
              }.join("\n")
            end
            if last && !last.empty?
              respond last
            else
              EM::Timer.new(30) { respond }
              @subscription_ids = @rooms.collect do |room|
                logger.info "Waiting for message from room #{room}"
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
        logger.info "Response #{status}: #{body}"
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
            @rooms.pop.unsubscribe(id)
          end
        end
      end
    end
  end
end