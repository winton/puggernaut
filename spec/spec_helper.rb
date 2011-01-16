require 'pp'

$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/puggernaut/gems"

Puggernaut::Gems.activate :rspec

require "#{$root}/lib/puggernaut"

Spec::Runner.configure do |config|
end