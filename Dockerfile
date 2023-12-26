# Build stage
FROM golang:1.21 AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o apiserver .

# Runtime stage
FROM alpine:3.19

COPY --from=builder ["/build/apiserver", "/"]

# Uses alpine's package manager to install zstd
RUN apk add zstd && zstd --version

ENTRYPOINT ["/apiserver"]