/// Abstracts track, artist, album and playlist for purpose of displaying.
abstract class SpotifyObject {
  String? get imageUrl;

  String get title;

  String? get subtitle;
}
