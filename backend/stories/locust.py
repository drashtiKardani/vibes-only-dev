from locust import HttpUser, task, between, FastHttpUser


class UserActions(FastHttpUser):
    # wait_time = between(1, 5)
    min_wait = 0
    max_wait = 0

    @task
    def check_stories_list(self):
        self.client.get("http://localhost/api/v1/stories/stories/?state=published")

    @task
    def check_videos_list(self):
        self.client.get("http://localhost/api/v1/videos/videos/?state=published")
