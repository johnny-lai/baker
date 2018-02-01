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
APP_GO_PACKAGE_MANAGER ?= dep
APP_GO_PACKAGES ?= $(APP_NAME) $(APP_NAME)/core/service
APP_GO_VENDOR_CHECK ?= $(WORKSPACE_ROOT)/vendor/.vendor_check
APP_GO_HOST_ARCH ?= $(shell $(shell go env); echo $${GOOS}_$${GOARCH})
APP_GO_ARCHS ?= $(APP_GO_HOST_ARCH)
APP_ALL_ARCHS = $(patsubst %,$(APP)_%,$(APP_GO_ARCHS))

#- Build -----------------------------------------------------------------------
$(APP): $(APP_ALL_ARCHS)
	ln -sf $(APP)_$(APP_GO_HOST_ARCH) $(APP)

$(APP)_%: $(APP_GO_SOURCES) $(APP_GO_DEPS) $(WORKSPACE_ROOT)/$(APP_GO_GLIDE_CHECK)
	GOOS=$(subst _, GOARCH=,$*) $(GO_ENV) go build $(GO_CFLAGS) \
		-o $@ \
		-ldflags "-X main.version=$(VERSION)-$(COMMIT)" \
		$(APP_GO_SOURCES)

#- Unit Tests ------------------------------------------------------------------
ifeq ($(BAKER_INCLUDE_UTEST_MK),yes)
utest: deps
	TEST_APP=$(APP) TEST_CONFIG_YML=$(TEST_CONFIG_YML) SRCROOT=$(SRCROOT) $(GO_TEST) $(APP_GO_PACKAGES)
endif

#- Integration Testing ---------------------------------------------------------
ifeq ($(BAKER_INCLUDE_ITEST_MK),yes)
itest.run: itest.env
	$(GO_TEST) -v $(APP_PACKAGE_NAME)/itest
endif
  
#- Dependencies ----------------------------------------------------------------
DEP ?= dep

# Basic dependencies to build go programs
deps: $(BUILD_ROOT) $(APP_GO_VENDOR_CHECK)

ifeq ($(APP_GO_PACKAGE_MANAGER),glide)
$(APP_GO_VENDOR_CHECK): $(WORKSPACE_ROOT)/glide.yaml $(WORKSPACE_ROOT)/glide.lock
	cd $(WORKSPACE_ROOT) && $(GLIDE) install
	touch $(APP_GO_VENDOR_CHECK)
endif

ifeq ($(APP_GO_PACKAGE_MANAGER),dep)
$(APP_GO_VENDOR_CHECK): $(WORKSPACE_ROOT)/Gopkg.toml $(WORKSPACE_ROOT)/Gopkg.lock
	cd $(WORKSPACE_ROOT) && $(DEP) ensure
	touch $(APP_GO_VENDOR_CHECK)
endif

#- Clean -----------------------------------------------------------------------
clean: clean.go

clean.go:
	go clean
	git clean -ffxd $(WORKSPACE_ROOT)/vendor
	rm -f $(APP_ALL_ARCHS)
