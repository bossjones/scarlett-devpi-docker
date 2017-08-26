project := scarlett-devpi-docker
projects := scarlett-devpi-docker
username := bossjones
container_name := scarlett-devpi-docker

CONTAINER_VERSION  = $(shell \cat ./VERSION | awk '{print $1}')
GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)

BOSSJONES_PROJECT := devpi
DOCKER_DEVPI_SERVER_VERSION := 4.1.1
DOCKER_DEVPI_CLIENT_VERSION := 2.7.0
DOCKER_DEVPI_WEB_VERSION := 3.1.1

# NOTE: DEFAULT_GOAL
# source: (GNU Make - Other Special Variables) https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
# Sets the default goal to be used if no
# targets were specified on the command
# line (see Arguments to Specify the Goals).
# The .DEFAULT_GOAL variable allows you to
# discover the current default goal,
# restart the default goal selection
# algorithm by clearing its value,
# or to explicitly set the default goal.
# The following example illustrates these cases:
.DEFAULT_GOAL := help

# http://misc.flogisoft.com/bash/tip_colors_and_formatting

RED=\033[0;31m
GREEN=\033[0;32m
ORNG=\033[38;5;214m
BLUE=\033[38;5;81m
PURP=\033[38;5;129m
GRAY=\033[38;5;246m
NC=\033[0m

export RED
export GREEN
export NC
export ORNG
export BLUE
export PURP
export GRAY

# NOTE: Eg. git symbolic-ref --short HEAD => feature-push-dockerhub
TAG ?= $(CONTAINER_VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

#################################################################################################
# A phony target is one that is not really the name of a file;
# rather it is just a name for a recipe to be executed when you make an explicit request.
# There are two reasons to use a phony target:
# to avoid a conflict with a file of the same name, and to improve performance.

# If you write a rule whose recipe will not create the target file,
# the recipe will be executed every time the target comes up for remaking.
# Here is an example:
# .PHONY: ci test build push-docker-hub
# .PHONY: test docker-compose-build docker-compose-up docker-compose-up-build docker-compose-down docker-version docker-exec docker-exec-master rake_deps rake_deps_build rake_deps_build_push docker_build_latest docker_build_compile_jhbuild

default: help
#################################################################################################

# NOTE: Purpose of Makefiles
# By default, Makefile targets are "file targets" -
# they are used to build files from other files.
# Make assumes its target is a file,
# and this makes writing Makefiles relatively easy:

# verify that certain variables have been defined off the bat
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))

list_allowed_args := name

.PHONY: help
help:
	@echo "help"

.PHONY: list
list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

.PHONY: test
test:
	@docker-compose -f docker-compose.yml up --build

.PHONY: run
run:
	set -x ;\
	mkdir -p data; \
	docker run \
		-d \
		--restart always \
		--name devpi \
		--env-file .env \
        -e CONTAINER_VERSION=$(CONTAINER_VERSION) \
        -e GIT_BRANCH=$(GIT_BRANCH) \
        -e GIT_SHA=$(GIT_SHA) \
        -e BUILD_DATE=$(BUILD_DATE) \
        -e DEVPI_PASSWORD='password' \
		-v $$(pwd)/data:/data \
		-p 3141:3141 \
        $(username)/$(container_name):latest

.PHONY: build
build:
	set -x ;\
	mkdir -p data; \
	docker build \
		--file=Dockerfile \
        --build-arg CONTAINER_VERSION=$(CONTAINER_VERSION) \
        --build-arg GIT_BRANCH=$(GIT_BRANCH) \
        --build-arg GIT_SHA=$(GIT_SHA) \
        --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg ARG_DEVPI_CLIENT_VERSION=$(DOCKER_DEVPI_CLIENT_VERSION) \
		--build-arg ARG_DEVPI_SERVER_VERSION=$(DOCKER_DEVPI_SERVER_VERSION) \
		--build-arg ARG_DEVPI_WEB_VERSION=$(DOCKER_DEVPI_WEB_VERSION) \
	    --tag $(username)/$(container_name):$(GIT_SHA) . ; \
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):$(TAG) ; \
	docker tag $(username)/$(container_name):$(GIT_SHA) $(username)/$(container_name):latest

.PHONY: build_and_push
build_and_push: build
	docker push $(username)/$(container_name):$(TAG)
	docker push $(username)/$(container_name):latest
