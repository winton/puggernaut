module Puggernaut
  class Client
    
    def initialize(env, servers)
      Puggernaut.env = env
      
      loop do
        begin
          GC.start
          EM.epoll if EM.epoll?
          EM.run do
            @connections = servers.inject([]) do |array, (host, port)|
              logger.info "#{Time.now} Starting TCP client for #{host}:#{port}"
              array << EM.connect(host, port, Tcp)
            end
          end
        rescue Interrupt
          logger.info "#{Time.now} Shuting down client..."
          exit
        rescue
          logger.error "#{Time.now} Error: " + $!.message
          logger.error "\t" + $!.backtrace.join("\n\t")
        end
      end
    end
    
    def logger
      Puggernaut.logger
    end
    
    def say(messages)
      @connections.each do |connection|
        connection.say messages
      end
    end
  end
end