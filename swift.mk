BEDROCK_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
include $(BEDROCK_ROOT)/boot.mk

DOCKER_DEVIMAGE ?= johnnylai/bedrock-dev-swift:3.0
FIXTURES_ROOT_D = $(BEDROCK_ROOT_D)/fixtures/swift

build:
	swift build

clean: clean.swift

clean.swift:
	rm -rf .build
