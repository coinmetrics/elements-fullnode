#!/bin/sh

set -e

export VERSION=$(cat version.txt)
echo "Image version ${VERSION}."

IMAGENAME="${CI_PROJECT_NAME:-$(basename "$PWD")}"

echo "Building image '$IMAGENAME:$VERSION'..."
docker build --build-arg "VERSION=${VERSION}" -t "${IMAGENAME}:${VERSION}" .
echo "Image ready."

pushimage() {

    DOCKER_REGISTRY_REPO="$1"
    DOCKER_REGISTRY_USER="$2"
    DOCKER_REGISTRY_PASSWORD="$3"
    IMAGENAME="$4"
    DOCKER_REGISTRY_REPO_VERSION="$5"
    DOCKER_REGISTRY_REPO="$6"

    if [ -n "${DOCKER_REGISTRY}" ] && [ -n "${DOCKER_REGISTRY_USER}" ] && [ -n "${DOCKER_REGISTRY_PASSWORD}" ]
    then
        echo "Logging into ${DOCKER_REGISTRY}..."
        docker login -u="${DOCKER_REGISTRY_USER}" -p="${DOCKER_REGISTRY_PASSWORD}" "${DOCKER_REGISTRY}"
        echo "Pushing image to ${DOCKER_REGISTRY_REPO}:${DOCKER_REGISTRY_REPO_VERSION}..."
        docker tag "${IMAGENAME}:${DOCKER_REGISTRY_REPO_VERSION}" "${DOCKER_REGISTRY_REPO}:${DOCKER_REGISTRY_REPO_VERSION}"
        docker push "${DOCKER_REGISTRY_REPO}:${DOCKER_REGISTRY_REPO_VERSION}"
    fi

}

pushimage "${DOCKER_REGISTRY}"  "${DOCKER_REGISTRY_USER}" "${DOCKER_REGISTRY_PASSWORD}""${IMAGENAME}" "${VERSION}" "${DOCKER_REGISTRY_REPO}"
pushimage "registry.gitlab.com" "gitlab-ci-token"         "${CI_BUILD_TOKEN}"          "${IMAGENAME}" "${VERSION}" "registry.gitlab.com/${CI_PROJECT_PATH}"
pushimage "index.docker.io"     "${DOCKERHUB_USER}"       "${DOCKERHUB_PASSWORD}"      "${IMAGENAME}" "${VERSION}" "index.docker.io/${CI_PROJECT_PATH}"

