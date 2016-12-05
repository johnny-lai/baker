# These are local paths
SRCROOT ?= $(abspath .)
BUILD_ROOT ?= $(SRCROOT)
TARGET_BUILD_DIR ?= $(BUILD_ROOT)
DOCKER_ROOT ?= $(SRCROOT)/docker
TEST_CONFIG_YML ?= $(SRCROOT)/config/test.yml

# The current version
MAJOR_VERSION ?= 0
MINOR_VERSION ?= 0
BUILD_NUMBER ?= 0
COMMIT ?= $(shell git log --pretty=format:'%h' -n 1)
VERSION = $(MAJOR_VERSION).$(MINOR_VERSION).$(BUILD_NUMBER)

# Application settings
APP_NAME ?= unset
APP_PACKAGE_NAME ?= $(APP_NAME)
APP_DOCKER_LABEL ?= $(APP_NAME)
APP_DOCKER_PUSH ?= yes
APP_SECRETS_ROOT ?= $(HOME)/.secrets/$(APP_NAME)
APP_ITEST_TYPE ?= cmdline
APP_ITEST_ENV_ROOT ?= $(SRCROOT)/itest/env
APP ?= $(TARGET_BUILD_DIR)/$(APP_NAME)

# These are paths used in the docker image
SRCROOT_D = /go/src/$(APP_PACKAGE_NAME)
BUILD_ROOT_D = $(SRCROOT_D)/tmp/dist
BEDROCK_ROOT_D = $(SRCROOT_D)/vendor/github.com/johnny-lai/bedrock
TEST_CONFIG_YML_D = $(SRCROOT_D)/config/production.yml
APP_SECRETS_ROOT_D = /etc/secrets

# Docker Labels
APP_DOCKER_LABEL_VERSION = $(APP_DOCKER_LABEL):$(MAJOR_VERSION).$(MINOR_VERSION)
APP_DOCKER_LABEL_COMMIT = $(APP_DOCKER_LABEL):$(COMMIT)

TESTDB_DOCKER_LABEL ?= $(APP_DOCKER_LABEL)-testdb
TESTDB_DOCKER_LABEL_VERSION = $(TESTDB_DOCKER_LABEL):$(MAJOR_VERSION).$(MINOR_VERSION)
TESTDB_DOCKER_LABEL_COMMIT = $(TESTDB_DOCKER_LABEL):$(COMMIT)

# Docker commands
DOCKER_VER_NUM ?= $(shell docker --version | cut -f1 "-d," | cut -f3 "-d ")
DOCKER_VER_MAJOR := $(shell echo $(DOCKER_VER_NUM) | cut -f1 -d.)
DOCKER_VER_MINOR := $(shell echo $(DOCKER_VER_NUM) | cut -f2 -d.)
DOCKER_GT_1_12 := $(shell [ $(DOCKER_VER_MAJOR) -gt 1 -o \( $(DOCKER_VER_MAJOR) -eq 1 -a $(DOCKER_VER_MINOR) -ge 12 \) ] && echo true)

ifeq ($(DOCKER_GT_1_12),true)
DOCKER_OPT_TAG_FORCE=
else
DOCKER_OPT_TAG_FORCE=-f
endif


DOCKER_DEV_UID ?= $(shell which docker-machine &> /dev/null || id -u)
DOCKER_DEV_GID ?= $(shell which docker-machine &> /dev/null || id -g)
DOCKER_OPTS ?= -v $(SRCROOT):$(SRCROOT_D) \
               -v $(KUBERNETES_CONFIG):/home/dev/.kube/config \
               -v $(KUBERNETES_CONFIG):/root/.kube/config \
               -v $(APP_SECRETS_ROOT):$(APP_SECRETS_ROOT_D) \
               -w $(SRCROOT_D) \
               -e "IN_DOCKER=true" \
               -e "DOCKER=$(DOCKER)" \
               -e "DOCKER_VER_NUM=$(DOCKER_VER_NUM)" \
               -e BUILD_ROOT=$(BUILD_ROOT_D) \
               -e APP_SECRETS_ROOT=$(APP_SECRETS_ROOT_D) \
               -e BUILD_NUMBER=$(BUILD_NUMBER) \
               -e DEV_UID=$(DOCKER_DEV_UID) \
               -e DEV_GID=$(DOCKER_DEV_GID) \
               --net=bridge
DOCKER ?= docker
ifneq ($(findstring gcr.io/,$(APP_DOCKER_LABEL)),)
	DOCKER_PUSH ?= gcloud docker push
else
	DOCKER_PUSH ?= $(DOCKER) push
endif

# Kubernetes config
KUBERNETES_CONFIG ?= $(BEDROCK_ROOT)/make/kubernetes.config.default

# Executables
GLIDE = $(GOPATH)/bin/glide
CLUSTER_SH = $(BEDROCK_ROOT)/scripts/cluster.sh

# Basic dependencies to build programs
deps:

$(GLIDE):
	go get github.com/Masterminds/glide

$(BUILD_ROOT):
	mkdir -p $(BUILD_ROOT)

$(APP_SECRETS_ROOT):
	mkdir -p $@

.PHONY: deps
