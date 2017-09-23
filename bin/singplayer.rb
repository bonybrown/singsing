#!/usr/bin/env ruby
$LOAD_PATH.unshift 'lib'

require 'remote_queue'
require 'vlc_handler'

VlcHandler.run( RemoteQueue )

