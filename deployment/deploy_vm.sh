#!/bin/bash

# echo yes | mix phx.gen.release --docker -- Need to copy over data/words.txt -- Is there a better way?
cd ..
tar -cvzf wavy_bird.tar.gz -X wavy_bird/deployment/exclude.txt wavy_bird
scp wavy_bird.tar.gz root@digital-ocean:/root
ssh digital-ocean << EOF
rm -rf wavy_bird/
tar -xvf wavy_bird.tar.gz
cd wavy_bird/
docker build . -t wavy-bird --build-arg MIX_ENV="prod"
docker-compose -f deployment/docker-compose.yaml -p wavy_bird down
docker-compose -f deployment/docker-compose.yaml -p wavy_bird up -d
EOF
