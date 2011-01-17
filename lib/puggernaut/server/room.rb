module Puggernaut
  class Server
    class Room < EM::Channel
      
      include Logger
      
      attr_reader :messages, :room
  
      def initialize(room)
        @messages = []
        @room = room
        super()
      end
      
      def all_messages_after(identifier)
        found = false
        (
          @messages.select { |(id, message)|
            found = true if id == identifier
            found
          }[1..-1] || []
          
        ).collect { |message|
          "#{@room}|#{message.join '|'}"
        }
      end
  
      def say(messages)
        push messages.split("\n").collect { |message|
          message = [ rand.to_s[2..-1], message ]
          @messages << message
          @messages.shift if @messages.length > 100
          logger.info "Server::Room#say - #{@room} - #{message[0]} - #{message[1]}"
          "#{@room}|#{message.join '|'}"
        }.join("\n")
      end
    end
  end
end