BEDROCK_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
include $(BEDROCK_ROOT)/boot.mk

# GO flags
ifeq ($(APP_GO_LINKING), static)
	GO_ENV ?= CGO_ENABLED=0
	GO_CFLAGS ?= -a
else
	GO_ENV ?=
	GO_CFLAGS ?=
endif

GO_TEST ?= go test

DOCKER_DEVIMAGE ?= johnnylai/bedrock-dev-golang:1.9
FIXTURES_ROOT_D = $(BEDROCK_ROOT_D)/fixtures/golang

APP_GO_LINKING ?= static
APP_GO_SOURCES ?= main.go
APP_GO_DEPS ?=
APP_GO_PACKAGES ?= $(APP_NAME) $(APP_NAME)/core/service
APP_GO_GLIDE_CHECK ?= vendor/github.com/onsi/ginkgo/README.md
APP_GO_HOST_ARCH ?= $(shell $(shell go env); echo $${GOOS}_$${GOARCH})
APP_GO_ARCHS ?= $(APP_GO_HOST_ARCH)
APP_ALL_ARCHS = $(patsubst %,$(APP)_%,$(APP_GO_ARCHS))

#- Build -----------------------------------------------------------------------
$(APP): $(APP_ALL_ARCHS)
	ln -sf $(APP)_$(APP_GO_HOST_ARCH) $(APP)

$(APP)_%: $(APP_GO_SOURCES) $(APP_GO_DEPS)
	GOOS=$(subst _, GOARCH=,$*) $(GO_ENV) go build $(GO_CFLAGS) \
		-o $@ \
		-ldflags "-X main.version=$(VERSION)-$(COMMIT)" \
		$(APP_GO_SOURCES)

#- Unit Tests ------------------------------------------------------------------
utest: deps
	TEST_APP=$(APP) TEST_CONFIG_YML=$(TEST_CONFIG_YML) SRCROOT=$(SRCROOT) $(GO_TEST) $(APP_GO_PACKAGES)

#- Integration Testing ---------------------------------------------------------
itest.run: itest.env
	$(GO_TEST) -v $(APP_PACKAGE_NAME)/itest
  
#- Dependencies ----------------------------------------------------------------

# Basic dependencies to build go programs
deps: $(GLIDE) $(BUILD_ROOT) $(WORKSPACE_ROOT)/$(APP_GO_GLIDE_CHECK)

$(WORKSPACE_ROOT)/$(APP_GO_GLIDE_CHECK): $(WORKSPACE_ROOT)/glide.yaml
	cd $(WORKSPACE_ROOT) && $(GLIDE) install

glide_touch:
	touch $(WORKSPACE_ROOT)/$(APP_GO_GLIDE_CHECK)
  
#- Clean -----------------------------------------------------------------------
clean: clean.go

clean.go:
	go clean
	git clean -ffxd $(WORKSPACE_ROOT)/vendor
	rm $(APP_ALL_ARCHS)
