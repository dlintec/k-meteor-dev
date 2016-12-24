#!/bin/bash
current_dir="$(pwd)"
echo "DrMongo exposes local mongo database on port 3040"
echo "Access on http://localhost:3040"

export APP_PARAMETERS="--port 3040"


if [ ! -d /home/meteor/DrMongo ];then
  cd /home/meteor/
  git clone https://github.com/dlintec/DrMongo.git
fi
cd /home/meteor/DrMongo
meteor --port 3040
