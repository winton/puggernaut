module Puggernaut
  class Server
    module Tcp

      include Logger
      
      def receive_data(data)
        messages = data.split("\n").inject({}) do |hash, line|
          room, message = line.split('|', 2)
          hash[room] ||= []
          hash[room] << message
          hash
        end
        messages.each do |room, messages|
          room = Puggernaut::Server.rooms[room] ||= Room.new(room)
          room.say messages.join("\n")
        end
        send_data "OK\n"
      end
    end
  end
end