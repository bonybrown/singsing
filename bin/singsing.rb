#!/usr/bin/env ruby
$LOAD_PATH.unshift 'lib'

require 'web_interface'
require 'vlc_handler'
require 'song_queue'

VlcHandler.start( SongQueue )

WebInterface.run!


