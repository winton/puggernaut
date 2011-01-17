require File.dirname(__FILE__) + '/puggernaut/gems'

Puggernaut::Gems.activate %w(eventmachine)

require 'eventmachine'
require 'logger'
require 'fileutils'

$:.unshift File.dirname(__FILE__)

require 'puggernaut/client'
require 'puggernaut/server'

module Puggernaut
  class <<self
    
    def logger
      unless @logger
        base = Dir.pwd
        FileUtils.mkdir_p("#{base}/log")
        file = File.open("#{base}/log/puggernaut.log", 'a')
        file.sync = true
        @logger = Logger.new(file)
      end
      @logger
    end
  end
end