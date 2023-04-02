USER=<docker-hub-username>
IMAGE=my-jenkins-agent-dood:latest
DOCKER_GID=$(shell getent group docker | cut -d: -f3)
SHELL=/bin/bash

.PHONY: build push

default: build

build:
	clear
	@echo El GID del grupo \"docker\" en el Docker Hosts es: $(DOCKER_GID)
	@echo
	@echo "Presiona cualquier tecla para continuar"
	@read -n 1 -r
	clear
	docker build --build-arg DOCKER_GID=$(DOCKER_GID) -t $(USER)/$(IMAGE) .

debug:
	docker run --rm -it --name myagent --privileged -v /var/run/docker.sock:/var/run/docker.sock $(USER)/$(IMAGE) bash

push:
	docker login
	docker push $(USER)/$(IMAGE)
