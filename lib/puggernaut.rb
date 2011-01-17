require File.dirname(__FILE__) + '/puggernaut/gems'

Puggernaut::Gems.activate %w(eventmachine)

require 'eventmachine'
require 'logger'
require 'fileutils'

$:.unshift File.dirname(__FILE__)

require 'puggernaut/logger'
require 'puggernaut/client'
require 'puggernaut/server'

module Puggernaut
  # snort snort
end