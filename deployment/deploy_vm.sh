#!/bin/bash

# echo yes | mix phx.gen.release --docker
docker buildx build . -t registry.devtoolbelt.xyz/wavy-bird:latest --platform linux/amd64 --push && \
scp deployment/docker-compose.yaml root@digital-ocean:/root/wavy_bird && \
scp deployment/.env root@digital-ocean:/root/wavy_bird && \
scp -r data/ root@digital-ocean:/root/wavy_bird/ && \
ssh digital-ocean << EOF
docker-compose -f wavy_bird/docker-compose.yaml -p wavy_bird down && \
docker-compose -f wavy_bird/docker-compose.yaml -p wavy_bird up -d
EOF
