import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/chat_message_model.dart';
import 'inline_markdown.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool        isStreaming;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: message.isUser
            ? [_UserBubble(content: message.content)]
            : [
                _Avatar(),
                const SizedBox(width: 8),
                _AssistantBubble(
                  content:    message.content,
                  isStreaming: isStreaming,
                ),
              ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(
      color:  AppColors.coachDim,
      shape:  BoxShape.circle,
      border: Border.all(color: AppColors.coachBorder, width: 0.5),
    ),
    child: const Icon(Icons.smart_toy_rounded,
        color: AppColors.coach, size: 16),
  );
}

class _UserBubble extends StatelessWidget {
  final String content;
  const _UserBubble({required this.content});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.72,
    ),
    child: Container(
      padding:     const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration:  const BoxDecoration(
        color:        AppColors.lime,
        borderRadius: BorderRadius.only(
          topLeft:     Radius.circular(18),
          topRight:    Radius.circular(18),
          bottomLeft:  Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(content, style: const TextStyle(
        fontFamily:  'Inter',
        fontSize:    13,
        fontWeight:  FontWeight.w500,
        color:       AppColors.bg,
        height:      1.5,
      )),
    ),
  );
}

class _AssistantBubble extends StatelessWidget {
  final String content;
  final bool   isStreaming;
  const _AssistantBubble({required this.content, required this.isStreaming});

  @override
  Widget build(BuildContext context) => Flexible(
    child: Container(
      padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:  AppColors.surface2,
        borderRadius: const BorderRadius.only(
          topLeft:     Radius.circular(4),
          topRight:    Radius.circular(18),
          bottomLeft:  Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      // ✅ Use IntrinsicWidth to avoid Flexible conflicts
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ✅ important
          children: [
            if (content.isNotEmpty)
              InlineMarkdown(text: content,),
            if (isStreaming) ...[
              const SizedBox(height: 4),
              _StreamingCursor(),
            ],
          ],
        ),
      ),
    ),
  );
}

class _StreamingCursor extends StatefulWidget {
  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _ctrl,
    child: Container(
      width: 8, height: 14,
      decoration: BoxDecoration(
        color:        AppColors.coach,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}