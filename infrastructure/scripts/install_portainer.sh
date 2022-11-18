#!/bin/bash
set -e

curl -L https://downloads.portainer.io/ce2-16/portainer-agent-stack.yml -o portainer-agent-stack.yml
sudo docker stack deploy -c portainer-agent-stack.yml portainer
