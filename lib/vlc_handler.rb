require 'song_queue'
require 'song'
require 'vlc-client'

class VlcHandler
  
  @@vlc = nil
  @@thread = nil
  @@running = false
  
  def self.start
    @@thread = Thread.new{ run }
  end
  
  def self.stop
    @@running = false
    Thread.join( @@thread )
  end
  
  def self.run
    @@running = true
    vlc = VLC::System.new
    while( @@running ) do
      if !vlc.playing?
        puts "vlc: not playing, dequeue next song"
        next_song = SongQueue.dequeue
        if next_song
          vlc.play( next_song.full_path )
          play_start = 0
          #wait for playback to start
          while( play_start < 5 ) do
            puts "vlc: waiting for playback start (count=#{play_start}) progress=#{vlc.progress}"
            play_start += 1 if vlc.playing?
            sleep 1
          end
          vlc.fullscreen
        end
      else
        puts "vlc: is playing"
      end
      sleep 5
    end
  end
  
end