import '../../models/chat_message.dart';
import '../../models/coaching_session.dart';
import '../../repositories/coach_repository.dart';
import '../mock_data.dart';

/// In-memory coach conversation.
///
/// Replies are drawn from a fixed set written in the Succenergy coaching
/// voice and matched to what the user said. They name the persona's real
/// goals, which is what makes the demo read as a coach that knows them.
class MockCoachRepository implements CoachRepository {
  final List<ChatMessage> _conversation = List<ChatMessage>.from(
    MockData.conversation,
  );
  int _replyCursor = 0;

  @override
  Future<List<ChatMessage>> loadConversation() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<ChatMessage>.unmodifiable(_conversation);
  }

  @override
  Future<ChatMessage> send(String text) async {
    _conversation.add(
      ChatMessage(
        id: 'msg-user-${DateTime.now().millisecondsSinceEpoch}',
        author: MessageAuthor.user,
        text: <String, String>{'en': text, 'pt': text},
        sentAt: DateTime.now(),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    final ChatMessage reply = ChatMessage(
      id: 'msg-coach-${DateTime.now().millisecondsSinceEpoch}',
      author: MessageAuthor.coach,
      text: _replyFor(text),
      sentAt: DateTime.now(),
    );
    _conversation.add(reply);
    return reply;
  }

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
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return MockData.sessions;
  }

  @override
  Future<CoachingSession?> loadSession(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final CoachingSession session in MockData.sessions) {
      if (session.id == id) {
        return session;
      }
    }
    return null;
  }

  @override
  Future<void> startNewSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _conversation
      ..clear()
      ..add(_opening);
    _replyCursor = 0;
  }

  Map<String, String> _replyFor(String text) {
    final String lower = text.toLowerCase();
    if (_matches(lower, const <String>['stuck', 'block', 'encrav', 'parad'])) {
      return _stuck;
    }
    if (_matches(lower, const <String>[
      'plan',
      'milestone',
      'marco',
      'divid',
      'break',
    ])) {
      return _plan;
    }
    if (_matches(lower, const <String>[
      'energy',
      'tired',
      'energia',
      'cansad',
      'baixo',
    ])) {
      return _energy;
    }
    if (_matches(lower, const <String>[
      'review',
      'cycle',
      'ciclo',
      'revej',
      'progress',
    ])) {
      return _review;
    }
    final Map<String, String> reply =
        _rotating[_replyCursor % _rotating.length];
    _replyCursor++;
    return reply;
  }

  bool _matches(String text, List<String> needles) =>
      needles.any((String n) => text.contains(n));

  static final ChatMessage _opening = ChatMessage(
    id: 'msg-open-${DateTime.now().millisecondsSinceEpoch}',
    author: MessageAuthor.coach,
    sentAt: DateTime.now(),
    text: const <String, String>{
      'en':
          'New session. You are in Praxis, day nineteen, with the Q4 relaunch open. Where do you want to start?',
      'pt':
          'Nova sessão. Está em Praxis, dia dezanove, com o relançamento Q4 em aberto. Por onde quer começar?',
    },
  );

  static const Map<String, String> _stuck = <String, String>{
    'en':
        'Stuck usually means the next step is too large to begin. On the Q4 relaunch the next step is one email to Aleixo. What is the ten-minute version of it you would send before lunch?',
    'pt':
        'Encravado quase sempre quer dizer que o passo seguinte é grande demais para começar. No relançamento Q4 o passo seguinte é um email ao Aleixo. Qual é a versão de dez minutos que enviaria antes do almoço?',
  };

  static const Map<String, String> _plan = <String, String>{
    'en':
        'Your next milestone is the internal preview, twelve days out. Work backwards from it. What has to be true four days before, and who needs to have seen it by then?',
    'pt':
        'O seu próximo marco é a apresentação interna, daqui a doze dias. Trabalhe de trás para a frente. O que tem de estar feito quatro dias antes, e quem precisa de o ter visto até lá?',
  };

  static const Map<String, String> _energy = <String, String>{
    'en':
        'Three weeks in, low energy is information rather than failure. Your deep work block held three days last week and none this week. Put tomorrow back at 07:30 and judge it on Thursday, not today.',
    'pt':
        'Ao fim de três semanas, energia em baixo é informação e não falhanço. O seu bloco de trabalho profundo aguentou três dias na semana passada e nenhum esta semana. Reponha o de amanhã às 07:30 e julgue-o na quinta, não hoje.',
  };

  static const Map<String, String> _review = <String, String>{
    'en':
        'Three weeks in you have closed one goal and reached seven milestones. You are in Praxis and holding there. The pattern is that you finish the work and then wait before showing it. What changes if showing it counts as finishing?',
    'pt':
        'Ao fim de três semanas fechou um objetivo e alcançou sete marcos. Está em Praxis e é aí que fica. O padrão é este: termina o trabalho e depois espera antes de o mostrar. O que muda se mostrar passar a contar como terminar?',
  };

  static const List<Map<String, String>> _rotating = <Map<String, String>>[
    <String, String>{
      'en':
          'Say more about that. What happened in the last two days that made it matter now?',
      'pt':
          'Diga-me mais sobre isso. O que aconteceu nos últimos dois dias que o tornou importante agora?',
    },
    <String, String>{
      'en':
          'That sounds like a decision you have already made and have not said out loud yet. What would you do if nobody needed to approve it?',
      'pt':
          'Isso parece uma decisão que já tomou e ainda não disse em voz alta. O que faria se ninguém tivesse de a aprovar?',
    },
    <String, String>{
      'en':
          'Hold that against the relaunch for a moment. Does it move the internal preview closer, or is it a second job pretending to be the first one?',
      'pt':
          'Compare isso com o relançamento por um momento. Aproxima a apresentação interna, ou é um segundo trabalho a fazer-se passar pelo primeiro?',
    },
    <String, String>{
      'en':
          'Good. Name the one thing you will have done by this time tomorrow, and make it small enough that a bad day cannot stop it.',
      'pt':
          'Bom. Diga uma coisa que estará feita a esta hora amanhã, e faça-a pequena o suficiente para que um dia mau não a impeça.',
    },
  ];
}
