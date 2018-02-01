FROM golang:1.9

# Install go
RUN go get -u github.com/derekparker/delve/cmd/dlv && \
	go get github.com/Masterminds/glide && \
	go get -u github.com/golang/dep/cmd/dep

# Install Kubernetes
RUN apt-get update && apt-get install -y lsb-release vim sudo

RUN curl -sSL https://get.kismatic.com/kubernetes/master.sh | sh

# Extra tooling
RUN apt-get install -y vim telnet jq

COPY docker/dev/sudoers /etc/sudoers

COPY docker/dev/Makefile /go/Makefile

COPY docker/dev/entrypoint.sh /entrypoint.sh

COPY scripts/cluster.sh /bin/cluster.sh

ENTRYPOINT ["/entrypoint.sh"]
