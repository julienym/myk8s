FROM golang:1.17-alpine

RUN apk add build-base
RUN apk add git

RUN git clone https://github.com/openshift/installer.git
 
RUN cd installer && hack/build.sh

FROM alpine:latest
COPY --from=0 /go/installer/bin/openshift-install /bin/
