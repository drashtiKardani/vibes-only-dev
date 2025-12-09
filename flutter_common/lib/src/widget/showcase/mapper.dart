import 'package:flutter/material.dart';
import 'package:vibes_common/src/model/models.dart';

import 'model.dart';

extension CategoryExt on Category {
  SectionItem toSectionItem(String scope) {
    return SectionItem(
      id: id.toString(),
      title: title,
      description: '',
      thumbnail: image ?? '',
      type: SectionType.category,
      heroTag: scope + id.toString(),
    );
  }
}

extension StoryExt on Story {
  SectionItem toSectionItem(
    String scope,
    Style style, {
    Section? parentSection,
  }) {
    return SectionItem(
      id: id.toString(),
      title: title,
      description: description,
      thumbnail: thumbnail(style),
      type: SectionType.story,
      tags: categories.map((e) => e.title).toList(),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      heroTag: scope + id.toString(),
      parentSection: parentSection,
      premium: paid,
    );
  }
}

extension VideoExt on Video {
  SectionItem toSectionItem(String scope, Style style, String parentId) {
    return SectionItem(
      id: id.toString(),
      title: title,
      description: '',
      // TODO use video preview (currently it's null)
      thumbnail: thumbnail ?? '',
      type: SectionType.video,
      // TODO get from API
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      heroTag: scope + id.toString(),
      parentId: parentId,
      premium: paid,
    );
  }
}
