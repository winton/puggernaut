require 'puggernaut/server/shared'
require 'puggernaut/server/http'
require 'puggernaut/server/channel'
require 'puggernaut/server/tcp'
require 'puggernaut/server/websocket'

module Puggernaut
  class Server
    
    include Logger
    
    def initialize(http_port=8100, tcp_port=http_port.to_i+1, ws_port=tcp_port.to_i+1)
      puts "\nPuggernaut is starting on #{http_port} (Long Poll HTTP), #{tcp_port} (Puggernaut TCP), and #{ws_port} (WebSocket TCP)"
      puts "*snort*\n\n"

      begin
        Channel.channels = []
        EM.epoll if EM.epoll?
        EM.run do
          logger.info "Server#initialize - Starting HTTP - #{http_port}"
          EM.start_server '0.0.0.0', http_port, Http
          
          logger.info "Server#initialize - Starting TCP - #{tcp_port}"
          EM.start_server '0.0.0.0', tcp_port, Tcp
          
          logger.info "Server#initialize - Starting WebSocket - #{ws_port}"
          Websocket.new '0.0.0.0', ws_port
          
          errors = 0
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