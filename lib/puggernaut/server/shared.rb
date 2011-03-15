module Puggernaut
  class Server
    module Shared
      
      def gather_messages(channels, lasts, time)
        if time
          channels.inject([]) { |array, channel|
            array += Channel.all_messages_after_time(channel, Time.parse(time))
            array
          }.join("\n")
        elsif !lasts.empty?
          channels.inject([]) { |array, channel|
            array += Channel.all_messages_after_id(channel, lasts.shift)
            array
          }.join("\n")
        else
          ''
        end
      end
      
      def join_channels(channels, user_id)
        Channel.say channels.inject({}) { |hash, channel|
          hash[channel] = "!PUGJOIN#{user_id}"
          hash
        }, user_id
      end
      
      def leave_channel(channel)
        Channel.say channel.channels.inject({}) { |hash, c|
          hash[c] = "!PUGLEAVE#{channel.user_id}"
          hash
        }, channel.user_id
      end
      
      def query_defaults(query)
        [
          (query['channel'].dup rescue []),
          (query['join_leave'].dup[0] rescue nil),
          (query['last'].dup rescue []),
          (query['time'].dup[0] rescue nil),
          (query['user_id'].dup[0] rescue nil)
        ]
      end
    end
  end
end