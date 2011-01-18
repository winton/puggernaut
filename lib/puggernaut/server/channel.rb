module Puggernaut
  class Server
    class Channel < EM::Channel
      
      include Logger
      
      attr_reader :messages, :channel
  
      def initialize(channel)
        @messages = []
        @channel = channel
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
          "#{@channel}|#{message.join '|'}"
        }
      end
  
      def say(messages)
        push messages.split("\n").collect { |message|
          message = [ rand.to_s[2..-1], message ]
          @messages << message
          @messages.shift if @messages.length > 100
          logger.info "Server::Channel#say - #{@channel} - #{message[0]} - #{message[1]}"
          "#{@channel}|#{message.join '|'}"
        }.join("\n")
      end
    end
  end
end