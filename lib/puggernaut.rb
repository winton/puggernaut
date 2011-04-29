require File.dirname(__FILE__) + '/puggernaut/gems'

Puggernaut::Gems.activate %w(eventmachine em-websocket)

require 'eventmachine'
require 'em-websocket'
require 'memprof'

$:.unshift File.dirname(__FILE__)

require 'puggernaut/logger'
require 'puggernaut/client'
require 'puggernaut/server'

module Puggernaut
end