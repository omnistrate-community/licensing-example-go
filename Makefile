PROJECT_NAME=licensing-example-go
DOCKER_PLATFORM?=linux/amd64
CGO_ENABLED=0
SERVICE_NAME=licensing-example
SERVICE_PLAN=licensing-example

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
	omnistrate-ctl build -f compose.yaml --product-name ${SERVICE_NAME} --release-as-preferred

.PHONY: create
create:
	omnistrate-ctl instance create --environment Dev --cloud-provider aws --region us-east-2 --plan ${SERVICE_PLAN} --service ${SERVICE_NAME} --resource web 


.PHONY: list
list:
	@omnistrate-ctl instance list --filter=service:${SERVICE_NAME},plan:${SERVICE_PLAN} --output json

.PHONY: delete-all
delete-all:
	@echo "Deleting all instances..."
	@for id in $$(omnistrate-ctl instance list --filter=service:${SERVICE_NAME},plan:${SERVICE_PLAN} --output json | jq -r '.[].instance_id'); do \
		echo "Deleting instance: $$id"; \
		omnistrate-ctl instance delete $$id; \
	done

.PHONY: destroy
destroy: delete-all-wait
	@echo "Destroying service: ${SERVICE_NAME}..."
	@omnistrate-ctl service delete ${SERVICE_NAME}

.PHONY: delete-all-wait
delete-all-wait:
	@echo "Deleting all instances and waiting for completion..."
	@instances_to_delete=$$(omnistrate-ctl instance list --filter=service:${SERVICE_NAME},plan:${SERVICE_PLAN} --output json | jq -r '.[].instance_id'); \
	if [ -n "$$instances_to_delete" ]; then \
		for id in $$instances_to_delete; do \
			echo "Deleting instance: $$id"; \
			omnistrate-ctl instance delete $$id; \
		done; \
		echo "Waiting for instances to be deleted..."; \
		while true; do \
			remaining=$$(omnistrate-ctl instance list --filter=service:${SERVICE_NAME},plan:${SERVICE_PLAN} --output json | jq -r '.[].instance_id'); \
			if [ -z "$$remaining" ]; then \
				echo "All instances deleted successfully"; \
				break; \
			fi; \
			echo "Still waiting for deletion to complete..."; \
			sleep 10; \
		done; \
	else \
		echo "No instances found to delete"; \
	fi