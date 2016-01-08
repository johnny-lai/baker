# GO flags
ifeq ($(APP_GO_LINKING), static)
	GO_ENV ?= GO15VENDOREXPERIMENT=1 CGO_ENABLED=0
	GO_CFLAGS ?= -a
else
	GO_ENV ?= GO15VENDOREXPERIMENT=1
	GO_CFLAGS ?=
endif

DOCKER_DEVIMAGE ?= johnnylai/bedrock-dev-golang:1.5
FIXTURES_ROOT_D = $(BEDROCK_ROOT_D)/fixtures/golang

APP_GO_LINKING ?= static
APP_GO_SOURCES ?= main.go
APP_GO_PACKAGES ?= $(APP_NAME) $(APP_NAME)/core/service

#- Build -----------------------------------------------------------------------
$(APP): $(APP_GO_SOURCES)
	$(GO_ENV) go build $(GO_CFLAGS) \
		-o $@ \
		-ldflags "-X main.version=$(VERSION)-$(COMMIT)" \
		$(APP_GO_SOURCES)

#- Dependencies ----------------------------------------------------------------
# Directory of logrus. Used to detect if `glide update` is needed
LOGRUS_ROOT = $(SRCROOT)/vendor/github.com/Sirupsen/logrus

# Basic dependencies to build go programs
deps: $(GLIDE) $(BUILD_ROOT) $(LOGRUS_ROOT)

$(LOGRUS_ROOT): $(SRCROOT)/glide.yaml
	$(GLIDE) update

#- Clean -----------------------------------------------------------------------
clean: clean.go

clean.go:
	go clean
	git clean -ffxd vendor