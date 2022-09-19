IMAGE_REPOSITORY := ${IMAGE_REPOSITORY}
TAG := ${TAG}
BUILD_TARGET := production

up-dev:
	@ docker-compose --project-name rail --env-file deploy/dev/.env -f deploy/dev/docker-compose.yaml up \
		-d --build --force-recreate --remove-orphans

down-dev:
	@ docker-compose --project-name rail -f deploy/dev/docker-compose.yaml down

.PHONY: up-dev down-dev

up-prod:
	@ docker-compose --project-name rail --env-file deploy/prod/.env -f deploy/prod/docker-compose.yaml up \
		-d --build --force-recreate --remove-orphans

down-prod:
	@ docker-compose --project-name rail -f deploy/prod/docker-compose.yaml down

.PHONY: up-prod down-prod

build:
	@ docker build -t ${IMAGE_REPOSITORY}:${TAG} --target ${BUILD_TARGET} -f Dockerfile . 

push:
	@ docker push ${IMAGE_REPOSITORY}:${TAG}

local:
	@ bin/rails s -b 0.0.0.0 -p ${PORT} 

