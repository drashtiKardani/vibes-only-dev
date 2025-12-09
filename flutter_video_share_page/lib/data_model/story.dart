import 'category.dart';

class Story {
  final int id;
  final String title;
  final String description;
  final String? imageFull;
  final int? audioLengthSeconds;
  final List<Category> categories;
  final String audioPreview;

  Story(
    this.id,
    this.title,
    this.description,
    this.imageFull,
    this.audioLengthSeconds,
    this.categories,
    this.audioPreview,
  );

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      json['id'],
      json['title'],
      json['description'],
      json['image_full'],
      json['audio_length_seconds'],
      (json['categories'] as List<dynamic>).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList(),
      json['audio_preview'],
    );
  }
}
