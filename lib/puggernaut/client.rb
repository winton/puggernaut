require 'socket'
#require 'puggernaut/client/tcp'

module Puggernaut
  class Client
    
    attr_accessor :connections
    
    def initialize(env='development', servers={})
      Puggernaut.env = env
      @connections = {}
      @retry = []
      @servers = servers
    end
    
    def connect(host, port)
      host_port = "#{host}:#{port}"
      @connections[host_port] ||= TCPSocket.open(host, port)
    end
    
    def close
      @connections.each do |host_port, connection|
        connection.close
        logger.info "Client#close - #{http_port}"
      end
    end
    
    def logger
      Puggernaut.logger
    end
    
    def say(messages)
      messages.each do |room, message|
        message =
          if message.is_a?(::Array)
            message.collect { |m| "#{room}|#{m}" }.join("\n")
          else
            "#{room}|#{message}"
          end
        @servers.each do |host, port|
          send host, port, message
        end
      end
    end
    
    private
    
    def send(host, port, data, try_retry=true)
      try if try_retry
      begin
        logger.info "Client#send - #{host}:#{port} - #{data}"
        connection = connect(host, port)
        connection.print(data)
        response = connection.gets
        raise 'not ok' if !response || !response.include?('OK')
      rescue Exception => e
        logger.info "Client#send - Exception - #{e.message} - #{host}:#{port} - #{data}"
        @retry << [ host, port, data ]
        @retry.shift if @retry.length > 10
      end
    end
    
    def try
      @retry.length.times do
        host, port, data = @retry.shift
        @connections.delete("#{host}:#{port}")
        send host, port, data, false
      end
    end
  end
end