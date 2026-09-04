import '../models/chat_message.dart';
import '../models/coaching_session.dart';
import '../models/principle.dart';
import 'json_reader.dart';

/// Translates the session endpoints into the coach's models.
class CoachMapper {
  const CoachMapper._();

  static ChatMessage messageFromJson(Map<String, Object?> json) {
    return ChatMessage(
      id: Json.text(json['id']),
      author: Json.enumByName(
        json['author'],
        MessageAuthor.values,
        MessageAuthor.coach,
      ),
      text: Json.localized(json['text']),
      sentAt: Json.date(json['sentAt']),
    );
  }

  static List<ChatMessage> messagesFromJson(Object? value) {
    return Json.objects(value).map(messageFromJson).toList(growable: false);
  }

  /// A session. `messages` is present on detail and absent from the list, so
  /// an absent transcript becomes an empty one rather than a failure.
  static CoachingSession sessionFromJson(Map<String, Object?> json) {
    return CoachingSession(
      id: Json.text(json['id']),
      startedAt: Json.date(json['startedAt']),
      durationMinutes: Json.integer(json['durationMinutes']),
      principle: Json.enumByName(
        json['principle'],
        Principle.values,
        Principle.purpose,
      ),
      summary: Json.localized(json['summary']),
      messages: messagesFromJson(json['messages']),
    );
  }

  static List<CoachingSession> sessionsFromJson(Object? value) {
    return Json.objects(value).map(sessionFromJson).toList(growable: false);
  }

  /// The body `POST /v1/me/sessions/:id/messages` takes.
  ///
  /// The author is explicit because both sides of a conversation are written
  /// by the same authenticated caller — the person's turn, and the reply
  /// generated for them.
  static Map<String, Object?> messageBody({
    required MessageAuthor author,
    required String text,
  }) {
    return <String, Object?>{'author': author.name, 'text': text};
  }
}
