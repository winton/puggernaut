require File.dirname(__FILE__) + '/gems'

Puggernaut::Gems.activate %w(sinatra)

require 'sinatra/base'

$:.unshift File.expand_path('../../', __FILE__)

require 'puggernaut/client'

class SpecServer < Sinatra::Base
  
  set :environment, :test
  set :root, File.expand_path("../../../", __FILE__)
  set :public, "#{root}/public"
  set :logging, true
  set :static, true
  
  get '/pulse' do
    'OK'
  end
  
  get '/' do
    redirect '/spec.html'
  end
  
  get '/basic/push' do
    begin
      client = Puggernaut::Client.new("localhost:8001")
      client.push :basic => "basic message"
      client.close
    rescue Exception => e
      e.message
    end
  end
end