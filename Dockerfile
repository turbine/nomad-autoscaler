# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# This Dockerfile contains multiple targets.
# Use 'docker build --target=<name> .' to build one.

# ===================================
#   Non-release images.
# ===================================

# devbuild compiles the binary
# -----------------------------------
FROM golang:1.21 AS devbuild

# Disable CGO to make sure we build static binaries
ENV CGO_ENABLED=0

# Escape the GOPATH
WORKDIR /build
COPY . ./
RUN go build -o nomad-autoscaler .

# dev runs the binary from devbuild
# -----------------------------------
FROM alpine:3.15 AS dev

COPY --from=devbuild /build/nomad-autoscaler /bin/
COPY ./scripts/docker-entrypoint.sh /

# Create a non-root user to run the software.
ARG PRODUCT_NAME=nomad-autoscaler
RUN addgroup $PRODUCT_NAME && \
    adduser -S -G $PRODUCT_NAME $PRODUCT_NAME

USER $PRODUCT_NAME
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["help"]
