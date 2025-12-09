
import '../../service/logger.dart';

class StoryTranscript {
  /// Regex for parsing a SubRip (srt) string.
  /// Transcripts of stories are in this format.
  /// Copied from https://stackoverflow.com/a/30882649/2511775
  static final _srtRegex =
      RegExp(r'(?<order>\d+)\n(?<start>[\d:,]+)\s+-{2}>\s+(?<end>[\d:,]+)\n(?<text>[\s\S]*?(?=\n{2}|$))');

  late final Iterable<StoryTranscriptLine> lines;

  StoryTranscript(String transcriptString) {
    final splitTranscript = _srtRegex.allMatches(transcriptString);
    lines = splitTranscript
        .map((e) {
          final order = int.tryParse(e.namedGroup('order') ?? '');
          final start = _tryParseSrtTime(e.namedGroup('start') ?? '');
          final end = _tryParseSrtTime(e.namedGroup('end') ?? '');
          final text = e.namedGroup('text');
          if (order == null || start == null || end == null || text == null) {
            Logger.storyTranscript.e('Error parsing ${e.input}');
            return null;
          } else {
            return StoryTranscriptLine(order, start, end, text);
          }
        })
        .where((e) => e != null)
        .map((e) => e!);
  }

  static Duration? _tryParseSrtTime(String time) {
    List<String> splitTime = time.split(',');
    if (splitTime.length != 2) return null;

    List<String> hms = splitTime[0].split(':');
    if (hms.length != 3) return null;

    final h = int.tryParse(hms[0]);
    final m = int.tryParse(hms[1]);
    final s = int.tryParse(hms[2]);
    final ms = int.tryParse(splitTime[1]);

    if (h == null || m == null || s == null || ms == null) return null;

    return Duration(hours: h, minutes: m, seconds: s, milliseconds: ms);
  }
}

/// Represents each segment or line of timestamped text in a [StoryTranscript] (SubRip format)
class StoryTranscriptLine {
  final int order;
  final Duration start;
  final Duration end;
  final String text;

  StoryTranscriptLine(this.order, this.start, this.end, this.text);

  bool isBeingReadAt(Duration? time) {
    if (time == null) return false;

    return start <= time && time < end;
  }
}
