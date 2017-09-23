require 'config'
require 'json'

class RemoteQueue
    
  def self.dequeue( id )
    dequeue_url = URI.join( Config.remote_url, "/dequeue?id=#{id}" )
    Net::HTTP.get( dequeue_url )
  end
  
  def self.peek
    peek_url = URI.join( Config.remote_url, "/peek" )
    result = Net::HTTP.get( peek_url )
    data = JSON.parse(result)
    return nil if data.empty?
    Song.new( data )
  end
  
  class Song
    attr_reader :filename, :queue_id
    
    def initialize( hash )
      hash.each_pair do |k,v|
        instance_variable_set("@#{k}",v)
      end
    end
    
    def full_path
      File.join( Config.media_base_path, filename )
    end
  
    def is_zip_file?
      filename.match( /\.ZIP$/i )
    end
  end
end