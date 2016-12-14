require 'sequel'
require 'config'


class Song < Sequel::Model
  
  many_to_one :artist
  
  def full_path
    File.join( Config.song_base_path, self.filename )
  end
  
  def self.query( search_term )
    Song.db[%q{SELECT s.id, a.name AS artist_name, s.name AS song_name,
                  ts_rank_cd(english, plainto_tsquery('english',:query)) + ts_rank_cd(simple, plainto_tsquery('simple',:query)) AS rank
                 FROM search i, songs s, artists a
                 WHERE (english @@ plainto_tsquery('english',:query) 
                 OR simple @@ plainto_tsquery('simple',:query ))
                 AND s.artist_id = a.id
                 AND i.song_id  = s.id
                 ORDER BY rank DESC;},
                  query: search_term]
  end
  
  def self.random
    Song.sample(10)
  end
end