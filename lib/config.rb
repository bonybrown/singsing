require 'sequel'
require 'logger'
require 'yaml'

class Config
  
  @@config = YAML.load_file( File.join( File.dirname(__FILE__), '../config/config.yml' ) )
  
  def self.media_base_path
    @@config[:media_base_path]
  end
  
  def self.database_connection
    @@config[:database_connection_string]
  end
  
end

DB = Sequel.connect( Config.database_connection )
DB.loggers << Logger.new($stdout)