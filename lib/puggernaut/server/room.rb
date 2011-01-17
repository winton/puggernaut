module Puggernaut
  class Server
    class Room < EM::Channel
      
      attr_reader :messages, :room
  
      def initialize(room)
        @messages = []
        @room = room
        super()
      end
      
      def all_messages_after(identifier)
        found = false
        @messages.select { |(id, message)|
          found = true if id == identifier
          found
        }[1..-1].collect { |message|
          "#{@room}|#{message.join '|'}"
        }.join("\n")
      end
  
      def say(message)
        message = [ rand.to_s[2..-1], message ]
        @messages << message
        @messages.pop if @messages.length > 100
        push "#{@room}|#{message.join '|'}"
        message[0]
      end
    end
  end
end