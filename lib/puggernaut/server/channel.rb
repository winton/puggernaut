module Puggernaut
  class Server
    class Channel < EM::Channel
      
      include Logger
      
      attr_reader :channels
      
      def initialize(channels)
        @channels = channels
        super()
      end
      
      class <<self
        
        attr_accessor :channels
        
        def create(channels)
          channel = self.new(channels)
          @channels ||= []
          @channels << channel
          channel
        end
        
        def all_messages_after(channel, identifier)
          if @messages && @messages[channel]
            found = false
            (
              @messages[channel].select { |(id, message)|
                found = true if id == identifier
                found
              }[1..-1] || []

            ).collect { |message|
              "#{channel}|#{message.join '|'}"
            }
          else
            []
          end
        end
        
        def say(messages)
          @messages ||= {}
          messages = messages.inject({}) do |hash, (channel_name, messages)|
            messages = messages.collect do |message|
              [ rand.to_s[2..-1], message ]
            end
            @messages[channel_name] ||= []
            @messages[channel_name] += messages
            if @messages[channel_name].length > 100
              @messages[channel_name] = @messages[channel_name][-100..-1]
            end
            hash[channel_name] = messages
            hash
          end
          @channels.each do |channel|
            push = channel.channels.collect do |channel_name|
              if messages[channel_name]
                messages[channel_name].collect { |message|
                  "#{channel_name}|#{message.join('|')}"
                }.join("\n")
              end
            end
            channel.push push.compact.join("\n")
          end
        end
      end
    end
  end
end