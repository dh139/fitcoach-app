import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../models/chat_message_model.dart';
import '../../providers/coach_provider.dart';
import 'chat_message_bubble.dart';

class ChatWindow extends ConsumerStatefulWidget {
  const ChatWindow({super.key});

  @override
  ConsumerState<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends ConsumerState<ChatWindow> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      if (animated) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve:    Curves.easeOut,
        );
      } else {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(coachProvider);
    final user     = ref.watch(currentUserProvider);
    final userName = user?.name ?? 'Athlete';

    // Auto-scroll when new content arrives
    ref.listen(coachProvider.select((s) => s.messages.length), (_, __) {
      _scrollToBottom();
    });
    ref.listen(coachProvider.select((s) => s.streamingContent.length),
        (_, __) => _scrollToBottom(animated: false));

    final showWelcome = !state.historyLoading && !state.hasMessages;

    // Build display messages
    final displayMessages = showWelcome
        ? [ChatMessage.welcome(userName)]
        : state.messages;

    return ListView.builder(
      controller:  _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: displayMessages.length +
          (state.isStreaming ? 1 : 0),
      itemBuilder: (_, i) {
        // Streaming assistant bubble at the end
        if (i == displayMessages.length && state.isStreaming) {
          return ChatMessageBubble(
            message: ChatMessage(
              role:      'assistant',
              content:   state.streamingContent,
              timestamp: DateTime.now(),
            ),
            isStreaming: true,
          );
        }
        return ChatMessageBubble(
          message: displayMessages[i],
        );
      },
    );
  }
}