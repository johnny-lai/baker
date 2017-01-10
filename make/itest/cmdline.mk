itest: itest.env
	$(GO_TEST) -v $(APP_PACKAGE_NAME)/itest

itest.env: build
