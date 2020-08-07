PROJECT = kube-watch
VERSION = 0.4.1

REGISTRY = quay.io
USER = aialferov

GIT_SHA = $(shell git rev-parse HEAD | cut -c1-8)

IMAGE = ${REGISTRY}/${USER}/${PROJECT}:${VERSION}
IMAGE_LATEST = ${REGISTRY}/${USER}/${PROJECT}:latest

BUILD_ARGS = \
	--build-arg PROJECT=${PROJECT} \
	--build-arg VERSION=${VERSION} \
	--build-arg GIT_SHA=${GIT_SHA}

shellcheck:
	shellcheck -as bash src/${PROJECT}{,-handle-{channel,file}}

image: image-build

image-build:
	docker build ${BUILD_ARGS} . -t ${IMAGE}

image-push:
	docker push ${IMAGE}

image-release: image-local-release image-push
	docker push ${IMAGE_LATEST}

image-local-release:
	docker tag ${IMAGE} ${IMAGE_LATEST}

image-clean:
	docker system prune -f --filter label=PROJECT=${PROJECT}

image-distclean: image-clean
	docker rmi ${IMAGE_LATEST} ${IMAGE} 2>/dev/null || true

git-release:
	git tag -a ${VERSION}
	git push origin ${VERSION}

version:
	@echo "${VERSION} {git-${GIT_SHA}}"
