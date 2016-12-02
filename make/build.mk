build: deps $(APP)

$(APP): $(BUILD_ROOT)

clean:
	rm -f $(BEDROCK)
	rm -f $(APP)

dist: image-dist image-testdb

distrun: distutest.env
	$(DOCKER) run --rm \
	           --link $(APP_NAME)-testdb:$(APP_NAME)-db \
               -p 8080:8080 \
	           -v $(APP_SECRETS_ROOT):/etc/secrets \
	           $(APP_DOCKER_LABEL_COMMIT)

distrun.env: distutest.env
	$(DOCKER) run --rm \
	           --link $(APP_NAME)-testdb:$(APP_NAME)-db \
	           -v $(APP_SECRETS_ROOT):/etc/secrets \
	           $(APP_DOCKER_LABEL_COMMIT) \
             env

distrun.sh:
	$(DOCKER) run --rm \
	           --link $(APP_NAME)-testdb:$(APP_NAME)-db \
	           -v $(APP_SECRETS_ROOT):/etc/secrets \
	           --entrypoint sh \
	           -it \
	           $(APP_DOCKER_LABEL_COMMIT)

distbuild:
	$(DOCKER) run --rm \
	           $(DOCKER_OPTS) \
	           $(DOCKER_DEVIMAGE) \
	           make build

distclean:
	$(DOCKER) run --rm \
	           $(DOCKER_OPTS) \
	           $(DOCKER_DEVIMAGE) \
	           make clean

distpush: image-dist.push image-testdb.push

distpublish: image-dist.publish image-testdb.publish

deploy: dist distutest distpush distitest

image-testdb:
	$(DOCKER) build -f $(DOCKER_ROOT)/testdb/Dockerfile -t $(TESTDB_DOCKER_LABEL_COMMIT) $(SRCROOT)
	$(DOCKER) tag $(DOCKER_OPT_TAG_FORCE) $(TESTDB_DOCKER_LABEL_COMMIT) $(TESTDB_DOCKER_LABEL)
	$(DOCKER) tag $(DOCKER_OPT_TAG_FORCE) $(TESTDB_DOCKER_LABEL_COMMIT) $(TESTDB_DOCKER_LABEL_VERSION)

image-testdb.push:
	if [ "$(APP_DOCKER_PUSH)" != "no" ]; then \
		$(DOCKER_PUSH) $(TESTDB_DOCKER_LABEL_COMMIT); \
	fi

image-testdb.publish:
	if [ "$(APP_DOCKER_PUSH)" != "no" ]; then \
		$(DOCKER_PUSH) $(TESTDB_DOCKER_LABEL_COMMIT); \
		$(DOCKER_PUSH) $(TESTDB_DOCKER_LABEL_VERSION); \
	fi

image-dist: distbuild
	$(DOCKER) build -f $(DOCKER_ROOT)/dist/Dockerfile -t $(APP_DOCKER_LABEL_COMMIT) $(SRCROOT)
	$(DOCKER) tag $(DOCKER_OPT_TAG_FORCE) $(APP_DOCKER_LABEL_COMMIT) $(APP_DOCKER_LABEL)
	$(DOCKER) tag $(DOCKER_OPT_TAG_FORCE) $(APP_DOCKER_LABEL_COMMIT) $(APP_DOCKER_LABEL_VERSION)

image-dist.push:
	if [ "$(APP_DOCKER_PUSH)" != "no" ]; then \
		$(DOCKER_PUSH) $(APP_DOCKER_LABEL_COMMIT); \
	fi

image-dist.publish:
	if [ "$(APP_DOCKER_PUSH)" != "no" ]; then \
		$(DOCKER_PUSH) $(APP_DOCKER_LABEL_COMMIT); \
		$(DOCKER_PUSH) $(APP_DOCKER_LABEL_VERSION); \
	fi
