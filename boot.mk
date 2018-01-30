default: build

include $(BEDROCK_ROOT)/make/env.mk
ifeq ($(BAKER_INCLUDE_BEDROCK_MK),yes)
	include $(BEDROCK_ROOT)/make/bedrock.mk
endif
ifeq ($(BAKER_INCLUDE_BUILD_MK),yes)
	include $(BEDROCK_ROOT)/make/build.mk
endif
ifeq ($(BAKER_INCLUDE_ITEST_MK),yes)
	include $(BEDROCK_ROOT)/make/itest.mk
endif
ifeq ($(BAKER_INCLUDE_UTEST_MK),yes)
	include $(BEDROCK_ROOT)/make/utest.mk
endif
ifeq ($(BAKER_INCLUDE_IBENCH_MK),yes)
	include $(BEDROCK_ROOT)/make/ibench.mk
endif
ifeq ($(BAKER_INCLUDE_GEN_MK),yes)
	include $(BEDROCK_ROOT)/make/gen.mk
endif

migrate:
	./cmd/server/server --config config.yaml migratedb

fmt:
	go fmt $(APP_GO_PACKAGES)

devconsole:
	docker run --rm \
	           -it \
	           $(DOCKER_OPTS) \
	           $(DOCKER_DEVIMAGE)


.PHONY: build clean default deploy deps dist distbuild fmt migrate itest utest


