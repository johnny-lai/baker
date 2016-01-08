utest: deps
	TEST_CONFIG_YML=$(TEST_CONFIG_YML) GO15VENDOREXPERIMENT=1 go test $(APP_GO_PACKAGES)

distutest: distutest.env distutest.run

ifeq ($(TESTDB_DOCKER_LABEL),)
#- No Test Database ------------------------------------------------------------
distutest.env:

distutest.run:
	$(DOCKER) run --rm \
	           -v $(SRCROOT):$(SRCROOT_D) \
	           -v $(APP_SECRETS_ROOT):/etc/secrets \
	           -w $(SRCROOT_D) \
	           -e DEV_UID=$(DOCKER_DEV_UID) \
	           -e DEV_GID=$(DOCKER_DEV_GID) \
	           -e TEST_CONFIG_YML=$(TEST_CONFIG_YML_D) \
	           $(DOCKER_DEVIMAGE) \
	           make utest
else
#- Has Test Database -----------------------------------------------------------
distutest.env:
	-$(DOCKER) rm -f $(APP_NAME)-testdb
	$(DOCKER) run -d --name $(APP_NAME)-testdb $(APP_DOCKER_LABEL)-testdb
	sleep 5

distutest.run:
	$(DOCKER) run --rm \
	           --link $(APP_NAME)-testdb:$(APP_NAME)-db \
	           -v $(SRCROOT):$(SRCROOT_D) \
	           -v $(APP_SECRETS_ROOT):/etc/secrets \
	           -w $(SRCROOT_D) \
	           -e DEV_UID=$(DOCKER_DEV_UID) \
	           -e DEV_GID=$(DOCKER_DEV_GID) \
	           -e TEST_CONFIG_YML=$(TEST_CONFIG_YML_D) \
	           $(DOCKER_DEVIMAGE) \
	           make utest

endif