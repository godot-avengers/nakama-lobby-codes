#include .env

PROJECTNAME="Nakama Lobby Codes"

# Go related variables.
GOBASE=$(shell pwd)
GOBIN=$(GOBASE)/bin
GOFILES=$(wildcard *.go)

# Redirect error output to a file, so we can show it in development mode.
STDERR=/tmp/.$(PROJECTNAME)-stderr.txt

# PID file will store the server process id when it's running on development mode
PID=/tmp/.$(PROJECTNAME)-api-server.pid

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

go-compile: go-clean go-get go-build

go-build:
	@echo "  >  Building binary..."
	@go build -trimpath -buildmode=plugin -o $(GOBIN)/lobby-codes.so $(GOFILES)

go-generate:
	@echo "  >  Generating dependency files..."
	@go generate $(generate)

go-get:
	@echo "  >  Checking if there is any missing dependencies..."
	@go get $(get)

go-install:
	@go install $(GOFILES)

go-clean:
	@echo "  >  Cleaning build cache"
	@go clean

go-test:
	@echo "  >  Running tests..."
	@go test

go-run:
	@echo "  >  Running ${PROJECTNAME}"
	@-(cd $(GOBIN); ./$(PROJECTNAME))

nakama-common:
	@echo "  >  Updating common library..."
	@go get -u "github.com/heroiclabs/nakama-common/runtime"


## install: downloads and installs dependencies
install: nakama-common go-get

## clean: Runs go clean
clean: go-clean

## compile: cleans project, installs dependencies, and builds project
compile:
	@-touch $(STDERR)
	@-rm $(STDERR)
	@-$(MAKE) -s go-compile 2> $(STDERR)
	@cat $(STDERR) | sed -e '1s/.*/\nError:\n/'  | sed 's/make\[.*/ /' | sed "/^/s/^/     /" 1>&2

## watch: Builds on changes
watch:
	@yolo -i . -e vendor -e bin -c $(run)

## build: Runs go build
build: go-build

run: go-compile go-run

## test: Run unit tests
test: go-test

## help: Displays help text for make commands
.DEFAULT_GOAL := help
all: help
help: Makefile
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'