require 'puggernaut/server/http'
require 'puggernaut/server/channel'
require 'puggernaut/server/tcp'

module Puggernaut
  class Server
    
    include Logger
    
    def initialize(http_port=8100, tcp_port=http_port.to_i+1)
      puts "\nPuggernaut is starting on #{http_port} (HTTP) and #{tcp_port} (TCP)"
      puts "*snort*\n\n"
      
      errors = 0
      
      while errors <= 10
        begin
          Channel.channels = []
          GC.start
          EM.epoll if EM.epoll?
          EM.run do
            logger.info "Server#initialize - Starting HTTP - #{http_port}"
            EM.start_server '0.0.0.0', http_port, Http
            
            logger.info "Server#initialize - Starting TCP - #{tcp_port}"
            EM.start_server '0.0.0.0', tcp_port, Tcp
            
            errors = 0
          end
        rescue Interrupt
          logger.info "Server#initialize - Shutting down"
          exit
        rescue
          errors += 1
          logger.error "Server#initialize - Error - #{$!.message}"
          logger.error "\t" + $!.backtrace.join("\n\t")
        end
      end
      
      puts "Exiting because of too many consecutive errors :("
      puts "Check #{Dir.pwd}/log/puggernaut.log\n\n"
    end
  end
end