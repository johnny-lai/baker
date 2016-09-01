utest: deps
	TEST_CONFIG_YML=$(TEST_CONFIG_YML) GO15VENDOREXPERIMENT=1 go test $(APP_GO_PACKAGES)

distutest: distutest.env distutest.run

ifeq ($(TESTDB_DOCKER_LABEL),)
#- No Test Database ------------------------------------------------------------
distutest.env:

distutest.run:
	$(DOCKER) run --rm \
	           -e TEST_CONFIG_YML=$(TEST_CONFIG_YML_D) \
	           $(DOCKER_OPTS) \
	           $(DOCKER_UTEST_OPTS) \
	           $(DOCKER_DEVIMAGE) \
	           make utest
else
#- Has Test Database -----------------------------------------------------------
distutest.env: image-testdb
	-$(DOCKER) rm -f $(APP_NAME)-testdb
	$(DOCKER) run -d --name $(APP_NAME)-testdb $(APP_DOCKER_LABEL)-testdb
	sleep 5

distutest.run:
	$(DOCKER) run --rm \
	           --link $(APP_NAME)-testdb:$(APP_NAME)-db \
	           -e TEST_CONFIG_YML=$(TEST_CONFIG_YML_D) \
	           $(DOCKER_OPTS) \
	           $(DOCKER_UTEST_OPTS) \
	           $(DOCKER_DEVIMAGE) \
	           make utest

endif
