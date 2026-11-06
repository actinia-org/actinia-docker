Steps when releasing actinia-docker:

## 1. Prepare release and version
- Go to https://github.com/actinia-org/actinia-docker/releases/new
- Fill in tag and release title with new version. We follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
- Click `Generate release notes`
- Adjust if needed
  - You can [compare manually](https://github.com/actinia-org/actinia-docker/compare/2.5.12...main)
  - Check again that the new version still fits
- Make sure that "Release label" is set to "Latest" so that this version appears on the main github repo page
- Now you can save the release

## Outcome:
- Automatically a new docker image with the new tag will be created and pushed to [Dockerhub](https://hub.docker.com/r/mundialis/actinia/tags)
