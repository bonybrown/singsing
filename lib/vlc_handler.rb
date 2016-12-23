require 'song_queue'
require 'song'
require 'zip'

class VlcHandler
  
  @@vlc_pid = 0
  @@thread = nil
  @@running = false
  @@current_tempdir = nil
  
  def self.start
    @@thread = Thread.new{ run }
  end
  
  def self.stop
    @@running = false
    Process.kill('kill', @@vlc_pid ) if @@vlc_pid > 0
    Thread.join( @@thread )
  end
  
  def self.unzip( song )
    puts "Attempting to unzip #{song.full_path}"
    @@current_tempdir = Dir.mktmpdir
    mp3 = nil
    Zip::File.open( song.full_path ) do | zip_file |
      mp3 = zip_file.glob('*.mp3').first
      puts "MP3 in zip file is #{mp3.name}"
#       zip_file.each do | entry |
#         extraction_name = File.join(@@current_tempdir, entry.name)
#         puts "Extracting #{extraction_name}"
#         entry.extract(extraction_name)
#       end
    end
    # Have to use system unzip command because rubyzip 
    # chokes on some files: Unknown compression type 9
    system 'unzip', song.full_path , '-d', @@current_tempdir
    File.join(@@current_tempdir, mp3.name)
  end
  
  def self.run
    @@running = true
    while( @@running ) do
      begin
        #puts "vlc: not playing, dequeue next song"
        next_song = SongQueue.peek
        if next_song
          
          media_file = next_song.full_path 
          media_file = unzip( next_song ) if next_song.is_zip_file?
          puts media_file
          
          @@vlc_pid = spawn('vlc','--fullscreen','--no-video-title-show','--play-and-exit',media_file)
          Process.wait(@@vlc_pid)
          next_song.queue_entry.dequeue
          @@vlc_pid  = 0
          FileUtils.remove_entry @@current_tempdir if @@current_tempdir
          @@current_tempdir = nil
        end
        sleep 5
      rescue StandardError => e
        $stderr.puts "ERROR: vlc_handler -> #{e}"
      end
    end
  end
  
end