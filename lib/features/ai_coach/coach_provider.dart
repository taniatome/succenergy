import 'package:flutter/foundation.dart';

import '../../core/network/request_guard.dart';

import '../../data/models/chat_message.dart';
import '../../data/repositories/coach_repository.dart';

/// Drives the AI Coach conversation.
///
/// Holds the messages, the thinking state that precedes a reply, and the
/// contextual suggestion chips.
class CoachProvider extends ChangeNotifier with RequestGuard {
  CoachProvider(this._coach);

  final CoachRepository _coach;

  List<ChatMessage> _messages = const <ChatMessage>[];
  List<String> _suggestionKeys = const <String>[];
  // Loading and failure state come from RequestGuard.
  bool _thinking = false;

  List<ChatMessage> get messages => _messages;

  List<String> get suggestionKeys => _suggestionKeys;

  bool get loading => isBusy;

  /// True while the coach composes a reply, which renders the dot indicator.
  bool get thinking => _thinking;

  /// Suggestions are offered only when the coach is waiting on the user.
  bool get showSuggestions =>
      !_thinking && _messages.isNotEmpty && _messages.last.isCoach;

  Future<void> load() async {
    await guard(() async {
      _messages = await _coach.loadConversation();
      _suggestionKeys = await _coach.loadSuggestionKeys();
    });
  }

  Future<void> send(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || _thinking) {
      return;
    }
    _thinking = true;
    _messages = <ChatMessage>[
      ..._messages,
      ChatMessage(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        author: MessageAuthor.user,
        text: <String, String>{'en': trimmed, 'pt': trimmed},
        sentAt: DateTime.now(),
      ),
    ];
    notifyListeners();

    // The thinking indicator is the progress here, so the loader stays off.
    // The flag is cleared in either outcome: a failed send that left it set
    // would lock the composer for the rest of the session.
    await guard(() async {
      await _coach.send(trimmed);
      _messages = await _coach.loadConversation();
    }, showLoading: false);

    _thinking = false;
    notifyListeners();
  }

  Future<void> startNewSession() async {
    _thinking = false;
    await guard(() async {
      await _coach.startNewSession();
      _messages = await _coach.loadConversation();
    });
  }
}
