module Puggernaut
  class Server
    class Channel < EM::Channel
      
      attr_reader :channels, :user_id
      
      def initialize(channels, user_id)
        @channels = channels
        @user_id = user_id
        super()
      end
      
      class <<self

        include Logger
        
        attr_accessor :channels
        
        def create(channels, user_id)
          channel = self.new(channels, user_id)
          @channels ||= []
          @channels << channel
          channel
        end
        
        def all_messages_after_id(channel, identifier)
          if @messages && @messages[channel]
            found = false
            (
              @messages[channel].select { |(id, message, time)|
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

        def all_messages_after_time(channel, after_time)
          if @messages && @messages[channel]
            (
              @messages[channel].select { |(id, message, time)|
                after_time < time
              } || []

            ).collect { |message|
              "#{channel}|#{message.join '|'}"
            }
          else
            []
          end
        end

        def inhabitants(channel_name)
          user_ids = @channels.collect do |channel|
            channel.user_id if channel.channels.include?(channel_name)
          end
          user_ids.compact
        end
        
        def say(messages)
          @messages ||= {}
          messages = messages.inject({}) do |hash, (channel_name, messages)|
            messages = messages.collect do |message|
              [ rand.to_s[2..-1], message, Time.now ]
            end
            @messages[channel_name] ||= []
            @messages[channel_name] += messages
            @messages[channel_name] = @messages[channel_name].select do |message|
              message[2] >= Time.now - 2 * 60 * 60
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
            push = push.compact
            unless push.empty?
              channel.push push.join("\n")
            end
          end
        end
      end
    end
  end
end