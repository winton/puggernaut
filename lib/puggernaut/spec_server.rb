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
  
  get '/single' do
    begin
      client = Puggernaut::Client.new("localhost:8001")
      client.push :single => "single message"
      client.close
    rescue Exception => e
      e.message
    end
  end
  
  get '/multiple' do
    begin
      client = Puggernaut::Client.new("localhost:8001")
      client.push :multiple => [ "multiple message 1", "multiple message 2" ]
      client.close
    rescue Exception => e
      e.message
    end
  end
  
  get '/last/:count' do
    begin
      client = Puggernaut::Client.new("localhost:8001")
      client.push :last => "last message #{params[:count]}"
      client.close
    rescue Exception => e
      e.message
    end
  end
  
  get '/multiple/channels' do
    begin
      client = Puggernaut::Client.new("localhost:8001")
      client.push :single => "single message", :multiple => [ "multiple message 1", "multiple message 2" ]
      client.close
    rescue Exception => e
      e.message
    end
  end
end