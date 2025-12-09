def transcribe_create_job(
    client,
    transcription_job_name,
    file_url,
    language_code='en-US',
    media_format='mp3',
):
    return client.start_transcription_job(
        TranscriptionJobName=transcription_job_name,
        LanguageCode=language_code,
        Media={
            'MediaFileUri': file_url,
        },
        MediaFormat=media_format,
        Subtitles={'Formats': ['srt']},
    )['TranscriptionJob']


def transcribe_get_job(client, transcription_job_name):
    return client.get_transcription_job(TranscriptionJobName=transcription_job_name)[
        'TranscriptionJob'
    ]


def transcribe_list_job(client):
    return client.list_transcription_jobs(MaxResults=10)
