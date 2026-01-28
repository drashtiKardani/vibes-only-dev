// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
// import 'package:flutter_mobile_app_presentation/controllers.dart';
// import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
// import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
// import 'package:flutter_mobile_app_presentation/theme.dart';
// import 'package:gap/gap.dart';
// import 'package:get_it/get_it.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:vibes_common/vibes.dart';
// import 'package:vibes_only/gen/assets.gen.dart';
// import 'package:vibes_only/src/data/commodities_store.dart';
// import 'package:vibes_only/src/feature/vibes_ai/components/known_toys_grid_view.dart';
// import 'package:vibes_only/src/feature/vibes_ai/components/ai_option_selector.dart';
// import 'package:vibes_only/src/feature/vibes_ai/components/vibe_studio_grid_view.dart';
// import 'package:vibes_only/src/feature/vibes_ai/enums/pre_defined_mood.dart';
// import 'package:vibes_only/src/feature/vibes_ai/enums/vibe_mode.dart';
// import 'package:vibes_only/src/feature/vibes_ai/extensions/extensions.dart';
// import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
// import 'package:flutter_mobile_app_presentation/src/feature/section_item_click_handler.dart';
// import 'dart:math' as math;

// const EdgeInsets _defaultPadding = EdgeInsets.symmetric(
//   horizontal: 16,
//   vertical: 8,
// );

// class VibesAiScreen extends StatefulWidget {
//   const VibesAiScreen({super.key});

//   @override
//   State<VibesAiScreen> createState() => _VibesAiScreenState();
// }

// class _VibesAiScreenState extends State<VibesAiScreen> {
//   late final VibesAiCubit _vibesAiCubit = context.read<VibesAiCubit>();
//   late final VibeApiNew _api = GetIt.I<VibeApiNew>();
//   late final TextEditingController _textEditingController =
//       TextEditingController();
//   late final ScrollController _scrollController = ScrollController();

//   late final List<Commodity> _knownToys = GetIt.I<CommoditiesStore>().knownToys;
//   int itemCount = VibePatters.count();
//   int threadId = math.Random().nextInt(100000);
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _vibesAiCubit.startChat(
//         startContent: _ContentWrapper(
//           fromAI: true,
//           child: Text(
//             'Nice to meet you. Here are the things I can do for you:',
//             style: context.textTheme.titleMedium,
//           ),
//         ),
//         suggestionsForYouContent: _buildSuggestions(),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     _scrollController.dispose();

//     super.dispose();
//   }

//   void _scrollToBottom({bool animated = true}) {
//     if (!_scrollController.hasClients) return;

//     final double target = _scrollController.position.maxScrollExtent;

//     if (!animated) {
//       _scrollController.jumpTo(target);
//       return;
//     }

//     _scrollController.animateTo(
//       target,
//       // make it smoother: longer duration
//       duration: const Duration(milliseconds: 800),
//       curve: Curves.easeOutCubic,
//     );
//   }

//   Widget _buildSuggestions() {
//     return _ContentWrapper(
//       fromAI: true,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children:
//             [
//               _SuggestionListItem(
//                 icon: VibesV3.vibesLined,
//                 title: 'Tell me about products.',
//                 onPressed: _onTellMeAboutProductsPressed,
//               ),
//               _SuggestionListItem(
//                 icon: HugeIcon(
//                   icon: HugeIcons.strokeRoundedPlay,
//                   color: context.colorScheme.onSurface,
//                 ),
//                 title: 'Design a vibe for me based on how I feel.',
//                 onPressed: _onDesignVibeBasedOnMoodPressed,
//               ),
//               _SuggestionListItem(
//                 icon: VibesV3.searchLined,
//                 title: 'Pick a story for me.',
//                 onPressed: _onPickStoryForMePressed,
//               ),
//               _SuggestionListItem(
//                 icon: VibesV3.shop,
//                 title: 'Help me shop for a new product.',
//                 onPressed: _onHelpMeShopPressed,
//               ),
//               _SuggestionListItem(
//                 icon: VibesV3.sound,
//                 title: 'Design a Vibe for me',
//                 onPressed: _onDesignVibeForMePressed,
//               ),
//             ].separateBuilder(
//               () => Divider(
//                 color: context.colorScheme.onSurface.withValues(alpha: 0.06),
//               ),
//             ),
//       ),
//     );
//   }

//   void _onTellMeAboutProductsPressed() {
//     _vibesAiCubit.sentChat(
//       content: Column(
//         spacing: 10,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _ContentWrapper(
//             fromAI: true,
//             child: Text(
//               'Select the products you have.',
//               style: context.textTheme.titleMedium,
//             ),
//           ),
//           BlocBuilder<VibesAiCubit, VibesAiState>(
//             bloc: _vibesAiCubit,
//             builder: (context, state) {
//               return KnownToysGridView(
//                 toy: state.toy,
//                 knownToys: _knownToys,
//                 onToySelected: (toy) {
//                   _vibesAiCubit.onToySelected(toy);

//                   final String? shopUrl = toy.shopUrl;
//                   if (shopUrl == null) return;

//                   final Uri shopUri = Uri.parse(shopUrl);
//                   launchUrl(shopUri);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _onDesignVibeBasedOnMoodPressed() {
//     _vibesAiCubit.sentChat(
//       content: Column(
//         spacing: 10,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _ContentWrapper(
//             fromAI: true,
//             child: Text(
//               'Choose how you want to create your vibe.',
//               style: context.textTheme.titleMedium,
//             ),
//           ),
//           _ContentWrapper(
//             fromAI: true,
//             child: AiOptionSelector<VibeMode>(
//               options: VibeMode.values,
//               titleOf: (option) => option.displayName,
//               onSelected: _onVibeModeSelected,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onDesignVibeForMePressed() {
//     _vibesAiCubit.sentChat(
//       content: Column(
//         spacing: 10,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           BlocBuilder<VibesAiCubit, VibesAiState>(
//             bloc: _vibesAiCubit,
//             builder: (context, state) {
//               return VibeStudioGridView(itemCount: itemCount);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _onHelpMeShopPressed() {
//     _handleSendMessage('Help me shop for a new product.');
//   }

//   void _onPickStoryForMePressed() {
//     _handleSendMessage('Pick a story for me.');
//   }

//   Future<void> _handleSendMessage(String rawText) async {
//     final String message = rawText.trim();
//     if (message.isEmpty) return;

//     // Hide keyboard
//     FocusScope.of(context).unfocus();

//     // Add user message bubble
//     _vibesAiCubit.sentChat(
//       isThinking: true,
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _ContentWrapper(
//             fromAI: false,
//             child: Text(message, style: context.textTheme.titleMedium),
//           ),
//         ],
//       ),
//     );

//     // Clear input
//     _textEditingController.clear();

//     try {
//       final ChatResponse result = await _api.sendChatMessage(
//         ChatRequest(
//           userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user',
//           threadId: threadId.toString(),
//           message: message,
//         ),
//       );

//       // Add AI response bubble
//       _vibesAiCubit.sentChat(
//         isThinking: false,
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _ContentWrapper(
//               fromAI: true,
//               child: MarkdownBody(
//                 selectable: true,
//                 data: result.response.message,
//                 styleSheet: MarkdownStyleSheet(
//                   // Paragraph text (NORMAL weight)
//                   p: context.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w400,
//                     height: 1.5,
//                   ),

//                   // Links
//                   a: context.textTheme.bodyMedium?.copyWith(
//                     color: Colors.blue,
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.underline,
//                   ),

//                   // Bold (**text**)
//                   strong: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Theme.of(context).primaryColor,
//                   ),

//                   // Italic (*text*)
//                   em: const TextStyle(
//                     fontStyle: FontStyle.italic,
//                     fontWeight: FontWeight.w400,
//                   ),

//                   // Headings
//                   h1: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//                   h2: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//                   h3: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   h4: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   h5: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   h6: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                   ),

//                   // Optional: blockquote (nice for chat-style UI)
//                   blockquote: context.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w400,
//                     color: Colors.grey,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//                 onTapLink: (text, href, title) {
//                   if (href == null && text.isEmpty) return;
//                   launchUrl(Uri.parse(href ?? text));
//                 },
//               ),
//             ),
//             if (result.response.stories != null &&
//                 result.response.stories!.isNotEmpty) ...[
//               SizedBox(height: 20),
//               _ContentWrapper(
//                 fromAI: true,
//                 child: BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
//                   builder: (context, subscription) {
//                     return ListView.separated(
//                       separatorBuilder: (context, index) {
//                         return const SizedBox(height: 20);
//                       },
//                       shrinkWrap: true,
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: result.response.stories!.length,
//                       itemBuilder: (context, index) => SectionListItem(
//                         sectionItem: result.response.stories![index]
//                             .toSectionItem('detail-all', Style.showcaseMedium),
//                         onItemClicked: onSectionItemClickHandler,
//                         shouldShowPremiumBadge: subscription.isNotActive(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],

//             if (result.response.suggestedToys != null &&
//                 result.response.suggestedToys!.isNotEmpty) ...[
//               SizedBox(height: 20),
//               _ContentWrapper(
//                 fromAI: true,
//                 child: BlocBuilder<VibesAiCubit, VibesAiState>(
//                   bloc: _vibesAiCubit,
//                   builder: (context, state) {
//                     return KnownToysGridView(
//                       toy: state.toy,
//                       knownToys: result.response.suggestedToys!,
//                       onToySelected: (toy) {
//                         _vibesAiCubit.onToySelected(toy);

//                         final String? shopUrl = toy.shopUrl;
//                         if (shopUrl == null) return;

//                         final Uri shopUri = Uri.parse(shopUrl);
//                         launchUrl(shopUri);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ],
//         ),
//       );
//     } catch (e) {
//       _vibesAiCubit.sentChat(
//         isThinking: false,
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _ContentWrapper(
//               fromAI: true,
//               child: Text(
//                 'Something went wrong. Please try again.',
//                 style: context.textTheme.bodySmall?.copyWith(
//                   color: context.colorScheme.error,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<VibesAiCubit, VibesAiState>(
//       bloc: _vibesAiCubit,
//       builder: (context, state) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _scrollToBottom(animated: true);
//         });
//         return Scaffold(
//           extendBodyBehindAppBar: true,
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             scrolledUnderElevation: 0,
//             leading: Transform.scale(
//               scale: 0.7,
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: context.colorScheme.onSurface.withValues(alpha: 0.1),
//                 ),
//                 child: IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: HugeIcon(
//                     icon: HugeIcons.strokeRoundedArrowLeft02,
//                     color: context.colorScheme.onSurface,
//                   ),
//                   iconSize: 30,
//                 ),
//               ),
//             ),
//             title: Row(
//               spacing: 8,
//               children: [const Text('Whitney'), Assets.svg.vibesAi.svg()],
//             ),
//             titleTextStyle: context.textTheme.displaySmall,
//           ),
//           body: Stack(
//             children: [
//               Positioned.fill(
//                 child: assets.Assets.images.background.image(
//                   filterQuality: FilterQuality.high,
//                   package: 'flutter_mobile_app_presentation',
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
//                   top: context.mediaQuery.viewPadding.top + kToolbarHeight + 10,
//                 ),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: ListView.separated(
//                         controller: _scrollController,

//                         itemCount: state.chats.length,
//                         separatorBuilder: (context, index) => const Gap(20),
//                         padding: EdgeInsets.only(
//                           bottom: context.mediaQuery.viewPadding.bottom + 10,
//                         ),
//                         itemBuilder: (context, index) {
//                           final ChatWithAI chat = state.chats[index];
//                           return chat.content;
//                         },
//                       ),
//                     ),
//                     if (state.isThinking)
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           margin: EdgeInsets.symmetric(vertical: 10),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.only(
//                               topRight: const Radius.circular(16),
//                               topLeft: const Radius.circular(16),
//                               bottomLeft: Radius.zero,
//                               bottomRight: const Radius.circular(16),
//                             ),
//                             color: context.colorScheme.onSurface.withValues(
//                               alpha: 0.05,
//                             ),
//                           ),
//                           child: Image.asset(
//                             'assets/images/typing.gif',
//                             scale: 3,
//                           ),
//                         ),
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 18.0),
//                       child: TextField(
//                         controller: _textEditingController,
//                         autofocus: false,
//                         onSubmitted: _handleSendMessage,
//                         decoration: InputDecoration(
//                           hintText: 'Type here...',
//                           hintStyle: context.textTheme.titleMedium?.copyWith(
//                             fontSize: 14,
//                             color: context.colorScheme.onSurface.withValues(
//                               alpha: 0.5,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderSide: const BorderSide(
//                               color: Color.fromRGBO(255, 255, 255, 0.2),
//                             ),
//                             borderRadius: BorderRadius.circular(50),
//                           ),
//                           suffixIcon: GestureDetector(
//                             onTap: () =>
//                                 _handleSendMessage(_textEditingController.text),
//                             child: Padding(
//                               padding: const EdgeInsets.only(right: 8.0),
//                               child: Image.asset(
//                                 'assets/images/send.png',
//                                 scale: 3,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _onVibeModeSelected(VibeMode mode) {
//     switch (mode) {
//       case VibeMode.chooseFromPreDefinedMoods:
//         _vibesAiCubit.sentChat(
//           content: Column(
//             spacing: 10,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _ContentWrapper(
//                 fromAI: true,
//                 child: Text(
//                   'Choose from Pre-Defined Mood:',
//                   style: context.textTheme.titleMedium,
//                 ),
//               ),
//               _ContentWrapper(
//                 fromAI: true,
//                 child: AiOptionSelector<PreDefinedMood>(
//                   options: PreDefinedMood.values,
//                   titleOf: (option) => option.displayName,
//                   onSelected: (option) {
//                     // TODO: hook this into AI flow
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//         break;
//       case VibeMode.describeYourMood:
//         _vibesAiCubit.sentChat(
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _ContentWrapper(
//                 fromAI: true,
//                 child: Text(
//                   'Tell me how you feel in one line.',
//                   style: context.textTheme.titleMedium,
//                 ),
//               ),
//             ],
//           ),
//         );
//         break;
//     }
//   }
// }

// class _ContentWrapper extends StatelessWidget {
//   final Widget child;
//   final bool fromAI;

//   const _ContentWrapper({required this.child, required this.fromAI});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: _defaultPadding,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(
//           topRight: const Radius.circular(16),
//           topLeft: const Radius.circular(16),
//           bottomLeft: fromAI ? Radius.zero : const Radius.circular(16),
//           bottomRight: fromAI ? const Radius.circular(16) : Radius.zero,
//         ),
//         color: context.colorScheme.onSurface.withValues(alpha: 0.05),
//       ),
//       child: child,
//     );
//   }
// }

// class _SuggestionListItem extends StatelessWidget {
//   final dynamic icon;
//   final String title;
//   final VoidCallback? onPressed;

//   const _SuggestionListItem({
//     required this.icon,
//     required this.title,
//     this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Widget iconWidget = const SizedBox.shrink();

//     if (icon is IconData) {
//       iconWidget = Icon(icon, color: context.colorScheme.onSurface);
//     } else {
//       iconWidget = icon as Widget;
//     }

//     return ListTile(
//       minTileHeight: 30,
//       onTap: onPressed,
//       leading: iconWidget,
//       title: Text(title),
//       titleTextStyle: context.textTheme.titleMedium?.copyWith(fontSize: 14),
//       trailing: Icon(
//         Icons.arrow_forward_ios_rounded,
//         size: 14,
//         color: context.colorScheme.onSurface,
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/vibes_ai/components/known_toys_grid_view.dart';
import 'package:vibes_only/src/feature/vibes_ai/components/ai_option_selector.dart';
import 'package:vibes_only/src/feature/vibes_ai/enums/pre_defined_mood.dart';
import 'package:vibes_only/src/feature/vibes_ai/enums/vibe_mode.dart';
import 'package:vibes_only/src/feature/vibes_ai/extensions/extensions.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
import 'package:flutter_mobile_app_presentation/src/feature/section_item_click_handler.dart';
import 'dart:math' as math;

const EdgeInsets _defaultPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 8,
);

class VibesAiScreen extends StatefulWidget {
  const VibesAiScreen({super.key});

  @override
  State<VibesAiScreen> createState() => _VibesAiScreenState();
}

class _VibesAiScreenState extends State<VibesAiScreen> {
  late final VibesAiCubit _cubit = context.read<VibesAiCubit>();
  late final VibeApiNew _api = GetIt.I<VibeApiNew>();
  late final TextEditingController _textController = TextEditingController();
  late final ScrollController _scrollController = ScrollController();
  late final FocusNode _focusNode = FocusNode();
  late final int _threadId = math.Random().nextInt(100000);
  VibeMode? _vibeMode;
  List<Commodity> get _knownToys => GetIt.I<CommoditiesStore>().knownToys;
  List<int> get _itemCount =>
      List<int>.generate(VibePatters.count(), (index) => index);

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.startChat(
        startContent: _buildWelcomeMessage(),
        suggestionsForYouContent: _buildSuggestions(),
      );
    });
  }

  Widget _buildWelcomeMessage() {
    return _ContentWrapper(
      fromAI: true,
      child: Text(
        'Nice to meet you. Here are the things I can do for you:',
        style: context.textTheme.titleMedium,
      ),
    );
  }

  Widget _buildSuggestions() {
    return BlocBuilder<VibesAiCubit, VibesAiState>(
      bloc: _cubit,
      builder: (context, state) {
        final suggestions = [
          _SuggestionItem(
            icon: VibesV3.vibesLined,
            title: 'Tell me about products.',
            onPressed: state.isThinking ? null : _onTellMeAboutProductsPressed,
          ),
          _SuggestionItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedPlay,
              color: context.colorScheme.onSurface,
            ),
            title: 'Design a vibe for me based on how I feel.',
            onPressed: state.isThinking
                ? null
                : _onDesignVibeBasedOnMoodPressed,
          ),
          _SuggestionItem(
            icon: VibesV3.searchLined,
            title: 'Pick a story for me.',
            onPressed: state.isThinking ? null : _onPickStoryForMePressed,
          ),
          _SuggestionItem(
            icon: VibesV3.shop,
            title: 'Help me shop for a new product.',
            onPressed: state.isThinking ? null : _onHelpMeShopPressed,
          ),
          _SuggestionItem(
            icon: VibesV3.sound,
            title: 'Design a Vibe for me',
            onPressed: state.isThinking ? null : _onDesignVibeForMePressed,
          ),
        ];

        return _ContentWrapper(
          fromAI: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: suggestions.separateBuilder(
              () => Divider(
                color: context.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
          ),
        );
      },
    );
  }

  // ========== Suggestion Handlers ==========

  void _onTellMeAboutProductsPressed() {
    if (_cubit.state.isThinking) return;

    _cubit.sendChat(chatBy: ChatBy.ai, content: _buildProductSelection());
  }

  void _onDesignVibeBasedOnMoodPressed() {
    if (_cubit.state.isThinking) return;

    _cubit.sendChat(chatBy: ChatBy.ai, content: _buildVibeModeSelection());
  }

  void _onDesignVibeForMePressed() {
    if (_cubit.state.isThinking) return;

    _cubit.sendChat(chatBy: ChatBy.ai, content: _buildWavesSection(_itemCount));
  }

  void _onHelpMeShopPressed() {
    if (_cubit.state.isThinking) return;
    _sendMessage('Help me shop for a new product.');
  }

  void _onPickStoryForMePressed() {
    if (_cubit.state.isThinking) return;
    _sendMessage('Pick a story for me.');
  }

  // ========== Chat Content Builders ==========

  Widget _buildProductSelection() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentWrapper(
          fromAI: true,
          child: Text(
            'Select the products you have.',
            style: context.textTheme.titleMedium,
          ),
        ),
        BlocBuilder<VibesAiCubit, VibesAiState>(
          bloc: _cubit,
          builder: (context, state) => KnownToysGridView(
            toy: state.toy,
            knownToys: _knownToys,
            onToySelected: _handleToySelection,
          ),
        ),
      ],
    );
  }

  Widget _buildVibeModeSelection() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentWrapper(
          fromAI: true,
          child: Text(
            'Choose how you want to create your vibe.',
            style: context.textTheme.titleMedium,
          ),
        ),
        _ContentWrapper(
          fromAI: true,
          child: AiOptionSelector<VibeMode>(
            options: VibeMode.values,
            titleOf: (option) => option.displayName,
            onSelected: _onVibeModeSelected,
          ),
        ),
      ],
    );
  }

  void _handleToySelection(Commodity toy) {
    if (_cubit.state.isThinking) return;

    _cubit.onToySelected(toy);

    final shopUrl = toy.shopUrl;
    if (shopUrl != null) {
      launchUrl(Uri.parse(shopUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _onVibeModeSelected(VibeMode mode) {
    if (_cubit.state.isThinking) return;
    _vibeMode = mode;
    switch (mode) {
      case VibeMode.chooseFromPreDefinedMoods:
        _cubit.sendChat(
          chatBy: ChatBy.ai,
          content: _buildPreDefinedMoodSelection(),
        );
        break;
      case VibeMode.describeYourMood:
        _cubit.sendChat(
          chatBy: ChatBy.ai,
          content: _buildMoodDescriptionPrompt(),
        );
        break;
    }
  }

  Widget _buildPreDefinedMoodSelection() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentWrapper(
          fromAI: true,
          child: Text(
            'Choose from Pre-Defined Mood:',
            style: context.textTheme.titleMedium,
          ),
        ),
        _ContentWrapper(
          fromAI: true,
          child: AiOptionSelector<PreDefinedMood>(
            options: PreDefinedMood.values,
            titleOf: (option) => option.displayName,
            onSelected: (option) {
              if (_cubit.state.isThinking) return;
              _vibeMode = VibeMode.chooseFromPreDefinedMoods;
              _sendMessage(option.displayName);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodDescriptionPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentWrapper(
          fromAI: true,
          child: Text(
            'Tell me how you feel in one line.',
            style: context.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  // ========== Message Handling ==========

  void _sendMessage(String message) {
    if (_cubit.state.isThinking) return;

    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return;

    _handleSendMessage(trimmedMessage);
  }

  Future<void> _handleSendMessage(String message) async {
    // Prevent multiple simultaneous requests
    if (_cubit.state.isThinking) return;

    // Hide keyboard
    _focusNode.unfocus();

    // Add user message (aligned to right)
    _cubit.sendChat(
      chatBy: ChatBy.user,
      isThinking: true,
      content: _ContentWrapper(
        fromAI: false,
        child: _vibeMode != null
            ? Text(message, style: context.textTheme.titleMedium)
            : Text(message, style: context.textTheme.titleMedium),
      ),
    );

    _textController.clear();

    try {
      final result = await _api.sendChatMessage(
        ChatRequest(
          userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user',
          threadId: _threadId.toString(),
          message: _vibeMode != null
              ? 'Design a vibe for me: $message'
              : message,
        ),
      );
      _vibeMode = null;

      // Add AI response (aligned to left)
      _cubit.sendChat(
        chatBy: ChatBy.ai,
        isThinking: false,
        content: _buildAIResponse(result),
      );
    } catch (e) {
      _cubit.sendChat(
        chatBy: ChatBy.ai,
        isThinking: false,
        content: _buildErrorMessage(),
      );
    }
  }

  Widget _buildAIResponse(ChatResponse result) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentWrapper(
          fromAI: true,
          child: MarkdownBody(
            selectable: true,
            data: result.response.message,
            styleSheet: _buildMarkdownStyleSheet(),
            onTapLink: (text, href, title) {
              final url = href ?? text;
              if (url.isNotEmpty) {
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
        if (result.response.stories?.isNotEmpty ?? false)
          _buildStoriesSection(result.response.stories!),
        if (result.response.suggestedToys?.isNotEmpty ?? false)
          _buildSuggestedToysSection(result.response.suggestedToys!),
        if (result.response.waves?.isNotEmpty ?? false)
          _buildWavesSection(result.response.waves!),
      ],
    );
  }

  Widget _buildWavesSection(List<int> waves) {
    return Column(
      children: [
        const SizedBox(height: 10),

        _ContentWrapper(
          fromAI: true,
          child: GridView.builder(
            itemCount: waves.length,
            shrinkWrap: true,

            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              Color onSurface = context.colorScheme.onSurface;

              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: AnimatedContainer(
                  width: double.infinity,
                  height: double.infinity,
                  duration: Durations.medium2,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: onSurface.withValues(alpha: 0.05),
                    border: Border.all(color: onSurface.withValues(alpha: 0.2)),
                  ),
                  child: VibePatters.getByIndex(waves[index], color: onSurface),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoriesSection(List<dynamic> stories) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _ContentWrapper(
          fromAI: true,
          child: BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
            builder: (context, subscription) {
              return ListView.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stories.length,
                itemBuilder: (context, index) => SectionListItem(
                  sectionItem: stories[index].toSectionItem(
                    'detail-all',
                    Style.showcaseMedium,
                  ),
                  onItemClicked: onSectionItemClickHandler,
                  shouldShowPremiumBadge: subscription.isNotActive(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedToysSection(List<Commodity> toys) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _ContentWrapper(
          fromAI: true,
          child: BlocBuilder<VibesAiCubit, VibesAiState>(
            bloc: _cubit,
            builder: (context, state) => KnownToysGridView(
              toy: state.toy,
              knownToys: toys,
              onToySelected: _handleToySelection,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return _ContentWrapper(
      fromAI: true,
      child: Text(
        'Something went wrong. Please try again.',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.error,
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      p: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      a: context.textTheme.bodyMedium?.copyWith(
        color: Colors.blue,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).primaryColor,
      ),
      em: const TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
      ),
      h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      h4: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      h5: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      h6: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      blockquote: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  // ========== UI Build Methods ==========
  void _scrollToBottomReliable() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) return;

      await Future.delayed(const Duration(milliseconds: 50));

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VibesAiCubit, VibesAiState>(
      listenWhen: (prev, curr) =>
          prev.chats.length != curr.chats.length ||
          prev.isThinking != curr.isThinking,
      listener: (_, __) => _scrollToBottomReliable(),
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: Stack(children: [_buildBackground(), _buildChatArea(state)]),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      leading: _buildBackButton(),
      title: Row(
        spacing: 8,
        children: [const Text('Whitney'), Assets.svg.vibesAi.svg()],
      ),
      titleTextStyle: context.textTheme.displaySmall,
    );
  }

  Widget _buildBackButton() {
    return Transform.scale(
      scale: 0.7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: context.colorScheme.onSurface,
          ),
          iconSize: 30,
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: assets.Assets.images.background.image(
        filterQuality: FilterQuality.high,
        package: 'flutter_mobile_app_presentation',
      ),
    );
  }

  Widget _buildChatArea(VibesAiState state) {
    return Padding(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: context.mediaQuery.viewPadding.top + kToolbarHeight + 10,
      ),
      child: Column(
        children: [
          Expanded(child: _buildChatList(state)),
          if (state.isThinking) _buildThinkingIndicator(),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildChatList(VibesAiState state) {
    return ListView.separated(
      controller: _scrollController,
      itemCount: state.chats.length,
      separatorBuilder: (_, __) => const Gap(10),
      padding: EdgeInsets.only(
        bottom: context.mediaQuery.viewPadding.bottom + 10,
      ),
      itemBuilder: (context, index) {
        final chat = state.chats[index];
        return Align(
          alignment: chat.chatBy == ChatBy.user
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: chat.content,
        );
      },
    );
  }

  Widget _buildThinkingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(16),
          ),
          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        child: Image.asset('assets/images/typing.gif', scale: 3),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: BlocBuilder<VibesAiCubit, VibesAiState>(
        bloc: _cubit,
        builder: (context, state) {
          return TextField(
            controller: _textController,
            focusNode: _focusNode,
            enabled: !state.isThinking,
            autofocus: false,
            textInputAction: TextInputAction.send,
            onSubmitted: _sendMessage,
            decoration: InputDecoration(
              hintText: state.isThinking ? 'AI is typing...' : 'Type here...',
              hintStyle: context.textTheme.titleMedium?.copyWith(
                fontSize: 14,
                color: context.colorScheme.onSurface.withValues(
                  alpha: state.isThinking ? 0.3 : 0.5,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: state.isThinking
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : const Color.fromRGBO(255, 255, 255, 0.2),
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              suffixIcon: IgnorePointer(
                ignoring: state.isThinking,
                child: GestureDetector(
                  onTap: () => _sendMessage(_textController.text),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Opacity(
                      opacity: state.isThinking ? 0.3 : 1.0,
                      child: Image.asset('assets/images/send.png', scale: 3),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ========== Helper Widgets ==========

class _ContentWrapper extends StatelessWidget {
  final Widget child;
  final bool fromAI;

  const _ContentWrapper({required this.child, required this.fromAI});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _defaultPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(16),
          topLeft: const Radius.circular(16),
          bottomLeft: fromAI ? Radius.zero : const Radius.circular(16),
          bottomRight: fromAI ? const Radius.circular(16) : Radius.zero,
        ),
        color: context.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      child: child,
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final VoidCallback? onPressed;

  const _SuggestionItem({
    required this.icon,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon is IconData
        ? Icon(icon, color: context.colorScheme.onSurface)
        : icon as Widget;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minTileHeight: 30,
      onTap: onPressed,
      leading: iconWidget,
      title: Text(title),
      titleTextStyle: context.textTheme.titleMedium?.copyWith(fontSize: 14),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: context.colorScheme.onSurface,
      ),
    );
  }
}
