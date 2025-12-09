import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'extra_settings.dart';

class VibesAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  static late VibesAudioHandler instance;

  static Future<void> init() async {
    instance = await AudioService.init(
      builder: () =>
          VibesAudioHandler(player: AudioPlayer(), defaultAlbum: 'Vibes Only'),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'vibes_only.channel.audio',
        androidNotificationChannelName: 'Vibes Only',
        androidNotificationIcon: 'mipmap/launcher_icon',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    instance.playbackState.listen((state) {
      if (state.processingState == AudioProcessingState.completed ||
          state.processingState == AudioProcessingState.error) {
        instance.stop();
      }
    });
  }

  final AudioPlayer _player;
  final String defaultAlbum;
  final String defaultClass;

  VibesAudioHandler({
    required AudioPlayer player,
    String? defaultAlbum,
    String? defaultClass,
  }) : _player = player,
       defaultAlbum = defaultAlbum ?? '',
       defaultClass = defaultClass ?? '' {
    // This beautiful construct is copied from the audio_service example.
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await _prepareMediaItem(
      extras ?? {},
      uri,
      MediaItem(id: uri.toString(), album: defaultAlbum, title: defaultClass),
    );
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await prepareFromUri(uri, extras);
    await _player.play();
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await _prepareMediaItem(
      mediaItem.extras ?? {},
      Uri.parse(mediaItem.id),
      mediaItem,
    );
    await _player.play();
  }

  @override
  Future<void> prepareFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    if (_isPlaying(mediaId, extras)) return;

    // If the media ID is already being played, don't query it.
    // We may still want to update the player source, for example if
    // we are switching to play from an offline file.
    final item = mediaItem.value ?? await getMediaItem(mediaId);

    // If we can't get media meta data, just play it like a regular Uri.
    if (item == null) {
      await prepareFromUri(Uri.parse(mediaId), extras);
      return;
    }

    await _prepareMediaItem(extras ?? {}, Uri.parse(mediaId), item);
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    await prepareFromMediaId(mediaId, extras);
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  Duration currentPosition() {
    return _player.position;
  }

  @override
  Future<void> seek(position) async {
    await _player.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> _prepareMediaItem(
    Map<String, dynamic> extras,
    Uri defaultUri,
    MediaItem item,
  ) async {
    if (_isPlaying(defaultUri.toString(), extras)) return;

    final parsedExtras = ExtraSettings.fromExtras(
      extras,
      defaultUri: defaultUri,
    );

    item = item.copyWith(extras: extras);

    mediaItem.add(item);

    final duration = await _player.setAudioSource(
      AudioSource.uri(parsedExtras.finalUri),
      initialPosition: parsedExtras.start,
    );

    if (duration != null && duration != item.duration) {
      mediaItem.add(item.copyWith(duration: duration));
    }

    return;
  }

  bool _isPlaying(String id, Map<String, dynamic>? extras) {
    if (mediaItem.value == null) {
      return false;
    }

    final currentExtras = ExtraSettings.fromExtras(
      mediaItem.value!.extras,
      defaultUri: Uri.parse(mediaItem.value!.id),
    );
    final newExtras = ExtraSettings.fromExtras(
      extras,
      defaultUri: Uri.parse(id),
    );

    return currentExtras.finalUri == newExtras.finalUri;
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
