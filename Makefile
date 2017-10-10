.PHONY: development test

development:
	docker build \
	  --tag ready-responder/app-dev \
	  --file Dockerfile.development .

test: development
	docker run \
	  --rm \
	  --interactive \
	  --tty \
	  --volume $(PWD):/app \
	  ready-responder/app-dev bin/docker-test
