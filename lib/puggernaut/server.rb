require 'puggernaut/server/http'
require 'puggernaut/server/room'
require 'puggernaut/server/tcp'

module Puggernaut
  class Server
    
    def initialize(env='development')
      self.class.env = env
    end

    class <<self
      attr_accessor :env, :rooms

      def logger
        unless @logger
          base = File.expand_path('../../', __FILE__)
          FileUtils.mkdir_p("#{base}/log")
          file = File.open("#{base}/log/#{env}.log", 'a')
          file.sync = true
          @logger = Logger.new(file)
        end
        @logger
      end
    end
  end
end