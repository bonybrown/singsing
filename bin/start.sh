#!/bin/bash

bundle exec bin/singsing.rb &
sleep 2
chromium-browser --app=http://localhost:8000/queue.html
