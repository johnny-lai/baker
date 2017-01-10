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
distutest.testdb.run: image-testdb
	-$(DOCKER) rm -f $(APP_NAME)-testdb
	$(DOCKER) run -d -P --name $(APP_NAME)-testdb $(APP_DOCKER_LABEL)-testdb

distutest.env: distutest.testdb.run
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
