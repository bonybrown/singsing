#!/usr/bin/env ruby
$LOAD_PATH.unshift 'lib'

require 'web_interface'
require 'vlc_handler'

VlcHandler.start

WebInterface.run!


