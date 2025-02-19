PROJECT_NAME=licensing-example-go
DOCKER_PLATFORM?=linux/amd64
CGO_ENABLED=0

# Load variables from .env if it exists
ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

# Go
.PHONY: all
all: tidy build

.PHONY: tidy
tidy:
	echo "Tidy dependency modules for service"
	go mod tidy

.PHONY: build
build:
	echo "Building go binaries for service"
	go build -o ${PROJECT_NAME} ./cmd/${PROJECT_NAME}/main.go

# Docker 
.PHONY: docker-build 
docker-build:
	docker build --platform=${DOCKER_PLATFORM} -f ./build/Dockerfile -t ${PROJECT_NAME}:latest .
.PHONY: docker-build-arm64
docker-build-arm64:
	docker build --platform=linux/arm64 -f ./build/Dockerfile -t ${PROJECT_NAME}:latest .

.PHONY: docker-run
docker-run:
	echo "Starting service"
	docker run --platform=${DOCKER_PLATFORM} -t ${PROJECT_NAME}:latest --name ${PROJECT_NAME}
.PHONY: docker-run-arm64
docker-run-arm64:
	echo "Starting service"
	docker run --platform=linux/arm64 -t ${PROJECT_NAME}:latest --name ${PROJECT_NAME}

# Omnistrate
.PHONY: install-ctl
install-ctl:
	@brew install omnistrate/tap/omnistrate-ctl

.PHONY: upgrade-ctl
upgrade-ctl:
	@brew upgrade omnistrate/tap/omnistrate-ctl
	
.PHONY: login
login:
	cat ./.omnistrate.password | omnistrate-ctl login --email $(OMNISTRATE_EMAIL) --password-stdin

.PHONY: release
release:
	omnistrate-ctl build -f compose.yaml --name licensing-compose --release-as-preferred

.PHONY: create
create:
	omnistrate-ctl instance create --environment Dev --cloud-provider aws --region ap-south-1 --plan licensing-compose --service licensing-compose --resource postgres 