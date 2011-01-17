module Puggernaut
  class Client
    
    def initialize(env='development', servers={})
      Puggernaut.env = env
      
      EM.epoll if EM.epoll?
      @connections = servers.inject([]) do |array, (host, port)|
        logger.info "Starting TCP client for #{host}:#{port}"
        array << EM.connect(host, port, Tcp)
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