module Puggernaut
  class Server
    class Websocket

      include Logger
      include Shared
      
      def initialize(host, port)
        EventMachine::WebSocket.start(:host => host, :port => port) do |ws|
          ws.onopen do
            logger.info "Server::Websocket#initialize - Open"
            channel = nil
            join_leave = nil
            joined = nil
            subscription_id = nil
            ws.onmessage do |msg|
              logger.info "Server::Websocket#initialize - Message - #{msg}"
              channels, join_leave, lasts, time, user_id = query_defaults(CGI.parse(msg))
              channel ||= Channel.create(channels, user_id)
              if join_leave && user_id && !joined
                joined = true
                join_channels(channels, user_id)
              end
              messages = gather_messages(channels, lasts, time)
              unless messages.empty?
                ws.send messages
              else
                logger.info "Server::Websocket#initialize - Subscribed - #{channel.channels.join(", ")}"
                subscription_id = channel.subscribe { |str| ws.send str }
              end
            end
            ws.onclose do
              if subscription_id
                channel.unsubscribe(subscription_id)
                logger.info "Sever::Websocket#initialize - Unsubscribe - #{channel.channels.join(", ")}"
                if join_leave && channel.user_id
                  leave_channel(channel)
                end
                Channel.channels.delete channel
              end
            end
          end
        end
      end
    end
  end
end