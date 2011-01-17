require 'puggernaut/server/http'
require 'puggernaut/server/room'
require 'puggernaut/server/tcp'

module Puggernaut
  class Server
    
    include Logger
    
    class <<self
      attr_accessor :rooms
    end
    
    def initialize(http_port=8000, tcp_port=http_port+1)
      puts "Puggernaut is starting on #{http_port} (HTTP) and #{tcp_port} (TCP)"
      puts "*snort*"
      
      loop do
        begin
          GC.start
          self.class.rooms = {}
          EM.epoll if EM.epoll?
          EM.run do
            logger.info "Server#initialize - Starting HTTP - #{http_port}"
            EM.start_server '0.0.0.0', http_port, Http
            
            logger.info "Server#initialize - Starting TCP - #{tcp_port}"
            EM.start_server '0.0.0.0', tcp_port, Tcp
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
  end
end