#Needs the following environment variables:
#	NAME - the application name in lowercase
#	ARCH - the architecture type, e.g 'amd64'
#	VERSION - the version
#	DOCKER_USER - the docker username
#	DOCKER_PASS - the docker password
#	DOCKER_REPO - the docker repository
default: all
all: push

help:
	@echo 'Makefile targets to build and push Docker images'
	@echo
	@echo 'Usage:'
	@echo '	build			Builds the image for given ARCH'
	@echo '	push			Pushes the image to given DOCKER_REPO'
	@echo '	manifest		Creates manifest'
	@echo '	clean			Removes temporary folders'
	@echo

build:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	curl -sL https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1/qemu-arm-static.tar.gz | tar -xzC .
	docker build --pull --cache-from ${DOCKER_USER}/${NAME}:${VERSION}-${ARCH} --build-arg VCS_URL=${TRAVIS_REPO_SLUG} --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=${TRAVIS_COMMIT} --build-arg VERSION=${VERSION} -t "${DOCKER_USER}/${NAME}:${VERSION}-${ARCH}" -f Dockerfile.${ARCH} .

push: build
	docker login -u ${DOCKER_USER} -p ${DOCKER_PASS} ${DOCKER_REPO}
	docker push "${DOCKER_USER}/${NAME}:${VERSION}-${ARCH}"

manifest:
	docker login -u ${DOCKER_USER} -p ${DOCKER_PASS} ${DOCKER_REPO}
	wget https://github.com/estesp/manifest-tool/releases/download/v0.7.0/manifest-tool-linux-amd64
	chmod +x manifest-tool-linux-amd64
	./manifest-tool-linux-amd64 push from-spec manifests/${VERSION}-multiarch.yml

clean:
	rm -rf qemu-arm-static
