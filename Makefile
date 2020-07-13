COMMIT ?= $(shell git log --pretty=format:'%h' -n 1)

DOCKER ?= docker

IMAGE_NAME = johnnylai/bedrock-dev

default: deploy

fmt:
	go fmt

image.dev.golang:
	$(DOCKER) build -t $(IMAGE_NAME)-golang -f docker/dev/golang.dockerfile .
	$(DOCKER) tag $(IMAGE_NAME)-golang $(IMAGE_NAME)-golang:1.14
	$(DOCKER) tag $(IMAGE_NAME)-golang $(IMAGE_NAME)-golang:$(COMMIT)

image.swift:
	$(DOCKER) build -t johnnylai/swift:3.0 -f docker/swift/Dockerfile .

image.dev.swift: image.swift
	$(DOCKER) build -t $(IMAGE_NAME)-swift -f docker/dev/swift.dockerfile .
	$(DOCKER) tag $(IMAGE_NAME)-swift $(IMAGE_NAME)-swift:3.0
	$(DOCKER) tag $(IMAGE_NAME)-swift $(IMAGE_NAME)-swift:$(COMMIT)

deploy.dev.golang: image.dev.golang
	$(DOCKER) push $(IMAGE_NAME)-golang
	$(DOCKER) push $(IMAGE_NAME)-golang:1.14
	
deploy.dev.swift: image.dev.swift
	$(DOCKER) push $(IMAGE_NAME)-swift
	$(DOCKER) push $(IMAGE_NAME)-swift:3.0

deploy: deploy.dev.golang deploy.dev.swift
