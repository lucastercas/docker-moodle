LATEST_VERSION=v3.8.3

build-latest:
	docker build --build-arg MOODLE_VERSION=$(LATEST_VERSION) -t lucastercas/moodle:$(LATEST_VERSION) .
	docker tag lucastercas/moodle:$(LATEST_VERSION) lucastercas/moodle:latest

push-latest:
	docker push lucastercas/moodle:$(LATEST_VERSION)
	docker push lucastercas/moodle:latest

build-push-latest: build-latest push-latest


# Ex: make build-image VERSION=v3.7.6
build-push-version:
	docker build --build-arg MOODLE_VERSION=$(VERSION) -t lucastercas/moodle:$(VERSION) .
	docker push lucastercas/moodle:$(VERSION)

