import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/converter_to_section.dart';
import 'package:vibes_common/vibes.dart';

import '../section_item_click_handler.dart';

class AllCreatorsScreen extends StatelessWidget {
  const AllCreatorsScreen({super.key, required this.videoCreators});

  final List<VideoCreator> videoCreators;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Video Creators'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SectionGridView(
              section: videoCreators.asSection(),
              numColumns: 2,
              childAspectRatio: 160 / 341,
              childImageAspectRatio: 1,
              onItemClicked: onSectionItemClickHandler,
              shouldShowPremiumBadge: true,
            ),
          ),
        ],
      ),
    );
  }
}
