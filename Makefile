build-images-no-cache:
	docker build -t lucastercas/moodle:38 . --no-cache
	docker tag lucastercas/moodle:38 lucastercas/moodle:latest
	docker build --build-arg MOODLE_BRANCH=MOODLE_37_STABLE -t lucastercas/moodle:37 . --no-cache

build-images:
	docker build -t lucastercas/moodle:38 .
	docker tag lucastercas/moodle:38 lucastercas/moodle:latest
	docker build --build-arg MOODLE_BRANCH=MOODLE_37_STABLE -t lucastercas/moodle:37 .

push-images:
	docker push lucastercas/moodle:latest
	docker push lucastercas/moodle:38
	docker push lucastercas/moodle:37

build-push-images: build-images push-images
