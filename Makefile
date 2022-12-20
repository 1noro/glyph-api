SHELL:=/bin/bash

IMAGE=1noro/glyph-api
target=debug
CONTAINER=glyph-api-container
VERSION=$(shell git log -n 1 --pretty=format:"%H")
EXTERNAL_PORT=8081
CONTAINER_PORT=8000
LOCAL_URL=http://api.glyph.localhost:$(EXTERNAL_PORT)

export DOCKER_BUILDKIT=1

all: help

.PHONY: build
build:
	@docker build -f Dockerfile --target $(target) --build-arg VERSION=$(VERSION) -t $(IMAGE):$(target) .

.PHONY: build-release
build-release:
	@docker build -f Dockerfile --target release --build-arg VERSION=$(VERSION) -t $(IMAGE):release .

.PHONY: build-all
build-all:
	@docker build -f Dockerfile --target debug --build-arg VERSION=$(VERSION) -t $(IMAGE):debug .
	@docker build -f Dockerfile --target release --build-arg VERSION=$(VERSION) -t $(IMAGE):release .

.PHONY: up
up:
	@docker run -d --rm -p $(EXTERNAL_PORT):$(CONTAINER_PORT) --name $(CONTAINER) $(IMAGE):$(target) 
	@echo "Running $(CONTAINER) in $(LOCAL_URL)"
	@echo "test if it is ok with: curl $(LOCAL_URL)/v1/healthcheck"

.PHONY: up-release
up-release:
	@docker run -d --rm -p $(EXTERNAL_PORT):$(CONTAINER_PORT) --name $(CONTAINER) $(IMAGE):release
	@echo "Running $(CONTAINER) in $(LOCAL_URL)"
	@echo "test if it is ok with: curl $(LOCAL_URL)/v1/healthcheck"

.PHONY: down
down:
	@docker stop $(CONTAINER) || true

.PHONY: clean
clean:
	@docker stop $(CONTAINER) 2> /dev/null || true
	@docker rmi $(IMAGE):$(target)

.PHONY: logs
logs:
	@docker logs -f $(CONTAINER)

.PHONY: bash
bash:
	@docker exec -u 0 -it $(CONTAINER) sh

.PHONY: bash-normal
bash-normal:
	@docker exec -it $(CONTAINER) sh

.PHONY: help
help:
	@echo "- default target=debug (debug || release)"
	@echo "make build"
	@echo "make build-release"
	@echo "make build-all"
	@echo "make up"
	@echo "make up-release"
	@echo "make down"
	@echo "make clean"
	@echo "make logs"
	@echo "make bash"
	@echo "make bash-normal"
