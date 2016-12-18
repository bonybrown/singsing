# singsing
A karaoke orchestrator using vlc for playback, with a universal web interface

Basically, a ruby-sinatra app that exposes a postgresql database containing
songs. Users can search and select songs to be placed in a queue, and the 
backend will continually dequeue items into vlc for playback.

Do not ask me for media or database entries for this app. It's strictly bring-your-own-media.

## Requirements

* Ruby
* Postgresql database
* VLC
* unzip

## To start

* `bundle install --path=.bundle`
* complete `config/config.yml`
* `bundle exec bin/singsing`
* navigate a browser to localhost:4567
