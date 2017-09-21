require 'sequel'
require 'config'


class SongQueue < Sequel::Model(:queue)
  
  def self.enqueue( song, who )
    queue_item = SongQueue.create( song_id: song.id,
                                   inserted_by: who,
                                   inserted: Time.now,
                                   played: false)    
    SongQueue.where(played: false).count
  end
  
  def self.items
    SongQueue.db[%q{SELECT s.id, a.name AS artist_name, s.name AS song_name, q.inserted_by as requested_by
                 FROM songs s , artists a, queue q
                WHERE s.artist_id = a.id
                AND q.song_id = s.id 
                AND q.played = false
                ORDER BY inserted;}]
  end
  
  
  def dequeue
    self.played = true
    self.save
  end
    
  def self.dequeue( id )
    item = SongQueue.where(id: id).first
    item.dequeue unless item.nil?
  end
  
  def self.peek
    queue_item = SongQueue.where(played: false).order(:inserted).first
    song = nil
    if queue_item
      song = QueuedSong[queue_item.song_id]
      song.queue_id = queue_item.id
    end
    song
  end
end