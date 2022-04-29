# actinia alpine docker image

A related docker image created and available for download from here:

https://hub.docker.com/r/mundialis/actinia

First it creates a base image with packages, dependencies and dependencies, from this the final image is created:

__Build with__:

```bash
$ docker build \
        --pull \
        --no-cache \
        --file actinia-alpine/Dockerfile_alpine_dependencies \
        --tag actinia:alpine-dependencies .
$ docker tag actinia:alpine-dependencies mundialis/actinia:alpine-dependencies-v1
$ docker push mundialis/actinia:alpine-dependencies-v1

$ docker build \
        --pull \
        --no-cache \
        --file actinia-alpine/Dockerfile \
        --tag actinia:latest \
        .

```
