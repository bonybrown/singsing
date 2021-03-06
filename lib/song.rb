require 'sequel'
require 'config'


class Song < Sequel::Model
  
  many_to_one :artist
  
  Song.db.extension :pg_array, :pg_inet, :pg_json
  
  def full_path
    File.join( Config.media_base_path, self.filename )
  end
  
  def is_zip_file?
    self.filename.match( /\.ZIP$/i )
  end
  
  def self.by_ids( id_list )
    Song.db[%q{SELECT array_agg(s.id) as id, array_agg(s.sortkey) as sortkey, a.name AS artist_name, s.name AS song_name
            FROM songs s , artists a
           WHERE s.artist_id = a.id
           AND s.id IN :ids
           GROUP BY a.name, s.name
           ORDER BY a.name, s.name;},
            ids: id_list]
  end
  
  def self.query( search_term )
    Song.db[%q{SELECT array_agg(s.id) as id, array_agg(s.sortkey) as sortkey, a.name AS artist_name, s.name AS song_name,
                 avg( ts_rank_cd(english, plainto_tsquery('english',:query)) + ts_rank_cd(simple, plainto_tsquery('simple',:query)) ) AS rank
                 FROM search i, songs s, artists a
                 WHERE (english @@ plainto_tsquery('english',:query) 
                 OR simple @@ plainto_tsquery('simple',:query ))
                 AND s.artist_id = a.id
                 AND i.song_id  = s.id
                 GROUP BY a.name, s.name
                 ORDER BY rank DESC, a.name, s.name;},
                  query: search_term]
  end
  
  def self.random
    Song.db[%q{SELECT array_agg(s.id) as id, array_agg(s.sortkey) as sortkey, a.name AS artist_name, s.name AS song_name
            FROM songs s TABLESAMPLE BERNOULLI( 20.0 / (SELECT COUNT(*) FROM SONGS) * 100 ) , artists a
           WHERE s.artist_id = a.id
           GROUP BY a.name, s.name;}]
  end

end

class QueuedSong < Song
  attr_accessor  :queue_id
end
