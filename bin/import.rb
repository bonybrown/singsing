#!/usr/bin/env ruby
$LOAD_PATH.unshift 'lib'

require 'song'
require 'artist'
require 'taglib'
require 'table_print'

def transform_artist( value )
  match_data = value.match(/(\w+), (\w+)(.*)/)
  return value unless match_data
  match_data[2] + ' ' + match_data[1] + match_data[3]
end

def save_data( items )
  items.each do |i|
    artist = i[:matched]
    artist = Artist.create( name: i[:artist] ) unless i[:matched]
    song = Song.create(  name: i[:title], 
                         artist_id: artist.id, 
                         filename: i[:import_filename] 
                      )
  end
  DB.run('REFRESH MATERIALIZED VIEW search;')                                
end

def update_matched_artists( items )
  items.each do |i|
    match = Artist.where(:name => i[:artist]).first
    i[:matched] = match
  end
end


DIR = ARGV[1]

unless DIR.index( Config.media_base_path ) == 0
  $stderr.puts("The media path #{DIR} is not anchored at the configured media base path #{Config.media_base_path}")
  $stderr.puts("The media cannot be imported.")
  exit 1
end

glob = File.join(DIR,'**/*.mp3' )
puts glob

items = []
index = 1




Dir.glob( glob ) do |mp3_file|
  
  import_filename = '.' + mp3_file.sub(Config.media_base_path,'')
  
  item = {index: index, import_filename: import_filename, file: mp3_file}
  TagLib::MPEG::File.open(mp3_file) do |file|
    tag = file.id3v2_tag
    
    artist = transform_artist( tag.artist)
    title = tag.title

    
    puts title
    puts artist
    item[:title] = title
    item[:artist] = artist
  end
  items << item
  index += 1
end


while( true )
  update_matched_artists( items )
  tp items, :index,:title,:artist,{:matched => lambda{|m|!m[:matched].nil?}},:import_filename => {:width => 100}
  $stdout.print("Enter line number to edit, save to add to database, quit to abort: ")
  cmd =  $stdin.gets.chomp
  if( cmd == 'quit')
    break
  end
  if( cmd == 'save' )
    #save data and quit
    save_data( items )
    break
  end
  id = cmd.to_i
  if id > 0 && id <= items.length
    item = items[id - 1]
    $stdout.print "Edit (a)rtist or (t)itle: "
    artist_or_title = $stdin.gets.chomp
    if artist_or_title == 'a'
      $stdout.print item[:artist]
      $stdout.print '=> '
      artist = $stdin.gets.chomp.strip
      item[:artist] = artist unless artist.empty?
    end
    if artist_or_title == 't'
      $stdout.print item[:title]
      $stdout.print '=> '
      title = $stdin.gets.chomp.strip
      item[:title] = title unless title.empty?
    end
  end
end
