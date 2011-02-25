require "#{File.dirname(__FILE__)}/logger"
require 'socket'
require 'timeout'

module Puggernaut
  class Client
    
    include Logger
    
    attr_accessor :connections
    
    def initialize(*servers)
      @connections = {}
      @retry = []
      @servers = servers.collect { |s| s.split(':') }
    end
    
    def close
      @connections.each do |host_port, connection|
        connection.close
        logger.info "Client#close - #{host_port}"
      end
    end
    
    def push(messages)
      messages = messages.collect do |channel, message|
        if message.is_a?(::Array)
          message.collect { |m| "#{channel}|#{m}" }.join("\n")
        else
          "#{channel}|#{message}"
        end
      end
      unless messages.empty?
        @servers.each do |(host, port)|
          send host, port, messages.join("\n")
        end
      end
    end
    
    private
    
    def send(host, port, data, try_retry=true)
      try if try_retry
      begin
        host_port = "#{host}:#{port}"
        logger.info "Client#send - #{host_port} - #{data}"
        response = nil
        Timeout.timeout(10) do
          connection = @connections[host_port] ||= TCPSocket.open(host, port)
          connection.print(data)
          response = connection.gets
        end
        raise 'not ok' if !response || !response.include?('OK')
      rescue Exception => e
        logger.info "Client#send - Exception - #{e.message} - #{host_port} - #{data}"
        @retry << [ host, port, data ]
        @retry.shift if @retry.length > 10
      end
      try if try_retry
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