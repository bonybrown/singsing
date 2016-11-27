#!/usr/bin/env ruby
$LOAD_PATH.unshift 'lib'

require 'song'

Song.each do | song |
  puts "Missing: #{song.full_path}" unless File.exists? song.full_path
end

