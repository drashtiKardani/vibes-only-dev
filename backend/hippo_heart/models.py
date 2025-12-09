from django.db import models
from django_fsm import FSMField, ConcurrentTransitionMixin


class PublisherMixin(models.Model, ConcurrentTransitionMixin):
    class Meta:
        abstract = True

    class State(models.TextChoices):
        CREATED = 'created'
        PROCESSED = 'processed'
        PROCESSING = 'processing'
        PROCESS_FAILED = 'process_failed'
        APPROVED = 'approved'
        PUBLISHED = 'published'

    state = FSMField(default=State.CREATED, choices=State.choices)
    date_created = models.DateTimeField(auto_now_add=True)
