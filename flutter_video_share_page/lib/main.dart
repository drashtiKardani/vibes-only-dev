import 'package:flutter/material.dart';
import 'package:flutter_video_share_page/pages/default_page.dart';
import 'package:flutter_video_share_page/pages/story_page.dart';
import 'package:flutter_video_share_page/pages/video_page.dart';
import 'package:flutter_video_share_page/theme.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy(); // remove # from urls
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share your vibe',
      theme: getAppTheme(),
      // This makes the legacy routing possible (<baseurl>?vid=*)
      initialRoute: '${Uri.base.path}?${Uri.base.query}',
      routes: {
        '/': (context) => const DefaultPage(),
      },
      onGenerateRoute: (settings) {
        final settingsUri = Uri.parse(settings.name ?? '');
        if ((settingsUri.path.isEmpty || settingsUri.path == '/') && settingsUri.queryParameters['vid'] != null) {
          // Old scheme of video page, for backward compatibility
          final videoId = settingsUri.queryParameters['vid'];
          return MaterialPageRoute(
            builder: (context) => VideoPage(id: videoId),
            settings: settings,
          );
        } else if (settingsUri.path == '/story') {
          final id = settingsUri.queryParameters['id'];
          return MaterialPageRoute(
            builder: (context) => StoryPage(id: id),
            settings: settings,
          );
        } else if (settingsUri.path == '/video') {
          final id = settingsUri.queryParameters['id'];
          return MaterialPageRoute(
            builder: (context) => VideoPage(id: id),
            settings: settings,
          );
        } else {
          // Url scheme is not recognized, reset to '/'
          return MaterialPageRoute(
            builder: (context) => const DefaultPage(),
            settings: RouteSettings(name: '/', arguments: settings.arguments),
          );
        }
      },
      // home: MyHomePage(videoId: Uri.base.queryParameters['vid']),
    );
  }
}
