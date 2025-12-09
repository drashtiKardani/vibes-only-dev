import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/screens.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: assets.Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14)
                .copyWith(top: context.viewPadding.top + kToolbarHeight + 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Text(
                  'Favorites',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontSize: 24,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                Expanded(
                  child: BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favorites) {
                      return ListView.separated(
                        itemCount: favorites.count(),
                        padding: EdgeInsets.only(
                          bottom: context.viewPadding.bottom + 10,
                        ),
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          FavoriteThing item = favorites.get(index);

                          return _FavoriteHorizontalItem(
                            item: item,
                            onItemClicked: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    if (item is FavoriteStory) {
                                      return StoryDetailScreen(
                                        item.sectionItem,
                                      );
                                    } else {
                                      return AdviceScreen(
                                        null,
                                        (item as FavoriteVideo).id,
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                            onRemove: () {
                              BlocProvider.of<FavoritesCubit>(context)
                                  .removeFavoriteStory(item.title);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteHorizontalItem extends StatelessWidget {
  const _FavoriteHorizontalItem({
    required this.item,
    this.onItemClicked,
    this.onRemove,
  });

  final FavoriteThing item;
  final VoidCallback? onItemClicked;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onItemClicked,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              height: 60,
              width: 120,
            ),
          ),
          Expanded(
            child: Column(
              spacing: 3,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (item.subtitle != null)
                  Text(
                    item.subtitle ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                  )
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onRemove,
            child: Icon(
              VibesV2.favorite,
              color: context.colorScheme.onSurface,
            ),
          )
        ],
      ),
    );
  }
}
