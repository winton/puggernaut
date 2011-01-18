require 'puggernaut/server/http'
require 'puggernaut/server/channel'
require 'puggernaut/server/tcp'

module Puggernaut
  class Server
    
    include Logger
    
    class <<self
      attr_accessor :channels
    end
    
    def initialize(http_port=8000, tcp_port=http_port+1)
      puts "Puggernaut is starting on #{http_port} (HTTP) and #{tcp_port} (TCP)"
      puts "*snort*"
      
      errors = 0
      
      while errors <= 10
        begin
          GC.start
          self.class.channels = {}
          EM.epoll if EM.epoll?
          EM.run do
            logger.info "Server#initialize - Starting HTTP - #{http_port}"
            EM.start_server '0.0.0.0', http_port, Http
            
            logger.info "Server#initialize - Starting TCP - #{tcp_port}"
            EM.start_server '0.0.0.0', tcp_port, Tcp
          end
          errors = 0
        rescue Interrupt
          logger.info "Server#initialize - Shutting down"
          exit
        rescue
          errors += 1
          logger.error "Server#initialize - Error - #{$!.message}"
          logger.error "\t" + $!.backtrace.join("\n\t")
        end
      end
    end
  end
end