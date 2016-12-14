require 'sequel'
require 'config'


class SongQueue < Sequel::Model(:queue)
  
  def self.enqueue( song, who )
    queue_item = SongQueue.create( song_id: song.id,
                                   inserted_by: who,
                                   inserted: Time.now )    
    SongQueue.count
  end
  
  def self.dequeue
    queue_item = SongQueue.order(:inserted).first
    song = nil
    if queue_item
      song = Song[queue_item.song_id]
      queue_item.delete
    end
    song
  end
end