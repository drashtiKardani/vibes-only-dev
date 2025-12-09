from flask import Flask
from flask import render_template
from flask import send_from_directory
from flask import request
import requests
import json

app = Flask(__name__)

@app.route('/')
def render_index_page():
    return render_template('/index.html')

@app.route('/.well-known/<path:filename>')
def return_app_site_association_file(filename):
    return send_from_directory('.well-known', filename, mimetype='application/json')

FLUTTER_WEB_APP = 'templates'

@app.route('/<path:name>')
def return_flutter_doc(name):
    datalist = str(name).split('/')

    if datalist[0] == 'story':
        storyId = request.args.get('id')
        response = requests.get(f'https://app.vibesonly.com/api/v1/stories/stories/{storyId}/')
        json_response = json.loads(response.text)
        title = json_response.get('title')
        description = json_response.get('description')
        imageUrl = json_response.get('image_showcase_small')
        return render_template('/index.html', og_title=title, og_image=imageUrl, og_url=request.url, og_description=description)

    if datalist[0] == 'video':
        videoId = request.args.get('id')
        response = requests.get(f'https://app.vibesonly.com/api/v1/videos/videos/{videoId}/share_page/')
        json_response = json.loads(response.text)
        title = json_response.get('title')
        description = json_response.get('caption')
        imageUrl = json_response.get('thumbnail')
        return render_template('/index.html', og_title=title, og_image=imageUrl, og_url=request.url, og_description=description)

    DIR_NAME = FLUTTER_WEB_APP

    if len(datalist) > 1:
        for i in range(0, len(datalist) - 1):
            DIR_NAME += '/' + datalist[i]

    return send_from_directory(DIR_NAME, datalist[-1])