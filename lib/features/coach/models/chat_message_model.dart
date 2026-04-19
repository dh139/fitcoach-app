class ChatMessage {
  final String   role;     // 'user' | 'assistant'
  final String   content;
  final DateTime timestamp;
  final bool     isStreaming;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role:      json['role']      as String? ?? 'user',
    content:   json['content']   as String? ?? '',
    timestamp: DateTime.tryParse(
                 json['timestamp'] as String? ?? '') ?? DateTime.now(),
  );

  bool get isUser      => role == 'user';
  bool get isAssistant => role == 'assistant';

  ChatMessage copyWith({String? content, bool? isStreaming}) => ChatMessage(
    role:        role,
    content:     content     ?? this.content,
    timestamp:   timestamp,
    isStreaming: isStreaming ?? this.isStreaming,
  );

  // Welcome message shown before any conversation
  static ChatMessage welcome(String userName) => ChatMessage(
    role:      'assistant',
    content:   "Hey $userName! I'm your FitCoach AI. I know your "
               "workout history, XP progress, and fitness goals — so ask "
               "me anything.\n\nI can **build you a workout plan**, suggest "
               "**Indian-friendly meals**, explain your **improvement score**, "
               "or just give you a push when you need it.\n\n"
               "**What's on your mind?**",
    timestamp: DateTime.now(),
  );
}