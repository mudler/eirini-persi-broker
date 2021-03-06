ARG BASE_IMAGE=opensuse/leap

FROM golang:1.12 as build
ARG USER="SUSE CFCIBot"
ARG EMAIL=ci-ci-bot@suse.de
ARG DEBUG_TOOLS=false
ARG KUBECTL_VERSION=v1.18.2
ARG KUBECTL_ARCH=linux-amd64
ARG KUBECTL_CHECKSUM=ed36f49e19d8e0a98add7f10f981feda8e59d32a8cb41a3ac6abdfb2491b3b5b3b6e0b00087525aa8473ed07c0e8a171ad43f311ab041dcc40f72b36fa78af95
ADD . /eirini-persi-broker
WORKDIR /eirini-persi-broker
RUN mkdir binaries
RUN git config --global user.name ${USER}
RUN git config --global user.email ${EMAIL}
RUN if [ "$DEBUG_TOOLS" = "true" ] ; then \
    wget -O kubectl.tar.gz https://dl.k8s.io/$KUBECTL_VERSION/kubernetes-client-$KUBECTL_ARCH.tar.gz && \
    echo "$KUBECTL_CHECKSUM kubectl.tar.gz" | sha512sum --check --status && \
    tar xvf kubectl.tar.gz -C / && \
    cp -f /kubernetes/client/bin/kubectl /eirini-persi-broker/binaries/; fi
RUN GO111MODULE=on go mod vendor
RUN CGO_ENABLED=0 go build -o "binaries/eirini-persi-broker" ./cmd/broker/

FROM $BASE_IMAGE
COPY --from=build /eirini-persi-broker/binaries/* /bin/
ENTRYPOINT ["/bin/eirini-persi-broker"]
