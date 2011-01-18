module Puggernaut
  class Server
    module Tcp

      include Logger
      
      def receive_data(data)
        messages = data.split("\n").inject({}) do |hash, line|
          channel, message = line.split('|', 2)
          hash[channel] ||= []
          hash[channel] << message
          hash
        end
        Channel.say messages
        send_data "OK\n"
      end
    end
  end
end