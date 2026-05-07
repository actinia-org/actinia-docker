Steps when releasing actinia-docker:

## 1. Prepare release and version
* Go to https://github.com/actinia-org/actinia-docker/releases/new
* Fill in tag and release title with a version - we follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
* Press the button `Generate release notes` and adjust if needed
  * You can [compare manually](https://github.com/actinia-org/actinia-docker/compare/2.5.12...main) if all changes are included. If changes were pushed directly to main branch, they are not included.
* Make sure that the checkbox for "Set as the latest release" is checked so that this version appears on the main github repo page
* Now you can save the release

## Outcome:
* Automatically a new docker image with the new tag will be created and pushed to [Dockerhub](https://hub.docker.com/r/mundialis/actinia/tags)
