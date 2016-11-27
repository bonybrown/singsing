require 'sinatra/base'

class WebInterface < Sinatra::Base
  get '/' do
    redirect to('/index.html')
  end
  
  get '/random' do
      puts "get random"
  end
  
  get '/search' do
      #query is in parameter q
      puts "Search for #{request[:q]}"
      erb :search
  end
end
