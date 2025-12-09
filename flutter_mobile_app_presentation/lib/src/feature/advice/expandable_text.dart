import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ExpandableText(this.text, {this.style, super.key});

  @override
  State createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin<ExpandableText> {
  bool isExpanded = false;
  final collapsedModeMaxLines = 2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clickable area outside (above) the text when expanded.
          // Clicking outside should collapse the text.
          isExpanded ? Expanded(child: Container()) : const SizedBox(height: 0),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: ConstrainedBox(
              // Expanded text covers 1 / 4 of screen height.
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 4),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: RichText(
                          text: TextSpan(
                            children:
                                splitTextWithExtractedInstagramAndTwitterIds(),
                          ),
                          maxLines: isExpanded ? null : collapsedModeMaxLines,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () => setState(() => isExpanded = !isExpanded),
    );
  }

  List<TextSpan> splitTextWithExtractedInstagramAndTwitterIds() {
    // Marks before and after of handles to social media accounts,
    // parts of the text that start with any number of @ characters,
    // and contain only allowed characters for a social media username.
    final socialMediaAccountRegex =
        RegExp(r'(?=@+[\w.]+)(?<!@)|(?<=@+[\w.]+)(?![\w.])');

    final List<String> textSplitBySocialAccounts =
        widget.text.split(socialMediaAccountRegex);

    return textSplitBySocialAccounts
        .map((e) => TextSpan(
              text: e,
              style: e.startsWith('@')
                  ? widget.style
                      ?.copyWith(color: Theme.of(context).colorScheme.primary)
                  : widget.style,
              recognizer: e.startsWith('@@@')
                  ? (TapGestureRecognizer()..onTap = () => launchTiktokPage(e))
                  : e.startsWith('@@')
                      ? (TapGestureRecognizer()
                        ..onTap = () => launchTwitterPage(e))
                      : e.startsWith('@')
                          ? (TapGestureRecognizer()
                            ..onTap = () => launchInstagramPage(e))
                          : null,
            ))
        .toList();
  }

  launchInstagramPage(String instagramId) async {
    // substring to remove the @ from the id.
    final url = 'https://www.instagram.com/${instagramId.substring(1)}';
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  launchTwitterPage(String twitterId) async {
    // substring to remove the @@ from the id.
    final url = 'https://www.twitter.com/${twitterId.substring(2)}';
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  launchTiktokPage(String tiktokId) async {
    // substring to remove the @@@ from the id.
    final url = 'https://www.tiktok.com/@${tiktokId.substring(3)}';
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }
}
