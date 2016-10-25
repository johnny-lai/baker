itest: itest.env
	go test -v $(APP_PACKAGE_NAME)/itest

itest.env: build
