# actinia alpine docker image

A related docker image created and available for download from here:

https://hub.docker.com/r/mundialis/actinia

First it creates a build image and a runtime image with packages and dependencies, from them the final image is created:

__Build with__:

```bash
$ docker build \
        --pull \
        --no-cache \
        --file actinia-alpine/Dockerfile_build_pkgs \
        --tag actinia:alpine-build-pkgs .
$ docker tag actinia:alpine-build-pkgs mundialis/actinia:alpine-build-pkgs_v10
$ docker push mundialis/actinia:alpine-build-pkgs_v10

$ docker build \
        --pull \
        --no-cache \
        --file actinia-alpine/Dockerfile_runtime_pkgs \
        --tag actinia:alpine-runtime-pkgs .
$ docker tag actinia:alpine-runtime-pkgs mundialis/actinia:alpine-runtime-pkgs_v10
$ docker push mundialis/actinia:alpine-runtime-pkgs_v10

$ docker build \
        --pull \
        --no-cache \
        --file actinia-alpine/Dockerfile \
        --tag actinia:latest \
        .

```
