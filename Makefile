build_images:
	docker build -t lucastercas/moodle:latest .
	docker tag lucastercas/moodle:latest lucastercas/moodle:38
	docker build --build-arg MOODLE_BRANCH=MOODLE_37_STABLE -t lucastercas/moodle:37 .

push_images:
	docker push lucastercas/moodle:latest
	docker push lucastercas/moodle:38
	docker push lucastercas/moodle:37

build_push_image: build_images push_images
