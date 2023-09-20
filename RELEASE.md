Steps when releasing actinia-docker:

## 1. Prepare release and version
* Run in terminal
    ```
    ESTIMATED_VERSION=2.6.0

    gh api repos/actinia-org/actinia-docker/releases/generate-notes -f tag_name="$ESTIMATED_VERSION" -f target_commitish=main -q .body
    ```
* Go to https://github.com/actinia-org/actinia-docker/releases/new
* Copy the output of terminal command to the release description
* You can [compare manually](https://github.com/actinia-org/actinia-docker/compare/2.5.12...main) if all changes are included. If changes were pushed directly to main branch, they are not included.
* Check if `ESTIMATED_VERSION` increase still fits - we follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
* Fill in tag and release title with this version
* At the bottom of the release, add
  "generated with `gh api repos/actinia-org/actinia-docker/releases/generate-notes -f tag_name="$ESTIMATED_VERSION" -f target_commitish=main -q .body`" and replace `$ESTIMATED_VERSION` with the actual version.
* Make sure that the checkbox for "Set as the latest release" is checked so that this version appears on the main github repo page
* Now you can save the release

## Outcome:
* Automatically a new docker image with the new tag will be created and pushed to [Dockerhub](https://hub.docker.com/r/mundialis/actinia/tags)
