import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vibes_common/src/model/models.dart';

void main() {
  var j = """
 {
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "is_visible": false,
            "title": "Current channel",
            "image": "http://vo-dev.6thsolution.tech/media/videos/channel/image/Rectangle_64.png",
            "description": "",
            "videos_count": 2,
            "video_list": [
                {
                    "id": 1,
                    "is_visible": false,
                    "title": "First Video",
                    "index": 0,
                    "file": "http://vo-dev.6thsolution.tech/media/videos/video/file/video_2021-09-01_18-03-53.mp4",
                    "short_start": null,
                    "short_end": null,
                    "channel": 1,
                    "style": "SHOWCASE_MEDIUM",
                    "creator": "328cf7d0-d6fa-4aba-8b77-ff9aada7cf2f",
                    "editor": null,
                    "publisher": null,
                    "date_created": "2021-09-30T08:23:21.274483Z",
                    "date_edited": "2021-09-30T08:23:21.274571Z",
                    "date_published": null
                },
                {
                    "id": 2,
                    "is_visible": false,
                    "title": "Second Video",
                    "index": 1,
                    "file": "http://vo-dev.6thsolution.tech/media/videos/video/file/video_2021-09-01_18-03-50.mp4",
                    "short_start": null,
                    "short_end": null,
                    "channel": 1,
                    "style": "SHOWCASE_MEDIUM",
                    "creator": "328cf7d0-d6fa-4aba-8b77-ff9aada7cf2f",
                    "editor": null,
                    "publisher": null,
                    "date_created": "2021-09-30T08:24:19.816763Z",
                    "date_edited": "2021-09-30T08:24:33.717414Z",
                    "date_published": null
                }
            ],
            "creator": "328cf7d0-d6fa-4aba-8b77-ff9aada7cf2f",
            "editor": null,
            "publisher": null,
            "date_created": "2021-09-30T08:22:10.177477Z",
            "date_edited": "2021-09-30T08:22:10.177533Z",
            "date_published": null
        }
    ]
}
  """;

  final AllChannel home = AllChannel.fromJson(json.decode(j));
  debugPrint(jsonEncode(home.toJson()));
}
