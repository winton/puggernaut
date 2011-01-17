module Puggernaut
  class Server
    module Tcp

      def logger
        Puggernaut.logger
      end
      
      def receive_data(data)
        data.split("\n").each do |line|
          room, message = line.split('|', 2)
          room = Puggernaut::Server.rooms[room] ||= Room.new(room)
          id = room.say message
          send_data "OK\n"
        end
      end
    end
  end
end