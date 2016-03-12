DOCKER_DEVIMAGE ?= johnnylai/bedrock-dev-swift:2.2
FIXTURES_ROOT_D = $(BEDROCK_ROOT_D)/fixtures/swift

build:
	swift build

clean: clean.swift

clean.swift:
	rm -rf .build