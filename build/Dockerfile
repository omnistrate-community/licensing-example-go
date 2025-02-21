# syntax=docker/dockerfile:1

## Build
FROM golang:1.24-alpine AS builder

RUN apk update && apk add git

WORKDIR /go/src/licensing-example-go
COPY ./ .

ARG TARGETOS
ARG TARGETARCH
ENV CGO_ENABLED=0

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /go/bin/licensing-example-go  ./cmd/licensing-example-go/main.go

## Deploy
FROM alpine:latest AS app

RUN apk update
# RUN apk add --no-cache ca-certificates -- optional as required public certs are included in sdk

COPY --from=builder /go/bin/licensing-example-go /bin/licensing-example-go

EXPOSE 8080
EXPOSE 8443

# Create a group (2000) and user (1000)
RUN addgroup -S servicegroup -g 2000 && adduser -S serviceuser -G servicegroup -u 1000

RUN echo Starting the Go service...
USER serviceuser:servicegroup
ENTRYPOINT [ "/bin/licensing-example-go" ]