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
    (erb :results, :locals => {:search_results => Song.random, :mode => :random}).gsub("\n","")
  end

  get '/queue' do
    (erb :queue, :locals => {:queue_items => SongQueue.items}).gsub("\n","")
  end
  
  get '/dequeue' do
    id = request[:id]
    SongQueue.dequeue( id )
    "ok"
  end
  
  get '/peek' do
    song = SongQueue.peek
    r = {}
    unless song.nil?
      r[:queue_id] = song.queue_id
      r[:filename] = song.filename
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
      (erb :results, :locals => {:search_results => search_results, :mode => :search}).gsub("\n","")
    end
  end
  
  get '/favourites' do
    #comma separated ids is parameter 'ids'
    list = request[:ids]
    puts "Favourites list #{list}"
    search_results = []
    if list
      search_results = ::Song.by_ids(list.split(','))
    end
    if search_results.empty? 
      erb :nofavourites, :locals => {:search_term => "nothing"}
    else
      (erb :results, :locals => {:search_results => search_results, :mode => :favourites}).gsub("\n","")
    end
  end
end
