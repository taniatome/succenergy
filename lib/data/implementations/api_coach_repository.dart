import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/chat_message.dart';
import '../models/coaching_session.dart';
import '../repositories/coach_repository.dart';
import 'coach_mapper.dart';
import 'coach_reply_stub.dart';

/// The coach against `/v1/me/sessions`.
///
/// A hybrid, and deliberately so. The conversation, the transcript and the
/// session history are real — both sides of every turn are persisted, which
/// the mock never did, so closing the app no longer loses the conversation.
/// The reply itself still comes from [CoachReplyStub] on the device.
///
/// That is the whole remaining gap, and it is one call in one place: the
/// Claude pass replaces the `_replies.replyTo` line with a request and
/// deletes the stub. Nothing about the endpoints, the models or this class's
/// shape changes when it does.
class ApiCoachRepository implements CoachRepository {
  ApiCoachRepository(this._api);

  final ApiClient _api;
  final CoachReplyStub _replies = CoachReplyStub();

  static const String _path = '/me/sessions';

  /// The session being talked in. Resolved on first use and after a restart.
  String? _currentSessionId;

  /// The open session's id, opening one if there is none.
  ///
  /// `POST /v1/me/sessions` resumes the session already open rather than
  /// starting a second, so calling this repeatedly is safe and a relaunch
  /// picks the conversation back up instead of abandoning it.
  Future<String> _session() async {
    final String? known = _currentSessionId;
    if (known != null) {
      return known;
    }

    final Map<String, Object?> session = await _api.post(_path);
    final String id = CoachMapper.sessionFromJson(session).id;
    _currentSessionId = id;
    return id;
  }

  @override
  Future<List<ChatMessage>> loadConversation() async {
    final String sessionId = await _session();
    return CoachMapper.messagesFromJson(
      await _api.getAll('$_path/$sessionId/messages'),
    );
  }

  /// Stores the person's turn, then the reply, and answers with the reply.
  ///
  /// Two writes rather than one, in that order, so a transcript read between
  /// them shows the question waiting rather than an answer to nothing. It is
  /// also the shape the Claude pass needs: the reply cannot be stored until
  /// it has been generated, and generating it is what goes between these two
  /// calls.
  @override
  Future<ChatMessage> send(String text) async {
    final String sessionId = await _session();

    await _api.post(
      '$_path/$sessionId/messages',
      body: CoachMapper.messageBody(author: MessageAuthor.user, text: text),
    );

    final Map<String, String> reply = _replies.replyTo(text);

    final Map<String, Object?> stored = await _api.post(
      '$_path/$sessionId/messages',
      body: CoachMapper.messageBody(
        author: MessageAuthor.coach,
        // Stored in the language it was written, which for the stub is both.
        text: reply['en'] ?? '',
      ),
    );

    return CoachMapper.messageFromJson(stored);
  }

  /// Contextual reply chips.
  ///
  /// Localisation keys with no endpoint behind them: they are app copy, and
  /// the coach does not choose them. The Claude pass may make them dynamic;
  /// until then they are the same four the mock offered.
  @override
  Future<List<String>> loadSuggestionKeys() async {
    return const <String>[
      'coach.suggestion.stuck',
      'coach.suggestion.plan',
      'coach.suggestion.energy',
      'coach.suggestion.review',
    ];
  }

  @override
  Future<List<CoachingSession>> loadSessions() async {
    return CoachMapper.sessionsFromJson(await _api.getAll(_path));
  }

  @override
  Future<CoachingSession?> loadSession(String id) async {
    try {
      return CoachMapper.sessionFromJson(await _api.get('$_path/$id'));
    } on ApiException catch (error) {
      if (error.kind == ApiFailureKind.notFound) {
        return null;
      }
      rethrow;
    }
  }

  /// Ends the open session and opens a fresh one on the next message.
  ///
  /// The old conversation is closed rather than discarded — it becomes an
  /// entry in Coaching History, which is what that screen reads.
  @override
  Future<void> startNewSession() async {
    final String? open = _currentSessionId;
    if (open != null) {
      await _api.post('$_path/$open/end');
    }
    _currentSessionId = null;
  }
}
