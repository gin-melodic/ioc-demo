GO ?= $(shell command -v go 2> /dev/null)
GOPATH ?= $(shell go env GOPATH)
GO_BUILD_FLAGS ?=
BINARY_NAME ?= "ioc-script"
LIPO ?= $(shell command -v lipo 2> /dev/null)

.PHONY: dist
dist:
	rm -rf dist
	mkdir -p dist
	@echo Build binary for darwin-amd64
	GOOS=darwin GOARCH=amd64 $(GO) build -o dist/$(BINARY_NAME)-darwin-amd64
	@echo Build binary for darwin-arm64
	GOOS=darwin GOARCH=arm64 $(GO) build -o dist/$(BINARY_NAME)-darwin-arm64
	@echo Combine binaries into universal binary
	$(LIPO) -create dist/$(BINARY_NAME)-darwin-amd64 dist/$(BINARY_NAME)-darwin-arm64 -output dist/$(BINARY_NAME)
	@echo Clen jobs
	rm -rf dist/$(BINARY_NAME)-darwin-amd64 dist/$(BINARY_NAME)-darwin-arm64