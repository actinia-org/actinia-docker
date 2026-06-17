# actinia docker image

A related docker image created and available for download from here:

https://hub.docker.com/r/mundialis/actinia

## Background info

This docker image is based on https://hub.docker.com/r/osgeo/grass-gis
(tag: _releasebranch_X_Y-ubuntu_) which provides the most recent stable
version of GRASS (_releasebranch_) with Python3 and PDAL support.
The GRASS image is based on the latest Ubuntu base image.

For most recent version of GRASS, change base image to
_osgeo/grass-gis:main-ubuntu_. The image can be chosen by setting
the _BRANCH_ build argument to _main_ (see below).

The Dockerfile contained in this folder is used to build via pipeline.
If you want to build manually...
## mind the build context!

Clone this repository and change directory:

```bash
$ git clone https://github.com/actinia-org/actinia-docker.git
$ cd actinia-docker
```

__Build an image with actinia and GRASS development versions__:

```bash
$ docker build \
         --file actinia-ubuntu/Dockerfile \
         --build-arg BRANCH=main \
         --tag actinia:latest-ubuntu .
```

View the images available using `docker images` and open a bash terminal with:

```bash
$ docker run -it --entrypoint=/bin/bash actinia:latest-ubuntu
root@c5e3b72ad8ba:/grassdb#
```

__To build a stable version__:
Update the line in the Dockerfile, where actinia-core is cloned and set it
to a certain version:
```bash
git clone --branch 4.8.0 --depth 1 https://github.com/actinia-org/actinia-core.git
```

then build and enter with:

```bash
$ docker build \
        --file actinia-ubuntu/Dockerfile \
        --tag actinia-core:4.8.0 .

$ docker run -it --entrypoint=/bin/bash actinia-core:4.8.0
root@c5e3b72ad8ba:/grassdb#
```
