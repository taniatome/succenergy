import '../models/chat_message.dart';
import '../models/coaching_session.dart';

/// The AI Coach conversation and the sessions behind it.
abstract class CoachRepository {
  /// The current conversation, oldest message first.
  Future<List<ChatMessage>> loadConversation();

  /// Sends the user's message and resolves with the coach's reply.
  Future<ChatMessage> send(String text);

  /// Contextual reply chips, as localisation keys.
  Future<List<String>> loadSuggestionKeys();

  Future<List<CoachingSession>> loadSessions();

  Future<CoachingSession?> loadSession(String id);

  /// Clears the current conversation and opens a fresh one.
  Future<void> startNewSession();
}
