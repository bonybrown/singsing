require 'sequel'
require 'config'


class SongQueue < Sequel::Model(:queue)
  
  def self.enqueue( song, who )
    queue_item = SongQueue.create( song_id: song.id,
                                   inserted_by: who,
                                   inserted: Time.now )    
    SongQueue.count
  end
  
  def self.items
    SongQueue.db[%q{SELECT s.id, a.name AS artist_name, s.name AS song_name, q.inserted_by as requested_by
                 FROM songs s , artists a, queue q
                WHERE s.artist_id = a.id
                AND q.song_id = s.id 
                ORDER BY inserted;}]
  end
  
  def self.dequeue
    queue_item = SongQueue.order(:inserted).first
    song = nil
    if queue_item
      song = QueuedSong[queue_item.song_id]
      song.requested_by = queue_item.inserted_by
      queue_item.delete
    end
    song
  end
end