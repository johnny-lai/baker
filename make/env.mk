# These are local paths
SRCROOT ?= $(abspath .)
DOCKER_ROOT ?= $(SRCROOT)/docker
TEST_CONFIG_YML ?= $(SRCROOT)/config/test.yml
PRODUCT_PATH = tmp/dist/$(APP_NAME)

# These are paths used in the docker image
SRCROOT_D = /go/src/$(APP_NAME)
BUILD_ROOT_D = $(SRCROOT_D)/tmp/dist
TEST_CONFIG_YML_D = $(SRCROOT_D)/config/production.yml

# The current version
MAJOR_VERSION ?= 0
MINOR_VERSION ?= 0
BUILD_NUMBER ?= 0
COMMIT ?= $(shell git log --pretty=format:'%h' -n 1)
VERSION = $(MAJOR_VERSION).$(MINOR_VERSION).$(BUILD_NUMBER)

# Application settings
APP_NAME ?= unset
APP_DOCKER_LABEL ?= $(APP_NAME)
APP_GO_LINKING ?= dynamic
APP_GO_SOURCES ?= main.go
APP_DOCKER_PUSH ?= yes
APP_ITEST_ENV_ROOT ?= $(SRCROOT)/itest/env

# Docker Labels
APP_DOCKER_LABEL_VERSION = $(APP_DOCKER_LABEL):$(MAJOR_VERSION).$(MINOR_VERSION)
APP_DOCKER_LABEL_COMMIT = $(APP_DOCKER_LABEL):$(COMMIT)

TESTDB_DOCKER_LABEL ?= $(APP_DOCKER_LABEL)-testdb
TESTDB_DOCKER_LABEL_VERSION = $(TESTDB_DOCKER_LABEL):$(MAJOR_VERSION).$(MINOR_VERSION)
TESTDB_DOCKER_LABEL_COMMIT = $(TESTDB_DOCKER_LABEL):$(COMMIT)

# Docker commands
DOCKER_DEVIMAGE ?= johnnylai/bedrock-dev:17cbf55
DOCKER_DEV_UID ?= $(shell which docker-machine &> /dev/null || id -u)
DOCKER_DEV_GID ?= $(shell which docker-machine &> /dev/null || id -g)
DOCKER_OPTS ?= -v $(SRCROOT):$(SRCROOT_D) \
               -v $(KUBERNETES_CONFIG):/home/dev/.kube/config \
               -v $(KUBERNETES_CONFIG):/root/.kube/config \
               -w $(SRCROOT_D) \
               -e DEV_UID=$(DOCKER_DEV_UID) \
               -e DEV_GID=$(DOCKER_DEV_GID)
ifneq ($(findstring gcr.io/,$(APP_DOCKER_LABEL)),)
	DOCKER_PUSH ?= gcloud docker push
else
	DOCKER_PUSH ?= docker push
endif

# Kubernetes config
KUBERNETES_CONFIG ?= $(BEDROCK_ROOT)/make/kubernetes.config.default

# Executables
GLIDE = $(GOPATH)/bin/glide
BEDROCK = $(SRCROOT)/bedrock

deps: $(GLIDE) $(BUILD_ROOT)
	if [ ! -d vendor/github.com/gin-gonic/gin ]; then $(GLIDE) update; fi

$(GLIDE): $(SRCROOT)/glide.yaml
	go get github.com/Masterminds/glide

$(BEDROCK): $(BEDROCK_ROOT)/cli/*.go deps
	GO15VENDOREXPERIMENT=1 go build -o $(BEDROCK) $(BEDROCK_ROOT)/cli/bedrock.go

$(BUILD_ROOT):
	mkdir -p $@
