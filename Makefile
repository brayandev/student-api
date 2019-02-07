.PHONY: usage build build-authentication-api test get-linter lint

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

GO := go
GO_LINTER := golint
GO_FLAGS ?=
BUILDOS ?= $(shell go env GOHOSTOS)
BUILDARCH ?= amd64
DOCKER_COMPOSE ?= docker-compose
ECHOFLAGS ?=
ROOT_DIR := $(realpath .)

CREATE_LOCAL_ENV := $(shell if [ ! -f "$(ROOT_DIR)/local.env" ]; then cp $(ROOT_DIR)/local.env.sample $(ROOT_DIR)/local.env; fi)
LOCAL_VARIABLES ?= $(shell while read -r line; do printf '%s' "$$line" | sed 's/ /\\ /g' | awk '{print}'; done < $(ROOT_DIR)/local.env)

PKGS = $(shell $(GO) list ./...)

ENVFLAGS ?= CGO_ENABLED=0
BUILDFLAGS ?= -a -installsuffix cgo $(GOFLAGS)
BUILDENV ?= GOOS=$(BUILDOS) GOARCH=$(BUILDARCH)

BIN_API_AUTHENTICATION := api-authentication

usage: Makefile
	@echo $(ECHOFLAGS) "to use make call:"
	@echo $(ECHOFLAGS) "make <action>"
	@echo $(ECHOFLAGS) ""
	@echo $(ECHOFLAGS) "list of available actions:"
	@sed -n 's/^##//p' $< | column -t -s ':' | sed -e 's/^/ /'

## build: build all.
build: build-authentication-api

## build-authentication-api: build authentication api.
build-authentication-api: 
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Building binary... (linux/$(BUILDARCH)/$(BIN_API_AUTHENTICATION))...$(NO_COLOR)"
	@echo $(ECHOFLAGS) $(ENVFLAGS) GOOS=linux GOARCH=$(BUILDARCH) $(GO) build $(BUILDFLAGS) -o bin/linux/amd64/$(BIN_API_AUTHENTICATION) ./cmd/rename
	@$(ENVFLAGS) GOOS=linux GOARCH=$(BUILDARCH) $(GO) build $(BUILDFLAGS) -o bin/linux_amd64/$(BIN_API_AUTHENTICATION) ./cmd/rename

## test: run unit tests
test: 
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running tests with envs:[$(LOCAL_VARIABLES)]...$(NO_COLOR)"
	@$(LOCAL_VARIABLES) $(ENVFLAGS) $(GO) test $(GOFLAGS) $(PKGS) -cover

## get-linter: install linter
get-linter:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Install linter...$(NO_COLOR)"
	@go get -v -u golang.org/x/lint/golint

## lint: lint package
lint: get-linter
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running linter...$(NO_COLOR)"
	@$(GO_LINTER) -set_exit_status $(PKGS)
