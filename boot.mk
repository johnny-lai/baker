default: build

include $(BEDROCK_ROOT)/make/env.mk
include $(BEDROCK_ROOT)/make/bedrock.mk
include $(BEDROCK_ROOT)/make/build.mk
include $(BEDROCK_ROOT)/make/itest.mk
include $(BEDROCK_ROOT)/make/utest.mk
include $(BEDROCK_ROOT)/make/ibench.mk
include $(BEDROCK_ROOT)/make/gen.mk

migrate:
	./cmd/server/server --config config.yaml migratedb

fmt:
	GO15VENDOREXPERIMENT=1 go fmt $(APP_GO_PACKAGES)

devconsole:
	docker run --rm \
	           -e GO15VENDOREXPERIMENT=1 \
	           -it \
	           $(DOCKER_OPTS) \
	           $(DOCKER_DEVIMAGE)


.PHONY: build clean default deploy deps dist distbuild fmt migrate itest utest


