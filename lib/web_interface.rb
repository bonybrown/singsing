require 'sinatra/base'
require 'erubis'
require 'song'
require 'song_queue'


class WebInterface < Sinatra::Base
  configure do
    set :server, :thin
    set :threaded, true
    set :logging, false
    set :erb, :escape_html => true
    set :bind, '0.0.0.0'
    set :port, 8000
  end

  get '/' do
    redirect to('/index.html')
  end
  
  get '/random' do
    erb :results, :locals => {:search_results => Song.random}
  end

  get '/queue' do
    erb :queue, :locals => {:queue_items => SongQueue.items}
  end
  
  get '/dequeue' do
    id = request[:id]
    SongQueue.dequeue( id )
    "ok"
  end
  
  get '/peek' do
    song = SongQueue.peek
    r = nil
    unless song.nil?
      r = { queue_id: song.queue_entry.id,
            filename: song.filename
          }
    end
    r.to_json
  end
  
  post '/queue' do
    id = request[:id]
    request_name = request[:name]
    puts "Queue #{id} for #{request_name}"
    song = Song[id]
    queue_index = 0
    if song
      queue_index = SongQueue.enqueue( song, request_name )
    end
    content_type "application/json"
    {result: !song.nil?, position: queue_index}.to_json
  end
  
  get '/search' do
    #query is in parameter q
    search_term = request[:q]
    puts "Search for #{search_term}"
    search_results = ::Song.query(search_term)
    if search_results.empty? 
      erb :nomatch, :locals => {:search_term => search_term}
    else
      erb :results, :locals => {:search_results => search_results}
    end
  end
end
