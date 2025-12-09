import 'package:flutter/material.dart';
import 'package:vibes_common/src/model/models.dart';

class SectionItem {
  SectionItem({
    required this.id,
    required this.title,
    required this.description,
    required String thumbnail,
    required this.type,
    required this.heroTag,
    this.parentSection,
    this.parentId,
    this.tags = const [],
    this.backgroundColor = Colors.transparent,
    this.premium,
  }) : thumbnail = _fixUrl(thumbnail);

  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final SectionType type;
  final List<String> tags;
  final Color backgroundColor;
  final String heroTag;
  final Section? parentSection;
  final String? parentId;
  final bool? premium;

  SectionItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        thumbnail = json['thumbnail'],
        type = SectionType.values
            .firstWhere((element) => element.toString() == json['type']),
        tags = (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
        backgroundColor = Colors.white,
        heroTag = json['heroTag'],
        parentSection = null,
        parentId = null,
        premium = json['premium'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'thumbnail': thumbnail,
        'type': type.toString(),
        'tags': tags,
        'backgroundColor': backgroundColor.toString(),
        'heroTag': heroTag,
        'premium': premium,
      };

  static const String _baseUrl = "https://vo-dev.6thsolution.tech";

  static String _fixUrl(String thumbnail) {
    if (thumbnail.startsWith("/media")) {
      return _baseUrl + thumbnail;
    } else if (thumbnail.startsWith("http://")) {
      return thumbnail.replaceFirst("http://", "https://");
    }
    return thumbnail;
  }
}

enum SectionType { story, character, category, video, channel, videoCreator }
