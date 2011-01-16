module Puggernaut
  class Client
    module Tcp
      
      include EM::Deferrable
      
      def connection_completed 
        @reconnecting = false
        @connected = true
        succeed 
      end

      def logger
        Puggernaut.logger
      end
      
      def say(messages)
        messages.each do |room, messages|
          messages.each do |message|
            send_data "#{room}|#{message}"
            logger.info "#{Time.now} Said #{message} to #{room}"
          end
        end
      end
      
      def send_data(data)
        callback{ super(data) } 
      end
      
      def unbind 
        @deferred_status = nil
        if @connected || @reconnecting 
          EM.add_timer(1) { reconnect @host, @port } 
          @connected = false 
          @reconnecting = true 
        else 
          raise 'Unable to connect to server' 
        end
      end
    end
  end
end