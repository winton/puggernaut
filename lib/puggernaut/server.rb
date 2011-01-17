require 'puggernaut/server/http'
require 'puggernaut/server/room'
require 'puggernaut/server/tcp'

module Puggernaut
  class Server
    
    class <<self
      attr_accessor :rooms
    end
    
    def initialize(env='development', port=8000)
      Puggernaut.env = env
      
      loop do
        begin
          GC.start
          self.class.rooms = {}
          EM.epoll if EM.epoll?
          EM.run do
            logger.info "Starting HTTP server on port #{port}"
            EM.start_server '0.0.0.0', port, Http
            
            logger.info "Starting TCP server on port #{port+1}"
            EM.start_server '0.0.0.0', port + 1, Tcp
          end
        rescue Interrupt
          logger.info "Shuting down server..."
          exit
        rescue
          logger.error "Error: " + $!.message
          logger.error "\t" + $!.backtrace.join("\n\t")
        end
      end
    end
    
    def logger
      Puggernaut.logger
    end
  end
end