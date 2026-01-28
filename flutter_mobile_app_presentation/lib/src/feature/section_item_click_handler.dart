import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/channel_screen_by_id.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/video_creator_screen.dart';
import 'package:vibes_common/vibes.dart';

import '../audio/audio_handler.dart';
import '../cubit/iap/in_app_purchase_cubit.dart';
import '../dialog/go_premium_dialog.dart';
import '../service/analytics.dart';
import 'advice/advice_screen.dart';
import 'detail_list/detail_list_screen.dart';
import 'story_detail/story_detail_screen.dart';


/// Call [onSectionItemClickHandler] + Report the name and type of clicked item
void firstPageSectionItemClickHandler(BuildContext context, SectionItem item) {
  Analytics.logEvent(
    context: context,
    name: 'first_page_item_click',
    parameters: {
      'first_page_item_click__type': item.type.name,
      'first_page_item_click__list_title': item.parentSection?.title ?? '',
      'first_page_item_click__item_title': item.title,
    },
  );
  onSectionItemClickHandler(context, item);
}

void onSectionItemClickHandler(BuildContext context, SectionItem item) {
  switch (item.type) {
    case SectionType.story:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoryDetailScreen(item)),
      );
      break;
    case SectionType.category:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailListScreen(item, SectionType.category),
        ),
      );
      break;
    case SectionType.character:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return DetailListScreen(item, SectionType.character);
        }),
      );
      break;
    case SectionType.video:
      VibesAudioHandler.instance.stop();
      if (BlocProvider.of<InAppPurchaseCubit>(context).state.isNotActive() &&
          (item.premium ?? false)) {
        showGoPremiumBottomSheet(context);
        break;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdviceScreen(item.parentId, item.id),
        ),
      );
      break;
    case SectionType.channel:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChannelScreenById(id: item.id)),
      );
      break;
    case SectionType.videoCreator:
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return VideoCreatorScreen(
            id: item.id,
            name: item.title,
            bio: item.description,
            image: item.thumbnail,
          );
        },
      ));
      break;
  }
}
