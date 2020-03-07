build_images:
	docker build -t lucastercas/moodle:latest .
	docker tag lucastercas/moodle:latest lucastercas/moodle:38
	docker build -t --build-args MOODLE_BRANCH MOODLE_37_STABLE lucastercas/moodle:37 .

docker_push:
	docker push lucastercas/moodle:latest
	docker push lucastercas/moodle:38
	docker push lucastercas/moodle:37
