import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Renders a small subset of Markdown inline:
///   **bold**, *italic*, bullet lists (- / *), numbered lists (1. 2.)
class InlineMarkdown extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const InlineMarkdown({
    super.key,
    required this.text,
    this.baseStyle, 
  });

  static const _base = TextStyle(
    fontFamily: 'Inter',
    fontSize:   13,
    color:      AppColors.textSecondary,
    height:     1.6,
  );

  @override
  Widget build(BuildContext context) {
    final style = baseStyle ?? _base;
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Bullet list
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        widgets.add(_buildBullet(
          trimmed.substring(2), style));
        continue;
      }

      // Numbered list  1. 2. etc
      final numMatch = RegExp(r'^\d+\.\s').firstMatch(trimmed);
      if (numMatch != null) {
        final num = trimmed.substring(0, numMatch.end - 1);
        final rest = trimmed.substring(numMatch.end);
        widgets.add(_buildNumbered(num, rest, style));
        continue;
      }

      // Regular line with inline bold/italic
      widgets.add(Text.rich(_parseInline(trimmed, style)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:           widgets,
    );
  }

  Widget _buildBullet(String text, TextStyle style) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 6, right: 8),
        child: Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
            color:  AppColors.lime,
            shape:  BoxShape.circle,
          ),
        ),
      ),
      Expanded(child: Text.rich(_parseInline(text, style))),
    ]),
  );

  Widget _buildNumbered(String num, String text, TextStyle style) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$num  ', style: style.copyWith(
        fontWeight: FontWeight.w700, color: AppColors.lime,
      )),
      Expanded(child: Text.rich(_parseInline(text, style))),
    ]),
  );

  // Parse **bold** and *italic* inline tokens
  TextSpan _parseInline(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    // Pattern: **bold** or *italic*
    final pattern = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
    int cursor = 0;

    for (final match in pattern.allMatches(text)) {
      // Text before match
      if (match.start > cursor) {
        spans.add(TextSpan(
          text:  text.substring(cursor, match.start),
          style: base,
        ));
      }
      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text:  match.group(1),
          style: base.copyWith(
            fontWeight: FontWeight.w700,
            color:      AppColors.textPrimary,
          ),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text:  match.group(2),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ));
      }
      cursor = match.end;
    }

    // Remaining text
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }

    return TextSpan(children: spans);
  }
}