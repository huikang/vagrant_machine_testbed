#! /bin/bash

#docker_cmd=docker-1.7.0-rc3
docker_cmd=docker-1.7.0-dev

/root/${docker_cmd} -dD -l debug       \
    --insecure-registry 9.12.248.205:5000 \
    -s aufs

# -s vfs
