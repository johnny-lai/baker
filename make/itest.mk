include $(BEDROCK_ROOT)/make/itest/$(APP_ITEST_TYPE).mk

distitest: distitest.env distitest.run

ifeq ($(TESTDB_DOCKER_LABEL),)
#- No Test Database ------------------------------------------------------------
distitest.env:

distitest.run:
	$(DOCKER) run --rm \
	           -e TEST_CONFIG_YML=$(TEST_CONFIG_YML_D) \
	           $(DOCKER_OPTS) \
	           $(DOCKER_UTEST_OPTS) \
	           $(DOCKER_DEVIMAGE) \
	           make itest
else
#- Has Test Database -----------------------------------------------------------
# Re-use unit test database

distitest.env: distutest.testdb.run
	sleep 5

distitest.run:
	$(DOCKER) run --rm \
	           --link $(APP_NAME)-testdb:$(APP_NAME)-db \
	           -e TEST_CONFIG_YML=$(TEST_CONFIG_YML_D) \
	           $(DOCKER_OPTS) \
	           $(DOCKER_UTEST_OPTS) \
	           $(DOCKER_DEVIMAGE) \
	           make itest

endif
