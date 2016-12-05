BEDROCK_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
include $(BEDROCK_ROOT)/boot.mk

# GO flags
ifeq ($(APP_GO_LINKING), static)
	GO_ENV ?= GO15VENDOREXPERIMENT=1 CGO_ENABLED=0
	GO_CFLAGS ?= -a
else
	GO_ENV ?= GO15VENDOREXPERIMENT=1
	GO_CFLAGS ?=
endif

DOCKER_DEVIMAGE ?= johnnylai/bedrock-dev-golang:1.7
FIXTURES_ROOT_D = $(BEDROCK_ROOT_D)/fixtures/golang

APP_GO_LINKING ?= static
APP_GO_SOURCES ?= main.go
APP_GO_PACKAGES ?= $(APP_NAME) $(APP_NAME)/core/service
APP_GO_GLIDE_CHECK ?= vendor/github.com/onsi/ginkgo/README.md
APP_GO_HOST_ARCH ?= $(shell $(shell go env); echo $${GOOS}_$${GOARCH})
APP_GO_ARCHS ?= $(APP_GO_HOST_ARCH)

#- Build -----------------------------------------------------------------------
$(APP): $(patsubst %,$(APP)_%,$(APP_GO_ARCHS))
	ln -sf $(APP)_$(APP_GO_HOST_ARCH) $(APP)

$(APP)_%: $(APP_GO_SOURCES)
	GOOS=$(subst _, GOARCH=,$*) $(GO_ENV) go build $(GO_CFLAGS) \
		-o $@ \
		-ldflags "-X main.version=$(VERSION)-$(COMMIT)" \
		$(APP_GO_SOURCES)

#- Integration Testing ---------------------------------------------------------
itest.run: itest.env
	go test -v $(APP_PACKAGE_NAME)/itest
  
#- Dependencies ----------------------------------------------------------------

# Basic dependencies to build go programs
deps: $(GLIDE) $(BUILD_ROOT) $(SRCROOT)/$(APP_GO_GLIDE_CHECK)

$(SRCROOT)/$(APP_GO_GLIDE_CHECK): $(SRCROOT)/glide.yaml
	$(GLIDE) install

glide_touch:
	touch $(SRCROOT)/$(APP_GO_GLIDE_CHECK)
  
#- Clean -----------------------------------------------------------------------
clean: clean.go

clean.go:
	go clean
	git clean -ffxd vendor
