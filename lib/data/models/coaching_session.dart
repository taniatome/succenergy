import 'chat_message.dart';
import 'principle.dart';

/// A past conversation with the coach, as listed on Coaching History.
class CoachingSession {
  const CoachingSession({
    required this.id,
    required this.startedAt,
    required this.durationMinutes,
    required this.principle,
    required this.summary,
    required this.messages,
  });

  final String id;
  final DateTime startedAt;
  final int durationMinutes;
  final Principle principle;

  /// Locale code to the one-line summary shown in the list.
  final Map<String, String> summary;

  final List<ChatMessage> messages;

  int get messageCount => messages.length;

  /// The summary line for [localeCode], falling back to English.
  String summaryFor(String localeCode) =>
      summary[localeCode] ?? summary['en'] ?? '';
}
