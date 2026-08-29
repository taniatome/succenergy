/// Who wrote a message in a coaching conversation.
enum MessageAuthor { coach, user }

/// One message in the AI Coach conversation.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final MessageAuthor author;

  /// Locale code to message text.
  final Map<String, String> text;

  final DateTime sentAt;

  bool get isCoach => author == MessageAuthor.coach;

  /// The message body for [localeCode], falling back to English.
  String body(String localeCode) => text[localeCode] ?? text['en'] ?? '';
}
