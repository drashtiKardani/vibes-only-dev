class ShortVideo {
  final int id;
  final String url;
  final String? title;
  final String? caption;
  final String? thumbnail;

  const ShortVideo({
    required this.id,
    required this.url,
    required this.title,
    required this.caption,
    required this.thumbnail,
  });

  factory ShortVideo.fromJson(Map<String, dynamic> json) {
    return ShortVideo(
      id: json['id'],
      url: json['short_video'],
      title: json['title'],
      caption: json['caption'],
      thumbnail: json['thumbnail'],
    );
  }
}
