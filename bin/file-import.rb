#!/usr/bin/env ruby
$LOAD_PATH.unshift 'lib'

require 'config'
require 'song'
require 'artist'
require 'pp'

def transform_artist( value )
  match_data = value.match(/(\w+), (\w+)(.*)/)
  return value unless match_data
  match_data[2] + ' ' + match_data[1] + match_data[3]
end

def save_data( items )
  items.each do |i|
    pp i
    artist = match_artist( i )
    artist = Artist.create( name: i[:artist] ) unless i[:matched]
    song = Song.create(  name: i[:title], 
                         artist_id: artist.id, 
                         filename: i[:import_filename],
                         sortkey: i[:sortkey]
                      )
  end
  DB.run('REFRESH MATERIALIZED VIEW search;')                                
end

def match_artist( item )
  match = Artist.where(:name => item[:artist]).first
  item[:matched] = match
end

def extract( filename )
  f = File.basename( filename )
  match_data = f.match(/(.+) - (.+)\.mp3/)
  if match_data.nil?
    $stderr.puts filename 
    return nil,nil
  else
    return match_data[1],match_data[2]
  end
end

DIR = ARGV[0]

unless DIR.index( Config.media_base_path ) == 0
  $stderr.puts("The media path #{DIR} is not anchored at the configured media base path #{Config.media_base_path}")
  $stderr.puts("The media cannot be imported.")
  exit 1
end

glob = File.join(DIR,'**/*.mp3' )
puts glob

items = []
Dir.glob( glob ) do |mp3_file|
  
  import_filename = '.' + mp3_file.sub(Config.media_base_path,'')
  artist,song = extract( mp3_file )
  matches = song.match( / \[(.+)\]/)
  karaoke = nil
  if matches
    karaoke = matches[1].to_s.gsub(' Karaoke','')
  end
  song = song.gsub( / \[.+\]/, '' )
  item = { artist: transform_artist(artist), import_filename: import_filename, title: song, sortkey: karaoke }
  #pp item
  items <<  item
end

save_data( items )


