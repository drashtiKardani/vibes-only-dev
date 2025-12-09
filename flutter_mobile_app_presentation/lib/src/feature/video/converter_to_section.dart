import 'package:vibes_common/vibes.dart';

extension TypeConverter on Channel {
  Section asSection() {
    return Section(
      id: id,
      isVisible: true,
      title: title,
      contentType: "video",
      style: Style.showcaseMedium,
      videos: videoList,
    );
  }
}

extension ChannelListAsSection on List<Channel> {
  Section asSection() {
    return Section(
      id: 0,
      isVisible: true,
      title: 'Channels',
      contentType: 'channel',
      style: Style.showcaseMedium,
      channels: this,
    );
  }
}

extension VideoCreatorListAsSection on List<VideoCreator> {
  Section asSection() {
    return Section(
      id: 0,
      isVisible: true,
      title: 'Video Creators',
      contentType: 'video-creator',
      style: Style.avatar,
      videoCreators: this,
    );
  }
}

extension VideoListAsSection on List<Video> {
  Section asSection() {
    return Section(
      id: 0,
      isVisible: true,
      title: 'Videos',
      contentType: 'video',
      style: Style.showcaseMedium,
      videos: this,
    );
  }
}
