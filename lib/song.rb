require 'sequel'
require 'config'


class Song < Sequel::Model
  
  many_to_one :artist
  
  def full_path
    File.join( Config.song_base_path, self.filename )
  end
end