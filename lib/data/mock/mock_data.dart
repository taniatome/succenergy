import '../../core/constants/app_constants.dart';
import '../models/action_item.dart';
import '../models/app_notification.dart';
import '../models/chat_message.dart';
import '../models/coaching_session.dart';
import '../models/exercise.dart';
import '../models/exercise_response.dart';
import '../models/exercise_step.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/onboarding_response.dart';
import '../models/principle.dart';
import '../models/progress_snapshot.dart';
import '../models/subscription_plan.dart';
import '../models/user.dart';

/// The single persona this build demonstrates.
///
/// Marisa Chissano is three weeks in, mid-cycle on Praxis, running a brand
/// relaunch. The same four goals, the same exercises and the same
/// conversation are referenced by every screen, so the demo reads as one
/// person's account rather than a set of unrelated samples.
class MockData {
  const MockData._();

  static final DateTime _today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  static DateTime daysAgo(int days) => _today.subtract(Duration(days: days));

  static DateTime daysAhead(int days) => _today.add(Duration(days: days));

  static DateTime hoursAgo(int hours) =>
      DateTime.now().subtract(Duration(hours: hours));

  // --- The person ---------------------------------------------------------

  static User get user => User(
    id: 'user-marisa',
    name: 'Marisa Chissano',
    email: 'marisa.chissano@lumeconsult.co.mz',
    joinedAt: daysAgo(21),
    currentPrinciple: Principle.praxis,
    cycleDay: 19,
    dayStreak: 12,
    tier: SubscriptionTier.professional,
    activity: UserActivity.professional,
    dateOfBirth: DateTime(1991, 4, 17),
    countryCode: 'MZ',
    tone: CoachingTone.direct,
    rhythm: CheckInRhythm.daily,
  );

  static OnboardingResponse get onboardingResponse => const OnboardingResponse(
    ambition: <String, String>{
      'en':
          'Run the Q4 relaunch myself, well enough that nobody has to check my work, and be given a team after it.',
      'pt':
          'Conduzir eu própria o relançamento do Q4, bem o suficiente para ninguém ter de rever o meu trabalho, e receber uma equipa depois disso.',
    },
    focusAreaKeys: <String>[
      'onboarding.option.career',
      'onboarding.option.confidence',
    ],
    challenge: <String, String>{
      'en':
          'I plan carefully and then hesitate before showing anything. The delay looks like thoroughness. It is not.',
      'pt':
          'Planeio com cuidado e depois hesito antes de mostrar seja o que for. O atraso parece rigor. Não é.',
    },
    priorityKeys: <String>[
      'onboarding.option.visibility',
      'onboarding.option.focus',
      'onboarding.option.team',
    ],
    mainGoals: <String, String>{
      'en':
          'Lead the relaunch end to end. Speak at the Leadership Forum in November. Stop losing my mornings.',
      'pt':
          'Liderar o relançamento do início ao fim. Falar no Fórum de Liderança em novembro. Parar de perder as minhas manhãs.',
    },
    motivationBalance: 0.35,
    successVision: <String, String>{
      'en':
          'A Tuesday where the hard work happens before ten, the relaunch is on track without me holding it together, and I said the thing in the room instead of writing it down afterwards.',
      'pt':
          'Uma terça-feira em que o trabalho difícil acontece antes das dez, o relançamento avança sem eu ter de o segurar, e em que disse a coisa na sala em vez de a escrever depois.',
    },
  );

  /// Saved answers to the five Purpose prompts, keyed by prompt id.
  static Map<String, Map<String, String>>
  get purposeAnswers => <String, Map<String, String>>{
    'talents': <String, String>{
      'en':
          'I can hear what a group is circling around and say it in one sentence. People relax when the thing is finally named.',
      'pt':
          'Consigo ouvir aquilo à volta do que um grupo anda a girar e dizê-lo numa frase. As pessoas descontraem quando a coisa é finalmente nomeada.',
    },
    'strengths': <String, String>{
      'en':
          'The rebrand two years ago. Small budget, short deadline, and I made every decision quickly because there was no room to hesitate.',
      'pt':
          'O rebranding há dois anos. Orçamento pequeno, prazo curto, e tomei todas as decisões depressa porque não havia espaço para hesitar.',
    },
    'values': <String, String>{
      'en':
          'I will not take credit that belongs to someone on my team, even when it would move me forward faster.',
      'pt':
          'Não fico com crédito que pertence a alguém da minha equipa, mesmo quando isso me faria avançar mais depressa.',
    },
  };

  // --- Goals --------------------------------------------------------------

  static List<Goal> get goals => <Goal>[
    Goal(
      id: 'goal-relaunch',
      title: <String, String>{
        'en': 'Lead the Q4 brand relaunch end to end',
        'pt': 'Liderar o relançamento da marca no Q4 do início ao fim',
      },
      why: <String, String>{
        'en':
            'If I run this one well, the leadership conversation stops being hypothetical.',
        'pt':
            'Se eu conduzir bem este, a conversa sobre liderança deixa de ser hipotética.',
      },
      principle: Principle.praxis,
      createdAt: daysAgo(19),
      targetDate: daysAhead(34),
      milestones: <Milestone>[
        Milestone(
          id: 'ms-relaunch-1',
          title: <String, String>{
            'en': 'Positioning brief signed off',
            'pt': 'Briefing de posicionamento aprovado',
          },
          dueDate: daysAgo(16),
          reachedAt: daysAgo(15),
        ),
        Milestone(
          id: 'ms-relaunch-2',
          title: <String, String>{
            'en': 'Creative route chosen with the agency',
            'pt': 'Rota criativa escolhida com a agência',
          },
          dueDate: daysAgo(9),
          reachedAt: daysAgo(8),
        ),
        Milestone(
          id: 'ms-relaunch-3',
          title: <String, String>{
            'en': 'Budget approved by finance',
            'pt': 'Orçamento aprovado pelas finanças',
          },
          dueDate: daysAgo(3),
          reachedAt: daysAgo(2),
        ),
        Milestone(
          id: 'ms-relaunch-4',
          title: <String, String>{
            'en': 'Internal preview delivered to the leadership team',
            'pt': 'Apresentação interna feita à equipa de liderança',
          },
          dueDate: daysAhead(12),
        ),
      ],
      actions: const <ActionItem>[
        ActionItem(
          id: 'act-relaunch-1',
          goalId: 'goal-relaunch',
          title: <String, String>{
            'en': 'Send the revised launch timeline to Aleixo for sign-off',
            'pt': 'Enviar o cronograma revisto ao Aleixo para aprovação',
          },
          isToday: true,
        ),
        ActionItem(
          id: 'act-relaunch-2',
          goalId: 'goal-relaunch',
          title: <String, String>{
            'en': 'Write the one-page story the sales team can repeat',
            'pt':
                'Escrever a página única que a equipa de vendas consegue repetir',
          },
          isDone: true,
        ),
        ActionItem(
          id: 'act-relaunch-3',
          goalId: 'goal-relaunch',
          title: <String, String>{
            'en': 'Cut the preview deck from twenty-two slides to nine',
            'pt': 'Cortar a apresentação de vinte e dois para nove slides',
          },
          isDone: true,
        ),
        ActionItem(
          id: 'act-relaunch-4',
          goalId: 'goal-relaunch',
          title: <String, String>{
            'en': 'Agree the one metric the relaunch will be judged on',
            'pt':
                'Definir a métrica única pela qual o relançamento será avaliado',
          },
        ),
        ActionItem(
          id: 'act-relaunch-5',
          goalId: 'goal-relaunch',
          title: <String, String>{
            'en': 'Book the preview room for the fourteenth',
            'pt': 'Reservar a sala da apresentação para o dia catorze',
          },
        ),
      ],
    ),
    Goal(
      id: 'goal-forum',
      title: <String, String>{
        'en': 'Speak at the Maputo Leadership Forum',
        'pt': 'Falar no Fórum de Liderança de Maputo',
      },
      why: <String, String>{
        'en':
            'I keep being the person who writes the words that someone else says out loud.',
        'pt':
            'Continuo a ser a pessoa que escreve as palavras que outra pessoa diz em voz alta.',
      },
      principle: Principle.passion,
      createdAt: daysAgo(17),
      targetDate: daysAhead(61),
      milestones: <Milestone>[
        Milestone(
          id: 'ms-forum-1',
          title: <String, String>{
            'en': 'Talk proposal submitted',
            'pt': 'Proposta de palestra submetida',
          },
          dueDate: daysAgo(12),
          reachedAt: daysAgo(11),
        ),
        Milestone(
          id: 'ms-forum-2',
          title: <String, String>{
            'en': 'The one idea the talk is built on, chosen',
            'pt': 'Escolhida a ideia única que sustenta a palestra',
          },
          dueDate: daysAgo(6),
          reachedAt: daysAgo(5),
        ),
        Milestone(
          id: 'ms-forum-3',
          title: <String, String>{
            'en': 'Talk drafted end to end',
            'pt': 'Palestra rascunhada do início ao fim',
          },
          dueDate: daysAhead(20),
        ),
        Milestone(
          id: 'ms-forum-4',
          title: <String, String>{
            'en': 'Run past two people who will be honest',
            'pt': 'Revista por duas pessoas que serão honestas',
          },
          dueDate: daysAhead(40),
        ),
      ],
      actions: const <ActionItem>[
        ActionItem(
          id: 'act-forum-1',
          goalId: 'goal-forum',
          title: <String, String>{
            'en': 'Record yourself telling the opening story once',
            'pt': 'Gravar-se a contar a história de abertura uma vez',
          },
        ),
        ActionItem(
          id: 'act-forum-2',
          goalId: 'goal-forum',
          title: <String, String>{
            'en': 'Ask Helena whether she will read a draft',
            'pt': 'Perguntar à Helena se lê um rascunho',
          },
          isDone: true,
        ),
        ActionItem(
          id: 'act-forum-3',
          goalId: 'goal-forum',
          title: <String, String>{
            'en': 'Block two hours on Saturday for the first draft',
            'pt': 'Reservar duas horas no sábado para o primeiro rascunho',
          },
        ),
      ],
    ),
    Goal(
      id: 'goal-deepwork',
      title: <String, String>{
        'en': 'Protect a 90-minute deep work block every weekday',
        'pt':
            'Proteger um bloco de 90 minutos de trabalho profundo em cada dia útil',
      },
      why: <String, String>{
        'en':
            'Everything I am proud of was made before ten in the morning. I keep giving that hour away.',
        'pt':
            'Tudo aquilo de que me orgulho foi feito antes das dez da manhã. Continuo a dar essa hora aos outros.',
      },
      principle: Principle.persistence,
      createdAt: daysAgo(15),
      targetDate: daysAhead(45),
      milestones: <Milestone>[
        Milestone(
          id: 'ms-deep-1',
          title: <String, String>{
            'en': 'Two people know not to book over it',
            'pt': 'Duas pessoas sabem que não devem marcar por cima',
          },
          dueDate: daysAgo(7),
          reachedAt: daysAgo(6),
        ),
        Milestone(
          id: 'ms-deep-2',
          title: <String, String>{
            'en': 'Held three days in one week',
            'pt': 'Cumprido três dias numa semana',
          },
          dueDate: daysAhead(6),
        ),
        Milestone(
          id: 'ms-deep-3',
          title: <String, String>{
            'en': 'Held five days in one week',
            'pt': 'Cumprido cinco dias numa semana',
          },
          dueDate: daysAhead(20),
        ),
        Milestone(
          id: 'ms-deep-4',
          title: <String, String>{
            'en': 'Held four weeks running',
            'pt': 'Cumprido quatro semanas seguidas',
          },
          dueDate: daysAhead(44),
        ),
      ],
      actions: const <ActionItem>[
        ActionItem(
          id: 'act-deep-1',
          goalId: 'goal-deepwork',
          title: <String, String>{
            'en': 'Move the block to 07:30 and see whether it survives',
            'pt': 'Mudar o bloco para as 07:30 e ver se sobrevive',
          },
        ),
        ActionItem(
          id: 'act-deep-2',
          goalId: 'goal-deepwork',
          title: <String, String>{
            'en': 'Silence notifications for the block window',
            'pt': 'Silenciar as notificações durante o bloco',
          },
          isDone: true,
        ),
        ActionItem(
          id: 'act-deep-3',
          goalId: 'goal-deepwork',
          title: <String, String>{
            'en': 'Tell the team what the block is actually for',
            'pt': 'Dizer à equipa para que serve mesmo o bloco',
          },
        ),
      ],
    ),
    Goal(
      id: 'goal-designer',
      title: <String, String>{
        'en': 'Hire and onboard the second designer',
        'pt': 'Contratar e integrar o segundo designer',
      },
      why: <String, String>{
        'en':
            'I cannot lead a relaunch and be the only person who can open the files.',
        'pt':
            'Não posso liderar um relançamento e ser a única pessoa capaz de abrir os ficheiros.',
      },
      principle: Principle.planning,
      createdAt: daysAgo(20),
      targetDate: daysAgo(5),
      completedAt: daysAgo(6),
      milestones: <Milestone>[
        Milestone(
          id: 'ms-des-1',
          title: <String, String>{
            'en': 'Role written in plain language and posted',
            'pt': 'Vaga escrita em linguagem simples e publicada',
          },
          dueDate: daysAgo(18),
          reachedAt: daysAgo(18),
        ),
        Milestone(
          id: 'ms-des-2',
          title: <String, String>{
            'en': 'Shortlist down to three',
            'pt': 'Lista curta reduzida a três',
          },
          dueDate: daysAgo(14),
          reachedAt: daysAgo(13),
        ),
        Milestone(
          id: 'ms-des-3',
          title: <String, String>{
            'en': 'Offer accepted',
            'pt': 'Proposta aceite',
          },
          dueDate: daysAgo(10),
          reachedAt: daysAgo(9),
        ),
        Milestone(
          id: 'ms-des-4',
          title: <String, String>{
            'en': 'First week planned to the day',
            'pt': 'Primeira semana planeada ao dia',
          },
          dueDate: daysAgo(6),
          reachedAt: daysAgo(6),
        ),
      ],
      actions: const <ActionItem>[
        ActionItem(
          id: 'act-des-1',
          goalId: 'goal-designer',
          title: <String, String>{
            'en': 'Write the role without a single piece of jargon',
            'pt': 'Escrever a vaga sem uma única palavra de jargão',
          },
          isDone: true,
        ),
        ActionItem(
          id: 'act-des-2',
          goalId: 'goal-designer',
          title: <String, String>{
            'en': 'Agree the salary band with finance before posting',
            'pt': 'Acordar a banda salarial com as finanças antes de publicar',
          },
          isDone: true,
        ),
        ActionItem(
          id: 'act-des-3',
          goalId: 'goal-designer',
          title: <String, String>{
            'en': 'Plan the first week hour by hour',
            'pt': 'Planear a primeira semana hora a hora',
          },
          isDone: true,
        ),
      ],
    ),
  ];

  // --- Exercise library ---------------------------------------------------

  static List<Exercise> get exercises => <Exercise>[
    Exercise(
      id: 'ex-sentence-test',
      principle: Principle.purpose,
      title: <String, String>{
        'en': 'The Sentence Test',
        'pt': 'O Teste da Frase',
      },
      summary: <String, String>{
        'en': 'Reduce what you are doing to one sentence you would defend.',
        'pt': 'Reduza o que anda a fazer a uma frase que defenderia.',
      },
      durationMinutes: 8,
      completedAt: daysAgo(16),
      suggestedAction: <String, String>{
        'en': 'Say your sentence out loud to one person this week',
        'pt': 'Diga a sua frase em voz alta a uma pessoa esta semana',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'Why are you doing the work you are doing right now?',
            'pt': 'Porque está a fazer o trabalho que faz neste momento?',
          },
          help: <String, String>{
            'en': 'One sentence. If it needs a comma, it needs cutting.',
            'pt': 'Uma frase. Se precisa de vírgula, precisa de corte.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.singleChoice,
          prompt: <String, String>{
            'en': 'Read it back. Whose sentence is it?',
            'pt': 'Releia. De quem é a frase?',
          },
          help: <String, String>{
            'en': 'Answer before you decide what the right answer is.',
            'pt': 'Responda antes de decidir qual é a resposta certa.',
          },
          options: <Map<String, String>>[
            <String, String>{'en': 'Mine', 'pt': 'Minha'},
            <String, String>{
              'en': 'Someone I admire',
              'pt': 'De alguém que admiro',
            },
            <String, String>{
              'en': 'My employer',
              'pt': 'Da minha entidade patronal',
            },
            <String, String>{
              'en': 'I am not sure yet',
              'pt': 'Ainda não tenho a certeza',
            },
          ],
        ),
        ExerciseStep(
          id: 'st-3',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'Rewrite it so it could only have come from you.',
            'pt': 'Reescreva-a para que só pudesse ter vindo de si.',
          },
          help: <String, String>{
            'en': 'Keep the part that would embarrass you slightly.',
            'pt': 'Mantenha a parte que o embaraçaria ligeiramente.',
          },
        ),
      ],
    ),
    Exercise(
      id: 'ex-not-trade',
      principle: Principle.purpose,
      title: <String, String>{
        'en': 'What You Would Not Trade',
        'pt': 'O Que Não Trocaria',
      },
      summary: <String, String>{
        'en': 'Find the line you will not cross, before you are asked to.',
        'pt': 'Encontre o limite que não ultrapassa, antes de lho pedirem.',
      },
      durationMinutes: 6,
      suggestedAction: <String, String>{
        'en': 'Write the line down where you will see it on a hard week',
        'pt': 'Escreva o limite onde o verá numa semana difícil',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'Name a result you want badly.',
            'pt': 'Nomeie um resultado que deseja muito.',
          },
          help: <String, String>{
            'en': 'The real one, not the presentable one.',
            'pt': 'O verdadeiro, não o apresentável.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What would you refuse to give up to get it?',
            'pt': 'O que se recusaria a abdicar para o conseguir?',
          },
          help: <String, String>{
            'en': 'That refusal is a value. It is worth naming precisely.',
            'pt': 'Essa recusa é um valor. Vale a pena nomeá-la com precisão.',
          },
        ),
        ExerciseStep(
          id: 'st-3',
          type: ExerciseStepType.scale,
          prompt: <String, String>{
            'en': 'How close have you come to trading it recently?',
            'pt': 'Quão perto esteve de a trocar recentemente?',
          },
          help: <String, String>{
            'en': 'An honest answer here is more useful than a good one.',
            'pt': 'Uma resposta honesta aqui vale mais do que uma boa.',
          },
          scaleLowLabel: <String, String>{'en': 'Never', 'pt': 'Nunca'},
          scaleHighLabel: <String, String>{
            'en': 'Last week',
            'pt': 'Na semana passada',
          },
        ),
      ],
    ),
    Exercise(
      id: 'ex-energy-audit',
      principle: Principle.passion,
      title: <String, String>{
        'en': 'Energy Audit',
        'pt': 'Auditoria de Energia',
      },
      summary: <String, String>{
        'en': 'Separate what drains you from what you simply dislike.',
        'pt': 'Separe o que o esgota do que apenas não gosta de fazer.',
      },
      durationMinutes: 10,
      completedAt: daysAgo(12),
      suggestedAction: <String, String>{
        'en': 'Move one draining task to the hour you have most energy',
        'pt': 'Mova uma tarefa desgastante para a hora de maior energia',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'Which part of last week left you with more energy?',
            'pt': 'Que parte da semana passada lhe deixou mais energia?',
          },
          help: <String, String>{
            'en': 'Look for the hour you did not notice passing.',
            'pt': 'Procure a hora que não deu por passar.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'Which part took the most out of you?',
            'pt': 'Que parte lhe tirou mais?',
          },
          help: <String, String>{
            'en': 'Be specific about the moment, not the category.',
            'pt': 'Seja concreto quanto ao momento, não a categoria.',
          },
        ),
        ExerciseStep(
          id: 'st-3',
          type: ExerciseStepType.singleChoice,
          prompt: <String, String>{
            'en': 'Is that drain about the task, or about the conditions?',
            'pt': 'Esse desgaste vem da tarefa ou das condições?',
          },
          help: <String, String>{
            'en': 'Conditions can be changed far more easily than work.',
            'pt': 'As condições mudam-se muito mais facilmente que o trabalho.',
          },
          options: <Map<String, String>>[
            <String, String>{'en': 'The task itself', 'pt': 'A própria tarefa'},
            <String, String>{'en': 'The timing', 'pt': 'O momento do dia'},
            <String, String>{
              'en': 'The people involved',
              'pt': 'As pessoas envolvidas',
            },
            <String, String>{
              'en': 'The lack of a decision',
              'pt': 'A falta de uma decisão',
            },
          ],
        ),
      ],
    ),
    Exercise(
      id: 'ex-reverse-calendar',
      principle: Principle.planning,
      title: <String, String>{
        'en': 'Reverse the Calendar',
        'pt': 'Inverter o Calendário',
      },
      summary: <String, String>{
        'en': 'Work backwards from the date until the first step is obvious.',
        'pt': 'Trabalhe de trás para a frente até o primeiro passo ser óbvio.',
      },
      durationMinutes: 12,
      completedAt: daysAgo(9),
      suggestedAction: <String, String>{
        'en': 'Put the first backwards step in the calendar today',
        'pt': 'Coloque o primeiro passo invertido no calendário hoje',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What is the date, and what has to be true by then?',
            'pt': 'Qual é a data, e o que tem de estar feito até lá?',
          },
          help: <String, String>{
            'en': 'A date without a condition is a wish.',
            'pt': 'Uma data sem condição é um desejo.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What has to be finished two weeks before that?',
            'pt': 'O que tem de estar terminado duas semanas antes disso?',
          },
          help: <String, String>{
            'en': 'Keep stepping backwards until the step takes one morning.',
            'pt': 'Recue até o passo caber numa manhã.',
          },
        ),
        ExerciseStep(
          id: 'st-3',
          type: ExerciseStepType.scale,
          prompt: <String, String>{
            'en': 'How much slack is in the last fortnight of that plan?',
            'pt': 'Quanta folga existe na última quinzena desse plano?',
          },
          help: <String, String>{
            'en': 'No slack is a plan that only works if nothing happens.',
            'pt': 'Sem folga, o plano só funciona se nada acontecer.',
          },
          scaleLowLabel: <String, String>{'en': 'None', 'pt': 'Nenhuma'},
          scaleHighLabel: <String, String>{
            'en': 'Comfortable',
            'pt': 'Confortável',
          },
        ),
      ],
    ),
    Exercise(
      id: 'ex-smallest-step',
      principle: Principle.planning,
      title: <String, String>{
        'en': 'The Smallest Next Step',
        'pt': 'O Passo Seguinte Mais Pequeno',
      },
      summary: <String, String>{
        'en': 'Shrink the next move until refusing it would be absurd.',
        'pt': 'Encolha o próximo passo até recusá-lo ser absurdo.',
      },
      durationMinutes: 5,
      suggestedAction: <String, String>{
        'en': 'Do the shrunken step before you close the app',
        'pt': 'Faça o passo encolhido antes de fechar a aplicação',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What have you been postponing?',
            'pt': 'O que tem andado a adiar?',
          },
          help: <String, String>{
            'en': 'The one you thought of first.',
            'pt': 'Aquilo em que pensou primeiro.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'Write the version of it that takes ten minutes.',
            'pt': 'Escreva a versão disso que demora dez minutos.',
          },
          help: <String, String>{
            'en': 'Not the whole thing. The part that unlocks the rest.',
            'pt': 'Não a coisa toda. A parte que destranca o resto.',
          },
        ),
      ],
    ),
    Exercise(
      id: 'ex-one-real-hour',
      principle: Principle.praxis,
      title: <String, String>{'en': 'One Real Hour', 'pt': 'Uma Hora a Sério'},
      summary: <String, String>{
        'en': 'Put the plan in front of reality before it is ready.',
        'pt': 'Ponha o plano diante da realidade antes de estar pronto.',
      },
      durationMinutes: 7,
      completedAt: daysAgo(3),
      suggestedAction: <String, String>{
        'en': 'Show the unfinished version to one person today',
        'pt': 'Mostre a versão inacabada a uma pessoa hoje',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What are you holding back until it is finished?',
            'pt': 'O que está a reter até estar terminado?',
          },
          help: <String, String>{
            'en': 'Praxis is contact with reality, not readiness.',
            'pt': 'Praxis é contacto com a realidade, não prontidão.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.singleChoice,
          prompt: <String, String>{
            'en': 'What is the delay actually protecting?',
            'pt': 'O que é que o atraso está mesmo a proteger?',
          },
          help: <String, String>{
            'en': 'Name it and it loses most of its weight.',
            'pt': 'Nomeie-o e perde a maior parte do peso.',
          },
          options: <Map<String, String>>[
            <String, String>{
              'en': 'How I will be judged',
              'pt': 'Como serei julgada',
            },
            <String, String>{
              'en': 'The quality of the work',
              'pt': 'A qualidade do trabalho',
            },
            <String, String>{
              'en': 'Someone else on the team',
              'pt': 'Outra pessoa da equipa',
            },
            <String, String>{
              'en': 'Nothing, honestly',
              'pt': 'Nada, na verdade',
            },
          ],
        ),
        ExerciseStep(
          id: 'st-3',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'Who sees it today, and what will you ask them?',
            'pt': 'Quem o vê hoje, e o que lhes vai perguntar?',
          },
          help: <String, String>{
            'en': 'One question gets a useful answer. Three get politeness.',
            'pt': 'Uma pergunta traz resposta útil. Três trazem cortesia.',
          },
        ),
      ],
    ),
    Exercise(
      id: 'ex-cost-of-stopping',
      principle: Principle.persistence,
      title: <String, String>{
        'en': 'The Cost of Stopping',
        'pt': 'O Custo de Parar',
      },
      summary: <String, String>{
        'en': 'Price the quiet decision to let something lapse.',
        'pt': 'Ponha um preço na decisão silenciosa de deixar cair algo.',
      },
      durationMinutes: 9,
      suggestedAction: <String, String>{
        'en': 'Restart the lapsed habit tomorrow, at half the size',
        'pt': 'Retome amanhã o hábito interrompido, com metade do tamanho',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What did you start and quietly stop?',
            'pt': 'O que começou e parou sem dizer nada?',
          },
          help: <String, String>{
            'en': 'Nobody announces stopping. That is why it works.',
            'pt': 'Ninguém anuncia que parou. É por isso que resulta.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.scale,
          prompt: <String, String>{
            'en': 'If it stays stopped for a year, how much does it cost you?',
            'pt': 'Se ficar parado um ano, quanto lhe custa?',
          },
          help: <String, String>{
            'en': 'Persistence starts with an honest price.',
            'pt': 'A persistência começa com um preço honesto.',
          },
          scaleLowLabel: <String, String>{
            'en': 'Very little',
            'pt': 'Muito pouco',
          },
          scaleHighLabel: <String, String>{
            'en': 'A great deal',
            'pt': 'Imenso',
          },
        ),
        ExerciseStep(
          id: 'st-3',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What is the half-sized version you would still do tired?',
            'pt': 'Qual é a versão a metade que faria mesmo cansada?',
          },
          help: <String, String>{
            'en': 'Persistence is built at the size you can keep.',
            'pt': 'A persistência constrói-se no tamanho que consegue manter.',
          },
        ),
      ],
    ),
    Exercise(
      id: 'ex-what-moved',
      principle: Principle.progress,
      title: <String, String>{
        'en': 'What Actually Moved',
        'pt': 'O Que Se Moveu Mesmo',
      },
      summary: <String, String>{
        'en': 'Separate the week you felt from the week you had.',
        'pt': 'Separe a semana que sentiu da semana que teve.',
      },
      durationMinutes: 6,
      completedAt: daysAgo(1),
      suggestedAction: <String, String>{
        'en': 'Tell one person the thing that moved this week',
        'pt': 'Conte a uma pessoa o que se moveu esta semana',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What is measurably further along than seven days ago?',
            'pt': 'O que está mensuravelmente mais adiantado que há sete dias?',
          },
          help: <String, String>{
            'en': 'Something someone else could verify.',
            'pt': 'Algo que outra pessoa pudesse verificar.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.scale,
          prompt: <String, String>{
            'en': 'How closely does that match how the week felt?',
            'pt': 'Quão próximo isso está do que a semana pareceu?',
          },
          help: <String, String>{
            'en': 'A gap in either direction is worth knowing about.',
            'pt': 'Uma diferença em qualquer sentido vale a pena conhecer.',
          },
          scaleLowLabel: <String, String>{
            'en': 'Felt much worse',
            'pt': 'Pareceu bem pior',
          },
          scaleHighLabel: <String, String>{
            'en': 'Felt much better',
            'pt': 'Pareceu bem melhor',
          },
        ),
      ],
    ),
    Exercise(
      id: 'ex-close-the-loop',
      principle: Principle.perfection,
      title: <String, String>{'en': 'Close the Loop', 'pt': 'Fechar o Ciclo'},
      summary: <String, String>{
        'en': 'Finish properly so the next cycle starts on firm ground.',
        'pt': 'Termine bem para o próximo ciclo começar em terreno firme.',
      },
      durationMinutes: 11,
      suggestedAction: <String, String>{
        'en': 'Write the one line you want to carry into the next cycle',
        'pt': 'Escreva a linha que quer levar para o próximo ciclo',
      },
      steps: <ExerciseStep>[
        ExerciseStep(
          id: 'st-1',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What is finished, and how do you know?',
            'pt': 'O que está terminado, e como é que sabe?',
          },
          help: <String, String>{
            'en': 'Perfection is closing well, not doing more.',
            'pt': 'Perfection é fechar bem, não fazer mais.',
          },
        ),
        ExerciseStep(
          id: 'st-2',
          type: ExerciseStepType.freeText,
          prompt: <String, String>{
            'en': 'What would you do differently if it began again tomorrow?',
            'pt': 'O que faria de outra forma se recomeçasse amanhã?',
          },
          help: <String, String>{
            'en': 'One change. The one you would actually make.',
            'pt': 'Uma mudança. Aquela que faria mesmo.',
          },
        ),
        ExerciseStep(
          id: 'st-3',
          type: ExerciseStepType.singleChoice,
          prompt: <String, String>{
            'en': 'What does the next cycle need to begin with?',
            'pt': 'Com o que precisa de começar o próximo ciclo?',
          },
          help: <String, String>{
            'en': 'The cycle turns whether or not you choose. Choose.',
            'pt': 'O ciclo vira quer escolha quer não. Escolha.',
          },
          options: <Map<String, String>>[
            <String, String>{
              'en': 'A clearer reason',
              'pt': 'Uma razão mais clara',
            },
            <String, String>{
              'en': 'A smaller plan',
              'pt': 'Um plano mais pequeno',
            },
            <String, String>{
              'en': 'More contact with reality',
              'pt': 'Mais contacto com a realidade',
            },
            <String, String>{
              'en': 'More rest first',
              'pt': 'Mais descanso antes',
            },
          ],
        ),
      ],
    ),
  ];

  /// Saved answers for the exercises already completed.
  static Map<String, List<ExerciseResponse>>
  get exerciseResponses => <String, List<ExerciseResponse>>{
    'ex-sentence-test': <ExerciseResponse>[
      ExerciseResponse(
        exerciseId: 'ex-sentence-test',
        stepId: 'st-1',
        value:
            'I make complicated work understandable so that other people can act on it.',
        answeredAt: daysAgo(16),
      ),
      ExerciseResponse(
        exerciseId: 'ex-sentence-test',
        stepId: 'st-2',
        value: 'Mine',
        answeredAt: daysAgo(16),
      ),
      ExerciseResponse(
        exerciseId: 'ex-sentence-test',
        stepId: 'st-3',
        value:
            'I name the thing a room is circling around, and then I make it possible to do.',
        answeredAt: daysAgo(16),
      ),
    ],
    'ex-energy-audit': <ExerciseResponse>[
      ExerciseResponse(
        exerciseId: 'ex-energy-audit',
        stepId: 'st-1',
        value:
            'Thursday morning with the agency. Two hours felt like twenty minutes.',
        answeredAt: daysAgo(12),
      ),
      ExerciseResponse(
        exerciseId: 'ex-energy-audit',
        stepId: 'st-2',
        value:
            'The Monday status call. Nothing is decided and everyone repeats themselves.',
        answeredAt: daysAgo(12),
      ),
      ExerciseResponse(
        exerciseId: 'ex-energy-audit',
        stepId: 'st-3',
        value: 'The lack of a decision',
        answeredAt: daysAgo(12),
      ),
    ],
    'ex-reverse-calendar': <ExerciseResponse>[
      ExerciseResponse(
        exerciseId: 'ex-reverse-calendar',
        stepId: 'st-1',
        value:
            'Launch day. The story, the assets and the sales one-pager all signed off.',
        answeredAt: daysAgo(9),
      ),
      ExerciseResponse(
        exerciseId: 'ex-reverse-calendar',
        stepId: 'st-2',
        value: 'The internal preview, with the leadership team in the room.',
        answeredAt: daysAgo(9),
      ),
      ExerciseResponse(
        exerciseId: 'ex-reverse-calendar',
        stepId: 'st-3',
        value: 'Almost none',
        answeredAt: daysAgo(9),
      ),
    ],
    'ex-one-real-hour': <ExerciseResponse>[
      ExerciseResponse(
        exerciseId: 'ex-one-real-hour',
        stepId: 'st-1',
        value: 'The launch timeline. It has been ready since Tuesday.',
        answeredAt: daysAgo(3),
      ),
      ExerciseResponse(
        exerciseId: 'ex-one-real-hour',
        stepId: 'st-2',
        value: 'How I will be judged',
        answeredAt: daysAgo(3),
      ),
      ExerciseResponse(
        exerciseId: 'ex-one-real-hour',
        stepId: 'st-3',
        value:
            'Aleixo. I will ask him what moves if the preview slips three days.',
        answeredAt: daysAgo(3),
      ),
    ],
    'ex-what-moved': <ExerciseResponse>[
      ExerciseResponse(
        exerciseId: 'ex-what-moved',
        stepId: 'st-1',
        value: 'Budget approved, and the deck is down to nine slides.',
        answeredAt: daysAgo(1),
      ),
      ExerciseResponse(
        exerciseId: 'ex-what-moved',
        stepId: 'st-2',
        value: 'Felt much worse',
        answeredAt: daysAgo(1),
      ),
    ],
  };

  // --- The current coach conversation -------------------------------------

  static List<ChatMessage> get conversation => <ChatMessage>[
    ChatMessage(
      id: 'msg-1',
      author: MessageAuthor.coach,
      sentAt: hoursAgo(4),
      text: <String, String>{
        'en':
            'You closed the budget milestone on the Q4 relaunch two days ago, and then the app went quiet. What happened after that?',
        'pt':
            'Fechou o marco do orçamento no relançamento Q4 há dois dias, e depois a aplicação ficou em silêncio. O que aconteceu a seguir?',
      },
    ),
    ChatMessage(
      id: 'msg-2',
      author: MessageAuthor.user,
      sentAt: hoursAgo(4),
      text: <String, String>{
        'en':
            'Three other things landed. The launch timeline is still sitting in my drafts.',
        'pt':
            'Cairam-me três outras coisas em cima. O cronograma de lançamento continua nos rascunhos.',
      },
    ),
    ChatMessage(
      id: 'msg-3',
      author: MessageAuthor.coach,
      sentAt: hoursAgo(4),
      text: <String, String>{
        'en':
            'So the work is done and the sending is what stalled. That is a different problem from being behind. What is making you hold it?',
        'pt':
            'Então o trabalho está feito e o que encravou foi enviar. Isso é um problema diferente de estar atrasada. O que a faz segurá-lo?',
      },
    ),
    ChatMessage(
      id: 'msg-4',
      author: MessageAuthor.user,
      sentAt: hoursAgo(3),
      text: <String, String>{
        'en': 'I want it to be right before Aleixo sees it.',
        'pt': 'Quero que esteja certo antes de o Aleixo o ver.',
      },
    ),
    ChatMessage(
      id: 'msg-5',
      author: MessageAuthor.coach,
      sentAt: hoursAgo(3),
      text: <String, String>{
        'en':
            'Perfection is the seventh principle, not the fourth. You are in Praxis. Praxis puts the work in front of someone at real size and lets it be corrected. Send the timeline today with the unfinished parts marked as unfinished.',
        'pt':
            'Perfection é o sétimo princípio, não o quarto. Está em Praxis. Praxis põe o trabalho à frente de alguém em tamanho real e deixa que seja corrigido. Envie hoje o cronograma com as partes por acabar assinaladas como tal.',
      },
    ),
    ChatMessage(
      id: 'msg-6',
      author: MessageAuthor.user,
      sentAt: hoursAgo(3),
      text: <String, String>{
        'en': 'That is uncomfortable.',
        'pt': 'Isso é desconfortável.',
      },
    ),
    ChatMessage(
      id: 'msg-7',
      author: MessageAuthor.coach,
      sentAt: hoursAgo(3),
      text: <String, String>{
        'en':
            'It should be. It is also the fastest way to find out whether the plan holds. Which section are you least sure about?',
        'pt':
            'E deve ser. Também é a via mais rápida para saber se o plano aguenta. De que secção tem menos certeza?',
      },
    ),
    ChatMessage(
      id: 'msg-8',
      author: MessageAuthor.user,
      sentAt: hoursAgo(2),
      text: <String, String>{
        'en': 'The two weeks before launch. There is no slack in there at all.',
        'pt':
            'As duas semanas antes do lançamento. Não há folga nenhuma ali dentro.',
      },
    ),
    ChatMessage(
      id: 'msg-9',
      author: MessageAuthor.coach,
      sentAt: hoursAgo(2),
      text: <String, String>{
        'en':
            'Then flag those two weeks in the note you send. Ask Aleixo one question: what moves if the internal preview slips by three days. His answer will teach you more than another edit will.',
        'pt':
            'Então assinale essas duas semanas na nota que enviar. Faça ao Aleixo uma pergunta: o que muda se a apresentação interna escorregar três dias. A resposta dele ensina-lhe mais do que outra revisão.',
      },
    ),
    ChatMessage(
      id: 'msg-10',
      author: MessageAuthor.user,
      sentAt: hoursAgo(2),
      text: <String, String>{
        'en': 'I can do that this morning.',
        'pt': 'Posso fazer isso esta manhã.',
      },
    ),
    ChatMessage(
      id: 'msg-11',
      author: MessageAuthor.coach,
      sentAt: hoursAgo(2),
      text: <String, String>{
        'en':
            'Good. One more thing, and then I will leave you to it. Your deep work block held three days last week and none this week. The relaunch is the reason. That is a fair trade for one week. It is not a fair trade for three.',
        'pt':
            'Bom. Mais uma coisa, e depois deixo-a trabalhar. O seu bloco de trabalho profundo aguentou três dias na semana passada e nenhum esta semana. O relançamento e a razão. É uma troca justa por uma semana. Não é por três.',
      },
    ),
    ChatMessage(
      id: 'msg-12',
      author: MessageAuthor.coach,
      sentAt: hoursAgo(2),
      text: <String, String>{
        'en':
            'Send the timeline, then put tomorrow back at 07:30. Tell me on Thursday whether it survived.',
        'pt':
            'Envie o cronograma e reponha o de amanhã às 07:30. Diga-me na quinta se sobreviveu.',
      },
    ),
  ];

  // --- Past sessions ------------------------------------------------------

  static List<CoachingSession> get sessions => <CoachingSession>[
    CoachingSession(
      id: 'ses-1',
      startedAt: daysAgo(5),
      durationMinutes: 18,
      principle: Principle.praxis,
      summary: <String, String>{
        'en':
            'Where the relaunch actually stands, once the optimism was removed.',
        'pt': 'Onde o relançamento está mesmo, depois de retirado o otimismo.',
      },
      messages: <ChatMessage>[
        ChatMessage(
          id: 'ses1-m1',
          author: MessageAuthor.coach,
          sentAt: daysAgo(5),
          text: <String, String>{
            'en':
                'Give me the relaunch status as you would give it to someone who cannot help you.',
            'pt':
                'Dê-me o estado do relançamento como o daria a alguém que não a pode ajudar.',
          },
        ),
        ChatMessage(
          id: 'ses1-m2',
          author: MessageAuthor.user,
          sentAt: daysAgo(5),
          text: <String, String>{
            'en':
                'Positioning done, creative route chosen, budget still with finance.',
            'pt':
                'Posicionamento feito, rota criativa escolhida, orçamento ainda nas finanças.',
          },
        ),
        ChatMessage(
          id: 'ses1-m3',
          author: MessageAuthor.coach,
          sentAt: daysAgo(5),
          text: <String, String>{
            'en':
                'Two of those are yours and one is not. Which of the two have you stopped moving while you wait for finance?',
            'pt':
                'Dois desses são seus e um não é. Qual dos dois deixou de mover enquanto espera pelas finanças?',
          },
        ),
        ChatMessage(
          id: 'ses1-m4',
          author: MessageAuthor.user,
          sentAt: daysAgo(5),
          text: <String, String>{
            'en': 'The deck. I told myself the budget changes it. It does not.',
            'pt':
                'A apresentação. Disse a mim mesma que o orçamento a muda. Não muda.',
          },
        ),
      ],
    ),
    CoachingSession(
      id: 'ses-2',
      startedAt: daysAgo(9),
      durationMinutes: 24,
      principle: Principle.passion,
      summary: <String, String>{
        'en': 'Why the Forum talk keeps being postponed to a calmer week.',
        'pt':
            'Porque a palestra do Fórum é sempre adiada para uma semana mais calma.',
      },
      messages: <ChatMessage>[
        ChatMessage(
          id: 'ses2-m1',
          author: MessageAuthor.coach,
          sentAt: daysAgo(9),
          text: <String, String>{
            'en':
                'The talk has moved three times. Each time to a calmer week. Have you had one?',
            'pt':
                'A palestra mudou três vezes. Sempre para uma semana mais calma. Já teve alguma?',
          },
        ),
        ChatMessage(
          id: 'ses2-m2',
          author: MessageAuthor.user,
          sentAt: daysAgo(9),
          text: <String, String>{'en': 'No.', 'pt': 'Não.'},
        ),
        ChatMessage(
          id: 'ses2-m3',
          author: MessageAuthor.coach,
          sentAt: daysAgo(9),
          text: <String, String>{
            'en':
                'Then the calm week is not the condition. Something else is. What do you think happens when you stand up and say it yourself?',
            'pt':
                'Então a semana calma não é a condição. Outra coisa é. O que pensa que acontece quando se levanta e o diz na primeira pessoa?',
          },
        ),
        ChatMessage(
          id: 'ses2-m4',
          author: MessageAuthor.user,
          sentAt: daysAgo(9),
          text: <String, String>{
            'en':
                'That someone in the room knows more than me and everyone can tell.',
            'pt':
                'Que alguém na sala sabe mais do que eu e que toda a gente percebe.',
          },
        ),
      ],
    ),
    CoachingSession(
      id: 'ses-3',
      startedAt: daysAgo(13),
      durationMinutes: 15,
      principle: Principle.planning,
      summary: <String, String>{
        'en': 'Cutting the plan down to the part you will actually do.',
        'pt': 'Reduzir o plano à parte que vai mesmo fazer.',
      },
      messages: <ChatMessage>[
        ChatMessage(
          id: 'ses3-m1',
          author: MessageAuthor.coach,
          sentAt: daysAgo(13),
          text: <String, String>{
            'en':
                'You have written eleven steps for the hire. How many of them happen this week?',
            'pt':
                'Escreveu onze passos para a contratação. Quantos acontecem esta semana?',
          },
        ),
        ChatMessage(
          id: 'ses3-m2',
          author: MessageAuthor.user,
          sentAt: daysAgo(13),
          text: <String, String>{
            'en': 'Two, realistically.',
            'pt': 'Dois, realisticamente.',
          },
        ),
        ChatMessage(
          id: 'ses3-m3',
          author: MessageAuthor.coach,
          sentAt: daysAgo(13),
          text: <String, String>{
            'en':
                'Then the other nine are decoration until those two are done. Keep the list, work the two, and let the plan earn the rest.',
            'pt':
                'Então os outros nove são decoração até esses dois estarem feitos. Guarde a lista, trabalhe os dois, e deixe o plano merecer o resto.',
          },
        ),
      ],
    ),
    CoachingSession(
      id: 'ses-4',
      startedAt: daysAgo(19),
      durationMinutes: 31,
      principle: Principle.purpose,
      summary: <String, String>{
        'en': 'First session. What the next year is actually for.',
        'pt': 'Primeira sessão. Para que serve mesmo o próximo ano.',
      },
      messages: <ChatMessage>[
        ChatMessage(
          id: 'ses4-m1',
          author: MessageAuthor.coach,
          sentAt: daysAgo(19),
          text: <String, String>{
            'en':
                'You wrote that you want to be given a team. Tell me what you would do with one that you cannot do now.',
            'pt':
                'Escreveu que quer que lhe deem uma equipa. Diga-me o que faria com ela que não pode fazer agora.',
          },
        ),
        ChatMessage(
          id: 'ses4-m2',
          author: MessageAuthor.user,
          sentAt: daysAgo(19),
          text: <String, String>{
            'en': 'Work on the decisions instead of the files.',
            'pt': 'Trabalhar nas decisões em vez dos ficheiros.',
          },
        ),
        ChatMessage(
          id: 'ses4-m3',
          author: MessageAuthor.coach,
          sentAt: daysAgo(19),
          text: <String, String>{
            'en':
                'Then the team is not the goal. The decisions are. You can start making them before anyone gives you permission. Where would you start?',
            'pt':
                'Então a equipa não é o objetivo. As decisões são. Pode começar a tomá-las antes de alguém lhe dar permissão. Por onde começaria?',
          },
        ),
        ChatMessage(
          id: 'ses4-m4',
          author: MessageAuthor.user,
          sentAt: daysAgo(19),
          text: <String, String>{
            'en': 'The relaunch. Nobody has actually said it is mine to run.',
            'pt':
                'O relançamento. Ninguém disse mesmo que sou eu a conduzi-lo.',
          },
        ),
      ],
    ),
  ];

  // --- Notifications ------------------------------------------------------

  static List<AppNotification> get notifications => <AppNotification>[
    AppNotification(
      id: 'not-1',
      type: NotificationType.goalNudge,
      receivedAt: hoursAgo(5),
      title: <String, String>{
        'en': 'The timeline is still unsent',
        'pt': 'O cronograma continua por enviar',
      },
      body: <String, String>{
        'en':
            'Sending it to Aleixo has been today’s action for two days. Praxis is contact, not readiness.',
        'pt':
            'Enviá-lo ao Aleixo é a ação do dia há dois dias. Praxis é contacto, não prontidão.',
      },
    ),
    AppNotification(
      id: 'not-2',
      type: NotificationType.principleOfDay,
      receivedAt: hoursAgo(9),
      isRead: true,
      title: <String, String>{'en': 'Praxis', 'pt': 'Praxis'},
      body: <String, String>{
        'en':
            'A plan that has not met reality is still a draft. Show one unfinished thing to one person today.',
        'pt':
            'Um plano que não encontrou a realidade ainda é um rascunho. Mostre hoje uma coisa por acabar a uma pessoa.',
      },
    ),
    AppNotification(
      id: 'not-3',
      type: NotificationType.milestone,
      receivedAt: daysAgo(2),
      title: <String, String>{
        'en': 'Budget approved by finance',
        'pt': 'Orcamento aprovado pelas finanças',
      },
      body: <String, String>{
        'en':
            'Third milestone closed on the Q4 relaunch. One left before the internal preview.',
        'pt':
            'Terceiro marco fechado no relançamento Q4. Falta um antes da apresentação interna.',
      },
    ),
    AppNotification(
      id: 'not-4',
      type: NotificationType.exerciseReminder,
      receivedAt: daysAgo(3),
      isRead: true,
      title: <String, String>{
        'en': 'One Real Hour is waiting',
        'pt': 'Uma Hora a Sério está à espera',
      },
      body: <String, String>{
        'en': 'Seven minutes, and it is the one that fits this week.',
        'pt': 'Sete minutos, e é o que encaixa nesta semana.',
      },
    ),
    AppNotification(
      id: 'not-5',
      type: NotificationType.reengagement,
      receivedAt: daysAgo(4),
      isRead: true,
      title: <String, String>{
        'en': 'Three days without a block',
        'pt': 'Três dias sem bloco',
      },
      body: <String, String>{
        'en':
            'Your deep work goal has not moved since Friday. Half an hour still counts.',
        'pt':
            'O seu objetivo de trabalho profundo não se move desde sexta. Meia hora ainda conta.',
      },
    ),
    AppNotification(
      id: 'not-6',
      type: NotificationType.milestone,
      receivedAt: daysAgo(6),
      isRead: true,
      title: <String, String>{'en': 'Goal closed', 'pt': 'Objetivo fechado'},
      body: <String, String>{
        'en':
            'Hire and onboard the second designer is complete. That is one full cycle closed at Perfection.',
        'pt':
            'Contratar e integrar o segundo designer está completo. É um ciclo inteiro fechado em Perfection.',
      },
    ),
  ];

  static Map<String, bool> get notificationPreferences => <String, bool>{
    'notifications.pref.goalNudges': true,
    'notifications.pref.principleOfDay': true,
    'notifications.pref.reengagement': false,
    'notifications.pref.exerciseReminders': true,
    'notifications.pref.quietHours': true,
  };

  // --- Progress -----------------------------------------------------------

  /// Twenty-one days of activity, oldest first. Two quiet days break the
  /// streak early on, which is what makes the chart believable.
  static List<ProgressSnapshot> get progressHistory {
    const List<List<num>> pattern = <List<num>>[
      <num>[1, 1, 0.06],
      <num>[2, 0, 0.09],
      <num>[1, 1, 0.14],
      <num>[0, 0, 0.14],
      <num>[2, 1, 0.19],
      <num>[1, 0, 0.21],
      <num>[0, 0, 0.21],
      <num>[3, 1, 0.28],
      <num>[2, 0, 0.31],
      <num>[1, 1, 0.30],
      <num>[2, 0, 0.34],
      <num>[1, 0, 0.35],
      <num>[3, 1, 0.42],
      <num>[2, 0, 0.44],
      <num>[1, 1, 0.43],
      <num>[2, 0, 0.46],
      <num>[1, 0, 0.47],
      <num>[2, 1, 0.51],
      <num>[3, 0, 0.53],
      <num>[1, 1, 0.52],
      <num>[2, 0, 0.55],
    ];
    return <ProgressSnapshot>[
      for (int i = 0; i < pattern.length; i++)
        ProgressSnapshot(
          date: daysAgo(pattern.length - 1 - i),
          goalCompletion: pattern[i][2].toDouble(),
          actionsCompleted: pattern[i][0].toInt(),
          exercisesCompleted: pattern[i][1].toInt(),
        ),
    ];
  }

  static Map<Principle, int> get practiceByPrinciple => <Principle, int>{
    Principle.purpose: 3,
    Principle.passion: 2,
    Principle.planning: 4,
    Principle.praxis: 3,
    Principle.persistence: 1,
    Principle.progress: 2,
    Principle.perfection: 1,
  };

  static Map<String, int> get headlineStats => <String, int>{
    'completionRate': 62,
    'streak': 12,
    'sessions': 4,
    'actions': 31,
  };

  /// Share of the seven-principle cycle closed so far.
  static double get cycleCompletion => 3 / 7;

  // --- Plans --------------------------------------------------------------

  static List<SubscriptionPlan> get plans => const <SubscriptionPlan>[
    SubscriptionPlan(
      tier: SubscriptionTier.trial,
      nameKey: 'subscription.plan.trial',
      price: AppConstants.trialPrice,
      periodKey: 'subscription.perTrial',
      featureValueKeys: includedFeatureValueKeys,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.student,
      nameKey: 'subscription.plan.student',
      price: AppConstants.studentMonthlyPrice,
      periodKey: 'subscription.perMonth',
      featureValueKeys: includedFeatureValueKeys,
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.professional,
      nameKey: 'subscription.plan.professional',
      price: AppConstants.professionalMonthlyPrice,
      periodKey: 'subscription.perMonth',
      featureValueKeys: includedFeatureValueKeys,
    ),
  ];

  /// What every tier includes, trial and monthly alike. The plans differ in
  /// price alone, so they share one map rather than repeating it.
  static const Map<String, String> includedFeatureValueKeys = <String, String>{
    'subscription.feature.coaching': 'subscription.feature.coaching.premium',
    'subscription.feature.memory': 'subscription.feature.memory.premium',
    'subscription.feature.exercises': 'subscription.feature.exercises.premium',
    'subscription.feature.goals': 'subscription.feature.goals.premium',
    'subscription.feature.personalisation':
        'subscription.feature.personalisation.premium',
    'subscription.feature.progress': 'subscription.feature.progress.premium',
  };

  /// What an account reaches before the trial is taken. The comparison table
  /// puts this beside [includedFeatureValueKeys], which is what shows the
  /// user what the trial actually opens.
  static const Map<String, String> lockedFeatureValueKeys = <String, String>{
    'subscription.feature.coaching': 'subscription.feature.coaching.free',
    'subscription.feature.memory': 'subscription.feature.memory.free',
    'subscription.feature.exercises': 'subscription.feature.exercises.free',
    'subscription.feature.goals': 'subscription.feature.goals.free',
    'subscription.feature.personalisation':
        'subscription.feature.personalisation.free',
    'subscription.feature.progress': 'subscription.feature.progress.free',
  };

  /// What the trial screen lists as opening up the moment it is taken.
  static const List<String> trialUnlockKeys = <String>[
    'trial.unlock.coach',
    'trial.unlock.exercises',
    'trial.unlock.goals',
    'trial.unlock.progress',
    'trial.unlock.library',
  ];

  /// Feature rows in the order the comparison table renders them.
  static const List<String> planFeatureKeys = <String>[
    'subscription.feature.coaching',
    'subscription.feature.memory',
    'subscription.feature.exercises',
    'subscription.feature.goals',
    'subscription.feature.personalisation',
    'subscription.feature.progress',
  ];

  // --- Management console -------------------------------------------------

  /// Accounts listed in the admin console.
  static List<User> get adminUsers => <User>[
    user,
    User(
      id: 'user-aleixo',
      name: 'Aleixo Muianga',
      email: 'aleixo.muianga@lumeconsult.co.mz',
      joinedAt: daysAgo(64),
      currentPrinciple: Principle.planning,
      cycleDay: 8,
      dayStreak: 5,
      tier: SubscriptionTier.professional,
      activity: UserActivity.professional,
    ),
    User(
      id: 'user-helena',
      name: 'Helena Sitoe',
      email: 'helena.sitoe@casadaspalavras.pt',
      joinedAt: daysAgo(41),
      currentPrinciple: Principle.persistence,
      cycleDay: 26,
      dayStreak: 19,
      tier: SubscriptionTier.student,
      activity: UserActivity.studentMinorities,
    ),
    User(
      id: 'user-nuno',
      name: 'Nuno Bragança',
      email: 'nuno.braganca@ateliernorte.pt',
      joinedAt: daysAgo(12),
      currentPrinciple: Principle.purpose,
      cycleDay: 3,
      dayStreak: 2,
      tier: SubscriptionTier.trial,
    ),
    User(
      id: 'user-dalia',
      name: 'Dália Fernandes',
      email: 'dalia.fernandes@vertentesul.br',
      joinedAt: daysAgo(97),
      currentPrinciple: Principle.perfection,
      cycleDay: 34,
      dayStreak: 41,
      tier: SubscriptionTier.professional,
      activity: UserActivity.professional,
    ),
    User(
      id: 'user-tomas',
      name: 'Tomás Ncube',
      email: 'tomas.ncube@bairrodigital.co.mz',
      joinedAt: daysAgo(29),
      currentPrinciple: Principle.passion,
      cycleDay: 11,
      dayStreak: 0,
      tier: SubscriptionTier.trial,
    ),
  ];

  static Map<String, String> get adminStats => <String, String>{
    'admin.stat.users': '2,847',
    'admin.stat.active': '1,312',
    'admin.stat.premium': '38%',
    'admin.stat.sessions': '4,061',
  };
}
