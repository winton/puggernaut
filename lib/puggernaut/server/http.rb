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
          logger.error "#{Time.now} Strange request: #{[method, request, version].inspect}"
          close_connection
          return
        else
          path, query = request.split('?', 2)
          logger.info "#{Time.now} Request on #{path} with #{query}"
          query = CGI.parse(query) if not query.nil?
        end

        if path == '/'
          if query && query['rooms']
            @rooms = query['rooms'].split(',').inject([]) do |array, room|
              array << (Puggernaut::Server.rooms[room] ||= Room.new(room))
              array
            end
            if query['last']
              last_ids = query['last'].split(',')
              respond @rooms.inject([]) { |array, room|
                array += room.all_messages_after(last_ids.pop)
                array
              }.join("\n")
            else
              EM::Timer.new(30) { respond }
              @subscription_ids = @rooms.collect do |room|
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
        @subscription_ids.each do |id|
          @rooms.pop.unsubscribe(id)
        end
      end
    end
  end
end