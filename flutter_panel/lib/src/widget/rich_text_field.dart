import 'package:flutter/material.dart';
import 'package:flutter_panel/src/di/di.dart';

class RichTextField extends StatefulWidget {
  final String? initialText;
  final String? hint;
  final Function(String? text) onChange;
  final int maxLines;
  final bool error;
  final String? errorMessage;

  const RichTextField(
      {super.key,
      required this.onChange,
      this.hint,
      this.maxLines = 1,
      this.initialText,
      this.error = false,
      this.errorMessage});

  @override
  State createState() => _RichTextFieldState();
}

class _RichTextFieldState extends State<RichTextField> {
  final TextEditingController _controller = TextFieldColorizer(
    {
      r'_(.*?)\_': TextStyle(fontStyle: FontStyle.italic, shadows: kElevationToShadow[2]),
      '~(.*?)~': TextStyle(decoration: TextDecoration.lineThrough, shadows: kElevationToShadow[2]),
      r'\*(.*?)\*': TextStyle(fontWeight: FontWeight.bold, shadows: kElevationToShadow[2]),
    },
  );

  @override
  void initState() {
    _controller.text = widget.initialText ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            maxLines: widget.maxLines,
            onChanged: (text) {
              final val = TextSelection.collapsed(offset: _controller.text.length);
              _controller.selection = val;
              widget.onChange.call(text);
            },
            controller: _controller,
            decoration: InputDecoration(hintText: widget.hint),
          ),
          if (widget.error) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.errorMessage ?? strings.fieldRequired,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            const SizedBox(
              height: 8,
            )
          ],
          const Divider(
            height: 0,
            endIndent: 10,
            indent: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              strings.richTextDescription,
              style: const TextStyle(fontSize: 10),
            ),
          )
        ],
      ),
    );
  }
}

class TextFieldColorizer extends TextEditingController {
  final Map<String, TextStyle> map;
  final Pattern pattern;

  TextFieldColorizer(this.map)
      : pattern = RegExp(
            map.keys.map((key) {
              return key;
            }).join('|'),
            multiLine: true);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<InlineSpan> children = [];
    String patternMatched = '';
    String formatText;
    TextStyle myStyle;
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        myStyle = (map[match[0]] ??
            map[map.keys.firstWhere(
              (e) {
                bool ret = false;
                RegExp(e).allMatches(text).forEach((element) {
                  if (element.group(0) == match[0]) {
                    patternMatched = e;
                    ret = true;
                  }
                });
                return ret;
              },
            )])!;

        if (patternMatched == r"_(.*?)\_") {
          formatText = match[0]!.replaceAll("_", " ");
        } else if (patternMatched == r'\*(.*?)\*') {
          formatText = match[0]!.replaceAll("*", " ");
        } else if (patternMatched == "~(.*?)~") {
          formatText = match[0]!.replaceAll("~", " ");
        } else if (patternMatched == r'```(.*?)```') {
          formatText = match[0]!.replaceAll("```", "   ");
        } else {
          formatText = match[0]!;
        }
        children.add(TextSpan(
          text: formatText,
          style: style!.merge(myStyle),
        ));
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}
