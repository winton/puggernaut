require 'puggernaut/server/http'
require 'puggernaut/server/room'
require 'puggernaut/server/tcp'

module Puggernaut
  class Server
    
    class <<self
      attr_accessor :rooms
    end
    
    def initialize(port=8000)
      loop do
        begin
          GC.start
          self.class.rooms = {}
          EM.epoll if EM.epoll?
          EM.run do
            logger.info "Server#initialize - Starting HTTP - #{port}"
            EM.start_server '0.0.0.0', port, Http
            
            logger.info "Server#initialize - Starting TCP - #{port+1}"
            EM.start_server '0.0.0.0', port + 1, Tcp
          end
        rescue Interrupt
          logger.info "Server#initialize - Shutting down"
          exit
        rescue
          logger.error "Server#initialize - Error - #{$!.message}"
          logger.error "\t" + $!.backtrace.join("\n\t")
        end
      end
    end
    
    def logger
      Puggernaut.logger
    end
  end
end