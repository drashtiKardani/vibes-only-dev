import 'package:flutter/material.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/list_of_spotify_objects.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/model/search_response.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/spotify_web_sdk.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.accessToken});

  final String accessToken;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final webSdk = SpotifyWebSdk(accessToken: widget.accessToken);

  late final TabController _tabController =
      TabController(length: 4, vsync: this);

  final TextEditingController _searchController = TextEditingController();

  SearchResponse? searchResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Vibes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'SEARCH',
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
          TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            indicatorColor: Colors.white,
            controller: _tabController,
            tabs: const [
              Tab(text: 'SONGS'),
              Tab(text: 'ARTISTS'),
              Tab(text: 'ALBUMS'),
              Tab(text: 'PLAYLISTS'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListOfSpotifyObjects.tracks(
                  tracks: searchResponse?.tracks.items,
                  context: context,
                ),
                ListOfSpotifyObjects.artists(
                  artists: searchResponse?.artists.items,
                  context: context,
                  accessToken: widget.accessToken,
                ),
                ListOfSpotifyObjects.albums(
                  albums: searchResponse?.albums.items,
                  context: context,
                  accessToken: widget.accessToken,
                ),
                ListOfSpotifyObjects.playlists(
                  playlists: searchResponse?.playlists.items,
                  context: context,
                  accessToken: widget.accessToken,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _search() async {
    searchResponse = await webSdk.search(query: _searchController.text);
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
