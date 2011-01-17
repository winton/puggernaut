module Puggernaut
  class Server
    module Tcp

      def logger
        Puggernaut.logger
      end
      
      def receive_data(data)
        data.split("\n").each do |line|
          room, message = line.split('|', 1)
          room = Puggernaut.rooms[room] ||= Room.new(room)
          id = room.say message
          logger.info "Message #{id} sent to #{room.room}"
        end
      end
    end
  end
end