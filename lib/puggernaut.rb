require File.dirname(__FILE__) + '/puggernaut/gems'

Puggernaut::Gems.activate %w(eventmachine)

require 'eventmachine'
require 'logger'

$:.unshift File.dirname(__FILE__)

require 'puggernaut/client'
require 'puggernaut/server'

module Puggernaut
  class <<self
    
    attr_accessor :env
    
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